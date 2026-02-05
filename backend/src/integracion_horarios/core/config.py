# app/core/config.py
"""Configuración para la integración con la API externa de horarios."""
import os

class Settings:
    """Configuración de la API externa de horarios."""
    API_HORARIOS: str = os.getenv("API_HORARIOS_URL", "http://serv-horarios.unsis.lan/api")
    PERIODO_ACTUAL: str = os.getenv("PERIODO_ACTUAL", "2526A")
    REQUEST_TIMEOUT: int = int(os.getenv("API_HORARIOS_TIMEOUT", "30"))

settings = Settings()
