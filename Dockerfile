FROM alpine:edge

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    perl \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Download and install Webmin
WORKDIR /opt
RUN wget -O webmin.tar.gz https://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz && \
    tar -xzf webmin.tar.gz && \
    cd $(tar -tzf webmin.tar.gz | head -1 | cut -f1 -d"/") && \
    ./setup.sh /usr/local/webmin <<EOF
/etc/webmin
/var/webmin
/usr/bin/perl
10000
admin
yourpassword
yourpassword
n
n
EOF

# Create Supervisor config directory
RUN mkdir -p /etc/supervisor/conf.d

# Create Supervisor configuration file
RUN echo "[supervisord]" > /etc/supervisor/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/supervisord.conf && \
    echo "[program:webmin]" > /etc/supervisor/conf.d/webmin.conf && \
    echo "command=/usr/local/webmin/start" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "stderr_logfile=/var/log/webmin.err.log" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "stdout_logfile=/var/log/webmin.out.log" >> /etc/supervisor/conf.d/webmin.conf

# Expose Webmin port
EXPOSE 10000

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
