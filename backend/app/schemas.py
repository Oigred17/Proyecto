from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import time, date

class Profesor(BaseModel):
    id: int
    nombre: str
    class Config:
        from_attributes = True

class AulaBase(BaseModel):
    nombre: str

class Aula(AulaBase):
    id: int
    class Config:
        from_attributes = True

class TipoExamen(BaseModel):
    id: int
    nombre: str
    descripcion: Optional[str] = None
    class Config:
        from_attributes = True

class Materia(BaseModel):
    id: int
    nombre: str
    profesor: Optional[Profesor] = None
    carrera_nombre: Optional[str] = None

    class Config:
        from_attributes = True

class Horario(BaseModel):
    id: int
    dia_semana: str
    hora_inicio: time
    hora_fin: time
    materia: Materia
    aula: Optional[Aula] = None

    class Config:
        from_attributes = True

class Grupo(BaseModel):
    id: int
    nombre_grupo: str
    horarios: List[Horario] = []
    class Config:
        from_attributes = True

class Carrera(BaseModel):
    id: int
    nombre: str
    grupos: List[Grupo] = []
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
    grupo_id: int # Add grupo_id to Examen
    materia: Materia
    aula: Aula
    grupo: Optional[Grupo] = None # Add grupo relationship

    class Config:
        from_attributes = True

# Schemas de Autenticación
class UserBase(BaseModel):
    username: str
    role: str
    email: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool
    
    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None
