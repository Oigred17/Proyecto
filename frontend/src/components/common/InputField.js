import React from 'react';
import './InputField.css';

function InputField({ 
  type = 'text', 
  placeholder, 
  value, 
  onChange, 
  icon: Icon,
  className = '' 
}) {
  return (
    <div className={`input-field-wrapper ${className}`}>
      <div className="input-group">
        {Icon && (
          <div className="input-icon">
            <Icon />
          </div>
        )}
        <input
          type={type}
          placeholder={placeholder}
          value={value}
          onChange={onChange}
          className="input-field"
        />
      </div>
    </div>
  );
}

export default InputField;
