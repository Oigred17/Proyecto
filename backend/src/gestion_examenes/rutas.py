from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload, contains_eager
from sqlalchemy import func
from typing import List, Optional, Union
from datetime import date, datetime, timedelta
# FORCE UPDATE: 2026-01-21 v14 - Ajuste duración Extraordinarios (1h) y Ordinarios (2h)
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

def normalizar_dia(dia):
    if not dia: return 'LUNES'
    d = dia.upper()
    if d == 'MIERCOLES': return 'MIÉRCOLES'
    if d == 'SABADO': return 'SÁBADO'
    return d

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
        joinedload(modelos_examenes.Examen.grupo),
        joinedload(modelos_examenes.Examen.sinodal),
        joinedload(modelos_examenes.Examen.aplicador)
    ).all()

    # Pre-cargar horarios con materias para evitar N+1 y errores de detección
    horarios = db.query(modelos_horarios.Horario).options(joinedload(modelos_horarios.Horario.materia)).all()
    
    # Post-procesamiento
    for ex in examenes:
        if ex.materia and ex.materia.carrera:
            ex.materia.carrera_nombre = ex.materia.carrera.nombre
        if ex.grupo:
            ex.grupo_id = ex.grupo.id
        
        # Detección de Conflictos (limpiar los viejos de la DB)
        ex.tiene_conflictos = False
        ex.detalles_conflicto = None
        clashes = []
        for other in examenes:
            if ex.id == other.id: continue
            
            # Mismo aula, mismo tiempo (solo si tiene aula asignada)
            if ex.aula_id and ex.aula_id == other.aula_id and ex.fecha == other.fecha:
                if (ex.hora_inicio < other.hora_fin) and (ex.hora_fin > other.hora_inicio):
                    clashes.append(f"Aula ocupada por {other.materia.nombre if other.materia else 'otro examen'}")
            
            # Mismo grupo, mismo día
            if ex.grupo_id == other.grupo_id and ex.fecha == other.fecha:
                clashes.append("El grupo ya tiene otro examen este día")
        
        # 2. Choque con clases regulares (Inglés tiene prioridad absoluta)
        dias_map = {0:'Lunes', 1:'Martes', 2:'Miércoles', 3:'Jueves', 4:'Viernes', 5:'Sábado', 6:'Domingo'}
        dia_nom = dias_map[ex.fecha.weekday()]
        
        horario_con_ingles = False
        for h in horarios:
            if h.grupo_id == ex.grupo_id and h.dia_semana.upper() == dia_nom.upper():
                if (ex.hora_inicio < h.hora_fin) and (ex.hora_fin > h.hora_inicio):
                    m_obj = getattr(h, 'materia', None)
                    if m_obj and m_obj.nombre and m_obj.nombre.strip().upper() in ["INGLÉS", "INGLES"]:
                        if m_obj.id != ex.materia_id:
                            clashes.append("RESTRICCIÓN DE HORARIO: El grupo tiene clase de Inglés. Debe cambiar el DÍA o la HORA (no solo el aula).")
                            horario_con_ingles = True
                            break # No buscamos más si ya hay choque con Inglés

        # 3. Choque de aula con otro grupo (solo si el horario está libre de Inglés)
        if not horario_con_ingles and ex.aula_id:
            for h in horarios:
                if h.aula_id == ex.aula_id and h.dia_semana.upper() == dia_nom.upper() and h.grupo_id != ex.grupo_id:
                    if (ex.hora_inicio < h.hora_fin) and (ex.hora_fin > h.hora_inicio):
                        m_name = h.materia.nombre if h.materia else 'otro grupo'
                        clashes.append(f"Aula ocupada por clase de {m_name}")
                        break

        # 4. Sin aula asignada (ELIMINADO DEFINITIVAMENTE)
        # (Código borrado para evitar mensajes N/A)

        if clashes:
            ex.tiene_conflictos = True
            ex.detalles_conflicto = clashes[0] # Solo mostramos el conflicto más importante
            
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
    academiaId: Optional[Union[int, str]] = None 
    aplicadorId: Optional[int] = None
    modalidad: Optional[str] = None

class GenerarExamenesRequest(BaseModel):
    seleccion: List[GenerarExamenesSelection]
    tipoExamen: Optional[str] = 'Parcial 1'
    periodo: Optional[str] = None
    modalidad: Optional[str] = 'Escrito'

