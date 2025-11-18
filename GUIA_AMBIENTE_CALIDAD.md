# 📋 Guía de Configuración - Asterisk Ambiente de Calidad

## 🎯 Objetivo

Habilitar servidor Asterisk en ambiente de calidad para desarrollo y pruebas del sistema MDT de monitoreo de buses.

**Ticket**: Habilitar servidor de Asterisk en ambiente de calidad - probar con clientes como Zoiper para dejarlo operativo para el desarrollo de la MDT.

---

## 📦 ¿Qué incluye esta configuración?

✅ **3 extensiones de prueba** (1001, 1002, 1003) en PostgreSQL Realtime
✅ **Dialplan configurado** para llamadas entre extensiones
✅ **Soporte de video** (codecs H.264, VP8, VP9)
✅ **WebRTC habilitado** (para navegadores)
✅ **Transport SIP UDP** (para Zoiper y dispositivos SIP)
✅ **Transport WebSocket Secure** (para aplicaciones web/MDT)

---

## 🚀 Paso 1: Levantar el Servidor

### 1.1 Build de la imagen Docker

```bash
cd /path/to/asterisk-project
docker build -t asterisk-normal:22.5.1 .
```

**Tiempo estimado**: 3-5 minutos (dependiendo de conexión)

### 1.2 Levantar los servicios

```bash
docker compose up -d
```

Esto levantará:
- **PostgreSQL 16** (puerto 5432)
- **Asterisk 22.5.1** (puertos 5060, 8089, 10000-20000)

### 1.3 Verificar que los contenedores están corriendo

```bash
docker ps
```

Deberías ver:
```
CONTAINER ID   IMAGE                      PORTS                    NAMES
xxxxxxxxxxxx   asterisk-normal:22.5.1     5060/udp, 8089/tcp...   asterisk
xxxxxxxxxxxx   postgres:16                5432/tcp                 ast-db
```

---

## ✅ Paso 2: Verificar la Configuración

### 2.1 Ejecutar script de verificación

```bash
docker exec -it asterisk /verify-asterisk.sh
```

Este script verifica automáticamente:
- ✓ Asterisk corriendo
- ✓ Conexión a PostgreSQL (ODBC)
- ✓ Módulos PJSIP cargados
- ✓ WebSocket habilitado
- ✓ Transportes configurados
- ✓ Extensiones en base de datos
- ✓ Codecs de video disponibles
- ✓ Dialplan [testing] configurado

**Salida esperada**: `✓ VERIFICACIÓN COMPLETADA - TODO OK`

### 2.2 Verificación manual (opcional)

```bash
# Acceder a la consola de Asterisk
docker exec -it asterisk asterisk -rvvv

# Dentro de la consola:
pjsip show endpoints       # Ver extensiones configuradas
pjsip show transports      # Ver transportes (UDP, WSS)
dialplan show testing      # Ver dialplan de pruebas
core show codecs           # Ver codecs disponibles (buscar h264, vp8)
odbc show                  # Verificar conexión PostgreSQL
```

Para salir de la consola: `exit` o `Ctrl+C`

---

## 📱 Paso 3: Configurar Zoiper para Pruebas

### 3.1 Descargar Zoiper

- **Windows/Mac/Linux**: https://www.zoiper.com/en/voip-softphone/download/current
- **Android**: Google Play Store
- **iOS**: App Store

### 3.2 Credenciales de las extensiones de prueba

| Extensión | Usuario    | Password   | Contexto |
|-----------|------------|------------|----------|
| 1001      | test1001   | Test1001!  | testing  |
| 1002      | test1002   | Test1002!  | testing  |
| 1003      | test1003   | Test1003!  | testing  |

### 3.3 Configuración en Zoiper (ejemplo para extensión 1001)

#### Paso 1: Crear nueva cuenta
1. Abrir Zoiper
2. Ir a **Settings** → **Accounts** → **Add Account**
3. Seleccionar **SIP**

#### Paso 2: Configurar cuenta

**Tab "Account":**
```
Account name:        Asterisk 1001
Domain:              <IP_DEL_SERVIDOR_ASTERISK>
Username:            test1001
Password:            Test1001!
Authentication user: test1001
Caller ID:           1001
```

**Tab "Domain":**
```
Domain/Realm:        <IP_DEL_SERVIDOR_ASTERISK>
```

**Tab "Network":**
```
Transport:           UDP
Port:                5060
```

