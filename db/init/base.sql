-- Sistema de Calendarización de Exámenes
-- Base de datos para gestión de horarios, carreras, grupos, profesores y exámenes

-- Tabla de Carreras
CREATE TABLE carreras (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(20) UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Roles de Usuario
CREATE TABLE roles (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Usuarios
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- Tabla de Profesores
CREATE TABLE profesores (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    usuario_id INTEGER UNIQUE, -- Un profesor puede tener una cuenta de usuario (opcional y único)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de relación Profesor-Sinodal por Materia
CREATE TABLE profesor_sinodales (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    profesor_id INTEGER NOT NULL, -- El profesor que tiene un sinodal
    sinodal_id INTEGER NOT NULL, -- El profesor que es el sinodal
    materia_id INTEGER NOT NULL, -- La materia específica para la cual es sinodal
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (sinodal_id) REFERENCES profesores(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    UNIQUE KEY unique_profesor_sinodal_materia (profesor_id, sinodal_id, materia_id)
);

-- Tabla de Academias
CREATE TABLE academias (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(20) UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Aulas
CREATE TABLE aulas (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    capacidad INTEGER DEFAULT 0,
    tipo VARCHAR(20) CHECK(tipo IN ('Normal', 'Laboratorio', 'Sala')) DEFAULT 'Normal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Materias
CREATE TABLE materias (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    clave VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    semestre INTEGER,
    horas_semanales INTEGER DEFAULT 0,
    es_ingles INTEGER DEFAULT 0, -- 0=false, 1=true
    carrera_id INTEGER NOT NULL, -- Una materia debe pertenecer a una carrera
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carrera_id) REFERENCES carreras(id)
);

-- Tabla de Tipos de Examen
CREATE TABLE tipos_examen (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE, -- "Parcial", "Ordinario", "Extraordinario", "Especial"
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Grupos
CREATE TABLE grupos (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    semestre INTEGER NOT NULL,
    carrera_id INTEGER NOT NULL,
    profesor_id INTEGER NOT NULL,
    materia_id INTEGER NOT NULL,
    academia_id INTEGER NOT NULL,
    aula_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carrera_id) REFERENCES carreras(id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    FOREIGN KEY (academia_id) REFERENCES academias(id),
    FOREIGN KEY (aula_id) REFERENCES aulas(id)
);

-- Tabla de Exámenes Programados
CREATE TABLE examenes (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    grupo_id INTEGER NOT NULL,
    materia_id INTEGER NOT NULL,
    profesor_id INTEGER NOT NULL,
    tipo_examen_id INTEGER NOT NULL,
    aula_id INTEGER, -- Dónde se realiza el examen
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    numero_alumnos INTEGER DEFAULT 0,
    observaciones TEXT,
    estado VARCHAR(20) CHECK(estado IN ('Programado', 'Realizado', 'Cancelado')) DEFAULT 'Programado',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (grupo_id) REFERENCES grupos(id),
    FOREIGN KEY (materia_id) REFERENCES materias(id),
    FOREIGN KEY (profesor_id) REFERENCES profesores(id),
    FOREIGN KEY (tipo_examen_id) REFERENCES tipos_examen(id),
    FOREIGN KEY (aula_id) REFERENCES aulas(id)
);

-- Tabla de Conflictos/Restricciones
CREATE TABLE restricciones (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    profesor_id INTEGER,
    aula_id INTEGER,
    grupo_id INTEGER,
    fecha DATE,
    hora_inicio TIME,
    hora_fin TIME,
    motivo TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
    FOREIGN KEY (aula_id) REFERENCES aulas(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE,
    CHECK (
        (CASE WHEN profesor_id IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN aula_id IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN grupo_id IS NOT NULL THEN 1 ELSE 0 END) = 1
    )
);

-- Tabla de Logs/Auditoría
CREATE TABLE auditoria (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(50),
    registro_id INTEGER,
    usuario_id INTEGER,
    examen_id INTEGER,
    grupo_id INTEGER,
    aula_id INTEGER,
    tipo_examen_id INTEGER,
    datos_anteriores TEXT, -- Storing JSON as TEXT
    datos_nuevos TEXT, -- Storing JSON as TEXT
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (examen_id) REFERENCES examenes(id),
    FOREIGN KEY (grupo_id) REFERENCES grupos(id),
    FOREIGN KEY (aula_id) REFERENCES aulas(id),
    FOREIGN KEY (tipo_examen_id) REFERENCES tipos_examen(id)
);
