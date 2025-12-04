-- Migración para agregar columna sinodal_id a la tabla examenes
-- Esta migración verifica si la columna existe antes de agregarla

-- Para SQLite
-- Verificar si la columna existe y agregarla si no existe
-- Nota: SQLite no soporta ALTER TABLE ADD COLUMN IF NOT EXISTS directamente
-- Por lo tanto, necesitamos verificar manualmente o usar una migración condicional

-- Para otros sistemas de BD (MySQL, PostgreSQL):
-- ALTER TABLE examenes ADD COLUMN sinodal_id INTEGER NULL;
-- ALTER TABLE examenes ADD CONSTRAINT fk_examen_sinodal FOREIGN KEY (sinodal_id) REFERENCES profesores(id);

-- Para SQLite, ejecutar:
-- ALTER TABLE examenes ADD COLUMN sinodal_id INTEGER;

-- Script para verificar y agregar (ejecutar manualmente si es necesario):
-- PRAGMA table_info(examenes);
-- Si sinodal_id no está en la lista, ejecutar:
-- ALTER TABLE examenes ADD COLUMN sinodal_id INTEGER;

