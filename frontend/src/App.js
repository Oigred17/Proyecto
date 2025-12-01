import React, { useState } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  const handleLogin = async (credentials) => {
    try {
      const API_URL = `http://${window.location.hostname}:8000/api`;

      console.log('=== LOGIN DEBUG ===');
      console.log('API URL:', API_URL);
      console.log('Username:', credentials.username);

      const formData = new URLSearchParams();
      formData.append('username', credentials.username);
      formData.append('password', credentials.password);

      console.log('Sending login request...');

      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
      });

      console.log('Response status:', response.status);

      if (!response.ok) {
        const error = await response.json();
        console.error('Login failed:', error);
        alert(error.detail || 'Credenciales incorrectas');
        return false;
      }

      const data = await response.json();
      console.log('Login successful!');
      const token = data.access_token;

      localStorage.setItem('token', token);

      // Decode token to get user info directly
      const tokenPayload = JSON.parse(atob(token.split('.')[1]));
      console.log('Token payload:', tokenPayload);

      setIsAuthenticated(true);
      setCurrentUser({
        username: tokenPayload.sub,
        role: tokenPayload.role,
        email: null,
        carrera: null
      });

      console.log('Login complete!');
      return true;
    } catch (error) {
      console.error('=== LOGIN ERROR ===');
      console.error('Error:', error);
      alert('Error al iniciar sesión. Verifique sus credenciales.');
      return false;
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
