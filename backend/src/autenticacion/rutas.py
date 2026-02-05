from fastapi import APIRouter, Depends, HTTPException, status, Form
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import Optional

from ..configuracion.base_datos import obtener_db
from . import modelos, esquemas
from .seguridad import (
    verificar_password, 
    obtener_hash_password, 
    crear_token_acceso, 
    decodificar_token,
    ACCESS_TOKEN_EXPIRE_MINUTES
)

router = APIRouter(
    prefix="/api/auth",
    tags=["Autenticación"]
)

@router.post("/register", response_model=esquemas.User)
def register_user(user: esquemas.UserCreate, db: Session = Depends(obtener_db)):
    """Registrar un nuevo usuario"""
    db_user = db.query(modelos.User).filter(modelos.User.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El nombre de usuario ya está registrado"
        )
    
    if user.email:
        db_email = db.query(modelos.User).filter(modelos.User.email == user.email).first()
        if db_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El email ya está registrado"
            )
    
    hashed_password = obtener_hash_password(user.password)
    db_user = modelos.User(
        username=user.username,
        hashed_password=hashed_password,
        role=user.role,
        email=user.email,
        carrera=user.carrera,
        profesor_id=user.profesor_id,
        is_active=1
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    db_user.is_active = bool(db_user.is_active)
    return db_user

@router.post("/login", response_model=esquemas.Token)
def login(
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(obtener_db)
):
    """Iniciar sesión y obtener token JWT. Acepta form-data o JSON."""
    user = db.query(modelos.User).filter(modelos.User.username == username).first()
    
    if not user or not verificar_password(password, user.hashed_password):
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
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": user.username, "role": user.role}
    if user.carrera:
        token_data["carrera"] = user.carrera
        
    access_token = crear_token_acceso(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": {
            "username": user.username,
            "role": user.role,
            "carrera": user.carrera,
            "email": user.email
        }
    }

@router.post("/login/json", response_model=esquemas.Token)
def login_json(login_data: esquemas.UserLogin, db: Session = Depends(obtener_db)):
    """Iniciar sesión y obtener token JWT. Acepta JSON."""
    user = db.query(modelos.User).filter(modelos.User.username == login_data.username).first()
    
    if not user or not verificar_password(login_data.password, user.hashed_password):
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
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token_data = {"sub": user.username, "role": user.role}
    if user.carrera:
        token_data["carrera"] = user.carrera
        
    access_token = crear_token_acceso(
        data=token_data,
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user": {
            "username": user.username,
            "role": user.role,
            "carrera": user.carrera,
            "email": user.email
        }
    }

@router.get("/me", response_model=esquemas.User)
def get_current_user(token: str = Depends(lambda: None), db: Session = Depends(obtener_db)):
    """Obtener información del usuario actual (requiere token en header o query param para este ejemplo simlpificado)"""
    # Nota: Idealmente usar Depends(oauth2_scheme)
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if not token:
        # Intentar leer del header Authorization si no viene como query param
        # Esto es un placeholder simplificado para mantener compatibilidad con el frontend original
        raise credentials_exception
    
    # Limpiar 'Bearer ' si viene en el token string
    if token.startswith("Bearer "):
        token = token.split(" ")[1]

    payload = decodificar_token(token)
    if payload is None:
        raise credentials_exception
    
    username: str = payload.get("sub")
    if username is None:
        raise credentials_exception
    
    user = db.query(modelos.User).filter(modelos.User.username == username).first()
    if user is None:
        raise credentials_exception
    
    user.is_active = bool(user.is_active)
    return user

@router.get("/users", response_model=list[esquemas.User])
def get_users(db: Session = Depends(obtener_db)):
    """Obtener lista de todos los usuarios (solo admin debería acceder idealmente)"""
    users = db.query(modelos.User).all()
    for user in users:
        user.is_active = bool(user.is_active)
    return users

@router.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(obtener_db)):
    """Eliminar un usuario por ID"""
    user = db.query(modelos.User).filter(modelos.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    db.delete(user)
    db.commit()
    return {"message": "Usuario eliminado exitosamente"}
