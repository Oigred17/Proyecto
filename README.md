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

## Usuarios de Prueba

Para acceder al sistema, utiliza los siguientes usuarios con sus contraseñas:

| Usuario | Contraseña | Rol | Acceso |
| :--- | :--- | :--- | :--- |
| `admin` | `admin123` | Administrador | Acceso total, incluyendo gestión de usuarios. |
| `escolares` | `escolares123` | Servicios Escolares | Acceso a todo el contenido, excepto gestión de usuarios. |
| `jefe_informatica` | `jefe123` | Jefe de Carrera | Acceso limitado a "Licenciatura en Informática". |
| `jefe_enfermeria` | `enfermeria123` | Jefe de Carrera | Acceso limitado a "Licenciatura en Enfermería". |

## Acceder a los Servicios

Una vez que los contenedores estén en funcionamiento, puedes acceder a los servicios desde cualquier dispositivo en la misma red usando la **IP de tu máquina**:

-   **Aplicación Frontend (React):**
    -   **URL:** `http://<IP_DE_TU_MAQUINA>` (puerto 80)
    -   Ejemplo: `http://192.168.1.100`

-   **API Backend (FastAPI):**
    -   **URL:** `http://<IP_DE_TU_MAQUINA>:8000`
    -   Documentación interactiva: `http://<IP_DE_TU_MAQUINA>:8000/docs`

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
