import React, { useState, useEffect } from 'react';
import './ExamScheduleDisplay.css';

const ExamReview = ({ currentUser, API_URL, showToast }) => {
    const [exams, setExams] = useState([]);
    const [selectedCareer, setSelectedCareer] = useState(null);
    const [showRejectModal, setShowRejectModal] = useState(false);
    const [rejectTarget, setRejectTarget] = useState(null);
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
            const pending = data.filter(e => e.status === 'pendiente_aprobacion');
            setExams(pending);
        } catch (e) {
            console.error(e);
        }
    };

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
            grupo_id: type === 'group' ? id : 0,
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
                await fetchExamenesPendientes();
                setShowRejectModal(false);
                setRejectReason("");
                setRejectComment("");
                if (type === 'career') {
                    setSelectedCareer(null);
                } else {
                    const updatedExams = exams.filter(e => {
                        if (type === 'group') return e.grupo_id !== id;
                        return true;
                    });
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
                    <button onClick={() => setSelectedCareer(null)} className="btn-edit">
                        <svg viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
                        Volver
                    </button>
                    <h3 className="table-header-title" style={{ margin: 0, border: 'none', padding: 0 }}>
                        {selectedCareer.name}
                    </h3>
                </header>

                <div style={{ backgroundColor: '#f8fafc', padding: '24px', borderRadius: '16px', marginBottom: '32px', border: '1px solid #e2e8f0' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div>
                            <h4 style={{ margin: 0, color: '#0f172a', fontSize: '1.1rem', fontWeight: 700 }}>Acciones Generales para la Carrera</h4>
                            <p style={{ margin: '8px 0 0 0', fontSize: '14px', color: '#64748b' }}>Afecta a todos los grupos mostrados abajo</p>
                        </div>
                        <div style={{ display: 'flex', gap: '12px' }}>
                            <button className="btn-save" onClick={() => handleAction('aprobar', 'career', selectedCareer.id)}>
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                Aprobar Toda la Carrera
                            </button>
                            <button className="btn-cancel" onClick={() => handleAction('rechazar', 'career', selectedCareer.id)}>
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                Rechazar Toda la Carrera
                            </button>
                        </div>
                    </div>
                </div>

                <div className="groups-review-list">
                    {sortedSemesters.map(semKey => (
                        <div key={semKey} className="semester-group">
                            <div style={{
                                background: 'transparent',
                                color: '#334155',
                                padding: '10px 0',
                                fontSize: '13px',
                                fontWeight: '800',
                                letterSpacing: '0.1em',
                                marginBottom: '16px',
                                textTransform: 'uppercase',
                                borderBottom: '2px solid #e2e8f0',
                                display: 'inline-block'
                            }}>
                                {semKey}
                            </div>
                            {Object.values(examsPerSemester[semKey]).sort((a, b) => a.name.localeCompare(b.name)).map(group => (
                                <div key={group.id} style={{ backgroundColor: 'white', borderRadius: '16px', border: '1px solid #e2e8f0', marginBottom: '24px', overflow: 'hidden', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.02)' }}>
                                    <div style={{ backgroundColor: '#fcfcfc', padding: '16px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #f1f5f9' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                            <div style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: '#3b82f6' }}></div>
                                            <h4 style={{ margin: 0, color: '#1e293b', fontSize: '1rem', fontWeight: 700 }}>Grupo: {group.name}</h4>
                                        </div>
                                        <div style={{ display: 'flex', gap: '10px' }}>
                                            <button className="btn-save" onClick={() => handleAction('aprobar', 'group', group.id)} style={{ padding: '8px 16px', fontSize: '0.85rem' }}>
                                                Aprobar
                                            </button>
                                            <button className="btn-cancel" onClick={() => handleAction('rechazar', 'group', group.id)} style={{ padding: '8px 16px', fontSize: '0.85rem' }}>
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
                                                {group.exams.map((ex, idx) => (
                                                    <tr key={ex.id} className={idx % 2 === 0 ? 'row-even' : 'row-odd'}>
                                                        <td className="td-materia">{ex.materia.nombre}</td>
                                                        <td className="td-profesor" style={{ color: '#475569' }}>{ex.materia.profesor ? ex.materia.profesor.nombre : 'S/A'}</td>
                                                        <td className="td-fecha" style={{ fontWeight: 500 }}>{new Date(ex.fecha + 'T00:00:00').toLocaleDateString()}</td>
                                                        <td className="td-hora">
                                                            <span className="time-display-premium">
                                                                {ex.hora_inicio.slice(0, 5)} - {ex.hora_fin.slice(0, 5)}
                                                            </span>
                                                        </td>
                                                        <td className="td-aula">
                                                            {ex.aula ? (
                                                                <span className="aula-tag">{ex.aula.nombre}</span>
                                                            ) : (
                                                                <span className="aula-tag-none">N/A</span>
                                                            )}
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
                    <div className="modal-overlay">
                        <div className="modal-content" style={{ width: '500px', backgroundColor: 'white', padding: '32px', borderRadius: '24px' }}>
                            <h3 style={{ marginTop: 0, color: '#1e293b', fontSize: '1.25rem', fontWeight: 800, marginBottom: '8px' }}>Confirmar Rechazo</h3>
                            <p style={{ color: '#64748b', fontSize: '0.95rem', marginBottom: '24px', lineHeight: 1.5 }}>
                                Está por rechazar los exámenes de <strong style={{ color: '#0f172a' }}>{rejectTarget.type === 'career' ? 'toda la carrera' : 'este grupo'}</strong>. Esta acción notificará a los coordinadores.
                            </p>
                            <div style={{ marginBottom: '20px' }}>
                                <label style={{ display: 'block', marginBottom: '8px', fontSize: '0.85rem', fontWeight: 600, color: '#475569', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Motivo principal</label>
                                <select className="edit-select" value={rejectReason} onChange={e => setRejectReason(e.target.value)}>
                                    <option value="">Selecciona una opción...</option>
                                    {reasons.map(r => <option key={r} value={r}>{r}</option>)}
                                </select>
                            </div>
                            <div style={{ marginBottom: '32px' }}>
                                <label style={{ display: 'block', marginBottom: '8px', fontSize: '0.85rem', fontWeight: 600, color: '#475569', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Observaciones adicionales</label>
                                <textarea
                                    className="edit-input"
                                    rows="4"
                                    value={rejectComment}
                                    onChange={e => setRejectComment(e.target.value)}
                                    placeholder="Escriba aquí los detalles o correcciones necesarias..."
                                    style={{ resize: 'none' }}
                                />
                            </div>
                            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                                <button className="btn-edit" onClick={() => setShowRejectModal(false)}>Cancelar</button>
                                <button className="btn-save" style={{ backgroundColor: '#ef4444', boxShadow: '0 4px 6px -1px rgba(239, 68, 68, 0.3)' }} onClick={() => handleAction('rechazar', rejectTarget.type, rejectTarget.id)}>
                                    Confirmar Rechazo
                                </button>
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
                    gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
                    gap: '24px',
                    width: '100%'
                }}>
                    {careers.map(career => (
                        <div key={career.id} onClick={() => setSelectedCareer(career)} style={{
                            padding: '24px',
                            backgroundColor: 'white',
                            border: '1px solid #e2e8f0',
                            borderRadius: '24px',
                            cursor: 'pointer',
                            transition: 'all 0.3s ease',
                            boxShadow: '0 4px 6px -1px rgba(0,0,0,0.02)',
                            position: 'relative',
                            overflow: 'hidden',
                            display: 'flex',
                            flexDirection: 'column',
                            justifyContent: 'space-between',
                            height: '100%'
                        }}
                            onMouseEnter={(e) => {
                                e.currentTarget.style.transform = 'translateY(-4px)';
                                e.currentTarget.style.boxShadow = '0 20px 25px -5px rgba(0, 0, 0, 0.08)';
                                e.currentTarget.style.borderColor = '#3b82f6';
                            }}
                            onMouseLeave={(e) => {
                                e.currentTarget.style.transform = 'translateY(0)';
                                e.currentTarget.style.boxShadow = '0 4px 6px -1px rgba(0,0,0,0.02)';
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

                            <h4 style={{ margin: '0 0 16px 0', color: '#1e293b', fontSize: '1.25rem', fontWeight: '800', lineHeight: '1.4' }}>
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
