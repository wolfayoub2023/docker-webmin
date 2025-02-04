FROM pschatzmann/webmin

# Disable SSL in Webmin config
RUN sed -i 's/ssl=1/ssl=0/' /etc/webmin/miniserv.conf

# Expose Webmin default port (10000)
EXPOSE 10000

# Restart Webmin to apply changes
CMD ["/etc/init.d/webmin", "restart"] 
