import React, { useState, useEffect } from 'react';
import './SinodalesView.css';

function SinodalesView({ currentUser }) {
    const [examenes, setExamenes] = useState([]);
    const [profesores, setProfesores] = useState([]);
    const [loading, setLoading] = useState(true);

    const API_URL = `http://${window.location.hostname}:8000/api`;

    useEffect(() => {
        fetchData();
    }, [currentUser]);

    const fetchData = async () => {
        setLoading(true);
        try {
           
            const examRes = await fetch(`${API_URL}/examenes`);
            const examData = await examRes.json();

            
            const materiasRes = await fetch(`${API_URL}/materias`);
            const materiasData = materiasRes.ok ? await materiasRes.json() : [];

           
            const profRes = await fetch(`${API_URL}/profesores`);
            let profData = [];
            if (profRes.ok) {
                profData = await profRes.json();
            } else {
                console.warn('Could not fetch /api/profesores, trying alternative method');
                
                const uniqueProfesores = {};
                materiasData.forEach(m => {
                    if (m.profesor && m.profesor.id) {
                        if (!uniqueProfesores[m.profesor.id]) {
                            uniqueProfesores[m.profesor.id] = {
                                id: m.profesor.id,
                                nombre: m.profesor.nombre,
                                materias: []
                            };
                        }
                        uniqueProfesores[m.profesor.id].materias.push({
                            id: m.id,
                            carrera_id: m.carrera_id,
                            carrera_nombre: m.carrera_nombre
                        });
                    }
                });
                profData = Object.values(uniqueProfesores);
            }

           
            if (profData.length > 0 && materiasData.length > 0) {
                profData = profData.map(prof => {
                    const profMaterias = materiasData.filter(m => m.profesor && m.profesor.id === prof.id);
                    const carreras = [...new Set(profMaterias.map(m => m.carrera_nombre).filter(Boolean))];
                    return {
                        ...prof,
                        carreras: carreras,
                        materias: profMaterias
                    };
                });
            }

            
            let filteredExams = examData;
            if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                filteredExams = examData.filter(e => e.materia && e.materia.carrera_nombre === currentUser.carrera);
            }
            

            if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                profData = profData.filter(p => {
                    // Solo mostrar profesores que enseñan materias de la carrera del jefe
                    return p.carreras && p.carreras.includes(currentUser.carrera);
                });
            }

            setExamenes(filteredExams);
            setProfesores(profData);
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleAssignSinodal = async (examenId, sinodalId) => {
        try {
            const res = await fetch(`${API_URL}/examenes/${examenId}/sinodal`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sinodal_id: sinodalId || null })
            });

            if (res.ok) {
                const data = await res.json();
                alert('Sinodal asignado correctamente');
                fetchData(); // Refresh
            } else {
                const errorData = await res.json().catch(() => ({ detail: 'Error al asignar sinodal' }));
                alert(errorData.detail || 'Error al asignar sinodal');
            }
        } catch (error) {
            console.error('Error assigning sinodal:', error);
            alert('Error al asignar sinodal: ' + error.message);
        }
    };

    if (loading) return <div className="loading">Cargando...</div>;

    return (
        <div className="sinodales-view">
            <h2>Asignación de Sinodales</h2>
            <div className="table-container">
                <table className="sinodales-table">
                    <thead>
                        <tr>
                            <th>Materia</th>
                            <th>Fecha</th>
                            <th>Profesor Titular</th>
                            <th>Sinodal Asignado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {examenes.map(exam => {
r
                            const titularId = exam.materia?.profesor?.id;
                            const examCarreraNombre = exam.materia?.carrera_nombre;

                            const availableSinodales = profesores.filter(p => {

                                const isTitular = p.id === titularId;
                                if (isTitular) return false;

                                if (examCarreraNombre && p.carreras) {
                                    return p.carreras.includes(examCarreraNombre);
                                }
                                

                                return true;
                            });

                            return (
                                <tr key={exam.id}>
                                    <td>{exam.materia?.nombre}</td>
                                    <td>{exam.fecha} {exam.hora_inicio}</td>
                                    <td>{exam.materia?.profesor?.nombre || 'N/A'}</td>
                                    <td>
                                        <select
                                            value={exam.sinodal_id || ''}
                                            onChange={(e) => handleAssignSinodal(exam.id, e.target.value)}
                                        >
                                            <option value="">Seleccionar Sinodal</option>
                                            {availableSinodales.map(p => (
                                                <option key={p.id} value={p.id}>{p.nombre}</option>
                                            ))}
                                        </select>
                                    </td>
                                    <td>
                                        {exam.sinodal_id ? <span className="status-ok">Asignado</span> : <span className="status-pending">Pendiente</span>}
                                    </td>
                                </tr>
                            );
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

export default SinodalesView;
