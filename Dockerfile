FROM alpine:latest

# Install required packages
RUN apk add --no-cache perl perl-net-ssleay wget tar expect

# Set up Webmin
WORKDIR /opt
RUN wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf -
RUN mv webmin-1.991 webmin

# 3. Create an expect script (WITHOUT INDENTATION)
RUN cat << 'EOF' > /opt/webmin/setup.expect
#!/usr/bin/expect -f
set timeout -1
spawn /opt/webmin/setup.sh /opt/webmin
expect "Config file directory" { send "/etc/webmin\r" }
expect "Log file directory" { send "/var/log/webmin\r" }
expect "Full path to perl" { send "\r" }
expect "Operating system" { send "84\r" }
expect "Version" { send "ES4.0\r" }
expect "Web server port" { send "10000\r" }
expect "Login name" { send "admin\r" }
expect "Login password" { send "admin-password\r" }
expect "Password again" { send "admin-password\r" }
expect "Use SSL" { send "n\r" }
expect eof
EOF

# Set permissions and run setup
RUN chmod +x /opt/webmin/setup.expect
RUN /opt/webmin/setup.expect

# Expose Webmin default port
EXPOSE 10000

# Start Webmin on container run
CMD ["/usr/local/webmin/start"]
