import React, { useState, useEffect } from 'react';
import './ServiciosEscolaresHome.css';

function ServiciosEscolaresHome({ currentUser }) {
  const [examenesPorCarrera, setExamenesPorCarrera] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Construir la URL base dinámicamente
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    const fetchExamenes = async () => {
      try {
        const response = await fetch(`${API_URL}/examenes?full=true`);
        if (!response.ok) {
          throw new Error('No se pudo obtener la lista de exámenes.');
        }
        const examenes = await response.json();

        // Agrupar exámenes por carrera
        const agrupados = examenes.reduce((acc, examen) => {
          const nombreCarrera = examen.carrera?.nombre || 'Carrera no especificada';
          if (!acc[nombreCarrera]) {
            acc[nombreCarrera] = [];
          }
          acc[nombreCarrera].push(examen);
          return acc;
        }, {});

        setExamenesPorCarrera(agrupados);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchExamenes();
  }, []);

  if (loading) {
    return <div className="seh-container">Cargando calendarios...</div>;
  }

  if (error) {
    return <div className="seh-container seh-error">Error: {error}</div>;
  }

  return (
    <div className="seh-container">
      <h2>Calendarios de Exámenes Recibidos</h2>
      <p>A continuación se muestra un resumen de los exámenes programados por cada carrera.</p>

      {Object.keys(examenesPorCarrera).length === 0 ? (
        <div className="seh-no-data">
          <p>Aún no se ha recibido ningún calendario de examen.</p>
        </div>
      ) : (
        Object.entries(examenesPorCarrera).map(([carrera, examenes]) => (
          <div key={carrera} className="seh-card">
            <h3>{carrera}</h3>
            <ul>
              {examenes.map((examen) => (
                <li key={examen.id}>
                  <strong>{examen.materia?.nombre || 'Materia desconocida'}</strong> - {new Date(examen.fecha).toLocaleDateString()} ({examen.hora_inicio} - {examen.hora_fin})
                </li>
              ))}
            </ul>
          </div>
        ))
      )}
    </div>
  );
}

export default ServiciosEscolaresHome;