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
