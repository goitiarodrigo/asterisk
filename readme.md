## Asterisk + PostgreSQL con Docker Compose

Este proyecto permite levantar Asterisk con PostgreSQL usando Docker Compose.

---

## 🎯 Ambiente de Calidad - Configuración Lista

✅ **3 extensiones de prueba configuradas** (1001, 1002, 1003)
✅ **Soporte de video habilitado** (H.264, VP8, VP9)
✅ **WebRTC configurado** (para navegadores)
✅ **Dialplan de testing** con extensiones de prueba

### ⚡ Quick Start

```bash
# 1. Build y levantar
docker build -t asterisk-normal:22.5.1 .
docker compose up -d

# 2. Verificar
docker exec -it asterisk /verify-asterisk.sh

# 3. Configurar Zoiper con:
#    - Usuario: test1001 / Password: Test1001!
#    - Domain: <IP_SERVIDOR>:5060
```

📘 **Guía completa**: Ver `GUIA_AMBIENTE_CALIDAD.md`
⚡ **Inicio rápido**: Ver `QUICK_START.md`

---

#### CREAR LA IMAGEN DE ASTERISK

Antes de levantar los contenedores, es necesario crear la imagen de Asterisk a partir del Dockerfile incluido en el zip. Para ello, desde la carpeta donde se encuentra el Dockerfile, ejecutar:
```
docker build -t CONTAINER_NAME:TAG .
```
#### CONFIGURACIÓN POR DEFECTO (DB LOCAL)

El docker-compose.yml incluye un servicio de PostgreSQL local.
El contenedor de Asterisk depende de la DB local y se inicializa automáticamente.

Para levantar la aplicación:
```
docker compose up -d
```

Para comprobar que los contenedores están corriendo:
```
docker ps
```

Esto levantará:

PostgreSQL 16 (volumen persistente `dbdata`)

Asterisk 22.5.1

Nota: la IP del servidor Asterisk será la IP del contenedor.

#### USO CON BASE DE DATOS EXTERNA

Eliminar el servicio db del docker-compose.yml.

Quitar la línea `depends_on: - db` del servicio asterisk.

Eliminar el volumen `dbdata`.

Editar `asterisk/odbc.ini` y cambiar Servername por la URL de la DB externa, ajustando los otros parámetros si es necesario.

En `db/init/001-ara-schema.sql` descomentar las siguientes líneas si es necesario:
```
--CREATE USER asterisk WITH ENCRYPTED PASSWORD 'asterisk' CREATEDB;
--CREATE DATABASE asterisk OWNER=asterisk;
```

Si hay problemas de permisos en la DB, ejecutar en la consola SQL:
```
GRANT USAGE ON SCHEMA public TO asterisk;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO asterisk;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO asterisk;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO asterisk;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO asterisk;
```

Levantar solo Asterisk:
`docker compose up -d asterisk`

Nota: la IP del servidor Asterisk seguirá siendo la IP del contenedor.
Si deseas que Asterisk use la IP del host, añadir la opción `network_mode: "host"` al servicio de Asterisk en el docker-compose.yml.

#### COMANDOS ÚTILES

Ver logs de Asterisk:
`docker logs -f asterisk`

Reiniciar Asterisk:
`docker restart asterisk`

Detener todo:
`docker compose down`

#### PERSISTENCIA DE DATOS

Con DB local: los datos se guardan en el volumen `dbdata`.

Con DB externa: depende de tu servidor de base de datos.