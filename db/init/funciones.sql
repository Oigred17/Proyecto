-- Triggers para actualización automática de timestamps
-- Compatible con SQLite

-- Trigger para actualizar updated_at en materias
CREATE TRIGGER trigger_materias_updated_at 
    BEFORE UPDATE ON materias
    FOR EACH ROW
    BEGIN
        UPDATE materias SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;

-- Trigger para actualizar updated_at en examenes
CREATE TRIGGER trigger_examenes_updated_at 
    BEFORE UPDATE ON examenes
    FOR EACH ROW
    BEGIN
        UPDATE examenes SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;