**Tab "Advanced":**
```
☑ Enable STUN
STUN Server:         stun.l.google.com:19302  (opcional, para NAT)
```

#### Paso 3: Guardar y registrar

- Click **OK** / **Save**
- Verificar que aparezca **estado verde** (Registered)

### 3.4 Obtener IP del servidor Asterisk

```bash
# Opción 1: IP del contenedor
docker inspect asterisk | grep IPAddress

# Opción 2: IP del host (si usas network_mode: host)
hostname -I | awk '{print $1}'

# Opción 3: IP pública (si está en servidor remoto)
curl ifconfig.me
```

---

## 🧪 Paso 4: Realizar Pruebas

### 4.1 Prueba de Registro

**Objetivo**: Verificar que Zoiper se registra correctamente en Asterisk.

1. Configurar extensión 1001 en Zoiper (siguiendo Paso 3)
2. Verificar estado: **verde** = Registered ✓
3. Si aparece **rojo** = No registered ✗, ver sección Troubleshooting

**Verificar desde Asterisk**:
```bash
docker exec -it asterisk asterisk -rx "pjsip show endpoints"
```

Buscar la extensión 1001 con estado `Avail`.

### 4.2 Prueba de Llamada de Audio (2 extensiones)

**Objetivo**: Verificar llamadas de audio entre extensiones.

**Requisitos**: 2 dispositivos con Zoiper (o 2 instancias de Zoiper en PC)

1. **Dispositivo A**: Configurar extensión 1001
2. **Dispositivo B**: Configurar extensión 1002
3. Desde **1001**, marcar: `1002`
4. Debería sonar en extensión **1002**
5. Contestar y verificar audio bidireccional

**Monitorear desde Asterisk**:
```bash
docker exec -it asterisk asterisk -rvvv
```
Verás los mensajes de la llamada en tiempo real.

### 4.3 Prueba de Llamada de Video

**Objetivo**: Verificar que funciona video entre extensiones.

1. **Dispositivo A** (1001): Activar cámara en Zoiper
2. Llamar a extensión **1002**
3. **Dispositivo B** (1002): Contestar con video activado
4. Verificar que se ve video bidireccional

**Configuración en Zoiper para video**:
- Settings → Video → **Enable video**
- Seleccionar cámara (webcam)
- Codec preferido: **H.264**

### 4.4 Pruebas adicionales en dialplan

El dialplan [testing] incluye extensiones especiales:

| Extensión | Función                          |
|-----------|----------------------------------|
| **600**   | Echo Test (prueba audio/latencia)|
| **601**   | Music on Hold                    |
| **700**   | Test de sistema (hello world)    |

**Ejemplo**:
- Marcar `600` desde Zoiper → Escucharás tu propia voz (echo)
- Marcar `601` → Escucharás música en espera

---

## 🔍 Paso 5: Monitoreo y Logs

### 5.1 Ver logs de Asterisk en tiempo real

```bash
docker logs -f asterisk
```

### 5.2 Consola de Asterisk (verbose)

```bash
docker exec -it asterisk asterisk -rvvv
```

**Comandos útiles en la consola**:
```
pjsip show endpoints           # Extensiones y su estado
pjsip show registrations       # Quién está registrado
core show channels             # Llamadas activas
dialplan show testing          # Ver dialplan de pruebas
pjsip set logger on            # Activar debug de SIP
core set verbose 5             # Más detalle en logs
```

### 5.3 Ver estado de base de datos

```bash
# Acceder a PostgreSQL
docker exec -it ast-db psql -U asterisk -d asterisk

# Verificar extensiones creadas
SELECT id, context, allow FROM ps_endpoints;

# Verificar credenciales
SELECT id, username, password FROM ps_auths;

# Salir
\q
```

---

## 🐛 Troubleshooting

### Problema 1: Zoiper no se registra (estado rojo)

**Síntomas**: Account status: **Not Registered** (rojo)

**Posibles causas y soluciones**:

1. **Firewall bloqueando puerto 5060**
   ```bash
   # En el servidor, verificar que el puerto esté abierto
   sudo ufw allow 5060/udp
   sudo ufw allow 10000:20000/udp  # RTP para audio/video
   ```

2. **IP incorrecta**
   - Verificar que la IP en Zoiper sea la correcta
   - Hacer ping al servidor: `ping <IP_SERVIDOR>`

