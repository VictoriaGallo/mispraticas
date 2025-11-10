#!/usr/bin/env bash
set -e

echo "🚀 Configurando balanceador NGINX - Weighted Round Robin..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

cat > /etc/nginx/sites-available/loadbalancer.conf <<EOF
upstream backend {
    server 192.168.56.11:80 weight=3;
    server 192.168.56.12:80 weight=1;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

systemctl enable nginx
systemctl restart nginx
echo "✅ Balanceador Weighted listo en 192.168.56.40"
