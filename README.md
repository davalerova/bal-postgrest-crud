# API de empleados (Ballerina + PostgreSQL)

API REST en Ballerina (`2201.13.4`) que gestiona empleados sobre PostgreSQL 16.

## Stack y estructura

Servicios definidos en `docker-compose.yml`:

| Servicio | Descripción |
|----------|-------------|
| `app` | Contenedor de desarrollo Ballerina |
| `db` | PostgreSQL 16 (`empresa_db`) |
| `adminer` | UI web para administrar la base de datos |

Archivos principales:

| Archivo | Rol |
|---------|-----|
| `main.bal` | Servicio HTTP con el CRUD de empleados |
| `Config.toml` | Host, credenciales DB y puerto de la app |
| `init/01_schema.sql` | Esquema inicial de la tabla `empleados` |
| `empleados.http` | Peticiones de prueba (REST Client) |

## Requisitos y arranque

1. Abre el proyecto en un Dev Container (`.devcontainer.json` usa compose, servicio `app`, y reenvía los puertos `8080` y `8090`).
2. Dentro del contenedor, inicia la API:

```bash
bal run
```

3. Adminer queda disponible en [http://localhost:8080](http://localhost:8080):
   - Sistema: PostgreSQL
   - Servidor: `db`
   - Usuario / contraseña / base: los de `Config.toml`

## Configuración

Valores actuales en `Config.toml`:

| Clave | Valor |
|-------|-------|
| `dbHost` | `db` |
| `dbUsername` | `postgres` |
| `dbPassword` | `example` |
| `dbName` | `empresa_db` |
| `dbPort` | `5432` |
| `appPort` | `8090` |

La API escucha en `http://localhost:8090`.

## Modelo de datos

Tabla `empleados` (creada por `init/01_schema.sql`):

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | `SERIAL` | Clave primaria |
| `nombre` | `VARCHAR(255)` | Obligatorio |
| `cargo` | `VARCHAR(255)` | Obligatorio |
| `salario` | `NUMERIC` | Obligatorio |

Body JSON de creación/actualización:

```json
{
  "nombre": "Ana García",
  "cargo": "Desarrolladora",
  "salario": 4500.00
}
```

## Endpoints

| Método | Ruta | Descripción | Respuestas |
|--------|------|-------------|------------|
| `GET` | `/empleados` | Lista todos los empleados | `200`, `500` |
| `GET` | `/empleados/{id}` | Obtiene un empleado por id | `200`, `404`, `500` |
| `POST` | `/empleados` | Crea un empleado | `201`, `500` |
| `PUT` | `/empleados/{id}` | Actualiza un empleado | `200`, `404`, `500` |
| `DELETE` | `/empleados/{id}` | Elimina un empleado | `204`, `404`, `500` |

## Cómo probar

1. Con la API en marcha (`bal run`).
2. Abre `empleados.http` (base URL `http://localhost:8090`).
3. Usa la extensión **REST Client** y ejecuta cada bloque con **Send Request**.
