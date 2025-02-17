# Use official PHP image with Apache
FROM php:8.2-apache

# Install required PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html

# Set file permissions
RUN chown -R www-data:www-data /var/www/html

# Expose the port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
