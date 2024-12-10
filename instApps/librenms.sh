#!/bin/sh
# by:   bitacorabyte
# date: 20241207
# Entorno de desarrollo: Debian 12 (LXC) (bookworm)
# Basado en la documentación oficial: https://docs.librenms.org/Installation/Install-LibreNMS/#prepare-linux-server
##
# Este script realiza las siguientes tareas:
# 1. Configurar timezone SO
# 2. Actualizar SO
# 3. Instalar paquetes
# 4. Crear usuario librenms
# 5. Descargar librenms
# 6. Establecer permisos
# 7. Instalar dependencias de PHP
# 8. Configurar MariaDB
# 9. Configurar PHP-FPM
# 10. Configurar timezone PHP
# 11. Configurar nginx
# 12. Habilitar comandos lmns
# 13. Configurar snmpd
# 14. Configurar cron
# 15. Habilittar el horario
# 16. Configurar logrotate
##
echo "\033[0;32mEste script instala LibreNMS. Developed on LXC Debian 12"
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 1. CONFIGURANDO EL TIMEZONE"
echo "\033[0;32m###########################################################"
# Set the system timezone
sleep 3
timedatectl set-timezone "Europe/Madrid"
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 2. ACTUALIZAR SO"
echo "\033[0;32m###########################################################"
# Actualizar SO
sleep 3
apt update && apt upgrade -y
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 3. INSTALAR PAQUETES REQUERIDOS"
echo "\033[0;32m###########################################################"
# Instalar paquetes
sleep 3
apt install -y apt-transport-https lsb-release ca-certificates wget acl curl fping git graphviz imagemagick mariadb-client mariadb-server mtr-tiny nginx-full nmap php-cli php-curl php-fpm php-gd php-gmp php-mbstring php-mysql php-snmp php-xml php-zip python3-dotenv python3-pymysql python3-redis python3-setuptools python3-systemd python3-pip rrdtool snmp snmpd unzip whois
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 4. CREAR USUARIO LIBRENMS"
echo "\033[0;32m###########################################################"
# Crear usuario librenms
sleep 3
useradd librenms -d /opt/librenms -M -r -s "$(which bash)"
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 5. DESCARGAR LIBRENMS"
echo "\033[0;32m###########################################################"
# Download LibreNMS
sleep 3
cd /opt
git clone https://github.com/librenms/librenms.git
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 6. ESTABLECER PERMISOS"
echo "\033[0;32m###########################################################"
# Set permissions
sleep 3
chown -R librenms:librenms /opt/librenms
chmod 771 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 7. INSTALAR DEPENDENCIAS DE PHP"
echo "\033[0;32m###########################################################"
# Install PHP dependencies
sleep 3
su librenms bash -c '/opt/librenms/scripts/composer_wrapper.php install --no-dev'
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 8. CONFIGURAR MARIADB"
echo "\033[0;32m###########################################################"
# Configure MariaDB
sleep 3
mysql -uroot -e "CREATE DATABASE librenms CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -uroot -e "CREATE USER 'librenms'@'localhost' IDENTIFIED BY 'Ab123456.';"
mysql -uroot -e "GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"
sed -i '/mysqld]/ a lower_case_table_names=0' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i '/mysqld]/ a innodb_file_per_table=1' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb
systemctl enable mariadb
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 9. CONFIGURAR PHP-FPM"
echo "\033[0;32m###########################################################"
# Configure PHP-FPM
sleep 3
cp /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/librenms.conf
sed -i 's/\[www\]/\[librenms\]/' /etc/php/8.2/fpm/pool.d/librenms.conf
sed -i 's/user = www-data/user = librenms/' /etc/php/8.2/fpm/pool.d/librenms.conf
sed -i 's/group = www-data/group = librenms/' /etc/php/8.2/fpm/pool.d/librenms.conf
sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = \/run\/php-fpm-librenms.sock/' /etc/php/8.2/fpm/pool.d/librenms.conf
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 10. ESTABLECER TIMEZONE EN PHP"
echo "\033[0;32m###########################################################"
# Set timezone in php.ini
sleep 3
sed -i "/;date.timezone =/ a date.timezone = Europe/Madrid" /etc/php/8.2/fpm/php.ini
sed -i "/;date.timezone =/ a date.timezone = Europe/Madrid" /etc/php/8.2/cli/php.ini
read -p "Please review changes in another terminal session then press [Enter] to continue..."
echo " "
### restart PHP-fpm ###
systemctl restart php8.2-fpm
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 11. CONFIGURAR NGINX"
echo "\033[0;32m###########################################################"
# Configure Web Server
sleep 3
echo "server {"> /etc/nginx/conf.d/librenms.conf
echo " listen      80;" >>/etc/nginx/conf.d/librenms.conf
echo " server_name 192.168.88.201;" >>/etc/nginx/conf.d/librenms.conf
echo ' root        /opt/librenms/html;' >>/etc/nginx/conf.d/librenms.conf
echo " index       index.php;" >>/etc/nginx/conf.d/librenms.conf
echo " " >>/etc/nginx/conf.d/librenms.conf
echo " charset utf-8;" >>/etc/nginx/conf.d/librenms.conf
echo " gzip on;" >>/etc/nginx/conf.d/librenms.conf
echo " gzip_types text/css application/javascript text/javascript application/x-javascript image/svg+xml \
text/plain text/xsd text/xsl text/xml image/x-icon;" >>/etc/nginx/conf.d/librenms.conf
echo ' location / {' >>/etc/nginx/conf.d/librenms.conf
echo '  try_files $uri $uri/ /index.php?$query_string;' >>/etc/nginx/conf.d/librenms.conf
echo " }" >>/etc/nginx/conf.d/librenms.conf
echo ' location ~ [^/]\.php(/|$) {' >>/etc/nginx/conf.d/librenms.conf
echo '  fastcgi_pass unix:/run/php-fpm-librenms.sock;' >>/etc/nginx/conf.d/librenms.conf
echo '  fastcgi_split_path_info ^(.+\.php)(/.+)$;' >>/etc/nginx/conf.d/librenms.conf
echo "  include fastcgi.conf;" >>/etc/nginx/conf.d/librenms.conf
echo " }" >>/etc/nginx/conf.d/librenms.conf
echo ' location ~ /\.(?!well-known).* {' >>/etc/nginx/conf.d/librenms.conf
echo "  deny all;" >>/etc/nginx/conf.d/librenms.conf
echo " }" >>/etc/nginx/conf.d/librenms.conf
echo "}" >>/etc/nginx/conf.d/librenms.conf
rm /etc/nginx/sites-enabled/default
systemctl restart nginx
systemctl restart php8.2-fpm
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 12. HABILITAR LOS COMANDOS DE LNMS"
echo "\033[0;32m###########################################################"
# Enable lnms command completion
sleep 3
ln -s /opt/librenms/lnms /usr/bin/lnms
cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 13. CONFIGURAR SNMPD"
echo "\033[0;32m###########################################################"
# Configure snmpd
sleep 3
cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf
sed -i 's/RANDOMSTRINGGOESHERE/public/g' /etc/snmp/snmpd.conf
curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
chmod +x /usr/bin/distro
systemctl enable snmpd
systemctl restart snmpd
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 14. CONFIGURAR CRON"
echo "\033[0;32m###########################################################"
# Cron job
sleep 3
cp /opt/librenms/dist/librenms.cron /etc/cron.d/librenms
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 15. CONFIGURAR CALENDARIO"
echo "\033[0;32m###########################################################"
# Enable the scheduler
sleep 3
cp /opt/librenms/dist/librenms-scheduler.service /opt/librenms/dist/librenms-scheduler.timer /etc/systemd/system/

systemctl enable librenms-scheduler.timer
systemctl start librenms-scheduler.timer
echo " "
echo "\033[0;32m###########################################################"
echo "\033[0;32mPASO 16. CONFIGURAR LOGROTAT"
echo "\033[0;32m###########################################################"
# Copy logrotate config
sleep 3
cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms