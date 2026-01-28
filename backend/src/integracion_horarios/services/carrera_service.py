"""Servicio para consultar carreras de la API externa."""
from pydantic import BaseModel
from ..core.base_sync import BaseSyncService
from ..core.config import settings

class CarreraSchema(BaseModel):
    """Schema para validar datos de carreras de la API externa."""
    clave: str
    nombre: str
    vigente: bool = True  # Opcional, por defecto True

class CarreraService(BaseSyncService):
    """Servicio para obtener carreras de la API externa."""
    
    def __init__(self):
        super().__init__(
            base_url=settings.API_HORARIOS,
            endpoint_path="/carreras/vigentes",
            schema=CarreraSchema
        )
    
    def extract_data_from_response(self, data):
        """Extrae carreras si vienen en un objeto anidado."""
        if isinstance(data, dict):
            return data.get('carreras', [])
        return super().extract_data_from_response(data)
    
    def obtener_todas_carreras(self):
        """
        Obtiene todas las carreras vigentes.
        Endpoint: GET /carreras/vigentes
        
        Este endpoint ya devuelve solo las carreras marcadas como vigentes,
        por lo que no es necesario filtrar.
        """
        return self.obtener_datos_en_vivo()
