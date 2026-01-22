import React, { useState, useEffect } from 'react';
import './ExamScheduleDisplay.css';
import EditExamModal from './EditExamModal';

const ExamScheduleDisplay = ({ examenes, onRefresh, title, showToast, children }) => {
  const [editingExam, setEditingExam] = useState(null);
  const [aulas, setAulas] = useState([]);
  const [profesores, setProfesores] = useState([]);
  const [filterText, setFilterText] = useState('');

  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    Promise.all([
      fetch(`${API_URL}/aulas`),
      fetch(`${API_URL}/profesores`)
    ])
      .then(([resAulas, resProfs]) => Promise.all([resAulas.json(), resProfs.json()]))
      .then(([dataAulas, dataProfs]) => {
        setAulas(dataAulas);
        setProfesores(dataProfs);
      })
      .catch(err => console.error("Error cargando datos:", err));
  }, []);

  const filteredExamenes = (examenes || []).filter(ex => {
    const search = filterText.toLowerCase();
    const matchesAula = ex.aula?.nombre?.toLowerCase().includes(search);
    const matchesMateria = ex.materia?.nombre?.toLowerCase().includes(search);
    const matchesProfesor = ex.materia?.profesor?.nombre?.toLowerCase().includes(search);
    return matchesAula || matchesMateria || matchesProfesor;
  });

  if (!examenes || examenes.length === 0) {
    return (
      <div className="exam-schedule-container">
        <div style={{ marginBottom: '20px' }}>{children}</div>
        <div className="exam-schedule-empty">
          <div className="empty-state-icon">
            <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
              <line x1="16" y1="2" x2="16" y2="6"></line>
              <line x1="8" y1="2" x2="8" y2="6"></line>
              <line x1="3" y1="10" x2="21" y2="10"></line>
            </svg>
          </div>
          <h3>No hay exámenes programados</h3>
          <p>Selecciona una carrera/grupo o utiliza la opción "Planificar" para generar los exámenes.</p>
        </div>
      </div>
    );
  }

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

  const examsPerSemester = filteredExamenes.reduce((acc, exam) => {
    const sem = obtenerSemestre(exam.grupo?.nombre_grupo);
    const semKey = sem === 0 ? 'OTROS' : `${sem}° SEMESTRE`;
    if (!acc[semKey]) acc[semKey] = {};
    const grupoName = exam.grupo ? exam.grupo.nombre_grupo : 'Sin Grupo';
    if (!acc[semKey][grupoName]) acc[semKey][grupoName] = [];
    acc[semKey][grupoName].push(exam);
    return acc;
  }, {});

  const sortedSemesters = Object.keys(examsPerSemester).sort((a, b) => {
    if (a === 'OTROS') return 1;
    if (b === 'OTROS') return -1;
    return parseInt(a) - parseInt(b);
  });

  const handleEditClick = (exam) => {
    setEditingExam(exam);
  };

  const handleSave = async (id, formData) => {
    try {
      const response = await fetch(`${API_URL}/examenes/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });
      if (!response.ok) throw new Error('Error al actualizar');
      setEditingExam(null);
      if (onRefresh) onRefresh();
      if (showToast) showToast('Examen actualizado con éxito', 'success');
    } catch (error) {
      if (showToast) showToast('Error guardando cambios: ' + error.message, 'error');
    }
  };

  return (
    <div className="exam-schedule-container">
      <div className="header-actions-container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px' }}>
        <div className="table-header-title" style={{ borderBottom: 'none', marginBottom: 0 }}>
          {title || "HORARIOS DE EXÁMENES"}
        </div>
        <div className="filters-container" style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <div className="search-input-wrapper" style={{ position: 'relative' }}>
            <input
              type="text"
              placeholder="Buscar Aula, Materia..."
              value={filterText}
              onChange={e => setFilterText(e.target.value)}
              style={{ padding: '8px 12px 8px 35px', borderRadius: '8px', border: '1px solid #e2e8f0', fontSize: '14px', width: '250px' }}
            />
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#94a3b8" strokeWidth="2" style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)' }}>
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </div>
          {children}
        </div>
      </div>
      <div style={{ height: '2px', background: '#e2e8f0', marginBottom: '20px', borderRadius: '2px' }}></div>

      <div className="table-responsive">
        <table className="schedule-table">
          <thead>
            <tr>
              <th className="th-grupo">GRUPO</th>
              <th className="th-materia">MATERIA</th>
              <th className="th-titular">TITULAR</th>
              <th className="th-aplicador">APLICADOR</th>
              <th className="th-modalidad">MODALIDAD</th>
              <th className="th-fecha">FECHA</th>
              <th className="th-horario">HORARIO</th>
              <th className="th-aula">AULA</th>
              {examenes.some(e => e.comentarios_rechazo) && <th className="th-rechazo">RECHAZO</th>}
              <th className="th-acciones">ACCIONES</th>
            </tr>
          </thead>
          {sortedSemesters.map(semKey => (
            <tbody key={semKey}>
              <tr className="semester-divider-row">
                <td colSpan="11" className="td-semester-header">{semKey}</td>
              </tr>
              {Object.keys(examsPerSemester[semKey]).sort().map((groupName, groupIdx) => {
                const groupExams = examsPerSemester[semKey][groupName].sort((a, b) => new Date(a.fecha) - new Date(b.fecha));
                return (
                  <React.Fragment key={groupName}>
                    {groupIdx > 0 && <tr className="group-spacer"><td colSpan="11"></td></tr>}
                    {groupExams.map((exam, index) => (
                      <tr key={exam.id} className={index % 2 === 0 ? 'row-even' : 'row-odd'}>
                        {index === 0 && (
                          <td className="td-grupo" rowSpan={groupExams.length}>
                            {groupName}
                          </td>
                        )}
                        <td className="td-materia">{exam.materia.nombre}</td>
                        <td className="td-titular">{exam.materia?.profesor?.nombre || 'Sin asignar'}</td>
                        <td className="td-aplicador">
                          <span className="text-secondary">{exam.aplicador?.nombre || exam.materia?.profesor?.nombre || 'Sin asignar'}</span>
                        </td>
                        <td>
                          <span className={`badge-modalidad ${exam.modalidad?.toLowerCase() || 'escrito'}`}>
                            {exam.modalidad || 'Escrito'}
                          </span>
                        </td>
                        <td className="td-fecha">{new Date(exam.fecha + 'T00:00:00').toLocaleDateString('es-ES')}</td>
                        <td className="td-horario">
                          <div className="time-display-premium">
                            {exam.hora_inicio?.slice(0, 5)} - {exam.hora_fin?.slice(0, 5)}
                          </div>
                        </td>
                        <td className="td-aula">
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span className={exam.aula ? 'aula-tag' : 'aula-tag-none'}>{exam.aula?.nombre || 'SIN AULA'}</span>
                            {exam.tiene_conflictos && (
                              <div className="conflict-badge" title={exam.detalles_conflicto} style={{ color: '#ef4444', cursor: 'help' }}>
                                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5">
                                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                                  <line x1="12" y1="9" x2="12" y2="13"></line>
                                  <line x1="12" y1="17" x2="12.01" y2="17"></line>
                                </svg>
                              </div>
                            )}
                          </div>
                        </td>
                        {examenes.some(e => e.comentarios_rechazo) && (
                          <td className="td-rechazo" style={{ color: '#e53e3e', fontWeight: '500' }}>{exam.comentarios_rechazo || '-'}</td>
                        )}
                        <td className="td-acciones">
                          <button className="btn-edit-premium" onClick={() => handleEditClick(exam)} title="Modificar Examen">
                            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2.5">
                              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                            </svg>
                          </button>
                        </td>
                      </tr>
                    ))}
                  </React.Fragment>
                );
              })}
            </tbody>
          ))}
        </table>
      </div>

      {editingExam && (
        <EditExamModal
          exam={editingExam}
          aulas={aulas}
          profesores={profesores}
          onClose={() => setEditingExam(null)}
          onSave={handleSave}
        />
      )}
    </div>
  );
};

export default ExamScheduleDisplay;
