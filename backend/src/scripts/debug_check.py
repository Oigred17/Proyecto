
from src.configuracion.base_datos import SessionLocal, engine
from src.gestion_academica.modelos import Materia, Grupo, Horario, Profesor
from sqlalchemy import text

def check_db():
    print(f"Connecting to DB: {engine.url}")
    db = SessionLocal()
    try:
        # 1. Verificar Semestres Visibles
        print("\n--- Analisis de Semestres y Grupos Visibles ---")
        grupos = db.query(Grupo).all()
        
        semestres_stats = {}
        
        import re
        for g in grupos:
            match = re.match(r'^(\d+)', g.nombre_grupo)
            if not match: continue
            
            raw_sem = match.group(1)
            # Normalizar semestre: 11 -> 1, 101 -> 1?
            # Asumimos logica del setup: "103" -> Semestre 1?
            # La logica es: Primeros 1 o 2 digitos?
            # Si nombre es '103-F', match es '103'.
            # Logica de setup dice: 
            # if len > 2: int(str[:-2]) -> 103 -> 1.
            
            sem = 0
            if len(raw_sem) > 2:
                try: sem = int(raw_sem[:-2])
                except: pass
            else:
                try: sem = int(raw_sem)
                except: pass
            
            if sem not in semestres_stats:
                semestres_stats[sem] = {"total": 0, "visibles": 0}
            
            semestres_stats[sem]["total"] += 1
            
            # Verificar si visible (tiene materia valida)
            q = db.query(Horario).join(Materia).filter(
                Horario.grupo_id == g.id,
                Materia.profesor_id != None
                # Y NO es Inglés (que no tiene profesor, asi que cubierto)
            )
            count = q.count()
            if count > 0:
                semestres_stats[sem]["visibles"] += 1
            else:
                pass # Invisible
                
        print("Semestre | Grupos Totales | Grupos Visibles (con materias examenables)")
        for s in sorted(semestres_stats.keys()):
            st = semestres_stats[s]
            print(f"   {s:<5} | {st['total']:<14} | {st['visibles']:<30}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_db()
