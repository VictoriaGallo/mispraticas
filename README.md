# Proyecto Final - Balanceador de Carga con NGINX y Pruebas con Artillery

**Materia:** Servicios Telemáticos  

**Autores:** Laura Gallo, Kelvin Martinez, Santiago Duque y Nicolas Cuellar

**Fecha:** 11 de noviembre de 2025  

---

## 🧩 Resumen
Este proyecto implementa una arquitectura de **balanceo de carga con NGINX**, utilizando **tres máquinas virtuales** creadas con **Vagrant + VirtualBox**, y se realizan **pruebas de rendimiento con Artillery**.  

**Arquitectura:**

| Máquina | Rol | IP | Servicio |
|----------|-----|----|-----------|
| `web1` | Servidor Web 1 | `192.168.50.10` | Apache |
| `web2` | Servidor Web 2 | `192.168.50.20` | Apache |
| `lb` | Balanceador de carga | `192.168.50.30` | NGINX |

---

## 🗂️ Estructura del proyecto
```bash
proyecto-balanceador/
├── Vagrantfile
├── provision/
│   ├── web.sh
│   └── lb.sh
├── artillery/
│   └── todos los archivos terminados en .yml
└── README.md
```

## ⚙️ Requisitos previos

- [VirtualBox](https://www.virtualbox.org/)  
- [Vagrant](https://www.vagrantup.com/)  
- [Node.js](https://nodejs.org/) + npm (para Artillery)  
- Git (opcional)

---

## 🧱 Configuración paso a paso

### 1️⃣ Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd proyecto-balanceador
```
### 2️⃣ Crear las máquinas virtuales

Ejecuta:
```bash
vagrant up
```
Esto creará las tres VMs (web1, web2, lb) y ejecutará los scripts de instalación automáticamente.

### 3️⃣ Verificar servicios

Prueba desde tu máquina host o desde el balanceador:
```bash
curl http://192.168.50.10
curl http://192.168.50.20
curl http://192.168.50.30
```
Debes ver la página HTML que identifica cada servidor.

## 🧾 Archivos principales
### 🖥️ provision/web.sh

Instala Apache y crea una página simple:
```bash
#!/usr/bin/env bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
cat > /var/www/html/index.html <<EOF
<html><body><h1>Servidor: $HOSTNAME</h1><p>IP: $IP</p></body></html>
EOF

systemctl enable apache2
systemctl restart apache2
```

### ⚙️ provision/lb.sh

Instala NGINX y configura el balanceo:
```bash
#!/usr/bin/env bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

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

ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/loadbalancer.conf || true
rm -f /etc/nginx/sites-enabled/default

systemctl enable nginx
systemctl restart nginx
```

## ⚙️ Pruebas de carga con Artillery

### Instalación

```bash
npm install -g artillery
```

### Archivo **artillery/loadtest.yml**

```bash
config:
  target: "http://192.168.50.30"
  phases:
    - duration: 60
      arrivalRate: 10
  defaults:
    headers:
      Accept: "text/html"

scenarios:
  - name: "Prueba balanceador"
    flow:
      - get:
          url: "/"
```
### Ejecutar prueba
```
artillery run artillery/ARCHIVOTEST.yml --record –k “la clave”

```
📘 El comando artillery con la clave perzonalizada la da en la pagina de **https://app.artillery.io** vicular con tu cuenta de Github


