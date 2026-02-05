# Integración con API Externa de Horarios

## ✅ Integración Completada

### Estructura del Módulo

```
src/integracion_horarios/
├── __init__.py              # Exporta el router
├── README.md                # Documentación detallada
├── rutas.py                 # Endpoints REST con response_model
├── esquemas.py              # Pydantic schemas para validación
├── core/                    # Configuración central
│   ├── __init__.py
│   ├── config.py           # Settings de API externa
│   └── base_sync.py        # Cliente HTTP base con reintentos
└── services/                # Servicios por recurso
    ├── __init__.py
    ├── periodo_service.py   # Consulta periodos académicos
    ├── carrera_service.py   # Consulta carreras
    ├── grupo_service.py     # Consulta grupos
    ├── aula_service.py      # Consulta aulas
    └── horario_service.py   # Consulta horarios
```

### Archivos Clave

#### Módulo de Integración
- `src/integracion_horarios/rutas.py` - Endpoints FastAPI para API externa
- `src/integracion_horarios/esquemas.py` - Schemas Pydantic (HorarioExterno, CarreraExterna, etc.)
- `src/integracion_horarios/core/config.py` - Configuración de API externa
- `src/integracion_horarios/core/base_sync.py` - Cliente HTTP con reintentos automáticos

#### Servicios
- `src/integracion_horarios/services/periodo_service.py` - Obtiene periodo actual
- `src/integracion_horarios/services/carrera_service.py` - Consulta carreras vigentes
- `src/integracion_horarios/services/grupo_service.py` - Consulta grupos por periodo/carrera
- `src/integracion_horarios/services/aula_service.py` - Consulta aulas
- `src/integracion_horarios/services/horario_service.py` - Consulta horarios por profesor/grupo

### Archivos Modificados

1. **setup.py**
   - Nueva función `populate_from_api()` que consume API externa
   - Obtiene periodo actual dinámicamente de la API
   - Mantiene `populate_from_json()` como fallback
   - Importa desde `src.integracion_horarios.services.*`

2. **src/main.py**
   - Registra router de `integracion_horarios.rutas`
   - Expone endpoints bajo `/api/horarios-externos`

3. **requirements.txt**
   - `requests==2.31.0` - Para HTTP requests
   - `tenacity==8.2.3` - Para reintentos automáticos

### Tests
- `tests/test_integracion_horarios.py` - Tests del módulo de integración

## 📡 Endpoints Disponibles

### Health Check
- `GET /api/horarios-externos/health` - Verifica disponibilidad de API externa

### Periodo
- `GET /api/horarios-externos/periodo/actual` - Obtiene periodo académico actual

### Carreras
- `GET /api/horarios-externos/carreras` - Lista todas las carreras vigentes

### Grupos
- `GET /api/horarios-externos/grupos?periodo=XXXX` - Obtiene grupos por periodo
- `GET /api/horarios-externos/grupos/carrera/{clave}?periodo=XXXX` - Grupos por carrera

### Aulas
- `GET /api/horarios-externos/aulas?page=1&size=200` - Lista aulas paginadas

### Horarios
- `GET /api/horarios-externos/horarios/profesor/{id}?periodo=XXXX` - Horarios de profesor
- `GET /api/horarios-externos/horarios/grupo/{id}?periodo=XXXX` - Horarios de grupo

## 🚀 Instalación y Configuración

### Con Docker (Recomendado)

```bash
cd /home/mayra/Proyecto-Calendario/Proyecto

# Construir e iniciar contenedores
sudo docker compose up -d --build

# Poblar base de datos desde API externa
sudo docker exec -it backend_api python setup.py

# Ver logs del backend
sudo docker logs backend_api -f
```

### Sin Docker

```bash
cd /home/mayra/Proyecto-Calendario/Proyecto/backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
export DATABASE_URL="postgresql+psycopg2://proj_user:proj_pass@localhost:5432/proyecto_db"

# Poblar base de datos desde API externa
python setup.py --reset

# Iniciar servidor
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

## 🔧 Configuración

### Variables de Entorno (Opcional)

Las siguientes variables se pueden configurar en `.env` o como variables de entorno:

```bash
# URL de la API externa de horarios (por defecto: http://serv-horarios.unsis.lan/api)
API_HORARIOS=http://serv-horarios.unsis.lan/api

