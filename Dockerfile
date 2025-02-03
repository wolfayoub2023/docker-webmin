# Use Alpine Linux edge for latest packages
FROM alpine:3.20

# Install dependencies
RUN apk add --no-cache \
    perl \
    perl-net-ssleay \
    perl-io-socket-ssl \
    perl-io-pty \
    perl-encode-detect \
    openssl \
    wget \
    shadow \
    bash \
    nano

# Create webmin user
RUN adduser -D -h /opt/webmin webmin

# Download and install Webmin
RUN wget https://download.webmin.com/download/v2/webmin-2.100.tar.gz && \
    tar -xzf webmin-2.100.tar.gz -C /opt/ && \
    rm webmin-2.100.tar.gz && \
    mv /opt/webmin-2.100 /opt/webmin

# Configure Webmin
RUN echo "port=10000" > /opt/webmin/miniserv.conf && \
    echo "ssl=0" >> /opt/webmin/miniserv.conf && \
    echo "root=/opt/webmin" >> /opt/webmin/miniserv.conf && \
    echo "mimetypes=/opt/webmin/mime.types" >> /opt/webmin/miniserv.conf && \
    echo "addtype_cgi=internal/cgi" >> /opt/webmin/miniserv.conf && \
    echo "realm=Webmin Server" >> /opt/webmin/miniserv.conf && \
    echo "logfile=/var/log/webmin/miniserv.log" >> /opt/webmin/miniserv.conf && \
    echo "errorlog=/var/log/webmin/miniserv.error" >> /opt/webmin/miniserv.conf && \
    mkdir -p /var/log/webmin && \
    chown -R webmin:webmin /opt/webmin /var/log/webmin

# Set default admin credentials (change in production!)
RUN echo "root:webmin" | chpasswd

# Expose webmin port
EXPOSE 10000

# Start script
CMD ["/opt/webmin/run", "--chdir", "/opt/webmin"]
