from pydantic import BaseModel
from typing import Optional
from datetime import time

class ProfesorRef(BaseModel):
    id: int
    nombre: str
    class Config:
        from_attributes = True

class MateriaRef(BaseModel):
    id: int
    nombre: str
    carrera_nombre: Optional[str] = None
    profesor_id: Optional[int] = None
    profesor: Optional[ProfesorRef] = None
    academia_id: Optional[int] = None
    sinodal_id: Optional[int] = None
    sinodal: Optional[ProfesorRef] = None
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
