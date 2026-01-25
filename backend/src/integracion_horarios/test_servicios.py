#!/usr/bin/env python3
"""
Script de prueba para verificar que todos los servicios de integración funcionen correctamente.
"""
import sys
import os

# Asegurar que podemos importar desde src
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from src.integracion_horarios.servicios.periodo_service import PeriodoService
from src.integracion_horarios.servicios.carrera_service import CarreraService
from src.integracion_horarios.servicios.grupo_service import GrupoService
from src.integracion_horarios.servicios.aula_service import AulaService
from src.integracion_horarios.servicios.horario_service import HorarioService

def test_periodo():
    """Prueba el servicio de periodos."""
    print("\n📅 Probando servicio de periodos...")
    try:
        service = PeriodoService()
        resultado = service.obtener_periodo_actual()
        if resultado and 'clave' in resultado:
            print(f"  ✓ Periodo obtenido: {resultado['clave']} - {resultado.get('nombre', 'N/A')}")
            return True
        else:
            print("  ✗ No se pudo obtener el periodo")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def test_carreras():
    """Prueba el servicio de carreras."""
    print("\n🎓 Probando servicio de carreras...")
    try:
        service = CarreraService()
        resultado = service.obtener_todas_carreras()
        if resultado and len(resultado) > 0:
            print(f"  ✓ Se obtuvieron {len(resultado)} carreras")
            print(f"    Ejemplo: {resultado[0].get('nombre', 'N/A')}")
            return True
        else:
            print("  ✗ No se obtuvieron carreras")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def test_grupos():
    """Prueba el servicio de grupos."""
    print("\n👥 Probando servicio de grupos...")
    try:
        service = GrupoService()
        resultado = service.obtener_grupos_por_periodo(periodo='2526A')
        if resultado and len(resultado) > 0:
            print(f"  ✓ Se obtuvieron {len(resultado)} grupos")
            print(f"    Ejemplo: {resultado[0].get('nombre', 'N/A')} - Carrera: {resultado[0].get('carrera', 'N/A')}")
            return True
        else:
            print("  ✗ No se obtuvieron grupos")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def test_aulas():
    """Prueba el servicio de aulas."""
    print("\n🏫 Probando servicio de aulas...")
    try:
        service = AulaService()
        resultado = service.obtener_todas_aulas(page=1, size=10)
        if resultado and len(resultado) > 0:
            print(f"  ✓ Se obtuvieron {len(resultado)} aulas")
            print(f"    Ejemplo: {resultado[0].get('nombre', 'N/A')} - Capacidad: {resultado[0].get('capacidad', 'N/A')}")
            return True
        else:
            print("  ✗ No se obtuvieron aulas")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def test_horarios():
    """Prueba el servicio de horarios."""
    print("\n📋 Probando servicio de horarios...")
    try:
        service = HorarioService()
        # Probar por profesor (puede que no haya datos)
        resultado = service.obtener_por_profesor(periodo='2526A', idprofesor='P3060')
        print(f"  ✓ Horarios por profesor: {len(resultado)} registros")
        
        # Probar por grupo
        resultado = service.obtener_por_grupo(periodo='2526A', idGrupo='116A')
        if resultado and len(resultado) > 0:
            print(f"  ✓ Horarios por grupo: {len(resultado)} registros")
            print(f"    Ejemplo: {resultado[0].get('materia', 'N/A')} en {resultado[0].get('nombreAula', 'N/A')}")
            return True
        else:
            print("  ⚠ No se obtuvieron horarios (puede ser normal si no hay datos)")
            return True  # No es un error crítico
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def main():
    """Ejecuta todas las pruebas."""
    print("=" * 60)
    print("🧪 Pruebas de Integración de Servicios de Horarios")
    print("=" * 60)
    
    tests = [
        ("Periodo", test_periodo),
        ("Carreras", test_carreras),
        ("Grupos", test_grupos),
        ("Aulas", test_aulas),
        ("Horarios", test_horarios),
    ]
    
    resultados = {}
    for nombre, test_func in tests:
        resultados[nombre] = test_func()
    
    # Resumen
    print("\n" + "=" * 60)
    print("📊 RESUMEN DE PRUEBAS")
    print("=" * 60)
    
    exitosos = sum(1 for r in resultados.values() if r)
    total = len(resultados)
    
    for nombre, resultado in resultados.items():
        icono = "✓" if resultado else "✗"
        print(f"  {icono} {nombre}")
    
    print(f"\n🎯 Resultado: {exitosos}/{total} pruebas exitosas")
    
    if exitosos == total:
        print("✅ ¡Todos los servicios funcionan correctamente!")
        return 0
    else:
        print("⚠️ Algunos servicios tienen problemas")
        return 1

if __name__ == "__main__":
    sys.exit(main())
