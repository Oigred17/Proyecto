#!/usr/bin/env python3
"""
Script de configuración e inicialización del sistema de gestión de horarios.
Crea la base de datos, tablas, ejecuta migraciones y pobla datos iniciales.
"""
import sys
import os
import json
import datetime
import argparse
import logging
import time
from sqlalchemy import inspect, text

sys.path.insert(0, os.path.dirname(__file__))

# Configurar logging - Solo mostrar WARNING y superiores para limpiar la consola
logging.basicConfig(level=logging.WARNING, format='%(asctime)s - %(levelname)s - %(message)s')

from src.configuracion.base_datos import engine, SessionLocal
from src.compartido.modelos_base import Base
from src.autenticacion.modelos import User
from src.autenticacion.seguridad import obtener_hash_password
from src.gestion_academica.modelos import Carrera, Profesor, Aula, Materia, Grupo, Academia
from src.gestion_horarios.modelos import Horario
from src.gestion_examenes.modelos import Examen

# Importar servicios de integración con API externa
from src.integracion_horarios.services.horario_service import HorarioService
from src.integracion_horarios.services.periodo_service import PeriodoService
from src.integracion_horarios.core.config import settings as horarios_config

logger = logging.getLogger(__name__)

def mostrar_progreso(actual, total, inicio_time, prefijo='Progreso'):
    """Muestra una barra de progreso con tiempo restante estimado."""
    transcurrido = time.time() - inicio_time
    # Evitar división por cero
    if total == 0: return
    
    porcentaje = actual / total
    if porcentaje > 0:
        total_estimado = transcurrido / porcentaje
        restante = total_estimado - transcurrido
    else:
        restante = 0
        
    m, s = divmod(int(restante), 60)
    tiempo_str = f"{m:02d}:{s:02d}"
    
    barra_largo = 30
    bloques = int(barra_largo * porcentaje)
    barra = "█" * bloques + "░" * (barra_largo - bloques)
    
    sys.stdout.write(f"\r{prefijo}: |{barra}| {actual}/{total} ({porcentaje*100:.1f}%) [⏳ Restante: {tiempo_str}]")
    sys.stdout.flush()
    if actual == total:
        print()

def obtener_o_crear(session, model, **kwargs):
    """Obtiene una instancia existente o crea una nueva si no existe, normalizando strings."""
    # Normalizar valores de búsqueda si son strings (quitar espacios)
    search_kwargs = {}
    for k, v in kwargs.items():
        if isinstance(v, str):
            search_kwargs[k] = v.strip()
        else:
            search_kwargs[k] = v

    instance = session.query(model).filter_by(**search_kwargs).first()
    if instance:
        return instance, False
    else:
        try:
            instance = model(**search_kwargs)
            session.add(instance)
            session.flush()
            return instance, True
        except Exception:
            # En caso de error de concurrencia o flush, intentar buscar de nuevo
            session.rollback()
            instance = session.query(model).filter_by(**search_kwargs).first()
            if instance:
                return instance, False
            raise

def clean_db():
    """Elimina todas las tablas de la base de datos."""
    print(" Limpiando base de datos...")
    Base.metadata.drop_all(bind=engine)
    print("✓ Base de datos limpia")

def setup_tables():
    """Crea todas las tablas definidas en los modelos."""
    print(" Creando tablas...")
    Base.metadata.create_all(bind=engine)
    print("✓ Tablas creadas")

