# Módulo de Integración con API Externa de Horarios

## 📁 Estructura

```
integracion_horarios/
├── __init__.py
├── rutas.py                      # Endpoints FastAPI para consumir API externa
├── esquemas.py                   # Pydantic schemas para validación
├── core/                         # Configuración y utilidades base
│   ├── __init__.py
│   ├── config.py                 # Configuración (API_HORARIOS, PERIODO_ACTUAL)
│   └── base_sync.py              # Servicio base para consultas HTTP
└── services/                     # Servicios para cada recurso
    ├── __init__.py
    ├── periodo_service.py        # Consulta periodos académicos
    ├── carrera_service.py        # Consulta carreras
    ├── grupo_service.py          # Consulta grupos
    ├── aula_service.py           # Consulta aulas
    └── horario_service.py        # Consulta horarios
```

## 📝 Descripción

Este módulo proporciona integración con la API externa de horarios (`serv-horarios.unsis.lan`). Implementa una capa de abstracción que permite consultar:

- **Periodos académicos** actuales y vigentes
- **Carreras** activas en la institución
- **Grupos** por periodo y carrera
- **Aulas** disponibles con capacidad y equipamiento
- **Horarios** por profesor y grupo

## 🎯 Schemas Definidos

### `HorarioExterno`
Representa un horario obtenido de la API externa.

### `CarreraExterna`
Información de una carrera (clave, nombre, vigencia).

### `GrupoExterno`
Datos de un grupo académico.

### `AulaExterna`
Información de un aula (nombre, capacidad, tipo).

### `PeriodoExterno`
Periodo académico (clave, nombre, estado).

### `APIExternaHealth`
Respuesta del health check de la API.

## 🌐 Endpoints Disponibles

### Estado
- `GET /api/horarios-externos/health` - Verifica disponibilidad de API externa

### Periodo
- `GET /api/horarios-externos/periodo/actual` - Obtiene periodo académico actual

### Carreras
- `GET /api/horarios-externos/carreras` - Lista todas las carreras vigentes

### Grupos
- `GET /api/horarios-externos/grupos?periodo=XXXX` - Grupos por periodo
- `GET /api/horarios-externos/grupos/carrera/{clave}?periodo=XXXX` - Grupos por carrera

### Aulas
- `GET /api/horarios-externos/aulas?page=1&size=200` - Lista aulas paginadas

### Horarios
- `GET /api/horarios-externos/horarios/profesor/{id}?periodo=XXXX` - Horarios de profesor
- `GET /api/horarios-externos/horarios/grupo/{id}?periodo=XXXX` - Horarios de grupo

## 🔧 Uso desde Python
```python
from src.integracion_horarios.servicios.periodo_service import PeriodoService
from src.integracion_horarios.servicios.carrera_service import CarreraService
from src.integracion_horarios.servicios.grupo_service import GrupoService
from src.integracion_horarios.servicios.aula_service import AulaService
from src.integracion_horarios.servicios.horario_service import HorarioService

# Periodo
service = PeriodoService()
periodo = service.obtener_periodo_actual()
print(periodo['clave'])  # "2526A"

# Carreras
service = CarreraService()
carreras = service.obtener_todas_carreras()

# Grupos
service = GrupoService()
grupos = service.obtener_grupos_por_periodo(periodo="2526A")

# Aulas
service = AulaService()
aulas = service.obtener_todas_aulas(page=1, size=200)

```python
from src.integracion_horarios.services.periodo_service import PeriodoService
from src.integracion_horarios.services.carrera_service import CarreraService
from src.integracion_horarios.services.horario_service import HorarioService

# Obtener periodo actual
periodo_service = PeriodoService()
periodo = periodo_service.obtener_periodo_actual()

# Obtener carreras vigentes
carrera_service = CarreraService()
carreras = carrera_service.obtener_todas_carreras()

# Horarios por profesor
horario_service = HorarioService()
horarios = horario_service.obtener_por_profesor(periodo="2526A", idprofesor="P3060")

# Horarios por grupo
horarios = horario_service.obtener_por_grupo(periodo="2526A", idGrupo="116A")
```

### Desde API REST
Los endpoints están disponibles bajo `/api/horarios-externos`:

```bash
# Health check
curl http://localhost:8000/api/horarios-externos/health

# Periodo actual
curl http://localhost:8000/api/horarios-externos/periodo/actual

# Carreras
curl http://localhost:8000/api/horarios-externos/carreras

# Grupos
curl http://localhost:8000/api/horarios-externos/grupos?periodo=2526A

# Horarios por grupo
curl http://localhost:8000/api/horarios-externos/horarios/grupo/106-A?periodo=2526A
```

## ⚙️ Configuración

Variables de entorno (opcional):

```bash
API_HORARIOS=http://serv-horarios.unsis.lan/api
PERIODO_ACTUAL=2526A
```

## 📋 Tests

Los tests están en `/backend/tests/test_integracion_horarios.py`:

```bash
# Ejecutar tests
cd backend
python -m pytest tests/test_integracion_horarios.py -v
```

## ⚠️ Notas Importantes

1. **API Externa**: Debe estar accesible en `http://serv-horarios.unsis.lan/api`
2. **Timeout**: 30 segundos por defecto para cada request
3. **Manejo de errores**: Los endpoints retornan HTTP 503 si la API externa no está disponible
4. **Cache**: No implementado - cada consulta va directamente a la API externa
5. **Periodo por defecto**: `2526A` (configurable)

## 🔄 Flujo de Datos

```
Frontend → Backend (rutas.py) → Services → API Externa → Response
              ↓
          esquemas.py (validación)
```

## 📦 Dependencias

- `requests`: Para HTTP requests a la API externa
- `pydantic`: Para validación de schemas
- `fastapi`: Para endpoints REST
