import sqlite3
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json

app = FastAPI(title="API del Proyecto", version="1.0")

# Configuración de la base de datos
DATABASE_PATH = os.getenv("DATABASE_PATH", "db/project.db")

def get_db_connection():
    """Obtiene una conexión a la base de datos SQLite."""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_database():
    """Inicializa la base de datos con las tablas necesarias."""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Leer y ejecutar los archivos SQL de inicialización
    sql_files = ["db/init/base.sql", "db/init/funciones.sql", "db/init/vistas.sql"]
    
    for sql_file in sql_files:
        if os.path.exists(sql_file):
            with open(sql_file, 'r', encoding='utf-8') as f:
                sql_content = f.read()
                try:
                    cursor.executescript(sql_content)
                except sqlite3.OperationalError as e:
                    # Ignorar errores de tablas que ya existen
                    if "already exists" not in str(e):
                        print(f"Error ejecutando {sql_file}: {e}")
    
    conn.commit()
    conn.close()

# Inicializar la base de datos al iniciar la aplicación
init_database()

@app.get("/", tags=["Root"])
async def read_root():
    """Devuelve un mensaje de bienvenida."""
    return {"message": "Bienvenido a la API del proyecto"}

@app.get("/profesores", tags=["Profesores"])
async def get_profesores():
    """Obtiene todos los profesores."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM profesores")
    profesores = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return profesores

@app.get("/aulas", tags=["Aulas"])
async def get_aulas():
    """Obtiene todas las aulas."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM aulas")
    aulas = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return aulas

@app.get("/examenes", tags=["Exámenes"])
async def get_examenes():
    """Obtiene todos los exámenes programados."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT e.*, te.nombre as tipo_examen, a.nombre as nombre_aula
        FROM examenes e
        JOIN tipos_examen te ON e.tipo_examen_id = te.id
        LEFT JOIN aulas a ON e.aula_id = a.id
    """)
    examenes = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return examenes
