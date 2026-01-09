from sqlalchemy import Column, Integer, String
from ..compartido.modelos_base import Base

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False)  # 'servicios_escolares', 'jefe_carrera', 'secretaria'
    email = Column(String, unique=True, index=True, nullable=True)
    carrera = Column(String, nullable=True)  # Nombre de la carrera para jefe_carrera
    is_active = Column(Integer, default=1)  # 1 for active, 0 for inactive
