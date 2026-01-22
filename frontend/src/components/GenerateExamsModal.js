import React, { useState, useEffect, useCallback } from 'react';
import './GenerateExamsModal.css';

/**
 * Redesigned GenerateExamsModal
 * - Grouped by Academic Group
 * - One exam per day enforcement handled by backend
 * - Visual indication of missing sinodales
 * - Academia selection restored
 */
function GenerateExamsModal({ onClose, onGenerate, carreraId, currentUser, API_URL, showToast }) {
  const [academias, setAcademias] = useState([]);
  const [profesores, setProfesores] = useState([]);
  const [groupsData, setGroupsData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterText, setFilterText] = useState('');
  const [tipoExamen, setTipoExamen] = useState('Parcial 1');
  const [modalidad, setModalidad] = useState('Escrito');
  const [periodo, setPeriodo] = useState('2025-2');
  const [isGenerating, setIsGenerating] = useState(false);
  const [genMessage, setGenMessage] = useState('Calculando horarios y evitando conflictos...');

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      // 1. Fetch academic structure
      const carreraRes = await fetch(`${API_URL}/carreras`);
      const carrerasData = await carreraRes.json();
      const currentCarrera = carrerasData.find(c => c.id === parseInt(carreraId));

      // 2. Fetch Academias and Profesores
      const [academiasRes, profesoresRes, examenesRes] = await Promise.all([
        fetch(`${API_URL}/academias`),
        fetch(`${API_URL}/profesores`),
        fetch(`${API_URL}/examenes`)
      ]);

      const acaData = await (academiasRes.ok ? academiasRes.json() : []);
      const profData = await (profesoresRes.ok ? profesoresRes.json() : []);
      const allExamenes = await (examenesRes.ok ? examenesRes.json() : []);

      setAcademias(acaData);
      setProfesores(profData);

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
              profesorId: h.materia.profesor?.id || null,
              profesor: h.materia.profesor?.nombre || 'Sin asignar',
              aplicadorId: h.materia.profesor?.id || '',
              hasSinodal: !!existing?.sinodal_id,
              sinodalNombre: existing?.sinodal?.nombre || null,
              selected: true,
              academiaId: h.materia.academia_id || ''
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

  const toggleSelectAll = (checked) => {
    setGroupsData(prev => prev.map(g => ({
      ...g,
      selected: checked,
      materias: g.materias.map(m => ({ ...m, selected: checked }))
    })));
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

  const setAplicadorValue = (groupId, materiaId, value) => {
    setGroupsData(prev => prev.map(g => {
      if (g.id === groupId) {
        return {
          ...g,
          materias: g.materias.map(m =>
            m.id === materiaId ? { ...m, aplicadorId: value } : m
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
            academiaId: m.academiaId || null,
            aplicadorId: m.aplicadorId || null,
            modalidad: modalidad
          });
        }
      });
    });

    if (selection.length === 0) {
      if (showToast) showToast("Por favor selecciona al menos una materia.", "warning");
      else alert("Por favor selecciona al menos una materia.");
      return;
    }

    setIsGenerating(true);
    setGenMessage('Analizando disponibilidad de aulas y docentes...');

    // We wrap the onGenerate call to handle local loading state
    const runGeneration = async () => {
      try {
        await onGenerate({
          selection,
          tipoExamen,
          periodo,
          modalidad
        });
      } finally {
        setIsGenerating(false);
      }
    };

    runGeneration();
  };

  const filteredGroups = groupsData.filter(g =>
    g.nombre.toLowerCase().includes(filterText.toLowerCase()) ||
    g.materias.some(m => m.nombre.toLowerCase().includes(filterText.toLowerCase()))
  );

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
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="16" x2="12" y2="12"></line>
                <line x1="12" y1="8" x2="12.01" y2="8"></line>
              </svg>
              <p><strong>Regla de Negocio:</strong> Se asignará automáticamente un solo examen por día para cada grupo para evitar sobrecarga.</p>
            </div>
          </div>

          <div className="gem-top-controls" style={{ display: 'flex', gap: '15px', marginBottom: '20px', alignItems: 'flex-end', flexWrap: 'wrap' }}>
            <div className="control-field">
              <label className="field-label-premium">TIPO DE EXAMEN</label>
              <select
                className="gem-select-premium"
                value={tipoExamen}
                onChange={e => setTipoExamen(e.target.value)}
              >
                <option value="Parcial 1">Parcial 1</option>
                <option value="Parcial 2">Parcial 2</option>
                <option value="Parcial 3">Parcial 3</option>
                <option value="Ordinario">Ordinario</option>
                <option value="Extraordinario 1">Extraordinario 1</option>
                <option value="Extraordinario 2">Extraordinario 2</option>
              </select>
            </div>

            <div className="control-field">
              <label className="field-label-premium">PERIODO</label>
              <input
                type="text"
                className="gem-input-premium"
                value={periodo}
                onChange={e => setPeriodo(e.target.value)}
                placeholder="Ej. 2025-2"
              />
            </div>

            <div className="control-field">
              <label className="field-label-premium">MODALIDAD</label>
              <select
                className="gem-select-premium"
                value={modalidad}
                onChange={e => setModalidad(e.target.value)}
              >
                <option value="Escrito">Escrito</option>
                <option value="Digital">Digital</option>
              </select>
            </div>

            <div className="control-field" style={{ flex: 1, minWidth: '180px' }}>
              <label className="field-label-premium">FILTRAR GRUPO O MATERIA</label>
              <input
                type="text"
                className="gem-input-premium"
                value={filterText}
                onChange={e => setFilterText(e.target.value)}
                placeholder="Buscar..."
                style={{ width: '100%' }}
              />
            </div>

            <div className="control-field">
              <label className="checkbox-label" style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', padding: '10px', background: '#f8fafc', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                <input
                  type="checkbox"
                  checked={groupsData.length > 0 && groupsData.every(g => g.selected)}
                  onChange={e => toggleSelectAll(e.target.checked)}
                />
                <span style={{ fontSize: '13px', fontWeight: '600' }}>Seleccionar Todo</span>
              </label>
            </div>
          </div>

          <div className="groups-container">
            {filteredGroups.length === 0 ? (
              <div className="empty-state">No se encontraron materias que coincidan con la búsqueda.</div>
            ) : filteredGroups.map(group => (
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
                          <th style={{ width: '25%' }}>Materia</th>
                          <th>Docente Titular</th>
                          <th>Docente Aplicador</th>
                          <th>Academia</th>
                          <th>Estado</th>
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
                            <td onClick={e => e.stopPropagation()}>
                              <select
                                className="gem-select-inner"
                                value={m.aplicadorId}
                                onChange={e => setAplicadorValue(group.id, m.id, e.target.value)}
                                disabled={!m.selected}
                              >
                                {profesores.map(p => (
                                  <option key={p.id} value={p.id}>{p.nombre}</option>
                                ))}
                              </select>
                            </td>
                            <td onClick={e => e.stopPropagation()}>
                              <select
                                className="gem-select-inner"
                                value={m.academiaId}
                                onChange={e => setAcademiaValue(group.id, m.id, e.target.value)}
                                disabled={!m.selected}
                              >
                                <option value="">No aplica</option>
                                <option value="si">Academia General</option>
                                {academias.map(aca => (
                                  <option key={aca.id} value={aca.id}>{aca.nombre}</option>
                                ))}
                              </select>
                            </td>
                            <td style={{ textAlign: 'center' }}>
                              {m.hasSinodal ? (
                                <div className="status-indicator ok" title={m.sinodalNombre || 'Sinodal Asignado'}>
                                  <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                    <polyline points="9 12 11 14 15 10"></polyline>
                                  </svg>
                                </div>
                              ) : (
                                <div className="status-indicator warning" title="Pendiente de Sinodal">
                                  <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2.5">
                                    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
                                    <line x1="12" y1="9" x2="12" y2="13"></line>
                                    <line x1="12" y1="17" x2="12.01" y2="17"></line>
                                  </svg>
                                </div>
                              )}
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
          {isGenerating ? (
            <div className="gem-generating-status">
              <div className="progress-line"></div>
              <span>{genMessage}</span>
            </div>
          ) : (
            <>
              <button className="gem-cancel" onClick={onClose}>Cancelar</button>
              <button className="gem-generate btn-primary" onClick={handleGenerateClick}>
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 2v20M5 5l14 14M19 5L5 14"></path>
                  <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
                Generar Exámenes
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default GenerateExamsModal;
