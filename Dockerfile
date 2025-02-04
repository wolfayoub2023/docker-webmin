FROM alpine:3.20

# 1. Install required packages
RUN apk add --no-cache perl perl-net-ssleay wget tar shadow bash expect

# 2. Download and extract Webmin 1.991
RUN cd /opt && \
    wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf - && \
    mv webmin-1.991 webmin

# 3. Create an expect script to automate the setup
RUN cat > /opt/webmin/setup.expect << 'EOF'
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
expect "Start Webmin at boot time" { send "y\r" }
expect eof
EOF

# 4. Make the expect script executable
RUN chmod +x /opt/webmin/setup.expect

# 5. Run the expect script
RUN /opt/webmin/setup.expect

# 6. Manually set password and permissions
RUN echo "admin:\$1\$salt\$qH7Y6ygQ3J4q6K8h7GZ3p/" > /etc/webmin/miniserv.users && \
    echo "admin: *" > /etc/webmin/webmin.acl && \
    chmod 600 /etc/webmin/miniserv.users && \
    chmod 600 /etc/webmin/webmin.acl

# 7. Configure for Render
RUN echo "ssl=0" >> /etc/webmin/miniserv.conf && \
    echo "referers=*.onrender.com" >> /etc/webmin/config && \
    echo "port=10000" >> /etc/webmin/miniserv.conf

# 8. Set permissions
RUN chown -R root:root /etc/webmin && \
    chown -R root:root /var/log/webmin

EXPOSE 10000

CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
