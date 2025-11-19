# 🐳 Deploy con Docker Compose - Sistema Completo

Esta guía explica cómo levantar **todo el sistema** (PostgreSQL + Asterisk + Frontend) con un solo comando usando Docker Compose.

---

## 🎯 ¿Qué incluye?

Con `docker compose up` levantas:

1. **PostgreSQL 16** - Base de datos con extensiones configuradas
2. **Asterisk 22.5.1** - Servidor SIP/WebRTC con certificados SSL
3. **Web Monitor** - Aplicación React para ver las cámaras

Todo en contenedores interconectados y listos para usar.

---

## 🚀 Quick Start (30 segundos)

```bash
# 1. Ir al directorio del proyecto
cd /path/to/asterisk

# 2. Build de todas las imágenes
docker compose build

# 3. Levantar todo
docker compose up -d

# 4. Verificar que todo esté corriendo
docker ps
```

Deberías ver 3 contenedores:
- `ast-db` (PostgreSQL)
- `asterisk` (Asterisk)
- `web-monitor` (Frontend)

---

## 🌐 Acceder a la Aplicación

### Frontend (Monitor de Cámaras)
```
http://localhost:3000
```

La app ya está configurada para conectarse automáticamente a Asterisk en la red interna de Docker.

### Asterisk WebSocket (para desarrollo local)
```
wss://localhost:8089
```

**IMPORTANTE**: Si accedes desde tu navegador local (fuera de Docker), necesitas:

1. **Aceptar certificados SSL**:
   - Visitar `https://localhost:8089`
   - Click en "Avanzado" → "Continuar"

2. **Usar la IP pública** del servidor (no `localhost` ni `asterisk`):
   - En el formulario de configuración de la web
   - Cambiar `asterisk` por la IP real del servidor
   - Ejemplo: `192.168.1.100`

---

## ⚙️ Configuración

### Variables de Entorno

El frontend lee la configuración de variables de entorno definidas en `docker-compose.yml`:

```yaml
environment:
  VITE_ASTERISK_SERVER: asterisk      # Hostname interno de Docker
  VITE_ASTERISK_PORT: 8089
  VITE_SIP_USERNAME: webuser3001
  VITE_SIP_PASSWORD: WebUser3001!
  VITE_SIP_EXTENSION: 3001
```

#### Para cambiar la configuración:

**Opción 1: Editar docker-compose.yml**
```yaml
# En la sección web-monitor → environment
VITE_ASTERISK_SERVER: mi-servidor.com
VITE_SIP_PASSWORD: MiPasswordSeguro123!
```

**Opción 2: Usar archivo .env**

Crear archivo `.env` en la raíz:
```bash
VITE_ASTERISK_SERVER=192.168.1.100
VITE_ASTERISK_PORT=8089
VITE_SIP_USERNAME=webuser3001
VITE_SIP_PASSWORD=WebUser3001!
VITE_SIP_EXTENSION=3001
```

Luego en docker-compose.yml:
```yaml
web-monitor:
  env_file: .env
```

---

## 📊 Arquitectura de Red

Docker Compose crea una red interna `asterisk-network`:

```
┌────────────────────────────────────────┐
│     Docker Network: asterisk-network   │
│                                        │
│  ┌──────────┐   ┌──────────┐         │
│  │   ast-db │◄──┤ asterisk │         │
│  │ (5432)   │   │ (5060)   │         │
│  └──────────┘   │ (8089)   │         │
│                 └────▲─────┘         │
│                      │               │
│                      │               │
│                 ┌────┴──────┐        │
│                 │web-monitor│        │
│                 │  (80)     │        │
│                 └───────────┘        │
└──────────────────┬─────────────────────┘
                   │
                   ▼
              localhost:3000 (host)
```

### Comunicación entre servicios:

- **Frontend → Asterisk**: Usa hostname `asterisk` (resuelto por Docker DNS)
- **Asterisk → PostgreSQL**: Usa hostname `db` (configurado en ODBC)
- **Host → Frontend**: Puerto `3000` mapeado a puerto `80` del contenedor

---

## 🔧 Comandos Útiles

### Ver logs

```bash
# Todos los servicios
docker compose logs -f

# Solo Asterisk
docker compose logs -f asterisk

# Solo frontend
docker compose logs -f web-monitor
```

### Rebuild de un servicio específico

```bash
# Solo frontend (útil después de cambios)
docker compose build web-monitor
docker compose up -d web-monitor

# Solo Asterisk
docker compose build asterisk
docker compose up -d asterisk
```

### Reiniciar servicios

```bash
# Reiniciar todo
docker compose restart

# Solo Asterisk
docker compose restart asterisk
```

### Detener y limpiar

```bash
# Detener todo
docker compose down

# Detener y eliminar volúmenes (⚠️ borra la BD)
docker compose down -v

# Detener y eliminar imágenes
docker compose down --rmi all
```

### Acceder a contenedores

```bash
# Bash en Asterisk
docker exec -it asterisk /bin/bash

# Consola de Asterisk
docker exec -it asterisk asterisk -rvvv

# PostgreSQL
docker exec -it ast-db psql -U asterisk -d asterisk
```

---

## 🧪 Probar el Sistema

