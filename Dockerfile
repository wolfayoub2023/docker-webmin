FROM alpine:edge

# Install required dependencies
RUN apk update && apk add --no-cache \
    perl \
    perl-net-ssleay \
    perl-io-tty \
    perl-encode \
    expect \
    openssl \
    wget \
    bash \
    tar \
    gzip

# Download and extract Webmin
WORKDIR /opt/webmin
RUN wget https://prdownloads.sourceforge.net/webadmin/webmin-1.991.tar.gz -O webmin.tar.gz && \
    tar -xzf webmin.tar.gz --strip-components=1 && \
    rm webmin.tar.gz

# Create an expect script to automate the Webmin setup
RUN printf '#!/usr/bin/expect -f\n\
set timeout -1\n\
spawn "/opt/webmin/setup.sh"
expect "Config file directory " {send "\r"}
expect "Log file directory " {send "\r"}
expect "Full path to perl (default /usr/bin/perl):" {send "\r"}
#expect "Operating system:" {send "102\r"}
#expect "Version:" {send "4.9\r"}
expect "Web server port (default 10000):" {send "\r"}
expect "Login name (default admin):" {send "root\r"}
expect "Login password:" {send "root\r"}
expect "Password again:" {send "root\r"}
expect "Use SSL (y/n):" {send  "n\r"}
expect "Start Webmin at boot time (y/n):" {send  "n\r"}
expect eof\n' > /opt/webmin/setup.expect

# Set permissions and run setup
RUN chmod +x /opt/webmin/setup.expect
RUN /opt/webmin/setup.expect

# Expose Webmin default port
EXPOSE 10000

# Start Webmin on container run
CMD ["/usr/local/webmin/start"]
