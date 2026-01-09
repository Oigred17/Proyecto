from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from ..compartido.modelos_base import Base

class Carrera(Base):
    __tablename__ = 'carreras'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, index=True)
    codigo = Column(String, unique=True)
    descripcion = Column(Text)
    materias = relationship("Materia", back_populates="carrera")
    grupos = relationship("Grupo", back_populates="carrera")

class Profesor(Base):
    __tablename__ = 'profesores'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)
    email = Column(String, unique=True, index=True, nullable=True)
    materias = relationship("Materia", back_populates="profesor")

class Academia(Base):
    __tablename__ = 'academias'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, index=True)
    codigo = Column(String, unique=True, nullable=True)
    descripcion = Column(Text, nullable=True)

class Aula(Base):
    __tablename__ = 'aulas'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, index=True)
    capacidad = Column(Integer)
    tipo = Column(String)
    horarios = relationship("Horario", back_populates="aula")
    examenes = relationship("Examen", back_populates="aula")

class Materia(Base):
    __tablename__ = 'materias'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String)
    carrera_id = Column(Integer, ForeignKey('carreras.id'))
    profesor_id = Column(Integer, ForeignKey('profesores.id'))

    carrera = relationship("Carrera", back_populates="materias")
    profesor = relationship("Profesor", back_populates="materias")
    horarios = relationship("Horario", back_populates="materia")
    examenes = relationship("Examen", back_populates="materia")

class Grupo(Base):
    __tablename__ = 'grupos'
    id = Column(Integer, primary_key=True, index=True)
    nombre_grupo = Column(String)
    carrera_id = Column(Integer, ForeignKey('carreras.id'))

    carrera = relationship("Carrera", back_populates="grupos")
    horarios = relationship("Horario", back_populates="grupo")
    examenes = relationship("Examen", back_populates="grupo")