### 1. Configurar "cámaras" con Zoiper

En 2 notebooks/PCs con Zoiper:

**Notebook 1:**
- Server: `<IP_DEL_SERVIDOR>`
- Username: `test1001`
- Password: `Test1001!`
- Port: `5060` (UDP)

**Notebook 2:**
- Server: `<IP_DEL_SERVIDOR>`
- Username: `test1002`
- Password: `Test1002!`
- Port: `5060` (UDP)

### 2. Abrir la Web

```
http://localhost:3000
```

Si accedes desde otra PC en la red:
```
http://<IP_SERVIDOR>:3000
```

### 3. Conectar a las cámaras

- La web debería conectarse automáticamente a Asterisk
- Click en "Conectar" en cada cámara
- Deberías ver los videos en tiempo real

---

## 🔐 Seguridad

### Certificados SSL

Los certificados se generan automáticamente al iniciar Asterisk (autofirmados para desarrollo).

Para producción:

1. **Usar certificados reales** (Let's Encrypt):
   ```bash
   # Copiar certificados en asterisk/keys/
   cp /etc/letsencrypt/live/tu-dominio/fullchain.pem asterisk/keys/asterisk.pem
   cp /etc/letsencrypt/live/tu-dominio/privkey.pem asterisk/keys/asterisk.key
   ```

2. **Rebuild Asterisk**:
   ```bash
   docker compose build asterisk
   docker compose up -d asterisk
   ```

### Cambiar Contraseñas

Editar `db/init/002-test-extensions.sql` y `003-webrtc-extensions.sql`:

```sql
-- Cambiar passwords antes del primer deploy
UPDATE ps_auths SET password='NuevoPassword!' WHERE id='1001';
```

O directamente en PostgreSQL:
```bash
docker exec -it ast-db psql -U asterisk -d asterisk
UPDATE ps_auths SET password='NuevoPassword!' WHERE id='1001';
```

---

## 🌍 Desplegar en Servidor Remoto

### En servidor VPS/Cloud:

1. **Clonar repositorio**:
   ```bash
   git clone <repo-url>
   cd asterisk
   ```

2. **Configurar variables de entorno**:
   - Editar `docker-compose.yml`
   - Cambiar `VITE_ASTERISK_SERVER` por la IP pública del servidor

3. **Abrir puertos en firewall**:
   ```bash
   sudo ufw allow 3000/tcp   # Frontend
   sudo ufw allow 5060/udp   # SIP
   sudo ufw allow 8089/tcp   # WebRTC
   sudo ufw allow 10000:10100/udp  # RTP
   ```

4. **Levantar servicios**:
   ```bash
   docker compose up -d
   ```

5. **Acceder**:
   ```
   http://<IP_SERVIDOR>:3000
   ```

---

## 📝 Troubleshooting

### Frontend no carga

```bash
# Ver logs
docker compose logs web-monitor

# Verificar que el contenedor esté corriendo
docker ps | grep web-monitor

# Rebuild
docker compose build web-monitor
docker compose up -d web-monitor
```

### No se conecta a Asterisk

```bash
# Verificar que Asterisk esté corriendo
docker exec -it asterisk asterisk -rx "pjsip show endpoints"

# Verificar certificados
docker exec -it asterisk ls -la /etc/asterisk/keys/

# Ver logs de Asterisk
docker compose logs -f asterisk
```

### Frontend no encuentra Asterisk (error de red)

Si accedes desde **fuera del contenedor** (navegador local):
- Cambiar `asterisk` por la **IP real** del servidor en la configuración
- Aceptar certificados SSL: `https://<IP>:8089`

Si accedes desde **dentro de Docker** (otro contenedor):
- Usar hostname `asterisk` (funciona por Docker DNS)

---

## 🔄 Desarrollo

### Desarrollo local (sin Docker)

**Backend (Asterisk):**
```bash
docker compose up -d db asterisk
```

**Frontend:**
```bash
cd web-monitor
npm install
npm run dev
```

La app en `http://localhost:5173` se conectará a Asterisk en `localhost:8089`.

### Hot Reload del Frontend

Si quieres hot reload en Docker (cambios sin rebuild):

```yaml
# Agregar en docker-compose.yml → web-monitor
volumes:
  - ./web-monitor/src:/app/src:ro
command: npm run dev
```

---

## 📚 Documentación Adicional

- **Guía completa de Asterisk**: `GUIA_AMBIENTE_CALIDAD.md`
- **Guía WebRTC**: `GUIA_WEBRTC_MONITOR.md`
- **Quick Start**: `QUICK_START.md`
- **Frontend README**: `web-monitor/README.md`

---

## ✅ Checklist de Validación

Verificar que todo funciona:

- [ ] 3 contenedores corriendo (`docker ps`)
- [ ] Frontend accesible en `http://localhost:3000`
- [ ] Asterisk responde en `wss://localhost:8089`
- [ ] Extensiones creadas en PostgreSQL
- [ ] Zoiper registrado (ext 1001, 1002)
- [ ] Web se conecta a Asterisk
- [ ] Video de cámaras visible en la web

---

**Fecha**: 2025-11-19
**Versión**: 1.0 - Docker Compose
