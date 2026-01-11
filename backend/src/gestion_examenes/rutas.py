from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import func
from typing import List, Optional
from datetime import date
from pydantic import BaseModel

from ..configuracion.base_datos import obtener_db
from ..compartido.utilidades import obtener_siguiente_lunes, obtener_siguiente_dia_semana
from . import modelos as modelos_examenes, esquemas
from ..gestion_academica import modelos as modelos_academica
from ..gestion_horarios import modelos as modelos_horarios
from ..notificaciones import modelos as modelos_notif

router = APIRouter(
    prefix="/api",
    tags=["Gestión de Exámenes"]
)

@router.get("/tipos_examen", response_model=List[esquemas.TipoExamen])
def get_tipos_examen(db: Session = Depends(obtener_db)):
    tipos = db.query(modelos_examenes.TipoExamen).all()
    if not tipos:
        defaults = ["Parcial", "Ordinario", "Extraordinario"]
        for nombre in defaults:
            db.add(modelos_examenes.TipoExamen(nombre=nombre))
        db.commit()
        tipos = db.query(modelos_examenes.TipoExamen).all()
    return tipos

@router.get("/examenes", response_model=List[esquemas.Examen])
def get_examenes(db: Session = Depends(obtener_db)):
    # Lógica robusta para obtener exámenes con todas las relaciones
    examenes = db.query(modelos_examenes.Examen).join(
        modelos_examenes.Examen.materia
    ).join(
        modelos_academica.Materia.carrera
    ).options(
        contains_eager(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.profesor),
        contains_eager(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.carrera),
        joinedload(modelos_examenes.Examen.aula),
        joinedload(modelos_examenes.Examen.grupo)
    ).all()
    
    # Post-procesamiento
    for ex in examenes:
        if ex.materia and ex.materia.carrera:
            ex.materia.carrera_nombre = ex.materia.carrera.nombre
        if ex.grupo:
            ex.grupo_id = ex.grupo.id
            
    return examenes

@router.post("/examenes", response_model=esquemas.Examen)
def create_examen(examen: esquemas.ExamenCreate, db: Session = Depends(obtener_db)):
    tipo_obj = db.query(modelos_examenes.TipoExamen).filter(modelos_examenes.TipoExamen.id == examen.tipo_examen_id).first()
    if not tipo_obj:
        raise HTTPException(status_code=404, detail="Tipo de examen no encontrado")
    
    db_examen = modelos_examenes.Examen(
        fecha=examen.fecha,
        hora_inicio=examen.hora_inicio,
        hora_fin=examen.hora_fin,
        tipo=tipo_obj.nombre,
        materia_id=examen.materia_id,
        aula_id=examen.aula_id,
        grupo_id=examen.grupo_id
    )
    db.add(db_examen)
    db.commit()
    db.refresh(db_examen)
    
    # Recargar para devolver esquema completo
    return db.query(modelos_examenes.Examen).options(
        joinedload(modelos_examenes.Examen.materia),
        joinedload(modelos_examenes.Examen.aula),
        joinedload(modelos_examenes.Examen.grupo)
    ).filter(modelos_examenes.Examen.id == db_examen.id).first()

class GenerarExamenesSelection(BaseModel):
    materiaId: int
    grupoId: int
    academiaId: Optional[str] = None # Puede venir como ID o "si"

