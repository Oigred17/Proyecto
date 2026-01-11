import React, { useState, useEffect } from 'react';
import Header from './layout/Header';
import Sidebar from './layout/Sidebar';
import ExamReview from './ExamReview';
import ExamScheduleDisplay from './ExamScheduleDisplay';
import UserManagement from './UserManagement';
import SinodalesView from './SinodalesView';
import GenerateExamsModal from './GenerateExamsModal';
import './Dashboard.css';

// Helper function to get day of the week from YYYY-MM-DD string
const getDayOfWeek = (dateString) => {
  const date = new Date(dateString + 'T00:00:00'); // Adding T00:00:00 to avoid timezone issues
  const days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
  return days[date.getDay()];
};

function Dashboard({ currentUser, onLogout }) {
  const [carreras, setCarreras] = useState([]);
  const [horarios, setHorarios] = useState([]);
  const [examenes, setExamenes] = useState([]);
  const [selectedCarreraName, setSelectedCarreraName] = useState('');
  const [selectedCarreraId, setSelectedCarreraId] = useState(null);
  const [selectedGrupoName, setSelectedGrupoName] = useState('');
  const [selectedGrupoId, setSelectedGrupoId] = useState(null);
  const [activeView, setActiveView] = useState('Inicio'); // New state for sidebar view
  const [selectedGrupoIdForExamenes, setSelectedGrupoIdForExamenes] = useState(null);
  const [showNotification, setShowNotification] = useState(false); // State for notification visibility
  const [notificationMessage, setNotificationMessage] = useState(''); // State for notification message
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [showGenerateModal, setShowGenerateModal] = useState(false); // State for generate exams modal
  const [notifications, setNotifications] = useState([]);

  const toggleSidebar = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  // Construir la URL base dinámicamente usando el hostname actual
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchNotifs, 30000); // Poll notifications every 30s
    return () => clearInterval(interval);
  }, [currentUser]);

  const fetchData = () => {
    // Fetch initial data
    console.log('Fetching carreras...');
    fetch(`${API_URL}/carreras`)
      .then(response => response.json())
      .then(data => {
        if (!Array.isArray(data)) {
          console.error("Carreras fetch did not return an array:", data);
          return;
        }
        let filteredCarreras = data;
        if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
          filteredCarreras = data.filter(c => c.nombre === currentUser.carrera);
          if (filteredCarreras.length > 0) {
            const carrera = filteredCarreras[0];
            setSelectedCarreraName(carrera.nombre);
            setSelectedCarreraId(carrera.id);
          }
        }
        setCarreras(filteredCarreras);

        // Safety check for mapping
        const allHorarios = filteredCarreras.flatMap(carrera => {
          if (!carrera || !carrera.grupos || !Array.isArray(carrera.grupos)) return [];
          return carrera.grupos.flatMap(grupo => {
            if (!grupo || !grupo.horarios || !Array.isArray(grupo.horarios)) return [];
            return grupo.horarios.map(horario => ({
              ...horario,
              carrera_name: carrera.nombre,
              carrera_id: carrera.id,
              grupo_name: grupo.nombre_grupo,
              grupo_id: grupo.id,
            }));
          });
        });
        setHorarios(allHorarios);
      })
      .catch(error => console.error('Error fetching carreras:', error));

    fetchExamenes();
    fetchNotifs();
  };

  const fetchNotifs = () => {
    if (!currentUser) return;
    // Assuming backend has GET /api/notificaciones/?rol=...
    const rol = currentUser.role;
    let url = `${API_URL}/notificaciones/?rol=${rol}`;
    if (currentUser.carrera) {
      url += `&carrera=${encodeURIComponent(currentUser.carrera)}`;
    }
    fetch(url)
      .then(r => {
        if (r.ok) return r.json();
        return [];
      })
      .then(data => setNotifications(data))
      .catch(e => console.error(e));
  };

  const handleMarkAsRead = (id) => {
    fetch(`${API_URL}/notificaciones/${id}/leer`, { method: 'PUT' })
      .then(r => {
        if (r.ok) {
          setNotifications(prev => prev.filter(n => n.id !== id));
        }
      })
      .catch(e => console.error(e));
  };


  const fetchExamenes = () => {
    console.log('Fetching examenes...');
    fetch(`${API_URL}/examenes`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Examenes fetched:', data);
        let filteredData = data;
        if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
          filteredData = data.filter(e => e.materia && e.materia.carrera_nombre === currentUser.carrera);
        }
        setExamenes(filteredData);
      })
      .catch(error => console.error('Error fetching examenes:', error));
  };

  const handleGenerateExams = () => {
    // ... same as before
    let carreraIdToUse = selectedCarreraId;
    if (!carreraIdToUse && currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      const carrera = carreras.find(c => c.nombre === currentUser.carrera);
      carreraIdToUse = carrera?.id;
    }
    if (!carreraIdToUse) {
      alert('Por favor selecciona una carrera');
      return;
    }
    if (!selectedCarreraId && carreraIdToUse) {
      const carrera = carreras.find(c => c.id === carreraIdToUse);
      if (carrera) {
        setSelectedCarreraId(carreraIdToUse);
        setSelectedCarreraName(carrera.nombre);
      }
    }
    setShowGenerateModal(true);
  };

  const handleGenerateFromModal = async (selectionData) => {
    try {
      let carreraIdToUse = selectedCarreraId;
      if (!carreraIdToUse && currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
        const carrera = carreras.find(c => c.nombre === currentUser.carrera);
        carreraIdToUse = carrera?.id;
      }

      const response = await fetch(`${API_URL}/generar-examenes?carrera_id=${carreraIdToUse}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(selectionData)
      });

      if (!response.ok) throw new Error('Error al generar exámenes');

      fetchExamenes();
      setShowGenerateModal(false);
      setActiveView('Horarios');
      setNotificationMessage('¡Exámenes generados exitosamente!');
      setShowNotification(true);
      setTimeout(() => setShowNotification(false), 3000);
    } catch (error) {
      alert(`Error al generar exámenes: ${error.message}`);
    }
  };

  const handleEnviarRevision = async () => {
    if (!selectedCarreraId) {
      alert("Selecciona una carrera."); return;
    }
    // If no group selected, we assume ALL groups (backend handles this with 0 or None)
    const grupoIdToSend = selectedGrupoIdForExamenes || 0;

    // Confirmación al usuario
    if (grupoIdToSend === 0) {
      if (!window.confirm("¿Estás seguro de enviar a revisión los exámenes de TODOS los grupos pendientes de esta carrera?")) {
        return;
      }
    }

    try {
      const res = await fetch(`${API_URL}/examenes/enviar-revision?carrera_id=${selectedCarreraId}&grupo_id=${grupoIdToSend}`, {
        method: 'POST'
      });
      const data = await res.json();
      if (res.ok) {
        setNotificationMessage(data.message);
        setShowNotification(true);
        fetchExamenes(); // Update status
        setTimeout(() => setShowNotification(false), 3000);
      } else {
        alert(data.message);
      }
    } catch (e) {
      alert("Error de conexión");
    }
  };

  const handleRevisionAction = async (accion) => {
    if (!selectedCarreraId) {
      alert("Selecciona una carrera."); return;
    }

    // Si no hay grupo seleccionado, asumimos General (0)
    const grupoIdToSend = selectedGrupoIdForExamenes || 0;

    let motivo = "";
    let comentarios = "";

    if (accion === 'rechazar') {
      motivo = prompt("Motivo del rechazo (ej. Empalme, Aula no disponible):");
      if (motivo === null) return; // Cancelled
      comentarios = prompt("Observaciones adicionales (opcional):");
    }

    // Confirmación extra si es masivo
    if (grupoIdToSend === 0) {
      const actionName = accion === 'aprobar' ? "APROBAR" : "RECHAZAR";
      if (!window.confirm(`¿Estás seguro de ${actionName} los exámenes de TODOS los grupos pendientes de esta carrera?`)) {
        return;
      }
    }

    const payload = {
      carrera_id: selectedCarreraId,
      grupo_id: grupoIdToSend,
      accion: accion,
      motivo: motivo,
      comentarios: comentarios
    };

    try {
      const res = await fetch(`${API_URL}/examenes/revision-grupo`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (res.ok) {
        setNotificationMessage(accion === 'aprobar' ? "✅ Grupo Aprobado" : "❌ Grupo Rechazado");
        setShowNotification(true);
        fetchExamenes();
        setTimeout(() => setShowNotification(false), 3000);
      } else {
        alert(data.message || "Error al procesar revisión");
      }
    } catch (e) {
      console.error(e);
      alert("Error de conexión");
    }
  };

  const handleSelectView = (view) => {
    setActiveView(view);
  };

  const timeSlots = Array.from({ length: 14 }, (_, i) => {
    const hour = i + 7;
    return `${hour.toString().padStart(2, '0')}:00`;
  });

  const weekDays = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];

  const filteredHorarios = horarios.filter(h => {
    // ... same filters
    if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      if (h.carrera_name !== currentUser.carrera) return false;
    }
    return (!selectedCarreraName || h.carrera_name === selectedCarreraName) &&
      (!selectedGrupoName || h.grupo_name === selectedGrupoName);
  });

  const filteredExamenes = examenes.filter(e => {
    if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      if (!e.materia || e.materia.carrera_nombre !== currentUser.carrera) return false;
    }
    const matchesCareer = !selectedCarreraName || (e.materia && e.materia.carrera_nombre === selectedCarreraName);
    let matchesGroup = true;
    if (activeView === 'Calendario') {
      matchesGroup = !selectedGrupoId || (e.grupo_id === selectedGrupoId);
    } else if (activeView === 'Horarios') {
      if (selectedGrupoIdForExamenes) {
        matchesGroup = e.grupo_id === selectedGrupoIdForExamenes;
      } else {
        matchesGroup = true; // Show all if none selected
      }
    } else if (activeView === 'Rechazados') {
      // Show only rejected
      return matchesCareer && e.status === 'rechazado';
    }
    return matchesCareer && matchesGroup;
  });

  const getEventForCell = (day, time) => {
    // ... same
    const formatTime = (t) => t.slice(0, 5);
    const formattedTime = formatTime(time);
    const exams = filteredExamenes.filter(e => {
      const examDay = getDayOfWeek(e.fecha);
      return examDay === day && formatTime(e.hora_inicio) === formattedTime;
    });
    if (exams.length > 0) {
      return (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', width: '100%' }}>
          {exams.map((exam, index) => (
            <div key={exam.id || index} className="exam-assignment" style={{ backgroundColor: '#4299e1', width: '90%', margin: '0 auto' }}>
              <div className="exam-assignment-name">{exam.materia.nombre}</div>
              <div style={{ fontSize: '0.8em', marginBottom: '2px' }}>{exam.grupo?.nombre_grupo || 'Grupo'}</div>
              <div className="exam-assignment-time">{exam.hora_inicio} - {exam.hora_fin}</div>
            </div>
          ))}
        </div>
      );
    }
    return null;
  };

  let carrerasToShow = carreras;
  if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
    carrerasToShow = carreras.filter(c => c.nombre === currentUser.carrera);
  }

  const uniqueCarreras = [...new Set(carrerasToShow.map(c => ({ id: c.id, nombre: c.nombre })))];
  const allUniqueGroups = [...new Set(carrerasToShow.flatMap(carrera => carrera.grupos.map(g => ({ id: g.id, nombre_grupo: g.nombre_grupo, carrera_id: carrera.id }))))];
  const uniqueGrupos = selectedCarreraName
    ? [...new Set(carrerasToShow.find(c => c.nombre === selectedCarreraName)?.grupos.map(g => ({ id: g.id, nombre_grupo: g.nombre_grupo })) || [])]
    : [];

  return (
    <div className="dashboard">
      <Header
        currentUser={currentUser}
        onLogout={onLogout}
        onMenuToggle={toggleSidebar}
        notifications={notifications}
        onMarkAsRead={handleMarkAsRead}
      />

      <div className="dashboard-content">
        <Sidebar activeView={activeView} onSelectView={handleSelectView} isCollapsed={isSidebarCollapsed} currentUser={currentUser} />

        <main className="main-content">
          <div className="content-header">
            <div>
              <h1>{
                activeView === 'Inicio' ? 'Bienvenido' :
                  activeView === 'Calendario' ? 'Horario de Exámenes' :
                    activeView === 'Horarios' ? 'Gestión de Horarios' :
                      activeView === 'Revisiones' ? 'Revisión (Servicios Escolares)' :
                        activeView === 'Rechazados' ? 'Exámenes Rechazados' :
                          activeView
              }</h1>
              {activeView === 'Calendario' && (
                <p className="subtitle">
                  {selectedCarreraName && selectedGrupoName ? `${selectedCarreraName} - ${selectedGrupoName}` : `Selecciona Carrera y Grupo`}
                </p>
              )}
            </div>
            {activeView === 'Calendario' && (
              <div className="header-controls">
                <select
                  className="career-select"
                  value={selectedCarreraName}
                  onChange={(e) => {
                    const name = e.target.value;
                    setSelectedCarreraName(name);
                    const selectedCarreraObj = carreras.find(c => c.nombre === name);
                    setSelectedCarreraId(selectedCarreraObj ? selectedCarreraObj.id : null);
                    setSelectedGrupoName('');
                    setSelectedGrupoId(null);
                  }}
                  disabled={currentUser && currentUser.role === 'jefe_carrera'}
                >
                  <option value="">Seleccionar Carrera</option>
                  {uniqueCarreras.map(career => (
                    <option key={career.id} value={career.nombre}>{career.nombre}</option>
                  ))}
                </select>
                {selectedCarreraName && (
                  <select
                    className="group-select"
                    value={selectedGrupoName}
                    onChange={(e) => {
                      const name = e.target.value;
                      setSelectedGrupoName(name);
                      const selectedGrupoObj = uniqueGrupos.find(g => g.nombre_grupo === name);
                      setSelectedGrupoId(selectedGrupoObj ? selectedGrupoObj.id : null);
                    }}
                  >
                    <option value="">Seleccionar Grupo</option>
                    {uniqueGrupos.map(group => (
                      <option key={group.id} value={group.nombre_grupo}>{group.nombre_grupo}</option>
                    ))}
                  </select>
                )}
                <button
                  className="plan-button"
                  onClick={handleGenerateExams}
                  disabled={!selectedCarreraId && !(currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera)}
                >
                  Planificar
                </button>
              </div>
            )}
          </div>

          <div className="planning-container">
            {activeView === 'Calendario' && (
              <div className="schedule-grid">
                <div className="grid-header">
                  <div className="time-column-header">Hora</div>
                  {weekDays.map(day => (
                    <div key={day} className="day-header"><div className="day-name">{day}</div></div>
                  ))}
                </div>
                {timeSlots.map(time => (
                  <div key={time} className="schedule-row">
                    <div className="time-column"><div className="time-display">{time}</div></div>
                    {weekDays.map(day => (
                      <div key={`${day}-${time}`} className="schedule-cell">
                        {getEventForCell(day, time)}
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            )}

            {activeView === 'Horarios' && (
              <ExamScheduleDisplay
                examenes={filteredExamenes.filter(e => e.status !== 'rechazado' && e.status !== 'aprobado')}
                // Only show workable exams here. Rejected go to Rejected tab if specific. 
                // Wait, user might want to see approved ones? Yes. So filter appropriately.
                // Let's modify filterExamenes logic or just show all non-rejected here?
                // Actually approved is fine. Rejected should be in "Rechazados" if separate view.
                onRefresh={fetchExamenes}
                title={selectedCarreraName ? selectedCarreraName.toUpperCase() : "HORARIOS DE EXÁMENES"}
              >
                <div className="examenes-filter-controls">
                  <select
                    className="career-select"
                    value={selectedCarreraName}
                    onChange={(e) => {
                      const name = e.target.value;
                      setSelectedCarreraName(name);
                      setSelectedGrupoIdForExamenes(null);
                    }}
                  >
                    <option value="">Seleccionar Carrera</option>
                    {uniqueCarreras.map(career => (
                      <option key={career.id} value={career.nombre}>{career.nombre}</option>
                    ))}
                  </select>
                  <select
                    className="group-select"
                    value={selectedGrupoIdForExamenes || ''}
                    onChange={(e) => setSelectedGrupoIdForExamenes(e.target.value ? parseInt(e.target.value) : null)}
                    disabled={!selectedCarreraName}
                  >
                    <option value="">Todos los Grupos</option>
                    {allUniqueGroups
                      .filter(group => !selectedCarreraName || group.carrera_id === selectedCarreraId)
                      .map(group => (
                        <option key={group.id} value={group.id}>{group.nombre_grupo}</option>
                      ))}
                  </select>
                  {currentUser && currentUser.role === 'jefe_carrera' && (
                    <button className="plan-button" onClick={handleEnviarRevision} style={{ marginLeft: '20px' }}>
                      Guardar y Enviar
                    </button>
                  )}
                  {currentUser && currentUser.role === 'servicios_escolares' && selectedGrupoIdForExamenes && (
                    <div style={{ display: 'flex', gap: '10px', marginLeft: '20px', alignItems: 'center' }}>
                      <button className="btn-save" onClick={() => handleRevisionAction('aprobar')} style={{ backgroundColor: '#48bb78', color: 'white', padding: '8px 15px', border: 'none', borderRadius: '5px', cursor: 'pointer', fontWeight: 'bold' }}>
                        Aprobar Grupo
                      </button>
                      <button className="btn-cancel" onClick={() => handleRevisionAction('rechazar')} style={{ backgroundColor: '#e53e3e', color: 'white', padding: '8px 15px', border: 'none', borderRadius: '5px', cursor: 'pointer', fontWeight: 'bold' }}>
                        Rechazar Grupo
                      </button>
                    </div>
                  )}
                </div>
              </ExamScheduleDisplay>
            )}

            {activeView === 'Rechazados' && (
              <ExamScheduleDisplay
                examenes={filteredExamenes.filter(e => e.status === 'rechazado')}
                onRefresh={fetchExamenes}
                title="EXÁMENES RECHAZADOS (CORREGIR)"
              >
                <div className="examenes-filter-controls">
                  <select
                    className="career-select"
                    value={selectedCarreraName}
                    onChange={(e) => {
                      const name = e.target.value;
                      setSelectedCarreraName(name);
                      setSelectedCarreraId(carreras.find(c => c.nombre === name)?.id || null);
                    }}
                  >
                    <option value="">Seleccionar Carrera</option>
                    {uniqueCarreras.map(career => (
                      <option key={career.id} value={career.nombre}>{career.nombre}</option>
                    ))}
                  </select>
                  {currentUser && currentUser.role === 'jefe_carrera' && selectedCarreraId && (
                    <button className="plan-button" onClick={handleEnviarRevision} style={{ marginLeft: '20px', backgroundColor: '#ed8936' }}>
                      Re-enviar a Revisión
                    </button>
                  )}
                </div>
              </ExamScheduleDisplay>
            )}

            {activeView === 'Revisiones' && (
              <ExamReview currentUser={currentUser} API_URL={API_URL} />
            )}

            {activeView === 'Usuarios' && <UserManagement />}
            {activeView === 'Sinodal' && <SinodalesView currentUser={currentUser} />}

            {activeView === 'Inicio' && (
              <div className="welcome-container">
                <div className="welcome-card">
                  <div className="welcome-icon">
                    <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                      <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                  </div>
                  <div className="welcome-text">
                    <h2>¡Bienvenido al Sistema de Gestión de Exámenes, {currentUser ? currentUser.username : 'Usuario'}!</h2>
                    <p>Aquí podrás gestionar tus horarios, calendarios y revisiones de forma eficiente.</p>
                  </div>
                </div>

                <div className="quick-access-grid">
                  <div className="access-card" onClick={() => setActiveView('Calendario')}>
                    <div className="access-icon">
                      <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                      </svg>
                    </div>
                    <h3>Calendario</h3>
                    <p>Visualiza y planifica los horarios de exámenes.</p>
                  </div>
                  <div className="access-card" onClick={() => setActiveView('Horarios')}>
                    <div className="access-icon">
                      <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                      </svg>
                    </div>
                    <h3>Gestión</h3>
                    <p>Modifica fechas y aulas de los exámenes.</p>
                  </div>
                  {currentUser && (currentUser.role === 'servicios_escolares') && (
                    <div className="access-card" onClick={() => setActiveView('Revisiones')}>
                      <div className="access-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                          <polyline points="22 4 12 14.01 9 11.01"></polyline>
                        </svg>
                      </div>
                      <h3>Revisiones</h3>
                      <p>Aprueba o rechaza solicitudes pendientes.</p>
                    </div>
                  )}
                  {currentUser && currentUser.role === 'jefe_carrera' && (
                    <div className="access-card" onClick={() => setActiveView('Sinodal')}>
                      <div className="access-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                          <circle cx="9" cy="7" r="4"></circle>
                          <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                          <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                        </svg>
                      </div>
                      <h3>Sinodales</h3>
                      <p>Asigna sinodales a los exámenes de tu carrera.</p>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </main>
      </div>
      {showNotification && (
        <div className={`notification bottom-right ${showNotification ? 'show' : ''}`}>
          {notificationMessage}
        </div>
      )}
      {showGenerateModal && (
        <GenerateExamsModal
          onClose={() => setShowGenerateModal(false)}
          onGenerate={handleGenerateFromModal}
          carreraId={selectedCarreraId || (currentUser && currentUser.role === 'jefe_carrera' && carreras.find(c => c.nombre === currentUser.carrera)?.id)}
          currentUser={currentUser}
          API_URL={API_URL}
        />
      )}
    </div>
  );
}

export default Dashboard;
