# Use Ubuntu LTS as the base image
FROM ubuntu:22.04

# Install dependencies and Webmin
RUN apt-get update && \
    apt-get install -y wget perl gnupg && \
    wget -qO- http://www.webmin.com/jcameron-key.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/jcameron-key.gpg && \
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list && \
    apt-get update && \
    apt-get install -y webmin && \
    apt-get clean

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
