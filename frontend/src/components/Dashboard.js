import React, { useState, useEffect } from 'react';
import Header from './layout/Header';
import Sidebar from './layout/Sidebar';
import ExamScheduleDisplay from './ExamScheduleDisplay'; // Import the new component
import UserManagement from './UserManagement'; // Import UserManagement component
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

  const toggleSidebar = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  // Construir la URL base dinámicamente usando el hostname actual
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    console.log('Fetching carreras...');
    fetch(`${API_URL}/carreras`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Carreras fetched:', data);

        let filteredCarreras = data;

        // Filtrar por rol de Jefe de Carrera
        if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
          filteredCarreras = data.filter(c => c.nombre === currentUser.carrera);
          // Auto-seleccionar la carrera
          if (filteredCarreras.length > 0) {
            const carrera = filteredCarreras[0];
            // Solo establecer si no hay una seleccionada (para evitar loops si se agrega currentUser a deps)
            if (!selectedCarreraId) {
              setSelectedCarreraName(carrera.nombre);
              setSelectedCarreraId(carrera.id);
            }
          }
        }

        setCarreras(filteredCarreras);
        const allHorarios = filteredCarreras.flatMap(carrera =>
          carrera.grupos.flatMap(grupo =>
            grupo.horarios.map(horario => ({
              ...horario,
              carrera_name: carrera.nombre, // Use carrera_name to avoid conflict
              carrera_id: carrera.id,
              grupo_name: grupo.nombre_grupo, // Use grupo_name
              grupo_id: grupo.id,
            }))
          )
        );
        setHorarios(allHorarios);
      })
      .catch(error => console.error('Error fetching carreras:', error));

    fetchExamenes();
  }, [currentUser]);

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
        setExamenes(data);
      })
      .catch(error => console.error('Error fetching examenes:', error));
  };

  const handleGenerateExams = () => {
    if (!selectedCarreraId || !selectedGrupoId) {
      console.warn('Selecciona una carrera y un grupo para generar exámenes.');
      return;
    }

    console.log(`Generating exams for Carrera ID: ${selectedCarreraId}, Grupo ID: ${selectedGrupoId}...`);
    fetch(`${API_URL}/generar-examenes?carrera_id=${selectedCarreraId}&grupo_id=${selectedGrupoId}`, { method: 'POST' })
      .then(response => {
        if (!response.ok) {
          return response.json().then(err => { throw new Error(err.detail || 'Error al generar exámenes'); });
        }
        return response.json();
      })
      .then(data => {
        console.log('Examenes generados y recibidos:', data);
        fetchExamenes(); // Refreshes the exam list after generation
        setActiveView('Horarios'); // Switch to Horarios view to display generated exams
        console.log('Active View after generation:', 'Horarios'); // Debug log for activeView
        console.log('Notification state set: success'); // Debug log
        setNotificationMessage('¡Exámenes generados exitosamente!');
        setShowNotification(true);
        setTimeout(() => setShowNotification(false), 3000); // Hide after 3 seconds
      })
      .catch(error => {
        console.error('Error generating exams:', error.message);
        console.error('Notification state set: error', error); // Debug log
        setNotificationMessage(`Error al generar exámenes: ${error.message}`);
        setShowNotification(true);
        setTimeout(() => setShowNotification(false), 5000); // Hide error after 5 seconds
      });
  };

  const handleSelectView = (view) => {
    setActiveView(view);
  };

  // Generate time slots from 7:00 AM to 8:00 PM
  const timeSlots = Array.from({ length: 14 }, (_, i) => {
    const hour = i + 7;
    return `${hour.toString().padStart(2, '0')}:00`;
  });

  const weekDays = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];

  const filteredHorarios = horarios.filter(h =>
    (!selectedCarreraName || h.carrera_name === selectedCarreraName) &&
    (!selectedGrupoName || h.grupo_name === selectedGrupoName)
  );

  const filteredExamenes = examenes.filter(e => {
    const matchesCareer = !selectedCarreraName || (e.materia && e.materia.carrera_nombre === selectedCarreraName);
    const matchesGroup = !selectedGrupoIdForExamenes || (e.grupo_id && e.grupo_id === parseInt(selectedGrupoIdForExamenes));
    return matchesCareer && matchesGroup;
  });

  console.log('Filtered Horarios:', filteredHorarios);
  console.log('Filtered Examenes:', filteredExamenes);

  const getEventForCell = (day, time) => {
    const formatTime = (t) => t.slice(0, 5);
    const formattedTime = formatTime(time);

    // Find exams first
    const exam = filteredExamenes.find(e => {
      const examDay = getDayOfWeek(e.fecha); // Use the helper function
      return examDay === day && formatTime(e.hora_inicio) === formattedTime;
    });
    if (exam) {
      return (
        <div className="exam-assignment" style={{ backgroundColor: '#4299e1' }}>
          <div className="exam-assignment-name">Examen: {exam.materia.nombre}</div>
          <div className="exam-assignment-time">{exam.hora_inicio} - {exam.hora_fin}</div>
        </div>
      );
    }

    // Find regular schedules
    const horario = filteredHorarios.find(h =>
      h.dia_semana === day && formatTime(h.hora_inicio) === formattedTime
    );

    if (horario) {
      return (
        <div className="exam-assignment" style={{ backgroundColor: '#48bb78' }}>
          <div className="exam-assignment-name">{horario.materia.nombre}</div>
          <div className="exam-assignment-time">{horario.hora_inicio} - {horario.hora_fin}</div>
          <div className="exam-assignment-profesor">{horario.materia.profesor?.nombre}</div>
        </div>
      );
    }

    return null;
  };

  const uniqueCarreras = [...new Set(carreras.map(c => ({ id: c.id, nombre: c.nombre })))];
  const allUniqueGroups = [...new Set(carreras.flatMap(carrera => carrera.grupos.map(g => ({ id: g.id, nombre_grupo: g.nombre_grupo, carrera_id: carrera.id }))))];
  const uniqueGrupos = selectedCarreraName
    ? [...new Set(carreras.find(c => c.nombre === selectedCarreraName)?.grupos.map(g => ({ id: g.id, nombre_grupo: g.nombre_grupo })) || [])]
    : [];

  return (
    <div className="dashboard">
      <Header currentUser={currentUser} onLogout={onLogout} onMenuToggle={toggleSidebar} />

      <div className="dashboard-content">
        <Sidebar activeView={activeView} onSelectView={handleSelectView} isCollapsed={isSidebarCollapsed} currentUser={currentUser} />

        <main className="main-content">
          <div className="content-header">
            <div>
              <h1>Horario de Clases y Exámenes</h1>
              <p className="subtitle">
                {selectedCarreraName && selectedGrupoName
                  ? `${selectedCarreraName} - ${selectedGrupoName}`
                  : `Selecciona Carrera y Grupo`
                }
              </p>
            </div>
            {activeView === 'Calendario' && ( // Only show controls in Calendario view
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
                  disabled={!selectedCarreraId || !selectedGrupoId}
                >
                  Planificar
                </button>
              </div>
            )}
          </div>

          <div className="planning-container">
            {activeView === 'Calendario' && ( // Render schedule grid only for Calendario view
              <div className="schedule-grid">
                <div className="grid-header">
                  <div className="time-column-header">Hora</div>
                  {weekDays.map(day => (
                    <div key={day} className="day-header">
                      <div className="day-name">{day}</div>
                    </div>
                  ))}
                </div>

                {timeSlots.map(time => (
                  <div key={time} className="schedule-row">
                    <div className="time-column">
                      <div className="time-display">{time}</div>
                    </div>
                    {weekDays.map(day => (
                      <div
                        key={`${day}-${time}`}
                        className="schedule-cell"
                      >
                        {getEventForCell(day, time)}
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            )}
            {activeView === 'Horarios' && ( // Render ExamScheduleDisplay for Horarios view
              <>
                <div className="examenes-filter-controls" style={{ marginBottom: '20px' }}>
                  {/* Filter by Career (already existing logic for selectedCarreraName) */}
                  <select
                    className="career-select"
                    value={selectedCarreraName} // This is for career filter for exams
                    onChange={(e) => {
                      const name = e.target.value;
                      setSelectedCarreraName(name);
                      // Reset group filter when career changes
                      setSelectedGrupoIdForExamenes(null);
                    }}
                  >
                    <option value="">Todas las Carreras</option>
                    {uniqueCarreras.map(career => (
                      <option key={career.id} value={career.nombre}>{career.nombre}</option>
                    ))}
                  </select>

                  {/* Filter by Group for Examenes */}
                  <select
                    className="group-select"
                    value={selectedGrupoIdForExamenes || ''}
                    onChange={(e) => setSelectedGrupoIdForExamenes(e.target.value ? parseInt(e.target.value) : null)}
                    disabled={!selectedCarreraName} // Disable group filter if no career is selected
                  >
                    <option value="">Todos los Grupos</option>
                    {allUniqueGroups
                      .filter(group => !selectedCarreraName || group.carrera_id === selectedCarreraId) // Filter groups by selected career
                      .map(group => (
                        <option key={group.id} value={group.id}>{group.nombre_grupo}</option>
                      ))}
                  </select>
                </div>
                <ExamScheduleDisplay examenes={filteredExamenes} />
              </>
            )}
            {activeView === 'Usuarios' && (
              <UserManagement />
            )}
            {activeView !== 'Calendario' && activeView !== 'Horarios' && activeView !== 'Usuarios' && (
              <div style={{ padding: '20px', textAlign: 'center', color: '#718096' }}>
                Selecciona una opción de la barra lateral para ver el contenido.
              </div>
            )}
          </div>
        </main>
      </div>
      {showNotification && (
        <div className="notification bottom-right">
          {notificationMessage}
        </div>
      )}
    </div>
  );
}

export default Dashboard;
