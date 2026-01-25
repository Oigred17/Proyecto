# Integración con API Externa de Horarios

## ✅ Integración Completada

### Archivos Creados

#### Módulo de Integración
- `src/integracion_horarios/__init__.py` - Módulo principal
- `src/integracion_horarios/config.py` - Configuración de API externa
- `src/integracion_horarios/base_sync.py` - Servicio base con reintentos
- `src/integracion_horarios/rutas.py` - Endpoints FastAPI para API externa

#### Servicios
- `src/integracion_horarios/servicios/__init__.py`
- `src/integracion_horarios/servicios/horario_service.py` - Consulta horarios
- `src/integracion_horarios/servicios/aula_service.py` - Consulta aulas
- `src/integracion_horarios/servicios/periodo_service.py` - Consulta periodos
- `src/integracion_horarios/servicios/carrera_service.py` - Consulta carreras
- `src/integracion_horarios/servicios/grupo_service.py` - Consulta grupos

### Archivos Modificados

1. **setup.py**
   - Nueva función `populate_from_api()` que consume API externa
   - Obtiene periodo actual dinámicamente de la API
   - Mantiene `populate_from_json()` como fallback
   - Importa servicios de integración

2. **src/main.py**
   - Registra router de `integracion_horarios.rutas`
   - Expone endpoints para consultar API externa

3. **requirements.txt**
   - Agregado: `requests==2.31.0`
   - Agregado: `tenacity==8.2.3`

## 📡 Endpoints Disponibles

### Periodo
- `GET /api/horarios-externos/periodo/actual` - Obtiene periodo académico actual

### Carreras
- `GET /api/horarios-externos/carreras` - Obtiene carreras vigentes

### Grupos
- `GET /api/horarios-externos/grupos?periodo=XXXX` - Obtiene grupos por periodo

### Aulas
- `GET /api/horarios-externos/aulas?page=1&size=200` - Obtiene todas las aulas
- `GET /api/horarios-externos/aulas/disponibles?periodo=X&capacidad=X&dia=X&hora=X` - Aulas disponibles
- `GET /api/horarios-externos/aulas/capacidad/{capacidad}` - Aulas por capacidad

### Horarios
- `GET /api/horarios-externos/horarios?periodo=XXXX` - Obtiene todos los horarios
- `GET /api/horarios-externos/horarios/profesor/{id}?periodo=XXXX` - Horarios de profesor
- `GET /api/horarios-externos/horarios/grupo/{id}?periodo=XXXX` - Horarios de grupo

### Validaciones
- `POST /api/horarios-externos/validar-disponibilidad` - Valida disponibilidad de aula/profesor

## 🚀 Instalación

```bash
cd /home/mayra/Proyecto-Calendario/Proyecto/backend

# Instalar dependencias nuevas
pip install -r requirements.txt

# Configurar variables de entorno (opcional)
export API_HORARIOS_URL="http://serv-horarios.unsis.lan/api"
export PERIODO_ACTUAL="2526A"
export DATABASE_URL="postgresql+psycopg2://proj_user:proj_pass@127.0.0.1:5432/proyecto_db"

# Poblar base de datos desde API externa
python setup.py --reset

# Iniciar servidor
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

## 🔧 Configuración

### Variables de Entorno

```bash
# URL de la API externa de horarios
API_HORARIOS_URL="http://serv-horarios.unsis.lan/api"

# Periodo académico por defecto (se obtiene dinámicamente de la API)
PERIODO_ACTUAL="2526A"

# Timeout para peticiones HTTP (segundos)
API_HORARIOS_TIMEOUT="30"

# Base de datos
DATABASE_URL="postgresql+psycopg2://proj_user:proj_pass@127.0.0.1:5432/proyecto_db"
```

## 📝 Flujo de Trabajo

### 1. Inicialización del Sistema
```bash
python setup.py --reset
```

**Proceso:**
1. Consulta `/periodo/actual` para obtener periodo académico
2. Consulta `/horarios?periodo=XXXX` para obtener todos los horarios
3. Parsea y guarda en BD local: Carreras, Grupos, Profesores, Aulas, Materias, Horarios
4. Si falla la API → carga desde JSON local (fallback)

### 2. Consultas en Tiempo Real

**Ejemplo: Validar disponibilidad de aula**
```python
POST /api/horarios-externos/validar-disponibilidad
{
  "fecha": "2026-01-21",
  "hora_inicio": 8,
  "hora_fin": 10,
  "aula_id": "116",
  "profesor_id": "P123",
  "periodo": "2526A"
}
```

**Respuesta:**
```json
{
  "fecha": "2026-01-21",
  "dia_semana": 2,
  "hora_inicio": 8,
  "hora_fin": 10,
  "disponible": false,
  "conflictos": [
    {
      "tipo": "aula",
      "id": "116",
      "detalles": [...]
    }
  ]
}
```

## 🎯 Casos de Uso

### 1. Programar un Examen
1. Usuario selecciona fecha, hora, materia
2. Frontend llama a `/api/horarios-externos/aulas/disponibles`
3. Muestra aulas libres
4. Usuario selecciona aula y profesor sinodal
5. Frontend llama a `/api/horarios-externos/validar-disponibilidad`
6. Si está disponible, crea el examen en BD local

### 2. Ver Horario de Profesor
```bash
GET /api/horarios-externos/horarios/profesor/P123?periodo=2526A
```

### 3. Sincronizar Datos
```bash
python setup.py --reset
```
Descarga todos los datos actualizados de la API externa

## 🔍 Verificación

### Probar Conexión a API Externa
```bash
cd /home/mayra/Proyecto-Calendario/Proyecto/backend
python -c "
from src.integracion_horarios.servicios.periodo_service import PeriodoService
service = PeriodoService()
periodo = service.obtener_periodo_actual()
print('Periodo actual:', periodo)
"
```

### Probar Consulta de Horarios
```bash
python -c "
from src.integracion_horarios.servicios.horario_service import HorarioService
service = HorarioService()
horarios = service.obtener_todos_horarios(periodo='2526A')
print(f'Total horarios: {len(horarios)}')
"
```

## ⚠️ Notas Importantes

1. **API Externa debe estar accesible** - Verifica conectividad a `serv-horarios.unsis.lan`
2. **Reintentos automáticos** - La librería `tenacity` reintenta 3 veces si hay errores de conexión
3. **Timeout de 30 segundos** - Configurable en variables de entorno
4. **Fallback a JSON** - Si falla la API, usa JSON local automáticamente
5. **Logs detallados** - Revisa la salida de `setup.py` para debugging

## 📊 Dependencias del Proyecto

```
consulta_api/  (Ya NO es necesario como servicio separado)
    ├── Lógica copiada a: src/integracion_horarios/
    └── API externa: http://serv-horarios.unsis.lan/api

Proyecto/backend/
    ├── src/integracion_horarios/  ← TODO integrado aquí
    └── Consume directamente API externa
```

## 🎉 Ventajas de la Integración

✅ Un solo proyecto - más fácil de mantener
✅ Sin dependencias entre servicios
✅ Datos siempre actualizados
✅ Mismo código probado de consulta_api
✅ Fallback automático a JSON si API falla
✅ Endpoints expuestos para frontend
✅ Validación de disponibilidad integrada
