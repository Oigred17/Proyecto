/**
 * Componente principal de la aplicación.
 * Maneja la autenticación y renderiza Login o Dashboard según el estado.
 */
import React, { useState } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  const handleLogin = async (credentials) => {
    try {
      const API_URL = `http://${window.location.hostname}:9000/api`;

      const formData = new URLSearchParams();
      formData.append('username', credentials.username);
      formData.append('password', credentials.password);

      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
      });

      if (!response.ok) {
        const error = await response.json();
        return { success: false, message: error.detail || 'Credenciales incorrectas' };
      }

      const data = await response.json();
      const token = data.access_token;

      localStorage.setItem('token', token);

      const tokenPayload = JSON.parse(atob(token.split('.')[1]));
      const carrera = data.user?.carrera || tokenPayload.carrera || null;

      setIsAuthenticated(true);
      setCurrentUser({
        username: tokenPayload.sub,
        role: tokenPayload.role,
        email: data.user?.email || null,
        carrera: carrera
      });

      return { success: true };
    } catch (error) {
      console.error('Error al iniciar sesión:', error);
      return { success: false, message: 'Error de conexión con el servidor' };
    }
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setCurrentUser(null);
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
