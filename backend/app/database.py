from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

# Obtener la URL de la base de datos desde la variable de entorno
# Si no existe, usar SQLite como fallback
SQLALCHEMY_DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "sqlite:///./horarios.db"
)

# Configuración del engine según el tipo de base de datos
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, 
        connect_args={"check_same_thread": False}
    )
else:
    # Para PostgreSQL no necesitamos check_same_thread
    engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