3. **Credenciales incorrectas**
   - Verificar usuario/password en Zoiper
   - Verificar en PostgreSQL:
     ```sql
     SELECT * FROM ps_auths WHERE id='1001';
     ```

4. **Transport incorrecto**
   - En Zoiper, asegurarse de usar **UDP** (no TCP ni TLS)

5. **Asterisk no está corriendo**
   ```bash
   docker ps  # Verificar que contenedor 'asterisk' esté up
   docker exec -it asterisk pgrep asterisk  # Debería devolver un PID
   ```

**Ver logs de registro en Asterisk**:
```bash
docker exec -it asterisk asterisk -rvvv
# Luego intentar registrar desde Zoiper y observar mensajes
```

---

### Problema 2: La llamada no se establece

**Síntomas**: Zoiper marca pero no suena en destino, o se corta inmediatamente.

**Soluciones**:

1. **Verificar que ambas extensiones estén registradas**
   ```bash
   docker exec -it asterisk asterisk -rx "pjsip show endpoints"
   # Buscar 1001 y 1002, ambos deben estar "Avail"
   ```

2. **Verificar dialplan**
   ```bash
   docker exec -it asterisk asterisk -rx "dialplan show testing"
   # Debe aparecer el pattern _1XXX
   ```

3. **Verificar contexto de la extensión**
   ```sql
   SELECT id, context FROM ps_endpoints WHERE id IN ('1001','1002');
   -- Ambos deben tener context='testing'
   ```

4. **Revisar logs durante la llamada**
   ```bash
   docker exec -it asterisk asterisk -rvvv
   # Hacer la llamada y observar qué dice Asterisk
   ```

---

### Problema 3: Audio funciona pero video no

**Síntomas**: Se establece la llamada, hay audio, pero no se ve video.

**Soluciones**:

1. **Verificar que Zoiper tenga video habilitado**
   - Settings → Video → ☑ Enable video
   - Verificar que cámara esté seleccionada

2. **Verificar codecs de video**
   ```bash
   docker exec -it asterisk asterisk -rx "core show codecs" | grep -i h264
   # Debe aparecer h264
   ```

3. **Firewall bloqueando RTP**
   ```bash
   # Abrir rango de puertos RTP
   sudo ufw allow 10000:20000/udp
   ```

4. **Verificar que extensión permita H.264**
   ```sql
   SELECT id, allow FROM ps_endpoints WHERE id='1001';
   -- allow debe contener 'h264'
   ```

---

### Problema 4: No se puede conectar a PostgreSQL

**Síntomas**: Error en logs de Asterisk sobre ODBC o PostgreSQL.

**Soluciones**:

1. **Verificar que contenedor de DB esté corriendo**
   ```bash
   docker ps | grep ast-db
   ```

2. **Verificar conexión ODBC desde Asterisk**
   ```bash
   docker exec -it asterisk asterisk -rx "odbc show"
   # Debe aparecer "asterisk" como connected
   ```

3. **Probar conexión manual**
   ```bash
   docker exec -it ast-db psql -U asterisk -d asterisk -c "SELECT 1;"
   # Debe devolver "1"
   ```

4. **Verificar configuración en odbc.ini**
   ```bash
   docker exec -it asterisk cat /etc/odbc.ini
   # Verificar Servername, Database, User, Password
   ```

5. **Reiniciar contenedores**
   ```bash
   docker compose down
   docker compose up -d
   ```

---

### Problema 5: WebRTC no funciona desde navegador

**Síntomas**: No se puede conectar desde aplicación web/MDT.

**Soluciones**:

1. **Verificar que módulo WebSocket esté cargado**
   ```bash
   docker exec -it asterisk asterisk -rx "module show like websocket"
   # Debe aparecer res_http_websocket.so
   ```

2. **Verificar transport WSS**
   ```bash
   docker exec -it asterisk asterisk -rx "pjsip show transports" | grep wss
   ```

3. **Certificados SSL faltantes**
   - WebRTC requiere HTTPS/WSS
   - Para pruebas, generar certificados autofirmados:
   ```bash
   docker exec -it asterisk mkdir -p /etc/asterisk/keys
   docker exec -it asterisk openssl req -new -x509 -days 365 -nodes \
     -out /etc/asterisk/keys/asterisk.pem \
     -keyout /etc/asterisk/keys/asterisk.key
   ```

