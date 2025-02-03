FROM alpine:3.20

# Install exact dependencies from Alpine docs
RUN apk add --no-cache \
    perl \
    perl-net-ssleay \
    wget \
    tar \
    shadow \
    bash \
    && rm -rf /var/cache/apk/*

# Create directories and users as per docs
RUN adduser -D webmin \
    && mkdir -p /opt/webmin \
    && mkdir -p /var/log/webmin \
    && mkdir -p /etc/webmin

# Download and extract Webmin 1.991 from GitHub
RUN wget -O /tmp/webmin.tar.gz https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz \
    && tar -xzf /tmp/webmin.tar.gz -C /opt/ \
    && mv /opt/webmin-1.991 /opt/webmin \
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

# Create required users and permissions
RUN echo "admin:xxxxxxxxxx" > /etc/webmin/miniserv.users \
    && echo "admin:webmin" > /etc/webmin/webmin.acl \
    && chmod 600 /etc/webmin/miniserv.users \
    && chmod 600 /etc/webmin/webmin.acl \
    && echo "admin:\$1\$12345678$v0ZNDlNQWkHthpMvox6rJ." > /etc/webmin/miniserv.pwd

# Set Render-specific configuration
RUN echo "referers=your-render-app.onrender.com" >> /etc/webmin/config \
    && echo "theme=authentic-theme" >> /etc/webmin/config

# Set permissions as per docs
RUN chown -R webmin:webmin /opt/webmin \
    && chown -R webmin:webmin /var/log/webmin \
    && chown -R webmin:webmin /etc/webmin

# Expose Webmin port
EXPOSE 10000

# Start command
CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
