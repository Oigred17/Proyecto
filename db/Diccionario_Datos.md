# Diccionario de Datos - Sistema de Calendarización de Exámenes

## Descripción General
Este diccionario de datos documenta la estructura completa de la base de datos del Sistema de Calendarización de Exámenes, incluyendo todas las tablas, campos, tipos de datos, restricciones y relaciones.

---

## Tablas del Sistema

### 1. CARRERAS
**Descripción:** Almacena información sobre las carreras académicas ofrecidas por la institución.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único de la carrera |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE | Nombre completo de la carrera |
| codigo | VARCHAR(20) | UNIQUE | Código identificador de la carrera |
| descripcion | TEXT | NULL | Descripción detallada de la carrera |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Relaciones:**
- Un padre de: materias, grupos

---

### 2. ROLES
**Descripción:** Define los diferentes roles de usuario en el sistema.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del rol |
| nombre | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del rol (ej: Admin, Profesor, Coordinador) |
| descripcion | TEXT | NULL | Descripción de las funciones del rol |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Relaciones:**
- Un padre de: usuarios

---

### 3. USUARIOS
**Descripción:** Contiene las cuentas de usuario del sistema con sus credenciales.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del usuario |
| nombre_usuario | VARCHAR(50) | NOT NULL, UNIQUE | Nombre de usuario para login |
| password_hash | VARCHAR(255) | NOT NULL | Hash de la contraseña del usuario |
| rol_id | INTEGER | NOT NULL, FK | Referencia al rol del usuario |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Relaciones:**
- Hijo de: roles
- Un padre de: profesores, auditoria

---

### 4. PROFESORES
**Descripción:** Información personal y académica de los profesores.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del profesor |
| nombre | VARCHAR(100) | NOT NULL | Nombre del profesor |
| apellido | VARCHAR(100) | NOT NULL | Apellido del profesor |
| email | VARCHAR(100) | UNIQUE | Correo electrónico del profesor |
| usuario_id | INTEGER | UNIQUE, FK | Referencia opcional a cuenta de usuario |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Relaciones:**
- Hijo de: usuarios
- Un padre de: grupos, examenes, profesor_sinodales, restricciones

---

### 5. PROFESOR_SINODALES
**Descripción:** Relación entre profesores y sus sinodales por materia específica.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único de la relación |
| profesor_id | INTEGER | NOT NULL, FK | Profesor que tiene un sinodal |
| sinodal_id | INTEGER | NOT NULL, FK | Profesor que actúa como sinodal |
| materia_id | INTEGER | NOT NULL, FK | Materia específica para la cual es sinodal |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Restricciones Especiales:**
- UNIQUE KEY: (profesor_id, sinodal_id, materia_id) - Evita duplicados

**Relaciones:**
- Hijo de: profesores, materias

---

### 6. ACADEMIAS
**Descripción:** Organizaciones académicas que agrupan carreras y programas.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único de la academia |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE | Nombre de la academia |
| codigo | VARCHAR(20) | UNIQUE | Código identificador de la academia |
| descripcion | TEXT | NULL | Descripción de la academia |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Relaciones:**
- Un padre de: grupos

---

### 7. AULAS
**Descripción:** Espacios físicos donde se imparten clases y se realizan exámenes.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del aula |
| nombre | VARCHAR(50) | NOT NULL, UNIQUE | Nombre o número del aula |
| capacidad | INTEGER | DEFAULT 0 | Capacidad máxima de estudiantes |
| tipo | VARCHAR(20) | CHECK(tipo IN ('Normal', 'Laboratorio', 'Sala')) | Tipo de aula |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación del registro |

**Valores Permitidos para 'tipo':**
- Normal: Aula estándar
- Laboratorio: Aula con equipamiento especializado
- Sala: Sala de conferencias o auditorio

**Relaciones:**
- Un padre de: grupos, examenes, restricciones, auditoria

---

