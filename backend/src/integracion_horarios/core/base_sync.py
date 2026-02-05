# app/services/base_sync.py
import requests
import logging
from typing import List, Dict, Type, Any
from pydantic import BaseModel, TypeAdapter
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from requests.exceptions import Timeout, ConnectionError

logger = logging.getLogger(__name__)

class BaseSyncService:
    """
    Servicio Base para consultar APIs externas.
    Soporta parámetros de ruta (path params) y parámetros de consulta (query params).
    """

    def __init__(
        self, 
        base_url: str,
        endpoint_path: str,
        schema: Type[BaseModel] = None
    ):
        self.base_url = base_url.rstrip('/')
        self.endpoint_path = endpoint_path 
        self.schema = schema
        self.timeout = 30

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        retry=retry_if_exception_type((Timeout, ConnectionError)),
        reraise=True
    )
    def fetch_data_from_api(self, path_params: dict = None, query_params: dict = None) -> List[Dict]:
        """
        Construye la URL dinámica y hace la petición.
        """
        path_params = path_params or {}
        query_params = query_params or {}

        try:
            formatted_path = self.endpoint_path.format(**path_params)
            full_url = f"{self.base_url}/{formatted_path.lstrip('/')}"
            
            logger.debug(f"Consultando: {full_url} | Query: {query_params}")

            response = requests.get(
                full_url, 
                params=query_params,
                timeout=self.timeout,
                headers={'Accept': 'application/json'}
            )
            response.raise_for_status()
            
            # Hook para extraer datos
            return self.extract_data_from_response(response.json())
            
        except KeyError as e:
            logger.error(f"Falta variable requerida para la URL: {e}")
            raise ValueError(f"La ruta {self.endpoint_path} requiere el parámetro {e}")
        except Exception as e:
            logger.error(f"Error HTTP/Conexión: {e}")
            raise

    def extract_data_from_response(self, data: Any) -> List[Dict]:
        """Método por defecto, sobrescribir en hijos si la API es rara"""
        if isinstance(data, list):
            return data
        if isinstance(data, dict):
            # Busca claves comunes
            return data.get('data', data.get('results', data.get('items', [])))
        return []
    
    def obtener_datos_en_vivo(self, path_params=None, query_params=None):
        """Obtiene datos de la API externa sin guardar en BD"""
        try:
            data = self.fetch_data_from_api(path_params, query_params)
            
            # Validamos con Pydantic si hay schema definido
            if data and self.schema:
                try:
                    adapter = TypeAdapter(List[self.schema])
                    return [item.model_dump() for item in adapter.validate_python(data)]
                except Exception as e:
                    logger.error(f"Error validación: {e}")
                    return data
            return data
        except (Timeout, ConnectionError) as e:
            logger.error(f"API externa no disponible: {e}")
            raise ConnectionError("La API externa de horarios no está disponible en este momento")
        except Exception as e:
            logger.error(f"Error al obtener datos: {e}")
            raise
