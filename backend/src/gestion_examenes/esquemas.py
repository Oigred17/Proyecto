from pydantic import BaseModel
from typing import Optional
from datetime import time, date
from ..gestion_academica.esquemas import Materia, Aula, Grupo

class TipoExamen(BaseModel):
    id: int
    nombre: str
    descripcion: Optional[str] = None
    class Config:
        from_attributes = True

class ExamenBase(BaseModel):
    fecha: date
    hora_inicio: time
    hora_fin: time
    tipo: str

class ExamenCreate(BaseModel):
    fecha: date
    hora_inicio: time
    hora_fin: time
    tipo_examen_id: int
    materia_id: int
    aula_id: int
    grupo_id: int
    observaciones: Optional[str] = None

class Examen(ExamenBase):
    id: int
    materia_id: int
    aula_id: int
    grupo_id: int
    sinodal_id: Optional[int] = None
    
    materia: Materia
    aula: Aula
    grupo: Optional[Grupo] = None
    
    status: Optional[str] = None
    comentarios_rechazo: Optional[str] = None
    fecha_envio: Optional[date] = None
    fecha_aprobacion: Optional[date] = None

    class Config:
        from_attributes = True

class RejectionModel(BaseModel):
    comentarios: str
