from fastapi import FastAPI

app = FastAPI(title="API del Proyecto", version="1.0")

@app.get("/", tags=["Root"])
async def read_root():
    """Devuelve un mensaje de bienvenida."""
    return {"message": "Bienvenido a la API del proyecto"}

# Aquí puedes añadir más endpoints para interactuar con la base de datos.
# Por ejemplo, para obtener datos de una tabla específica.