def run_migrations():
    """Ejecuta migraciones manuales para agregar columnas dinámicas."""
    print(" Ejecutando migraciones manuales...")
    db = SessionLocal()
    try:
        inspector = inspect(engine)
        
        if 'examenes' in inspector.get_table_names():
            columns = [col['name'] for col in inspector.get_columns('examenes')]
            cols_to_add = {
                'sinodal_id': "INTEGER",
                'status': "VARCHAR(50) DEFAULT 'borrador'",
                'comentarios_rechazo': "TEXT",
                'fecha_envio': "DATE",
                'fecha_aprobacion': "DATE",
                'academia_id': "INTEGER"
            }
            for col, dtype in cols_to_add.items():
                if col not in columns:
                    db.execute(text(f"ALTER TABLE examenes ADD COLUMN {col} {dtype}"))
        
        if 'users' in inspector.get_table_names():
            user_cols = [c['name'] for c in inspector.get_columns('users')]
            if 'carrera' not in user_cols:
                db.execute(text("ALTER TABLE users ADD COLUMN carrera VARCHAR"))
            if 'profesor_id' not in user_cols:
                db.execute(text("ALTER TABLE users ADD COLUMN profesor_id INTEGER"))
        
        if 'notificaciones' in inspector.get_table_names():
            if 'carrera' not in [c['name'] for c in inspector.get_columns('notificaciones')]:
                db.execute(text("ALTER TABLE notificaciones ADD COLUMN carrera VARCHAR"))

        if 'materias' in inspector.get_table_names():
            mat_cols = [c['name'] for c in inspector.get_columns('materias')]
            if 'academia_id' not in mat_cols:
                db.execute(text("ALTER TABLE materias ADD COLUMN academia_id INTEGER"))
            if 'semestre' not in mat_cols:
                db.execute(text("ALTER TABLE materias ADD COLUMN semestre INTEGER"))
            if 'sinodal_id' not in mat_cols:
                db.execute(text("ALTER TABLE materias ADD COLUMN sinodal_id INTEGER"))
        
        if 'grupos' in inspector.get_table_names():
            if 'semestre' not in [c['name'] for c in inspector.get_columns('grupos')]:
                db.execute(text("ALTER TABLE grupos ADD COLUMN semestre INTEGER"))

        db.commit()
        print("✓ Migraciones completadas")
    except Exception as e:
        print(f"✗ Error en migraciones: {e}")
        db.rollback()
    finally:
        db.close()

