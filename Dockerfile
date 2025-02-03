# Use Ubuntu LTS as the base image
FROM ubuntu:22.04

# Prevent services from starting during installation
RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

# Install dependencies and Webmin with lock timeout
RUN apt-get -o APT::Get::Lock::Timeout=60 update && \
    apt-get install -y --no-install-recommends \
    wget \
    perl \
    gnupg \
    && \
    wget -qO- http://www.webmin.com/jcameron-key.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/jcameron-key.gpg && \
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list && \
    apt-get -o APT::Get::Lock::Timeout=60 update && \
    apt-get install -y --no-install-recommends webmin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove policy override
RUN rm -f /usr/sbin/policy-rc.d

# Create start script
RUN echo "#!/bin/sh\n" > /start-webmin.sh && \
    echo "sed -i \"s/^port=.*/port=\${PORT}/\" /etc/webmin/miniserv.conf\n" >> /start-webmin.sh && \
    echo "exec /usr/share/webmin/daemon.pl" >> /start-webmin.sh && \
    chmod +x /start-webmin.sh

# Set default root password (change in Render dashboard)
RUN echo "root:webmin-render" | chpasswd

# Expose default port (overridden by Render's PORT)
EXPOSE 10000

# Start Webmin
CMD ["/start-webmin.sh"]
