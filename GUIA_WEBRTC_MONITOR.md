# 🎥 Guía Completa - Monitor Web de Cámaras con WebRTC

Esta guía te lleva paso a paso para configurar y probar el sistema completo de monitoreo de cámaras usando Asterisk + WebRTC.

---

## 🎯 Objetivo Final

Simular el sistema de monitoreo de buses usando:
- **2 notebooks con webcam** = Cámaras de buses (usando Zoiper)
- **Navegador web** = Operador MDT viendo las cámaras en tiempo real

---

## 📋 Arquitectura

```
┌─────────────────┐      ┌─────────────────┐
│  Notebook 1     │      │  Notebook 2     │
│  (Webcam)       │      │  (Webcam)       │
│                 │      │                 │
│  Zoiper         │      │  Zoiper         │
│  Ext: 1001      │      │  Ext: 1002      │
└────────┬────────┘      └────────┬────────┘
         │                        │
         │    SIP/RTP (UDP)      │
         │                        │
         └────────┬───────────────┘
                  │
                  ▼
         ┌────────────────┐
         │   ASTERISK     │
         │   (Servidor)   │
         │                │
         │ - PJSIP/SIP   │
         │ - WebRTC/WSS  │
         └────────┬───────┘
                  │
                  │ WebRTC (WSS)
                  │
                  ▼
         ┌────────────────┐
         │  NAVEGADOR     │
         │  (Chrome)      │
         │                │
         │  React App     │
         │  Ext: 3001     │
         │                │
         │ [Video 1001]   │
         │ [Video 1002]   │
         └────────────────┘
```

---

## 🚀 Paso 1: Rebuild de Asterisk con WebRTC

Los cambios que hicimos requieren reconstruir la imagen Docker.

### En el servidor Asterisk:

```bash
cd /path/to/asterisk

# Detener contenedores actuales
docker compose down

# Rebuild de la imagen
docker build -t asterisk-normal:22.5.1 .

# Levantar servicios
docker compose up -d

# Esperar 10 segundos para que inicie completamente
sleep 10

# Verificar que todo esté OK
docker exec -it asterisk /verify-asterisk.sh
```

### Verificaciones importantes:

Deberías ver:
- ✅ Asterisk corriendo
- ✅ Conexión ODBC OK
- ✅ Módulo PJSIP cargado
- ✅ Módulo WebSocket cargado ← **NUEVO**
- ✅ Extensiones 1001-1003 en BD
- ✅ Transportes UDP y WSS ← **NUEVO**

### Verificar certificados SSL:

```bash
docker exec -it asterisk ls -la /etc/asterisk/keys/
```

Deberías ver:
```
asterisk.pem
asterisk.key
asterisk-combined.pem
```

Si no existen, se generarán automáticamente al iniciar.

### Verificar transport WSS:

```bash
docker exec -it asterisk asterisk -rx "pjsip show transports"
```

Deberías ver:

```
Transport:  <TransportId........>  <Type>  <cos>  <tos>  <BindAddress...................>
==========================================================================================
transport-udp                      udp      0      0  0.0.0.0:5060
transport-wss                      wss      0      0  0.0.0.0:8089  ← ✅ ESTE ES IMPORTANTE
transport-tcp                      tcp      0      0  0.0.0.0:5060
```

### Verificar extensiones WebRTC:

```bash
docker exec -it asterisk asterisk -rx "pjsip show endpoints" | grep 3001
```

Deberías ver la extensión 3001 (operador web).

### Obtener IP del servidor:

```bash
# Opción 1: IP del host
hostname -I | awk '{print $1}'

# Opción 2: IP pública (si está en servidor remoto)
curl ifconfig.me
```

**Anota esta IP**, la necesitarás más adelante.

---

## 🎬 Paso 2: Configurar "Cámaras" (Notebooks con Zoiper)

### Notebook 1 (Cámara 1)

1. **Instalar Zoiper**: https://www.zoiper.com/en/voip-softphone/download/current

2. **Configurar extensión 1001**:
   - Settings → Accounts → Add Account → SIP
   - **Domain**: `<IP_SERVIDOR>`
   - **Username**: `test1001`
   - **Password**: `Test1001!`
   - **Port**: `5060`
   - **Transport**: UDP

3. **Habilitar video**:
   - Settings → Video → ☑ Enable video
   - Codec: H.264
   - Camera: Seleccionar webcam
   - Preview: Verificar que se ve la cámara

4. **Verificar registro**:
   - Estado debe ser **VERDE** (Registered)

### Notebook 2 (Cámara 2)

Repetir lo mismo pero con:
- **Username**: `test1002`
- **Password**: `Test1002!`

### Verificar desde Asterisk:

