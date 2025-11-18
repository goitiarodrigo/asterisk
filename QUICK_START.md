# ⚡ Quick Start - Asterisk Ambiente de Calidad

## 🚀 Inicio Rápido (5 minutos)

### 1. Levantar servicios
```bash
docker build -t asterisk-normal:22.5.1 .
docker compose up -d
```

### 2. Verificar
```bash
docker exec -it asterisk /verify-asterisk.sh
```

### 3. Configurar Zoiper

**Extensión 1001:**
- Domain: `<IP_SERVIDOR>`
- Username: `test1001`
- Password: `Test1001!`
- Port: `5060` (UDP)

**Extensión 1002:**
- Domain: `<IP_SERVIDOR>`
- Username: `test1002`
- Password: `Test1002!`
- Port: `5060` (UDP)

### 4. Probar
- Desde 1001 marcar: `1002`
- Debería sonar y conectar ✅

---

## 📋 Credenciales Completas

| Ext  | Usuario   | Password   |
|------|-----------|------------|
| 1001 | test1001  | Test1001!  |
| 1002 | test1002  | Test1002!  |
| 1003 | test1003  | Test1003!  |

---

## 🔍 Comandos Útiles

```bash
# Ver logs
docker logs -f asterisk

# Consola de Asterisk
docker exec -it asterisk asterisk -rvvv

# Ver extensiones registradas
docker exec -it asterisk asterisk -rx "pjsip show endpoints"

# Reiniciar Asterisk
docker restart asterisk

# Detener todo
docker compose down
```

---

## 📚 Documentación Completa

Ver **GUIA_AMBIENTE_CALIDAD.md** para:
- Configuración detallada
- Pruebas de video
- Troubleshooting
- WebRTC setup

---

## ⚠️ Troubleshooting Básico

**Problema**: Zoiper no se registra
- Verificar IP del servidor
- Verificar firewall: `sudo ufw allow 5060/udp`
- Ver logs: `docker logs -f asterisk`

**Problema**: No hay audio/video
- Abrir puertos RTP: `sudo ufw allow 10000:20000/udp`
- Verificar codecs en Zoiper

**Problema**: Asterisk no inicia
- Ver logs: `docker logs asterisk`
- Verificar que PostgreSQL esté corriendo: `docker ps | grep ast-db`
