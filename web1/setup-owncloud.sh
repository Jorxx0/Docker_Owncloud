#!/bin/bash

# Definición de variables para la configuración de la base de datos y el usuario administrador
DB_HOST="db1_jorge"  # Nombre del servicio MariaDB en docker-compose.yaml
DB_PORT=3306
DB_NAME="owncloud_db"
DB_USER="user_owncloud"
DB_PASS="GHHJHSGDY"
ADMIN_USER="admin"
ADMIN_PASS="admin"

# Función para instalar OwnCloud
install_owncloud() {
  echo "Instalando OwnCloud..."
  # Ejecuta el comando de instalación de OwnCloud con los parámetros definidos
  sudo -u www-data php /var/www/html/owncloud/occ maintenance:install \
    --database "mysql" \
    --database-name "$DB_NAME" \
    --database-user "$DB_USER" \
    --database-pass "$DB_PASS" \
    --database-host "$DB_HOST" \
    --admin-user "$ADMIN_USER" \
    --admin-pass "$ADMIN_PASS" || echo "OwnCloud ya está instalado."
  echo "OwnCloud instalado correctamente."
}

# Función para configurar los dominios confiables
add_trusted_domains() {
  echo "Configurando dominios confiables..."
  # Añade localhost y 127.0.0.1 a la lista de dominios confiables
  sudo -u www-data php /var/www/html/owncloud/occ config:system:set trusted_domains 0 --value="localhost"
  sudo -u www-data php /var/www/html/owncloud/occ config:system:set trusted_domains 1 --value="127.0.0.1"
  echo "Dominios confiables configurados."
}

# Ejecutar las funciones definidas
install_owncloud
add_trusted_domains

echo "OwnCloud listo para usar."
