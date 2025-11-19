# Solución Definitiva para NAT con Docker

## Problema

`external_media_address` en el transport UDP no se está aplicando correctamente en Asterisk 16.

## Solución: Configurar STUN

En lugar de confiar en `external_media_address`, vamos a usar STUN para que Asterisk descubra automáticamente su IP externa.

### Paso 1: Revertir host mode

Ejecuta en PowerShell:

```powershell
docker compose down
docker compose up -d
```

Espera a que todos los servicios estén corriendo (unos 30 segundos).

### Paso 2: Crear rtp.conf

Vamos a crear un archivo de configuración RTP que use STUN.

Crea el archivo `asterisk/conf/rtp.conf` con este contenido:

```ini
[general]
rtpstart=10000
rtpend=20000
; Configuración NAT para Docker
; STUN permite que Asterisk descubra su IP pública automáticamente
stunaddr=stun.l.google.com:3478
; IP externa del host (fallback si STUN falla)
external media_address=192.168.1.34
icesupport=yes
```

### Paso 3: Actualizar pjsip.conf para usar STUN

Además del `external_media_address`, necesitamos asegurarnos que PJSIP use STUN.

En `asterisk/conf/pjsip.conf`, busca `[transport-udp]` y asegúrate que tenga:

```ini
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0
external_media_address=192.168.1.34
external_signaling_address=192.168.1.34
local_net=192.168.100.0/24
```

### Paso 4: Rebuild

```powershell
docker compose down
docker compose build --no-cache asterisk
docker compose up -d
```

### Paso 5: Verificar

Llama a extensión 600 desde Zoiper y verifica en los logs que ahora envía:

```
c=IN IP4 192.168.1.34   ← IP del host (CORRECTO)
```

En lugar de:

```
c=IN IP4 192.168.100.3  ← IP de Docker (INCORRECTO)
```

---

**Si esto tampoco funciona**, el problema puede ser una limitación de Asterisk 16 con Docker. En ese caso, la única solución real es:

1. Usar Asterisk 20+ (mejor soporte NAT)
2. Exponer Asterisk directamente en el host sin Docker para esta prueba
3. Usar un proxy RTP externo (más complejo)
