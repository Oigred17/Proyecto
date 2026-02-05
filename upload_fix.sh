#!/bin/bash

SERVER_IP="132.18.38.133"
PROJECT_DIR="proycal"

# Preguntar usuario
echo "Ingrese el nombre de usuario SSH para el servidor $SERVER_IP (ej. root, debian, usuario):"
read REMOTE_USER

if [ -z "$REMOTE_USER" ]; then
    echo "Usuario no puede estar vacío."
    exit 1
fi

DEST_PATH="/home/$REMOTE_USER/$PROJECT_DIR"

# Subir el script de firewall
echo "Subiendo script de corrección de firewall..."
scp fix_firewall.sh ${REMOTE_USER}@${SERVER_IP}:${DEST_PATH}/

if [ $? -eq 0 ]; then
    echo ""
    echo "Script subido. Ahora ejecuta esto en el servidor:"
    echo "1. ssh ${REMOTE_USER}@${SERVER_IP}"
    echo "2. cd $PROJECT_DIR"
    echo "3. chmod +x fix_firewall.sh"
    echo "4. ./fix_firewall.sh"
    echo ""
else
    echo "Error al subir el script."
    exit 1
fi
