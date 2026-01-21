from sqlalchemy import inspect, text
from .base_datos import engine, SessionLocal
from ..autenticacion.modelos import User

def inicializar_base_datos():
    """Inicializa la base de datos agregando columnas faltantes si es necesario"""
    db = SessionLocal()
    try:
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        print(f"[INIT DB] Tablas encontradas: {tables}")
        
        # Verificar tabla examenes y columnas nuevas
        if 'examenes' in tables:
            columns = [col['name'] for col in inspector.get_columns('examenes')]
            columns_to_add = {
                'sinodal_id': "INTEGER",
                'status': "VARCHAR(50) DEFAULT 'borrador'",
                'comentarios_rechazo': "TEXT",
                'fecha_envio': "DATE",
                'fecha_aprobacion': "DATE",
                'academia_id': "INTEGER"
            }

            for col_name, col_type in columns_to_add.items():
                if col_name not in columns:
                    print(f"[INIT DB] Agregando columna {col_name} a examenes...")
                    try:
                        db.execute(text(f"ALTER TABLE examenes ADD COLUMN {col_name} {col_type}"))
                        db.commit()
                    except Exception as e:
                        print(f"[INIT DB] ERROR al agregar {col_name}: {e}")
                        db.rollback()

        # Verificar tabla users y columnas nuevas
        if 'users' in tables:
            user_columns = [col['name'] for col in inspector.get_columns('users')]
            if 'carrera' not in user_columns:
                print("[INIT DB] Agregando columna carrera a users...")
                try:
                    db.execute(text("ALTER TABLE users ADD COLUMN carrera VARCHAR"))
                    db.commit()
                    
                    # Actualizar usuarios jefe_carrera existentes
                    carrera_map = {
                        'jefe_informatica': 'Licenciatura en Informática',
                        'jefe_enfermeria': 'Licenciatura en Enfermería',
                        'jefe_contaduria': 'Licenciatura en Contaduría',
                    }
                    
                    jefe_users = db.query(User).filter(User.role == 'jefe_carrera').all()
                    for user in jefe_users:
                        if user.username in carrera_map:
                            user.carrera = carrera_map[user.username]
                    db.commit()
                except Exception as e:
                    print(f"[INIT DB] ERROR al agregar carrera: {e}")
                    db.rollback()

        # Verificar tabla notificaciones y columnas nuevas
        if 'notificaciones' in tables:
            columns = [col['name'] for col in inspector.get_columns('notificaciones')]
            if 'carrera' not in columns:
                print("[INIT DB] Agregando columna carrera a notificaciones...")
                try:
                    db.execute(text("ALTER TABLE notificaciones ADD COLUMN carrera VARCHAR"))
                    db.commit()
                except Exception as e:
                    print(f"[INIT DB] ERROR al agregar carrera a notificaciones: {e}")
                    db.rollback()

        # Verificar tabla materias y columnas nuevas
        if 'materias' in tables:
            materia_columns = [col['name'] for col in inspector.get_columns('materias')]
            if 'academia_id' not in materia_columns:
                print("[INIT DB] Agregando columna academia_id a materias...")
                try:
                    db.execute(text("ALTER TABLE materias ADD COLUMN academia_id INTEGER"))
                    db.commit()
                except Exception as e:
                    print(f"[INIT DB] ERROR al agregar academia_id a materias: {e}")
                    db.rollback()
                    
    except Exception as e:
        print(f"[INIT DB] ERROR general: {e}")
        db.rollback()
    finally:
        db.close()
