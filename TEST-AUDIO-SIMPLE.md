# Prueba de Audio Simple - Configuración Mínima

## Objetivo
Probar audio básico en Asterisk sin necesidad del frontend WebRTC.

## Paso 1: Actualizar contexto de extensiones

Ejecuta estos comandos en **PowerShell** (en tu Windows):

```powershell
cd C:\Users\tu-usuario\ruta\al\proyecto\asterisk

# 1. Ver configuración actual
docker compose exec ast-db psql -U asterisk -d asterisk -c "SELECT id, context, transport FROM ps_endpoints WHERE id IN ('1001', '1002', '1003');"

# 2. Actualizar contexto a 'testing'
docker compose exec ast-db psql -U asterisk -d asterisk -c "UPDATE ps_endpoints SET context = 'testing' WHERE id IN ('1001', '1002', '1003');"

# 3. Recargar Asterisk
docker compose exec asterisk asterisk -rx "pjsip reload"
```

## Paso 2: Probar desde Zoiper

### Prueba 1: Echo Test (extensión 600)
1. Abre Zoiper
2. Asegúrate que estás registrado como extensión **1001**
3. Marca: **600**
4. Espera a que conteste
5. **Habla** - deberías escuchar tu propia voz con un pequeño delay (echo)

### Prueba 2: Hello World (extensión 700)
1. Desde Zoiper marca: **700**
2. Deberías escuchar "Hello world" seguido de números

### Prueba 3: Llamar a otra extensión
1. Si tienes otro Zoiper en extensión **1002** o **1003**
2. Marca: **1002** (o 1003)
3. Deberías poder hablar entre extensiones

## Diagnóstico

Si NO escuchas audio:

```powershell
# Ver logs de Asterisk en tiempo real
docker compose logs -f asterisk

# Ver si hay problema con codecs
docker compose exec asterisk asterisk -rx "core show codecs"

# Ver estado de RTP
docker compose exec asterisk asterisk -rx "rtp show settings"
```

## Notas importantes

- **Esta configuración NO usa WebRTC** - solo SIP/RTP tradicional
- Zoiper debe estar configurado con:
  - Protocolo: UDP o TCP (NO WebSocket)
  - Puerto: 5060 (SIP tradicional)
  - Servidor: IP de tu host (no localhost)
- Si funciona esto, el problema anterior era específico de WebRTC

## ¿Qué hace cada extensión?

- **600**: Echo - devuelve lo que dices (prueba de audio bidireccional)
- **601**: Music on Hold - reproduce música (si está configurada)
- **700**: Hello World - reproduce mensaje grabado (prueba de audio unidireccional)
- **1001-1999**: Llamadas entre extensiones
