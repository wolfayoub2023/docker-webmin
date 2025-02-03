# Use Alpine Linux with edge repositories for latest packages
FROM alpine:3.20

# Install dependencies with corrected package names
RUN apk add --no-cache \
    perl \
    perl-net-ssleay \
    perl-io-socket-ssl \
    perl-io-tty \
    perl-encode \
    openssl \
    wget \
    shadow \
    bash \
    nano

# Create webmin user and directories
RUN adduser -D -h /opt/webmin webmin && \
    mkdir -p /var/log/webmin && \
    mkdir -p /opt/webmin

# Download and install Webmin
RUN wget https://download.webmin.com/download/v2/webmin-2.100.tar.gz && \
    tar -xzf webmin-2.100.tar.gz -C /opt/ && \
    rm webmin-2.100.tar.gz && \
    mv /opt/webmin-2.100 /opt/webmin && \
    chown -R webmin:webmin /opt/webmin /var/log/webmin

# Configure Webmin with SSL disabled
RUN echo "port=10000" > /opt/webmin/miniserv.conf && \
    echo "ssl=0" >> /opt/webmin/miniserv.conf && \
    echo "root=/opt/webmin" >> /opt/webmin/miniserv.conf && \
    echo "mimetypes=/opt/webmin/mime.types" >> /opt/webmin/miniserv.conf && \
    echo "addtype_cgi=internal/cgi" >> /opt/webmin/miniserv.conf && \
    echo "realm=Webmin Server" >> /opt/webmin/miniserv.conf && \
    echo "logfile=/var/log/webmin/miniserv.log" >> /opt/webmin/miniserv.conf && \
    echo "errorlog=/var/log/webmin/miniserv.error" >> /opt/webmin/miniserv.conf

# Set default admin credentials (change this in production!)
RUN echo "root:webmin" | chpasswd

# Expose webmin port
EXPOSE 10000

# Start script
CMD ["/opt/webmin/run", "--chdir", "/opt/webmin"]
