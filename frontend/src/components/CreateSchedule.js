import React, { useEffect, useState } from 'react';
import './CreateSchedule.css';

function CreateSchedule({ onClose, onCreated, currentUser }) {
  const [carreras, setCarreras] = useState([]);
  const [materias, setMaterias] = useState([]);
  const [tipos, setTipos] = useState([]);
  const [aulas, setAulas] = useState([]);
  const [academias, setAcademias] = useState([]);
  const [profesores, setProfesores] = useState([]);
  const [grupos, setGrupos] = useState([]);

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
    observaciones: '',
    grupo_id: '',
    tiene_academias: '',
    tipo_examen_modalidad: '', // 'Escrito' o 'Digital'
    periodo_examen: '' // Periodo de examenes
  });

  // Construir la URL base dinámicamente usando el hostname actual
  const API_URL = `http://${window.location.hostname}:8000/api`;

  useEffect(() => {
    fetch(`${API_URL}/carreras`)
      .then(r => r.json())
      .then(data => {
        // Si es jefe_carrera, filtrar solo su carrera
        if (currentUser && currentUser.role === 'jefe_carrera' && currentUser.carrera) {
          const filtered = data.filter(c => c.nombre === currentUser.carrera);
          setCarreras(filtered);
          if (filtered.length > 0) {
            setForm(prev => ({ ...prev, carrera_id: filtered[0].id.toString() }));
          }
        } else {
          setCarreras(data);
        }
      })
      .catch(console.error);
    fetch(`${API_URL}/tipos_examen`)
      .then(r => r.json())
      .then(setTipos)
      .catch(console.error);
    
    // Fetch aulas
    fetch(`${API_URL}/aulas`)
      .then(r => r.json())
      .then(setAulas)
      .catch(() => setAulas([])); // Si no existe el endpoint, dejar vacío
    
    // Fetch academias
    fetch(`${API_URL}/academias`)
      .then(r => r.json())
      .then(setAcademias)
      .catch(() => setAcademias([])); // Si no existe el endpoint, dejar vacío

    // Fetch profesores (sinodales)
    fetch(`${API_URL}/profesores`)
      .then(r => r.json())
      .then(setProfesores)
      .catch(() => setProfesores([]));
  }, [currentUser]);

  useEffect(() => {
    if (form.carrera_id) {
      fetch(`${API_URL}/materias?carrera_id=${form.carrera_id}`)
        .then(r => r.json())
        .then(setMaterias)
        .catch(console.error);
      
      // Fetch grupos de la carrera
      fetch(`${API_URL}/carreras`)
        .then(r => r.json())
        .then(data => {
          const carrera = data.find(c => c.id === parseInt(form.carrera_id));
          if (carrera && carrera.grupos) {
            setGrupos(carrera.grupos);
          }
        })
        .catch(console.error);
    } else {
      setMaterias([]);
      setGrupos([]);
    }
  }, [form.carrera_id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm(prev => {
      const newForm = { ...prev, [name]: value };
      
      // Si cambia el tipo de examen (Escrito/Digital), resetear aula_id
      if (name === 'tipo_examen_modalidad') {
        newForm.aula_id = '';
      }
      
      return newForm;
    });
  };

  // Filtrar aulas según el tipo de examen
  const aulasDisponibles = form.tipo_examen_modalidad === 'Digital' 
    ? aulas.filter(a => a.tipo === 'Laboratorio')
    : form.tipo_examen_modalidad === 'Escrito'
    ? aulas.filter(a => a.tipo === 'Normal' || a.tipo === 'Sala')
    : aulas;

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validaciones según el diagrama de flujo
    if (!form.tipo_examen_modalidad) {
      alert('Por favor selecciona si el examen es Escrito o Digital');
      return;
    }
    
    if (!form.aula_id) {
      alert(`Por favor selecciona una ${form.tipo_examen_modalidad === 'Digital' ? 'Laboratorio' : 'Aula'}`);
      return;
    }
    
    // Build payload
    const payload = {
      carrera_id: form.carrera_id ? parseInt(form.carrera_id) : null,
      materia_id: parseInt(form.materia_id) || null,
      profesor_id: parseInt(form.profesor_id) || null,
      tipo_examen_id: parseInt(form.tipo_examen_id) || null,
      aula_id: parseInt(form.aula_id) || null,
      grupo_id: parseInt(form.grupo_id) || null,
      fecha: form.fecha,
      hora_inicio: form.hora_inicio,
      hora_fin: form.hora_fin,
      numero_alumnos: parseInt(form.numero_alumnos) || 0,
      observaciones: form.observaciones || `Periodo: ${form.periodo_examen || 'N/A'}, Modalidad: ${form.tipo_examen_modalidad}`
      // estado: 'creado' // El estado inicial se asigna al crear.
    };

    try {
      const res = await fetch(`${API_URL}/examenes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (!res.ok) {
        
        const msg = data && data.error ? data.error : 'Error creando examen';
        throw new Error(msg);
      }
      if (data && data.id) {
        alert('Horario creado con éxito (ID: ' + data.id + ').\n\nUna vez que completes todos los horarios de tu carrera, deberás enviar el calendario completo a la Secretaría de Escolares para su validación.');
        if (typeof onClose === 'function') onClose();
        if (typeof onCreated === 'function') onCreated(data);
        else window.location.reload();
      } else {
        
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
          <select 
            name="carrera_id" 
            value={form.carrera_id} 
            onChange={handleChange} 
            required
            disabled={currentUser && currentUser.role === 'jefe_carrera'}
          >
            <option value="">Seleccionar carrera</option>
            {carreras.map(c => <option key={c.id} value={c.id}>{c.nombre}</option>)}
          </select>

          {/* Pregunta del diagrama: ¿Tiene Academias? */}
          {form.carrera_id && academias.length > 0 && (
            <>
              <label>¿La carrera tiene Academias?</label>
              <select name="tiene_academias" value={form.tiene_academias} onChange={handleChange}>
                <option value="">Seleccionar</option>
                <option value="si">Sí</option>
                <option value="no">No</option>
              </select>
            </>
          )}

          <label>Grupo</label>
          <select name="grupo_id" value={form.grupo_id} onChange={handleChange} required>
            <option value="">Seleccionar grupo</option>
            {grupos.map(g => <option key={g.id} value={g.id}>{g.nombre_grupo}</option>)}
          </select>

          <label>Materia</label>
          <select name="materia_id" value={form.materia_id} onChange={handleChange} required>
            <option value="">Seleccionar materia</option>
            {materias.map(m => <option key={m.id} value={m.id}>{m.nombre}</option>)}
          </select>

          <label>Profesor (Sinodal)</label>
          <select name="profesor_id" value={form.profesor_id} onChange={handleChange}>
            <option value="">Seleccionar profesor</option>
            {profesores.map(p => <option key={p.id} value={p.id}>{p.nombre}</option>)}
          </select>

          <label>Tipo de Examen</label>
          <select name="tipo_examen_id" value={form.tipo_examen_id} onChange={handleChange} required>
            <option value="">Seleccionar tipo</option>
            {tipos.map(t => <option key={t.id} value={t.id}>{t.nombre}</option>)}
          </select>

          {/* Pregunta del diagrama: Examen Escrito o Digital */}
          <label>Modalidad del Examen *</label>
          <select 
            name="tipo_examen_modalidad" 
            value={form.tipo_examen_modalidad} 
            onChange={handleChange} 
            required
          >
            <option value="">Seleccionar modalidad</option>
            <option value="Escrito">Escrito</option>
            <option value="Digital">Digital</option>
          </select>

          {/* Asignar Aula o Laboratorio según el tipo */}
          {form.tipo_examen_modalidad && (
            <label>
              {form.tipo_examen_modalidad === 'Digital' ? 'Asignar Laboratorio' : 'Asignar Aula'} *
            </label>
          )}
          {form.tipo_examen_modalidad && (
            <select 
              name="aula_id" 
              value={form.aula_id} 
              onChange={handleChange} 
              required
            >
              <option value="">Seleccionar {form.tipo_examen_modalidad === 'Digital' ? 'Laboratorio' : 'Aula'}</option>
              {aulasDisponibles.map(a => (
                <option key={a.id} value={a.id}>
                  {a.nombre} {a.capacidad ? `(Cap: ${a.capacidad})` : ''}
                </option>
              ))}
            </select>
          )}

          <label>Periodo de Exámenes</label>
          <input 
            type="text" 
            name="periodo_examen" 
            value={form.periodo_examen} 
            onChange={handleChange} 
            placeholder="Ej: Enero-Junio 2024"
          />

          <label>Fecha</label>
          <input type="date" name="fecha" value={form.fecha} onChange={handleChange} required />

          <label>Hora Inicio</label>
          <input type="time" name="hora_inicio" value={form.hora_inicio} onChange={handleChange} required />

          <label>Hora Fin</label>
          <input type="time" name="hora_fin" value={form.hora_fin} onChange={handleChange} required />

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
