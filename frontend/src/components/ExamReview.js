import React, { useState, useEffect } from 'react';
import './ExamScheduleDisplay.css'; // Reusing styles

const ExamReview = ({ currentUser, API_URL, showToast }) => {
    const [exams, setExams] = useState([]);
    const [selectedCareer, setSelectedCareer] = useState(null);
    const [showRejectModal, setShowRejectModal] = useState(false);
    const [rejectTarget, setRejectTarget] = useState(null); // {type: 'career'|'group', id: number}
    const [rejectReason, setRejectReason] = useState("");
    const [rejectComment, setRejectComment] = useState("");

    const reasons = [
        "Empalme con otra actividad",
        "Aula no disponible",
        "Horario fuera de rango",
        "Fechas no autorizadas",
        "Otro"
    ];

    useEffect(() => {
        fetchExamenesPendientes();
    }, []);

    const fetchExamenesPendientes = async () => {
        try {
            const res = await fetch(`${API_URL}/examenes`);
            const data = await res.json();
            // Filter only pending approval
            const pending = data.filter(e => e.status === 'pendiente_aprobacion');
            setExams(pending);
        } catch (e) {
            console.error(e);
        }
    };

    // Grouping logic
    const examsByCareer = exams.reduce((acc, exam) => {
        const careerName = exam.materia && exam.materia.carrera_nombre ? exam.materia.carrera_nombre : 'Desconocida';
        const careerId = exam.materia ? exam.materia.carrera_id : 0;

        if (!acc[careerName]) {
            acc[careerName] = {
                id: careerId,
                name: careerName,
                exams: []
            };
        }
        acc[careerName].exams.push(exam);
        return acc;
    }, {});

    const careers = Object.values(examsByCareer).sort((a, b) => a.name.localeCompare(b.name));

    const handleAction = async (accion, type, id) => {
        if (accion === 'rechazar' && !showRejectModal) {
            setRejectTarget({ type, id });
            setShowRejectModal(true);
            return;
        }

        const payload = {
            carrera_id: type === 'career' ? id : selectedCareer.id,
            grupo_id: type === 'group' ? id : 0, // 0 means all groups in that career
            accion: accion,
            motivo: rejectReason,
            comentarios: rejectComment
        };

        try {
            const res = await fetch(`${API_URL}/examenes/revision-grupo`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                // Refresh
                await fetchExamenesPendientes();
                setShowRejectModal(false);
                setRejectReason("");
                setRejectComment("");
                if (type === 'career') {
                    setSelectedCareer(null);
                } else {
                    // Update current view exams
                    const updatedExams = exams.filter(e => {
                        if (type === 'group') return e.grupo_id !== id;
                        return true;
                    });
                    // If no more exams for this career, go back
                    const careerStillHasExams = updatedExams.some(e => e.materia.carrera_id === selectedCareer.id);
                    if (!careerStillHasExams) setSelectedCareer(null);
                }
                if (showToast) showToast(`Revisión procesada: ${accion.toUpperCase()}`, 'success');
            } else {
                if (showToast) showToast("Error al procesar la revisión", 'error');
                else alert("Error al procesar la revisión");
            }
        } catch (e) {
            console.error(e);
            if (showToast) showToast("Error de conexión", 'error');
            else alert("Error de conexión");
        }
    };

    if (selectedCareer) {
        const careerExams = exams.filter(e => e.materia.carrera_id === selectedCareer.id);
        const obtenerSemestre = (nombre) => {
            if (!nombre) return 0;
            const match = nombre.match(/^(\d+)/);
            if (match) {
                const numStr = match[1];
                if (numStr.length >= 4) return parseInt(numStr.slice(0, -2)) || 0;
                if (numStr.length === 3) return parseInt(numStr[0]) || 0;
                return parseInt(numStr) || 0;
            }
            return 0;
        };

        const examsPerSemester = careerExams.reduce((acc, exam) => {
            const sem = obtenerSemestre(exam.grupo?.nombre_grupo);
            const semKey = sem === 0 ? 'OTROS' : `${sem}° SEMESTRE`;
            if (!acc[semKey]) acc[semKey] = {};
            const gId = exam.grupo_id;
            const gName = exam.grupo ? exam.grupo.nombre_grupo : 'S/G';
            if (!acc[semKey][gId]) acc[semKey][gId] = { id: gId, name: gName, exams: [] };
            acc[semKey][gId].exams.push(exam);
            return acc;
        }, {});

        const sortedSemesters = Object.keys(examsPerSemester).sort((a, b) => {
            if (a === 'OTROS') return 1;
            if (b === 'OTROS') return -1;
            return parseInt(a) - parseInt(b);
        });

        return (
            <div className="exam-schedule-container">
                <header style={{ display: 'flex', alignItems: 'center', marginBottom: '20px', gap: '20px' }}>
                    <button onClick={() => setSelectedCareer(null)} className="btn-edit" style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                        <svg viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                        Volver
                    </button>
                    <h3 className="table-header-title" style={{ margin: 0, border: 'none', padding: 0 }}>
                        {selectedCareer.name}
                    </h3>
                </header>

                <div style={{ backgroundColor: '#f8fafc', padding: '20px', borderRadius: '12px', marginBottom: '30px', border: '1px solid #e2e8f0' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div>
                            <h4 style={{ margin: 0, color: '#475569' }}>Acciones Generales para la Carrera</h4>
                            <p style={{ margin: '5px 0 0 0', fontSize: '13px', color: '#64748b' }}>Afecta a todos los grupos mostrados abajo</p>
                        </div>
                        <div style={{ display: 'flex', gap: '10px' }}>
                            <button className="btn-save" onClick={() => handleAction('aprobar', 'career', selectedCareer.id)} style={{ padding: '10px 20px', fontSize: '14px', backgroundColor: '#3b82f6', color: 'white' }}>
                                Aprobar Toda la Carrera
                            </button>
                            <button className="btn-cancel" onClick={() => handleAction('rechazar', 'career', selectedCareer.id)} style={{ padding: '10px 20px', fontSize: '14px' }}>
                                Rechazar Toda la Carrera
                            </button>
                        </div>
                    </div>
                </div>

                <div className="groups-review-list">
                    {sortedSemesters.map(semKey => (
                        <div key={semKey} className="semester-group">
                            <div style={{
                                background: '#ffffff',
                                color: '#1e293b',
                                padding: '10px 20px',
                                borderRadius: '10px',
                                fontSize: '12px',
                                fontWeight: '800',
                                letterSpacing: '0.1em',
                                marginBottom: '20px',
                                textTransform: 'uppercase'
                            }}>
                                {semKey}
                            </div>
                            {Object.values(examsPerSemester[semKey]).sort((a, b) => a.name.localeCompare(b.name)).map(group => (
                                <div key={group.id} style={{ backgroundColor: 'white', borderRadius: '12px', border: '1px solid #e2e8f0', marginBottom: '24px', overflow: 'hidden', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}>
                                    <div style={{ backgroundColor: '#f1f5f9', padding: '15px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                        <h4 style={{ margin: 0, color: '#1e293b' }}>Grupo: {group.name}</h4>
                                        <div style={{ display: 'flex', gap: '10px' }}>
                                            <button className="btn-save" onClick={() => handleAction('aprobar', 'group', group.id)} style={{ padding: '6px 15px', fontSize: '13px' }}>
                                                Aprobar
                                            </button>
                                            <button className="btn-cancel" onClick={() => handleAction('rechazar', 'group', group.id)} style={{ padding: '6px 15px', fontSize: '13px' }}>
                                                Rechazar
                                            </button>
                                        </div>
                                    </div>
                                    <div className="table-responsive">
                                        <table className="schedule-table" style={{ margin: 0, boxShadow: 'none' }}>
                                            <thead>
                                                <tr>
                                                    <th>Materia</th>
                                                    <th>Profesor</th>
                                                    <th>Fecha</th>
                                                    <th>Hora</th>
                                                    <th>Aula</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {group.exams.map(ex => (
                                                    <tr key={ex.id}>
                                                        <td className="td-materia">{ex.materia.nombre}</td>
                                                        <td className="td-profesor">{ex.materia.profesor ? ex.materia.profesor.nombre : 'S/A'}</td>
                                                        <td className="td-fecha">{new Date(ex.fecha + 'T00:00:00').toLocaleDateString()}</td>
                                                        <td className="td-hora">{ex.hora_inicio.slice(0, 5)} - {ex.hora_fin.slice(0, 5)}</td>
                                                        <td className="td-aula">
                                                            {ex.aula ? ex.aula.nombre : 'N/A'}
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            ))}
                        </div>
                    ))}
                </div>

                {showRejectModal && (
                    <div className="modal-overlay" style={{
                        position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
                        backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 9999
                    }}>
                        <div className="modal-content" style={{
                            backgroundColor: 'white', padding: '30px', borderRadius: '12px', width: '500px',
                            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)'
                        }}>
                            <h3 style={{ marginTop: 0, color: '#1e293b' }}>Confirmar Rechazo</h3>
                            <p style={{ color: '#64748b', fontSize: '14px' }}>
                                Está por rechazar los exámenes de {rejectTarget.type === 'career' ? 'toda la carrera' : 'este grupo'}.
                            </p>
                            <div style={{ marginBottom: '15px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', color: '#64748b' }}>Motivo principal</label>
                                <select className="edit-select" value={rejectReason} onChange={e => setRejectReason(e.target.value)}>
                                    <option value="">Selecciona...</option>
                                    {reasons.map(r => <option key={r} value={r}>{r}</option>)}
                                </select>
                            </div>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', color: '#64748b' }}>Observaciones</label>
                                <textarea
                                    className="edit-input"
                                    rows="4"
                                    value={rejectComment}
                                    onChange={e => setRejectComment(e.target.value)}
                                    placeholder="Detalles adicionales sobre el rechazo..."
                                />
                            </div>
                            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                                <button className="btn-edit" onClick={() => setShowRejectModal(false)}>Cancelar</button>
                                <button className="btn-cancel" onClick={() => handleAction('rechazar', rejectTarget.type, rejectTarget.id)}>Confirmar y Rechazar</button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        );
    }

    return (
        <div className="exam-schedule-container">
            <h3 className="table-header-title">Revisiones por Carrera</h3>
            {careers.length === 0 ? (
                <div className="exam-schedule-empty">
                    <div className="empty-state-icon" style={{ margin: '0 0 1rem 0', color: '#3b82f6' }}>
                        <svg viewBox="0 0 24 24" width="60" height="60" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                            <polyline points="22 4 12 14.01 9 11.01"></polyline>
                        </svg>
                    </div>
                    <p>No hay carreras con revisiones pendientes.</p>
                </div>
            ) : (
                <div style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(3, 1fr)',
                    gap: '24px',
                    width: '100%'
                }}>
                    {careers.map(career => (
                        <div key={career.id} onClick={() => setSelectedCareer(career)} style={{
                            padding: '24px',
                            backgroundColor: 'white',
                            border: '1px solid #e2e8f0',
                            borderRadius: '20px',
                            cursor: 'pointer',
                            transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                            boxShadow: '0 4px 6px -1px rgba(0,0,0,0.05)',
                            position: 'relative',
                            overflow: 'hidden',
                            display: 'flex',
                            flexDirection: 'column',
                            justifyContent: 'space-between'
                        }}
                            onMouseEnter={(e) => {
                                e.currentTarget.style.transform = 'translateY(-8px)';
                                e.currentTarget.style.boxShadow = '0 25px 30px -5px rgba(0, 0, 0, 0.1)';
                                e.currentTarget.style.borderColor = '#3b82f6';
                            }}
                            onMouseLeave={(e) => {
                                e.currentTarget.style.transform = 'translateY(0)';
                                e.currentTarget.style.boxShadow = '0 4px 6px -1px rgba(0,0,0,0.05)';
                                e.currentTarget.style.borderColor = '#e2e8f0';
                            }}
                        >
                            <div style={{ position: 'absolute', top: 0, right: 0, width: '6px', height: '100%', backgroundColor: '#3b82f6' }}></div>

                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px', alignItems: 'center' }}>
                                <div style={{ backgroundColor: '#eff6ff', color: '#2563eb', padding: '8px 14px', borderRadius: '10px', fontSize: '11px', fontWeight: '800', letterSpacing: '0.05em', textTransform: 'uppercase' }}>
                                    {career.exams.length} Materias
                                </div>
                                <div style={{ color: '#94a3b8' }}>
                                    <svg viewBox="0 0 24 24" width="22" height="22" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                                </div>
                            </div>

                            <h4 style={{ margin: '0 0 16px 0', color: '#1e293b', fontSize: '20px', fontWeight: '800', lineHeight: '1.4' }}>
                                {career.name}
                            </h4>

                            <div style={{ marginTop: 'auto', paddingTop: '20px', borderTop: '1px solid #f1f5f9', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                    <div style={{ display: 'flex' }}>
                                        {[...new Set(career.exams.map(e => e.grupo_id))].slice(0, 3).map((g, i) => (
                                            <div key={g} style={{
                                                width: '28px', height: '28px', borderRadius: '8px', backgroundColor: '#f8fafc',
                                                border: '2px solid white', marginLeft: i === 0 ? 0 : '-10px',
                                                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', fontWeight: '800', color: '#3b82f6',
                                                boxShadow: '0 2px 4px rgba(0,0,0,0.05)'
                                            }}>
                                                {i + 1}
                                            </div>
                                        ))}
                                    </div>
                                    <span style={{ fontSize: '14px', fontWeight: '600', color: '#64748b' }}>
                                        {[...new Set(career.exams.map(e => e.grupo_id))].length} Grupos
                                    </span>
                                </div>
                                <div style={{ color: '#10b981' }}>
                                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5">
                                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

export default ExamReview;
