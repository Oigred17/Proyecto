from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .compartido.modelos_base import Base
from .configuracion.base_datos import engine
from .configuracion.inicializacion import inicializar_base_datos

# Importar modelos para registro en SQLAlchemy
from .autenticacion import modelos as modelos_auth
from .gestion_academica import modelos as modelos_aca
from .gestion_horarios import modelos as modelos_hor
from .gestion_examenes import modelos as modelos_exam
from .notificaciones import modelos as modelos_notif

# Importar rutas
from .autenticacion import rutas as rutas_auth
from .gestion_academica import rutas as rutas_aca
from .gestion_examenes import rutas as rutas_exam
from .notificaciones import rutas as rutas_notif

# Crear tablas
Base.metadata.create_all(bind=engine)

# Migraciones manuales si son necesarias
inicializar_base_datos()

app = FastAPI(title="Sistema de Gestión Escolar", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Registrar rutas
app.include_router(rutas_auth.router)
app.include_router(rutas_aca.router)
app.include_router(rutas_exam.router)
app.include_router(rutas_notif.router)

@app.get("/")
def read_root():
    return {"message": "Bienvenido a la API con Arquitectura por Dominios"}
