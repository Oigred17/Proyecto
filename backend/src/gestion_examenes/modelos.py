"""Modelos de gestión de exámenes."""
from sqlalchemy import Column, Integer, String, Text, Date, Time, ForeignKey
from sqlalchemy.orm import relationship
from ..compartido.modelos_base import Base

class TipoExamen(Base):
    """Modelo de tipo de examen (parcial, final, etc.)."""
    __tablename__ = 'tipos_examen'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, index=True)
    descripcion = Column(Text)

class Examen(Base):
    """Modelo de examen programado."""
    __tablename__ = 'examenes'
    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(Date)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    tipo = Column(String)
    modalidad = Column(String)
    materia_id = Column(Integer, ForeignKey('materias.id'))
    aula_id = Column(Integer, ForeignKey('aulas.id'))
    grupo_id = Column(Integer, ForeignKey('grupos.id'))
    sinodal_id = Column(Integer, ForeignKey('profesores.id'), nullable=True)
    aplicador_id = Column(Integer, ForeignKey('profesores.id'), nullable=True)
    academia_id = Column(Integer, ForeignKey('academias.id'), nullable=True) 

    status = Column(String, default='borrador')
    comentarios_rechazo = Column(Text, nullable=True)
    fecha_envio = Column(Date, nullable=True)
    fecha_aprobacion = Column(Date, nullable=True)

    materia = relationship("Materia", back_populates="examenes")
    aula = relationship("Aula", back_populates="examenes")
    grupo = relationship("Grupo", back_populates="examenes")
    sinodal = relationship("Profesor", foreign_keys=[sinodal_id])
    aplicador = relationship("Profesor", foreign_keys=[aplicador_id])