4. **Descomentar certificados en pjsip.conf**
   - Editar `/asterisk/conf/pjsip.conf`
   - En sección `[transport-wss]`, descomentar:
     ```
     cert_file=/etc/asterisk/keys/asterisk.pem
     priv_key_file=/etc/asterisk/keys/asterisk.key
     ```

5. **Reiniciar Asterisk**
   ```bash
   docker restart asterisk
   ```

---

## 📊 Información de las Extensiones Creadas

### Tabla de Extensiones de Prueba

| Extensión | Usuario   | Password   | Contexto | Codecs Permitidos       | Max Contacts |
|-----------|-----------|------------|----------|-------------------------|--------------|
| 1001      | test1001  | Test1001!  | testing  | ulaw,alaw,h264,vp8,vp9 | 1            |
| 1002      | test1002  | Test1002!  | testing  | ulaw,alaw,h264,vp8,vp9 | 1            |
| 1003      | test1003  | Test1003!  | testing  | ulaw,alaw,h264,vp8,vp9 | 1            |

### Características de las Extensiones

- **Transporte**: UDP (puerto 5060)
- **WebRTC**: Soporte opcional (cambiar `webrtc=yes` en BD)
- **Direct Media**: Deshabilitado (media pasa por Asterisk)
- **ICE Support**: Habilitado (para NAT traversal)
- **RTP Symmetric**: Habilitado (para trabajar con NAT)
- **Qualify Frequency**: 60 segundos (verifica disponibilidad cada minuto)

---

## 🔐 Seguridad (Importante para Producción)

⚠️ **ADVERTENCIA**: Esta configuración es para **ambiente de calidad/desarrollo**.

Para **producción**, considerar:

1. **Cambiar contraseñas**
   - Las contraseñas `Test1001!` son de ejemplo
   - Usar contraseñas fuertes y únicas

2. **Firewall**
   - Limitar acceso al puerto 5060 a IPs conocidas
   - No exponer PostgreSQL (puerto 5432) públicamente

3. **TLS/SRTP**
   - Usar transport TLS en lugar de UDP
   - Habilitar SRTP para encriptar audio/video

4. **Fail2ban**
   - Implementar para bloquear intentos de registro fallidos

5. **ACLs**
   - Configurar ACLs en PJSIP para permitir solo rangos IP autorizados

---

## 📞 Próximos Pasos

Una vez que Zoiper funciona correctamente:

### Para el desarrollo del MDT:

1. **Integrar WebRTC en aplicación web**
   - Usar librería SIP.js o JsSIP
   - Conectar a `wss://<IP_SERVIDOR>:8089/ws`

2. **Mapear cámaras de buses a extensiones**
   - Diseñar esquema: IMEI + Canal → Extensión
   - Crear script para auto-provisionar extensiones desde DB principal

3. **Implementar autenticación**
   - Integrar JWT del portal con credenciales SIP
   - Generar credenciales temporales por sesión

4. **Optimizar para producción**
   - Configurar codecs según ancho de banda disponible
   - Implementar QoS para priorizar video

---

## 📚 Referencias

- **Asterisk PJSIP**: https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/Configuring-res_pjsip/
- **WebRTC con Asterisk**: https://docs.asterisk.org/Configuration/WebRTC/
- **Realtime Database**: https://docs.asterisk.org/Fundamentals/Asterisk-Configuration/Database-Support-Configuration/Realtime-Database-Configuration/
- **Zoiper Documentation**: https://www.zoiper.com/en/support/home

---

## ✅ Checklist de Validación

Antes de dar por completada la configuración, verificar:

- [ ] Contenedores Docker corriendo (`docker ps`)
- [ ] Script de verificación exitoso (`/verify-asterisk.sh`)
- [ ] Al menos 2 extensiones registradas en Zoiper
- [ ] Llamada de audio exitosa entre 2 extensiones
- [ ] Llamada de video exitosa entre 2 extensiones
- [ ] Echo test funciona (extensión 600)
- [ ] Logs de Asterisk sin errores críticos
- [ ] Conexión PostgreSQL estable

---

## 👥 Contacto y Soporte

Para dudas o problemas:
1. Revisar sección **Troubleshooting** de este documento
2. Consultar logs: `docker logs -f asterisk`
3. Revisar documentación oficial de Asterisk

---

**Documento creado**: 2025-11-18
**Ambiente**: Calidad (QA)
**Versión Asterisk**: 22.5.1
**Versión PostgreSQL**: 16
