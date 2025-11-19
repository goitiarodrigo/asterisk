# Diagnóstico: external_media_address no se aplica

## Problema

Asterisk sigue enviando la IP de Docker (`192.168.100.3`) en lugar de la IP del host (`192.168.1.34`).

## Verificación 1: ¿Está el archivo correcto en el contenedor?

Ejecuta en PowerShell:

```powershell
docker compose exec asterisk grep -A 5 "transport-udp" /etc/asterisk/pjsip.conf
```

**Deberías ver:**
```
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0
; Configuración NAT para Docker
; El softphone necesita conectarse a la IP del host, no la IP interna de Docker
external_media_address=192.168.1.34
external_signaling_address=192.168.1.34
local_net=192.168.100.0/24
```

**Si NO ves `external_media_address`**, el rebuild no funcionó correctamente.

## Verificación 2: ¿Hiciste el rebuild completo?

Los comandos deben ser:

```powershell
# 1. Detener y eliminar TODO (incluye redes)
docker compose down

# 2. Rebuild SIN cache
docker compose build --no-cache asterisk

# 3. Levantar todo de nuevo
docker compose up -d

# 4. Verificar logs
docker compose logs -f asterisk
```

## Verificación 3: ¿Aplicó Asterisk la configuración?

Si el archivo está correcto pero aún envía IP de Docker, puede ser que Asterisk no esté aplicando el `external_media_address` por alguna razón.

Ejecuta dentro del contenedor:

```powershell
docker compose exec asterisk asterisk -rx "pjsip show transports"
```

Busca `transport-udp` y deberías ver la configuración NAT.

## Solución Temporal: Configurar en endpoints en lugar de transport

Si `external_media_address` no funciona en el transport, podemos configurarlo directamente en cada endpoint.

Ejecuta en PowerShell:

```powershell
docker compose exec ast-db psql -U asterisk -d asterisk -c "UPDATE ps_endpoints SET media_address = '192.168.1.34' WHERE id IN ('1001', '1002', '1003', '600');"

docker compose exec asterisk asterisk -rx "pjsip reload"
```

## Solución Definitiva: Cambiar modo de red de Docker

Si nada funciona, la solución más simple es usar `network_mode: host` que elimina el NAT de Docker completamente.

En `docker-compose.yml`, cambia el servicio asterisk a:

```yaml
asterisk:
  build:
    context: .
    dockerfile: Dockerfile
  image: asterisk-normal:22.5.1
  container_name: asterisk
  network_mode: host  # ← AGREGAR ESTO
  # Remover 'networks:' y 'ports:' porque con host mode no se necesitan
  depends_on:
    - db
  restart: unless-stopped
```

Con `host` mode, Asterisk ve directamente la red del host sin NAT.

---

**Ejecuta la Verificación 1 primero y comparte el resultado**
