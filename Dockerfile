FROM alpine:latest

# Install dependencies
RUN apk add --no-cache perl perl-net-ssleay wget tar expect

# Set environment variables
ENV WEBMIN_VERSION=1.991
ENV WEBMIN_DIR=/opt/webmin

# Download and install Webmin
RUN wget -O - https://github.com/webmin/webmin/archive/refs/tags/$WEBMIN_VERSION.tar.gz | tar -xz -C /opt && \
    mv /opt/webmin-$WEBMIN_VERSION $WEBMIN_DIR

# Create setup script
RUN printf '#!/usr/bin/expect -f\nset timeout -1\nspawn /opt/webmin/setup.sh /usr/local/webmin\nexpect "Config file directory" { send "\r" }\nexpect "Log file directory" { send "/var/log/webmin\r" }\nexpect "Full path to perl" { send "\r" }\nexpect "Operating system" { send "84\r" }\nexpect "Version" { send "ES4.0\r" }\nexpect "Web server port" { send "10000\r" }\nexpect "Login name" { send "admin\r" }\nexpect "Login password" { send "admin-password\r" }\nexpect "Password again" { send "admin-password\r" }\nexpect "Use SSL" { send "n\r" }\nexpect "Start Webmin at boot time" { send "y\r" }\nexpect eof\n' > /opt/webmin/setup.expect

# Set execute permission for the setup script
RUN chmod +x /opt/webmin/setup.expect

# Run Webmin setup
RUN /opt/webmin/setup.expect

# Expose Webmin port
EXPOSE 10000

# Start Webmin service
CMD ["/usr/local/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
