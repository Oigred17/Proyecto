from src.configuracion.base_datos import SessionLocal, engine
from src.compartido.modelos_base import Base
import src.gestion_academica.modelos
import src.gestion_horarios.modelos
import src.gestion_examenes.modelos
import src.autenticacion.modelos
import src.notificaciones.modelos

def limpiar():
    db = SessionLocal()
    try:
        num_deleted = db.query(src.gestion_examenes.modelos.Examen).delete()
        db.commit()
        print(f"Se eliminaron {num_deleted} exámenes.")
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    limpiar()
