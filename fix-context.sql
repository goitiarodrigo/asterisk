-- Script para verificar y actualizar contexto de extensiones de prueba
-- Esto asegura que 1001, 1002, 1003 puedan llamar a las extensiones de prueba (600, 700, etc)

-- Ver configuración actual
SELECT id, context, transport, aors
FROM ps_endpoints
WHERE id IN ('1001', '1002', '1003');

-- Actualizar contexto a 'testing' para que puedan usar las extensiones de prueba
UPDATE ps_endpoints
SET context = 'testing'
WHERE id IN ('1001', '1002', '1003');

-- Verificar el cambio
SELECT id, context, transport, aors
FROM ps_endpoints
WHERE id IN ('1001', '1002', '1003');
