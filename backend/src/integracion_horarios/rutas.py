"""Rutas para consultar la API externa de horarios."""
from fastapi import APIRouter, HTTPException
from typing import Optional
from requests.exceptions import ConnectionError, Timeout
import logging

from .servicios.horario_service import HorarioService
from .servicios.aula_service import AulaService
from .servicios.periodo_service import PeriodoService
from .servicios.carrera_service import CarreraService
from .servicios.grupo_service import GrupoService
from .core.config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/horarios-externos", tags=["API Externa de Horarios"])

# ==================== HEALTH CHECK ====================
@router.get("/health")
def verificar_api_externa():
    """Verifica si la API externa de horarios está disponible."""
    try:
        service = PeriodoService()
        service.obtener_periodo_actual()
        return {
            "disponible": True,
            "mensaje": "API externa de horarios disponible",
            "url": settings.API_HORARIOS
        }
    except Exception as e:
        return {
            "disponible": False,
            "mensaje": "API externa de horarios no disponible",
            "error": str(e),
            "url": settings.API_HORARIOS
        }

def manejar_error_api(e: Exception):
    """Maneja errores de la API externa de manera consistente."""
    if isinstance(e, (ConnectionError, Timeout)):
        logger.warning(f"API externa no disponible: {str(e)}")
        raise HTTPException(
            status_code=503, 
            detail={
                "error": "API_NO_DISPONIBLE",
                "mensaje": "La API externa de horarios no está disponible en este momento. Intente más tarde.",
                "disponible": False
            }
        )
    else:
        logger.error(f"Error al consultar API externa: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail={
                "error": "ERROR_CONSULTA",
                "mensaje": f"Error al consultar la API externa: {str(e)}",
                "disponible": False
            }
        )

# ==================== PERIODO ====================
@router.get("/periodo/actual")
def obtener_periodo_actual():
    """Obtiene el periodo académico actual de la API externa."""
    try:
        service = PeriodoService()
        return service.obtener_periodo_actual()
    except Exception as e:
        manejar_error_api(e)

# ==================== CARRERAS ====================
@router.get("/carreras")
def obtener_carreras():
    """Obtiene todas las carreras vigentes de la API externa."""
    try:
        service = CarreraService()
        return service.obtener_todas_carreras()
    except Exception as e:
        manejar_error_api(e)

# ==================== GRUPOS ====================
@router.get("/grupos")
def obtener_grupos(periodo: Optional[str] = None):
    """Obtiene grupos por periodo de la API externa."""
    try:
        service = GrupoService()
        return service.obtener_grupos_por_periodo(periodo=periodo)
    except Exception as e:
        manejar_error_api(e)

@router.get("/grupos/carrera/{clave_carrera}")
def obtener_grupos_por_carrera(clave_carrera: str, periodo: Optional[str] = None):
    """Obtiene grupos de una carrera específica en un periodo de la API externa."""
    try:
        service = GrupoService()
        return service.obtener_grupos_por_carrera(periodo=periodo, carrera=clave_carrera)
    except Exception as e:
        manejar_error_api(e)

# ==================== AULAS ====================
@router.get("/aulas")
def obtener_aulas(page: int = 1, size: int = 200):
    """Obtiene todas las aulas de la API externa."""
    try:
        service = AulaService()
        return service.obtener_todas_aulas(page=page, size=size)
    except Exception as e:
        manejar_error_api(e)

@router.get("/aulas/disponibles")
def obtener_aulas_disponibles(
    periodo: str,
    capacidad: int,
    dia: int,
    hora: int
):
    """
    Obtiene aulas disponibles en un horario específico.
    
    - **periodo**: Periodo académico (ej: 2526A)
    - **capacidad**: Capacidad mínima requerida
    - **dia**: Día de la semana (1=Lunes, 7=Domingo)
    - **hora**: Hora del día (0-23)
    """
    try:
        service = AulaService()
        return service.obtener_aulas_disponibles(
            periodo=periodo,
            capacidad=capacidad,
            dia=dia,
            hora=hora
        )
    except Exception as e:
        manejar_error_api(e)

@router.get("/aulas/capacidad/{capacidad}")
def obtener_aulas_por_capacidad(capacidad: int):
    """Obtiene aulas con capacidad mínima especificada."""
    try:
        service = AulaService()
        return service.obtener_por_capacidad(capacidad=capacidad)
    except Exception as e:
        manejar_error_api(e)

