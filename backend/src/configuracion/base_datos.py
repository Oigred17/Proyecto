import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Usar variable de entorno o SQLite por defecto
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./horarios.db")

# Ajustes para SQLite
connect_args = {"check_same_thread": False} if "sqlite" in DATABASE_URL else {}

engine = create_engine(
    DATABASE_URL, 
    connect_args=connect_args
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def obtener_db():
    """Dependencia para obtener la sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
