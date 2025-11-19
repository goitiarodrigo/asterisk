## 🎥 Sistema de Monitoreo de Cámaras con Asterisk + WebRTC

Sistema completo de streaming de video en tiempo real usando Asterisk como media server y aplicación web React para monitoreo.

---

## 🚀 Quick Start - Levantar Todo con Docker

```bash
# 1. Build y levantar TODO (DB + Asterisk + Frontend)
docker compose build
docker compose up -d

# 2. Acceder a la aplicación web
http://localhost:3000

# 3. Configurar "cámaras" con Zoiper:
#    - Usuario: test1001 / Password: Test1001!
#    - Domain: <IP_SERVIDOR>:5060
```

🐳 **Deploy completo**: Ver `DEPLOY_DOCKER.md`

---

## 📦 ¿Qué incluye?

### Backend
- ✅ **PostgreSQL 16** - Base de datos con extensiones en Realtime
- ✅ **Asterisk 22.5.1** - Servidor SIP/WebRTC
- ✅ **Extensiones de prueba** (1001, 1002, 1003)
- ✅ **Extensiones WebRTC** (3001, 3002)
- ✅ **Soporte de video** (H.264, VP8, VP9)
- ✅ **Certificados SSL** autofirmados (auto-generados)
- ✅ **Dialplan de testing**

### Frontend
- ✅ **Aplicación React + TypeScript**
- ✅ **WebRTC** para streaming en tiempo real
- ✅ **UI moderna** con grid de cámaras
- ✅ **Conexión/desconexión** individual por cámara
- ✅ **Configuración dinámica** vía variables de entorno

---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| **DEPLOY_DOCKER.md** | 🐳 Guía completa de despliegue con Docker Compose |
| **GUIA_WEBRTC_MONITOR.md** | 🎥 Configuración de WebRTC y pruebas con webcams |
| **GUIA_AMBIENTE_CALIDAD.md** | ⚙️ Configuración de Asterisk y pruebas con Zoiper |
| **QUICK_START.md** | ⚡ Inicio rápido en 5 minutos |
| **web-monitor/README.md** | ⚛️ Documentación del frontend React |

---

## 🌐 Puertos Expuestos

| Puerto | Servicio | Protocolo | Descripción |
|--------|----------|-----------|-------------|
| 3000   | Frontend | HTTP      | Aplicación web de monitoreo |
| 5060   | Asterisk | UDP/TCP   | SIP (para Zoiper/cámaras) |
| 8089   | Asterisk | WSS       | WebSocket Secure (WebRTC) |
| 10000-10100 | Asterisk | UDP | RTP (audio/video) |
| 5432   | PostgreSQL | TCP    | Base de datos (opcional) |

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