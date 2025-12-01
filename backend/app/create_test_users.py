import sys
import os

# Agregar el directorio 'backend' a sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.database import SessionLocal, engine
from app.models import Base, User
from app.auth import get_password_hash

def create_test_users():
    """
    Crea usuarios de prueba para el sistema
    """
    # Crear todas las tablas
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # Definir los usuarios de prueba
        usuarios = [
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
            },
            {
                "username": "jefe_informatica",
                "password": "jefe123",
                "role": "jefe_carrera",
                "email": "jefe.informatica@escuela.edu.mx"
            },
            {
                "username": "jefe_enfermeria",
                "password": "enfermeria123",
                "role": "jefe_carrera",
                "email": "jefe.enfermeria@escuela.edu.mx"
            }
        ]
        
        usuarios_creados = 0
        usuarios_existentes = 0
        
        for user_data in usuarios:
            # Verificar si el usuario ya existe
            existing_user = db.query(User).filter(User.username == user_data["username"]).first()
            
            if existing_user:
                print(f"✓ Usuario '{user_data['username']}' ya existe")
                usuarios_existentes += 1
            else:
                # Crear nuevo usuario
                new_user = User(
                    username=user_data["username"],
                    hashed_password=get_password_hash(user_data["password"]),
                    role=user_data["role"],
                    email=user_data["email"],
                    is_active=1
                )
                db.add(new_user)
                print(f"✓ Usuario '{user_data['username']}' creado exitosamente")
                print(f"  - Contraseña: {user_data['password']}")
                print(f"  - Rol: {user_data['role']}")
                print(f"  - Email: {user_data['email']}")
                usuarios_creados += 1
        
        db.commit()
        
        print("\n" + "="*60)
        print(f"Resumen:")
        print(f"  - Usuarios creados: {usuarios_creados}")
        print(f"  - Usuarios existentes: {usuarios_existentes}")
        print(f"  - Total de usuarios: {usuarios_creados + usuarios_existentes}")
        print("="*60)
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error al crear usuarios: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Creando usuarios de prueba del sistema...")
    print("="*60)
    create_test_users()
