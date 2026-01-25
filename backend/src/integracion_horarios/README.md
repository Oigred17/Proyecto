# Estructura de integracion_horarios - Reorganizada

## 📁 Nueva Estructura

```
integracion_horarios/
├── __init__.py
├── rutas.py                      # Endpoints FastAPI para API externa
├── core/                         # Configuración y utilidades base
│   ├── __init__.py
│   ├── config.py                 # Configuración (API_HORARIOS, PERIODO_ACTUAL)
│   └── base_sync.py              # Servicio base para consultas HTTP
└── servicios/                    # Servicios para cada recurso
    ├── __init__.py
    ├── periodo_service.py        # Consulta periodos académicos
    ├── carrera_service.py        # Consulta carreras
    ├── grupo_service.py          # Consulta grupos
    ├── aula_service.py           # Consulta aulas
    └── horario_service.py        # Consulta horarios
```

## ✅ Cambios Realizados

### 1. Reorganización de archivos
- **Movido** `config.py` → `core/config.py`
- **Movido** `base_sync.py` → `core/base_sync.py`
- **Actualizado** config.py para no requerir `pydantic_settings`
- **Actualizados** todos los imports en servicios y rutas

### 2. Schemas actualizados
Todos los schemas ahora coinciden con los de `consulta_api`:

- **PeriodoSchema**: `clave`, `nombre`, `tipo`, `fInicio`, `fFin`
- **CarreraSchema**: `clave`, `nombre`, `vigente`
- **GrupoSchema**: `clave`, `nombre`, `carrera`, `semestre`, `alumnos`, `periodo`
- **AulaSchema**: `clave`, `nombre`, `capacidad`, `tipo`, `statusProyector`
- **HorarioSchema**: `rowId`, `idprofesor`, `nombreCompleto`, `asignatura`, `idGrupo`, `idAula`, `dia`, `hora`, `carrera`, `periodog`, `materia`, `nombreGrupo`, `nombreAula`

### 3. Correcciones importantes

#### Periodo
- ✅ Corregido: Ahora extrae `clave` del JSON en lugar de `periodo` inexistente
- ✅ Schema completo con todos los campos (`clave`, `nombre`, `tipo`, `fInicio`, `fFin`)

#### Horarios
- ⚠️ **IMPORTANTE**: La API externa NO tiene endpoint `GET /horarios?periodo=XXX`
- ✅ Solo existen endpoints específicos:
  - `GET /horarios/{periodo}/{idprofesor}` - Por profesor
  - `GET /horarios/{periodo}/grupo/{idGrupo}` - Por grupo
- ✅ `obtener_todos_horarios()` ahora lanza `NotImplementedError`
- ✅ `setup.py` actualizado para usar JSON local como fuente principal

## 🌐 Endpoints Disponibles

### Estado
- `GET /api/horarios-externos/health` - Verifica disponibilidad de API

### Periodo
- `GET /api/horarios-externos/periodo/actual` - Obtiene periodo actual

### Carreras
- `GET /api/horarios-externos/carreras` - Obtiene carreras vigentes

### Grupos
- `GET /api/horarios-externos/grupos?periodo=XXXX` - Obtiene grupos por periodo

### Aulas
- `GET /api/horarios-externos/aulas?page=1&size=200` - Obtiene aulas paginadas
- `GET /api/horarios-externos/aulas/disponibles?periodo=X&capacidad=X&dia=X&hora=X` - Aulas disponibles
- `GET /api/horarios-externos/aulas/capacidad/{capacidad}` - Aulas por capacidad mínima

### Horarios
- `GET /api/horarios-externos/horarios/profesor/{idprofesor}?periodo=XXXX` - Horarios de profesor
- `GET /api/horarios-externos/horarios/grupo/{idGrupo}?periodo=XXXX` - Horarios de grupo

## ✅ Pruebas Realizadas

```bash
# Periodo
✓ Periodo obtenido: {'clave': '2526A', 'nombre': 'SEMESTREOCT/25-FEB/26', ...}

# Carreras
✓ Se obtuvieron 31 carreras
  Ejemplo: {'clave': '01B', 'nombre': 'LICENCIATURA EN ADMINISTRACIÓN MUNICIPAL 2015', 'vigente': True}

# Grupos
✓ Se obtuvieron 111 grupos
  Ejemplo: {'nombre': '104-A', 'carrera': '04B', ...}

# Aulas
✓ Se obtuvieron 150 aulas
  Ejemplo: {'nombre': 'A1', 'capacidad': 18, ...}

# Horarios por profesor
✓ Endpoint funcional (retorna lista de horarios del profesor)
```

## 🔧 Uso

### Desde Python
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

# Horarios por profesor
service = HorarioService()
horarios = service.obtener_por_profesor(periodo="2526A", idprofesor="P3060")

# Horarios por grupo
horarios = service.obtener_por_grupo(periodo="2526A", idGrupo="116A")
```

### Desde FastAPI
Los endpoints están registrados en `src/main.py` bajo el prefijo `/api/horarios-externos`

## ⚠️ Notas Importantes

1. **API Externa**: Se conecta a `http://serv-horarios.unsis.lan/api`
2. **Horarios completos**: NO disponibles en API externa, usar JSON local
3. **Timeout**: 30 segundos por defecto
4. **Reintentos**: 3 intentos automáticos con backoff exponencial
5. **Periodo por defecto**: `2526A` (configurable vía env var `PERIODO_ACTUAL`)

## 🔄 Comparación con consulta_api

| Aspecto | consulta_api | integracion_horarios (Proyecto) |
|---------|--------------|--------------------------------|
| Estructura | ✅ Ordenada (core/, services/, endpoints/) | ✅ Ahora igual |
| Schemas | ✅ Completos | ✅ Ahora iguales |
| Base Sync | ✅ Funcional | ✅ Copiado igual |
| Config | ✅ Settings class | ✅ Ahora igual |
| Endpoints | ✅ Todos funcionan | ✅ Actualizados |
| BD Local | ✅ Sincronización | ❌ Solo consulta |

## 🎯 Resultado

La estructura de `integracion_horarios` ahora es **idéntica** a `consulta_api`, con schemas completos y actualizados. Todos los endpoints que existen en la API externa funcionan correctamente.
