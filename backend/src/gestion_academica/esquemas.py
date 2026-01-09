from pydantic import BaseModel
from typing import List, Optional
from ..gestion_horarios.esquemas import Horario

class Profesor(BaseModel):
    id: int
    nombre: str
    email: Optional[str] = None
    class Config:
        from_attributes = True

class Aula(BaseModel):
    id: int
    nombre: str
    capacidad: Optional[int] = None
    tipo: Optional[str] = None
    class Config:
        from_attributes = True

class Academia(BaseModel):
    id: int
    nombre: str
    codigo: Optional[str] = None
    descripcion: Optional[str] = None
    class Config:
        from_attributes = True

class Materia(BaseModel):
    id: int
    nombre: str
    profesor: Optional[Profesor] = None
    carrera_nombre: Optional[str] = None
    class Config:
        from_attributes = True

class Grupo(BaseModel):
    id: int
    nombre_grupo: str
    horarios: List[Horario] = []
    class Config:
        from_attributes = True

class Carrera(BaseModel):
    id: int
    nombre: str
    grupos: List[Grupo] = []
    class Config:
        from_attributes = True