@router.post("/generar-examenes", response_model=List[esquemas.Examen])
def generar_examenes(
    carrera_id: int, 
    datos: GenerarExamenesRequest, 
    db: Session = Depends(obtener_db)
):
    try:
        print(f"DEBUG: Generando examenes para carrera={carrera_id}. Datos recibidos: {datos}")
        seleccion = datos.seleccion
        tipo_examen = (datos.tipoExamen or "PARCIAL").upper()
        modalidad_global = datos.modalidad or "Escrito"
        from datetime import timedelta
        
        # Determinar duración del examen según el tipo
        # Parciales y Extraordinarios: 1 hora, Ordinarios: 2 horas
        if 'PARCIAL' in tipo_examen or 'EXTRAORDINARIO' in tipo_examen:
            duracion_examen = timedelta(hours=1)
        else:  # ORDINARIO
            duracion_examen = timedelta(hours=2)
        print(f"DEBUG: Tipo examen: {tipo_examen}, Duración: {duracion_examen}")
        
        # Validaciones carrera
        carrera = db.query(modelos_academica.Carrera).filter(modelos_academica.Carrera.id == carrera_id).first()
        if not carrera:
            raise HTTPException(status_code=404, detail=f"Carrera con ID {carrera_id} no encontrada.")

        fecha_lunes_inicio = obtener_siguiente_lunes(date.today())

        # 1. Agrupar la selección por Academia (usando valor del UI o de la DB)
        academias_map = {} # academia_id -> list of seleccion items
        individuales = []   # list of seleccion items without academia

        for item in seleccion:
            materia = db.query(modelos_academica.Materia).get(item.materiaId)
            if not materia: continue
            
            # Prioridad: 1. ID de academia enviado, 2. Academia en DB
            aca_val = item.academiaId
            final_aca_id = None
            
            if aca_val and str(aca_val).isdigit():
                final_aca_id = int(aca_val)
            elif materia.academia_id:
                final_aca_id = materia.academia_id
                
            if final_aca_id:
                if final_aca_id not in academias_map:
                    academias_map[final_aca_id] = []
                academias_map[final_aca_id].append(item)
            elif aca_val == 'si':
                # Si dice "si" pero no tiene ID, lo agrupamos por nombre de materia para "simular" una academia ad-hoc
                pseudoid = f"materia_{materia.nombre}"
                if pseudoid not in academias_map:
                    academias_map[pseudoid] = []
                academias_map[pseudoid].append(item)
            else:
                individuales.append(item)

        # 0. Verificar duplicados antes de borrar
        # El usuario pidió bloquear la regeneración si ya existen exámenes ("borradores").
        for item in seleccion:
            existe = db.query(modelos_examenes.Examen).filter(
                modelos_examenes.Examen.materia_id == item.materiaId,
                modelos_examenes.Examen.grupo_id == item.grupoId
            ).first()
            if existe:
                 raise HTTPException(
                     status_code=400, 
                     detail=f"Ya existen horarios planificados para la materia {existe.materia.nombre} y grupo {existe.grupo.nombre_grupo}. Por favor, elimínelos manualmente si desea volver a generar."
                 )

        # Si no existen, limpiamos cualquier residuo (doble check)
        for item in seleccion:
            db.query(modelos_examenes.Examen).filter(
                modelos_examenes.Examen.materia_id == item.materiaId,
                modelos_examenes.Examen.grupo_id == item.grupoId
            ).delete()
        db.commit()

        import re

        def obtener_semestre(grupo_nombre):
            """Extrae el semestre del nombre del grupo (ej: 116-A -> 1, 103-B -> 1, 1114-C -> 11)."""
            if not grupo_nombre: return 0
            match = re.match(r'^(\d+)', str(grupo_nombre))
            if match:
                num_str = match.group(1)
                # Si tiene 4 dígitos (ej: 1114), los dos primeros son el semestre
                if len(num_str) >= 4:
                    try: return int(num_str[:-2])
                    except: return 0
                # Si tiene 3 dígitos (ej: 116, 103), el primero es el semestre
                elif len(num_str) == 3:
                    try: return int(num_str[0])
                    except: return 0
                # Si tiene 1 o 2 dígitos, es el semestre directo
                else:
                    try: return int(num_str)
                    except: return 0
            return 0

        # Tracking en memoria
        ocupacion_grupos = set() 
        ocupacion_semestres = set()
        ocupacion_aulas = {} 
        aulas_pool = db.query(modelos_academica.Aula).all()

        def poblar_ocupacion_existente():
            # Consideramos la semana completa (7 días)
            existentes = db.query(modelos_examenes.Examen).options(joinedload(modelos_examenes.Examen.grupo)).filter(
                modelos_examenes.Examen.fecha >= fecha_lunes_inicio,
                modelos_examenes.Examen.fecha <= fecha_lunes_inicio + timedelta(days=7)
            ).all()
            for ex in existentes:
                ocupacion_grupos.add((ex.fecha, ex.grupo_id))
                if ex.grupo:
                    sem = obtener_semestre(ex.grupo.nombre_grupo)
                    ocupacion_semestres.add((ex.fecha, ex.grupo.carrera_id, sem))
                if ex.aula_id not in ocupacion_aulas: ocupacion_aulas[ex.aula_id] = []
                ocupacion_aulas[ex.aula_id].append((ex.hora_inicio, ex.hora_fin, ex.fecha))
        
        def calcular_hora_fin(hora_inicio):
            """Calcula la hora de fin del examen basándose en la duración según el tipo de examen"""
            return (datetime.combine(date.today(), hora_inicio) + duracion_examen).time()

        poblar_ocupacion_existente()

        def slot_libre(grupo_id, aula_id, fecha, h_ini, h_fin, ignore_semestre=False, ignore_clases=False, ignore_grupo_ocupacion=False):
            # UN EXAMEN POR DÍA: Verificar que el grupo no tenga ya otro examen ese día
            # EXCEPCIÓN: Si ignore_grupo_ocupacion=True, permitimos múltiples exámenes del mismo grupo
            # (útil para academias donde todas las materias tienen examen el mismo día)
            if not ignore_grupo_ocupacion and (fecha, grupo_id) in ocupacion_grupos: 
                return False
            
            if not ignore_semestre:
                g_obj = db.query(modelos_academica.Grupo).get(grupo_id)
                if g_obj:
                    sem = obtener_semestre(g_obj.nombre_grupo)
                    if (fecha, g_obj.carrera_id, sem) in ocupacion_semestres: return False
            
            dias_map = {0:'Lunes', 1:'Martes', 2:'Miércoles', 3:'Jueves', 4:'Viernes', 5:'Sábado', 6:'Domingo'}
            dia_nom = dias_map[fecha.weekday()]

            # 1. Choque con otros exámenes en la misma aula
            if aula_id and aula_id in ocupacion_aulas:
                for ini, fin, f in ocupacion_aulas[aula_id]:
                    if f == fecha and (h_ini < fin) and (h_fin > ini): return False
            
            # 2. Choque con clases regulares en la misma aula (otro grupo)
            # IMPORTANTE: No podemos ocupar el aula de otro grupo que tiene clase a esa hora
            # Pero si ignore_clases=True, permitimos que el examen desaloje la clase regular del MISMO grupo
            # El ID 3 se considera 'SIN AULA' (virtual), no genera choques físicos
            if aula_id and int(aula_id) != 3:
                clash_clase = db.query(modelos_horarios.Horario).filter(
                    modelos_horarios.Horario.aula_id == aula_id,
                    func.upper(modelos_horarios.Horario.dia_semana) == dia_nom.upper(),
                    modelos_horarios.Horario.grupo_id != grupo_id  # Otro grupo
                ).all()
                for ch in clash_clase:
                    if (h_ini < ch.hora_fin) and (h_fin > ch.hora_inicio): 
                        return False  # No podemos ocupar el aula de otro grupo con clase

            # 3. Choque con Inglés (SAGRADA).
            # Verificamos si el grupo tiene Inglés en este slot (insensible a mayúsculas/acentos)
            clash_ingles = db.query(modelos_horarios.Horario).join(modelos_academica.Materia).filter(
                modelos_horarios.Horario.grupo_id == grupo_id,
                func.upper(modelos_horarios.Horario.dia_semana) == dia_nom.upper(),
                func.trim(func.upper(modelos_academica.Materia.nombre)).in_(['INGLÉS', 'INGLES', 'ingles', 'inglés'.upper()])
            ).first()
            
            if clash_ingles:
                print(f"DEBUG: Conflicto Inglés detectado para grupo {grupo_id} el {dia_nom} a las {h_ini}-{h_fin}")
                if (h_ini < clash_ingles.hora_fin) and (h_fin > clash_ingles.hora_inicio):
                    return False
                
            return True

        def find_best_aula(grupo_id, fecha, h_ini, h_fin, aula_ref_id=None, aulas_bloqueadas=set(), ignore_clases=False, ignore_grupo_ocupacion=False):
            # Para academias, ignore_clases=True significa que el grupo puede tener clase a esa hora
            # pero aún debemos verificar que el aula no esté ocupada por OTRO grupo con clase
            # ignore_grupo_ocupacion=True permite múltiples exámenes del mismo grupo el mismo día (para academias)
            if aula_ref_id and aula_ref_id not in aulas_bloqueadas:
                if slot_libre(grupo_id, aula_ref_id, fecha, h_ini, h_fin, ignore_semestre=True, ignore_clases=ignore_clases, ignore_grupo_ocupacion=ignore_grupo_ocupacion): return aula_ref_id
            for a in aulas_pool:
                if a.id in aulas_bloqueadas: continue
                if slot_libre(grupo_id, a.id, fecha, h_ini, h_fin, ignore_semestre=True, ignore_clases=ignore_clases, ignore_grupo_ocupacion=ignore_grupo_ocupacion): return a.id
            return None

        def registrar_slot(grupo_id, aula_id, fecha, h_ini, h_fin):
            ocupacion_grupos.add((fecha, grupo_id))
            g_obj = db.query(modelos_academica.Grupo).get(grupo_id)
            if g_obj:
                sem = obtener_semestre(g_obj.nombre_grupo)
                ocupacion_semestres.add((fecha, g_obj.carrera_id, sem))
            if aula_id and int(aula_id) != 3:
                if aula_id not in ocupacion_aulas: ocupacion_aulas[aula_id] = []
                ocupacion_aulas[aula_id].append((h_ini, h_fin, fecha))

        # 2. Procesar Academias
        for aca_id, items in academias_map.items():
            if not items:
                continue
                
            # Agrupar items por grupo - solo UN examen por grupo por día
            items_por_grupo = {}
            for it in items:
                if it.grupoId not in items_por_grupo:
                    items_por_grupo[it.grupoId] = []
                items_por_grupo[it.grupoId].append(it)
            
            # Para cada grupo, seleccionar solo UNA materia (la primera) para el primer día
            # Todos los grupos de la academia tendrán examen el mismo día y hora
            items_primer_dia = []
            for grupo_id, grupo_items in items_por_grupo.items():
                if grupo_items:
                    items_primer_dia.append(grupo_items[0])
            
            if not items_primer_dia:
                continue
            
            # Recolectar todos los horarios de las materias seleccionadas
            # para encontrar la mejor hora (donde más grupos tienen clase)
            todos_horarios_academia = []
            for it in items_primer_dia:
                horarios_it = db.query(modelos_horarios.Horario).filter(
                    modelos_horarios.Horario.materia_id == it.materiaId,
                    modelos_horarios.Horario.grupo_id == it.grupoId
                ).all()
                todos_horarios_academia.extend([(it.grupoId, it.materiaId, h) for h in horarios_it])
            
            fecha_final = None
            hora_inicio_final = None
            hora_fin_final = None
            asignacion_aulas = {} 

            def intentar_slot_academia(f_int, h_ini, h_fin):
                """
                Para academias (exámenes colegiados):
                - Todos los grupos tienen examen el mismo día y hora (primera materia de cada grupo)
                - UN SOLO examen por grupo por día
                - Buscamos aulas libres (no ocupadas por OTROS grupos con clase o actividades)
                - NO importa si el grupo tiene clase a esa hora (el examen la reemplaza)
                - Si no hay aula disponible, permitimos crear sin aula
                - RESTRICCIÓN ABSOLUTA: NO se puede programar si algún grupo tiene Inglés a esa hora
                """
                # Verificar que ningún grupo ya tenga un examen ese día
                for it in items_primer_dia:
                    if (f_int, it.grupoId) in ocupacion_grupos:
                        return False
                
                # VERIFICACIÓN DE INGLÉS: Antes de cualquier asignación, verificar que NINGÚN grupo
                # tenga clase de Inglés a esta hora en este día
                dias_map_inv = {0:'Lunes', 1:'Martes', 2:'Miércoles', 3:'Jueves', 4:'Viernes', 5:'Sábado', 6:'Domingo'}
                dia_nom_check = dias_map_inv[f_int.weekday()]
                
                for it in items_primer_dia:
                    # Buscar si este grupo tiene Inglés a esta hora
                    clash_ingles = db.query(modelos_horarios.Horario).join(modelos_academica.Materia).filter(
                        modelos_horarios.Horario.grupo_id == it.grupoId,
                        func.upper(modelos_horarios.Horario.dia_semana) == dia_nom_check.upper(),
                        func.trim(func.upper(modelos_academica.Materia.nombre)).in_(['INGLÉS', 'INGLES'])
                    ).first()
                    
                    if clash_ingles:
                        # Verificar si hay overlap de horas
                        if (h_ini < clash_ingles.hora_fin) and (h_fin > clash_ingles.hora_inicio):
                            print(f"DEBUG ACADEMIA: Slot rechazado por Inglés - Grupo {it.grupoId}, Día {dia_nom_check}, Hora {h_ini}-{h_fin}")
                            return False  # Rechazar este slot para toda la academia
                
                temp_aulas = set()
                temp_map = {}
                # Para academias, asignamos un aula por grupo (un examen por grupo)
                # Si no encontramos aula, permitimos None (SIN AULA)
                for it in items_primer_dia:
                    # Buscar aula preferida (donde normalmente tienen esta materia)
                    h_it = db.query(modelos_horarios.Horario).filter(
                        modelos_horarios.Horario.materia_id == it.materiaId,
                        modelos_horarios.Horario.grupo_id == it.grupoId
                    ).first()
                    pref_aula = h_it.aula_id if h_it else None
                    
                    # Buscar aula disponible 
                    # ignore_clases=True: permite que el grupo tenga clase a esa hora, pero 
                    # aún verifica que el aula no esté ocupada por OTRO grupo con clase
                    aula_encontrada = find_best_aula(it.grupoId, f_int, h_ini, h_fin, pref_aula, temp_aulas, ignore_clases=True, ignore_grupo_ocupacion=False)
                    # Si encontramos aula, la añadimos al set para evitar conflictos
                    if aula_encontrada:
                        temp_aulas.add(aula_encontrada)
                    # Permitimos None (SIN AULA) si no se encuentra disponible
                    temp_map[it.grupoId] = aula_encontrada
                return temp_map

            # Calcular cuántos grupos tienen clase a cada hora
            horario_scores = {}  # (hora_inicio, hora_fin) -> cantidad de grupos con esa hora
            
            for grupo_id, materia_id, h in todos_horarios_academia:
                key = (h.hora_inicio, h.hora_fin)
                if key not in horario_scores:
                    horario_scores[key] = set()
                horario_scores[key].add(grupo_id)
            
            # Convertir a lista ordenada por cantidad de grupos (más grupos = mejor)
            horarios_ordenados = sorted(
                horario_scores.items(),
                key=lambda x: len(x[1]),
                reverse=True
            ) if horario_scores else []

            # A. Intentar primero con las horas donde más grupos tienen clase
            for (h_ini, h_fin), grupos_con_hora in horarios_ordenados:
                # Intentar en cada día donde algún grupo tiene esa clase
                dias_intentados = set()
                for grupo_id, materia_id, h in todos_horarios_academia:
                    if h.hora_inicio == h_ini and h.hora_fin == h_fin:
                        dia_nom = normalizar_dia(h.dia_semana)
                        if dia_nom not in dias_intentados:
                            dias_intentados.add(dia_nom)
                            f_intento = obtener_siguiente_dia_semana(fecha_lunes_inicio, dia_nom)
                            res_map = intentar_slot_academia(f_intento, h_ini, h_fin)
                            if res_map:
                                fecha_final, hora_inicio_final, hora_fin_final, asignacion_aulas = f_intento, h_ini, h_fin, res_map
                                break
                    if fecha_final:
                        break
                if fecha_final:
                    break

            # B. Si no se encontró con los horarios ideales, intentar en otros días con esos horarios
            if not fecha_final:
                for (h_ini, h_fin), grupos_con_hora in horarios_ordenados:
                    for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                        f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                        res_map = intentar_slot_academia(f_int, h_ini, h_fin)
                        if res_map:
                            fecha_final, hora_inicio_final, hora_fin_final, asignacion_aulas = f_int, h_ini, h_fin, res_map
                            break
                    if fecha_final:
                        break

            # C. Si aún no se encontró, búsqueda exhaustiva de cualquier hueco libre (7am-9pm)
            # IMPORTANTE: Incluir 19:00 porque puede ser el único slot libre de Inglés para todos
            if not fecha_final:
                from datetime import time
                h_slots = [time(7,0), time(8,0), time(9,0), time(10,0), time(11,0), time(12,0), time(13,0), time(14,0), time(15,0), time(16,0), time(17,0), time(18,0), time(19,0)]
                for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                    f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                    for h_s in h_slots:
                        h_e = (datetime.combine(date.today(), h_s) + duracion_examen).time()
                        res_map = intentar_slot_academia(f_int, h_s, h_e)
                        if res_map:
                            fecha_final, hora_inicio_final, hora_fin_final, asignacion_aulas = f_int, h_s, h_e, res_map
                            break
                    if fecha_final:
                        break

            # Crear exámenes para la primera materia de cada grupo (mismo día y hora)
            if fecha_final:
                for it in items_primer_dia:
                    a_id = asignacion_aulas[it.grupoId]
                    # Solo registrar slot si hay aula (None no se registra en ocupacion_aulas pero sí en ocupacion_grupos)
                    if a_id:
                        registrar_slot(it.grupoId, a_id, fecha_final, hora_inicio_final, hora_fin_final)
                    else:
                        # Si no hay aula, solo registrar que el grupo está ocupado ese día
                        ocupacion_grupos.add((fecha_final, it.grupoId))
                        g_obj = db.query(modelos_academica.Grupo).get(it.grupoId)
                        if g_obj:
                            sem = obtener_semestre(g_obj.nombre_grupo)
                            ocupacion_semestres.add((fecha_final, g_obj.carrera_id, sem))
                    
                    db.add(modelos_examenes.Examen(
                        fecha=fecha_final, hora_inicio=hora_inicio_final, hora_fin=hora_fin_final,
                        tipo=tipo_examen, materia_id=it.materiaId, aula_id=a_id,
                        grupo_id=it.grupoId, academia_id=aca_id if isinstance(aca_id, int) else None,
                        aplicador_id=it.aplicadorId,
                        modalidad=it.modalidad or modalidad_global,
                        status='borrador'
                    ))
            else:
                # No se encontró slot común - esto no debería pasar con la búsqueda exhaustiva que incluye 19:00-21:00
                # pero si ocurre, lo registramos para debugging
                print(f"ADVERTENCIA ACADEMIA: No se encontró slot común para academia {aca_id}. Grupos: {[it.grupoId for it in items_primer_dia]}")
            
            # Ahora procesar las demás materias de cada grupo (una por día, distribuidas)
            for grupo_id, grupo_items in items_por_grupo.items():
                # Si hay más de una materia, procesar las restantes
                if len(grupo_items) > 1:
                    materias_restantes = grupo_items[1:]  # Todas excepto la primera
                    
                    for materia_item in materias_restantes:
                        # Buscar horario de esta materia
                        horarios_materia = db.query(modelos_horarios.Horario).filter(
                            modelos_horarios.Horario.materia_id == materia_item.materiaId,
                            modelos_horarios.Horario.grupo_id == materia_item.grupoId
                        ).all()
                        
                        if not horarios_materia:
                            continue
                        
                        ex_creado = False
                        # Intentar en horario original en otro día
                        for h in horarios_materia:
                            for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                                f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                                # Verificar que este grupo no tenga ya un examen ese día
                                if (f_int, materia_item.grupoId) in ocupacion_grupos:
                                    continue
                                
                                # SEGURIDAD: Verificar primero si el horario está libre de Inglés (y otras restricciones de tiempo)
                                # Pasamos aula_id=None para verificar solo restricciones de tiempo/calendario
                                if not slot_libre(materia_item.grupoId, None, f_int, h.hora_inicio, h.hora_fin, ignore_semestre=True):
                                     continue

                                aula_ok = find_best_aula(materia_item.grupoId, f_int, h.hora_inicio, h.hora_fin, h.aula_id, set(), ignore_clases=True, ignore_grupo_ocupacion=False)
                                # Si encontramos aula, usarla
                                if aula_ok:
                                    # Doble chequeo con el aula específica
                                    if slot_libre(materia_item.grupoId, aula_ok, f_int, h.hora_inicio, h.hora_fin, ignore_semestre=True, ignore_clases=True, ignore_grupo_ocupacion=False):
                                        registrar_slot(materia_item.grupoId, aula_ok, f_int, h.hora_inicio, h.hora_fin)
                                        db.add(modelos_examenes.Examen(
                                            fecha=f_int, hora_inicio=h.hora_inicio, hora_fin=h.hora_fin,
                                            tipo=tipo_examen, materia_id=materia_item.materiaId, aula_id=aula_ok,
                                            grupo_id=materia_item.grupoId, academia_id=aca_id if isinstance(aca_id, int) else None,
                                            aplicador_id=materia_item.aplicadorId,
                                            modalidad=materia_item.modalidad or modalidad_global,
                                            status='borrador'
                                        ))
                                        ex_creado = True
                                        break
                                else:
                                    # Si no hay aula disponible, crear examen sin aula (PERO SOLO SI EL SLOT DE TIEMPO ES VÁLIDO)
                                    if slot_libre(materia_item.grupoId, None, f_int, h.hora_inicio, h.hora_fin, ignore_semestre=True, ignore_clases=True, ignore_grupo_ocupacion=False):
                                        ocupacion_grupos.add((f_int, materia_item.grupoId))
                                        g_obj = db.query(modelos_academica.Grupo).get(materia_item.grupoId)
                                        if g_obj:
                                            sem = obtener_semestre(g_obj.nombre_grupo)
                                            ocupacion_semestres.add((f_int, g_obj.carrera_id, sem))
                                        db.add(modelos_examenes.Examen(
                                            fecha=f_int, hora_inicio=h.hora_inicio, hora_fin=h.hora_fin,
                                            tipo=tipo_examen, materia_id=materia_item.materiaId, aula_id=None,
                                            grupo_id=materia_item.grupoId, academia_id=aca_id if isinstance(aca_id, int) else None,
                                            aplicador_id=materia_item.aplicadorId,
                                            modalidad=materia_item.modalidad or modalidad_global,
                                            status='borrador'
                                        ))
                                        ex_creado = True
                                        break
                            if ex_creado:
                                break
                        
                        # Si no se encontró, buscar cualquier hueco disponible
                        if not ex_creado:
                            from datetime import time
                            # Búsqueda amplia 7am-9pm
                            h_slots = [time(7,0), time(8,0), time(9,0), time(10,0), time(11,0), time(12,0), time(13,0), time(14,0), time(15,0), time(16,0), time(17,0), time(18,0), time(19,0)]
                            for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                                f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                                if (f_int, materia_item.grupoId) in ocupacion_grupos:
                                    continue
                                
                                for h_s in h_slots:
                                    h_e_calc = calcular_hora_fin(h_s)
                                    aula_ok = find_best_aula(materia_item.grupoId, f_int, h_s, h_e_calc, None, set(), ignore_clases=True, ignore_grupo_ocupacion=False)
                                    # Si encontramos aula, usarla
                                    if aula_ok:
                                        if slot_libre(materia_item.grupoId, aula_ok, f_int, h_s, h_e_calc, ignore_semestre=True, ignore_clases=True, ignore_grupo_ocupacion=False):
                                            registrar_slot(materia_item.grupoId, aula_ok, f_int, h_s, h_e_calc)
                                            db.add(modelos_examenes.Examen(
                                                fecha=f_int, hora_inicio=h_s, hora_fin=h_e_calc,
                                                tipo=tipo_examen, materia_id=materia_item.materiaId, aula_id=aula_ok,
                                                grupo_id=materia_item.grupoId, academia_id=aca_id if isinstance(aca_id, int) else None,
                                                status='borrador'
                                            ))
                                            ex_creado = True
                                            break
                                    else:
                                        # Si no hay aula disponible, crear examen sin aula
                                        if slot_libre(materia_item.grupoId, None, f_int, h_s, h_e_calc, ignore_semestre=True, ignore_clases=True, ignore_grupo_ocupacion=False):
                                            ocupacion_grupos.add((f_int, materia_item.grupoId))
                                            g_obj = db.query(modelos_academica.Grupo).get(materia_item.grupoId)
                                            if g_obj:
                                                sem = obtener_semestre(g_obj.nombre_grupo)
                                                ocupacion_semestres.add((f_int, g_obj.carrera_id, sem))
                                            db.add(modelos_examenes.Examen(
                                                fecha=f_int, hora_inicio=h_s, hora_fin=h_e_calc,
                                                tipo=tipo_examen, materia_id=materia_item.materiaId, aula_id=None,
                                                grupo_id=materia_item.grupoId, academia_id=aca_id if isinstance(aca_id, int) else None,
                                                status='borrador'
                                            ))
                                            ex_creado = True
                                            break
                                if ex_creado:
                                    break
                            if ex_creado:
                                break

        # 3. Individuales
        for it in individuales:
            horarios = db.query(modelos_horarios.Horario).filter(
                modelos_horarios.Horario.materia_id == it.materiaId,
                modelos_horarios.Horario.grupo_id == it.grupoId
            ).all()
            if not horarios: continue
            
            ex_creado = False
            
            # A. En periodo ORDINARIO, no hay clases regulares, así que buscamos cualquier hueco primero
            if 'ORDINARIO' in tipo_examen or 'EXTRAORDINARIO' in tipo_examen:
                from datetime import time
                h_slots = [time(7,0), time(8,0), time(9,0), time(10,0), time(11,0), time(12,0), time(13,0), time(14,0), time(15,0), time(16,0), time(17,0), time(18,0), time(19,0)]
                for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                    f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                    if (f_int, it.grupoId) in ocupacion_grupos: continue
                    
                    for h_s in h_slots:
                        h_e_calc = calcular_hora_fin(h_s)
                        # En ordinario no importan las clases actuales
                        if not slot_libre(it.grupoId, None, f_int, h_s, h_e_calc, ignore_semestre=True): continue
                        
                        aula_ok = find_best_aula(it.grupoId, f_int, h_s, h_e_calc, None, set(), ignore_clases=True)
                        if aula_ok:
                             if slot_libre(it.grupoId, aula_ok, f_int, h_s, h_e_calc, ignore_semestre=True, ignore_clases=True):
                                registrar_slot(it.grupoId, aula_ok, f_int, h_s, h_e_calc)
                                db.add(modelos_examenes.Examen(
                                    fecha=f_int, hora_inicio=h_s, hora_fin=h_e_calc,
                                    tipo=tipo_examen, materia_id=it.materiaId, aula_id=aula_ok,
                                    grupo_id=it.grupoId, 
                                    aplicador_id=it.aplicadorId,
                                    modalidad=it.modalidad or modalidad_global,
                                    status='borrador'
                                ))
                                ex_creado = True; break
                        else:
                             # Sin aula
                             registrar_slot(it.grupoId, None, f_int, h_s, h_e_calc)
                             db.add(modelos_examenes.Examen(
                                fecha=f_int, hora_inicio=h_s, hora_fin=h_e_calc,
                                tipo=tipo_examen, materia_id=it.materiaId, aula_id=None,
                                grupo_id=it.grupoId, 
                                aplicador_id=it.aplicadorId,
                                modalidad=it.modalidad or modalidad_global,
                                status='borrador'
                            ))
                             ex_creado = True; break
                    if ex_creado: break
            
            # B. Si es Parcial o si no encontró hueco en búsqueda amplia de Ordinario (fallback o lógica normal)
            if not ex_creado:
                # Intentar en horario original de la materia
                for h in horarios:
                    f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, normalizar_dia(h.dia_semana))
                    h_e_calc = calcular_hora_fin(h.hora_inicio)
                    
                    # SEGURIDAD: Verificar primero si el horario está libre de Inglés
                    if not slot_libre(it.grupoId, None, f_int, h.hora_inicio, h_e_calc, ignore_semestre=True): 
                        continue

                    aula_ok = find_best_aula(it.grupoId, f_int, h.hora_inicio, h_e_calc, h.aula_id)
                    
                    if aula_ok:
                         if slot_libre(it.grupoId, aula_ok, f_int, h.hora_inicio, h_e_calc, ignore_semestre=True):
                            registrar_slot(it.grupoId, aula_ok, f_int, h.hora_inicio, h_e_calc)
                            db.add(modelos_examenes.Examen(
                                fecha=f_int, hora_inicio=h.hora_inicio, hora_fin=h_e_calc,
                                tipo=tipo_examen, materia_id=it.materiaId, aula_id=aula_ok,
                                grupo_id=it.grupoId, 
                                aplicador_id=it.aplicadorId,
                                modalidad=it.modalidad or modalidad_global,
                                status='borrador'
                            ))
                            ex_creado = True; break
                    else:
                        # Fallback sin aula
                        if slot_libre(it.grupoId, None, f_int, h.hora_inicio, h_e_calc, ignore_semestre=True):
                             registrar_slot(it.grupoId, None, f_int, h.hora_inicio, h_e_calc)
                             db.add(modelos_examenes.Examen(
                                fecha=f_int, hora_inicio=h.hora_inicio, hora_fin=h_e_calc,
                                tipo=tipo_examen, materia_id=it.materiaId, aula_id=None,
                                grupo_id=it.grupoId, 
                                aplicador_id=it.aplicadorId,
                                modalidad=it.modalidad or modalidad_global,
                                status='borrador'
                            ))
                             ex_creado = True; break
            
                # Fallback otros días buscando huecos de la materia original
                if not ex_creado:
                    for d_nom in ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO']:
                        f_int = obtener_siguiente_dia_semana(fecha_lunes_inicio, d_nom)
                        for h in horarios:
                            h_e_calc = calcular_hora_fin(h.hora_inicio)
                            aula_ok = find_best_aula(it.grupoId, f_int, h.hora_inicio, h_e_calc, h.aula_id)
                            if aula_ok and slot_libre(it.grupoId, aula_ok, f_int, h.hora_inicio, h_e_calc, ignore_semestre=True):
                                registrar_slot(it.grupoId, aula_ok, f_int, h.hora_inicio, h_e_calc)
                                db.add(modelos_examenes.Examen(
                                    fecha=f_int, hora_inicio=h.hora_inicio, hora_fin=h_e_calc,
                                    tipo=tipo_examen, materia_id=it.materiaId, aula_id=aula_ok,
                                    grupo_id=it.grupoId, 
                                    aplicador_id=it.aplicadorId,
                                    modalidad=it.modalidad or modalidad_global,
                                    status='borrador'
                                ))
                                ex_creado = True; break
                        if ex_creado: break
        
        db.commit()
        return get_examenes(db)
    except Exception as e:
        db.rollback()
        import traceback
        error_detail = f"Error al generar exámenes: {str(e)}\n{traceback.format_exc()}"
        print(f"ERROR: {error_detail}")
        with open("/app/error_log.txt", "w") as f:
            f.write(error_detail)
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {str(e)}")

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
    if datos.aplicador_id:
        examen.aplicador_id = datos.aplicador_id
    if datos.modalidad:
        examen.modalidad = datos.modalidad
        
    db.commit()
    db.refresh(examen)
    
    # Recargar para devolver esquema completo
    return db.query(modelos_examenes.Examen).options(
        joinedload(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.profesor),
        joinedload(modelos_examenes.Examen.materia).joinedload(modelos_academica.Materia.carrera),
        joinedload(modelos_examenes.Examen.aula),
        joinedload(modelos_examenes.Examen.grupo),
        joinedload(modelos_examenes.Examen.sinodal),
        joinedload(modelos_examenes.Examen.aplicador)
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
    
    count_grupos = 0 # Inicializar contador

    # VALIDACIÓN: Verificar que NO haya conflictos en los exámenes que se quieren enviar
    examenes_con_error = db.query(modelos_examenes.Examen).join(modelos_academica.Materia).filter(
        modelos_examenes.Examen.grupo_id.in_(grupos_ids),
        modelos_academica.Materia.carrera_id == carrera_id,
        modelos_examenes.Examen.status.in_(['borrador', 'rechazado'])
    ).all()

    # Usamos la lógica de get_examenes para detectar conflictos actuales (frescos)
    todos_procesados = get_examenes(db)
    for ex in todos_procesados:
        if ex.grupo_id in grupos_ids and ex.status in ['borrador', 'rechazado']:
            if ex.tiene_conflictos:
                 raise HTTPException(
                     status_code=400, 
                     detail=f"No se pueden enviar los exámenes. El grupo {ex.grupo.nombre_grupo} tiene conflictos pendientes (ej: {ex.detalles_conflicto})."
                 )
    
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
