from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload, contains_eager
from typing import List
from datetime import date

from ..configuracion.base_datos import obtener_db
from ..compartido.utilidades import obtener_siguiente_lunes, obtener_siguiente_dia_semana
from . import modelos as modelos_examenes, esquemas
from ..gestion_academica import modelos as modelos_academica
from ..gestion_horarios import modelos as modelos_horarios

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

@router.post("/generar-examenes", response_model=List[esquemas.Examen])
def generar_examenes(carrera_id: int, grupo_id: int, db: Session = Depends(obtener_db)):
    # Validaciones
    carrera = db.query(modelos_academica.Carrera).filter(modelos_academica.Carrera.id == carrera_id).first()
    if not carrera:
        raise HTTPException(status_code=404, detail=f"Carrera con ID {carrera_id} no encontrada.")
    grupo = db.query(modelos_academica.Grupo).filter(modelos_academica.Grupo.id == grupo_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail=f"Grupo con ID {grupo_id} no encontrado.")

    # Borrar exámenes previos SOLO del grupo que se está generando
    # Anteriormente borraba toda la carrera, lo que impedía guardar múltiples grupos
    db.query(modelos_examenes.Examen).filter(
        modelos_examenes.Examen.grupo_id == grupo_id
    ).delete(synchronize_session=False)
    db.commit()

    # Obtener horarios
    horarios = db.query(modelos_horarios.Horario).join(
        modelos_horarios.Horario.materia
    ).filter(
        modelos_horarios.Horario.grupo_id == grupo_id,
        modelos_academica.Materia.carrera_id == carrera_id
    ).all()

    if not horarios:
        raise HTTPException(status_code=404, detail=f"No se encontraron horarios para generar exámenes.")

    examenes_a_crear = []
    fecha_inicio = obtener_siguiente_lunes(date.today())
    slots_ocupados = {}

    for horario in horarios:
        if not horario.materia or not horario.aula_id:
            continue

        dia_sem = horario.dia_semana.upper()
        hora_str = horario.hora_inicio.strftime('%H:%M')
        
        
        # Eliminamos la restricción de slots ocupados para permitir múltiples exámenes a la misma hora
        # if dia_sem not in slots_ocupados:
        #     slots_ocupados[dia_sem] = {}
        # if hora_str in slots_ocupados[dia_sem]:
        #     continue 
        # slots_ocupados[dia_sem][hora_str] = True
        
        fecha_examen = obtener_siguiente_dia_semana(fecha_inicio, dia_sem)
        
        nuevo_examen = modelos_examenes.Examen(
            fecha=fecha_examen,
            hora_inicio=horario.hora_inicio,
            hora_fin=horario.hora_fin,
            tipo='PARCIAL',
            materia_id=horario.materia_id,
            aula_id=horario.aula_id,
            grupo_id=horario.grupo_id
        )
        examenes_a_crear.append(nuevo_examen)
    
    if not examenes_a_crear:
         raise HTTPException(status_code=404, detail="No se pudieron generar nuevos exámenes.")
    
    db.add_all(examenes_a_crear)
    db.commit()

    return get_examenes(db) # Reutilizar la función de lectura

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
