FROM ubuntu:22.04

# Prevent service startup and configure APT
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d && \
    echo 'APT::Get::Lock::Timeout "60";' > /etc/apt/apt.conf.d/80-render

# Install Webmin with consolidated APT operations
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        perl \
        gnupg \
        ca-certificates && \
    wget -qO- https://www.webmin.com/jcameron-key.asc | gpg --batch --dearmor > /etc/apt/trusted.gpg.d/webmin.gpg && \
    echo "deb https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends webmin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Cleanup policy file
RUN rm -f /usr/sbin/policy-rc.d

# Configure startup script
RUN echo "#!/bin/sh\n" > /start-webmin.sh && \
    echo "sed -i \"s/^port=.*/port=\${PORT}/\" /etc/webmin/miniserv.conf\n" >> /start-webmin.sh && \
    echo "exec /usr/share/webmin/miniserv.pl /etc/webmin/miniserv.conf" >> /start-webmin.sh && \
    chmod +x /start-webmin.sh

# Set default credentials
RUN echo "root:webmin" | chpasswd

EXPOSE 10000
CMD ["/start-webmin.sh"]
