from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, selectinload, joinedload
from typing import List, Optional
import logging
import subprocess
import os
import sys
import threading
import re

from ..configuracion.base_datos import obtener_db
from . import modelos, esquemas
from ..gestion_horarios import modelos as modelos_horarios 
from ..integracion_horarios.core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api",
    tags=["Gestión Académica"]
)

@router.get("/carreras", response_model=List[esquemas.Carrera])
def get_carreras(db: Session = Depends(obtener_db)):
    # La lógica original cargaba grupos, horarios, materias, profesores y aulas.
    # Dado que las relaciones están definidas como strings en los modelos divididos, 
    # SQLAlchemy las resolverá si todos los modelos se han importado al menos una vez (en main.py).
    
    # Nota: joinedload usa los atributos de la clase.
    # modelos.Carrera.grupos -> relaciona con modelos.Grupo
    # modelos.Grupo.horarios -> relaciona con 'Horario'
    
    carreras = db.query(modelos.Carrera).options(
        selectinload(modelos.Carrera.grupos)
            .selectinload(modelos.Grupo.horarios)
            .selectinload(modelos_horarios.Horario.materia)
            .selectinload(modelos.Materia.profesor),
        selectinload(modelos.Carrera.grupos)
            .selectinload(modelos.Grupo.horarios)
            .selectinload(modelos_horarios.Horario.materia)
            .selectinload(modelos.Materia.sinodal),
        selectinload(modelos.Carrera.grupos)
            .selectinload(modelos.Grupo.horarios)
            .selectinload(modelos_horarios.Horario.materia)
            .selectinload(modelos.Materia.academia),
        selectinload(modelos.Carrera.grupos)
            .selectinload(modelos.Grupo.horarios)
            .selectinload(modelos_horarios.Horario.aula)
    ).all()

    # Pre-popular nombre de carrera en materia y filtrar materias no examen (Inglés/Sin Profesor)
    for carrera in carreras:
        for grupo in carrera.grupos:
            # Filtrar horarios cuya materia no deba tener examen (Inglés, Sala de Cómputo, Sin Profesor)
            grupo.horarios = [
                h for h in grupo.horarios 
                if h.materia and h.materia.profesor_id is not None and 
                not any(x in h.materia.nombre.upper() for x in ['INGLÉS', 'INGLES', 'SALA DE CÓMPUTO', 'SALA DE COMPUTO', 'TUTORÍA', 'ASESORÍA'])
            ]
            for horario in grupo.horarios:
                if horario.materia:
                    horario.materia.carrera_nombre = carrera.nombre
    return carreras

@router.get("/profesores", response_model=List[esquemas.Profesor])
def get_profesores(db: Session = Depends(obtener_db)):
    return db.query(modelos.Profesor).all()

@router.get("/aulas", response_model=List[esquemas.Aula])
def get_aulas(db: Session = Depends(obtener_db)):
    return db.query(modelos.Aula).all()

@router.get("/academias", response_model=List[esquemas.Academia])
def get_academias(db: Session = Depends(obtener_db)):
    return db.query(modelos.Academia).all()

@router.post("/academias", response_model=esquemas.Academia)
def create_academia(academia: esquemas.AcademiaCreate, db: Session = Depends(obtener_db)):
    db_academia = modelos.Academia(**academia.model_dump())
    db.add(db_academia)
    db.commit()
    db.refresh(db_academia)
    return db_academia

@router.delete("/academias/{academia_id}")
def delete_academia(academia_id: int, db: Session = Depends(obtener_db)):
    db_academia = db.query(modelos.Academia).filter(modelos.Academia.id == academia_id).first()
    if not db_academia:
        raise HTTPException(status_code=404, detail="Academia no encontrada")
    db.delete(db_academia)
    db.commit()
    return {"message": "Academia eliminada"}

@router.get("/materias", response_model=List[esquemas.Materia])
def get_materias(carrera_id: int = None, carrera_codigo: str = None, db: Session = Depends(obtener_db)):
    query = db.query(modelos.Materia).options(
        joinedload(modelos.Materia.profesor),
        joinedload(modelos.Materia.carrera),
        joinedload(modelos.Materia.academia)
    ).order_by(modelos.Materia.nombre)
    if carrera_id:
        query = query.filter(modelos.Materia.carrera_id == carrera_id)
    elif carrera_codigo:
        query = query.join(modelos.Carrera).filter(modelos.Carrera.codigo == carrera_codigo)
    
    # Filtrar materias que no son para examen (Inglés, Sala de Cómputo, Tutoría, etc)
    query = query.filter(modelos.Materia.profesor_id.isnot(None))
    ignorar = ['%inglés%', '%ingles%', '%sala de cómputo%', '%sala de computo%', '%tutoría%', '%asesoría%', '%biblioteca%', '%extraescolares%']
    for pattern in ignorar:
        query = query.filter(~modelos.Materia.nombre.ilike(pattern))

    materias = query.all()
    
    for materia in materias:
        if materia.carrera:
            materia.carrera_nombre = materia.carrera.nombre
    
    return materias

