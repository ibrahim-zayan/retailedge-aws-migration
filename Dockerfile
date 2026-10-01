FROM php:8.2-apache

# Copy application code into the container
COPY . /var/www/html/

# Change Apache to listen on port 8080 instead of 80
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 8080
