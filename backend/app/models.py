from sqlalchemy import create_engine, Column, Integer, String, Text, Date, Time, ForeignKey
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

class Horario(Base):
    __tablename__ = 'horarios'
    id = Column(Integer, primary_key=True, index=True)
    dia_semana = Column(String) # e.g., 'LUNES'
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    grupo_id = Column(Integer, ForeignKey('grupos.id'))
    materia_id = Column(Integer, ForeignKey('materias.id'))
    aula_id = Column(Integer, ForeignKey('aulas.id'))

    grupo = relationship("Grupo", back_populates="horarios")
    materia = relationship("Materia", back_populates="horarios")
    aula = relationship("Aula", back_populates="horarios")

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
    # Relationships
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
    # Relationships
    horarios = relationship("Horario", back_populates="aula")
    examenes = relationship("Examen", back_populates="aula")


class Materia(Base):
    __tablename__ = 'materias'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String)
    carrera_id = Column(Integer, ForeignKey('carreras.id'))
    profesor_id = Column(Integer, ForeignKey('profesores.id'))

    # Relationships
    carrera = relationship("Carrera", back_populates="materias")
    profesor = relationship("Profesor", back_populates="materias")
    horarios = relationship("Horario", back_populates="materia")
    examenes = relationship("Examen", back_populates="materia")

class Grupo(Base):
    __tablename__ = 'grupos'
    id = Column(Integer, primary_key=True, index=True)
    nombre_grupo = Column(String)
    carrera_id = Column(Integer, ForeignKey('carreras.id'))

    # Relationships
    carrera = relationship("Carrera", back_populates="grupos")
    horarios = relationship("Horario", back_populates="grupo")
    examenes = relationship("Examen", back_populates="grupo") # Add this line

class TipoExamen(Base):
    __tablename__ = 'tipos_examen'
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, unique=True, index=True)
    descripcion = Column(Text)

class Examen(Base):
    __tablename__ = 'examenes'
    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(Date)
    hora_inicio = Column(Time)
    hora_fin = Column(Time)
    tipo = Column(String) # e.g., 'PARCIAL', 'FINAL'
    materia_id = Column(Integer, ForeignKey('materias.id'))
    aula_id = Column(Integer, ForeignKey('aulas.id'))
    grupo_id = Column(Integer, ForeignKey('grupos.id'))
    sinodal_id = Column(Integer, ForeignKey('profesores.id'), nullable=True) # Sinodal asignado

   
    status = Column(String, default='borrador') # borrador, pendiente_aprobacion, aprobado, rechazado
    comentarios_rechazo = Column(Text, nullable=True)
    fecha_envio = Column(Date, nullable=True)
    fecha_aprobacion = Column(Date, nullable=True)

    materia = relationship("Materia", back_populates="examenes")
    aula = relationship("Aula", back_populates="examenes")
    grupo = relationship("Grupo", back_populates="examenes") # Add relationship to Grupo

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False)  # 'servicios_escolares', 'jefe_carrera', 'secretaria'
    email = Column(String, unique=True, index=True, nullable=True)
    carrera = Column(String, nullable=True)  # Nombre de la carrera para jefe_carrera
    is_active = Column(Integer, default=1)  # 1 for active, 0 for inactive