@router.put("/materias/{materia_id}/sinodal")
def assign_sinodal_to_materia(materia_id: int, sinodal_id: Optional[int] = None, db: Session = Depends(obtener_db)):
    materia = db.query(modelos.Materia).filter(modelos.Materia.id == materia_id).first()
    if not materia:
        raise HTTPException(status_code=404, detail="Materia no encontrada")
    
    materia.sinodal_id = sinodal_id
    db.commit()
    return {"message": "Sinodal asignado a la materia correctamente"}

@router.put("/materias/{materia_id}/academia")
def assign_academia_by_name(materia_id: int, academia_nombre: Optional[str] = None, db: Session = Depends(obtener_db)):
    materia = db.query(modelos.Materia).filter(modelos.Materia.id == materia_id).first()
    if not materia:
        raise HTTPException(status_code=404, detail="Materia no encontrada")
    
    if not academia_nombre:
        materia.academia_id = None
    else:
        # Buscar academia por nombre (normalizado)
        nombre_clean = academia_nombre.strip().upper()
        academia = db.query(modelos.Academia).filter(modelos.Academia.nombre.ilike(nombre_clean)).first()
        
        if not academia:
            # Crear nueva academia
            academia = modelos.Academia(nombre=nombre_clean)
            db.add(academia)
            db.flush() # Para obtener el ID
            
        materia.academia_id = academia.id
    
    db.commit()
    return {"message": "Academia actualizada correctamente"}

# ==================== ENDPOINTS FILTRADOS POR ROL ====================

@router.get("/carreras-filtradas", response_model=List[esquemas.CarreraSimple])
def get_carreras_filtradas(rol: str, clave_carrera: str = None, db: Session = Depends(obtener_db)):
    """
    Obtiene carreras filtradas según el rol del usuario.
    - servicios_escolares: devuelve TODAS las carreras
    - jefe_carrera: devuelve todas las carreras que compartan el mismo número base
                    (ej: 06B incluye 06 y 06B, 04B incluye 04 y 04B)
    """
    if rol == "servicios_escolares" or rol == "administrador":
        # Devolver todas las carreras
        carreras = db.query(modelos.Carrera).all()
        return carreras
    elif rol == "jefe_carrera":
        if not clave_carrera:
            raise HTTPException(status_code=400, detail="Se requiere clave_carrera para rol jefe_carrera")
        
        # Extraer el número base de la clave (ej: de "06B" extraer "06")
        import re
        match = re.match(r'^(\d+)', clave_carrera)
        
        if match:
            numero_base = match.group(1)
            logger.info(f"Filtrando carreras por número base: {numero_base}")
            # Buscar carreras cuyo código empiece con el número base o cuyo nombre sea similar
            # Esto permite agrupar planes de estudio (06, 06B, etc)
            carreras = db.query(modelos.Carrera).filter(
                modelos.Carrera.codigo.like(f"{numero_base}%")
            ).all()
            
            if not carreras:
                # Fallback: intentar por código exacto por si no empieza con números
                carreras = db.query(modelos.Carrera).filter(
                    modelos.Carrera.codigo == clave_carrera
                ).all()
        else:
            # Si no empieza con números (ej: "INGLES"), buscar por código exacto
            carreras = db.query(modelos.Carrera).filter(
                modelos.Carrera.codigo == clave_carrera
            ).all()
            
        logger.info(f"Carreras encontradas para jefe ({clave_carrera}): {len(carreras)}")
        return carreras
    else:
        return []

# Variables globales para rastrear la sincronización
sync_status = {
    "running": False,
    "progress": 0,
    "last_log": "",
    "logs": [],
    "error": None,
    "finished": False
}
sync_buffer = []

def run_sync_task(script_path):
    global sync_status, sync_buffer
    sync_status["running"] = True
    sync_status["progress"] = 0
    sync_status["logs"] = []
    sync_status["error"] = None
    sync_status["finished"] = False
    sync_buffer = []
    
    try:
        process = subprocess.Popen(
            [sys.executable, script_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True
        )
        
        # Patrón mejorado para extraer progreso: "111/111 (100.0%)" o "(2%)"
        progress_pattern = re.compile(r'\((\d+(?:\.\d+)?)%\)')
        
        for line in process.stdout:
            line = line.strip()
            if not line: continue
            
            sync_status["last_log"] = line
            sync_status["logs"].append(line)
            if len(sync_status["logs"]) > 50: # Mantener solo los últimos 50 logs
                sync_status["logs"].pop(0)
            
            # Intentar extraer porcentaje
            match = progress_pattern.search(line)
            if match:
                try:
                    sync_status["progress"] = int(float(match.group(1)))
                except: pass
            elif "Tablas creadas" in line:
                sync_status["progress"] = 5
            elif "Consultando API externa" in line:
                sync_status["progress"] = 10
            elif "SISTEMA LISTO" in line or "poblados exitosamente" in line:
                sync_status["progress"] = 100
                
        process.wait()
        sync_status["finished"] = True
        if process.returncode != 0:
            sync_status["error"] = "El proceso terminó con errores."
    except Exception as e:
        sync_status["error"] = str(e)
    finally:
        sync_status["running"] = False

@router.post("/sincronizar")
def iniciar_sincronizacion():
    global sync_status
    if sync_status["running"]:
        return {"message": "Ya hay una sincronización en curso"}
        
    script_path = "/app/setup.py"
    if not os.path.exists(script_path):
        script_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "setup.py")
    
    thread = threading.Thread(target=run_sync_task, args=(script_path,))
    thread.start()
    return {"message": "Sincronización iniciada"}

