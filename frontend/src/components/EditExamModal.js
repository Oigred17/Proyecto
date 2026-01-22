import React, { useState, useEffect } from 'react';
import './EditExamModal.css';

function EditExamModal({ exam, aulas, profesores, onClose, onSave }) {
    const [form, setForm] = useState({
        fecha: exam.fecha,
        hora_inicio: exam.hora_inicio,
        hora_fin: exam.hora_fin,
        aula_id: exam.aula_id || '',
        aplicador_id: exam.aplicador_id || (exam.materia?.profesor ? exam.materia.profesor.id : ''),
        modalidad: exam.modalidad || 'Escrito',
        tipo: exam.tipo
    });

    const duration = form.tipo?.toLowerCase().includes('ordinario') ? 2 : 1;

    const handleChange = (e) => {
        const { name, value } = e.target;

        if (name === 'hora_inicio') {
            const [h, m] = value.split(':').map(Number);
            if (!isNaN(h)) {
                const newH = (h + duration) % 24;
                const autoHoraFin = `${newH.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:00`;
                setForm(prev => ({ ...prev, [name]: value, hora_fin: autoHoraFin }));
                return;
            }
        }

        setForm(prev => ({ ...prev, [name]: value }));
    };

    return (
        <div className="eem-backdrop" onClick={onClose}>
            <div className="eem-modal" onClick={e => e.stopPropagation()}>
                <div className="eem-header">
                    <div className="eem-title-group">
                        <div className="eem-icon-circle">
                            <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2.5">
                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                            </svg>
                        </div>
                        <div>
                            <h3>Modificar Examen</h3>
                            <p>{exam.materia?.nombre} - Grupo {exam.grupo?.nombre_grupo}</p>
                        </div>
                    </div>
                    <button className="eem-close" onClick={onClose}>
                        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>

                <div className="eem-content">
                    <div className="eem-form-grid">
                        {/* Fecha y Hora */}
                        <div className="eem-section">
                            <h4 className="eem-section-title">Programación</h4>
                            <div className="eem-field">
                                <label>Fecha del Examen</label>
                                <input
                                    type="date"
                                    name="fecha"
                                    value={form.fecha}
                                    onChange={handleChange}
                                    className="eem-input"
                                />
                            </div>
                            <div className="eem-field">
                                <label>Hora de Inicio</label>
                                <div className="eem-time-wrapper">
                                    <input
                                        type="time"
                                        name="hora_inicio"
                                        value={form.hora_inicio ? form.hora_inicio.slice(0, 5) : ''}
                                        onChange={handleChange}
                                        className="eem-input"
                                    />
                                    <div className="eem-duration-tag">
                                        {duration} Horas calculadas ({form.tipo})
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Asignación */}
                        <div className="eem-section">
                            <h4 className="eem-section-title">Logística</h4>
                            <div className="eem-field">
                                <label>Aula Asignada</label>
                                <select name="aula_id" value={form.aula_id} onChange={handleChange} className="eem-select">
                                    <option value="">Sin Aula</option>
                                    {aulas.map(a => (
                                        <option key={a.id} value={a.id}>{a.nombre}</option>
                                    ))}
                                </select>
                            </div>
                            <div className="eem-field">
                                <label>Docente Aplicador</label>
                                <select name="aplicador_id" value={form.aplicador_id} onChange={handleChange} className="eem-select">
                                    <option value="">Seleccionar Aplicador</option>
                                    {profesores.map(p => (
                                        <option key={p.id} value={p.id}>{p.nombre}</option>
                                    ))}
                                </select>
                            </div>
                            <div className="eem-field">
                                <label>Modalidad</label>
                                <div className="eem-radio-group">
                                    <label className={`eem-radio ${form.modalidad === 'Escrito' ? 'active' : ''}`}>
                                        <input type="radio" name="modalidad" value="Escrito" checked={form.modalidad === 'Escrito'} onChange={handleChange} />
                                        <span>Escrito</span>
                                    </label>
                                    <label className={`eem-radio ${form.modalidad === 'Digital' ? 'active' : ''}`}>
                                        <input type="radio" name="modalidad" value="Digital" checked={form.modalidad === 'Digital'} onChange={handleChange} />
                                        <span>Digital</span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="eem-footer">
                    <button className="eem-btn-cancel" onClick={onClose}>Cancelar</button>
                    <button className="eem-btn-save" onClick={() => onSave(exam.id, form)}>
                        Guardar Cambios
                    </button>
                </div>
            </div>
        </div>
    );
}

export default EditExamModal;
