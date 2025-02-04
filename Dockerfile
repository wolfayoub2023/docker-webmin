# Use a minimal base image
FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    perl \
    expect \
    libnet-ssleay-perl \
    libauthen-pam-perl \
    libio-pty-perl \
    libdigest-md5-perl \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Webmin
WORKDIR /opt
RUN wget http://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz -O webmin.tar.gz && \
    tar -xzf webmin.tar.gz && \
    mv webmin-* webmin && \
    rm webmin.tar.gz

# Setup Webmin using Expect to automate input
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

# Run the setup script
RUN /opt/webmin/setup.expect

# Fix networking issues: Ensure Webmin listens on all interfaces
RUN sed -i 's/^listen=127.0.0.1/listen=0.0.0.0/' /etc/webmin/miniserv.conf && \
    echo "allow=0.0.0.0" >> /etc/webmin/miniserv.conf

# Expose Webmin's default port
EXPOSE 10000

# Start Webmin in the foreground to prevent container exit
CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
