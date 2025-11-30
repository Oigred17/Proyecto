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

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:3001",
    "http://132.18.53.85",
    "http://132.18.53.85:8080",
    "*"  # Permitir todo para evitar problemas de desarrollo
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Helper function to get the date of the next occurrence of a weekday
def get_next_weekday(start_date: date, weekday: str) -> date:
    weekdays_map = {
        'LUNES': 0, 'MARTES': 1, 'MIÉRCOLES': 2, 'JUEVES': 3,
        'VIERNES': 4, 'SÁBADO': 5, 'DOMINGO': 6
    }
    target_weekday_int = weekdays_map.get(weekday.upper())
    if target_weekday_int is None:
        raise ValueError(f"Día de la semana '{weekday}' no válido.")

    # Special handling for Sunday: always move to the next Monday
    if weekday.upper() == 'DOMINGO':
        # start_date is guaranteed to be a Monday (from get_next_monday).
        # We want the Monday after the start_date's week.
        return start_date + timedelta(days=7)

    # For other weekdays (Lunes to Sabado), calculate the next occurrence including start_date
    # Use standard formula for days until next weekday (0 means today)
    days_ahead = (target_weekday_int - start_date.weekday() + 7) % 7

    return start_date + timedelta(days=days_ahead)

def get_next_monday(current_date: date) -> date:
    # Monday is 0
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
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role},
        expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

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
    # Validate carrera and grupo exist
    carrera = db.query(models.Carrera).filter(models.Carrera.id == carrera_id).first()
    if not carrera:
        raise HTTPException(status_code=404, detail=f"Carrera con ID {carrera_id} no encontrada.")
    grupo = db.query(models.Grupo).filter(models.Grupo.id == grupo_id).first()
    if not grupo:
        raise HTTPException(status_code=404, detail=f"Grupo con ID {grupo_id} no encontrado.")

    # Clean up existing exams for this specific carrera and grupo
    # First, get the IDs of materias belonging to the specified carrera
    materia_ids_in_carrera = db.query(models.Materia.id).filter(models.Materia.carrera_id == carrera_id).all()
    materia_ids_in_carrera = [m_id for m_id, in materia_ids_in_carrera] # Extract IDs from list of tuples

    # Then, delete exams that correspond to these materia_ids
    if materia_ids_in_carrera:
        db.query(models.Examen).filter(
            models.Examen.materia_id.in_(materia_ids_in_carrera)
        ).delete(synchronize_session=False)
        db.commit() # Commit after deletion

    # Fetch relevant horarios
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
    # Calculate the fixed start date for exams as the upcoming Monday
    start_date_for_exams = get_next_monday(today)
    
    # To ensure one exam slot per day (e.g., if multiple classes overlap)
    occupied_slots_per_day = {} # Format: { 'LUNES': { '09:00': True }, ... }

    for horario in horarios_filtrados:
        if not horario.materia or not horario.aula_id:
            continue

        day_of_week = horario.dia_semana.upper()
        time_slot = horario.hora_inicio.strftime('%H:%M')

        if day_of_week not in occupied_slots_per_day:
            occupied_slots_per_day[day_of_week] = {}
        
        # Check if this specific time slot for this day is already occupied by an exam
        if time_slot in occupied_slots_per_day[day_of_week]:
            continue # Skip if an exam is already planned for this slot
        
        # Mark this slot as occupied
        occupied_slots_per_day[day_of_week][time_slot] = True

        # Calculate the actual exam date for the given weekday, relative to the upcoming Monday
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

    # Return the created exams with all details
    return get_examenes_logic(db)

def get_examenes_logic(db: Session):
    examenes = db.query(models.Examen).join(models.Examen.materia).join(models.Materia.carrera).options(
        contains_eager(models.Examen.materia).joinedload(models.Materia.profesor),
        contains_eager(models.Examen.materia).joinedload(models.Materia.carrera),
        joinedload(models.Examen.aula),
        joinedload(models.Examen.grupo) # Eagerly load the grupo relationship
    ).all()
    
    for ex in examenes:
        if ex.materia and ex.materia.carrera:
            ex.materia.carrera_nombre = ex.materia.carrera.nombre
        # Add grupo_id to the Examen object for the frontend
        if ex.grupo:
            ex.grupo_id = ex.grupo.id
            
    return examenes

@app.get("/api/examenes", response_model=List[schemas.Examen])
def get_examenes(db: Session = Depends(get_db)):
    return get_examenes_logic(db)

def get_examenes_logic(db: Session):
    examenes = db.query(models.Examen).join(models.Examen.materia).join(models.Materia.carrera).options(
        contains_eager(models.Examen.materia).joinedload(models.Materia.profesor),
        contains_eager(models.Examen.materia).joinedload(models.Materia.carrera),
        joinedload(models.Examen.aula),
        joinedload(models.Examen.grupo) # Eagerly load the grupo relationship
    ).all()
    
    for ex in examenes:
        if ex.materia and ex.materia.carrera:
            ex.materia.carrera_nombre = ex.materia.carrera.nombre
        # Add grupo_id to the Examen object for the frontend
        if ex.grupo:
            ex.grupo_id = ex.grupo.id
            
    return examenes

@app.get("/api/examenes", response_model=List[schemas.Examen])
def get_examenes(db: Session = Depends(get_db)):
    return get_examenes_logic(db)

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
    query = db.query(models.Materia)
    if carrera_id:
        query = query.filter(models.Materia.carrera_id == carrera_id)
    return query.all()

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
    return db.query(models.Examen).options(
        joinedload(models.Examen.materia),
        joinedload(models.Examen.aula),
        joinedload(models.Examen.grupo)
    ).filter(models.Examen.id == db_examen.id).first()

