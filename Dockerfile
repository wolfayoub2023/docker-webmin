# Use a base image (Alpine for a lightweight container)
FROM alpine:latest

# Install required dependencies
RUN apk update && apk add --no-cache \
    perl \
    expect \
    openssl \
    wget \
    bash \
    tar \
    gzip \
    perl-net-ssleay  # 🔹 Fix: Install Perl SSLeay for SSL support

# Download and extract Webmin
WORKDIR /opt/webmin
RUN wget https://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz -O webmin.tar.gz && \
    tar -xzf webmin.tar.gz --strip-components=1 && \
    rm webmin.tar.gz

# Create an expect script to automate the Webmin setup
RUN printf '#!/usr/bin/expect -f\n\
set timeout -1\n\
spawn /opt/webmin/setup.sh /opt/webmin\n\
expect "Config file directory" { send "/etc/webmin\\r" }\n\
expect "Log file directory" { send "/var/log/webmin\\r" }\n\
expect "Full path to perl" { send "\\r" }\n\
expect "Web server port" { send "10000\\r" }\n\
expect "Login name" { send "admin\\r" }\n\
expect "Login password" { send "admin-password\\r" }\n\
expect "Password again" { send "admin-password\\r" }\n\
expect "Use SSL" { send "y\\r" }\n\
expect "Start Webmin at boot time" { send "y\\r" }\n\
expect eof\n' > /opt/webmin/setup.expect

# Make the expect script executable
RUN chmod +x /opt/webmin/setup.expect

# Run the expect script to set up Webmin
RUN /opt/webmin/setup.expect

# Expose Webmin port
EXPOSE 10000

# Start Webmin on container start
CMD ["/etc/webmin/start"]
