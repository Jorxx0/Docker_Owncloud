#!/bin/bash

# Variables de configuración de la base de datos
DB_HOST="db1_jorge"
DB_PORT=3306
DB_USER="owncloud"
DB_PASS="owncloudpass"
DB_NAME="owncloud"
WAIT_TIMEOUT=30

# Iniciar PHP-FPM
service php7.4-fpm start

# Función para esperar a que MariaDB esté disponible
wait_for_db() {
  echo "Esperando a que la base de datos en $DB_HOST:$DB_PORT esté disponible..."
  for ((i=1; i<=WAIT_TIMEOUT; i++)); do
    # Intentar conectarse a la base de datos usando PHP y PDO
    if php -r "try { new PDO('mysql:host=$DB_HOST;port=$DB_PORT;', '$DB_USER', '$DB_PASS'); exit(0); } catch (Exception \$e) { exit(1); }"; then
      echo "La base de datos está disponible."
      return 0
    fi
    echo "Intento $i/$WAIT_TIMEOUT: La base de datos no está lista, esperando..."
    sleep 2
  done
  echo "Error: La base de datos no está disponible después de $WAIT_TIMEOUT segundos."
  exit 1
}

# Ejecutar instalación de OwnCloud si no está configurado
install_owncloud() {
  if [ ! -f /var/www/html/owncloud/config/config.php ]; then
    echo "Iniciando instalación de OwnCloud..."
    sudo -u www-data php /var/www/html/owncloud/occ maintenance:install \
      --database "mysql" \
      --database-name "$DB_NAME" \
      --database-user "$DB_USER" \
      --database-pass "$DB_PASS" \
      --database-host "$DB_HOST" \
      --admin-user "admin" \
      --admin-pass "adminpassword"
    echo "Instalación de OwnCloud completada."
  else
    echo "OwnCloud ya está configurado."
  fi
}

# Agregar dominios confiables
add_trusted_domains() {
  echo "Agregando dominios confiables..."
  sudo -u www-data php /var/www/html/owncloud/occ config:system:set trusted_domains 0 --value='localhost'
  sudo -u www-data php /var/www/html/owncloud/occ config:system:set trusted_domains 1 --value='127.0.0.1'
  echo "Dominios confiables agregados correctamente."
}

# Lógica principal
wait_for_db
install_owncloud
add_trusted_domains

# Iniciar Nginx en primer plano
nginx -g "daemon off;"
