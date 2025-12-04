import React, { useState, useEffect } from 'react';
import './GenerateExamsModal.css';

function GenerateExamsModal({ onClose, onGenerate, carreraId, currentUser, API_URL }) {
  const [materias, setMaterias] = useState([]);
  const [examenes, setExamenes] = useState([]);
  const [academias, setAcademias] = useState([]);
  const [selectedMaterias, setSelectedMaterias] = useState({}); // { materiaId: { selected: true, academiaId: null } }
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, [carreraId]);

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch materias de la carrera
      const materiasRes = await fetch(`${API_URL}/materias?carrera_id=${carreraId}`);
      const materiasData = await materiasRes.ok ? await materiasRes.json() : [];
      
      // Fetch exámenes existentes para verificar sinodales
      const examenesRes = await fetch(`${API_URL}/examenes`);
      const examenesData = await examenesRes.ok ? await examenesRes.json() : [];
      
      // Filtrar exámenes de esta carrera
      const examenesCarrera = examenesData.filter(e => 
        e.materia && e.materia.carrera_nombre === currentUser?.carrera
      );
      
      // Fetch academias
      const academiasRes = await fetch(`${API_URL}/academias`);
      const academiasData = await academiasRes.ok ? await academiasRes.json() : [];
      
      setMaterias(materiasData);
      setExamenes(examenesCarrera);
      setAcademias(academiasData);
      
      // Inicializar selección de materias
      const initialSelection = {};
      materiasData.forEach(m => {
        initialSelection[m.id] = {
          selected: true,
          academiaId: null
        };
      });
      setSelectedMaterias(initialSelection);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleMateriaToggle = (materiaId) => {
    setSelectedMaterias(prev => ({
      ...prev,
      [materiaId]: {
        ...prev[materiaId],
        selected: !prev[materiaId]?.selected
      }
    }));
  };

  const handleAcademiaChange = (materiaId, academiaId) => {
    setSelectedMaterias(prev => ({
      ...prev,
      [materiaId]: {
        ...prev[materiaId],
        academiaId: academiaId || null
      }
    }));
  };

  const hasSinodal = (materiaId) => {
    const examen = examenes.find(e => e.materia_id === materiaId);
    return examen && examen.sinodal_id;
  };

  const materiasSinSinodal = materias.filter(m => !hasSinodal(m.id));

  const handleGenerate = () => {
    const materiasToGenerate = Object.entries(selectedMaterias)
      .filter(([_, data]) => data.selected)
      .map(([materiaId, data]) => ({
        materiaId: parseInt(materiaId),
        academiaId: data.academiaId ? parseInt(data.academiaId) : null
      }));
    
    if (materiasToGenerate.length === 0) {
      alert('Por favor selecciona al menos una materia');
      return;
    }
    
    onGenerate(materiasToGenerate);
  };

  if (loading) {
    return (
      <div className="gem-backdrop">
        <div className="gem-modal">
          <div className="gem-loading">Cargando...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="gem-backdrop" onClick={onClose}>
      <div className="gem-modal" onClick={(e) => e.stopPropagation()}>
        <div className="gem-header">
          <h3>Generar Exámenes - {currentUser?.carrera}</h3>
          <button className="gem-close" onClick={onClose}>✕</button>
        </div>
        
        <div className="gem-content">
          {materiasSinSinodal.length > 0 && (
            <div className="gem-warning">
              <strong>⚠️ Advertencia:</strong> Las siguientes materias no tienen sinodal asignado:
              <ul>
                {materiasSinSinodal.map(m => (
                  <li key={m.id}>{m.nombre}</li>
                ))}
              </ul>
            </div>
          )}
          
          <div className="gem-materias-list">
            <h4>Selecciona las materias para generar exámenes:</h4>
            <table className="gem-table">
              <thead>
                <tr>
                  <th>Seleccionar</th>
                  <th>Materia</th>
                  <th>Profesor</th>
                  <th>Sinodal</th>
                  <th>Academia</th>
                </tr>
              </thead>
              <tbody>
                {materias.map(materia => {
                  const examen = examenes.find(e => e.materia_id === materia.id);
                  const hasSinodalAssigned = hasSinodal(materia.id);
                  
                  return (
                    <tr key={materia.id} className={!hasSinodalAssigned ? 'gem-no-sinodal' : ''}>
                      <td>
                        <input
                          type="checkbox"
                          checked={selectedMaterias[materia.id]?.selected || false}
                          onChange={() => handleMateriaToggle(materia.id)}
                        />
                      </td>
                      <td>{materia.nombre}</td>
                      <td>{materia.profesor?.nombre || 'N/A'}</td>
                      <td>
                        {hasSinodalAssigned ? (
                          <span className="gem-status-ok">✓ Asignado</span>
                        ) : (
                          <span className="gem-status-warning">⚠ Sin asignar</span>
                        )}
                      </td>
                      <td>
                        <select
                          value={selectedMaterias[materia.id]?.academiaId || ''}
                          onChange={(e) => handleAcademiaChange(materia.id, e.target.value)}
                          disabled={!selectedMaterias[materia.id]?.selected}
                        >
                          <option value="">Sin academia</option>
                          {academias.map(academia => (
                            <option key={academia.id} value={academia.id}>
                              {academia.nombre}
                            </option>
                          ))}
                        </select>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
        
        <div className="gem-actions">
          <button className="gem-cancel" onClick={onClose}>Cancelar</button>
          <button className="gem-generate" onClick={handleGenerate}>
            Generar Exámenes
          </button>
        </div>
      </div>
    </div>
  );
}

export default GenerateExamsModal;

