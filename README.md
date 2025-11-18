# Proyecto Final Servicios Telemáticos

Despliegue Seguro, Monitoreo y Visualización de Mini Web App en AWS con Docker, Prometheus y Grafana

Autores: Laura Gallo y Kelvin Martinez — Universidad Autónoma de Occidente

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
<img width="1082" height="467" alt="image" src="https://github.com/user-attachments/assets/748661ec-06f5-4fb2-a39f-3e16bc67e2b2" />

## Parte 2 – Despliegue en AWS EC2

✔ Instancia Ubuntu

✔ Security Group permitiendo puertos: 22, 80, 9090, 9100, 3000
<img width="1367" height="691" alt="image" src="https://github.com/user-attachments/assets/0027966f-cc17-44d4-ade4-4c1861b5835e" />

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
<img width="900" height="494" alt="image" src="https://github.com/user-attachments/assets/e371371b-30b5-42a8-8f87-30a1713bd8f5" />

<img width="900" height="248" alt="image" src="https://github.com/user-attachments/assets/13992c70-a932-4b56-96f1-820a099d347f" />

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
<img width="900" height="231" alt="image" src="https://github.com/user-attachments/assets/c5bf2ce7-0a6c-4177-aaf2-576c84a975ca" />

<img width="900" height="455" alt="image" src="https://github.com/user-attachments/assets/edaa382e-4a26-47bd-9df1-b9d4d4417f01" />


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

<img width="900" height="723" alt="image" src="https://github.com/user-attachments/assets/139c4024-c87c-4a88-a3e4-b477bdd62361" />


Dashboard importado ID:
```bash
1860
```
<img width="900" height="409" alt="image" src="https://github.com/user-attachments/assets/d5c579b9-7226-4c29-b732-725ff54dca3d" />

## Conclusión Técnica

Integrar Docker, AWS y Prometheus facilita despliegues reproducibles y observabilidad del sistema.

Lo más retador fue el despliegue en EC2 por configuraciones de red y servicios, pero la solución estuvo en revisar logs, servicios y reglas de seguridad.

La observabilidad permite detectar fallos antes que los usuarios, mejorar rendimiento y tomar decisiones basadas en métricas, clave en DevOps.







