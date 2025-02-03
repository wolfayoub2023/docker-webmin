FROM alpine:3.20

# 1. Install Perl with SSL module as per docs
RUN apk add --no-cache perl perl-net-ssleay

# 2. Download and unpack Webmin 1.991 from documented URL
RUN cd /opt && \
    wget -O - https://github.com/webmin/webmin/archive/refs/tags/1.991.tar.gz | tar -xzf - && \
    mv webmin-1.991 webmin

# 3. Configure Webmin with automatic responses (excluding password)
RUN printf "/etc/webmin\n/var/log/webmin\n\n\n84\nES4.0\n10000\nadmin\n" | /opt/webmin/setup.sh /opt/webmin

# 4. Manually set password after installation
RUN echo "admin:$(perl -e 'print crypt("admin123", "salt")')" > /etc/webmin/miniserv.users && \
    echo "admin: *" > /etc/webmin/webmin.acl

# 5. Configure for Render
RUN echo "ssl=0" >> /etc/webmin/miniserv.conf && \
    echo "referers=*.onrender.com" >> /etc/webmin/config && \
    echo "port=10000" >> /etc/webmin/miniserv.conf

# 6. Fix permissions
RUN chown -R root:root /etc/webmin && \
    chown -R root:root /var/log/webmin

EXPOSE 10000

# 7. Start command from documentation
CMD ["/opt/webmin/miniserv.pl", "/etc/webmin/miniserv.conf"]
