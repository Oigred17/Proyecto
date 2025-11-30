import React from 'react';
import './Checkbox.css';

function Checkbox({ checked, onChange, label, className = '' }) {
  return (
    <label className={`checkbox-label ${className}`}>
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}
        className="checkbox-input"
      />
      <span className="checkbox-custom"></span>
      {label && <span className="checkbox-text">{label}</span>}
    </label>
  );
}

export default Checkbox;

