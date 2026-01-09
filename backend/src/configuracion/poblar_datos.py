import sys
import os
import re
import datetime

# Agrega el directorio 'backend' a sys.path para que se encuentre el módulo 'src'
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from src.configuracion.base_datos import SessionLocal, engine
from src.compartido.modelos_base import Base
# Importar modelos de gestión académica y horarios
from src.gestion_academica.modelos import Carrera, Profesor, Aula, Materia, Grupo
from src.gestion_horarios.modelos import Horario
# Importar Examen para que SQLAlchemy reconozca la relación en Aula
from src.gestion_examenes.modelos import Examen

def obtener_o_crear(session, model, **kwargs):
    """
    Revisa si un objeto existe en la base de datos. Si existe, lo devuelve.
    Si no, crea uno nuevo y lo devuelve.
    """
    instance = session.query(model).filter_by(**kwargs).first()
    if instance:
        return instance, False
    else:
        instance = model(**kwargs)
        session.add(instance)
        session.flush()
        return instance, True

def poblar():
    """
    Analiza los datos crudos desde un archivo y puebla la base de datos.
    """
    # Construir la ruta al archivo de datos
    try:
        data_path = os.path.join(os.path.dirname(__file__), 'horarios.txt')
        with open(data_path, 'r', encoding='utf-8') as f:
            data = f.read()
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo 'horarios.txt' en la ruta: {data_path}")
        return

    # No reseteamos las tablas aquí para ser seguros, asumimos que están vacías o se desea agregar
    # Base.metadata.create_all(bind=engine) # Ya se crea en main.py
    
    db = SessionLocal()

    materias_map = {}

    carrera_blocks = data.strip().split('### Horarios de ')
    for block in carrera_blocks:
        if not block:
            continue

        lines = block.strip().split('\n')
        carrera_name_full = lines[0].strip()
        carrera_name_match = re.match(r'(.+?)(?:\s\(\d{4}\))?$', carrera_name_full)
        carrera_name = carrera_name_match.group(1).strip() if carrera_name_match else carrera_name_full
        
        carrera_obj, _ = obtener_o_crear(db, Carrera, nombre=carrera_name)

        group_sections = re.split(r'####\s+', block)[1:]
        for section in group_sections:
            section_lines = section.strip().split('\n')
            grupo_name = section_lines[0].replace('Grupo ', '').strip()
            
            grupo_obj, _ = obtener_o_crear(db, Grupo, nombre_grupo=grupo_name, carrera_id=carrera_obj.id)

            # Mapeo de materias y profesores
            prof_map_section = {}
            prof_marker = '**Materias y Profesores:**'
            if prof_marker in section:
                prof_data = section.split(prof_marker)[1]
                for line in prof_data.strip().split('\n'):
                    if not line.startswith('-'): continue
                    parts = line[1:].strip().split(':')
                    if len(parts) < 2: continue
                    materia_name = parts[0].strip()
                    prof_name = parts[1].strip()

                    prof_obj, _ = obtener_o_crear(db, Profesor, nombre=prof_name)
                    
                    materia_obj, is_created = obtener_o_crear(db, Materia, nombre=materia_name, carrera_id=carrera_obj.id)
                    if is_created or not materia_obj.profesor_id:
                         materia_obj.profesor_id = prof_obj.id
                    
                    materias_map[materia_name] = materia_obj

            # Análisis de la tabla de horarios
            schedule_started = False
            header = []
            prev_line = ""
            for line in section_lines:
                if '---|' in line:
                    schedule_started = True
                    header = [h.strip() for h in prev_line.split('|')]
                    continue
                if schedule_started and '|' in line:
                    cells = [c.strip() for c in line.split('|')]
                    time_slot = cells[0]
                    
                    try:
                        start_str, end_str = time_slot.split(' - ')
                        start_time = datetime.datetime.strptime(start_str, '%H:%M').time()
                        end_time = datetime.datetime.strptime(end_str, '%H:%M').time()
                    except ValueError:
                        continue

                    for i, day_cell in enumerate(cells[1:], 1):
                        if i >= len(header): continue # Safety check
                        
                        if not day_cell or 'BIBLIOTECA' in day_cell or 'ACTIVIDADES' in day_cell or 'TUTORÍA' in day_cell:
                            continue
                        
                        current_dia_semana = header[i]
                        # Corrige el día de la semana si es Domingo para que sea Lunes
                        if current_dia_semana == "Domingo":
                            current_dia_semana = "Lunes"
                        
                        aula_match = re.search(r'Aula:\s*(.+)$', day_cell)
                        aula_name = aula_match.group(1).strip() if aula_match else None
                        materia_name_sched = (aula_match.string[:aula_match.start()].strip() if aula_match else day_cell).replace(' / INGLÉS', '')

                        # Only create Horario if materia_name_sched is a recognized subject
                        materia_obj_sched = materias_map.get(materia_name_sched)
                        if not materia_obj_sched:
                            # If it's not a recognized subject, skip creating a Horario for it
                            continue

                        aula_obj = None
                        if aula_name:
                            aula_obj, _ = obtener_o_crear(db, Aula, nombre=aula_name)
                        
                        # Crear horario sin duplicar si ya existe
                        horario_existente = db.query(Horario).filter_by(
                            dia_semana=current_dia_semana,
                            hora_inicio=start_time,
                            grupo_id=grupo_obj.id,
                            materia_id=materia_obj_sched.id
                        ).first()

                        if not horario_existente:
                            horario_obj = Horario(
                                dia_semana=current_dia_semana,
                                hora_inicio=start_time,
                                hora_fin=end_time,
                                grupo_id=grupo_obj.id,
                                materia_id=materia_obj_sched.id,
                                aula_id=aula_obj.id if aula_obj else None
                            )
                            db.add(horario_obj)
                prev_line = line
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        print(f"Error durante la confirmación: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    print("Poblando la base de datos con los horarios detallados...")
    poblar()
    print("Base de datos poblada exitosamente.")
