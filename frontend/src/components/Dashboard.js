/**
 * Componente Dashboard - Panel principal de la aplicación.
 * Gestiona la visualización de horarios, exámenes y navegación entre vistas.
 */
import React, { useState, useEffect } from 'react';
import Header from './layout/Header';
import Sidebar from './layout/Sidebar';
import ExamReview from './ExamReview';
import ExamScheduleDisplay from './ExamScheduleDisplay';
import UserManagement from './UserManagement';
import SinodalesView from './SinodalesView';
import GenerateExamsModal from './GenerateExamsModal';
import ExamFiles from './ExamFiles';
import './Dashboard.css';

const getDayOfWeek = (dateString) => {
  const date = new Date(dateString + 'T00:00:00');
  const days = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
  return days[date.getDay()];
};

function Dashboard({ currentUser, onLogout }) {
  const [carreras, setCarreras] = useState([]);
  const [grupos, setGrupos] = useState([]);
  const [horarios, setHorarios] = useState([]);
  const [examenes, setExamenes] = useState([]);
  const [selectedCarreraName, setSelectedCarreraName] = useState('');
  const [selectedCarreraId, setSelectedCarreraId] = useState(null);
  const [selectedGrupoName, setSelectedGrupoName] = useState('');
  const [selectedGrupoId, setSelectedGrupoId] = useState(null);
  const [activeView, setActiveView] = useState('Inicio');
  const [selectedGrupoIdForExamenes, setSelectedGrupoIdForExamenes] = useState(null);
  const [showNotification, setShowNotification] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState('');
  const [notificationType, setNotificationType] = useState('success'); // 'success', 'error', 'warning'
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [showGenerateModal, setShowGenerateModal] = useState(false);
  const [notifications, setNotifications] = useState([]);

  // State for Custom Modal (Confirm/Prompt)
  const [customModal, setCustomModal] = useState({
    show: false,
    title: '',
    message: '',
    type: 'confirm', // 'confirm', 'danger', 'prompt'
    icon: 'info', // 'info', 'warning', 'error'
    onConfirm: null,
    onCancel: null,
    inputValue: ''
  });

  // Helper para mostrar notificaciones (Toasts)
  const showToast = (message, type = 'success') => {
    setNotificationMessage(message);
    setNotificationType(type);
    setShowNotification(true);
    setTimeout(() => setShowNotification(false), 4000);
  };

  // Helper para diálogos de confirmación premium
  const confirmCustom = ({ title, message, type = 'confirm', icon = 'warning', onConfirm, onCancel }) => {
    setCustomModal({
      show: true,
      title,
      message,
      type,
      icon,
      onConfirm: () => {
        if (onConfirm) onConfirm();
        setCustomModal(prev => ({ ...prev, show: false }));
      },
      onCancel: () => {
        if (onCancel) onCancel();
        setCustomModal(prev => ({ ...prev, show: false }));
      }
    });
  };

  const toggleSidebar = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchNotifs, 30000);
    return () => clearInterval(interval);
  }, [currentUser]);

  // Recargar grupos cuando cambia la carrera seleccionada (solo para servicios escolares)
  useEffect(() => {
    if (currentUser && (currentUser.role === 'servicios_escolares' || currentUser.role === 'administrador')) {
      if (selectedCarreraId) {
        // Recargar grupos filtrados por la carrera seleccionada
        fetch(`${API_URL}/grupos-filtrados?rol=${currentUser.role}&carrera_seleccionada_id=${selectedCarreraId}`)
          .then(res => res.json())
          .then(gruposData => {
            setGrupos(gruposData);
          })
          .catch(err => console.error('Error al cargar grupos filtrados:', err));
      } else {
        // Si no hay carrera seleccionada, cargar todos los grupos
        fetch(`${API_URL}/grupos-filtrados?rol=${currentUser.role}`)
          .then(res => res.json())
          .then(gruposData => {
            setGrupos(gruposData);
          })
          .catch(err => console.error('Error al cargar todos los grupos:', err));
      }
    }
  }, [selectedCarreraId, currentUser, API_URL]);

  const fetchData = () => {
    // Usar endpoint filtrado según rol
    let carrerasUrl = `${API_URL}/carreras-filtradas?rol=${currentUser.role}`;
    if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      carrerasUrl += `&clave_carrera=${currentUser.carrera}`;
    }
    
    fetch(carrerasUrl)
      .then(response => response.json())
      .then(data => {
        if (!Array.isArray(data)) {
          console.error("Error: Carreras no es un array", data);
          return;
        }
        
        // Para jefe_carrera, NO auto-seleccionar para permitir elegir entre planes (06, 06B)
        // if (currentUser && currentUser.role === 'jefe_carrera' && data.length > 0) {
        //   const carrera = data[0];
        //   setSelectedCarreraName(carrera.nombre);
        //   setSelectedCarreraId(carrera.id);
        // }
        
        setCarreras(data);
        
        // Obtener grupos filtrados (sin carrera_seleccionada_id aún)
        let gruposUrl = `${API_URL}/grupos-filtrados?rol=${currentUser.role}`;
        if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
          gruposUrl += `&clave_carrera=${currentUser.carrera}`;
        }
        
        fetch(gruposUrl)
          .then(res => res.json())
          .then(gruposData => {
            setGrupos(gruposData);
          })
          .catch(err => console.error('Error al cargar grupos:', err));

        // Obtener horarios completos de las carreras filtradas
        // Necesitamos hacer fetch de carreras completas para obtener horarios
        fetch(`${API_URL}/carreras`)
          .then(res => res.json())
          .then(fullCarreras => {
            const carreraIds = data.map(c => c.id);
            const filteredFullCarreras = fullCarreras.filter(c => carreraIds.includes(c.id));
            
            const allHorarios = filteredFullCarreras.flatMap(carrera => {
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
          });
      })
      .catch(error => console.error('Error fetching carreras:', error));

    fetchExamenes();
    fetchNotifs();
  };

  const fetchNotifs = () => {
    if (!currentUser) return;
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
    fetch(`${API_URL}/examenes`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        // Por ahora mostrar TODOS los exámenes
        // TODO: El backend debe devolver solo los de la carrera del usuario
        setExamenes(data);
      })
      .catch(error => console.error('Error fetching examenes:', error));
  };

  const handleGenerateExams = () => {
    // Para jefe_carrera, asegurarse de que haya una carrera seleccionada
    if (currentUser && currentUser.role === 'jefe_carrera') {
      if (!selectedCarreraId) {
        alert('Por favor selecciona una carrera primero');
        return;
      }
    } else {
      // Para admin/servicios escolares, usar la carrera seleccionada o pedir que seleccionen
      if (!selectedCarreraId) {
        alert('Por favor selecciona una carrera');
        return;
      }
    }
    
    setShowGenerateModal(true);
  };

  const handleGenerateFromModal = async (selectionData) => {
    try {
      // Usar la carrera seleccionada (ya validada en handleGenerateExams)
      const carreraIdToUse = selectedCarreraId;

      const response = await fetch(`${API_URL}/generar-examenes?carrera_id=${carreraIdToUse}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          seleccion: selectionData.selection,
          tipoExamen: selectionData.tipoExamen,
          periodo: selectionData.periodo,
          modalidad: selectionData.modalidad
        })
      });

      if (!response.ok) throw new Error('Error al generar exámenes');

      fetchExamenes();
      setShowGenerateModal(false);
      setActiveView('Horarios');
      showToast('¡Exámenes generados exitosamente!', 'success');
    } catch (error) {
      showToast(`Error al generar exámenes: ${error.message}`, 'error');
    }
  };

  const handleEnviarRevision = async () => {
    if (!selectedCarreraId) {
      alert("Selecciona una carrera."); return;
    }
    const grupoIdToSend = selectedGrupoIdForExamenes || 0;

    if (grupoIdToSend === 0) {
      confirmCustom({
        title: "Enviar Todos a Revisión",
        message: "¿Estás seguro de enviar a revisión los exámenes de TODOS los grupos pendientes de esta carrera?",
        type: 'confirm',
        icon: 'info',
        onConfirm: async () => {
          await ejecutarEnvioRevision(selectedCarreraId, grupoIdToSend);
        }
      });
    } else {
      await ejecutarEnvioRevision(selectedCarreraId, grupoIdToSend);
    }
  };

  const ejecutarEnvioRevision = async (carreraId, grupoId) => {
    try {
      const res = await fetch(`${API_URL}/examenes/enviar-revision?carrera_id=${carreraId}&grupo_id=${grupoId}`, {
        method: 'POST'
      });
      const data = await res.json();
      if (res.ok) {
        showToast(data.message, 'success');
        fetchExamenes();
      } else {
        showToast(data.detail || data.message || "Error al enviar a revisión", 'error');
      }
    } catch (e) {
      showToast("Error de conexión", 'error');
    }
  };

  const handleRevisionAction = async (accion) => {
    if (!selectedCarreraId) {
      alert("Selecciona una carrera."); return;
    }

    const grupoIdToSend = selectedGrupoIdForExamenes || 0;

    if (accion === 'rechazar') {
      setCustomModal({
        show: true,
        title: "Rechazar Exámenes",
        message: "Por favor indica el motivo del rechazo:",
        type: 'prompt',
        icon: 'warning',
        inputValue: '',
        onConfirm: (val) => {
          if (!val) {
            showToast("Debes indicar un motivo", 'error');
            return;
          }
          finalizarRevisionAction(accion, grupoIdToSend, val, '');
        },
        onCancel: () => setCustomModal(prev => ({ ...prev, show: false }))
      });
      return;
    }

    if (grupoIdToSend === 0) {
      confirmCustom({
        title: "Aprobar Carrera",
        message: "¿Estás seguro de APROBAR los exámenes de TODOS los grupos pendientes de esta carrera?",
        onConfirm: () => finalizarRevisionAction(accion, grupoIdToSend, '', '')
      });
    } else {
      finalizarRevisionAction(accion, grupoIdToSend, '', '');
    }
  };

  const finalizarRevisionAction = async (accion, grupoId, motivo, comentarios) => {
    const payload = {
      carrera_id: selectedCarreraId,
      grupo_id: grupoId,
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
        showToast(accion === 'aprobar' ? "✅ Grupo Aprobado" : "❌ Grupo Rechazado", 'success');
        fetchExamenes();
      } else {
        showToast(data.message || "Error al procesar revisión", 'error');
      }
    } catch (e) {
      console.error(e);
      showToast("Error de conexión", 'error');
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
    if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      if (h.carrera_name !== currentUser.carrera) return false;
    }
    return (!selectedCarreraName || h.carrera_name === selectedCarreraName) &&
      (!selectedGrupoName || h.grupo_name === selectedGrupoName);
  });

  const filteredExamenes = examenes.filter(e => {
    
    // Para jefe_carrera, filtrar por carrera_id en lugar de carrera_nombre
    if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
      if (!e.materia) {
        return false;
      }
      
      // Comparar con carrera_id usando selectedCarreraId si existe
      if (selectedCarreraId && e.materia.carrera_id !== selectedCarreraId) {
        return false;
      }
    }
    const matchesCareer = !selectedCarreraName || (e.materia && e.materia.carrera_nombre === selectedCarreraName);
    let matchesGroup = true;
    if (activeView === 'Calendario') {
      matchesGroup = !selectedGrupoId || (e.grupo_id === selectedGrupoId);
    } else if (activeView === 'Horarios') {
      if (selectedGrupoIdForExamenes) {
        matchesGroup = e.grupo_id === selectedGrupoIdForExamenes;
      } else {
        matchesGroup = true;
      }
    } else if (activeView === 'Rechazados') {
      return matchesCareer && e.status === 'rechazado';
    }
    return matchesCareer && matchesGroup;
  });

  const getEventForCell = (day, time) => {
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

  // Las carreras ya vienen filtradas del endpoint carreras-filtradas
  // No necesitamos filtrar nuevamente aquí
  let carrerasToShow = carreras;

  // Eliminar duplicados usando un Map para comparar por id
  const uniqueCarrerasMap = new Map();
  carrerasToShow.forEach(c => {
    if (!uniqueCarrerasMap.has(c.id)) {
      uniqueCarrerasMap.set(c.id, { id: c.id, nombre: c.nombre });
    }
  });
  const uniqueCarreras = Array.from(uniqueCarrerasMap.values());
  
  // DEBUG: Verificar carreras disponibles
  console.log('DEBUG - uniqueCarreras:', uniqueCarreras);
  console.log('DEBUG - selectedCarreraName:', selectedCarreraName);
  console.log('DEBUG - currentUser:', currentUser);
  
  // Los grupos vienen del estado 'grupos' que se carga del endpoint grupos-filtrados
  const allUniqueGroups = grupos.map(g => ({ 
    id: g.id, 
    nombre_grupo: g.nombre_grupo, 
    carrera_id: g.carrera_id 
  }));
  
  // Filtrar grupos por la carrera seleccionada
  const carreraSeleccionadaId = carrerasToShow.find(c => c.nombre === selectedCarreraName)?.id;
  const uniqueGrupos = carreraSeleccionadaId
    ? grupos.filter(g => g.carrera_id === carreraSeleccionadaId).map(g => ({ id: g.id, nombre_grupo: g.nombre_grupo }))
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
                  activeView === 'Calendario' ? 'Calendario de Exámenes' :
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
                    console.log('DEBUG - onChange triggered, value:', e.target.value);
                    const name = e.target.value;
                    setSelectedCarreraName(name);
                    const selectedCarreraObj = carreras.find(c => c.nombre === name);
                    setSelectedCarreraId(selectedCarreraObj ? selectedCarreraObj.id : null);
                    setSelectedGrupoName('');
                    setSelectedGrupoId(null);
                    
                    // Actualizar grupos cuando cambia la carrera seleccionada (para todos los roles)
                    if (selectedCarreraObj) {
                      let gruposUrl = `${API_URL}/grupos-filtrados?rol=${currentUser.role}`;
                      if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                        gruposUrl += `&clave_carrera=${currentUser.carrera}`;
                      }
                      gruposUrl += `&carrera_seleccionada_id=${selectedCarreraObj.id}`;
                      
                      fetch(gruposUrl)
                        .then(res => res.json())
                        .then(gruposData => {
                          setGrupos(gruposData);
                        })
                        .catch(err => console.error('Error al cargar grupos:', err));
                    }
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
                  onClick={() => {
                    const isPending = filteredExamenes.some(e => e.status === 'pendiente_aprobacion');
                    if (isPending) {
                      showToast("Ya tienes exámenes enviados a revisión. Debes esperar a que Servicios Escolares los apruebe o rechace antes de generar nuevos.", "warning");
                      return;
                    }
                    handleGenerateExams();
                  }}
                  disabled={!selectedCarreraId}
                  style={filteredExamenes.some(e => e.status === 'pendiente_aprobacion') ? { opacity: 0.6, cursor: 'not-allowed' } : {}}
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
                onRefresh={fetchExamenes}
                showToast={showToast}
                title={selectedCarreraName ? selectedCarreraName.toUpperCase() : "HORARIOS DE EXÁMENES"}
              >
                <div className="examenes-filter-controls">
                  <select
                    className="career-select"
                    value={selectedCarreraName}
                    onChange={(e) => {
                      const name = e.target.value;
                      const selectedCarreraObj = carreras.find(c => c.nombre === name);
                      setSelectedCarreraName(name);
                      setSelectedCarreraId(selectedCarreraObj ? selectedCarreraObj.id : null);
                      setSelectedGrupoIdForExamenes(null);
                      
                      // Actualizar grupos cuando cambia la carrera seleccionada (para todos los roles)
                      if (selectedCarreraObj) {
                        let gruposUrl = `${API_URL}/grupos-filtrados?rol=${currentUser.role}`;
                        if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                          gruposUrl += `&clave_carrera=${currentUser.carrera}`;
                        }
                        gruposUrl += `&carrera_seleccionada_id=${selectedCarreraObj.id}`;
                        
                        fetch(gruposUrl)
                          .then(res => res.json())
                          .then(gruposData => {
                            setGrupos(gruposData);
                          })
                          .catch(err => console.error('Error al cargar grupos:', err));
                      }
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
                      value={selectedGrupoIdForExamenes || ''}
                      onChange={(e) => setSelectedGrupoIdForExamenes(e.target.value ? parseInt(e.target.value) : null)}
                    >
                      <option value="">Todos los Grupos</option>
                      {allUniqueGroups
                        .filter(group => group.carrera_id === selectedCarreraId)
                        .map(group => (
                          <option key={group.id} value={group.id}>{group.nombre_grupo}</option>
                        ))}
                    </select>
                  )}
                  {currentUser && currentUser.role === 'jefe_carrera' && (
                    <button
                      className="plan-button"
                      onClick={() => {
                        const isPending = filteredExamenes.some(e => e.status === 'pendiente_aprobacion');
                        if (isPending) {
                          showToast("Estos exámenes ya fueron enviados a revisión.", "warning");
                          return;
                        }
                        handleEnviarRevision();
                      }}
                      style={{
                        marginLeft: '20px',
                        ...(filteredExamenes.some(e => e.status === 'pendiente_aprobacion') ? { opacity: 0.6, cursor: 'not-allowed', backgroundColor: '#94a3b8' } : {})
                      }}
                      disabled={filteredExamenes.length === 0}
                    >
                      {filteredExamenes.some(e => e.status === 'pendiente_aprobacion') ? 'En Revisión...' : 'Guardar y Enviar'}
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
                showToast={showToast}
                title="EXÁMENES RECHAZADOS (CORREGIR)"
              >
                <div className="examenes-filter-controls">
                  <select
                    className="career-select"
                    value={selectedCarreraName}
                    onChange={(e) => {
                      const name = e.target.value;
                      const selectedCarreraObj = carreras.find(c => c.nombre === name);
                      setSelectedCarreraName(name);
                      setSelectedCarreraId(selectedCarreraObj ? selectedCarreraObj.id : null);
                      
                      // Actualizar grupos cuando cambia la carrera seleccionada (para todos los roles)
                      if (selectedCarreraObj) {
                        let gruposUrl = `${API_URL}/grupos-filtrados?rol=${currentUser.role}`;
                        if (currentUser.role === 'jefe_carrera' && currentUser.carrera) {
                          gruposUrl += `&clave_carrera=${currentUser.carrera}`;
                        }
                        gruposUrl += `&carrera_seleccionada_id=${selectedCarreraObj.id}`;
                        
                        fetch(gruposUrl)
                          .then(res => res.json())
                          .then(gruposData => {
                            setGrupos(gruposData);
                          })
                          .catch(err => console.error('Error al cargar grupos:', err));
                      }
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
              <ExamReview currentUser={currentUser} API_URL={API_URL} showToast={showToast} />
            )}

            {activeView === 'Usuarios' && <UserManagement showToast={showToast} confirmCustom={confirmCustom} />}
            {activeView === 'Sinodal' && <SinodalesView currentUser={currentUser} showToast={showToast} confirmCustom={confirmCustom} />}
            {activeView === 'Archivos' && <ExamFiles currentUser={currentUser} API_URL={API_URL} showToast={showToast} />}

            {activeView === 'Inicio' && (
              <div className="welcome-container">
                <div className="welcome-card">
                  <div className="welcome-icon">
                    <svg viewBox="0 0 24 24" width="60" height="60" fill="none" stroke="#3b82f6" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
                      <path d="M6 12v5c3 3 9 3 12 0v-5"></path>
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
                  <div className="access-card" onClick={() => setActiveView('Archivos')}>
                    <div className="access-icon">
                      <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
                      </svg>
                    </div>
                    <h3>Archivos</h3>
                    <p>Imprime los calendarios de exámenes aprobados.</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </main>
      </div>
      {showNotification && (
        <div className={`notification bottom-right ${notificationType} ${showNotification ? 'show' : ''}`}>
          <div className="notification-icon">
            {notificationType === 'success' && (
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
            )}
            {notificationType === 'error' && (
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="15" y1="9" x2="9" y2="15"></line>
                <line x1="9" y1="9" x2="15" y2="15"></line>
              </svg>
            )}
            {notificationType === 'warning' && (
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                <line x1="12" y1="9" x2="12" y2="13"></line>
                <line x1="12" y1="17" x2="12.01" y2="17"></line>
              </svg>
            )}
          </div>
          <div className="notification-content">
            {notificationMessage}
          </div>
        </div>
      )}
      {showGenerateModal && (
        <GenerateExamsModal
          onClose={() => setShowGenerateModal(false)}
          onGenerate={handleGenerateFromModal}
          carreraId={selectedCarreraId}
          currentUser={currentUser}
          API_URL={API_URL}
          showToast={showToast}
          confirmCustom={confirmCustom}
        />
      )}

      {/* RENDER CUSTOM PREMIUM MODAL (Confirm/Prompt) */}
      {customModal.show && (
        <div className="custom-modal-overlay">
          <div className="custom-modal-container">
            <div className={`custom-modal-icon ${customModal.icon}`}>
              {customModal.icon === 'warning' && (
                <svg viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                  <line x1="12" y1="9" x2="12" y2="13"></line>
                  <line x1="12" y1="17" x2="12.01" y2="17"></line>
                </svg>
              )}
              {customModal.icon === 'error' && (
                <svg viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="15" y1="9" x2="9" y2="15"></line>
                  <line x1="9" y1="9" x2="15" y2="15"></line>
                </svg>
              )}
              {customModal.icon === 'info' && (
                <svg viewBox="0 0 24 24" width="32" height="32" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="16" x2="12" y2="12"></line>
                  <line x1="12" y1="8" x2="12.01" y2="8"></line>
                </svg>
              )}
            </div>
            <h3 className="custom-modal-title">{customModal.title}</h3>
            <p className="custom-modal-message">{customModal.message}</p>

            {customModal.type === 'prompt' && (
              <input
                type="text"
                className="custom-modal-input"
                autoFocus
                value={customModal.inputValue}
                onChange={(e) => setCustomModal(prev => ({ ...prev, inputValue: e.target.value }))}
                placeholder="Escribe aquí..."
                onKeyDown={(e) => {
                  if (e.key === 'Enter') customModal.onConfirm(customModal.inputValue);
                }}
              />
            )}

            <div className="custom-modal-actions">
              <button className="btn-custom btn-custom-cancel" onClick={customModal.onCancel}>
                Cancelar
              </button>
              <button
                className={`btn-custom ${customModal.type === 'danger' ? 'btn-custom-danger' : 'btn-custom-confirm'}`}
                onClick={() => customModal.onConfirm(customModal.type === 'prompt' ? customModal.inputValue : null)}
              >
                {customModal.type === 'prompt' ? 'Enviar' : 'Confirmar'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
