# 🎥 Monitor de Cámaras - Asterisk WebRTC

Aplicación web React + TypeScript para monitorear cámaras en tiempo real a través de Asterisk con WebRTC.

## 📋 Requisitos

- Node.js 18+ (recomendado: 20+)
- npm o yarn
- Servidor Asterisk configurado y corriendo

## 🚀 Instalación

```bash
# Instalar dependencias
npm install

# O con yarn
yarn install
```

## ⚙️ Configuración

### 1. Obtener IP del servidor Asterisk

```bash
# Desde el servidor donde está Asterisk
docker inspect asterisk | grep IPAddress

# O si usas la IP del host
hostname -I
```

### 2. Aceptar certificados autofirmados (desarrollo)

**IMPORTANTE**: WebRTC requiere HTTPS. En desarrollo usamos certificados autofirmados.

**Antes de usar la app**, visita en tu navegador:

```
https://<IP_SERVIDOR>:8089
```

Ejemplo: `https://192.168.1.100:8089`

Verás un aviso de seguridad. Click en **"Avanzado"** → **"Continuar a sitio (inseguro)"**

Esto es necesario para que el navegador acepte el certificado autofirmado.

### 3. Configurar IP en la aplicación

Al abrir la app, verás un formulario de configuración:

- **Servidor Asterisk**: IP de tu servidor (ejemplo: `192.168.1.100`)
- **Puerto WebSocket**: `8089` (default)
- **Usuario**: `webuser3001`
- **Contraseña**: `WebUser3001!`
- **Extensión**: `3001`

O edita directamente `src/App.tsx`:

```typescript
const DEFAULT_CONFIG: SipConfig = {
  server: '192.168.1.100',    // ⚠️ CAMBIAR por tu IP
  port: '8089',
  username: 'webuser3001',
  password: 'WebUser3001!',
  extension: '3001',
};
```

## 🎬 Uso

### Levantar la aplicación

```bash
npm run dev
```

La app estará disponible en: `http://localhost:3000`

### Workflow de prueba

1. **Levantar Asterisk** (en el servidor):
   ```bash
   docker compose up -d
   docker exec -it asterisk /verify-asterisk.sh
   ```

2. **Configurar "cámaras" (notebooks con Zoiper)**:
   - Notebook 1: Extensión 1001 (test1001 / Test1001!)
   - Notebook 2: Extensión 1002 (test1002 / Test1002!)

3. **Abrir la app web** en el navegador

4. **Conectar a Asterisk** (formulario inicial)

5. **Ver cámaras**: Click en "Conectar" en cada cámara

### Resultado esperado

Deberías ver:
- ✅ Estado "Conectado" en el header
- ✅ Video de Notebook 1 en "Cámara Frontal"
- ✅ Video de Notebook 2 en "Cámara Pasajeros"
- ✅ Video en tiempo real con baja latencia

## 🔧 Troubleshooting

### Error: "Failed to connect"

**Solución 1**: Verificar que Asterisk esté corriendo
```bash
docker ps | grep asterisk
```

**Solución 2**: Verificar que el puerto 8089 esté abierto
```bash
# En el servidor
sudo ufw allow 8089/tcp
```

**Solución 3**: Aceptar certificados autofirmados
- Visitar `https://<IP_SERVIDOR>:8089` y aceptar el certificado

### Error: "WebSocket connection failed"

**Solución**: Verificar que el transport WSS esté configurado en Asterisk
```bash
docker exec -it asterisk asterisk -rx "pjsip show transports" | grep wss
```

Debe aparecer `transport-wss` escuchando en `0.0.0.0:8089`

### No se ve video

**Solución 1**: Verificar que las extensiones estén registradas en Asterisk
```bash
docker exec -it asterisk asterisk -rx "pjsip show endpoints"
```

**Solución 2**: Verificar que las "cámaras" (notebooks) tengan video habilitado en Zoiper

**Solución 3**: Abrir puertos RTP
```bash
sudo ufw allow 10000:20000/udp
```

### Video se congela

**Solución**: Reducir resolución en Zoiper o verificar ancho de banda

## 📁 Estructura del Proyecto

```
web-monitor/
├── src/
│   ├── hooks/
│   │   └── useSipClient.ts      # Hook para gestionar SIP.js
│   ├── components/
│   │   └── CameraStream.tsx     # Componente de video individual
│   ├── App.tsx                  # Componente principal
│   ├── App.css                  # Estilos
│   ├── main.tsx                 # Entry point
│   └── index.css                # Estilos globales
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 🎯 Próximos Pasos

### Para integrar con el MDT real:

1. **Mapear extensiones a buses reales**:
   ```typescript
   const CAMERAS = [
     { extension: '230451', label: 'Bus ABCD12 - Cámara 1', imei: '403230454' },
     { extension: '230452', label: 'Bus ABCD12 - Cámara 2', imei: '403230454' },
   ];
   ```

2. **Integrar autenticación**:
   - Usar JWT del portal actual
   - Generar credenciales SIP desde el backend

3. **Agregar funcionalidades**:
   - Grabación de video
   - PTZ (si las cámaras lo soportan)
   - Notificaciones de eventos
   - Dashboard con múltiples buses

## 🔒 Producción

Para producción:

1. **Usar certificados reales** (Let's Encrypt)
2. **Cambiar logLevel** a 'warn' en `useSipClient.ts`
3. **Build de producción**:
   ```bash
   npm run build
   ```
4. **Servir con nginx** o similar

## 📚 Tecnologías

- **React 18** - UI
- **TypeScript** - Type safety
- **SIP.js** - WebRTC/SIP client
- **Vite** - Build tool
- **Asterisk** - Media server

## 📝 Licencia

Proyecto interno - VecchTelligence
