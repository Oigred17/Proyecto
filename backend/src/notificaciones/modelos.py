from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from ..compartido.modelos_base import Base
from datetime import datetime

class Notificacion(Base):
    __tablename__ = 'notificaciones'
    id = Column(Integer, primary_key=True, index=True)
    mensaje = Column(String)
    leida = Column(Boolean, default=False)
    fecha_creacion = Column(DateTime, default=datetime.utcnow)
    destinatario_rol = Column(String, nullable=True)  # 'jefe_carrera', 'servicios_escolares'
    destinatario_id = Column(Integer, nullable=True)  # Si es para un usuario especifico
    tipo = Column(String)  # 'envio_revision', 'rechazo', 'aprobacion'
    referencia_id = Column(Integer, nullable=True) 
    referencia_tipo = Column(String, nullable=True) # 'grupo', 'examen'
    carrera = Column(String, nullable=True) # Nombre de la carrera para filtrar jefe_carrera
