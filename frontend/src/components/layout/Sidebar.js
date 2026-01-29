import React from 'react';
import './Sidebar.css';

function Sidebar({ activeView, onSelectView, isCollapsed, currentUser }) {
  return (
    <aside className={`sidebar ${isCollapsed ? 'collapsed' : ''}`}>
      <div className="sidebar-container">
        {/* Logo eliminado según requerimiento */}

        {/* Iconos principales - Diseño original */}
        <div className="sidebar-icons">
          <div
            className={`sidebar-icon ${activeView === 'Inicio' ? 'active' : ''}`}
            onClick={() => onSelectView('Inicio')}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
              <polyline points="9 22 9 12 15 12 15 22" />
            </svg>
            <span className="sidebar-label">Inicio</span>
          </div>
          <div
            className={`sidebar-icon ${activeView === 'Calendario' ? 'active' : ''}`}
            onClick={() => onSelectView('Calendario')}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
              <circle cx="12" cy="12" r="3" />
            </svg>
            <span className="sidebar-label">Generar</span>
          </div>
          <div
            className={`sidebar-icon ${activeView === 'Horarios' ? 'active' : ''}`}
            onClick={() => onSelectView('Horarios')}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
            <span className="sidebar-label">Horarios</span>
          </div>
          {currentUser && currentUser.role === 'jefe_carrera' && (
            <div
              className={`sidebar-icon ${activeView === 'Rechazados' ? 'active' : ''}`}
              onClick={() => onSelectView('Rechazados')}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17" />
              </svg>
              <span className="sidebar-label">Rechazados</span>
            </div>
          )}

          {currentUser && currentUser.role === 'servicios_escolares' && (
            <div
              className={`sidebar-icon ${activeView === 'Revisiones' ? 'active' : ''}`}
              onClick={() => onSelectView('Revisiones')}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
                <line x1="16" y1="17" x2="8" y2="17"></line>
                <polyline points="10 9 9 9 8 9"></polyline>
              </svg>
              <span className="sidebar-label">Revisiones</span>
            </div>
          )}

          {/* Solo mostrar Sinodal si el rol es jefe_carrera */}
          {currentUser && currentUser.role === 'jefe_carrera' && (
            <div
              className={`sidebar-icon ${activeView === 'Sinodal' ? 'active' : ''}`}
              onClick={() => onSelectView('Sinodal')}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                <circle cx="9" cy="7" r="4" />
                <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                <path d="M16 3.13a4 4 0 0 1 0 7.75" />
              </svg>
              <span className="sidebar-label">Sinodal</span>
            </div>
          )}

          {/* Mostrar Academias para jefe_carrera y administrador */}
          {currentUser && (currentUser.role === 'jefe_carrera' || currentUser.role === 'administrador') && (
            <div
              className={`sidebar-icon ${activeView === 'Academias' ? 'active' : ''}`}
              onClick={() => onSelectView('Academias')}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
              </svg>
              <span className="sidebar-label">Academias</span>
            </div>
          )}

          {/* Solo mostrar Usuarios si el rol es administrador */}
          {currentUser && currentUser.role === 'administrador' && (
            <div
              className={`sidebar-icon ${activeView === 'Usuarios' ? 'active' : ''}`}
              onClick={() => onSelectView('Usuarios')}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                <circle cx="9" cy="7" r="4" />
                <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                <path d="M16 3.13a4 4 0 0 1 0 7.75" />
              </svg>
              <span className="sidebar-label">Usuarios</span>
            </div>
          )}

          {currentUser && currentUser.role === 'administrador' && (
            <>
              <div
                className={`sidebar-icon ${activeView === 'Sincronizar' ? 'active' : ''}`}
                onClick={() => onSelectView('Sincronizar')}
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <polyline points="23 4 23 10 17 10" />
                  <polyline points="1 20 1 14 7 14" />
                  <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
                </svg>
                <span className="sidebar-label">Sincronizar</span>
              </div>
              <div
                className={`sidebar-icon ${activeView === 'Tabla' ? 'active' : ''}`}
                onClick={() => onSelectView('Tabla')}
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <rect x="3" y="3" width="18" height="18" rx="2" />
                  <line x1="3" y1="9" x2="21" y2="9" />
                  <line x1="9" y1="21" x2="9" y2="9" />
                </svg>
                <span className="sidebar-label">Tablas</span>
              </div>
            </>
          )}
          <div
            className={`sidebar-icon ${activeView === 'Archivos' ? 'active' : ''}`}
            onClick={() => onSelectView('Archivos')}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z" />
            </svg>
            <span className="sidebar-label">Archivos</span>
          </div>
        </div>
      </div>
    </aside>
  );
}

export default Sidebar;

