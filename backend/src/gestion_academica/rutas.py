from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, selectinload, joinedload
from typing import List
import logging

from ..configuracion.base_datos import obtener_db
from . import modelos, esquemas
from ..gestion_horarios import modelos as modelos_horarios # Necesario para que SQLAlchemy conozca Horario si se carga explícitamente, pero con strings basta si la base está compartida

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
            .selectinload(modelos.Materia.academia),
        selectinload(modelos.Carrera.grupos)
            .selectinload(modelos.Grupo.horarios)
            .selectinload(modelos_horarios.Horario.aula)
    ).all()

    # Pre-popular nombre de carrera en materia y filtrar materias no examen (Inglés/Sin Profesor)
    for carrera in carreras:
        for grupo in carrera.grupos:
            # Filtrar horarios cuya materia no tenga profesor (Ej: Inglés)
            grupo.horarios = [
                h for h in grupo.horarios 
                if h.materia and h.materia.profesor_id is not None
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

@router.get("/materias", response_model=List[esquemas.Materia])
def get_materias(carrera_id: int = None, db: Session = Depends(obtener_db)):
    query = db.query(modelos.Materia).options(
        joinedload(modelos.Materia.profesor),
        joinedload(modelos.Materia.carrera),
        joinedload(modelos.Materia.academia)
    )
    if carrera_id:
        query = query.filter(modelos.Materia.carrera_id == carrera_id)
    
    # Filtrar materias sin profesor o específicamente Inglés
    # Usamos ilike para ser case-insensitive por si acaso
    query = query.filter(modelos.Materia.profesor_id.isnot(None))
    query = query.filter(~modelos.Materia.nombre.ilike('%inglés%'))
    query = query.filter(~modelos.Materia.nombre.ilike('%ingles%'))

    materias = query.all()
    
    for materia in materias:
        if materia.carrera:
            materia.carrera_nombre = materia.carrera.nombre
    
    return materias

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
        
        # Extraer el número base de la clave (sin letras)
        import re
        numero_base = re.match(r'^(\d+)', clave_carrera)
        if not numero_base:
            raise HTTPException(status_code=400, detail="Formato de clave_carrera inválido")
        
        numero_base = numero_base.group(1)
        logger.info(f"Buscando carreras con número base: {numero_base}")
        
        # Devolver TODAS las carreras que empiecen con ese número base
        from ..integracion_horarios.services.carrera_service import CarreraService
        try:
            carrera_service = CarreraService()
            # Obtener carreras vigentes
            carreras_api = carrera_service.obtener_todas_carreras()
            
            # Filtrar carreras cuya clave empiece con el número base
            nombres_carreras = [
                c['nombre'] for c in carreras_api 
                if c['clave'].startswith(numero_base)
            ]
            
            logger.info(f"Carreras encontradas para número base {numero_base}: {nombres_carreras}")
            
            if nombres_carreras:
                # Obtener todas las carreras de la BD que coincidan
                carreras = db.query(modelos.Carrera).filter(
                    modelos.Carrera.nombre.in_(nombres_carreras)
                ).all()
                logger.info(f"Total carreras en BD: {len(carreras)}")
                return carreras
        except Exception as e:
            logger.error(f"Error al obtener carreras filtradas: {e}", exc_info=True)
        return []
    else:
        return []

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
        from ..integracion_horarios.services.carrera_service import CarreraService
        try:
            carrera_service = CarreraService()
            # Obtener carreras vigentes
            carreras_api = carrera_service.obtener_todas_carreras()
            
            # Extraer el número base de la clave (sin letras)
            import re
            numero_base = re.match(r'^(\d+)', clave_carrera)
            if not numero_base:
                logger.error(f"Formato de clave_carrera inválido: {clave_carrera}")
                return []
            
            numero_base = numero_base.group(1)
            logger.info(f"Buscando carreras con número base: {numero_base}")
            
            # Filtrar carreras cuya clave empiece con el número base
            nombres_carreras = [
                c['nombre'] for c in carreras_api 
                if c['clave'].startswith(numero_base)
            ]
            
            logger.info(f"Carreras encontradas para número base {numero_base}: {nombres_carreras}")
            
            if nombres_carreras:
                # Obtener IDs de todas las carreras
                carreras = db.query(modelos.Carrera).filter(
                    modelos.Carrera.nombre.in_(nombres_carreras)
                ).all()
                carrera_ids = [c.id for c in carreras]
                
                logger.info(f"IDs de carreras: {carrera_ids}")
                
                # Obtener grupos de todas esas carreras
                grupos = db.query(modelos.Grupo).filter(
                    modelos.Grupo.carrera_id.in_(carrera_ids)
                ).all()
                logger.info(f"Grupos encontrados: {len(grupos)}")
                return grupos
            else:
                logger.warning(f"No se encontraron carreras para número base: {numero_base}")
        except Exception as e:
            logger.error(f"Error al obtener grupos para jefe_carrera: {e}", exc_info=True)
        return []
    else:
        logger.warning(f"Rol no reconocido: {rol}")
        return []
