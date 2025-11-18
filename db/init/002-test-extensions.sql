-- ============================================================================
-- Script de inicialización de extensiones de prueba para Asterisk
-- Ambiente: Calidad (QA)
-- Fecha: 2025-11-18
-- ============================================================================
--
-- Este script crea 3 extensiones de prueba para validar:
-- - Registro SIP/PJSIP
-- - Llamadas de audio
-- - Llamadas de video (H.264)
-- - WebRTC desde navegador
--
-- EXTENSIONES CREADAS:
-- - 1001: Extensión de prueba 1 (usuario: test1001, password: Test1001!)
-- - 1002: Extensión de prueba 2 (usuario: test1002, password: Test1002!)
-- - 1003: Extensión de prueba 3 (usuario: test1003, password: Test1003!)
--
-- ============================================================================

\c asterisk;

-- ============================================================================
-- EXTENSIÓN 1001
-- ============================================================================

-- Endpoint (configuración del dispositivo)
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
    webrtc
) VALUES (
    '1001',                    -- ID único
    'transport-udp',           -- Transporte UDP
    '1001',                    -- AOR asociado
    '1001',                    -- Auth asociado
    'testing',                 -- Contexto del dialplan
    'all',                     -- Deshabilitar todos los codecs primero
    'ulaw,alaw,h264,vp8,vp9', -- Permitir audio (ulaw,alaw) y video (h264,vp8,vp9)
    'no',                      -- Forzar media through Asterisk
    'yes',                     -- Soporte ICE para NAT/WebRTC
    'yes',                     -- Force rport para NAT
    'yes',                     -- Reescribir contacto para NAT
    'yes',                     -- RTP simétrico
    'yes',                     -- Session timers
    'no'                       -- WebRTC (cambiar a 'yes' si se usa desde navegador)
);

-- Auth (autenticación)
INSERT INTO ps_auths (
    id,
    auth_type,
    password,
    username
) VALUES (
    '1001',
    'userpass',
    'Test1001!',
    'test1001'
);

-- AOR (Address of Record - dirección de registro)
INSERT INTO ps_aors (
    id,
    max_contacts,
    remove_existing,
    qualify_frequency
) VALUES (
    '1001',
    1,          -- Solo 1 dispositivo registrado a la vez
    'yes',      -- Remover registros anteriores
    60          -- Verificar cada 60 segundos si sigue activo
);

-- ============================================================================
-- EXTENSIÓN 1002
-- ============================================================================

INSERT INTO ps_endpoints (
    id, transport, aors, auth, context, disallow, allow,
    direct_media, ice_support, force_rport, rewrite_contact,
    rtp_symmetric, timers, webrtc
) VALUES (
    '1002', 'transport-udp', '1002', '1002', 'testing', 'all', 'ulaw,alaw,h264,vp8,vp9',
    'no', 'yes', 'yes', 'yes', 'yes', 'yes', 'no'
);

INSERT INTO ps_auths (id, auth_type, password, username)
VALUES ('1002', 'userpass', 'Test1002!', 'test1002');

INSERT INTO ps_aors (id, max_contacts, remove_existing, qualify_frequency)
VALUES ('1002', 1, 'yes', 60);

-- ============================================================================
-- EXTENSIÓN 1003
-- ============================================================================

INSERT INTO ps_endpoints (
    id, transport, aors, auth, context, disallow, allow,
    direct_media, ice_support, force_rport, rewrite_contact,
    rtp_symmetric, timers, webrtc
) VALUES (
    '1003', 'transport-udp', '1003', '1003', 'testing', 'all', 'ulaw,alaw,h264,vp8,vp9',
    'no', 'yes', 'yes', 'yes', 'yes', 'yes', 'no'
);

INSERT INTO ps_auths (id, auth_type, password, username)
VALUES ('1003', 'userpass', 'Test1003!', 'test1003');

INSERT INTO ps_aors (id, max_contacts, remove_existing, qualify_frequency)
VALUES ('1003', 1, 'yes', 60);

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================

-- Mostrar extensiones creadas
SELECT 'EXTENSIONES CREADAS:' as info;
SELECT id, context, allow as codecs FROM ps_endpoints WHERE id IN ('1001', '1002', '1003');

SELECT 'CREDENCIALES:' as info;
SELECT id, username, password FROM ps_auths WHERE id IN ('1001', '1002', '1003');

SELECT 'CONFIGURACIÓN REALIZADA EXITOSAMENTE' as status;
