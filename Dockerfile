# Start with Debian slim
FROM debian:11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Asterisk dependencies + Asterisk itself
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      asterisk \
      asterisk-dev \
      unixodbc \
      unixodbc-dev \
      odbc-postgresql \
      curl \
      nano \
      net-tools \
      procps \
      openssl \
      # add anything else you need
    && rm -rf /var/lib/apt/lists/*

# Set workdir for Asterisk configs
WORKDIR /etc/asterisk

# Copy your Asterisk configs into the container
COPY asterisk/conf/ /etc/asterisk/
COPY asterisk/odbc.ini /etc/odbc.ini
COPY asterisk/odbcinst.ini /etc/odbcinst.ini

# Copy entrypoint script to container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy verification script
COPY verify-asterisk.sh /verify-asterisk.sh
RUN chmod +x /verify-asterisk.sh

# Copy SSL certificate generation script
COPY generate-ssl-certs.sh /usr/local/bin/generate-ssl-certs.sh
RUN chmod +x /usr/local/bin/generate-ssl-certs.sh

# Expose Asterisk ports
# 5060: SIP UDP/TCP
# 8089: WebSocket Secure (WSS) para WebRTC
# 10000-20000: RTP para audio/video
EXPOSE 5060/udp 5060/tcp 8089/tcp 10000-20000/udp

# Default command: start Asterisk in foreground
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]