import React, { useState } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  const handleLogin = (credentials) => {
    // Aquí puedes agregar lógica de autenticación real
    console.log('Login attempt:', credentials);
    setIsAuthenticated(true);
    // Guardar información del usuario
    setCurrentUser({
      username: credentials.username,
      role: credentials.role || 'usuario'
    });
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setCurrentUser(null);
    // Limpiar localStorage si se usa
    localStorage.removeItem('token');
  };

  return (
    <div className="App">
      {!isAuthenticated ? (
        <Login onLogin={handleLogin} />
      ) : (
        <Dashboard currentUser={currentUser} onLogout={handleLogout} />
      )}
    </div>
  );
}

export default App;
