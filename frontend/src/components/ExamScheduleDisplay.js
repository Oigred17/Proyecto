import React from 'react';
import './ExamScheduleDisplay.css'; // We'll create this CSS file next

const ExamScheduleDisplay = ({ examenes }) => {
  if (!examenes || examenes.length === 0) {
    return (
      <div className="exam-schedule-container">
        <p>No hay exámenes generados aún. Por favor, genera los exámenes.</p>
      </div>
    );
  }

  // Group exams by date
  const examsByDate = examenes.reduce((acc, exam) => {
    const date = new Date(exam.fecha + 'T00:00:00').toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
    if (!acc[date]) {
      acc[date] = [];
    }
    acc[date].push(exam);
    return acc;
  }, {});

  return (
    <div className="exam-schedule-container">
      <h2>Próximos Exámenes</h2>
      {Object.entries(examsByDate).map(([date, exams]) => (
        <div key={date} className="exam-date-group">
          <h3>{date}</h3>
          <div className="exam-list">
            {exams.map(exam => (
              <div key={exam.id} className="exam-item">
                <div className="exam-header">
                  <span className="exam-materia">{exam.materia.nombre}</span>
                  <span className="exam-time">{exam.hora_inicio.substring(0, 5)} - {exam.hora_fin.substring(0, 5)}</span>
                </div>
                <div className="exam-details">
                  <span className="exam-carrera">{exam.materia.carrera_nombre}</span>
                  <span className="exam-aula">Aula: {exam.aula.nombre}</span>
                  {exam.materia.profesor && (
                    <span className="exam-profesor">Profesor: {exam.materia.profesor.nombre}</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
};

export default ExamScheduleDisplay;
