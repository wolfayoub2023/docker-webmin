FROM alpine:latest

# Install required packages
RUN apk add --no-cache perl perl-net-ssleay wget tar expect

# Set up Webmin
WORKDIR /opt
RUN wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf -
RUN mv webmin-1.991 webmin

# Generate Expect script for automated setup
RUN printf '#!/usr/bin/expect -f\n\
set timeout -1\n\
spawn /opt/webmin/setup.sh /usr/local/webmin\n\
expect "Config file directory" { send "\\r" }\n\
expect "Log file directory" { send "/var/log/webmin\\r" }\n\
expect "Full path to perl" { send "\\r" }\n\
expect "Operating system" { send "84\\r" }\n\
expect "Version" { send "ES4.0\\r" }\n\
expect "Web server port" { send "10000\\r" }\n\
expect "Login name" { send "admin\\r" }\n\
expect "Login password" { send "admin-password\\r" }\n\
expect "Password again" { send "admin-password\\r" }\n\
expect "Use SSL" { send "n\\r" }\n\
expect "Start Webmin at boot time" { send "y\\r" }\n\
expect eof' > /opt/webmin/setup.expect

# Set permissions and run setup
RUN chmod +x /opt/webmin/setup.expect
RUN /opt/webmin/setup.expect

# Expose Webmin default port
EXPOSE 10000

# Start Webmin on container run
CMD ["/usr/local/webmin/start"]
