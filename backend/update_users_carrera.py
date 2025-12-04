#!/usr/bin/env python3
"""
Script para actualizar usuarios jefe_carrera con su carrera
"""
import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app.database import engine, SessionLocal
from app.models import User
from sqlalchemy import inspect, text

def update_users():
    """Actualiza usuarios jefe_carrera con su carrera"""
    db = SessionLocal()
    try:
        # Verificar si la columna carrera existe
        inspector = inspect(engine)
        columns = [col['name'] for col in inspector.get_columns('users')]
        
        if 'carrera' not in columns:
            print("Agregando columna 'carrera' a la tabla 'users'...")
            db.execute(text("ALTER TABLE users ADD COLUMN carrera VARCHAR"))
            db.commit()
            print("✓ Columna 'carrera' agregada")
        
        # Mapeo de usernames a carreras
        carrera_map = {
            'jefe_informatica': 'Licenciatura en Informática',
            'jefe_enfermeria': 'Licenciatura en Enfermería',
            'jefe_contaduria': 'Licenciatura en Contaduría',
        }
        
        # Actualizar usuarios jefe_carrera
        jefe_users = db.query(User).filter(User.role == 'jefe_carrera').all()
        updated = 0
        
        for user in jefe_users:
            if not user.carrera and user.username in carrera_map:
                user.carrera = carrera_map[user.username]
                print(f"✓ Actualizado {user.username} -> {user.carrera}")
                updated += 1
            elif user.carrera:
                print(f"  {user.username} ya tiene carrera: {user.carrera}")
        
        db.commit()
        print(f"\n✓ {updated} usuarios actualizados")
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    print("=" * 50)
    print("Actualizando usuarios con carrera")
    print("=" * 50)
    success = update_users()
    print("=" * 50)
    if success:
        print("Actualización completada")
    else:
        print("Actualización falló")

