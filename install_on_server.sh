#!/bin/bash

# Configuración
COMPOSE_FILE="docker-compose.prod.yml"
CONTAINER_DB="proyecto_db"
DB_USER="proj_user"
DB_NAME="proyecto_db"
BACKUP_FILE="backup_full.sql"
IMAGES_FILE="app_images.tar.gz"

echo "=== Despliegue en Servidor (Modo Offline/Imágenes) ==="

# 1. Cargar Imágenes Docker
if [ -f "$IMAGES_FILE" ]; then
    echo "Cargando imágenes Docker desde $IMAGES_FILE (esto puede tardar un poco)..."
    docker load -i $IMAGES_FILE
else
    echo "Advertencia: No se encontró $IMAGES_FILE. Asumiendo que las imágenes ya existen."
fi

# 2. Iniciar Contenedores
echo "Iniciando contenedores usando $COMPOSE_FILE..."
docker compose -f $COMPOSE_FILE up -d

echo "Esperando 10 segundos a que la base de datos inicie..."
sleep 10

# 3. Restaurar Base de Datos
if [ -f "$BACKUP_FILE" ]; then
    echo "Restaurando base de datos desde $BACKUP_FILE..."
    cat $BACKUP_FILE | docker exec -i $CONTAINER_DB psql -h localhost -p 9003 -U $DB_USER -d $DB_NAME
    if [ $? -eq 0 ]; then
        echo "=== Base de datos restaurada correctamente ==="
    else
        echo "Error al restaurar la base de datos."
    fi
else
    echo "No se encontró archivo de backup para restaurar."
fi

echo "=== Despliegue Finalizado ==="
