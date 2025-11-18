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

# Expose Asterisk default SIP + RTP ports
EXPOSE 5060/udp 5060/tcp 10000-20000/udp

# Default command: start Asterisk in foreground
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]