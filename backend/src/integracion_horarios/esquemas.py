"""Esquemas Pydantic para la integración con API externa de horarios."""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import time


class HorarioExterno(BaseModel):
    """Esquema para un horario obtenido de la API externa."""
    carrera: str
    nombreCarrera: Optional[str] = None
    nombreGrupo: str
    materia: str
    nombreCompleto: str  # Profesor
    nombreAula: str
    dia: int = Field(ge=1, le=7, description="Día de la semana (1=Lunes, 7=Domingo)")
    hora: int = Field(ge=0, le=23, description="Hora de inicio")
    
    class Config:
        json_schema_extra = {
            "example": {
                "carrera": "06B",
                "nombreCarrera": "LICENCIATURA EN INFORMÁTICA 2022",
                "nombreGrupo": "106-A",
                "materia": "Programación Web",
                "nombreCompleto": "Juan Pérez García",
                "nombreAula": "Lab 3",
                "dia": 1,
                "hora": 8
            }
        }


class CarreraExterna(BaseModel):
    """Esquema para una carrera obtenida de la API externa."""
    clave: str
    nombre: str
    vigente: bool = True
    
    class Config:
        json_schema_extra = {
            "example": {
                "clave": "06B",
                "nombre": "LICENCIATURA EN INFORMÁTICA 2022",
                "vigente": True
            }
        }


class GrupoExterno(BaseModel):
    """Esquema para un grupo obtenido de la API externa."""
    clave: str
    carrera: str
    nombreCarrera: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "clave": "106-A",
                "carrera": "06B",
                "nombreCarrera": "LICENCIATURA EN INFORMÁTICA 2022"
            }
        }


class AulaExterna(BaseModel):
    """Esquema para un aula obtenida de la API externa."""
    nombre: str
    capacidad: Optional[int] = None
    tipo: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "nombre": "Lab 3",
                "capacidad": 30,
                "tipo": "Laboratorio"
            }
        }


class PeriodoExterno(BaseModel):
    """Esquema para un periodo académico obtenido de la API externa."""
    clave: str
    nombre: Optional[str] = None
    activo: bool = True
    
    class Config:
        json_schema_extra = {
            "example": {
                "clave": "2526A",
                "nombre": "Enero-Junio 2025",
                "activo": True
            }
        }


class APIExternaHealth(BaseModel):
    """Esquema para la respuesta del health check de la API externa."""
    disponible: bool
    mensaje: str
    url: str
    error: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "disponible": True,
                "mensaje": "API externa de horarios disponible",
                "url": "http://serv-horarios.unsis.lan/api"
            }
        }
