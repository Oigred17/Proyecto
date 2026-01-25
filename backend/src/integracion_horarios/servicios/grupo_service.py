"""Servicio para consultar grupos de la API externa."""
from pydantic import BaseModel
from ..core.base_sync import BaseSyncService
from ..core.config import settings

class GrupoSchema(BaseModel):
    """Schema para validar datos de grupos de la API externa."""
    clave: str
    nombre: str
    carrera: str
    semestre: int
    alumnos: int
    periodo: str

class GrupoService(BaseSyncService):
    """Servicio para obtener grupos de la API externa."""
    
    def __init__(self):
        super().__init__(
            base_url=settings.API_HORARIOS,
            endpoint_path="/grupos/periodo={periodo}",
            schema=GrupoSchema
        )
    
    def extract_data_from_response(self, data):
        """Extrae grupos si vienen en un objeto anidado."""
        if isinstance(data, dict):
            return data.get('grupos', [])
        return super().extract_data_from_response(data)
    
    def obtener_grupos_por_periodo(self, periodo: str = None):
        """
        Obtiene todos los grupos de un periodo.
        Endpoint: GET /grupos/periodo=XXXX
        """
        if not periodo:
            periodo = settings.PERIODO_ACTUAL
        
        return self.obtener_datos_en_vivo(
            path_params={"periodo": periodo}
        )
    
    def obtener_grupos_por_carrera(self, periodo: str = None, carrera: str = None):
        """
        Obtiene grupos de una carrera específica en un periodo.
        Endpoint: GET /grupos/lista-carrera/periodo=XXXX&carrera=YY
        """
        if not periodo:
            periodo = settings.PERIODO_ACTUAL
        if not carrera:
            raise ValueError("Se requiere especificar la clave de carrera")
        
        # Cambiar temporalmente el endpoint
        original_endpoint = self.endpoint_path
        self.endpoint_path = "/grupos/lista-carrera/periodo={periodo}&carrera={carrera}"
        
        try:
            result = self.obtener_datos_en_vivo(
                path_params={"periodo": periodo, "carrera": carrera}
            )
            return result
        finally:
            # Restaurar el endpoint original
            self.endpoint_path = original_endpoint