def populate_from_api():
    """Pobla la base de datos con los horarios desde la API externa."""
    print(f" Consultando API externa: {horarios_config.API_HORARIOS}")
    
    db = SessionLocal()
    
    # 1. PRIMERO: Cargar todas las aulas con sus atributos completos desde la API
    try:
        print(" Cargando catálogo de aulas desde API...")
        from src.integracion_horarios.services.aula_service import AulaService
        aula_service = AulaService()
        aulas_api = aula_service.obtener_todas_aulas(page=1, size=500)
        
        aulas_creadas = 0
        total_aulas = len(aulas_api)
        start_aulas = time.time()
        
        for i, aula_data in enumerate(aulas_api):
            nombre_aula = aula_data.get('nombre', '').strip().upper()
            if nombre_aula:
                aula_existente = db.query(Aula).filter_by(nombre=nombre_aula).first()
                if not aula_existente:
                    db.add(Aula(
                        nombre=nombre_aula,
                        capacidad=aula_data.get('capacidad'),
                        tipo=aula_data.get('tipo')
                    ))
                    aulas_creadas += 1
                elif aula_existente.capacidad is None:
                    # Actualizar aulas existentes sin capacidad
                    aula_existente.capacidad = aula_data.get('capacidad')
                    aula_existente.tipo = aula_data.get('tipo')
            mostrar_progreso(i + 1, total_aulas, start_aulas, " Aulas")
        
        db.commit()
        print(f"✓ Cargadas {aulas_creadas} aulas nuevas con sus atributos completos")
    except Exception as e:
        print(f"  Error al cargar aulas: {e}")
        db.rollback()
    
    # 2. Obtener carreras de la API para crear mapeo clave -> nombre
    carrera_map = {}
    try:
        from src.integracion_horarios.services.carrera_service import CarreraService
        carrera_service = CarreraService()
        carreras_api = carrera_service.obtener_todas_carreras()
        # Normalizar nombres de la API: strip y upper para consistencia
        carrera_map = {c['clave']: c['nombre'].strip().upper() for c in carreras_api if c.get('vigente', True)}
        print(f"✓ Mapeadas {len(carrera_map)} carreras vigentes")
    except Exception as e:
        print(f"  No se pudieron obtener carreras de API: {e}")
    
    # Agregar mapeos adicionales para claves que no están en la API de carreras vigentes
    carrera_map_adicional = {
        '08B': 'MAESTRÍA EN PLANEACIÓN ESTRATÉGICA MUNICIPAL 2024',
        '10B': 'MAESTRÍA EN GOBIERNO ELECTRÓNICO 2024',
        '11B': 'DOCTORADO EN GOBIERNO ELECTRÓNICO 2024',
        '13': 'INGLÉS',
        '12': 'INGLÉS',
    }
    # Asegurar que el mapa adicional también esté normalizado
    carrera_map_adicional = {k: v.strip().upper() for k, v in carrera_map_adicional.items()}
    carrera_map.update(carrera_map_adicional)
    
    try:
        # Obtener el periodo actual dinámicamente de la API
        periodo_service = PeriodoService()
        periodo_data = periodo_service.obtener_periodo_actual()
        
        if periodo_data and 'clave' in periodo_data:
            periodo_actual = periodo_data['clave']
            print(f" Periodo académico obtenido de API: {periodo_actual}")
        else:
            periodo_actual = horarios_config.PERIODO_ACTUAL
            print(f"  No se pudo obtener periodo de API, usando configurado: {periodo_actual}")
        
        # Obtener grupos del periodo actual
        from src.integracion_horarios.services.grupo_service import GrupoService
        grupo_service = GrupoService()
        grupos_data = grupo_service.obtener_grupos_por_periodo(periodo=periodo_actual)
        
        if not grupos_data or len(grupos_data) == 0:
            print("  No se obtuvieron grupos de la API")
            print(" Cargando desde JSON local...")
            return populate_from_json()
        
        print(f"✓ Se obtuvieron {len(grupos_data)} grupos de la API")
        
        # Procesar grupos uno por uno
        db = SessionLocal()
        dias_map_inv = {1: "Lunes", 2: "Martes", 3: "Miércoles", 4: "Jueves", 5: "Viernes", 6: "Sábado", 7: "Domingo"}
        
        horario_service = HorarioService()
        total_grupos = len(grupos_data)
        start_grupos = time.time()
        print(f" Procesando {total_grupos} grupos y sus horarios...")
        
        for i, grupo_info in enumerate(grupos_data):
            try:
                # 1. Información del grupo
                clave_grupo = grupo_info.get('clave')
                clave_carrera = grupo_info.get('carrera')
                semestre = grupo_info.get('semestre')
                
                if not clave_grupo or not clave_carrera:
                    continue
                
                # 2. Carrera (del grupo)
                carrera_nombre = carrera_map.get(clave_carrera, str(clave_carrera).strip().upper())
                # Normalizar nombre: quitar el año al final (ej: " 2022") para agrupar planes
                import re
                carrera_nombre_base = re.sub(r'\s+\d{4}$', '', carrera_nombre).strip()
                
                # Buscar por nombre base. Si ya existe, nos quedamos con ese.
                carrera_obj = db.query(Carrera).filter_by(nombre=carrera_nombre_base).first()
                if not carrera_obj:
                    # Si no existe, lo creamos con el código de la primera vez que lo encontremos
                    carrera_obj = Carrera(nombre=carrera_nombre_base, codigo=str(clave_carrera))
                    db.add(carrera_obj)
                    db.flush()
                # Nota: mantenemos el código original del primer plan encontrado.
                # Para que el filtrado por código funcione, si el jefe tiene un código '06B' 
                # pero la carrera se guardó como '06', deberíamos considerar esto.
                # Sin embargo, si el jefe tiene el código del plan que esté en la DB, funcionará.
                
                # 3. Grupo (con su semestre y carrera)
                grupo_obj, _ = obtener_o_crear(db, Grupo, 
                    nombre_grupo=clave_grupo.strip().upper(), 
                    carrera_id=carrera_obj.id,
                    semestre=semestre
                )
                
                # 4. Obtener horarios de este grupo
                horarios_grupo = horario_service.obtener_por_grupo(periodo=periodo_actual, idGrupo=clave_grupo)
                if not horarios_grupo:
                    continue
                    
                for item in horarios_grupo:
                    # Profesor
                    prof_nombre = item.get("nombreCompleto", "SIN PROFESOR").strip().upper()
                    if prof_nombre in ["SIN PROFESOR ASIGNADO", "", "SIN PROFESOR"]:
                        prof_obj = None
                    else:
                        prof_obj, _ = obtener_o_crear(db, Profesor, nombre=prof_nombre)

                    # Aula - buscar en las ya creadas, si no existe crear con nombre básico
                    aula_nombre = item.get("nombreAula", "SIN AULA").strip().upper()
                    if not aula_nombre:
                        aula_nombre = "SIN AULA"
                    
                    aula_obj = db.query(Aula).filter_by(nombre=aula_nombre).first()
                    if not aula_obj:
                        # Si no existe, crear una básica (no debería pasar si cargamos primero el catálogo)
                        aula_obj = Aula(nombre=aula_nombre)
                        db.add(aula_obj)
                        db.flush()

                    # Materia (SIEMPRE asociada a la carrera de la licenciatura del grupo)
                    m_raw = item.get("materia", "").strip()
                    if not m_raw:
                        continue
                        
                    m_upper = m_raw.upper()
                    # Materias puramente administrativas o de servicio que NO deben tener examen
                    # Pero las mantenemos para detectar choques de horario (Inglés y Sala de Cómputo)
                    ignorar_total = ['BIBLIOTECA', 'TUTORÍA', 'ASESORÍA', 'EXTRAESCOLARES']
                    if any(x == m_upper for x in ignorar_total):
                        continue

                    # Crear materia ligada a la carrera del grupo
                    if prof_obj:
                        materia_obj, _ = obtener_o_crear(db, Materia, nombre=m_raw, carrera_id=carrera_obj.id, profesor_id=prof_obj.id, semestre=semestre)
                    else:
                        materia_obj, _ = obtener_o_crear(db, Materia, nombre=m_raw, carrera_id=carrera_obj.id, semestre=semestre)

                    # Horario
                    dia_num = item.get("dia", 1)
                    dia_nombre = dias_map_inv.get(dia_num, "Lunes")
                    hora_num = item.get("hora", 8)
                    t_start = datetime.time(hour=hora_num, minute=0)
                    t_end = datetime.time(hour=(hora_num + 1), minute=0)

                    horario_exists = db.query(Horario).filter_by(
                        dia_semana=dia_nombre, hora_inicio=t_start, grupo_id=grupo_obj.id, materia_id=materia_obj.id
                    ).first()
                    
                    if not horario_exists:
                        db.add(Horario(
                            dia_semana=dia_nombre, hora_inicio=t_start, hora_fin=t_end,
                            grupo_id=grupo_obj.id, materia_id=materia_obj.id,
                            aula_id=aula_obj.id
                        ))
                
                # Mostrar progreso y commit periódico
                mostrar_progreso(i + 1, total_grupos, start_grupos, " Grupos")
                
                if i % 10 == 0:
                    db.commit()

            except Exception as e:
                print(f"  ⚠ Error en grupo {clave_grupo}: {e}")
                db.rollback()
                continue
        
        db.commit()
        print(f"✓ Datos de {len(grupos_data)} grupos poblados exitosamente desde API")
        return # Terminar aquí, ya no procesamos el bloque de abajo
    except Exception as e:
        print(f"✗ Error al poblar desde API: {e}")
        db.rollback()
        print(" Intentando cargar desde JSON local como respaldo...")
        db.close()
        return populate_from_json()
    finally:
        db.close()

