import React, { useState } from 'react';
import './Header.css';

function Header({ onMenuToggle, currentUser, onLogout }) {
  const [showNotifications, setShowNotifications] = useState(false);

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
        <div className="notification-wrapper">
          <button
            className="notification-icon"
            onClick={() => setShowNotifications(!showNotifications)}
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
              <path d="M13.73 21a2 2 0 0 1-3.46 0" />
            </svg>
            <span className="notification-badge">3</span>
          </button>
        </div>
        <div className="user-profile">
          <div className="user-avatar">
            {currentUser && currentUser.username ? currentUser.username.substring(0, 2).toUpperCase() : 'NH'}
          </div>
          <span>{currentUser && currentUser.username ? currentUser.username : 'Natalia Herrero'}</span>
        </div>
        <select className="group-select">
          <option>Grupo de Desarrollo</option>
        </select>
        <button className="plan-button" onClick={onLogout}>
          <span>Cerrar Sesión</span>
        </button>
      </div>
    </header>
  );
}

export default Header;

/* Add this to Header.css or inline style if preferred, but since we are editing JS, I will assume CSS is handled separately or I should edit CSS file. 
   Wait, I am editing JS file here. I should edit Header.css separately. 
   I will just do the JS change here. 
*/
