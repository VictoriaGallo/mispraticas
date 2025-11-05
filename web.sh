#!/usr/bin/env bash
set -e

echo "[INFO] Instalando Apache en $(hostname)"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

# Crear una página simple con el nombre del servidor
HOSTNAME=$(hostname)
echo "<html><body><h1>Servidor: $HOSTNAME</h1><p>IP: $(hostname -I)</p></body></html>" > /var/www/html/index.html

systemctl enable apache2
systemctl restart apache2