FROM alpine:3.20

# 1. Install required packages
RUN apk add --no-cache perl perl-net-ssleay wget tar shadow bash expect

# 2. Download and extract Webmin 1.991
RUN cd /opt && \
    wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf - && \
    mv webmin-1.991 webmin

# 3. Create an expect script to automate the setup
RUN echo '#!/usr/bin/expect -f\n\
set timeout -1\n\
spawn /opt/webmin/setup.sh /opt/webmin\n\
expect "Config file directory" { send "/etc/webmin\\r" }\n\
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
expect eof' > /opt/webmin/setup.expect && \
    chmod +x /opt/webmin/setup.expect

# 4. Run the expect script
RUN /opt/webmin/setup.expect

# 5. Manually set password and permissions
RUN echo "admin:\$1\$salt\$qH7Y6ygQ3J4q6K8h7GZ3p/" > /etc/webmin/miniserv.users && \
    echo "admin: *" > /etc/webmin/webmin.acl && \
    chmod 600 /etc/webmin/miniserv.users && \
    chmod 600 /etc/webmin/webmin.acl

# 6. Configure for Render
RUN echo "ssl=0" >> /etc/webmin/miniserv.conf && \
    echo "referers=*.onrender.com" >> /etc/webmin/config && \
    echo "port=10000" >> /etc/webmin/miniserv.conf

# 7. Set permissions
RUN chown -R root:root /etc/webmin && \
    chown -R root:root /var/log/webmin

EXPOSE 10000

CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
