#!/usr/bin/env bash
set -e

echo "[INFO] Instalando NGINX como balanceador"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

# Configuración del balanceador
cat > /etc/nginx/sites-available/loadbalancer.conf <<'EOF'
upstream backend {
    server 192.168.50.10:80;
    server 192.168.50.20:80;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Activar la configuración
ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/loadbalancer.conf || true
rm -f /etc/nginx/sites-enabled/default

systemctl enable nginx
systemctl restart nginx