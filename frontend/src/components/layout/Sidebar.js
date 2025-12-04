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
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
              <line x1="16" y1="2" x2="16" y2="6" />
              <line x1="8" y1="2" x2="8" y2="6" />
              <line x1="3" y1="10" x2="21" y2="10" />
            </svg>
            <span className="sidebar-label">Calendario</span>
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
          <div
            className={`sidebar-icon ${activeView === 'Rechazados' ? 'active' : ''}`}
            onClick={() => onSelectView('Rechazados')}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17" />
            </svg>
            <span className="sidebar-label">Rechazados</span>
          </div>

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
            <span className="sidebar-label">Tabla</span>
          </div>
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

