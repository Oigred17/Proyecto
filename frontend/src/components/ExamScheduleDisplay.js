import React, { useState, useEffect } from 'react';
import './ExamScheduleDisplay.css';

const ExamScheduleDisplay = ({ examenes, onRefresh, title, children }) => {
  const [editingId, setEditingId] = useState(null);
  const [editForm, setEditForm] = useState({});
  const [aulas, setAulas] = useState([]);
  const [filterText, setFilterText] = useState('');

  // URL API base
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    fetch(`${API_URL}/aulas`)
      .then(res => res.json())
      .then(data => setAulas(data))
      .catch(err => console.error("Error cargando aulas:", err));
  }, []);

  // Filtrar exámenes antes de agrupar
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
        <div style={{ marginBottom: '20px' }}>
          {children}
        </div>
        <div className="exam-schedule-empty">
          <div className="empty-state-icon">
            <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
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

  // Agrupar exámenes filtrados por Grupo
  const groupedExams = filteredExamenes.reduce((acc, exam) => {
    const grupoName = exam.grupo ? exam.grupo.nombre_grupo : 'Sin Grupo';
    if (!acc[grupoName]) {
      acc[grupoName] = [];
    }
    acc[grupoName].push(exam);
    return acc;
  }, {});

  // Ordenar grupos alfabéticamente
  const sortedGroups = Object.keys(groupedExams).sort();

  // Función para iniciar edición
  const handleEditClick = (exam) => {
    setEditingId(exam.id);
    setEditForm({
      fecha: exam.fecha,
      hora_inicio: exam.hora_inicio,
      hora_fin: exam.hora_fin,
      aula_id: exam.aula_id
    });
  };

  // Cancelar edición
  const handleCancelEdit = () => {
    setEditingId(null);
    setEditForm({});
  };

  // Manejar cambios en inputs
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setEditForm(prev => ({ ...prev, [name]: value }));
  };

  // Guardar cambios
  const handleSave = async (id) => {
    try {
      const response = await fetch(`${API_URL}/examenes/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(editForm)
      });

      if (!response.ok) throw new Error('Error al actualizar');

      setEditingId(null);
      if (onRefresh) onRefresh(); // Recargar datos desde el padre
    } catch (error) {
      alert('Error guardando cambios: ' + error.message);
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
              style={{
                padding: '8px 12px 8px 35px',
                borderRadius: '8px',
                border: '1px solid #e2e8f0',
                fontSize: '14px',
                width: '250px'
              }}
            />
            <svg
              viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="#94a3b8" strokeWidth="2"
              style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)' }}
            >
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
              <th className="th-titular">ACADÉMICO TITULAR</th>
              <th className="th-fecha">FECHA</th>
              <th className="th-hora">HORA</th>
              <th className="th-aula">AULA</th>
              {examenes.some(e => e.comentarios_rechazo) && <th className="th-rechazo">MOTIVO RECHAZO</th>}
              <th className="th-acciones">ACCIONES</th>
            </tr>
          </thead>
          <tbody>
            {sortedGroups.map(groupName => {
              const groupExams = groupedExams[groupName].sort((a, b) =>
                new Date(a.fecha) - new Date(b.fecha)
              );

              return groupExams.map((exam, index) => (
                <tr key={exam.id} className={index % 2 === 0 ? 'row-even' : 'row-odd'}>
                  {/* Celda GRUPO con RowSpan */}
                  {index === 0 && (
                    <td className="td-grupo" rowSpan={groupExams.length}>
                      {groupName}
                    </td>
                  )}

                  {/* Materia y Profesor (Solo lectura) */}
                  <td className="td-materia">{exam.materia.nombre}</td>
                  <td className="td-profesor">
                    {exam.materia.profesor ? exam.materia.profesor.nombre : 'Sin asignar'}
                  </td>

                  {/* Campos Editables */}
                  {editingId === exam.id ? (
                    <>
                      <td className="td-editable">
                        <input
                          type="date"
                          name="fecha"
                          value={editForm.fecha}
                          onChange={handleInputChange}
                          className="edit-input"
                        />
                      </td>
                      <td className="td-editable">
                        <div className="time-edit-container" style={{ display: 'flex', gap: '5px' }}>
                          <input
                            type="time"
                            name="hora_inicio"
                            value={editForm.hora_inicio ? editForm.hora_inicio.slice(0, 5) : ''}
                            onChange={handleInputChange}
                            className="edit-input time-sm"
                            title="Hora Inicio"
                          />
                          <span style={{ alignSelf: 'center' }}>-</span>
                          <input
                            type="time"
                            name="hora_fin"
                            value={editForm.hora_fin ? editForm.hora_fin.slice(0, 5) : ''}
                            onChange={handleInputChange}
                            className="edit-input time-sm"
                            title="Hora Fin"
                          />
                        </div>
                      </td>
                      <td className="td-editable">
                        <select
                          name="aula_id"
                          value={editForm.aula_id}
                          onChange={handleInputChange}
                          className="edit-select"
                        >
                          {aulas.map(a => (
                            <option key={a.id} value={a.id}>{a.nombre}</option>
                          ))}
                        </select>
                      </td>
                      <td className="td-actions">
                        <button className="btn-save" onClick={() => handleSave(exam.id)} title="Guardar">
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                            <polyline points="17 21 17 13 7 13 7 21"></polyline>
                            <polyline points="7 3 7 8 15 8"></polyline>
                          </svg>
                        </button>
                        <button className="btn-cancel" onClick={handleCancelEdit} title="Cancelar">
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                          </svg>
                        </button>
                      </td>
                      {examenes.some(e => e.comentarios_rechazo) && <td className="td-rechazo"></td>}
                    </>
                  ) : (
                    <>
                      <td className="td-fecha">
                        {new Date(exam.fecha + 'T00:00:00').toLocaleDateString('es-ES')}
                      </td>
                      <td className="td-hora">
                        {exam.hora_inicio.slice(0, 5)} - {exam.hora_fin.slice(0, 5)}
                      </td>
                      <td className="td-aula">
                        {exam.aula ? exam.aula.nombre : 'N/A'}
                        {exam.tiene_conflictos && (
                          <div className="conflict-badge" title={exam.detalles_conflicto} style={{
                            display: 'inline-block', marginLeft: '8px', color: '#ef4444', cursor: 'help'
                          }}>
                            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2.5">
                              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                              <line x1="12" y1="9" x2="12" y2="13"></line>
                              <line x1="12" y1="17" x2="12.01" y2="17"></line>
                            </svg>
                          </div>
                        )}
                      </td>
                      {examenes.some(e => e.comentarios_rechazo) && (
                        <td className="td-rechazo" style={{ color: '#e53e3e', fontWeight: '500' }}>
                          {exam.comentarios_rechazo || '-'}
                        </td>
                      )}
                      <td className="td-actions">
                        <button className="btn-edit" onClick={() => handleEditClick(exam)} title="Editar">
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                          </svg>
                        </button>
                      </td>
                    </>
                  )}
                </tr>
              ));
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ExamScheduleDisplay;
