"""Servicio para consultar aulas de la API externa."""
from pydantic import BaseModel
from typing import Optional
from ..core.base_sync import BaseSyncService
from ..core.config import settings

class AulaSchema(BaseModel):
    """Schema para validar datos de aulas de la API externa."""
    clave: str
    nombre: str
    capacidad: int
    tipo: str
    statusProyector: Optional[str] = None

class AulaService(BaseSyncService):
    """Servicio para obtener aulas de la API externa."""
    
    def __init__(self):
        super().__init__(
            base_url=settings.API_HORARIOS,
            endpoint_path="/aulas",
            schema=AulaSchema
        )
    
    def obtener_todas_aulas(self, page: int = 1, size: int = 200):
        """
        Obtiene todas las aulas.
        Endpoint: GET /aulas?page=X&size=Y
        """
        return self.obtener_datos_en_vivo(
            query_params={"page": page, "size": size}
        )
    
    def obtener_aulas_disponibles(self, periodo: str, capacidad: int, dia: int, hora: int):
        """
        Obtiene aulas disponibles en un horario específico.
        Endpoint: GET /aulas/buscarlibres/periodo={periodo}&capacidad={capacidad}&dia={dia}&hora={hora}
        """
        service = BaseSyncService(
            base_url=settings.API_HORARIOS,
            endpoint_path="/aulas/buscarlibres/periodo={periodo}&capacidad={capacidad}&dia={dia}&hora={hora}",
            schema=AulaSchema
        )
        return service.obtener_datos_en_vivo(
            path_params={
                "periodo": periodo,
                "capacidad": capacidad,
                "dia": dia,
                "hora": hora
            }
        )
    
    def obtener_por_capacidad(self, capacidad: int):
        """
        Obtiene aulas con capacidad mínima.
        Endpoint: GET /aulas/capacidad/{capacidad}
        """
        service = BaseSyncService(
            base_url=settings.API_HORARIOS,
            endpoint_path="/aulas/capacidad/{capacidad}",
            schema=AulaSchema
        )
        return service.obtener_datos_en_vivo(
            path_params={"capacidad": capacidad}
        )
