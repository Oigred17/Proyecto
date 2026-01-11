import sys
import os

# Agregar el directorio 'backend' a sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from src.configuracion.base_datos import SessionLocal, engine
from src.compartido.modelos_base import Base
from src.autenticacion.modelos import User
from src.autenticacion.seguridad import obtener_hash_password

def crear_usuarios_prueba():
    """
    Crea usuarios de prueba para el sistema
    """
    db = SessionLocal()
    
    try:
        # 1. Crear usuarios fijos
        fijos = [
            {
                "username": "admin",
                "password": "admin123",
                "role": "administrador",
                "email": "admin@escuela.edu.mx"
            },
            {
                "username": "escolares",
                "password": "escolares123",
                "role": "servicios_escolares",
                "email": "escolares@escuela.edu.mx"
            }
        ]
        
        usuarios_creados = 0
        usuarios_existentes = 0
        
        for u_data in fijos:
            existing = db.query(User).filter(User.username == u_data["username"]).first()
            if not existing:
                new_u = User(
                    username=u_data["username"],
                    hashed_password=obtener_hash_password(u_data["password"]),
                    role=u_data["role"],
                    email=u_data["email"],
                    is_active=1
                )
                db.add(new_u)
                usuarios_creados += 1
                print(f"✓ Usuario '{u_data['username']}' creado")
            else:
                usuarios_existentes += 1
        
        # 2. Crear Jefes de Carrera dinámicos
        from sqlalchemy import text
        res = db.execute(text("SELECT nombre FROM carreras")).fetchall()
        carreras = [r[0] for r in res]
        
        prefijos = {
            "Licenciatura en Informática": "jefe_informatica",
            "Licenciatura en Administración Municipal": "jefe_municipal",
            "Licenciatura en Administración Pública": "jefe_publica"
        }
        
        for name in carreras:
            username = prefijos.get(name)
            if not username:
                clean = name.lower().replace("licenciatura en ", "").replace(" ", "_")
                username = f"jefe_{clean}"
            
            existing = db.query(User).filter(User.username == username).first()
            if not existing:
                new_jefe = User(
                    username=username,
                    hashed_password=obtener_hash_password("jefe123"),
                    role="jefe_carrera",
                    email=f"{username}@escuela.edu.mx",
                    carrera=name,
                    is_active=1
                )
                db.add(new_jefe)
                usuarios_creados += 1
                print(f"✓ Usuario {username} creado para {name}")
            else:
                usuarios_existentes += 1
                # Asegurar que tenga la carrera correcta si ya existe
                if existing.carrera != name:
                    existing.carrera = name
                    print(f"Updated {username} career to {name}")
        
        db.commit()
        
        print("\n" + "="*60)
        print(f"Resumen:")
        print(f"  - Usuarios creados: {usuarios_creados}")
        print(f"  - Usuarios existentes: {usuarios_existentes}")
        print(f"  - Total de usuarios: {usuarios_creados + usuarios_existentes}")
        print("="*60)
        
    except Exception as e:
        db.rollback()
        print(f" Error al crear usuarios: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Creando usuarios de prueba del sistema...")
    print("="*60)
    crear_usuarios_prueba()
