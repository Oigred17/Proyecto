import React, { useState, useEffect } from 'react';

function TableView({ API_URL }) {
    const [materias, setMaterias] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetch(`${API_URL}/materias`)
            .then(res => res.json())
            .then(data => {
                setMaterias(data);
                setLoading(false);
            })
            .catch(err => {
                console.error(err);
                setLoading(false);
            });
    }, [API_URL]);

    if (loading) return <div style={{ padding: '20px' }}>Cargando datos maestros...</div>;

    return (
        <div style={{ padding: '20px' }}>
            <h2>Vista de Datos Maestros (Solo Admin)</h2>
            <div style={{
                background: 'white',
                borderRadius: '8px',
                boxShadow: '0 2px 10px rgba(0,0,0,0.05)',
                overflow: 'hidden',
                marginTop: '20px'
            }}>
                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <thead style={{ background: '#f8fafc', borderBottom: '2px solid #e2e8f0' }}>
                        <tr>
                            <th style={{ padding: '12px', textAlign: 'left' }}>Materia</th>
                            <th style={{ padding: '12px', textAlign: 'left' }}>Carrera</th>
                            <th style={{ padding: '12px', textAlign: 'left' }}>Profesor</th>
                            <th style={{ padding: '12px', textAlign: 'left' }}>ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        {materias.map(m => (
                            <tr key={m.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                                <td style={{ padding: '12px' }}>{m.nombre}</td>
                                <td style={{ padding: '12px' }}>{m.carrera_nombre}</td>
                                <td style={{ padding: '12px' }}>{m.profesor?.nombre || 'N/A'}</td>
                                <td style={{ padding: '12px', color: '#64748b' }}>{m.id}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

export default TableView;
