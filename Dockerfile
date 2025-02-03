FROM ubuntu:22.04

# Prevent service startup during installation
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

# Install dependencies with proper cleanup
RUN apt-get -o APT::Get::Lock::Timeout=60 update && \
    apt-get install -y \
    wget \
    perl \
    gnupg \
    ca-certificates \
    && \
    wget -qO- https://www.webmin.com/jcameron-key.asc | gpg --batch --dearmor > /etc/apt/trusted.gpg.d/webmin.gpg && \
    echo "deb https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list && \
    apt-get -o APT::Get::Lock::Timeout=60 update && \
    apt-get install -y webmin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Cleanup policy file
RUN rm -f /usr/sbin/policy-rc.d

# Configure Webmin for Render
RUN echo "#!/bin/sh" > /start-webmin.sh && \
    echo "sed -i \"s/^port=.*/port=\${PORT}/\" /etc/webmin/miniserv.conf" >> /start-webmin.sh && \
    echo "exec /usr/share/webmin/miniserv.pl /etc/webmin/miniserv.conf" >> /start-webmin.sh && \
    chmod +x /start-webmin.sh

# Set default credentials
RUN echo "root:webmin" | chpasswd

EXPOSE 10000
CMD ["/start-webmin.sh"]
