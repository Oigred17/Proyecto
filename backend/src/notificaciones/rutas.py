from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session
from typing import List
from ..configuracion.base_datos import obtener_db
from . import modelos, esquemas

router = APIRouter(
    prefix="/api/notificaciones",
    tags=["Notificaciones"]
)

@router.get("/", response_model=List[esquemas.Notificacion])
def leer_notificaciones(rol: str = None, usuario_id: int = None, carrera: str = None, db: Session = Depends(obtener_db)):
    query = db.query(modelos.Notificacion).filter(modelos.Notificacion.leida == False)
    
    # Normalización y filtrado
    if carrera:
        carrera = carrera.strip().lower() # Normalizar a minúsculas para comparación
        
    if rol:
        rol = rol.strip().lower() # Normalizar rol a minúsculas

    if rol == 'jefe_carrera':
        if not carrera:
            return []
        # Filtro estricto por rol Y carrera (case-insensitive)
        query = query.filter(
            func.lower(modelos.Notificacion.destinatario_rol) == 'jefe_carrera',
            func.lower(modelos.Notificacion.carrera) == carrera
        )
    elif rol == 'servicios_escolares':
        query = query.filter(modelos.Notificacion.destinatario_rol == 'servicios_escolares')
        if carrera:
            query = query.filter(modelos.Notificacion.carrera == carrera)
    elif rol:
        query = query.filter(modelos.Notificacion.destinatario_rol == rol)
        
    return query.order_by(modelos.Notificacion.fecha_creacion.desc()).all()

@router.put("/{notificacion_id}/leer")
def marcar_leida(notificacion_id: int, db: Session = Depends(obtener_db)):
    notif = db.query(modelos.Notificacion).filter(modelos.Notificacion.id == notificacion_id).first()
    if notif:
        notif.leida = True
        db.commit()
    return {"message": "Leída"}
