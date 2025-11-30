import sys
import os

# Agregar el directorio 'backend' a sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.database import SessionLocal, engine
from app.models import Base, User
from app.auth import get_password_hash

def create_initial_users():
    """
    Crea los tres usuarios iniciales del sistema:
    - servicios escolares
    - jefe de carrera
    - secretaria
    """
    # Crear todas las tablas
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # Definir los usuarios iniciales
        usuarios_iniciales = [
            {
                "username": "servicios_escolares",
                "password": "servicios123",
                "role": "servicios_escolares",
                "email": "servicios@escuela.edu.mx"
            },
            {
                "username": "jefe_carrera",
                "password": "jefe123",
                "role": "jefe_carrera",
                "email": "jefe@escuela.edu.mx"
            },
            {
                "username": "secretaria",
                "password": "secretaria123",
                "role": "secretaria",
                "email": "secretaria@escuela.edu.mx"
            }
        ]
        
        usuarios_creados = 0
        usuarios_existentes = 0
        
        for user_data in usuarios_iniciales:
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
        
        if usuarios_creados > 0:
            print("\n⚠️  IMPORTANTE: Cambia las contraseñas después del primer inicio de sesión")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error al crear usuarios: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Creando usuarios iniciales del sistema...")
    print("="*60)
    create_initial_users()
