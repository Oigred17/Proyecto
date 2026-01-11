#!/usr/bin/env python3
"""
Script para verificar los datos en la base de datos
"""
import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from src.configuracion.base_datos import SessionLocal
from src.autenticacion.modelos import User
from sqlalchemy import text

def verificar_datos():
    """Verifica los datos en la base de datos"""
    db = SessionLocal()
    try:
        # Verificar usuarios
        users = db.query(User).all()
        print("\n" + "=" * 80)
        print(" USUARIOS CREADOS")
        print("=" * 80)
        print(f"Total de usuarios: {len(users)}")
        for user in users:
            print(f"  - Usuario: {user.username}")
            print(f"    Rol: {user.role}")
            print(f"    Email: {user.email}")
            if hasattr(user, 'carrera') and user.carrera:
                print(f"    Carrera: {user.carrera}")
            print()
        
        # Verificar carreras
        carreras_count = db.execute(text("SELECT COUNT(*) FROM carreras")).scalar()
        print("=" * 80)
        print(f" CARRERAS: {carreras_count}")
        print("=" * 80)
        
        if carreras_count > 0:
            carreras = db.execute(text("SELECT id, nombre FROM carreras")).fetchall()
            for carrera in carreras:
                print(f"  - {carrera[1]}")
            print()
        
        # Verificar profesores
        profesores_count = db.execute(text("SELECT COUNT(*) FROM profesores")).scalar()
        print(f" PROFESORES: {profesores_count}")
        print("=" * 80)
        
        # Verificar materias
        materias_count = db.execute(text("SELECT COUNT(*) FROM materias")).scalar()
        print(f" MATERIAS: {materias_count}")
        print("=" * 80)
        
        # Verificar grupos
        grupos_count = db.execute(text("SELECT COUNT(*) FROM grupos")).scalar()
        print(f" GRUPOS: {grupos_count}")
        print("=" * 80)
        
        # Verificar horarios
        horarios_count = db.execute(text("SELECT COUNT(*) FROM horarios")).scalar()
        print(f" HORARIOS: {horarios_count}")
        print("=" * 80)
        
        print("\n✓ Verificación completada")
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    verificar_datos()
