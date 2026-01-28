import React, { useState, useEffect } from 'react';
import html2pdf from 'html2pdf.js';
import './ExamFiles.css';

function ExamFiles({ currentUser, API_URL, showToast }) {
    const [carreras, setCarreras] = useState([]);
    const [examenes, setExamenes] = useState([]);
    const [selectedCarreraId, setSelectedCarreraId] = useState('');
    const [loading, setLoading] = useState(false);
    const [periodo, setPeriodo] = useState('2025-2');
    const [tipoExamen, setTipoExamen] = useState('TERCERA EVALUACIÓN PARCIAL');

    useEffect(() => {
        fetchData();
    }, [currentUser]);

    const fetchData = async () => {
        setLoading(true);
        try {
            // Usar endpoint filtrado según rol
            let carrerasUrl = `${API_URL}/carreras-filtradas?rol=${currentUser.role}`;
            if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                carrerasUrl += `&clave_carrera=${currentUser.carrera}`;
            }
            
            const cRes = await fetch(carrerasUrl);
            const cData = await cRes.json();

            // Para jefe_carrera, NO auto-seleccionar para permitir elegir entre planes
            setCarreras(cData);

            const eRes = await fetch(`${API_URL}/examenes`);
            const eData = await eRes.json();
            setExamenes(eData);
        } catch (e) {
            console.error("Error fetching data:", e);
        }
        setLoading(false);
    };

    const handleDownloadPDF = () => {
        const element = document.getElementById('report');
        const selectedCarreraObj = carreras.find(c => c.id === parseInt(selectedCarreraId));
        const carreraNombre = selectedCarreraObj ? selectedCarreraObj.nombre.replace(/\s+/g, '_') : 'Carrera';

        // Pattern: exámenes_L[Licenciatura]_Periodo[Periodo]-[Parcial]
        // Clean tipoExamen for filename (get the last word or something short)
        const partialName = tipoExamen.split(' ').pop() || 'Examen';
        const fileName = `exámenes_L_${carreraNombre}_Periodo_${periodo}_-${partialName}.pdf`;

        const opt = {
            margin: [10, 10, 10, 10], // top, left, bottom, right in mm
            filename: fileName,
            image: { type: 'jpeg', quality: 0.98 },
            html2canvas: {
                scale: 2,
                useCORS: true,
                letterRendering: true
            },
            jsPDF: { unit: 'mm', format: 'letter', orientation: 'portrait' }
        };

        html2pdf().set(opt).from(element).save();
        if (showToast) showToast('Archivo PDF generado y descargado', 'success');
    };

    const filteredExamenes = examenes.filter(e => {
        if (!selectedCarreraId) return false;
        // Solo mostrar exámenes aprobados en el reporte oficial? 
        // O todos los borradores? El usuario pidió "imprimir los examenes".
        // Usualmente el calendario oficial es el aprobado.
        return (e.materia && e.materia.carrera_id === parseInt(selectedCarreraId)) && e.status === 'aprobado';
    });

    // Group by Grupo
    const groupedExamenes = filteredExamenes.reduce((acc, curr) => {
        const grupoName = curr.grupo?.nombre_grupo || 'Sin Grupo';
        if (!acc[grupoName]) acc[grupoName] = [];
        acc[grupoName].push(curr);
        return acc;
    }, {});

    const selectedCarreraObj = carreras.find(c => c.id === parseInt(selectedCarreraId));

    if (loading) return <div className="no-exams">Cargando archivos...</div>;

    return (
        <div className="exam-files">
            <div className="files-controls">
                <select
                    value={selectedCarreraId}
                    onChange={(e) => setSelectedCarreraId(e.target.value)}
                    className="career-select"
                >
                    <option value="">Seleccione Carrera</option>
                    {carreras.map(c => (
                        <option key={c.id} value={c.id}>{c.nombre}</option>
                    ))}
                </select>

                <div className="report-settings" style={{ display: 'flex', gap: '10px' }}>
                    <input
                        type="text"
                        className="career-select"
                        value={periodo}
                        onChange={e => setPeriodo(e.target.value)}
                        placeholder="Periodo (ej. 2025-2)"
                        title="Periodo"
                    />
                    <select
                        className="career-select"
                        value={tipoExamen}
                        onChange={e => setTipoExamen(e.target.value)}
                    >
                        <option value="PRIMERA EVALUACIÓN PARCIAL">Primera Evaluación Parcial</option>
                        <option value="SEGUNDA EVALUACIÓN PARCIAL">Segunda Evaluación Parcial</option>
                        <option value="TERCERA EVALUACIÓN PARCIAL">Tercera Evaluación Parcial</option>
                        <option value="EVALUACIÓN ORDINARIA">Evaluación Ordinaria</option>
                        <option value="EXAMEN EXTRAORDINARIO 1">Examen Extraordinario 1</option>
                        <option value="EXAMEN EXTRAORDINARIO 2">Examen Extraordinario 2</option>
                    </select>
                </div>

                {selectedCarreraId && filteredExamenes.length > 0 && (
                    <button className="print-button" onClick={handleDownloadPDF} style={{ backgroundColor: '#2563eb' }}>
                        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                            <polyline points="7 10 12 15 17 10" />
                            <line x1="12" y1="15" x2="12" y2="3" />
                        </svg>
                        Guardar PDF
                    </button>
                )}
            </div>

            {selectedCarreraId && filteredExamenes.length === 0 && (
                <div className="no-exams">
                    No hay exámenes aprobados para imprimir en esta carrera.
                </div>
            )}

            {/* Vista previa en pantalla (opcional) o solo printable */}
            <div className="printable-report" id="report">
                <div className="report-header">
                    {/* Logo base64 o URL */}
                    <img src="/logounsis.png" alt="UNSIS" onError={(e) => e.target.style.display = 'none'} />
                    <h1>UNIVERSIDAD DE LA SIERRA SUR</h1>
                    <h2>CALENDARIO DE {tipoExamen}</h2>
                    <h3>PERIODO: {periodo}</h3>
                    <h3>{selectedCarreraObj?.nombre.toUpperCase()}</h3>
                </div>

                {Object.keys(groupedExamenes).sort().map(grupoName => (
                    <div key={grupoName} className="report-group-section">
                        <table className="report-table">
                            <thead>
                                <tr>
                                    <th style={{ width: '10%' }}>GRUPO</th>
                                    <th style={{ width: '25%' }}>MATERIA</th>
                                    <th style={{ width: '15%' }}>ACADÉMICO TITULAR</th>
                                    <th style={{ width: '15%' }}>SINODAL</th>
                                    <th style={{ width: '12%' }}>FECHA</th>
                                    <th style={{ width: '13%' }}>HORA</th>
                                    <th style={{ width: '10%' }}>AULA</th>
                                </tr>
                            </thead>
                            <tbody>
                                {groupedExamenes[grupoName].sort((a, b) => a.fecha.localeCompare(b.fecha)).map((ex, idx) => (
                                    <tr key={ex.id}>
                                        {idx === 0 && (
                                            <td rowSpan={groupedExamenes[grupoName].length} className="group-cell">
                                                {grupoName}
                                            </td>
                                        )}
                                        <td>{ex.materia.nombre}</td>
                                        <td>{ex.materia.profesor?.nombre || '---'}</td>
                                        <td>{ex.sinodal?.nombre || '---'}</td>
                                        <td style={{ textAlign: 'center' }}>{ex.fecha.split('-').reverse().join('/')}</td>
                                        <td style={{ textAlign: 'center' }}>{ex.hora_inicio.slice(0, 5)} - {ex.hora_fin.slice(0, 5)}</td>
                                        <td style={{ textAlign: 'center' }}>{ex.aula?.nombre || 'Sala'}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                ))}
            </div>

            {/* Mensaje visual para el usuario */}
            {!selectedCarreraId && (
                <div className="no-exams">Selecciona una carrera para visualizar los archivos disponibles.</div>
            )}
            {selectedCarreraId && filteredExamenes.length > 0 && (
                <div className="welcome-card" style={{ marginTop: '20px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
                        <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#2563eb" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                            <polyline points="14 2 14 8 20 8"></polyline>
                            <line x1="16" y1="13" x2="8" y2="13"></line>
                            <line x1="16" y1="17" x2="8" y2="17"></line>
                            <polyline points="10 9 9 9 8 9"></polyline>
                        </svg>
                        <h3 style={{ margin: 0 }}>Vista Previa del Documento Oficial</h3>
                    </div>
                    <p>Se han encontrado {filteredExamenes.length} exámenes aprobados para {selectedCarreraObj?.nombre}.</p>
                    <p style={{ fontSize: '0.9em', color: '#666' }}>El diseño de abajo es exactamente lo que se guardará en el PDF.</p>
                </div>
            )}
        </div>
    );
}

export default ExamFiles;
