#!/bin/bash

# Nombre del contenedor definido en docker-compose.yml
CONTAINER_NAME="proyecto_db"
DB_USER="proj_user"
DB_NAME="proyecto_db"
OUTPUT_FILE="backup_full.sql"

echo "Generando respaldo de la base de datos '$DB_NAME' del contenedor '$CONTAINER_NAME'..."

# Verificar si el contenedor está corriendo
if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Error: El contenedor '$CONTAINER_NAME' no está corriendo. Asegúrate de ejecutar 'docker-compose up -d' primero."
    exit 1
fi

# Ejecutar pg_dump
docker exec $CONTAINER_NAME pg_dump -h localhost -p 9003 -U $DB_USER $DB_NAME > $OUTPUT_FILE

if [ $? -eq 0 ]; then
    echo "Respaldo exitoso: $OUTPUT_FILE"
else
    echo "Error al generar el respaldo."
    exit 1
fi
