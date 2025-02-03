FROM alpine:3.20

# Install exact dependencies
RUN apk add --no-cache \
    perl \
    perl-net-ssleay \
    perl-io-socket-ssl \
    wget \
    tar \
    shadow \
    bash \
    && rm -rf /var/cache/apk/*

# Create directories and users
RUN adduser -D webmin \
    && mkdir -p /opt/webmin \
    && mkdir -p /var/log/webmin \
    && mkdir -p /etc/webmin

# Download and extract Webmin
RUN wget -O /tmp/webmin.tar.gz https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz \
    && tar -xzf /tmp/webmin.tar.gz -C /opt/ \
    && mv /opt/webmin-2.115 /opt/webmin \
    && rm /tmp/webmin.tar.gz

# Manual configuration instead of interactive setup
COPY <<EOF /etc/webmin/miniserv.conf
port=10000
root=/opt/webmin
ssl=0
mimetypes=/opt/webmin/mime.types
addtype_cgi=internal/cgi
realm=Webmin Server
logfile=/var/log/webmin/miniserv.log
errorlog=/var/log/webmin/miniserv.error
pidfile=/var/run/webmin.pid
logtime=168
premodules=WebminCore
server=MiniServ/1.991
userfile=/etc/webmin/miniserv.users
keyfile=/etc/webmin/miniserv.pem
passwd_file=/etc/shadow
passwd_uindex=0
passwd_pindex=1
passwd_cindex=2
passwd_mindex=4
passwd_mode=0
preroot=authentic-theme
EOF

# Configure Webmin for Render
RUN echo "port=\$PORT" > /etc/webmin/miniserv.conf \
    && echo "ssl=0" >> /etc/webmin/miniserv.conf \
    && echo "root=/opt/webmin" >> /etc/webmin/miniserv.conf \
    && echo "referers=*.onrender.com" >> /etc/webmin/config \
    && echo "theme=authentic-theme" >> /etc/webmin/config

# Set permissions
RUN chown -R webmin:webmin /opt/webmin \
    && chown -R webmin:webmin /var/log/webmin \
    && chown -R webmin:webmin /etc/webmin

# Install required Perl modules
RUN /opt/webmin/setup.sh /opt/webmin --force --nopostinstall

# Create admin user (change password!)
RUN echo "admin:webmin" | chpasswd \
    && echo "admin: *" > /etc/webmin/miniserv.users

EXPOSE 10000

# Start command with Render compatibility
CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf", "--listen", "0.0.0.0:\$PORT"]
