import React, { useState } from 'react';
import './Login.css';

function Login({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    // Simular delay de autenticación
    await new Promise(resolve => setTimeout(resolve, 500));

    if (onLogin) {
      onLogin({ username, password });
    }

    setIsSubmitting(false);
  };

  return (
    <div className="login-container">
      {/* Left Side - Logo */}
      <div className="login-left">
        <div className="illustration">
          <img src="/logounsis.png" alt="Universidad de la Sierra Sur" className="university-logo-img" />
        </div>
      </div>

      {/* Right Side - Login Form */}
      <div className="login-right">
        <div className="login-form-container">
          <h1 className="login-title">Login</h1>

          <form onSubmit={handleSubmit} className="login-form">
            <div className="form-group">
              <label htmlFor="username">Username</label>
              <div className="input-wrapper">
                <input
                  id="username"
                  type="text"
                  placeholder="Enter your username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="password">Password</label>
              <div className="input-wrapper">
                <input
                  id="password"
                  type="password"
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <a href="#forgot" className="forgot-password">Forgot Password?</a>
            </div>

            <button
              type="submit"
              className={`login-button ${isSubmitting ? 'submitting' : ''}`}
              disabled={isSubmitting}
            >
              {isSubmitting ? 'Logging in...' : 'Login to Wifi'}
            </button>
          </form>

          <div className="terms-link">
            <a href="#terms">Terms and Services</a>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;
