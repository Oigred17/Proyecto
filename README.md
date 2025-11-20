# Proyecto Full Stack con Docker

## Integrantes 
- Daniel Bernardino Reyes Nolasco
- Dergio Eliezer Figueroa Cortés
- Giovany Herrera Lopéz
- Mayra Castellanos Pacheco

Este proyecto contiene una aplicación web completa con un backend en Python (FastAPI), un frontend en React, y una base de datos PostgreSQL. Todo el entorno está containerizado con Docker para un despliegue fácil y consistente.

## Estructura del Proyecto

```
/
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── db/
│   └── init/
│       ├── base.sql
│       ├── funciones.sql
│       └── vistas.sql
├── frontend/
│   ├── Dockerfile
│   ├── public/
│   ├── src/
│   └── ...
├── docker-compose.yml
└── README.md
```

-   **`backend/`**: Contiene la API de FastAPI.
-   **`db/init/`**: Scripts SQL para la inicialización de la base de datos.
-   **`frontend/`**: Contiene la aplicación de React.
-   **`docker-compose.yml`**: Orquesta todos los servicios.

## Requisitos

-   [Docker](https://www.docker.com/get-started)
-   [Docker Compose](https://docs.docker.com/compose/install/) (generalmente incluido con Docker Desktop)

## Instalación y Uso

1.  **Asegurar la IP:**
    Asegúrate de que la dirección IP de tu máquina en la red local sea `132.18.53.85`. La configuración de los contenedores expondrá los servicios a través de esta IP.

2.  **Levantar los Contenedores:**
    Abre una terminal en la raíz de este proyecto y ejecuta el siguiente comando:
    ```bash
    docker-compose up -d --build
    ```
    Este comando construirá las imágenes de los contenedores y los iniciará en segundo plano. La primera vez puede tardar unos minutos.

3.  **Verificar que todo funciona:**
    Puedes ver los logs de los contenedores para asegurarte de que no hay errores:
    ```bash
    docker-compose logs -f
    ```

## Acceder a los Servicios en la Red Local

Una vez que los contenedores estén en funcionamiento, puedes acceder a los servicios desde cualquier dispositivo en la misma red (por ejemplo, el del profesor):

-   **Aplicación Frontend (React):**
    -   **URL:** `http://132.18.53.85`
    -   Esta es la página web principal.

-   **API Backend (FastAPI):**
    -   **URL:** `http://132.18.53.85:8000`
    -   Documentación interactiva de la API disponible en `http://132.18.53.85:8000/docs`.

-   **Gestor de Base de Datos (Adminer):**
    -   **URL:** `http://132.18.53.85:8080`

## Procedimiento para Acceder a la Base de Datos (Adminer)

Para que el profesor o cualquier persona en la red local acceda a la base de datos:

1.  Abrir un navegador web y dirigirse a `http://132.18.53.85:8080`.

2.  En la pantalla de inicio de sesión de Adminer, rellenar los campos de la siguiente manera:
    -   **Sistema:** `PostgreSQL`
    -   **Servidor:** `db` (Importante: este es el nombre del *servicio* de Docker, no la IP)
    -   **Usuario:** `user`
    -   **Contraseña:** `password`
    -   **Base de datos:** `project_db`

3.  Hacer clic en **Login**. Con esto, se tendrá acceso completo a la estructura de la base de datos, incluyendo las tablas, vistas y funciones creadas por tus scripts.

## Entrega del Proyecto

Para la entrega, simplemente comprime toda la carpeta del proyecto (`Proyecto/`) en un único archivo `.zip`.
