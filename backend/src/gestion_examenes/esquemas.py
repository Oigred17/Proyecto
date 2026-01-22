from pydantic import BaseModel
from typing import Optional
from datetime import time, date
from ..gestion_academica.esquemas import Materia, Aula, Grupo, Profesor

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
    tipo: str
    modalidad: Optional[str] = None
    materia_id: int
    aula_id: Optional[int] = None
    grupo_id: int
    aplicador_id: Optional[int] = None
    observaciones: Optional[str] = None

class ExamenUpdate(BaseModel):
    fecha: Optional[date] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    aula_id: Optional[int] = None
    aplicador_id: Optional[int] = None
    modalidad: Optional[str] = None

class Examen(ExamenBase):
    id: int
    materia_id: int
    aula_id: Optional[int] = None
    grupo_id: int
    sinodal_id: Optional[int] = None
    aplicador_id: Optional[int] = None
    modalidad: Optional[str] = None
    
    materia: Materia
    aula: Optional[Aula] = None
    grupo: Optional[Grupo] = None
    sinodal: Optional[Profesor] = None
    aplicador: Optional[Profesor] = None
    tiene_conflictos: Optional[bool] = False
    detalles_conflicto: Optional[str] = None
    
    status: Optional[str] = None
    comentarios_rechazo: Optional[str] = None
    fecha_envio: Optional[date] = None
    fecha_aprobacion: Optional[date] = None

    class Config:
        from_attributes = True

class RejectionModel(BaseModel):
    comentarios: str
