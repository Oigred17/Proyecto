#!/bin/bash

echo "=========================================="
echo "   DIAGNÓSTICO DE CONEXIÓN Y SERVICIOS"
echo "=========================================="

echo "[1] Verificando contenedores..."
if docker ps | grep -q "frontend_app"; then
    echo "✅ Frontend container está corriendo."
else
    echo "❌ Frontend container NO está corriendo."
fi

echo ""
echo "[2] Verificando respuesta LOCAL del Frontend (en el servidor)..."
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" http://localhost:9001)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "304" ]; then
    echo "✅ El Frontend responde correctamente localmente (Código $HTTP_CODE)."
else
    echo "❌ El Frontend NO responde localmente (Código $HTTP_CODE). Revisa la configuración de Nginx."
    # Mostrar logs si falla
    echo "--- Logs recientes del frontend ---"
    docker logs --tail 20 frontend_app
fi

echo ""
echo "[3] Verificando respuesta LOCAL del Backend..."
HTTP_CODE_API=$(curl -o /dev/null -s -w "%{http_code}\n" http://localhost:9000/docs)
if [ "$HTTP_CODE_API" == "200" ]; then
    echo "✅ El Backend responde correctamente localmente."
else
    echo "❌ El Backend NO responde localmente (Código $HTTP_CODE_API)."
fi

echo ""
echo "[4] Verificando puertos escuchando (netstat)..."
if sudo netstat -tulpn | grep 9001 > /dev/null; then
    echo "✅ Puerto 9001 está siendo escuchado por un proceso:"
    sudo netstat -tulpn | grep 9001
else
    echo "❌ No se detecta proceso escuchando en 9001."
fi

echo ""
echo "[5] Estado del Firewall (UFW)..."
if command -v ufw > /dev/null; then
    sudo ufw status | grep 9001 --color=always
    if [ $? -eq 0 ]; then
         echo "✅ Regla encontrada para 9001 en UFW."
    else
         echo "⚠️ NO se encontró regla explícita para 9001 en UFW. (Si UFW está 'inactive', esto no importa)."
         echo "Estado general: $(sudo ufw status | head -n 1)"
    fi
else
    echo "ℹ️ UFW no instalado."
fi

echo ""
echo "=========================================="
echo "CONCLUSIÓN:"
echo "Si los pasos [2] y [3] tienen ✅, tu aplicación funciona."
echo "Si no puedes entrar desde tu navegador, el problema es 100% DE RED EXTERNA (Firewall de la universidad/empresa)."
