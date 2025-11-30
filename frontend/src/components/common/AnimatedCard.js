import React from 'react';
import './AnimatedCard.css';

function AnimatedCard({ children, className = '', delay = 0 }) {
  return (
    <div 
      className={`animated-card ${className}`}
      style={{ animationDelay: `${delay}ms` }}
    >
      {children}
    </div>
  );
}

export default AnimatedCard;

