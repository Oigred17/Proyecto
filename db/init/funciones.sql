CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_materias_updated_at BEFORE UPDATE ON materias
    FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();

CREATE TRIGGER trigger_examenes_updated_at BEFORE UPDATE ON examenes
    FOR EACH ROW EXECUTE FUNCTION actualizar_updated_at();