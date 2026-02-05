#!/bin/bash

# Configuración
CONTAINER_DB="proyecto_db"
DB_USER="proj_user"
DB_NAME="proyecto_db"
BACKUP_FILE="backup_full.sql"

echo "=== Restaurando Base de Datos desde $BACKUP_FILE ==="

# 1. Verificar si el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: No se encuentra el archivo $BACKUP_FILE en la carpeta actual."
    exit 1
fi

# 2. Verificar si el contenedor está corriendo
if [ ! "$(docker ps -q -f name=$CONTAINER_DB)" ]; then
    echo "El contenedor $CONTAINER_DB no está corriendo. Iniciando servicios..."
    docker compose up -d
    echo "Esperando 10 segundos a que la base de datos acepte conexiones..."
    sleep 10
fi

# 3. Restaurar
echo "Ejecutando restauración..."
# Usamos -i para modo interactivo sin TTY, evitando errores de 'the input device is not a TTY'
cat $BACKUP_FILE | docker exec -i $CONTAINER_DB psql -U $DB_USER -d $DB_NAME

if [ $? -eq 0 ]; then
    echo "=== ¡Restauración Completada Exitosamente! ==="
else
    echo "Error durante la restauración."
    exit 1
fi
