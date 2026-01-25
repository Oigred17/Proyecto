"""Servicio para consultar periodos académicos de la API externa."""
from pydantic import BaseModel
from ..core.base_sync import BaseSyncService
from ..core.config import settings
from typing import Any, List, Dict

class PeriodoSchema(BaseModel):
    """Schema para validar datos de periodos de la API externa."""
    clave: str
    nombre: str
    tipo: str
    fInicio: str
    fFin: str

class PeriodoService(BaseSyncService):
    """Servicio para obtener periodos académicos de la API externa."""
    
    def __init__(self):
        super().__init__(
            base_url=settings.API_HORARIOS,
            endpoint_path="/periodo/actual",
            schema=PeriodoSchema
        )
    
    def extract_data_from_response(self, data: Any) -> List[Dict]:
        if isinstance(data, dict):
            return [data]
        return super().extract_data_from_response(data)
    
    def obtener_periodo_actual(self):
        """
        Obtiene el periodo académico actual.
        Endpoint: GET /periodo/actual
        """
        resultado = self.obtener_datos_en_vivo()
        return resultado[0] if resultado else None
