#!/bin/sh
# by:   bitacorabyte
# date: 20210108
# Actualizar sistema
echo "ACTUALIZANDO SISTEMA"
apt update && apt upgrade -y
#
# Instalar dependencias
echo "INSTALANDO DEPENDENCIAS"
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#
# Añadir la clave oficial de Docker
echo "AGREGANDO LA CLAVE DOCKER"
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
#
# Crear el repositorio oficial Dockers
echo "CREANDO REPOSITORIO"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
#
# Instalación de Docker Engine
echo "INSTALANDO DOCKER ENGINE"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io