@router.post("/generar-examenes", response_model=List[esquemas.Examen])
def generar_examenes(
    carrera_id: int, 
    seleccion: List[GenerarExamenesSelection], 
    db: Session = Depends(obtener_db)
):
    from datetime import timedelta
    # Validaciones carrera
    carrera = db.query(modelos_academica.Carrera).filter(modelos_academica.Carrera.id == carrera_id).first()
    if not carrera:
        raise HTTPException(status_code=404, detail=f"Carrera con ID {carrera_id} no encontrada.")

    # Agrupar por grupo para evitar choques el mismo día para el mismo grupo
    seleccion_por_grupo = {}
    for item in seleccion:
        if item.grupoId not in seleccion_por_grupo:
            seleccion_por_grupo[item.grupoId] = []
        seleccion_por_grupo[item.grupoId].append({
            'm_id': item.materiaId,
            'aca_id': item.academiaId
        })

    fecha_lunes_inicio = obtener_siguiente_lunes(date.today())

    for g_id, materias_info in seleccion_por_grupo.items():
        fechas_usadas_grupo = set()
        
        for m_info in materias_info:
            m_id = m_info['m_id']
            aca_val = m_info['aca_id']
            
            # Borrar previo
            db.query(modelos_examenes.Examen).filter(
                modelos_examenes.Examen.materia_id == m_id,
                modelos_examenes.Examen.grupo_id == g_id
            ).delete(synchronize_session=False)
            db.commit()

            # Obtener horarios
            horarios = db.query(modelos_horarios.Horario).filter(
                modelos_horarios.Horario.materia_id == m_id,
                modelos_horarios.Horario.grupo_id == g_id
            ).all()

            if not horarios:
                continue

            fecha_exa = None
            horario_ref = None

            # Normalización básica de nombres de días para el mapa de utilidades
            def normalizar_dia(dia):
                d = dia.upper()
                if d == 'MIERCOLES': return 'MIÉRCOLES'
                if d == 'SABADO': return 'SÁBADO'
                return d

            # 1. Intentar encontrar un día que coincida con el horario de clase y esté libre
            for h in horarios:
                dia_norm = normalizar_dia(h.dia_semana)
                try:
                    f_intento = obtener_siguiente_dia_semana(fecha_lunes_inicio, dia_norm)
                    if f_intento not in fechas_usadas_grupo:
                        fecha_exa = f_intento
                        horario_ref = h
                        break
                except ValueError:
                    continue
            
            # 2. Si hay choque o no hay horario, buscar el primer día libre de la semana
            if not fecha_exa:
                dias_semana = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']
                offset_semanal = 0
                while not fecha_exa:
                    for d_nom in dias_semana:
                        f_intento = obtener_siguiente_dia_semana(fecha_lunes_inicio + timedelta(days=offset_semanal), d_nom)
                        if f_intento not in fechas_usadas_grupo:
                            fecha_exa = f_intento
                            horario_ref = horarios[0] if horarios else None
                            break
                    if not fecha_exa:
                        offset_semanal += 7 # Probar siguiente semana
                    if offset_semanal > 28: # Evitar bucles infinitos por si acaso
                        break

            if fecha_exa and horario_ref:
                # Procesar academia_id
                final_aca_id = None
                if aca_val and aca_val.isdigit():
                    final_aca_id = int(aca_val)
                
                nuevo_examen = modelos_examenes.Examen(
                    fecha=fecha_exa,
                    hora_inicio=horario_ref.hora_inicio,
                    hora_fin=horario_ref.hora_fin,
                    tipo='PARCIAL',
                    materia_id=m_id,
                    aula_id=horario_ref.aula_id,
                    grupo_id=g_id,
                    academia_id=final_aca_id,
                    status='borrador'
                )
                
                # Si aca_val es "si", tal vez poner algo en observaciones
                if aca_val == 'si':
                    nuevo_examen.comentarios_rechazo = "Materia con Academia (General)" # Reutilizando campo o similar si no hay observaciones
                
                db.add(nuevo_examen)
                fechas_usadas_grupo.add(fecha_exa)
    
    db.commit()
    return get_examenes(db)

@router.put("/examenes/{examen_id}", response_model=esquemas.Examen)
def update_examen(examen_id: int, datos: esquemas.ExamenUpdate, db: Session = Depends(obtener_db)):
    examen = db.query(modelos_examenes.Examen).get(examen_id)
    if not examen:
        raise HTTPException(status_code=404, detail="Examen no encontrado")
    
    if datos.fecha:
        examen.fecha = datos.fecha
    if datos.hora_inicio:
        examen.hora_inicio = datos.hora_inicio
    if datos.hora_fin:
        examen.hora_fin = datos.hora_fin
    if datos.aula_id:
        examen.aula_id = datos.aula_id
        
    db.commit()
    db.refresh(examen)
    
    # Recargar para devolver esquema completo
    return db.query(modelos_examenes.Examen).options(
        joinedload(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.profesor),
        joinedload(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.carrera),
        joinedload(modelos_examenes.Examen.aula),
        joinedload(modelos_examenes.Examen.grupo)
    ).filter(modelos_examenes.Examen.id == examen.id).first()