def populate_from_json():
    """Pobla la base de datos con los horarios desde el archivo JSON (FALLBACK)."""
    print(" Poblando datos desde horario_por_grupo.json (modo fallback)...")
    
    posibles_rutas = [
        os.path.join(os.path.dirname(__file__), 'db', 'horarios', 'horario_por_grupo.json'),
        os.path.join(os.path.dirname(__file__), '..', 'db', 'horarios', 'horario_por_grupo.json'),
        '/app/db/horarios/horario_por_grupo.json'
    ]
    
    json_path = next((r for r in posibles_rutas if os.path.exists(r)), None)
    if not json_path:
        print("✗ Error: No se encontró horario_por_grupo.json")
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    db = SessionLocal()
    try:
        dias_map_inv = {1: "Lunes", 2: "Martes", 3: "Miércoles", 4: "Jueves", 5: "Viernes", 6: "Sábado", 7: "Domingo"}

        for item in data:
            carrera_nombre = item.get("nombreCarrera", "Carrera Desconocida")
            if not carrera_nombre.startswith("Licenciatura"):
                 carrera_nombre = item.get("carrera", "Carrera Desconocida")
            
            carrera_obj, _ = obtener_o_crear(db, Carrera, nombre=carrera_nombre)
            
            grupo_nombre = item.get("nombreGrupo", "Grupo X")
            grupo_obj, _ = obtener_o_crear(db, Grupo, nombre_grupo=grupo_nombre, carrera_id=carrera_obj.id)
            
            prof_nombre = item.get("nombreCompleto", "SIN PROFESOR").strip()
            if prof_nombre == "SIN PROFESOR ASIGNADO":
                prof_obj = None
            else:
                prof_obj, _ = obtener_o_crear(db, Profesor, nombre=prof_nombre)

            aula_nombre = item.get("nombreAula", "Sin Aula").strip()
            aula_obj, _ = obtener_o_crear(db, Aula, nombre=aula_nombre)

            m_raw = item.get("materia", "").strip()
            m_upper = m_raw.upper()

            ignorar_total = ['BIBLIOTECA', 'TUTORÍA', 'ASESORÍA', 'EXTRAESCOLARES']

            if any(x == m_upper for x in ignorar_total):
                 if 'INGLÉS' not in m_upper and 'INGLES' not in m_upper:
                     continue
            
            is_english = 'INGLÉS' in m_upper or 'INGLES' in m_upper
            
            if not is_english:
                 if any(x in m_upper for x in ignorar_total):
                     continue

            if is_english:
                m_clean = "Inglés"
            else:
                m_clean = m_raw.replace('Sala de Cómputo/', '').replace('/Inglés', '').strip()
            
            materia_obj, _ = obtener_o_crear(db, Materia, nombre=m_clean, carrera_id=carrera_obj.id)

            if not is_english and prof_obj:
                materia_obj.profesor_id = prof_obj.id
            
            acad_obj, _ = obtener_o_crear(db, Academia, nombre=f"Academia de {m_clean}")
            materia_obj.academia_id = acad_obj.id
            
            dia_num = item.get("dia")
            dia_nombre = dias_map_inv.get(dia_num, "Lunes")
            
            hora_inicio_int = item.get("hora")
            t_start = datetime.time(hour=hora_inicio_int, minute=0)
            t_end = datetime.time(hour=hora_inicio_int + 1, minute=0)
            
            horario_exists = db.query(Horario).filter_by(
                dia_semana=dia_nombre, hora_inicio=t_start, grupo_id=grupo_obj.id, materia_id=materia_obj.id
            ).first()
            
            if not horario_exists:
                db.add(Horario(
                    dia_semana=dia_nombre, hora_inicio=t_start, hora_fin=t_end,
                    grupo_id=grupo_obj.id, materia_id=materia_obj.id,
                    aula_id=aula_obj.id
                ))

        db.commit()
        print("✓ Datos poblados exitosamente desde JSON")
    except Exception as e:
        print(f"✗ Error al poblar desde JSON: {e}")
        db.rollback()
    finally:
        db.close()