# Periodo académico por defecto (se obtiene dinámicamente de la API)
PERIODO_ACTUAL=2526A

# Base de datos
DATABASE_URL=postgresql+psycopg2://proj_user:proj_pass@db:5432/proyecto_db
```

### Configuración en `core/config.py`

El archivo de configuración se encuentra en `src/integracion_horarios/core/config.py` y define:

- `API_HORARIOS`: URL base de la API externa
- `PERIODO_ACTUAL`: Periodo académico por defecto
- Timeout de 30 segundos para requests HTTP
- Reintentos automáticos configurados en `base_sync.py`

## 📝 Flujo de Trabajo

### 1. Inicialización del Sistema

```bash
# Con Docker
sudo docker exec -it backend_api python setup.py --reset

# Sin Docker
python setup.py --reset
```

**Proceso:**
1. Crea todas las tablas en la base de datos
2. Ejecuta migraciones automáticas
3. Consulta `/periodo/actual` para obtener periodo académico vigente
4. Consulta `/grupos?periodo=XXXX` para obtener todos los grupos
5. Para cada grupo, consulta `/horarios/{periodo}/grupo/{id}`
6. Parsea y guarda en BD local: Carreras, Grupos, Profesores, Aulas, Materias, Horarios
7. Crea usuarios del sistema (admin, escolares, jefes de carrera)
8. Si falla la API → carga desde JSON local automáticamente (fallback)

### 2. Consultas en Tiempo Real

Las consultas se hacen directamente a la API externa a través de los servicios:

**Ejemplo: Obtener horarios de un grupo**
```python
from src.integracion_horarios.services.horario_service import HorarioService

service = HorarioService()
horarios = service.obtener_por_grupo(periodo="2526A", idGrupo="106-A")
# Retorna lista de diccionarios con los horarios del grupo
```

**Ejemplo: Verificar carreras vigentes**
```python
from src.integracion_horarios.services.carrera_service import CarreraService

service = CarreraService()
carreras = service.obtener_todas_carreras()
# Retorna lista de carreras con clave, nombre y vigencia
```

## 🎯 Casos de Uso

### 1. Programar un Examen
1. Usuario selecciona fecha, hora, materia y carrera
2. Sistema consulta la BD local para verificar disponibilidad
3. Si necesita datos actualizados, consulta API externa:
   - `GET /api/horarios-externos/horarios/grupo/{id}?periodo=2526A`
4. Muestra aulas y horarios disponibles
5. Usuario selecciona aula y profesor sinodal
6. Sistema crea el examen en BD local

### 2. Ver Horarios de un Profesor
```bash
# Desde API REST
GET /api/horarios-externos/horarios/profesor/P123?periodo=2526A

# Desde Python
from src.integracion_horarios.services.horario_service import HorarioService
service = HorarioService()
horarios = service.obtener_por_profesor(periodo="2526A", idprofesor="P123")
```

### 3. Consultar Grupos de una Carrera
```bash
# Desde API REST
GET /api/horarios-externos/grupos/carrera/06B?periodo=2526A

# Desde Python
from src.integracion_horarios.services.grupo_service import GrupoService
service = GrupoService()
grupos = service.obtener_grupos_por_carrera(periodo="2526A", carrera="06B")
```

### 4. Sincronizar Datos Completos
```bash
# Con Docker
sudo docker exec -it backend_api python setup.py --reset

