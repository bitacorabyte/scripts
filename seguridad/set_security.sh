#!/bin/sh
# by:   bitacorabyte
# date: 20220118
# Entorno de desarrollo: debian 10 (Buster)
##
# Este script realiza las siguientes tareas:
# 1. Actualiza el sistema
# 2. Instala Fail2Ban
# 3. Crea un grupo de usuarios, un usuario y lo añade al grupo anterior
# 4. Modifica el archivo de configuración de ssh para:
#    - Deshabilitar el acceso ssh a root
#    - No permitir claves vacias
#    - Denegar el acceso ssh a todos los grupos
#    - Permitir el acceso ssh solo al grupo creado anteriormente
# 5. Reiniciar el servicio ssh
##
# 1. Actualizar sistema
echo "1. ACTUALIZANDO SISTEMA"
apt update && apt upgrade -y
# 2. Instalando Fail2ban
echo "2. INSTALANDO FAIL2BAN"
apt install fail2-ban
# 3. SSH. Crear grupo y usuario espec  fico
echo "SSH. CREANDO GRUPO Y USUARIO"
echo -n "Nombre del grupo de usuarios para SSH: "
read -r grupo
addgroup $grupo
echo -n "Usuario: "
read -r user
adduser --ingroup $grupo $user
# 4. SSH. Modificando archivo de configuraci  n
echo 'SSH. MODIFICANDO LA CONFIGURACI ^sN'
sed -i -e '$aPermitRootLogin No\nPermitEmptyPasswords No\nDenyGroups All\nAllowGroups '"$grupo"'' /etc/ssh/sshd_config
# 5. SSH. Reiniciar servicio
service ssh restart