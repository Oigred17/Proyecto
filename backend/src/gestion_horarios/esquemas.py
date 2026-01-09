from pydantic import BaseModel
from typing import Optional
from datetime import time

class MateriaRef(BaseModel):
    id: int
    nombre: str
    carrera_nombre: Optional[str] = None
    class Config:
        from_attributes = True

class AulaRef(BaseModel):
    id: int
    nombre: str
    class Config:
        from_attributes = True

class Horario(BaseModel):
    id: int
    dia_semana: str
    hora_inicio: time
    hora_fin: time
    materia: MateriaRef
    aula: Optional[AulaRef] = None

    class Config:
        from_attributes = True
