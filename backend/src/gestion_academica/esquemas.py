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

class AcademiaCreate(BaseModel):
    nombre: str
    codigo: Optional[str] = None
    descripcion: Optional[str] = None

class Materia(BaseModel):
    id: int
    nombre: str
    profesor: Optional[Profesor] = None
    carrera_id: int
    carrera_nombre: Optional[str] = None
    academia_id: Optional[int] = None
    academia: Optional[Academia] = None
    semestre: Optional[int] = None
    sinodal_id: Optional[int] = None
    sinodal: Optional[Profesor] = None
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
    nombre: Optional[str] = None
    grupos: List[Grupo] = []
    class Config:
        from_attributes = True

# Esquemas simplificados para combobox
class CarreraSimple(BaseModel):
    id: int
    nombre: Optional[str] = None
    class Config:
        from_attributes = True

class GrupoSimple(BaseModel):
    id: int
    nombre_grupo: str
    carrera_id: int
    class Config:
        from_attributes = True
