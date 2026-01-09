from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session, joinedload, contains_eager
from typing import List
from datetime import date, timedelta, datetime

from . import models, schemas
from .database import SessionLocal, engine
from .auth import (
    verify_password, 
    get_password_hash, 
    create_access_token, 
    decode_access_token,
    ACCESS_TOKEN_EXPIRE_MINUTES
)

models.Base.metadata.create_all(bind=engine)

# Función para agregar columnas faltantes a la base de datos
def init_database():
    """Inicializa la base de datos agregando columnas faltantes si es necesario"""
    from sqlalchemy import inspect, text
    db = SessionLocal()
    try:
        inspector = inspect(engine)
        tables = inspector.get_table_names()
        
        print(f"[INIT DB] Tablas encontradas: {tables}")
        
        # Verificar si la tabla examenes existe
        if 'examenes' in tables:
            columns = [col['name'] for col in inspector.get_columns('examenes')]
            print(f"[INIT DB] Columnas en 'examenes': {columns}")

            # Columnas a agregar
            columns_to_add = {
                'sinodal_id': "INTEGER",
                'status': "VARCHAR(50) DEFAULT 'borrador'",
                'comentarios_rechazo': "TEXT",
                'fecha_envio': "DATE",
                'fecha_aprobacion': "DATE"
            }

            for col_name, col_type in columns_to_add.items():
                if col_name not in columns:
                    print(f"[INIT DB] Agregando columna {col_name} a la tabla examenes...")
                    try:
                        db.execute(text(f"ALTER TABLE examenes ADD COLUMN {col_name} {col_type}"))
                        db.commit()
                        print(f"[INIT DB] ✓ Columna {col_name} agregada exitosamente")
                    except Exception as e:
                        print(f"[INIT DB] ERROR al agregar {col_name}: {e}")
                        db.rollback()
                else:
                    print(f"[INIT DB] ✓ La columna {col_name} ya existe")
        else:
            print("[INIT DB] ADVERTENCIA: La tabla 'examenes' no existe aún")
        
        # Verificar si la tabla users existe y agregar columna carrera
        if 'users' in tables:
            user_columns = [col['name'] for col in inspector.get_columns('users')]
            print(f"[INIT DB] Columnas en 'users': {user_columns}")
            
            if 'carrera' not in user_columns:
                print("[INIT DB] Agregando columna carrera a la tabla users...")
                try:
                    db.execute(text("ALTER TABLE users ADD COLUMN carrera VARCHAR"))
                    db.commit()
                    print("[INIT DB] ✓ Columna carrera agregada exitosamente")
                    
                    # Actualizar usuarios jefe_carrera existentes
                    carrera_map = {
                        'jefe_informatica': 'Licenciatura en Informática',
                        'jefe_enfermeria': 'Licenciatura en Enfermería',
                        'jefe_contaduria': 'Licenciatura en Contaduría',
                    }
                    
                    from app.models import User
                    jefe_users = db.query(User).filter(User.role == 'jefe_carrera').all()
                    for user in jefe_users:
                        if user.username in carrera_map:
                            user.carrera = carrera_map[user.username]
                            print(f"[INIT DB] Actualizado {user.username} -> {user.carrera}")
                    db.commit()
                except Exception as e:
                    print(f"[INIT DB] ERROR al agregar carrera: {e}")
                    import traceback
                    traceback.print_exc()
                    db.rollback()
            else:
                print("[INIT DB] ✓ La columna carrera ya existe")
    except Exception as e:
        print(f"[INIT DB] ERROR al inicializar base de datos: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

# Inicializar base de datos al iniciar la aplicación
print("[INIT] Inicializando base de datos...")
init_database()
print("[INIT] Inicialización de base de datos completada")

app = FastAPI()

origins = [
    "*"  
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_next_weekday(start_date: date, weekday: str) -> date:
    weekdays_map = {
        'LUNES': 0, 'MARTES': 1, 'MIÉRCOLES': 2, 'JUEVES': 3,
        'VIERNES': 4, 'SÁBADO': 5, 'DOMINGO': 6
    }
    target_weekday_int = weekdays_map.get(weekday.upper())
    if target_weekday_int is None:
        raise ValueError(f"Día de la semana '{weekday}' no válido.")

   
    if weekday.upper() == 'DOMINGO':

        return start_date + timedelta(days=7)


    days_ahead = (target_weekday_int - start_date.weekday() + 7) % 7

    return start_date + timedelta(days=days_ahead)

def get_next_monday(current_date: date) -> date:

    days_until_monday = (0 - current_date.weekday() + 7) % 7
    return current_date + timedelta(days=days_until_monday)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Horarios API"}

# ==================== ENDPOINTS DE AUTENTICACIÓN ====================

@app.post("/api/auth/register", response_model=schemas.User)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """Registrar un nuevo usuario"""
    # Verificar si el usuario ya existe
    db_user = db.query(models.User).filter(models.User.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nombre de usuario ya está registrado"
        )
    
    # Verificar si el email ya existe (si se proporciona)
    if user.email:
        db_email = db.query(models.User).filter(models.User.email == user.email).first()
        if db_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El email ya está registrado"
            )
    
    # Crear nuevo usuario
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        username=user.username,
        hashed_password=hashed_password,
        role=user.role,
        email=user.email,
        is_active=1
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Convertir is_active a booleano para la respuesta
    db_user.is_active = bool(db_user.is_active)
    return db_user

@app.post("/api/auth/login", response_model=schemas.Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """Iniciar sesión y obtener token JWT"""
    # Buscar usuario
    user = db.query(models.User).filter(models.User.username == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo"
        )
    
    # Crear token de acceso
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": user.username, "role": user.role}
    if user.carrera:
        token_data["carrera"] = user.carrera
    access_token = create_access_token(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": {
            "username": user.username,
            "role": user.role,
            "carrera": user.carrera
        }
    }

@app.get("/api/auth/me", response_model=schemas.User)
def get_current_user(token: str = Depends(lambda: None), db: Session = Depends(get_db)):
    """Obtener información del usuario actual (requiere token)"""
    # Este endpoint se puede mejorar con un dependency para extraer el token del header
    # Por ahora es un placeholder básico
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if not token:
        raise credentials_exception
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
    
    username: str = payload.get("sub")
    if username is None:
        raise credentials_exception
    
    user = db.query(models.User).filter(models.User.username == username).first()
    if user is None:
        raise credentials_exception
    
    # Convertir is_active a booleano
    user.is_active = bool(user.is_active)
    return user

# ==================== ENDPOINTS DE HORARIOS ====================

def get_carreras_logic(db: Session):
    carreras = db.query(models.Carrera).options(
        joinedload(models.Carrera.grupos).joinedload(models.Grupo.horarios).joinedload(models.Horario.materia).joinedload(models.Materia.profesor),
        joinedload(models.Carrera.grupos).joinedload(models.Grupo.horarios).joinedload(models.Horario.aula)
    ).all()

    for carrera in carreras:
        for grupo in carrera.grupos:
            for horario in grupo.horarios:
                horario.materia.carrera_nombre = carrera.nombre
    return carreras

@app.get("/api/carreras", response_model=List[schemas.Carrera])
def get_carreras(db: Session = Depends(get_db)):
    return get_carreras_logic(db)

@app.post("/api/generar-examenes", response_model=List[schemas.Examen])
def generar_examenes(carrera_id: int, grupo_id: int, db: Session = Depends(get_db)):

    carrera = db.query(models.Carrera).filter(models.Carrera.id == carrera_id).first()
    if not carrera:
        raise HTTPException(status_code=404, detail=f"Carrera con ID {carrera_id} no encontrada.")
    grupo = db.query(models.Grupo).filter(models.Grupo.id == grupo_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail=f"Grupo con ID {grupo_id} no encontrado.")


    materia_ids_in_carrera = db.query(models.Materia.id).filter(models.Materia.carrera_id == carrera_id).all()
    materia_ids_in_carrera = [m_id for m_id, in materia_ids_in_carrera] 

    if materia_ids_in_carrera:
        db.query(models.Examen).filter(
            models.Examen.materia_id.in_(materia_ids_in_carrera)
        ).delete(synchronize_session=False)
        db.commit() 

    horarios_query = db.query(models.Horario).options(
        joinedload(models.Horario.materia).joinedload(models.Materia.carrera)
    ).filter(
        models.Horario.grupo_id == grupo_id,
        models.Horario.materia.has(models.Materia.carrera_id == carrera_id)
    )
    horarios_filtrados = horarios_query.all()

    if not horarios_filtrados:
        raise HTTPException(status_code=404, detail=f"No se encontraron horarios para la Carrera ID {carrera_id} y Grupo ID {grupo_id} para generar exámenes.")

    examenes_a_crear = []
    today = date.today()
  
    start_date_for_exams = get_next_monday(today)
    
    
    occupied_slots_per_day = {} 

    for horario in horarios_filtrados:
        if not horario.materia or not horario.aula_id:
            continue

        day_of_week = horario.dia_semana.upper()
        time_slot = horario.hora_inicio.strftime('%H:%M')

        if day_of_week not in occupied_slots_per_day:
            occupied_slots_per_day[day_of_week] = {}
        
       
        if time_slot in occupied_slots_per_day[day_of_week]:
            continue 
 
        occupied_slots_per_day[day_of_week][time_slot] = True


        calculated_exam_date = get_next_weekday(start_date_for_exams, day_of_week)
        
        nuevo_examen = models.Examen(
            fecha=calculated_exam_date,
            hora_inicio=horario.hora_inicio,
            hora_fin=horario.hora_fin,
            tipo='PARCIAL', # Default type
            materia_id=horario.materia_id,
            aula_id=horario.aula_id,
            grupo_id=horario.grupo_id # Assign grupo_id from horario
        )
        examenes_a_crear.append(nuevo_examen)
    
    if not examenes_a_crear:
        raise HTTPException(status_code=404, detail="No se pudieron crear nuevos exámenes a partir de los horarios filtrados.")

    print("\n--- DEBUG: Exams to be created ---")
    for exam in examenes_a_crear:
        print(f"DEBUG: Exam Date: {exam.fecha}, Start Time: {exam.hora_inicio}, Type: {exam.tipo}, Materia ID: {exam.materia_id}")
    print("----------------------------------\n")

    try:
        db.add_all(examenes_a_crear)
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al guardar exámenes: {e}")


    return get_examenes_logic(db)

def get_examenes_logic(db: Session):
    try:
        # Consulta con join para obtener todas las relaciones
        examenes = db.query(models.Examen).join(models.Examen.materia).join(models.Materia.carrera).options(
            contains_eager(models.Examen.materia).joinedload(models.Materia.profesor),
            contains_eager(models.Examen.materia).joinedload(models.Materia.carrera),
            joinedload(models.Examen.aula),
            joinedload(models.Examen.grupo)
        ).all()
    except Exception as e:
        # Si el join falla, intentar sin join de carrera
        import traceback
        print(f"Error en join, intentando sin join de carrera: {e}")
        print(traceback.format_exc())
        try:
            examenes = db.query(models.Examen).options(
                joinedload(models.Examen.materia).joinedload(models.Materia.profesor),
                joinedload(models.Examen.materia).joinedload(models.Materia.carrera),
                joinedload(models.Examen.aula),
                joinedload(models.Examen.grupo)
            ).all()
        except Exception as e2:
            print(f"Error en consulta con joinedload: {e2}")
            import traceback
            print(traceback.format_exc())
            raise HTTPException(status_code=500, detail=f"Error al obtener exámenes: {str(e2)}")
    
    for ex in examenes:
        if ex.materia:
            if ex.materia.carrera:
                ex.materia.carrera_nombre = ex.materia.carrera.nombre
            elif hasattr(ex.materia, 'carrera_id') and ex.materia.carrera_id:
                carrera = db.query(models.Carrera).filter(models.Carrera.id == ex.materia.carrera_id).first()
                if carrera:
                    ex.materia.carrera_nombre = carrera.nombre
        if ex.grupo:
            ex.grupo_id = ex.grupo.id
        # Asegurar que sinodal_id esté definido
        if not hasattr(ex, 'sinodal_id'):
            ex.sinodal_id = None
            
    return examenes

@app.get("/api/examenes", response_model=List[schemas.Examen])
def get_examenes(db: Session = Depends(get_db)):
    try:
        return get_examenes_logic(db)
    except Exception as e:
        # Si hay un error, probablemente es porque sinodal_id no existe en la BD
        # Intentar sin cargar sinodal_id
        import traceback
        print(f"Error en get_examenes: {e}")
        print(traceback.format_exc())
        # Intentar consulta más simple
        try:
            examenes = db.query(models.Examen).join(models.Examen.materia).join(models.Materia.carrera).options(
                contains_eager(models.Examen.materia).joinedload(models.Materia.profesor),
                contains_eager(models.Examen.materia).joinedload(models.Materia.carrera),
                joinedload(models.Examen.aula),
                joinedload(models.Examen.grupo)
            ).all()
            
            for ex in examenes:
                if ex.materia and ex.materia.carrera:
                    ex.materia.carrera_nombre = ex.materia.carrera.nombre
                if ex.grupo:
                    ex.grupo_id = ex.grupo.id
                # Si sinodal_id no existe, establecerlo como None
                if not hasattr(ex, 'sinodal_id'):
                    ex.sinodal_id = None
                    
            return examenes
        except Exception as e2:
            print(f"Error secundario: {e2}")
            raise HTTPException(status_code=500, detail=f"Error al obtener exámenes: {str(e2)}")

@app.get("/api/tipos_examen", response_model=List[schemas.TipoExamen])
def get_tipos_examen(db: Session = Depends(get_db)):
    # Verificar si hay tipos de examen, si no crear los por defecto
    tipos = db.query(models.TipoExamen).all()
    if not tipos:
        defaults = ["Parcial", "Ordinario", "Extraordinario"]
        for nombre in defaults:
            db.add(models.TipoExamen(nombre=nombre))
        db.commit()
        tipos = db.query(models.TipoExamen).all()
    return tipos

@app.get("/api/materias", response_model=List[schemas.Materia])
def get_materias(carrera_id: int = None, db: Session = Depends(get_db)):
    query = db.query(models.Materia).options(
        joinedload(models.Materia.profesor),
        joinedload(models.Materia.carrera)
    )
    if carrera_id:
        query = query.filter(models.Materia.carrera_id == carrera_id)
    materias = query.all()
    
 
    for materia in materias:
        if materia.carrera:
            materia.carrera_nombre = materia.carrera.nombre
    
    return materias

@app.post("/api/examenes", response_model=schemas.Examen)
def create_examen(examen: schemas.ExamenCreate, db: Session = Depends(get_db)):
    # Buscar el nombre del tipo de examen
    tipo_obj = db.query(models.TipoExamen).filter(models.TipoExamen.id == examen.tipo_examen_id).first()
    if not tipo_obj:
        raise HTTPException(status_code=404, detail="Tipo de examen no encontrado")
    
    # Crear el examen
    # Nota: models.Examen usa 'tipo' como string, así que usamos el nombre
    db_examen = models.Examen(
        fecha=examen.fecha,
        hora_inicio=examen.hora_inicio,
        hora_fin=examen.hora_fin,
        tipo=tipo_obj.nombre,
        materia_id=examen.materia_id,
        aula_id=examen.aula_id,
        grupo_id=examen.grupo_id
    )
    db.add(db_examen)
    db.commit()
    db.refresh(db_examen)
    
    # Cargar relaciones para la respuesta
    examen_result = db.query(models.Examen).options(
        joinedload(models.Examen.materia).joinedload(models.Materia.profesor),
        joinedload(models.Examen.materia).joinedload(models.Materia.carrera),
        joinedload(models.Examen.aula),
        joinedload(models.Examen.grupo)
    ).filter(models.Examen.id == db_examen.id).first()
    
    # Agregar carrera_nombre
    if examen_result and examen_result.materia and examen_result.materia.carrera:
        examen_result.materia.carrera_nombre = examen_result.materia.carrera.nombre
    if examen_result and examen_result.grupo:
        examen_result.grupo_id = examen_result.grupo.id
    
    return examen_result

# ==================== ENDPOINTS DE GESTIÓN DE USUARIOS ====================

@app.get("/api/users", response_model=List[schemas.User])
def get_users(db: Session = Depends(get_db)):
    """Obtener lista de todos los usuarios"""
    users = db.query(models.User).all()
    # Convertir is_active a booleano para cada usuario
    for user in users:
        user.is_active = bool(user.is_active)
    return users

@app.delete("/api/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    """Eliminar un usuario por ID"""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    db.delete(user)
    db.commit()
    return {"message": "Usuario eliminado exitosamente"}

# ==================== ENDPOINTS DE AULAS, ACADEMIAS Y PROFESORES ====================

@app.get("/api/aulas", response_model=List[schemas.Aula])
def get_aulas(db: Session = Depends(get_db)):
    """Obtener lista de todas las aulas"""
    return db.query(models.Aula).all()

@app.get("/api/profesores", response_model=List[schemas.Profesor])
def get_profesores(db: Session = Depends(get_db)):
    """Obtener lista de todos los profesores"""
    return db.query(models.Profesor).all()

@app.get("/api/academias", response_model=List[schemas.Academia])
def get_academias(db: Session = Depends(get_db)):
    """Obtener lista de todas las academias"""
    try:
        return db.query(models.Academia).all()
    except Exception as e:
        # Si la tabla no existe, retornar lista vacía
        print(f"Error al obtener academias: {e}")
        return []

@app.put("/api/examenes/{examen_id}/sinodal")
def assign_sinodal(examen_id: int, sinodal_data: dict, db: Session = Depends(get_db)):
    """Asignar un sinodal a un examen"""
    examen = db.query(models.Examen).options(
        joinedload(models.Examen.materia).joinedload(models.Materia.profesor),
        joinedload(models.Examen.materia).joinedload(models.Materia.carrera)
    ).filter(models.Examen.id == examen_id).first()
    if not examen:
        raise HTTPException(status_code=404, detail="Examen no encontrado")
    
    sinodal_id = sinodal_data.get("sinodal_id")
    if sinodal_id:
        sinodal_id = int(sinodal_id)
        # Verificar que el profesor existe
        profesor = db.query(models.Profesor).filter(models.Profesor.id == sinodal_id).first()
        if not profesor:
            raise HTTPException(status_code=404, detail="Profesor sinodal no encontrado")
        
        # Verificar que no sea el profesor titular
        if examen.materia and examen.materia.profesor_id == sinodal_id:
            raise HTTPException(status_code=400, detail="El sinodal no puede ser el mismo profesor titular")
        
        # Intentar asignar sinodal_id, si la columna no existe, agregarla
        try:
            examen.sinodal_id = sinodal_id
        except AttributeError:
            # Si la columna no existe, intentar agregarla
            from sqlalchemy import inspect
            inspector = inspect(engine)
            columns = [col['name'] for col in inspector.get_columns('examenes')]
            if 'sinodal_id' not in columns:
                try:
                    db.execute(text("ALTER TABLE examenes ADD COLUMN sinodal_id INTEGER"))
                    db.commit()
                    # Recargar el examen
                    db.refresh(examen)
                    examen.sinodal_id = sinodal_id
                except Exception as e:
                    raise HTTPException(status_code=500, detail=f"Error al agregar columna sinodal_id: {str(e)}")
            else:
                raise
    else:
        try:
            examen.sinodal_id = None
        except AttributeError:
            # Si la columna no existe, no hacer nada
            pass
    
    db.commit()
    db.refresh(examen)
    
    # Cargar todas las relaciones para la respuesta
    examen_result = db.query(models.Examen).options(
        joinedload(models.Examen.materia).joinedload(models.Materia.profesor),
        joinedload(models.Examen.materia).joinedload(models.Materia.carrera),
        joinedload(models.Examen.aula),
        joinedload(models.Examen.grupo)
    ).filter(models.Examen.id == examen_id).first()
    
    if examen_result and examen_result.materia and examen_result.materia.carrera:
        examen_result.materia.carrera_nombre = examen_result.materia.carrera.nombre
    if examen_result and examen_result.grupo:
        examen_result.grupo_id = examen_result.grupo.id
    
    return {"message": "Sinodal asignado correctamente", "examen_id": examen_id, "sinodal_id": examen_result.sinodal_id if examen_result else None}