```bash
docker exec -it asterisk asterisk -rx "pjsip show endpoints"
```

Deberías ver:
```
Endpoint:  <Endpoint/CID.....................................>  <State.....>  <Channels.>
=============================================================================================
1001                                                             Avail         0 of inf
1002                                                             Avail         0 of inf
```

**Ambos en estado "Avail"** = Todo OK ✅

---

## 🌐 Paso 3: Aceptar Certificados SSL (Importante)

WebRTC **requiere HTTPS**. Como usamos certificados autofirmados para desarrollo, necesitas aceptarlos primero.

### En tu navegador (Chrome/Firefox):

1. Visitar: `https://<IP_SERVIDOR>:8089`
   - Ejemplo: `https://192.168.1.100:8089`

2. Verás un **aviso de seguridad**:
   - Chrome: "Tu conexión no es privada"
   - Firefox: "Advertencia: Riesgo potencial de seguridad a continuación"

3. Click en **"Avanzado"** → **"Continuar a <IP> (no seguro)"**

4. Verás un error de Asterisk (normal, solo estamos aceptando el certificado)

**Este paso es CRÍTICO**. Si no aceptas el certificado, WebRTC NO funcionará.

---

## ⚛️ Paso 4: Configurar y Levantar la App Web

### En tu PC local (no en el servidor):

```bash
# Ir a la carpeta web-monitor
cd /path/to/asterisk/web-monitor

# Instalar dependencias
npm install

# Abrir el proyecto en tu editor (opcional)
code .
```

### Editar configuración (opcional):

Abrir `src/App.tsx` y cambiar la IP:

```typescript
const DEFAULT_CONFIG: SipConfig = {
  server: '192.168.1.100',    // ⚠️ CAMBIAR por la IP de tu servidor
  port: '8089',
  username: 'webuser3001',
  password: 'WebUser3001!',
  extension: '3001',
};
```

### Levantar la app:

```bash
npm run dev
```

Verás:

```
  VITE v5.0.8  ready in 500 ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: http://192.168.1.50:3000/
  ➜  press h to show help
```

### Abrir en el navegador:

```
http://localhost:3000
```

---

## 🎮 Paso 5: Conectar y Ver las Cámaras

### 5.1 Conectar a Asterisk

Verás un formulario de configuración:

1. **Verificar la IP** del servidor Asterisk
2. **Click en "Conectar a Asterisk"**
3. Esperar unos segundos...
4. Deberías ver: **✓ Conectado** en verde

Si ves error:
- Verificar IP
- Verificar que aceptaste certificados SSL (Paso 3)
- Ver logs en consola del navegador (F12 → Console)

### 5.2 Ver Cámara 1 (Notebook 1)

1. En la card "Notebook 1 - Cámara Frontal"
2. Click en **"Conectar"**
3. Esperar 2-3 segundos...
4. Deberías ver el **video en vivo** de la webcam del Notebook 1 🎥

### 5.3 Ver Cámara 2 (Notebook 2)

1. En la card "Notebook 2 - Cámara Pasajeros"
2. Click en **"Conectar"**
3. Deberías ver el **video en vivo** de la webcam del Notebook 2 🎥

### Resultado Final:

```
┌──────────────────────────────────────────────┐
│  🎥 Monitor de Cámaras en Tiempo Real       │
│  ✓ Conectado    Ext: 3001    [Desconectar] │
├──────────────────────────────────────────────┤
│                                              │
│  ┌─────────────────┐  ┌─────────────────┐  │
│  │ Notebook 1      │  │ Notebook 2      │  │
│  │ [VIDEO VIVO 📹] │  │ [VIDEO VIVO 📹] │  │
│  │ ✓ CONECTADO     │  │ ✓ CONECTADO     │  │
│  └─────────────────┘  └─────────────────┘  │
│                                              │
│  Cámaras activas: 2 / 3  [Desconectar Tod.] │
└──────────────────────────────────────────────┘
```

🎉 **¡Éxito! Tienes streaming en tiempo real de 2 cámaras simultáneas**

---

## 🧪 Paso 6: Pruebas Adicionales

### Probar latencia:

1. Mover la mano frente a la webcam del Notebook 1
2. Observar en el navegador web
3. **Latencia esperada**: < 500ms (medio segundo)

### Probar múltiples operadores:

1. Abrir otra pestaña del navegador
2. Conectar con extensión **3002** (webuser3002 / WebUser3002!)
3. Conectar a las mismas cámaras
4. Ambos operadores ven el mismo video ✅

### Probar reconexión:

1. Desconectar Cámara 1
2. Esperar 5 segundos
3. Volver a conectar
4. Debería funcionar sin problemas

### Probar con 3 cámaras:

