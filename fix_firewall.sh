#!/bin/bash

echo "=== Verificando Estado del Firewall ==="

# Intentar detectar UFW (Ubuntu/Debian)
if command -v ufw > /dev/null; then
    echo "Detectado UFW. Estado actual:"
    sudo ufw status
    
    echo ""
    echo "Intentando abrir puertos 9000 (API) y 9001 (Frontend)..."
    sudo ufw allow 9000/tcp
    sudo ufw allow 9001/tcp
    
    echo "Puertos permitidos. Recargando UFW..."
    sudo ufw reload
    echo "Estado final:"
    sudo ufw status
else
    # Si no hay UFW, intentar iptables directo
    echo "UFW no detectado. Intentando usar iptables..."
    
    # Aceptar tráfico en 9000 y 9001
    sudo iptables -I INPUT -p tcp --dport 9000 -j ACCEPT
    sudo iptables -I INPUT -p tcp --dport 9001 -j ACCEPT
    
    echo "Reglas de iptables añadidas (nota: no son persistentes al reinicio si no se guarda la config)."
fi

echo ""
echo "=== Verificando si los puertos están escuchando ==="
if command -v netstat > /dev/null; then
    netstat -tuln | grep 900
else
    ss -tuln | grep 900
fi

echo ""
echo "Si ves líneas con :::9000 y :::9001 (o 0.0.0.0:9000...), todo debería funcionar."
