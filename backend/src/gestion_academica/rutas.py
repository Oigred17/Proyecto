from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List

from ..configuracion.base_datos import obtener_db
from . import modelos, esquemas
from ..gestion_horarios import modelos as modelos_horarios # Necesario para que SQLAlchemy conozca Horario si se carga explícitamente, pero con strings basta si la base está compartida

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
        joinedload(modelos.Carrera.grupos).joinedload(modelos.Grupo.horarios).joinedload(modelos_horarios.Horario.materia).joinedload(modelos.Materia.profesor),
        joinedload(modelos.Carrera.grupos).joinedload(modelos.Grupo.horarios).joinedload(modelos_horarios.Horario.aula)
    ).all()

    # Pre-popular nombre de carrera en materia si es necesario (lógica original)
    for carrera in carreras:
        for grupo in carrera.grupos:
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
        joinedload(modelos.Materia.carrera)
    )
    if carrera_id:
        query = query.filter(modelos.Materia.carrera_id == carrera_id)
    materias = query.all()
    
    for materia in materias:
        if materia.carrera:
            materia.carrera_nombre = materia.carrera.nombre
    
    return materias