# ==================== HORARIOS ====================
# NOTA: La API externa NO tiene un endpoint para obtener todos los horarios
# Solo tiene endpoints específicos por profesor o grupo
# GET /horarios/{periodo}/{idprofesor}
# GET /horarios/{periodo}/grupo/{idGrupo}

@router.get("/horarios/profesor/{idprofesor}")
def obtener_horarios_profesor(idprofesor: str, periodo: Optional[str] = None):
    """Obtiene los horarios de un profesor específico."""
    try:
        if not periodo:
            periodo = settings.PERIODO_ACTUAL
        service = HorarioService()
        return service.obtener_por_profesor(periodo=periodo, idprofesor=idprofesor)
    except Exception as e:
        manejar_error_api(e)

@router.get("/horarios/grupo/{idGrupo}")
def obtener_horarios_grupo(idGrupo: str, periodo: Optional[str] = None):
    """Obtiene los horarios de un grupo específico."""
    try:
        if not periodo:
            periodo = settings.PERIODO_ACTUAL
        service = HorarioService()
        return service.obtener_por_grupo(periodo=periodo, idGrupo=idGrupo)
    except Exception as e:
        manejar_error_api(e)

@router.get("/horarios/aula/{idAula}")
def obtener_horarios_aula(idAula: str, periodo: Optional[str] = None):
    """Obtiene los horarios de un aula específica."""
    try:
        if not periodo:
            periodo = settings.PERIODO_ACTUAL
        service = HorarioService()
        return service.obtener_por_aula(periodo=periodo, idAula=idAula)
    except Exception as e:
        manejar_error_api(e)

# ==================== VALIDACIONES ====================
@router.post("/validar-disponibilidad")
def validar_disponibilidad(
    fecha: str,
    hora_inicio: int,
    hora_fin: int,
    aula_id: Optional[str] = None,
    profesor_id: Optional[str] = None,
    periodo: Optional[str] = None
):
    """
    Valida si un aula y/o profesor están disponibles en un horario específico.
    
    - **fecha**: Fecha en formato YYYY-MM-DD
    - **hora_inicio**: Hora de inicio (0-23)
    - **hora_fin**: Hora de fin (0-23)
    - **aula_id**: ID del aula a validar (opcional)
    - **profesor_id**: ID del profesor a validar (opcional)
    - **periodo**: Periodo académico (opcional)
    """
    try:
        from datetime import datetime
        fecha_obj = datetime.strptime(fecha, "%Y-%m-%d")
        dia_semana = fecha_obj.isoweekday()  # 1=Lunes, 7=Domingo
        
        if not periodo:
            periodo_service = PeriodoService()
            periodo_data = periodo_service.obtener_periodo_actual()
            periodo = periodo_data.get('clave') if periodo_data else settings.PERIODO_ACTUAL
        
        resultados = {
            "fecha": fecha,
            "dia_semana": dia_semana,
            "hora_inicio": hora_inicio,
            "hora_fin": hora_fin,
            "disponible": True,
            "conflictos": []
        }
        
        # Validar disponibilidad de aula
        if aula_id:
            # La API externa no tiene endpoint para obtener todos los horarios
            # Por lo tanto, esta validación requeriría consultar la base de datos local
            resultados['disponible'] = False
            resultados['conflictos'].append({
                "tipo": "aula",
                "mensaje": "Validación de aula requiere consultar BD local. Use el endpoint de BD interna."
            })
        
        # Validar disponibilidad de profesor
        if profesor_id:
            horario_service = HorarioService()
            horarios_profesor = horario_service.obtener_por_profesor(
                periodo=periodo,
                idprofesor=profesor_id
            )
            
            conflictos_profesor = [
                h for h in horarios_profesor
                if h.get('dia') == dia_semana
                and hora_inicio <= h.get('hora') < hora_fin
            ]
            
            if conflictos_profesor:
                resultados['disponible'] = False
                resultados['conflictos'].append({
                    "tipo": "profesor",
                    "id": profesor_id,
                    "detalles": conflictos_profesor
                })
        
        return resultados
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al validar disponibilidad: {str(e)}")
