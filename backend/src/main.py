from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Intentar inicializar base de datos
try:
    from .compartido.modelos_base import Base
    from .configuracion.base_datos import engine
    from .configuracion.inicializacion import inicializar_base_datos
    
    # Importar modelos para registro en SQLAlchemy
    from .autenticacion import modelos as modelos_auth
    from .gestion_academica import modelos as modelos_aca
    from .gestion_horarios import modelos as modelos_hor
    from .gestion_examenes import modelos as modelos_exam
    from .notificaciones import modelos as modelos_notif
    
    # Crear tablas
    Base.metadata.create_all(bind=engine)
    
    # Migraciones manuales si son necesarias
    inicializar_base_datos()
    
    logger.info("✓ Base de datos inicializada correctamente")
except Exception as e:
    logger.error(f"✗ Error al inicializar base de datos: {str(e)}")
    logger.info("La aplicación continuará pero con funcionalidad limitada")

# Importar rutas
from .autenticacion import rutas as rutas_auth
from .gestion_academica import rutas as rutas_aca
from .gestion_examenes import rutas as rutas_exam
from .notificaciones import rutas as rutas_notif
from .integracion_horarios import rutas as rutas_horarios_externos

app = FastAPI(title="Sistema de Gestión Escolar", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:80",
        "http://localhost:3000", 
        "http://localhost:5173",
        "http://127.0.0.1",
        "http://127.0.0.1:80",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
        "*"  # Permitir todos los orígenes en desarrollo
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

# Registrar rutas con manejo de errores
try:
    app.include_router(rutas_auth.router)
    logger.info("✓ Rutas de autenticación registradas")
except Exception as e:
    logger.warning(f"⚠ No se pudieron registrar rutas de autenticación: {str(e)}")

try:
    app.include_router(rutas_aca.router)
    logger.info("✓ Rutas académicas registradas")
except Exception as e:
    logger.warning(f"⚠ No se pudieron registrar rutas académicas: {str(e)}")

try:
    app.include_router(rutas_exam.router)
    logger.info("✓ Rutas de exámenes registradas")
except Exception as e:
    logger.warning(f"⚠ No se pudieron registrar rutas de exámenes: {str(e)}")

try:
    app.include_router(rutas_notif.router)
    logger.info("✓ Rutas de notificaciones registradas")
except Exception as e:
    logger.warning(f"⚠ No se pudieron registrar rutas de notificaciones: {str(e)}")

try:
    app.include_router(rutas_horarios_externos.router)
    logger.info("✓ Rutas de horarios externos registradas")
except Exception as e:
    logger.warning(f"⚠ No se pudieron registrar rutas de horarios externos: {str(e)}")

@app.get("/")
def read_root():
    return {
        "message": "Bienvenido a la API con Arquitectura por Dominios",
        "status": "online"
    }
