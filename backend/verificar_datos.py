#!/usr/bin/env python3
"""
Script de verificación del estado del sistema.
Muestra un reporte completo de usuarios, carreras y datos académicos.
"""
import sys
import os
from sqlalchemy import text

sys.path.insert(0, os.path.dirname(__file__))

from src.configuracion.base_datos import SessionLocal

def verificar():
    """Genera un reporte completo del estado del sistema."""
    print("\n" + "="*80)
    print(" REPORTE DE ESTADO DEL SISTEMA")
    print("="*80)
    
    db = SessionLocal()
    try:
        users = db.execute(text("SELECT username, role, carrera FROM users")).fetchall()
        print(f"\n✅ USUARIOS CREADOS: {len(users)}")
        for u in users:
            carrera_info = f" ({u.carrera})" if u.carrera else ""
            print(f"  - {u.username} [{u.role}]{carrera_info}")

        carreras = db.execute(text("SELECT id, nombre FROM carreras")).fetchall()
        print(f"\n📚 CARRERAS: {len(carreras)}")
        for c in carreras:
            print(f"  - ID {c.id}: {c.nombre}")

        profesores = db.execute(text("SELECT COUNT(*) FROM profesores")).scalar()
        materias = db.execute(text("SELECT COUNT(*) FROM materias")).scalar()
        grupos = db.execute(text("SELECT COUNT(*) FROM grupos")).scalar()
        horarios = db.execute(text("SELECT COUNT(*) FROM horarios")).scalar()
        examenes = db.execute(text("SELECT COUNT(*) FROM examenes")).scalar()
        academias = db.execute(text("SELECT COUNT(*) FROM academias")).scalar()

        print(f"\n📊 RESUMEN DE DATOS:")
        print(f"  - Profesores: {profesores}")
        print(f"  - Materias:   {materias}")
        print(f"  - Academias:  {academias}")
        print(f"  - Grupos:     {grupos}")
        print(f"  - Horarios:   {horarios}")
        print(f"  - Exámenes:   {examenes}")

        print("\n" + "="*80)
        print("✓ Verificación completada exitosamente")
        print("="*80 + "\n")

    except Exception as e:
        print(f"\n✗ ERROR AL VERIFICAR: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    verificar()