@router.get("/sincronizar/status")
def obtener_estado_sincronizacion():
    return sync_status

@router.get("/grupos-filtrados", response_model=List[esquemas.GrupoSimple])
def get_grupos_filtrados(
    rol: str, 
    clave_carrera: str = None, 
    carrera_seleccionada_id: int = None,
    db: Session = Depends(obtener_db)
):
    """
    Obtiene grupos filtrados según el rol del usuario y la carrera seleccionada.
    - servicios_escolares SIN carrera seleccionada: devuelve TODOS los grupos
    - servicios_escolares CON carrera seleccionada: devuelve grupos de esa carrera
    - jefe_carrera: devuelve grupos de todas sus carreras O de la carrera seleccionada si se especifica
    """
    logger.info(f"get_grupos_filtrados - rol: {rol}, clave_carrera: {clave_carrera}, carrera_seleccionada_id: {carrera_seleccionada_id}")
    
    if rol == "servicios_escolares" or rol == "administrador":
        if carrera_seleccionada_id:
            # Filtrar por carrera seleccionada
            logger.info(f"Filtrando grupos por carrera_id: {carrera_seleccionada_id}")
            grupos = db.query(modelos.Grupo).filter(
                modelos.Grupo.carrera_id == carrera_seleccionada_id
            ).all()
            logger.info(f"Grupos encontrados: {len(grupos)}")
        else:
            # Devolver todos los grupos
            logger.info("Devolviendo todos los grupos")
            grupos = db.query(modelos.Grupo).all()
            logger.info(f"Total grupos: {len(grupos)}")
        return grupos
    elif rol == "jefe_carrera":
        if not clave_carrera:
            raise HTTPException(status_code=400, detail="Se requiere clave_carrera para rol jefe_carrera")
        
        logger.info(f"Buscando grupos para jefe_carrera con clave: {clave_carrera}")
        
        # Si hay una carrera seleccionada, filtrar solo por esa
        if carrera_seleccionada_id:
            logger.info(f"Filtrando grupos por carrera seleccionada: {carrera_seleccionada_id}")
            grupos = db.query(modelos.Grupo).filter(
                modelos.Grupo.carrera_id == carrera_seleccionada_id
            ).all()
            logger.info(f"Grupos encontrados: {len(grupos)}")
            return grupos
        
        # Si NO hay carrera seleccionada, devolver grupos de TODAS las carreras del jefe
        # Buscamos las carreras en la BD local basándonos en el código (número base)
        import re
        match = re.match(r'^(\d+)', clave_carrera)
        
        if match:
            numero_base = match.group(1)
            # Obtener IDs de todas las carreras que empiecen con ese número base
            carreras = db.query(modelos.Carrera).filter(
                modelos.Carrera.codigo.like(f"{numero_base}%")
            ).all()
            carrera_ids = [c.id for c in carreras]
            
            logger.info(f"IDs de carreras encontradas para base {numero_base}: {carrera_ids}")
            
            # Obtener grupos de todas esas carreras
            if carrera_ids:
                grupos = db.query(modelos.Grupo).filter(
                    modelos.Grupo.carrera_id.in_(carrera_ids)
                ).all()
                logger.info(f"Grupos encontrados: {len(grupos)}")
                return grupos
            else:
                # Fallback: intentar por código exacto
                carrera = db.query(modelos.Carrera).filter(modelos.Carrera.codigo == clave_carrera).first()
                if carrera:
                    grupos = db.query(modelos.Grupo).filter(modelos.Grupo.carrera_id == carrera.id).all()
                    return grupos
        else:
            # Caso para códigos no numéricos (ej: "INGLES")
            carrera = db.query(modelos.Carrera).filter(modelos.Carrera.codigo == clave_carrera).first()
            if carrera:
                grupos = db.query(modelos.Grupo).filter(modelos.Grupo.carrera_id == carrera.id).all()
                return grupos

        return []
    else:
        logger.warning(f"Rol no reconocido: {rol}")
        return []
@router.get("/config/periodo")
def get_periodo_config():
    """
    Obtiene el periodo configurado localmente.
    """
    return {
        "clave": settings.PERIODO_ACTUAL,
        "nombre": f"Periodo {settings.PERIODO_ACTUAL}"
    }
