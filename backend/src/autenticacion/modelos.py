"""Modelos de autenticación y usuarios del sistema."""
from sqlalchemy import Column, Integer, String
from ..compartido.modelos_base import Base

class User(Base):
    """Modelo de usuario del sistema."""
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=True)
    carrera = Column(String, nullable=True)
    is_active = Column(Integer, default=1)