@router.put("/examenes/{examen_id}/sinodal")
def assign_sinodal(examen_id: int, sinodal_data: dict, db: Session = Depends(obtener_db)):
    examen = db.query(modelos_examenes.Examen).join(
        modelos_examenes.Examen.materia
    ).filter(modelos_examenes.Examen.id == examen_id).first()
    
    if not examen:
        raise HTTPException(status_code=404, detail="Examen no encontrado")

    sinodal_id = sinodal_data.get("sinodal_id")
    if sinodal_id:
        sinodal_id = int(sinodal_id)
        # Validar profesor
        profesor = db.query(modelos_academica.Profesor).filter(modelos_academica.Profesor.id == sinodal_id).first()
        if not profesor:
            raise HTTPException(status_code=404, detail="Profesor sinodal no encontrado")
        
        if examen.materia and examen.materia.profesor_id == sinodal_id:
             raise HTTPException(status_code=400, detail="El sinodal no puede ser el titular")
             
        examen.sinodal_id = sinodal_id
    else:
        examen.sinodal_id = None
        
    db.commit()
    db.refresh(examen)
    return {"message": "Sinodal asignado", "sinodal_id": examen.sinodal_id}

@router.get("/clean-duplicates")
def clean_duplicates_endpoint(db: Session = Depends(obtener_db)):
    # Encontrar duplicados (mismo grupo, misma materia)
    subquery = db.query(
        modelos_examenes.Examen.materia_id,
        modelos_examenes.Examen.grupo_id,
        func.count(modelos_examenes.Examen.id).label('count')
    ).group_by(
        modelos_examenes.Examen.materia_id,
        modelos_examenes.Examen.grupo_id
    ).having(func.count(modelos_examenes.Examen.id) > 1).subquery()
    
    duplicados = db.query(subquery).all()
    
    total_eliminados = 0
    # duplicados es una lista de Row(materia_id, grupo_id, count)
    for row in duplicados:
        # Acceder a los campos por índice o nombre si es posible, subquery devuelve tupla
        m_id = row[0]
        g_id = row[1]
        
        examenes = db.query(modelos_examenes.Examen).filter(
            modelos_examenes.Examen.materia_id == m_id,
            modelos_examenes.Examen.grupo_id == g_id
        ).order_by(modelos_examenes.Examen.fecha.asc()).all()
        
        # Dejar el primero, borrar el resto
        for ex in examenes[1:]:
            db.delete(ex)
            total_eliminados += 1
            
    db.commit()
    db.commit()
    return {"message": f"Se han eliminado {total_eliminados} exámenes duplicados."}

@router.post("/examenes/enviar-revision")
def enviar_revision(carrera_id: int, grupo_id: Optional[int] = None, db: Session = Depends(obtener_db)):
    # Si grupo_id es 0, lo tratamos como None (todos los grupos)
    if grupo_id == 0:
        grupo_id = None

    carrera = db.query(modelos_academica.Carrera).get(carrera_id)
    if not carrera:
         raise HTTPException(status_code=404, detail="Carrera no encontrada")

    # Identificar grupos a procesar
    grupos_ids = []
    if grupo_id:
        grupos_ids = [grupo_id]
    else:
        # Encontrar todos los grupos de la carrera que tengan exámenes en borrador
        # Hacemos distinct de grupo_id
        res = db.query(modelos_examenes.Examen.grupo_id).join(
            modelos_examenes.Examen.materia
        ).filter(
            modelos_academica.Materia.carrera_id == carrera_id,
            modelos_examenes.Examen.status.in_(['borrador', 'rechazado'])
        ).distinct().all()
        grupos_ids = [r[0] for r in res]
    
    if not grupos_ids:
        return {"message": "No hay exámenes pendientes de enviar (borradores o rechazados)."}
    
    count_grupos = 0
    
    for g_id in grupos_ids:
        examenes = db.query(modelos_examenes.Examen).join(
            modelos_examenes.Examen.materia
        ).filter(
            modelos_examenes.Examen.grupo_id == g_id,
            modelos_academica.Materia.carrera_id == carrera_id,
            modelos_examenes.Examen.status.in_(['borrador', 'rechazado'])
        ).all()
        
        if not examenes:
            continue
            
        for ex in examenes:
            ex.status = 'pendiente_aprobacion'
            ex.fecha_envio = date.today()
            # Limpiar comentarios de rechazo al re-enviar
            ex.comentarios_rechazo = None
        
        grupo = db.query(modelos_academica.Grupo).get(g_id)
        msg = f"El Jefe de Carrera de {carrera.nombre} ha enviado los exámenes del grupo {grupo.nombre_grupo} para revisión."
        
        notif = modelos_notif.Notificacion(
            mensaje=msg,
            destinatario_rol='servicios_escolares',
            tipo='envio_revision',
            referencia_id=g_id,
            referencia_tipo='grupo',
            carrera=carrera.nombre
        )
        db.add(notif)
        count_grupos += 1
        
    db.commit()
    
    if count_grupos == 0:
         return {"message": "No se enviaron exámenes (posiblemente ya estaban enviados)."}
         
    return {"message": f"Se han enviado los exámenes de {count_grupos} grupo(s) a revisión exitosamente."}

