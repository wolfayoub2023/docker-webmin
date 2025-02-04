FROM alpine:edge

# Install dependencies
RUN apk update && apk add --no-cache \
    perl \
    perl-net-ssleay \
    perl-io-tty \
    perl-encode \
    openssl \
    wget \
    bash \
    tar \
    gzip \
    supervisor

# Set working directory
WORKDIR /opt

# Download and extract Webmin
RUN wget https://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz -O webmin.tar.gz && \
    tar -xzf webmin.tar.gz && \
    mv webmin-1.991 webmin && \
    rm webmin.tar.gz

# Setup Webmin
RUN cd webmin && \
    ./setup.sh /usr/local/webmin <<EOF
/etc/webmin
/var/log/webmin
/usr/bin/perl
10000
admin
admin-password
admin-password
n
n
EOF

# Create supervisord configuration
RUN mkdir -p /etc/supervisor/conf.d
RUN echo "[program:webmin]" > /etc/supervisor/conf.d/webmin.conf && \
    echo "command=/usr/local/webmin/start" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "stderr_logfile=/var/log/webmin.err.log" >> /etc/supervisor/conf.d/webmin.conf && \
    echo "stdout_logfile=/var/log/webmin.out.log" >> /etc/supervisor/conf.d/webmin.conf

# Expose Webmin port
EXPOSE 10000

# Start Webmin using Supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/webmin.conf"]
