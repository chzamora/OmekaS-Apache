#!/bin/bash
set -e

# Generar el archivo database.ini con las variables de entorno
cat <<EOF > /var/www/html/config/database.ini
[database]
user = "${DATABASE_USER}"
password = "${DATABASE_PASSWORD}"
dbname = "${DATABASE_NAME}"
host = "${DATABASE_HOST}"
;port     = ""
;unix_socket =
;log_path =
EOF

# Asegurar permisos correctos para Apache
chown -R www-data:www-data /var/www/html/config/database.ini
chmod 644 /var/www/html/config/database.ini

# Iniciar Apache en primer plano (el proceso principal del contenedor)
exec apache2-foreground