def create_system_users():
    """Crea los usuarios del sistema (admin, escolares y jefes de carrera)."""
    print(" Creando usuarios del sistema...")
    db = SessionLocal()
    try:
        fijos = [
            ("admin", "admin123", "administrador", "admin@escuela.edu.mx", None),
            ("escolares", "escolares123", "servicios_escolares", "escolares@escuela.edu.mx", None)
        ]
        for user, pwd, role, email, carrera in fijos:
            print(f"  Procesando usuario fijo: {user}")
            if not db.query(User).filter_by(username=user).first():
                db.add(User(username=user, hashed_password=obtener_hash_password(pwd), role=role, email=email, carrera=carrera, is_active=1))
        
        db.commit() # Commit fixed users first
        
        # Obtener carreras de la API para tener nombres completos
        try:
            from src.integracion_horarios.services.carrera_service import CarreraService
            carrera_service = CarreraService()
            carreras_api = carrera_service.obtener_todas_carreras()
            
            # Crear mapeo de clave -> nombre completo y viceversa
            carrera_map = {c['clave']: c['nombre'] for c in carreras_api if c.get('vigente', True)}
            nombre_to_clave = {c['nombre']: c['clave'] for c in carreras_api if c.get('vigente', True)}
        except Exception as e:
            print(f"  No se pudieron obtener carreras de API: {e}")
            # Usar mapeo manual como fallback
            carrera_map = {
                '06': 'LICENCIATURA EN INFORMÁTICA',
                '06B': 'LICENCIATURA EN INFORMÁTICA 2022',
                '03C': 'LICENCIATURA EN ENFERMERÍA',
                '04B': 'LICENCIATURA EN CIENCIAS EMPRESARIALES',
                '05C': 'LICENCIATURA EN ADMINISTRACIÓN PÚBLICA',
                '07B': 'LICENCIATURA EN NUTRICIÓN',
                '08': 'MAESTRÍA EN PLANEACIÓN ESTRATÉGICA MUNICIPAL',
                '09': 'MAESTRÍA EN SALUD PÚBLICA',
                '10': 'MAESTRÍA EN GOBIERNO ELECTRÓNICO',
                '11': 'DOCTORADO EN GOBIERNO ELECTRÓNICO',
            }
            nombre_to_clave = {v: k for k, v in carrera_map.items()}
        
        carreras = db.query(Carrera).all()
        print(f"  Encontradas {len(carreras)} carreras para crear jefes")
        
        for c in carreras:
            # Obtener la clave de carrera (usamos el código guardado en el objeto Carrera)
            clave_carrera = c.codigo
            nombre_lower = c.nombre.lower()
            
            # Determinar prefijo según el grado para evitar colisiones (ej: Maestría vs Doctorado)
            prefix = "jefe"
            if "maestría" in nombre_lower:
                prefix = "jefe_mtr"
            elif "doctorado" in nombre_lower:
                prefix = "jefe_dr"
            elif "especialidad" in nombre_lower:
                prefix = "jefe_esp"
            
            clean = nombre_lower.replace("licenciatura en ", "").replace("maestría en ", "").replace("doctorado en ", "").replace("especialidad en ", "")
            
            # Quitar años al final si queda alguno
            import re
            clean = re.sub(r'\s+\d{4}$', '', clean).strip()
            
            accents = {'á':'a', 'é':'e', 'í':'i', 'ó':'o', 'ú':'u', 'ñ':'n'}
            for k, v in accents.items():
                clean = clean.replace(k, v)
            
            clean = clean.replace(" ", "_").replace(".", "").replace("-", "_")
            username_base = f"{prefix}_{clean}"
            username = username_base
            
            # Evitar colisiones si por alguna razón el nombre limpio sigue siendo igual
            counter = 1
            while db.query(User).filter_by(username=username).first():
                # Si ya existe un usuario con este username pero es para OTRA carrera, añadir número
                existing_user = db.query(User).filter_by(username=username).first()
                if existing_user.carrera == clave_carrera:
                    break # Ya existe para esta carrera, no hacer nada
                username = f"{username_base}_{counter}"
                counter += 1
            
            if not db.query(User).filter_by(username=username).first():
                print(f"  -> Creando usuario: {username} para {c.nombre}")
                db.add(User(
                    username=username, hashed_password=obtener_hash_password("jefe123"),
                    role="jefe_carrera", email=f"{username}@escuela.edu.mx", 
                    carrera=clave_carrera,
                    is_active=1
                ))
        
        db.commit()
        print("✓ Usuarios creados")
    except Exception as e:
        print(f"✗ Error en usuarios: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Configuración unificada del sistema")
    parser.add_argument("--reset", action="store_true", help="Borrar y recrear todo")
    args = parser.parse_args()

    print(" Iniciando configuración unificada...")
    if args.reset:
        clean_db()
    
    setup_tables()
    run_migrations()
    populate_from_api()  # Ahora usa la API externa primero
    create_system_users()
    print("\n SISTEMA LISTO")
