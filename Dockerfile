FROM alpine:3.20

# 1. Install required packages
RUN apk add --no-cache perl perl-net-ssleay wget tar shadow bash

# 2. Download and extract Webmin 1.991
RUN cd /opt && \
    wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf - && \
    mv webmin-1.991 webmin

# 3. Configure Webmin with automatic responses
RUN printf "/etc/webmin\n/var/log/webmin\n\n\n84\nES4.0\n10000\nadmin\n\n\nn\ny\n" | \
    /opt/webmin/setup.sh /opt/webmin

# 4. Manually set password and permissions
RUN echo "admin:\$1\$salt\$qH7Y6ygQ3J4q6K8h7GZ3p/" > /etc/webmin/miniserv.users && \
    echo "admin: *" > /etc/webmin/webmin.acl && \
    chmod 600 /etc/webmin/miniserv.users && \
    chmod 600 /etc/webmin/webmin.acl

# 5. Configure for Render
RUN echo "ssl=0" >> /etc/webmin/miniserv.conf && \
    echo "referers=*.onrender.com" >> /etc/webmin/config && \
    echo "port=10000" >> /etc/webmin/miniserv.conf

# 6. Set permissions
RUN chown -R root:root /etc/webmin && \
    chown -R root:root /var/log/webmin

EXPOSE 10000

CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