Si tienes un tercer dispositivo (móvil, tablet):
- Configurar extensión **1003** (test1003 / Test1003!)
- Conectar desde la web
- Ver 3 videos simultáneos

---

## 🐛 Troubleshooting

### Problema: "Failed to connect to Asterisk"

**Causa**: No se puede conectar al WebSocket WSS

**Soluciones**:

1. **Verificar que Asterisk esté corriendo**:
   ```bash
   docker ps | grep asterisk
   ```

2. **Verificar certificados aceptados** (Paso 3):
   - Visitar `https://<IP>:8089` y aceptar

3. **Verificar firewall**:
   ```bash
   sudo ufw allow 8089/tcp
   ```

4. **Ver logs de Asterisk**:
   ```bash
   docker logs -f asterisk
   ```

5. **Ver consola del navegador**:
   - F12 → Console
   - Buscar errores de WebSocket

---

### Problema: "Conexión OK pero no se ve video"

**Causa**: Extensiones no registradas o problemas de RTP

**Soluciones**:

1. **Verificar que Zoiper esté registrado** (verde):
   ```bash
   docker exec -it asterisk asterisk -rx "pjsip show endpoints"
   ```

2. **Verificar que video esté habilitado** en Zoiper:
   - Settings → Video → ☑ Enable video

3. **Abrir puertos RTP**:
   ```bash
   sudo ufw allow 10000:20000/udp
   ```

4. **Ver logs en consola de Asterisk**:
   ```bash
   docker exec -it asterisk asterisk -rvvv
   # Luego conectar desde la web y observar
   ```

---

### Problema: "Video se congela o pixela"

**Causa**: Ancho de banda insuficiente

**Soluciones**:

1. **Reducir resolución en Zoiper**:
   - Settings → Video → Resolution: 480p

2. **Verificar velocidad de Internet**:
   ```bash
   # En el servidor
   speedtest-cli
   ```

3. **Usar red local** (misma WiFi) para pruebas

---

### Problema: "WebSocket error: SSL handshake failed"

**Causa**: Certificados no aceptados

**Solución**:
- Repetir Paso 3 (aceptar certificados)
- Asegurarse de usar `https://` (no `http://`)

---

## 📊 Monitoreo en Tiempo Real

Mientras pruebas, puedes monitorear desde Asterisk:

```bash
# Consola verbose
docker exec -it asterisk asterisk -rvvv

# Ver canales activos
pjsip show endpoints

# Ver llamadas en curso
core show channels

# Ver estadísticas RTP
rtp show stats

# Ver transporte WSS
pjsip show transports
```

---

## ✅ Checklist de Validación

Antes de dar por completado, verificar:

- [ ] Asterisk corriendo con certificados SSL
- [ ] Transport WSS funcionando (puerto 8089)
- [ ] Extensión 1001 registrada (Zoiper - Notebook 1)
- [ ] Extensión 1002 registrada (Zoiper - Notebook 2)
- [ ] Certificados SSL aceptados en navegador
- [ ] App web corriendo (npm run dev)
- [ ] Conexión WebRTC exitosa (ext 3001)
- [ ] Video de cámara 1 funcionando
- [ ] Video de cámara 2 funcionando
- [ ] Latencia < 1 segundo
- [ ] Sin pixelado ni congelamiento

---

## 🎯 Próximos Pasos

Una vez validado con notebooks:

### Fase 1: Integrar con Hardware Real

- Identificar DVR/NVR de los buses
- Configurar DVR para registrarse en Asterisk vía SIP
- Mapear IMEI + Canal → Extensión
- Crear script de auto-provisioning

### Fase 2: Integrar con MDT Existente

- Incorporar componente React en MDT actual
- Autenticación con JWT del portal
- Mapeo dinámico de buses/cámaras
- Dashboard con mapa de flota

### Fase 3: Producción

- Certificados SSL reales (Let's Encrypt)
- Optimizar codecs según 4G/5G
- Implementar grabación
- Monitoreo y alertas

---

## 📚 Documentación Adicional

- **Configuración Asterisk**: Ver `GUIA_AMBIENTE_CALIDAD.md`
- **Quick Start**: Ver `QUICK_START.md`
- **App Web**: Ver `web-monitor/README.md`

---

## 🎉 Conclusión

Si llegaste hasta aquí y todo funciona:

✅ **Tienes un sistema de monitoreo de cámaras en tiempo real completamente funcional**

✅ **Asterisk está configurado como media server**

✅ **WebRTC funcionando desde navegador**

✅ **Listo para escalar a buses reales**

**¡Felicitaciones! 🎊**

---

**Fecha**: 2025-11-19
**Versión**: 1.0
**Ambiente**: Calidad (QA)
