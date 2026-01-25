"""Servicio para consultar horarios de la API externa."""
from typing import Optional
from pydantic import BaseModel
from ..core.base_sync import BaseSyncService
from ..core.config import settings

class HorarioSchema(BaseModel):
    """Schema para validar datos de horarios de la API externa."""
    rowId: int
    idprofesor: str
    nombreCompleto: str
    asignatura: str
    idGrupo: str
    idAula: str
    dia: int
    hora: int
    carrera: Optional[str] = None
    periodog: str
    materia: str
    nombreGrupo: str
    nombreAula: str

class HorarioService(BaseSyncService):
    """Servicio para obtener horarios de la API externa."""
    
    def __init__(self):
        super().__init__(
            base_url=settings.API_HORARIOS,
            endpoint_path="/horarios",
            schema=HorarioSchema
        )
    
    def obtener_todos_horarios(self, periodo: str = None):
        """
        Obtiene todos los horarios de un periodo.
        NOTA: Este método está diseñado para cargar desde JSON local ya que la API 
        externa no tiene un endpoint GET /horarios?periodo=XXX
        La API externa solo tiene endpoints específicos por profesor o grupo.
        """
        # Este método no funciona con la API externa real
        # Se mantiene por compatibilidad con setup.py que carga desde JSON
        raise NotImplementedError(
            "La API externa no soporta obtener todos los horarios. "
            "Use obtener_por_profesor() o obtener_por_grupo() en su lugar, "
            "o cargue desde JSON local con populate_from_json()."
        )
    
    def obtener_por_profesor(self, periodo: str, idprofesor: str):
        """
        Obtiene horarios de un profesor específico.
        Endpoint: GET /horarios/{periodo}/{idprofesor}
        """
        service = BaseSyncService(
            base_url=settings.API_HORARIOS,
            endpoint_path="/horarios/{periodo}/{idprofesor}",
            schema=HorarioSchema
        )
        return service.obtener_datos_en_vivo(
            path_params={"periodo": periodo, "idprofesor": idprofesor}
        )
    
    def obtener_por_grupo(self, periodo: str, idGrupo: str):
        """
        Obtiene horarios de un grupo específico.
        Endpoint: GET /horarios/{periodo}/grupo/{idGrupo}
        """
        service = BaseSyncService(
            base_url=settings.API_HORARIOS,
            endpoint_path="/horarios/{periodo}/grupo/{idGrupo}",
            schema=HorarioSchema
        )
        return service.obtener_datos_en_vivo(
            path_params={"periodo": periodo, "idGrupo": idGrupo}
        )
    
    def obtener_por_aula(self, periodo: str, idAula: str):
        """
        Obtiene horarios de un aula específica.
        Endpoint: GET /horarios/{periodo}/aula/{idAula}
        """
        service = BaseSyncService(
            base_url=settings.API_HORARIOS,
            endpoint_path="/horarios/{periodo}/aula/{idAula}",
            schema=HorarioSchema
        )
        return service.obtener_datos_en_vivo(
            path_params={"periodo": periodo, "idAula": idAula}
        )
