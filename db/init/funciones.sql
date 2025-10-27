-- Triggers para actualización automática de timestamps
-- Compatible con MySQL, PostgreSQL y SQLite

-- Trigger para actualizar updated_at en materias
CREATE TRIGGER trigger_materias_updated_at 
    BEFORE UPDATE ON materias
    FOR EACH ROW
    SET NEW.updated_at = CURRENT_TIMESTAMP;

-- Trigger para actualizar updated_at en examenes
CREATE TRIGGER trigger_examenes_updated_at 
    BEFORE UPDATE ON examenes
    FOR EACH ROW
    SET NEW.updated_at = CURRENT_TIMESTAMP;