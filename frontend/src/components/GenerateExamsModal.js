import React, { useState, useEffect, useCallback } from 'react';
import './GenerateExamsModal.css';

/**
 * Redesigned GenerateExamsModal
 * - Grouped by Academic Group
 * - One exam per day enforcement handled by backend
 * - Visual indication of missing sinodales
 * - Academia selection restored
 */
function GenerateExamsModal({ onClose, onGenerate, carreraId, currentUser, API_URL }) {
  const [academias, setAcademias] = useState([]);
  const [groupsData, setGroupsData] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      // 1. Fetch academic structure
      const carreraRes = await fetch(`${API_URL}/carreras`);
      const carrerasData = await carreraRes.json();
      const currentCarrera = carrerasData.find(c => c.id === parseInt(carreraId));

      // 2. Fetch Academias
      const academiasRes = await fetch(`${API_URL}/academias`);
      const acaData = await (academiasRes.ok ? academiasRes.json() : []);
      setAcademias(acaData);

      // 3. Fetch current exams to check for already assigned sinodales
      const examenesRes = await fetch(`${API_URL}/examenes`);
      const allExamenes = await (examenesRes.ok ? examenesRes.json() : []);

      // 4. Process Groups from Horarios
      // We want to show which materias are actually assigned to each group
      if (!currentCarrera || !currentCarrera.grupos) {
        setGroupsData([]);
        return;
      }

      const processed = currentCarrera.grupos.map(grupo => {
        // Collect unique materias from schedules
        const materiasMap = {};
        (grupo.horarios || []).forEach(h => {
          if (h.materia && !materiasMap[h.materia.id]) {
            // Check if there's an existing exam record to get sinodal info
            const existing = allExamenes.find(e => e.materia_id === h.materia.id && e.grupo_id === grupo.id);

            materiasMap[h.materia.id] = {
              id: h.materia.id,
              nombre: h.materia.nombre,
              profesor: h.materia.profesor?.nombre || 'Sin asignar',
              hasSinodal: !!existing?.sinodal_id,
              sinodalNombre: existing?.sinodal?.nombre || null,
              selected: true,
              academiaId: ''
            };
          }
        });

        const materiasList = Object.values(materiasMap).sort((a, b) => a.nombre.localeCompare(b.nombre));

        return {
          id: grupo.id,
          nombre: grupo.nombre_grupo,
          materias: materiasList,
          selected: materiasList.length > 0
        };
      }).filter(g => g.materias.length > 0) // Only show groups with materias
        .sort((a, b) => a.nombre.localeCompare(b.nombre));

      setGroupsData(processed);
    } catch (error) {
      console.error("Error in modal fetchData:", error);
    } finally {
      setLoading(false);
    }
  }, [carreraId, API_URL]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const toggleGroup = (groupId) => {
    setGroupsData(prev => prev.map(g => {
      if (g.id === groupId) {
        const newSel = !g.selected;
        return {
          ...g,
          selected: newSel,
          materias: g.materias.map(m => ({ ...m, selected: newSel }))
        };
      }
      return g;
    }));
  };

  const toggleMateria = (groupId, materiaId) => {
    setGroupsData(prev => prev.map(g => {
      if (g.id === groupId) {
        const updatedMaterias = g.materias.map(m =>
          m.id === materiaId ? { ...m, selected: !m.selected } : m
        );
        return {
          ...g,
          materias: updatedMaterias,
          selected: updatedMaterias.some(m => m.selected)
        };
      }
      return g;
    }));
  };

  const setAcademiaValue = (groupId, materiaId, value) => {
    setGroupsData(prev => prev.map(g => {
      if (g.id === groupId) {
        return {
          ...g,
          materias: g.materias.map(m =>
            m.id === materiaId ? { ...m, academiaId: value } : m
          )
        };
      }
      return g;
    }));
  };

  const handleGenerateClick = () => {
    const selection = [];
    groupsData.forEach(g => {
      g.materias.forEach(m => {
        if (m.selected) {
          selection.push({
            materiaId: m.id,
            grupoId: g.id,
            academiaId: m.academiaId || null
          });
        }
      });
    });

    if (selection.length === 0) {
      alert("Por favor selecciona al menos una materia.");
      return;
    }

    onGenerate(selection);
  };

  if (loading) {
    return (
      <div className="gem-backdrop">
        <div className="gem-modal">
          <div className="gem-loading">
            <div className="spinner-blue"></div>
            <p>Cargando estructura académica...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="gem-backdrop" onClick={onClose}>
      <div className="gem-modal" onClick={e => e.stopPropagation()}>
        <div className="gem-header border-blue">
          <div className="header-icon-title">
            <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="#2563eb" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
              <line x1="16" y1="2" x2="16" y2="6"></line>
              <line x1="8" y1="2" x2="8" y2="6"></line>
              <line x1="3" y1="10" x2="21" y2="10"></line>
            </svg>
            <h3>Configuración de Exámenes - {currentUser?.carrera || 'Carrera'}</h3>
          </div>
          <button className="gem-close" onClick={onClose}>
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>

        <div className="gem-content">
          <div className="gem-instruction blue-light">
            <p><strong>Regla de Negocio:</strong> Se asignará automáticamente un solo examen por día para cada grupo para evitar sobrecarga de los estudiantes.</p>
          </div>

          <div className="groups-container">
            {groupsData.length === 0 ? (
              <div className="empty-state">No se encontraron materias programadas para los grupos de esta carrera.</div>
            ) : groupsData.map(group => (
              <div key={group.id} className={`group-section ${group.selected ? 'active' : ''}`}>
                <div className="group-header" onClick={() => toggleGroup(group.id)}>
                  <div className="group-info">
                    <div className={`checkbox-custom ${group.selected ? 'checked' : ''}`}>
                      {group.selected && <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="white" strokeWidth="3"><polyline points="20 6 9 17 4 12"></polyline></svg>}
                    </div>
                    <span className="group-name">Grupo {group.nombre}</span>
                  </div>
                  <div className="group-stats">
                    {group.materias.filter(m => m.selected).length} de {group.materias.length} materias seleccionadas
                  </div>
                </div>

                {group.selected && (
                  <div className="group-table-container">
                    <table className="materia-table">
                      <thead>
                        <tr>
                          <th style={{ width: '40px' }}></th>
                          <th>Materia</th>
                          <th>Docente Titular</th>
                          <th>Estado Sinodal</th>
                          <th>Academia</th>
                        </tr>
                      </thead>
                      <tbody>
                        {group.materias.map(m => (
                          <tr
                            key={`${group.id}-${m.id}`}
                            className={`${m.selected ? 'row-selected' : ''} ${!m.hasSinodal ? 'row-warning' : ''}`}
                            onClick={() => toggleMateria(group.id, m.id)}
                          >
                            <td>
                              <div className={`checkbox-small ${m.selected ? 'checked' : ''}`}>
                                {m.selected && <svg viewBox="0 0 24 24" width="10" height="10" fill="none" stroke="white" strokeWidth="4"><polyline points="20 6 9 17 4 12"></polyline></svg>}
                              </div>
                            </td>
                            <td>
                              <div className="materia-main-info">
                                <span className="m-name">{m.nombre}</span>
                                {!m.hasSinodal && <span className="sinodal-badge">Falta Asignar Sinodal</span>}
                              </div>
                            </td>
                            <td className="m-text-muted">{m.profesor}</td>
                            <td>
                              {m.hasSinodal ? (
                                <div className="sinodal-assigned">
                                  <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="#059669" strokeWidth="2.5"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                  <span>{m.sinodalNombre || 'Asignado'}</span>
                                </div>
                              ) : (
                                <span className="sinodal-missing">Pendiente de Sinodal</span>
                              )}
                            </td>
                            <td onClick={e => e.stopPropagation()}>
                              <select
                                className="gem-select-inner"
                                value={m.academiaId}
                                onChange={e => setAcademiaValue(group.id, m.id, e.target.value)}
                                disabled={!m.selected}
                              >
                                <option value="">¿Tiene Academia?</option>
                                <option value="si">Sí (General)</option>
                                {academias.map(aca => (
                                  <option key={aca.id} value={aca.id}>{aca.nombre}</option>
                                ))}
                              </select>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="gem-actions">
          <button className="gem-cancel" onClick={onClose}>Cancelar</button>
          <button className="gem-generate btn-primary" onClick={handleGenerateClick}>
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 2v20M5 5l14 14M19 5L5 14"></path>
              {/* Note: Dummy icon for generate, replace if needed */}
              <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
            Generar Exámenes
          </button>
        </div>
      </div>
    </div>
  );
}

export default GenerateExamsModal;