class RevisionRequest(BaseModel):
    carrera_id: int
    grupo_id: Optional[int] = None
    accion: str # 'aprobar', 'rechazar'
    comentarios: Optional[str] = None
    motivo: Optional[str] = None

@router.post("/examenes/revision-grupo")
def revision_grupo(datos: RevisionRequest, db: Session = Depends(obtener_db)):
    if datos.grupo_id == 0:
        datos.grupo_id = None

    carrera = db.query(modelos_academica.Carrera).get(datos.carrera_id)
    if not carrera:
         raise HTTPException(status_code=404, detail="Carrera no encontrada")

    grupos_ids = []
    if datos.grupo_id:
        grupos_ids = [datos.grupo_id]
    else:
        # Buscar todos los grupos de la carrera con examenes pendientes
        res = db.query(modelos_examenes.Examen.grupo_id).join(
            modelos_examenes.Examen.materia
        ).filter(
            modelos_academica.Materia.carrera_id == datos.carrera_id,
            modelos_examenes.Examen.status == 'pendiente_aprobacion'
        ).distinct().all()
        grupos_ids = [r[0] for r in res]
    
    if not grupos_ids:
        raise HTTPException(status_code=404, detail="No hay exámenes pendientes para revisión.")

    nuevo_status = 'aprobado' if datos.accion == 'aprobar' else 'rechazado'
    count_grupos = 0

    for g_id in grupos_ids:
        examenes = db.query(modelos_examenes.Examen).join(modelos_examenes.Examen.materia).filter(
            modelos_examenes.Examen.grupo_id == g_id,
            modelos_academica.Materia.carrera_id == datos.carrera_id,
            modelos_examenes.Examen.status == 'pendiente_aprobacion'
        ).all()
        
        if not examenes:
            continue
            
        for ex in examenes:
            ex.status = nuevo_status
            if nuevo_status == 'aprobado':
                ex.fecha_aprobacion = date.today()
            else:
                sep = " - " if datos.motivo and datos.comentarios else ""
                comento = (datos.motivo or "") + sep + (datos.comentarios or "")
                ex.comentarios_rechazo = comento

        grupo = db.query(modelos_academica.Grupo).get(g_id)
        mensaje_inicio = "Aprobada" if datos.accion == 'aprobar' else "Rechazada"
        msg = f"Revisión {mensaje_inicio} para el grupo {grupo.nombre_grupo} de {carrera.nombre}."

        notif = modelos_notif.Notificacion(
            mensaje=msg,
            destinatario_rol='jefe_carrera',
            tipo='aprobacion' if datos.accion == 'aprobar' else 'rechazo',
            referencia_id=g_id,
            referencia_tipo='grupo',
            carrera=carrera.nombre
        )
        db.add(notif)
        count_grupos += 1
    
    db.commit()
    
    return {"message": f"Exámenes {nuevo_status}s para {count_grupos} grupo(s)."}
