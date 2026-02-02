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

# 1. Generar Backup DB
echo "=== Paso 1: Generando Backup de Base de Datos Local ==="
chmod +x ./backup_local_db.sh
./backup_local_db.sh
if [ $? -ne 0 ]; then
    echo "Fallo al crear el backup. Abortando."
    exit 1
fi

# 2. Construir y guardar imágenes Docker
echo "=== Paso 2: Preparando Imágenes Docker ==="
echo "Asegurando que las imágenes locales estén actualizadas..."
docker compose build

echo "Guardando imágenes en app_images.tar.gz (Backend, Frontend, Postgres)..."
echo "Esto puede tardar unos minutos..."
# Asumimos los nombres de imagen por defecto de docker compose o los taggeamos
# El docker-compose.prod.yml espera: proyecto-backend:latest y proyecto-frontend:latest
# Vamos a etiquetar las imágenes actuales del build
docker tag proyecto-backend proyecto-backend:latest
docker tag proyecto-frontend proyecto-frontend:latest

docker save proyecto-backend:latest proyecto-frontend:latest postgres:15-alpine | gzip > app_images.tar.gz

if [ $? -ne 0 ]; then
    echo "Error al guardar las imágenes."
    exit 1
fi
echo "Imágenes empaquetadas correctamente."

# 3. Preparar carpeta remota
echo "=== Paso 3: Preparando carpeta '$PROJECT_DIR' en el servidor ==="
ssh ${REMOTE_USER}@${SERVER_IP} "mkdir -p $DEST_PATH"

# 4. Subir al servidor
echo "=== Paso 4: Subiendo archivos a $SERVER_IP ==="
# Solo subimos lo necesario para producción: imágenes, compose prod, backup y script de instalación
scp app_images.tar.gz docker-compose.prod.yml backup_full.sql install_on_server.sh ${REMOTE_USER}@${SERVER_IP}:${DEST_PATH}/

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================"
    echo "   ¡ARCHIVOS SUBIDOS EXITOSAMENTE!   "
    echo "========================================================"
    echo ""
    echo "INSTRUCCIONES FINALES:"
    echo "1. Conéctate al servidor:"
    echo "   ssh ${REMOTE_USER}@${SERVER_IP}"
    echo ""
    echo "2. Entra a la carpeta y ejecuta el instalador:"
    echo "   cd $PROJECT_DIR"
    echo "   chmod +x install_on_server.sh"
    echo "   ./install_on_server.sh"
    echo ""
    echo "Este script cargará las imágenes, levantará los contenedores (sin build) y restaurará la DB."
    echo "========================================================"
else
    echo "Error al subir los archivos."
    exit 1
fi
