-- ============================================================================
-- Simplificación: Solo Audio (sin video)
-- ============================================================================
-- Este script actualiza las extensiones existentes para solo soportar audio
-- Elimina codecs de video y simplifica la configuración
-- ============================================================================

\c asterisk;

-- Actualizar endpoints para solo audio (sin video)
UPDATE ps_endpoints
SET allow = 'ulaw,alaw'  -- Solo codecs de audio
WHERE id IN ('1001', '1002', '1003');

-- Verificación
SELECT 'CONFIGURACIÓN SIMPLIFICADA - SOLO AUDIO' as status;
SELECT id, context, allow as codecs FROM ps_endpoints WHERE id IN ('1001', '1002', '1003');
