-- Vistas útiles para consultas frecuentes
DROP VIEW IF EXISTS vista_examenes_completos;
CREATE VIEW vista_examenes_completos AS
SELECT
    e.id,
    e.fecha,
    e.hora_inicio,
    e.hora_fin,
    e.numero_alumnos,
    e.estado,
    e.observaciones,
    te.nombre as tipo_examen,
    a.nombre as nombre_aula
FROM examenes e
JOIN tipos_examen te ON e.tipo_examen_id = te.id
LEFT JOIN aulas a ON e.aula_id = a.id;