### 8. MATERIAS
**Descripción:** Asignaturas o materias académicas de las carreras.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único de la materia |
| clave | VARCHAR(20) | UNIQUE, NOT NULL | Clave identificadora de la materia |
| nombre | VARCHAR(150) | NOT NULL | Nombre completo de la materia |
| semestre | INTEGER | NULL | Semestre en que se imparte |
| horas_semanales | INTEGER | DEFAULT 0 | Horas de clase por semana |
| es_ingles | INTEGER | DEFAULT 0 | Indica si la materia es en inglés (0=No, 1=Sí) |
| carrera_id | INTEGER | NOT NULL, FK | Carrera a la que pertenece la materia |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de última actualización |

**Relaciones:**
- Hijo de: carreras
- Un padre de: grupos, examenes, profesor_sinodales

---

### 9. TIPOS_EXAMEN
**Descripción:** Clasificación de los diferentes tipos de exámenes.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del tipo |
| nombre | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del tipo de examen |
| descripcion | TEXT | NULL | Descripción del tipo de examen |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación |

**Valores Típicos para 'nombre':**
- Parcial
- Ordinario
- Extraordinario
- Especial

**Relaciones:**
- Un padre de: examenes, auditoria

---

### 10. GRUPOS
**Descripción:** Grupos de estudiantes para materias específicas.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del grupo |
| nombre | VARCHAR(50) | NOT NULL | Nombre o código del grupo |
| semestre | INTEGER | NOT NULL | Semestre académico |
| carrera_id | INTEGER | NOT NULL, FK | Carrera del grupo |
| profesor_id | INTEGER | NOT NULL, FK | Profesor responsable del grupo |
| materia_id | INTEGER | NOT NULL, FK | Materia que se imparte |
| academia_id | INTEGER | NOT NULL, FK | Academia a la que pertenece |
| aula_id | INTEGER | NULL, FK | Aula asignada al grupo |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación |

**Relaciones:**
- Hijo de: carreras, profesores, materias, academias, aulas
- Un padre de: examenes, restricciones, auditoria

---

### 11. EXAMENES
**Descripción:** Exámenes programados con toda su información logística.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del examen |
| grupo_id | INTEGER | NOT NULL, FK | Grupo que presenta el examen |
| materia_id | INTEGER | NOT NULL, FK | Materia del examen |
| profesor_id | INTEGER | NOT NULL, FK | Profesor responsable |
| tipo_examen_id | INTEGER | NOT NULL, FK | Tipo de examen |
| aula_id | INTEGER | NULL, FK | Aula donde se realiza |
| fecha | DATE | NOT NULL | Fecha del examen |
| hora_inicio | TIME | NOT NULL | Hora de inicio del examen |
| hora_fin | TIME | NOT NULL | Hora de finalización |
| numero_alumnos | INTEGER | DEFAULT 0 | Número de estudiantes inscritos |
| observaciones | TEXT | NULL | Observaciones adicionales |
| estado | VARCHAR(20) | CHECK(estado IN ('Programado', 'Realizado', 'Cancelado')) | Estado actual del examen |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de última actualización |

**Valores Permitidos para 'estado':**
- Programado: Examen agendado
- Realizado: Examen ya realizado
- Cancelado: Examen cancelado

**Relaciones:**
- Hijo de: grupos, materias, profesores, tipos_examen, aulas
- Un padre de: auditoria

---

### 12. RESTRICCIONES
**Descripción:** Restricciones o conflictos que afectan la programación.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único de la restricción |
| profesor_id | INTEGER | NULL, FK | Profesor afectado por la restricción |
| aula_id | INTEGER | NULL, FK | Aula afectada por la restricción |
| grupo_id | INTEGER | NULL, FK | Grupo afectado por la restricción |
| fecha | DATE | NULL | Fecha de la restricción |
| hora_inicio | TIME | NULL | Hora de inicio de la restricción |
| hora_fin | TIME | NULL | Hora de fin de la restricción |
| motivo | TEXT | NULL | Descripción del motivo de la restricción |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de creación |

