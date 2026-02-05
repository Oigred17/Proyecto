#!/bin/bash
# Script para verificar los cambios en el contenedor Docker

echo "🔍 Verificando cambios en el contenedor..."
echo ""

# Verificar que el contenedor backend esté corriendo
if ! docker ps | grep -q backend_api; then
    echo "❌ El contenedor backend_api no está corriendo"
    echo "   Ejecuta: docker compose up -d"
    exit 1
fi

echo "✅ Contenedor backend_api está corriendo"
echo ""

# Verificar que las carreras se obtengan correctamente
echo "📋 Probando endpoint de carreras (sin filtro)..."
response=$(curl -s http://localhost:8000/api/horarios-externos/carreras | jq 'length')
echo "   Total de carreras obtenidas: $response"
echo ""

# Verificar carreras duplicadas (ej: Informática 06 y 06B)
echo "🔎 Buscando carreras con múltiples planes..."
carreras_informatica=$(curl -s http://localhost:8000/api/horarios-externos/carreras | jq '[.[] | select(.nombre | contains("INFORMÁTICA"))] | length')
echo "   Carreras de INFORMÁTICA encontradas: $carreras_informatica"
echo "   (Debería ser al menos 2: plan antiguo y nuevo)"
echo ""

echo "✅ Verificación completada"
echo ""
echo "Para ver los logs del setup.py ejecuta:"
echo "   docker logs backend_api | grep -A 20 'Carreras con múltiples planes'"
