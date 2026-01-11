from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NotificacionBase(BaseModel):
    mensaje: str
    destinatario_rol: Optional[str] = None
    destinatario_id: Optional[int] = None
    tipo: str
    referencia_id: Optional[int] = None
    referencia_tipo: Optional[str] = None

class NotificacionCreate(NotificacionBase):
    pass

class Notificacion(NotificacionBase):
    id: int
    leida: bool
    fecha_creacion: datetime

    class Config:
        orm_mode = True