**Restricciones Especiales:**
- CHECK: Exactamente uno de los campos (profesor_id, aula_id, grupo_id) debe ser NOT NULL
- ON DELETE CASCADE: Si se elimina el profesor/aula/grupo, se elimina la restricción

**Relaciones:**
- Hijo de: profesores, aulas, grupos

---

### 13. AUDITORIA
**Descripción:** Registro de todas las acciones realizadas en el sistema para trazabilidad.

| Campo | Tipo | Restricciones | Descripción |
|-------|------|---------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Identificador único del registro |
| accion | VARCHAR(100) | NOT NULL | Descripción de la acción realizada |
| tabla_afectada | VARCHAR(50) | NULL | Tabla que fue modificada |
| registro_id | INTEGER | NULL | ID del registro específico modificado |
| usuario_id | INTEGER | NULL, FK | Usuario que realizó la acción |
| examen_id | INTEGER | NULL, FK | Examen relacionado con la acción |
| grupo_id | INTEGER | NULL, FK | Grupo relacionado con la acción |
| aula_id | INTEGER | NULL, FK | Aula relacionada con la acción |
| tipo_examen_id | INTEGER | NULL, FK | Tipo de examen relacionado |
| datos_anteriores | TEXT | NULL | Datos anteriores (formato JSON) |
| datos_nuevos | TEXT | NULL | Datos nuevos (formato JSON) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Fecha y hora de la acción |

**Relaciones:**
- Hijo de: usuarios, examenes, grupos, aulas, tipos_examen

---

## Diagrama de Relaciones Principales

```
CARRERAS (1) -----> (N) MATERIAS (1) -----> (N) GRUPOS
    |                    |                      |
    |                    |                      |
    v                    v                      v
ACADEMIAS (1) -----> (N) GRUPOS (1) -----> (N) EXAMENES
    |                      |                      |
    |                      |                      |
    v                      v                      v
AULAS (1) ---------> (N) GRUPOS (1) -----> (N) EXAMENES
    |                      |                      |
    |                      |                      |
    v                      v                      v
PROFESORES (1) -----> (N) GRUPOS (1) -----> (N) EXAMENES
    |                      |                      |
    |                      |                      |
    v                      v                      v
ROLES (1) ---------> (N) USUARIOS (1) -----> (N) PROFESORES
```

---

## Convenciones de Nomenclatura

### Campos de Identificación
- `id`: Clave primaria auto-incremental
- `*_id`: Clave foránea que referencia otra tabla

### Campos de Auditoría
- `created_at`: Timestamp de creación
- `updated_at`: Timestamp de última modificación

### Campos de Estado
- `estado`: Estado actual del registro
- `es_*`: Campos booleanos (0=false, 1=true)

### Restricciones de Integridad
- **NOT NULL**: Campo obligatorio
- **UNIQUE**: Valor único en la tabla
- **CHECK**: Validación de valores específicos
- **FOREIGN KEY**: Relación con otra tabla
- **ON DELETE CASCADE**: Eliminación en cascada

---

## Índices Recomendados

### Índices de Búsqueda Frecuente
- `examenes(fecha, hora_inicio)` - Para consultas por fecha
- `grupos(carrera_id, semestre)` - Para consultas por carrera y semestre
- `profesor_sinodales(profesor_id, materia_id)` - Para consultas de sinodales
- `auditoria(created_at, usuario_id)` - Para auditoría por usuario y fecha

### Índices de Rendimiento
- `examenes(estado)` - Para filtrar por estado
- `materias(carrera_id)` - Para consultas por carrera
- `grupos(profesor_id)` - Para consultas por profesor

---

## Consideraciones de Seguridad

### Datos Sensibles
- `usuarios.password_hash`: Almacenado como hash, nunca texto plano
- `auditoria.datos_anteriores/nuevos`: Almacenados como JSON encriptado

### Permisos Recomendados
- **Lectura**: Todos los usuarios autenticados
- **Escritura**: Solo usuarios con roles administrativos
- **Auditoría**: Solo administradores del sistema

---

*Documento generado automáticamente - Sistema de Calendarización de Exámenes*
