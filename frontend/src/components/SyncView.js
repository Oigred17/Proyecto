import React, { useState, useEffect, useRef } from 'react';

function SyncView({ API_URL, showToast }) {
    const [status, setStatus] = useState({
        running: false,
        progress: 0,
        last_log: 'Esperando inicio...',
        logs: [],
        error: null,
        finished: false
    });
    const logContainerRef = useRef(null);
    const [polling, setPolling] = useState(false);

    // Auto-scroll logs
    useEffect(() => {
        if (logContainerRef.current) {
            logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
        }
    }, [status.logs]);

    // Polling effect
    useEffect(() => {
        let interval;
        if (polling || status.running) {
            interval = setInterval(async () => {
                try {
                    const res = await fetch(`${API_URL}/sincronizar/status`);
                    if (res.ok) {
                        const data = await res.json();
                        setStatus(data);
                        if (!data.running && data.finished) {
                            setPolling(false);
                            if (data.error) showToast(data.error, 'error');
                            else showToast('Sincronización finalizada correctamente', 'success');
                        }
                    }
                } catch (err) {
                    console.error("Polling error:", err);
                }
            }, 1000);
        }
        return () => clearInterval(interval);
    }, [polling, status.running, API_URL, showToast]);

    const handleSync = async () => {
        if (status.running) return;

        try {
            const res = await fetch(`${API_URL}/sincronizar`, { method: 'POST' });
            if (res.ok) {
                setPolling(true);
                showToast('Iniciando conexión con el core...', 'info');
            } else {
                showToast('No se pudo iniciar la sincronización', 'error');
            }
        } catch (err) {
            showToast('Error de conexión', 'error');
        }
    };

    return (
        <div className="sync-view" style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto', animation: 'fadeIn 0.5s ease-out' }}>
            <div className="sync-card" style={{
                background: 'white',
                padding: '40px',
                borderRadius: '24px',
                boxShadow: '0 20px 50px rgba(0,0,0,0.04)',
                border: '1px solid #f1f5f9',
                position: 'relative',
                overflow: 'hidden'
            }}>
                {/* Background Accent */}
                <div style={{
                    position: 'absolute',
                    top: 0,
                    right: 0,
                    width: '300px',
                    height: '300px',
                    background: 'radial-gradient(circle, rgba(37, 99, 235, 0.03) 0%, transparent 70%)',
                    zIndex: 0
                }}></div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '48px', position: 'relative', zIndex: 1 }}>
                    <div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
                            <div style={{
                                background: '#eff6ff',
                                padding: '10px',
                                borderRadius: '12px',
                                color: '#2563eb'
                            }}>
                                <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                                    <polyline points="17 8 12 3 7 8"></polyline>
                                    <line x1="12" y1="3" x2="12" y2="15"></line>
                                </svg>
                            </div>
                            <h2 style={{ margin: 0, color: '#0f172a', fontSize: '32px', fontWeight: '800', letterSpacing: '-0.5px' }}>Sincronización de Datos</h2>
                        </div>
                        <p style={{ margin: 0, color: '#64748b', fontSize: '16px', maxWidth: '500px', lineHeight: '1.6' }}>
                            Actualiza la base de datos local con la información más reciente del sistema central académico.
                        </p>
                    </div>

                    <button
                        onClick={handleSync}
                        disabled={status.running}
                        style={{
                            background: status.running ? '#94a3b8' : 'linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%)',
                            color: 'white',
                            border: 'none',
                            padding: '16px 32px',
                            borderRadius: '16px',
                            fontWeight: '700',
                            fontSize: '16px',
                            cursor: status.running ? 'not-allowed' : 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '12px',
                            transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                            boxShadow: status.running ? 'none' : '0 10px 25px rgba(37, 99, 235, 0.2)',
                            transform: status.running ? 'none' : 'translateY(0)'
                        }}
                        onMouseEnter={(e) => !status.running && (e.currentTarget.style.transform = 'translateY(-2px)')}
                        onMouseLeave={(e) => !status.running && (e.currentTarget.style.transform = 'translateY(0)')}
                    >
                        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" strokeWidth="2.5" className={status.running ? 'spin' : ''}>
                            <path d="M23 4v6h-6M1 20v-6h6M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
                        </svg>
                        {status.running ? 'Sincronizando...' : 'Actualizar Ahora'}
                    </button>
                </div>

                {/* Main Progress Metric */}
                <div style={{
                    background: '#f8fafc',
                    padding: '32px',
                    borderRadius: '20px',
                    marginBottom: '40px',
                    border: '1px solid #e2e8f0'
                }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px', alignItems: 'flex-end' }}>
                        <div>
                            <span style={{
                                display: 'block',
                                color: '#64748b',
                                fontSize: '14px',
                                fontWeight: '600',
                                textTransform: 'uppercase',
                                letterSpacing: '0.05em',
                                marginBottom: '4px'
                            }}>
                                Estado del Proceso
                            </span>
                            <span style={{ fontWeight: '800', color: '#0f172a', fontSize: '20px' }}>
                                {status.running ? 'Ejecutando tareas de red...' : status.finished ? 'Sincronización Exitosa' : 'Sistema en Espera'}
                            </span>
                        </div>
                        <div style={{ textAlign: 'right' }}>
                            <span style={{ fontWeight: '900', color: '#2563eb', fontSize: '36px', lineHeight: '1' }}>{status.progress}%</span>
                        </div>
                    </div>

                    <div style={{
                        height: '12px',
                        background: '#e2e8f0',
                        borderRadius: '10px',
                        overflow: 'hidden',
                        position: 'relative'
                    }}>
                        <div style={{
                            width: `${status.progress}%`,
                            height: '100%',
                            background: 'linear-gradient(90deg, #2563eb, #60a5fa)',
                            borderRadius: '10px',
                            transition: 'width 1s cubic-bezier(0.65, 0, 0.35, 1)',
                            position: 'relative'
                        }}>
                            {status.running && <div className="shimmer"></div>}
                        </div>
                    </div>
                </div>

                {/* Activity Monitor */}
                <div style={{ position: 'relative' }}>
                    <div style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        marginBottom: '16px',
                        padding: '0 4px'
                    }}>
                        <h3 style={{ margin: 0, fontSize: '15px', color: '#475569', fontWeight: '700' }}>Monitor de Actividad</h3>
                        {status.running && (
                            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <div className="pulse-dot"></div>
                                <span style={{ fontSize: '12px', color: '#2563eb', fontWeight: '600' }}>EN VIVO</span>
                            </div>
                        )}
                    </div>

                    <div
                        ref={logContainerRef}
                        style={{
                            background: '#0f172a',
                            padding: '24px',
                            borderRadius: '20px',
                            height: '380px',
                            overflowY: 'auto',
                            fontFamily: '"JetBrains Mono", "Fira Code", monospace',
                            fontSize: '13px',
                            lineHeight: '1.8',
                            color: '#cbd5e1',
                            boxShadow: 'inset 0 2px 10px rgba(0,0,0,0.2)',
                            border: '1px solid #1e293b'
                        }}
                    >
                        {status.logs.length === 0 && (
                            <div style={{ color: '#475569', textAlign: 'center', marginTop: '140px' }}>
                                <p>No hay actividad registrada actualmente</p>
                            </div>
                        )}

                        {status.logs.map((log, i) => {
                            const isError = log.toLowerCase().includes('error');
                            const isSuccess = log.includes('✓') || log.includes('EXITO') || log.includes('LISTO');
                            const isWarning = log.toLowerCase().includes('advertencia');

                            return (
                                <div key={i} style={{
                                    marginBottom: '8px',
                                    padding: '4px 8px',
                                    borderRadius: '6px',
                                    background: isError ? 'rgba(239, 68, 68, 0.1)' : 'transparent',
                                    borderLeft: isError ? '3px solid #ef4444' : isSuccess ? '3px solid #10b981' : '3px solid transparent',
                                    color: isError ? '#f87171' : isSuccess ? '#34d399' : isWarning ? '#fbbf24' : '#cbd5e1',
                                    transition: 'all 0.2s ease'
                                }}>
                                    <span style={{ color: '#475569', marginRight: '16px', fontSize: '11px', opacity: 0.6, userSelect: 'none' }}>
                                        {new Date().toLocaleTimeString([], { hour12: false })}
                                    </span>
                                    {log}
                                </div>
                            );
                        })}
                        {status.running && <div className="cursor">█</div>}
                        {!status.running && status.finished && (
                            <div style={{
                                margin: '20px 0 10px',
                                padding: '15px',
                                background: 'rgba(16, 185, 129, 0.1)',
                                borderRadius: '12px',
                                color: '#10b981',
                                fontWeight: '700',
                                textAlign: 'center',
                                border: '1px border #10b981'
                            }}>
                                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="3" style={{ marginRight: '10px', verticalAlign: 'middle' }}>
                                    <polyline points="20 6 9 17 4 12"></polyline>
                                </svg>
                                PROCESO COMPLETADO EXITOSAMENTE
                            </div>
                        )}
                    </div>
                </div>

                <div style={{
                    marginTop: '32px',
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                    gap: '24px',
                    borderTop: '1px solid #f1f5f9',
                    paddingTop: '32px'
                }}>
                    {[
                        { label: 'Integridad de Red', desc: 'Validación de paquetes' },
                        { label: 'Sincronización Delta', desc: 'Solo cambios recientes' },
                        { label: 'Seguridad TLS 1.3', desc: 'Canal de datos cifrado' }
                    ].map((item, idx) => (
                        <div key={idx} style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                            <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#10b981' }}></div>
                            <div>
                                <div style={{ fontSize: '13px', fontWeight: '700', color: '#0f172a' }}>{item.label}</div>
                                <div style={{ fontSize: '12px', color: '#64748b' }}>{item.desc}</div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <style>{`
                @keyframes spin {
                    from { transform: rotate(0deg); }
                    to { transform: rotate(360deg); }
                }
                .spin {
                    animation: spin 1s linear infinite;
                }
                @keyframes shimmer {
                    0% { transform: translateX(-100%); }
                    100% { transform: translateX(100%); }
                }
                .shimmer {
                    position: absolute;
                    top: 0; left: 0; width: 100%; height: 100%;
                    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
                    animation: shimmer 2s infinite;
                }
                .cursor {
                    display: inline-block;
                    animation: blink 1s infinite;
                    color: #3b82f6;
                    margin-left: 4px;
                }
                @keyframes blink {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0; }
                }
                .pulse-dot {
                    width: 8px;
                    height: 8px;
                    background: #2563eb;
                    border-radius: 50%;
                    box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.7);
                    animation: pulse 1.5s infinite;
                }
                @keyframes pulse {
                    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.7); }
                    70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(37, 99, 235, 0); }
                    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(37, 99, 235, 0); }
                }
                ::-webkit-scrollbar {
                    width: 8px;
                }
                ::-webkit-scrollbar-track {
                    background: #1e293b;
                }
                ::-webkit-scrollbar-thumb {
                    background: #334155;
                    border-radius: 10px;
                }
                ::-webkit-scrollbar-thumb:hover {
                    background: #475569;
                }
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(10px); }
                    to { opacity: 1; transform: translateY(0); }
                }
            `}</style>
        </div>

    );
}

export default SyncView;
