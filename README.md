# Proyecto Final Servicios Telemáticos

Despliegue Seguro, Monitoreo y Visualización de Mini Web App en AWS con Docker, Prometheus y Grafana
Autor: Tu nombre — Universidad Autónoma de Occidente

## Descripción del Proyecto

Este proyecto despliega una aplicación web en un entorno productivo sobre AWS EC2 usando Docker Compose, habilitando monitoreo con Prometheus + Node Exporter y visualización con Grafana como parte del ciclo DevOps orientado a observabilidad.

| Servicio             | Tecnología          | 
| -------------------- | ------------------- |
| Servidor Web / API   | Flask + Docker      | 
| Base de Datos        | MySQL en contenedor |
| Métricas del sistema | Node Exporter       |
| Monitor de métricas  | Prometheus          |
| Dashboards           | Grafana             |

## Parte 1 – Empaquetado con Docker
Dockerfile
```bash
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

docker-compose.yml

```bash
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - db
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: miniwebdb
```
Comandos usados:
```bash
cd /home/ubuntu/webapp
docker compose up -d --build
docker ps
```

## Parte 2 – Despliegue en AWS EC2

✔ Instancia Ubuntu

✔ Security Group permitiendo puertos: 22, 80, 9090, 9100, 3000

✔ Clave SSH para acceso seguro

Conexión SSH:
```bash
ssh -i "nubefinalssh.pem" ubuntu@ec2-xx-xx-xx.compute-1.amazonaws.com
```

## Parte 3 – Monitoreo con Prometheus y Node Exporter

### Instalación Node Exporter
```bash
cd /opt
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
sudo tar xvf node_exporter-*.tar.gz
sudo mv node_exporter-1.8.0.linux-amd64 node_exporter
```
Servicio:
```bash
sudo nano /etc/systemd/system/node_exporter.service
```

```bash
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=ubuntu
ExecStart=/opt/node_exporter/node_exporter

[Install]
WantedBy=default.target
```
```bash
sudo systemctl enable --now node_exporter
```

### Instalación Prometheus

```bash
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
sudo tar xvf prometheus-*.tar.gz
sudo mv prometheus-2.51.2.linux-amd64 prometheus
```
Configuracion:
```bash
sudo nano /opt/prometheus/prometheus.yml
```
```bash
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
```
Servicio:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
```

## Parte 4 – Visualización con Grafana

Instalación:
```bash
sudo apt-get install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl enable --now grafana-server
```
Acceso:
```bash
http://IP_PUBLICA:3000
```
Usuario/Pass:
```bash
admin / admin
```

### Dashboards creados
| Panel       | Métrica                                                                                                   | Visualización |
| ----------- | --------------------------------------------------------------------------------------------------------- | ------------- |
| Uso CPU     | `100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`                           | TimeSeries    |
| Uso Memoria | `(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100`        | TimeSeries    |
| Uso Disco   | `100 - (node_filesystem_free_bytes{fstype!="tmpfs"} / node_filesystem_size_bytes{fstype!="tmpfs"} * 100)` | Gauge         |


Dashboard importado ID:
1860

```bash
```bash
```bash








