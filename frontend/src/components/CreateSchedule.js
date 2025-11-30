import React, { useEffect, useState } from 'react';
import './CreateSchedule.css';

function CreateSchedule({ onClose, onCreated }) {
  const [carreras, setCarreras] = useState([]);
  const [materias, setMaterias] = useState([]);
  const [tipos, setTipos] = useState([]);

  const [form, setForm] = useState({
    carrera_id: '',
    materia_id: '',
    profesor_id: '',
    aula_id: '',
    tipo_examen_id: '',
    fecha: '',
    hora_inicio: '',
    hora_fin: '',
    numero_alumnos: 30,
    observaciones: ''
  });

  // Construir la URL base dinámicamente usando el hostname actual
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    fetch(`${API_URL}/carreras`)
      .then(r => r.json())
      .then(setCarreras)
      .catch(console.error);
    fetch(`${API_URL}/tipos_examen`)
      .then(r => r.json())
      .then(setTipos)
      .catch(console.error);
  }, []);

  useEffect(() => {
    if (form.carrera_id) {
      fetch(`${API_URL}/materias?carrera_id=${form.carrera_id}`)
        .then(r => r.json())
        .then(setMaterias)
        .catch(console.error);
    } else {
      setMaterias([]);
    }
  }, [form.carrera_id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Build payload
    const payload = {
      carrera_id: form.carrera_id ? parseInt(form.carrera_id) : null,
      materia_id: parseInt(form.materia_id) || null,
      profesor_id: parseInt(form.profesor_id) || null,
      tipo_examen_id: parseInt(form.tipo_examen_id) || null,
      aula_id: parseInt(form.aula_id) || null,
      fecha: form.fecha,
      hora_inicio: form.hora_inicio,
      hora_fin: form.hora_fin,
      numero_alumnos: parseInt(form.numero_alumnos) || 0,
      observaciones: form.observaciones
    };

    try {
      const res = await fetch(`${API_URL}/examenes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (!res.ok) {
        // try to show backend error message
        const msg = data && data.error ? data.error : 'Error creando examen';
        throw new Error(msg);
      }
      if (data && data.id) {
        alert('Horario creado (id: ' + data.id + ')');
        if (typeof onClose === 'function') onClose();
        if (typeof onCreated === 'function') onCreated(data);
        else window.location.reload();
      } else {
        // backend returned no id
        const msg = data && data.error ? data.error : 'Respuesta inesperada del servidor';
        throw new Error(msg);
      }
    } catch (err) {
      console.error(err);
      alert('Error al crear horario: ' + err.message);
    }
  };

  return (
    <div className="cs-backdrop">
      <div className="cs-modal">
        <div className="cs-header">
          <h3>Crear Horario / Examen</h3>
          <button className="cs-close" onClick={onClose}>✕</button>
        </div>
        <form className="cs-form" onSubmit={handleSubmit}>
          <label>Carrera</label>
          <select name="carrera_id" value={form.carrera_id} onChange={handleChange} required>
            <option value="">Seleccionar carrera</option>
            {carreras.map(c => <option key={c.id} value={c.id}>{c.nombre}</option>)}
          </select>

          <label>Tipo de Examen</label>
          <select name="tipo_examen_id" value={form.tipo_examen_id} onChange={handleChange} required>
            <option value="">Seleccionar tipo</option>
            {tipos.map(t => <option key={t.id} value={t.id}>{t.nombre}</option>)}
          </select>

          <label>Fecha</label>
          <input type="date" name="fecha" value={form.fecha} onChange={handleChange} required />

          <label>Número alumnos</label>
          <input type="number" name="numero_alumnos" value={form.numero_alumnos} onChange={handleChange} min="0" />

          <label>Observaciones</label>
          <textarea name="observaciones" value={form.observaciones} onChange={handleChange} />

          <div className="cs-actions">
            <button type="submit" className="cs-submit">Crear</button>
            <button type="button" className="cs-cancel" onClick={onClose}>Cancelar</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default CreateSchedule;
