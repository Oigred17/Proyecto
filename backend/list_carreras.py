from src.configuracion.base_datos import SessionLocal
from sqlalchemy import text
db = SessionLocal()
res = db.execute(text("SELECT id, nombre FROM carreras")).fetchall()
for r in res:
    print(f"{r[0]}: {r[1]}")
db.close()
