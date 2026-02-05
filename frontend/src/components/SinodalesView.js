import React, { useState, useEffect } from 'react';
import './SinodalesView.css';

function SinodalesView({ currentUser, showToast }) {
    const [materias, setMaterias] = useState([]);
    const [profesores, setProfesores] = useState([]);
    const [loading, setLoading] = useState(true);
    const [lastAssignedId, setLastAssignedId] = useState(null);

    const API_URL = `http://${window.location.hostname}:9000/api`;

    useEffect(() => {
        fetchData();
    }, [currentUser]);

    const fetchData = async (silent = false) => {
        if (!silent) setLoading(true);
        try {
            // Cargar materias filtradas por carrera si es jefe
            const queryParam = (currentUser && currentUser.role === 'jefe_carrera')
                ? `?carrera_codigo=${currentUser.carrera}`
                : '';

            const materiasRes = await fetch(`${API_URL}/materias${queryParam}`);
            const materiasData = materiasRes.ok ? await materiasRes.json() : [];

            const profRes = await fetch(`${API_URL}/profesores`);
            let profData = profRes.ok ? await profRes.json() : [];

            setMaterias(materiasData);
            setProfesores(profData);
        } catch (error) {
            console.error('Error fetching data:', error);
            showToast('Error al cargar datos', 'error');
        } finally {
            if (!silent) setLoading(false);
        }
    };

    const handleAssignSinodal = async (materiaId, sinodalId) => {
        try {
            const res = await fetch(`${API_URL}/materias/${materiaId}/sinodal?sinodal_id=${sinodalId || ''}`, {
                method: 'PUT'
            });

            if (res.ok) {
                showToast('Sinodal asignado a la materia correctamente', 'success');
                if (sinodalId) {
                    setLastAssignedId(materiaId);
                    // Limpiar el highlight después de la animación
                    setTimeout(() => setLastAssignedId(null), 3000);
                }
                fetchData(true); // Refrescar silenciosamente
            } else {
                const errorData = await res.json().catch(() => ({ detail: 'Error al asignar sinodal' }));
                showToast(errorData.detail || 'Error al asignar sinodal', 'error');
            }
        } catch (error) {
            console.error('Error assigning sinodal:', error);
            showToast('Error de conexión', 'error');
        }
    };

    if (loading) return <div className="loading">Cargando catálogo de materias...</div>;

    return (
        <div className="sinodales-view">
            <div className="view-header">
                <div>
                    <h2>Asignación de Sinodales</h2>
                    <p className="subtitle">Configuración preventiva (antes de generar exámenes)</p>
                </div>
            </div>

            <div className="table-container">
                <table className="sinodales-table">
                    <thead>
                        <tr>
                            <th>Materia</th>
                            <th>Carrera</th>
                            <th>Semestre</th>
                            <th>Profesor Titular</th>
                            <th>Sinodal Asignado</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        {materias.length === 0 ? (
                            <tr><td colSpan="6" className="empty-message">No se encontraron materias.</td></tr>
                        ) : (
                            materias.map(materia => {
                                const titularId = materia.profesor_id || (materia.profesor ? materia.profesor.id : null);
                                // Filtrar profesores para que no se elija al mismo titular
                                const availableSinodales = profesores.filter(p => p.id !== titularId);

                                return (
                                    <tr
                                        key={materia.id}
                                        className={lastAssignedId === materia.id ? 'row-just-assigned' : ''}
                                    >
                                        <td><strong>{materia.nombre}</strong></td>
                                        <td><span className="carrera-badge">{(materia.carrera_nombre || 'N/A').replace(/\s+\d{4}$/, '').trim()}</span></td>
                                        <td style={{ textAlign: 'center' }}>{materia.semestre || '-'}</td>
                                        <td>{materia.profesor?.nombre || 'SIN TITULAR'}</td>
                                        <td>
                                            <select
                                                className="sinodal-select"
                                                value={materia.sinodal_id || ''}
                                                onChange={(e) => handleAssignSinodal(materia.id, e.target.value)}
                                            >
                                                <option value="">Seleccionar Sinodal...</option>
                                                {availableSinodales.map(p => (
                                                    <option key={p.id} value={p.id}>{p.nombre}</option>
                                                ))}
                                            </select>
                                        </td>
                                        <td>
                                            {materia.sinodal_id ?
                                                <span className="status-ok">Listo</span> :
                                                <span className="status-pending">Pendiente</span>
                                            }
                                        </td>
                                    </tr>
                                );
                            })
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

export default SinodalesView;
