#!/usr/bin/env python3
"""
Script para inicializar completamente el sistema:
1. Crear las tablas de la base de datos
2. Crear usuarios de prueba
3. Poblar datos de horarios, carreras, materias, etc.
"""

import sys
import os

# Agregar el directorio 'backend' a sys.path
sys.path.insert(0, os.path.dirname(__file__))

from src.configuracion.base_datos import engine, SessionLocal
from src.compartido.modelos_base import Base
from src.configuracion.inicializacion import inicializar_base_datos
from src.configuracion.crear_usuarios_prueba import crear_usuarios_prueba
from src.configuracion.poblar_datos import poblar

def main():
    """
    Inicializa el sistema completo
    """
    print("=" * 80)
    print(" INICIALIZANDO SISTEMA DE GESTIÓN ESCOLAR")
    print("=" * 80)
    print()
    
    # Paso 1: Crear tablas
    print("=" * 80)
    print(" PASO 1: Creando tablas de la base de datos")
    print("=" * 80)
    try:
        Base.metadata.create_all(bind=engine)
        print("✓ Tablas creadas exitosamente")
    except Exception as e:
        print(f"✗ Error al crear tablas: {e}")
        return False
    print()
    
    # Paso 2: Inicializar base de datos (agregar columnas adicionales si es necesario)
    print("=" * 80)
    print(" PASO 2: Inicializando base de datos (migraciones)")
    print("=" * 80)
    try:
        inicializar_base_datos()
        print("✓ Base de datos inicializada exitosamente")
    except Exception as e:
        print(f"✗ Error al inicializar base de datos: {e}")
        return False
    print()
    
    # Paso 3: Poblar datos de horarios y carreras
    print("=" * 80)
    print(" PASO 3: Poblando datos de horarios y carreras")
    print("=" * 80)
    try:
        poblar()
        print("✓ Datos poblados exitosamente")
    except Exception as e:
        print(f"✗ Error al poblar datos: {e}")
        return False
    print()
    
    # Paso 4: Crear usuarios de prueba
    print("=" * 80)
    print(" PASO 4: Creando usuarios de prueba")
    print("=" * 80)
    try:
        crear_usuarios_prueba()
    except Exception as e:
        print(f"✗ Error al crear usuarios: {e}")
        return False
    print()
    
    # Resumen final
    print("=" * 80)
    print(" ✓ SISTEMA INICIALIZADO EXITOSAMENTE")
    print("=" * 80)
    print()
    print("Usuarios de prueba creados:")
    print("  - admin / admin123 (Administrador)")
    print("  - escolares / escolares123 (Servicios Escolares)")
    print("  - jefe_[carrera] / jefe123 (Jefes de Carrera para cada carrera detectada)")
    print()
    print("Los datos de horarios de clase, carreras, materias, profesores, grupos y aulas")
    print("han sido poblados correctamente.")
    print()
    print("=" * 80)
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
