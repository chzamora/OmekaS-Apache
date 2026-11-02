FROM php:8.2-apache

# 1. Instalar dependencias del sistema, Git y extensiones PHP requeridas por Omeka S
RUN apt-get update && apt-get install -y \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        intl \
        mysqli \
        xsl \
        xml \
        opcache

# 2. Habilitar mod_rewrite de Apache para las URLs amigables de Omeka
RUN a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Clonar el repositorio oficial de Omeka S directamente en el directorio web
# (Puedes cambiar la rama o tag usando -b si lo requieres, ej: -b v4.1.1)
RUN rm -rf /var/www/html/* \
    && git clone --depth 1 https://github.com/omeka/omeka-s.git /var/www/html \
    && cd /var/www/html \
    && composer install --no-dev --optimize-autoloader \
    && mv .htaccess.dist .htaccess
    
# Ajustes para integrar configuración requerida para Omeka S
#Ajuste de apache para modReWrite
COPY apache-omeka.conf /etc/apache2/conf-available/omeka.conf
RUN a2enconf omeka

# Configuración de parámetros para base de datos
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Definir el entrypoint por defecto
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 4. Asegurar permisos correctos para el usuario de Apache (www-data)
RUN chown -R www-data:www-data /var/www/html
