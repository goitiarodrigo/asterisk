-- ============================================================================
-- Extensiones WebRTC para navegadores (MDT Web)
-- ============================================================================
-- Estas extensiones son para operadores que ven desde el navegador
-- A diferencia de las extensiones 1001-1003 (Zoiper/cámaras),
-- estas usan WebRTC nativo del navegador
--
-- EXTENSIONES CREADAS:
-- - 3001: Operador Web 1 (usuario: webuser3001, password: WebUser3001!)
-- - 3002: Operador Web 2 (usuario: webuser3002, password: WebUser3002!)
-- ============================================================================

\c asterisk;

-- ============================================================================
-- EXTENSIÓN 3001 (Operador Web)
-- ============================================================================

INSERT INTO ps_endpoints (
    id,
    transport,
    aors,
    auth,
    context,
    disallow,
    allow,
    direct_media,
    ice_support,
    force_rport,
    rewrite_contact,
    rtp_symmetric,
    timers,
    webrtc,
    dtls_auto_generate_cert,
    media_encryption,
    use_avpf
) VALUES (
    '3001',
    'transport-wss',       -- WebSocket Secure (no UDP)
    '3001',
    '3001',
    'testing',
    'all',
    'opus,ulaw,alaw,h264,vp8,vp9',  -- Opus para WebRTC
    'no',
    'yes',
    'yes',
    'yes',
    'yes',
    'yes',
    'yes',                 -- WebRTC habilitado
    'yes',                 -- Auto-generar certificados DTLS
    'dtls',                -- Encriptación DTLS para WebRTC
    'yes'                  -- Audio/Video Profile Feedback (requerido para WebRTC)
);

INSERT INTO ps_auths (id, auth_type, password, username)
VALUES ('3001', 'userpass', 'WebUser3001!', 'webuser3001');

INSERT INTO ps_aors (id, max_contacts, remove_existing, qualify_frequency)
VALUES ('3001', 5, 'yes', 60);  -- 5 contactos = 5 tabs del navegador

-- ============================================================================
-- EXTENSIÓN 3002 (Operador Web 2)
-- ============================================================================

INSERT INTO ps_endpoints (
    id, transport, aors, auth, context, disallow, allow,
    direct_media, ice_support, force_rport, rewrite_contact,
    rtp_symmetric, timers, webrtc, dtls_auto_generate_cert,
    media_encryption, use_avpf
) VALUES (
    '3002', 'transport-wss', '3002', '3002', 'testing', 'all', 'opus,ulaw,alaw,h264,vp8,vp9',
    'no', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'yes', 'dtls', 'yes'
);

INSERT INTO ps_auths (id, auth_type, password, username)
VALUES ('3002', 'userpass', 'WebUser3002!', 'webuser3002');

INSERT INTO ps_aors (id, max_contacts, remove_existing, qualify_frequency)
VALUES ('3002', 5, 'yes', 60);

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

SELECT 'EXTENSIONES WEBRTC CREADAS:' as info;
SELECT id, context, webrtc, transport, allow as codecs FROM ps_endpoints WHERE id IN ('3001', '3002');

SELECT 'CREDENCIALES WEBRTC:' as info;
SELECT id, username, password FROM ps_auths WHERE id IN ('3001', '3002');
