"""Modelos de gestión de horarios."""
from sqlalchemy import Column, Integer, String, Time, ForeignKey
from sqlalchemy.orm import relationship
from ..compartido.modelos_base import Base

class Horario(Base):
    """Modelo de horario de clases."""
    __tablename__ = 'horarios'
    id = Column(Integer, primary_key=True, index=True)
    dia_semana = Column(String)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    grupo_id = Column(Integer, ForeignKey('grupos.id'))
    materia_id = Column(Integer, ForeignKey('materias.id'))
    aula_id = Column(Integer, ForeignKey('aulas.id'))

    grupo = relationship("Grupo", back_populates="horarios")
    materia = relationship("Materia", back_populates="horarios")
    aula = relationship("Aula", back_populates="horarios")
