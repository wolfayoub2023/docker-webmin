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
    supervisor \
    expect

# Download and extract Webmin
WORKDIR /opt/webmin
RUN wget https://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz -O webmin.tar.gz && \
    tar -xzf webmin.tar.gz --strip-components=1 && \
    rm webmin.tar.gz

# Create an expect script to automate the Webmin setup
RUN printf '#!/usr/bin/expect -f\n\
set timeout -1\n\
spawn /opt/webmin/setup.sh /opt/webmin\n\
expect "Config file directory" { send "/etc/webmin\\r" }\n\
expect "Log file directory" { send "/var/log/webmin\\r" }\n\
expect "Full path to perl" { send "/usr/bin/perl\\r" }\n\
expect "Web server port" { send "10000\\r" }\n\
expect "Login name" { send "admin\\r" }\n\
expect "Login password" { send "admin-password\\r" }\n\
expect "Password again" { send "admin-password\\r" }\n\
expect "Use SSL" { send "n\\r" }\n\
expect "Start Webmin at boot time" { send "n\\r" }\n\
expect eof\n' > /opt/webmin/setup.expect && chmod +x /opt/webmin/setup.expect

# Run the expect script
RUN /opt/webmin/setup.expect

# Create Supervisor config directory
RUN mkdir -p /etc/supervisor/conf.d

# Create Supervisor configuration file
RUN cat > /etc/supervisor/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:webmin]
command=/usr/bin/perl /opt/webmin/miniserv.pl /etc/webmin/miniserv.conf
autostart=true
autorestart=true
stderr_logfile=/var/log/webmin.err.log
stdout_logfile=/var/log/webmin.out.log
EOF

# Expose Webmin port
EXPOSE 10000

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
