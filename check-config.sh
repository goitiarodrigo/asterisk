# Verificar configuración dentro del contenedor
docker compose exec asterisk grep -A 5 "transport-udp" /etc/asterisk/pjsip.conf
