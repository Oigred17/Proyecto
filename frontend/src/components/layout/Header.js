import React, { useState, useEffect, useRef } from 'react';
import './Header.css';

function Header({ onMenuToggle, currentUser, onLogout, notifications, onMarkAsRead }) {
  const [showNotifications, setShowNotifications] = useState(false);
  const dropdownRef = useRef(null);

  // Cerrar el menú al hacer clic fuera
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setShowNotifications(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const getRelativeTime = (dateStr) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffInMs = now - date;
    const diffInMins = Math.floor(diffInMs / (1000 * 60));
    const diffInHours = Math.floor(diffInMs / (1000 * 60 * 60));
    const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

    if (diffInMins < 1) return 'hace un momento';
    if (diffInMins < 60) return `hace ${diffInMins} min`;
    if (diffInHours < 24) return `hace ${diffInHours} horas`;
    return `hace ${diffInDays} días`;
  };

  const getIconForType = (type) => {
    const iconProps = { width: 20, height: 20, fill: "none", stroke: "currentColor", strokeWidth: 2 };
    switch (type) {
      case 'aprobacion':
        return <svg {...iconProps} className="status-success"><polyline points="20 6 9 17 4 12"></polyline></svg>;
      case 'rechazo':
        return <svg {...iconProps} className="status-error"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>;
      case 'envio_revision':
        return <svg {...iconProps} className="status-info"><polyline points="16 16 12 12 8 16"></polyline><line x1="12" y1="12" x2="12" y2="21"></line><path d="M20.39 18.39A5 5 0 0 0 18 9h-1.26A8 8 0 1 0 3 16.3"></path><polyline points="16 16 12 12 8 16"></polyline></svg>;
      default:
        return <svg {...iconProps}><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>;
    }
  };

  return (
    <header className="dashboard-header">
      <div className="header-left">
        <button className="menu-button" onClick={onMenuToggle}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="3" y1="12" x2="21" y2="12" />
            <line x1="3" y1="6" x2="21" y2="6" />
            <line x1="3" y1="18" x2="21" y2="18" />
          </svg>
        </button>
        <h1 className="header-title">Calendarios de Exámenes</h1>
      </div>

      <div className="header-right">
        <div className="notification-wrapper" ref={dropdownRef}>
          <button
            className={`notification-icon ${showNotifications ? 'active' : ''}`}
            onClick={() => setShowNotifications(!showNotifications)}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
              <path d="M13.73 21a2 2 0 0 1-3.46 0" />
            </svg>
            {notifications && notifications.length > 0 && (
              <span className="notification-badge">{notifications.length}</span>
            )}
          </button>

          {showNotifications && (
            <div className="notifications-dropdown">
              <div className="dropdown-header">
                <h3>Notificaciones</h3>
                <button className="settings-btn">
                  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                </button>
              </div>
              <div className="dropdown-content">
                {notifications && notifications.length > 0 ? (
                  notifications.map(notif => (
                    <div key={notif.id} className="notification-item" onClick={() => {
                      onMarkAsRead(notif.id);
                      // Opcional: navegar a la vista correspondiente
                    }}>
                      <div className="item-avatar">
                        {getIconForType(notif.tipo)}
                      </div>
                      <div className="item-body">
                        <p className="item-message">{notif.mensaje}</p>
                        <span className="item-time">{getRelativeTime(notif.fecha_creacion)}</span>
                      </div>
                      {!notif.leida && <div className="unread-dot"></div>}
                    </div>
                  ))
                ) : (
                  <div className="no-notifications">
                    <p>No tienes notificaciones nuevas</p>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        <div className="user-profile">
          <div className="user-avatar">
            {currentUser && currentUser.username ? currentUser.username.substring(0, 2).toUpperCase() : 'NH'}
          </div>
          <span>{currentUser && currentUser.username ? currentUser.username : 'Usuario'}</span>
        </div>

        <select className="group-select">
          <option>Grupo de Desarrollo</option>
        </select>

        <button className="logout-button" onClick={onLogout}>
          <span>Cerrar Sesión</span>
        </button>
      </div>
    </header>
  );
}

export default Header;