# Sin Docker
python setup.py --reset
```
Descarga todos los datos actualizados de la API externa y los guarda en la BD local.

## 🔍 Verificación

### Probar Conexión a API Externa
```bash
cd /home/mayra/Proyecto-Calendario/Proyecto/backend
python -c "
from src.integracion_horarios.services.periodo_service import PeriodoService
service = PeriodoService()
periodo = service.obtener_periodo_actual()
print('Periodo actual:', periodo)
"
```

### Probar Consulta de Carreras
```bash
python -c "
from src.integracion_horarios.services.carrera_service import CarreraService
service = CarreraService()
carreras = service.obtener_todas_carreras()
print(f'Total carreras: {len(carreras)}')
print('Primera carrera:', carreras[0] if carreras else 'N/A')
"
```

### Probar Horarios por Grupo
```bash
python -c "
from src.integracion_horarios.services.horario_service import HorarioService
service = HorarioService()
horarios = service.obtener_por_grupo(periodo='2526A', idGrupo='106-A')
print(f'Horarios del grupo 106-A: {len(horarios)}')
"
```

### Verificar Endpoints desde Terminal
```bash
# Health check
curl http://localhost:8000/api/horarios-externos/health

# Periodo actual
curl http://localhost:8000/api/horarios-externos/periodo/actual

# Carreras
curl http://localhost:8000/api/horarios-externos/carreras

# Horarios de un grupo
curl "http://localhost:8000/api/horarios-externos/horarios/grupo/106-A?periodo=2526A"
```

## ⚠️ Notas Importantes

1. **API Externa debe estar accesible**
   - URL: `http://serv-horarios.unsis.lan/api`
   - Configurada en `extra_hosts` del docker-compose.yml
   - Verifica conectividad con: `curl http://serv-horarios.unsis.lan/api/periodo/actual`

2. **Reintentos automáticos**
   - Implementados en `core/base_sync.py` con `tenacity`
   - 3 intentos por defecto con backoff exponencial
   - Timeout de 30 segundos por request

3. **Fallback automático a JSON**
   - Si la API externa falla, `setup.py` usa automáticamente los archivos JSON locales
   - Archivos en: `/db/horarios/horario_por_grupo.json`

4. **Schemas con validación**
   - Todos los endpoints tienen `response_model` definido
   - Validación automática con Pydantic en `esquemas.py`
   - Tipos: `HorarioExterno`, `CarreraExterna`, `GrupoExterno`, etc.

5. **Logs detallados**
   - Revisa logs del backend: `sudo docker logs backend_api -f`
   - Salida de setup.py muestra progreso de la sincronización

6. **Estructura consistente**
   - Módulo sigue el mismo patrón que `gestion_academica`, `gestion_examenes`
   - `services/` para lógica de negocio
   - `esquemas.py` para validación
   - `rutas.py` para endpoints REST

## 📊 Arquitectura del Proyecto

```
Proyecto/
├── backend/
│   ├── src/
│   │   ├── integracion_horarios/      ← Módulo de integración API externa
│   │   │   ├── rutas.py              ← Endpoints REST
│   │   │   ├── esquemas.py           ← Schemas Pydantic
│   │   │   ├── services/             ← Servicios de consulta
│   │   │   └── core/                 ← Configuración y HTTP client
│   │   ├── gestion_academica/         ← Gestión de carreras, profesores, etc.
│   │   ├── gestion_examenes/          ← Gestión de exámenes
│   │   ├── gestion_horarios/          ← Gestión de horarios locales
│   │   └── autenticacion/             ← Login y usuarios
│   ├── setup.py                       ← Inicialización y sincronización
│   └── tests/
│       └── test_integracion_horarios.py
├── db/
│   └── horarios/
│       └── horario_por_grupo.json     ← Fallback si API falla
└── docker-compose.yml

API Externa: http://serv-horarios.unsis.lan/api
    ↓
Backend (integracion_horarios)
    ↓
Base de Datos Local (PostgreSQL)
    ↓
Frontend (React)
```

## 🎉 Ventajas de la Integración

✅ **Un solo proyecto** - Más fácil de mantener y desplegar
✅ **Sin dependencias entre servicios** - Todo integrado en el backend
✅ **Datos siempre actualizados** - Consulta directa a API externa
✅ **Código probado** - Basado en el módulo `consulta_api` funcional
✅ **Fallback automático** - Si API falla, usa JSON local
✅ **Endpoints expuestos** - Frontend puede consumir datos externos
✅ **Validación robusta** - Schemas Pydantic en todos los endpoints
✅ **Estructura consistente** - Mismo patrón que otros módulos del backend
✅ **Documentación automática** - Swagger UI disponible en `/docs`
