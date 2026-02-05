import React, { useState, useEffect } from 'react';
import './AcademiasView.css';

function AcademiasView({ currentUser, showToast, API_URL }) {
    const [materias, setMaterias] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isSaving, setIsSaving] = useState(false);

    // Estado local para rastrear cambios antes de guardarlos
    // Estructura: { [nombreMateria]: { hasAcademia: boolean, academiaNombre: string } }
    const [localChanges, setLocalChanges] = useState({});

    useEffect(() => {
        fetchData();
    }, [currentUser]);

    const fetchData = async (silent = false) => {
        if (!silent) setLoading(true);
        try {
            const queryParam = (currentUser && currentUser.role === 'jefe_carrera')
                ? `?carrera_codigo=${currentUser.carrera}`
                : '';

            const res = await fetch(`${API_URL}/materias${queryParam}`);
            if (res.ok) {
                const data = await res.json();
                setMaterias(data);
                // Resetear cambios locales al recargar datos frescos
                setLocalChanges({});
            }
        } catch (error) {
            console.error('Error fetching materias:', error);
            showToast('Error al cargar materias', 'error');
        } finally {
            if (!silent) setLoading(false);
        }
    };

    // Agrupar materias por semestre y nombre único
    const materiasPorSemestreYNombre = materias.reduce((acc, current) => {
        const sem = current.semestre || 'N/A';
        if (!acc[sem]) acc[sem] = {};

        const mKey = current.nombre.trim();
        if (!acc[sem][mKey]) {
            acc[sem][mKey] = {
                nombre: current.nombre,
                academia_id: current.academia_id,
                academia: current.academia,
                ids: [current.id]
            };
        } else {
            acc[sem][mKey].ids.push(current.id);
            if (current.academia_id && !acc[sem][mKey].academia_id) {
                acc[sem][mKey].academia_id = current.academia_id;
                acc[sem][mKey].academia = current.academia;
            }
        }
        return acc;
    }, {});

    const semestres = Object.keys(materiasPorSemestreYNombre).sort((a, b) => a - b);

    // Funciones para manejar cambios locales
    const handleLocalToggle = (materiaName, checked) => {
        setLocalChanges(prev => {
            const current = prev[materiaName] || {
                hasAcademia: !!materias.find(m => m.nombre === materiaName)?.academia_id,
                academiaNombre: materias.find(m => m.nombre === materiaName)?.academia?.nombre || materiaName
            };
            return {
                ...prev,
                [materiaName]: {
                    ...current,
                    hasAcademia: checked,
                    academiaNombre: checked ? current.academiaNombre : ''
                }
            };
        });
    };

    const handleLocalNameChange = (materiaName, newName) => {
        setLocalChanges(prev => {
            const current = prev[materiaName] || {
                hasAcademia: true,
                academiaNombre: newName
            };
            return {
                ...prev,
                [materiaName]: { ...current, academiaNombre: newName }
            };
        });
    };

    const handleSelectAllInSemester = (semestre, checked) => {
        const newChanges = { ...localChanges };
        Object.values(materiasPorSemestreYNombre[semestre]).forEach(mGroup => {
            newChanges[mGroup.nombre] = {
                hasAcademia: checked,
                academiaNombre: checked ? (newChanges[mGroup.nombre]?.academiaNombre || mGroup.academia?.nombre || mGroup.nombre) : ''
            };
        });
        setLocalChanges(newChanges);
    };

    const handleSaveChanges = async () => {
        const changesToApply = Object.entries(localChanges);
        if (changesToApply.length === 0) return;

        setIsSaving(true);
        try {
            const promises = [];

            for (const [mName, data] of changesToApply) {
                const mGroup = Object.values(materiasPorSemestreYNombre).flatMap(sem => Object.values(sem)).find(g => g.nombre === mName);
                if (mGroup) {
                    mGroup.ids.forEach(id => {
                        promises.push(
                            fetch(`${API_URL}/materias/${id}/academia?academia_nombre=${encodeURIComponent(data.hasAcademia ? data.academiaNombre : '')}`, {
                                method: 'PUT'
                            })
                        );
                    });
                }
            }

            await Promise.all(promises);
            showToast('Todos los cambios han sido guardados', 'success');
            await fetchData(true);
        } catch (error) {
            console.error('Error saving changes:', error);
            showToast('Error al guardar algunos cambios', 'error');
        } finally {
            setIsSaving(false);
        }
    };

    const hasChanges = Object.keys(localChanges).length > 0;

    if (loading) return <div className="loading">Cargando catálogo de materias...</div>;

    return (
        <div className="academias-view">
            <div className="view-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%' }}>
                    <div>
                        <h2>Configuración de Academias</h2>
                        <p className="subtitle">Gestión unificada por nombre de materia</p>
                    </div>
                    {hasChanges && (
                        <button
                            className="btn-save-batch"
                            onClick={handleSaveChanges}
                            disabled={isSaving}
                        >
                            {isSaving ? 'Guardando...' : `Guardar ${Object.keys(localChanges).length} cambios`}
                        </button>
                    )}
                </div>
            </div>

            <div className="table-container-master">
                {semestres.map(semestre => {
                    const materiasDelSemestre = Object.values(materiasPorSemestreYNombre[semestre]);
                    const allSelected = materiasDelSemestre.every(m => {
                        const change = localChanges[m.nombre];
                        return change ? change.hasAcademia : !!m.academia_id;
                    });

                    return (
                        <div key={semestre} className="semester-group">
                            <div className="semester-header-bar" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <h3>Semestre {semestre}</h3>
                                <label className="select-all-label">
                                    <input
                                        type="checkbox"
                                        checked={allSelected}
                                        onChange={(e) => handleSelectAllInSemester(semestre, e.target.checked)}
                                    />
                                    Seleccionar todo el semestre
                                </label>
                            </div>
                            <table className="academias-modern-table">
                                <thead>
                                    <tr>
                                        <th style={{ width: '40%' }}>Materia</th>
                                        <th style={{ width: '20%', textAlign: 'center' }}>¿Tiene Academia?</th>
                                        <th style={{ width: '40%' }}>Nombre de la Academia</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {materiasDelSemestre.map(materiaGroup => {
                                        const change = localChanges[materiaGroup.nombre];
                                        const hasAcademia = change ? change.hasAcademia : !!materiaGroup.academia_id;
                                        const academiaNombreDisplay = change ? change.academiaNombre : (materiaGroup.academia?.nombre || materiaGroup.nombre);

                                        return (
                                            <tr key={materiaGroup.nombre} className={change ? 'row-changed' : ''}>
                                                <td>
                                                    <div className="materia-main-info">
                                                        <span className="m-name">{materiaGroup.nombre}</span>
                                                        <span className="m-prof">
                                                            {materiaGroup.ids.length} grupo(s) detectado(s)
                                                        </span>
                                                    </div>
                                                </td>
                                                <td style={{ textAlign: 'center' }}>
                                                    <label className="switch">
                                                        <input
                                                            type="checkbox"
                                                            checked={hasAcademia}
                                                            onChange={(e) => handleLocalToggle(materiaGroup.nombre, e.target.checked)}
                                                        />
                                                        <span className="slider round"></span>
                                                    </label>
                                                </td>
                                                <td>
                                                    {hasAcademia ? (
                                                        <div className="academia-input-wrapper">
                                                            <input
                                                                type="text"
                                                                className="academia-name-input"
                                                                value={academiaNombreDisplay}
                                                                onChange={(e) => handleLocalNameChange(materiaGroup.nombre, e.target.value)}
                                                            />
                                                            {change && <span className="dirty-indicator">●</span>}
                                                        </div>
                                                    ) : (
                                                        <span className="academia-disabled-text">Materia Individual</span>
                                                    )}
                                                </td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

export default AcademiasView;
