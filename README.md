# 📘 PARCIAL 2: Servicios Telemáticos con Firewall, DNS Maestro/Esclavo y FTP Seguro

✍️ Autor: *Laura Victoria Gallo Payana 2220903*  

Este proyecto implementa y valida tres servicios principales en un entorno de red local con servidores y un cliente, protegidos por un **firewall con iptables**.  

---

## 🖥️ Topología

- **Cliente** → `192.168.50.2`  
- **Servidor DNS Maestro + FTP** → `192.168.50.3`  
- **Servidor DNS Esclavo** → `192.168.50.4`  
- **Firewall / Servidor2** → `192.168.50.5`  

---

## 🔐 1. FTP Seguro (FTPS) con Firewall

### 🔧 Configuración del servidor FTP (192.168.50.3)
1. Instalar y habilitar **vsftpd**:  
   ```bash
   sudo apt install vsftpd -y
   sudo systemctl enable vsftpd --now
   ```
2. Configurar `/etc/vsftpd.conf` para soportar **FTP explícito sobre TLS** que tenga hablitado.
   ```bash
   allow_anon_ssl=NO
   force_local_data_ssl=YES
   force_local_logins_ssl=YES
   ssl_enable=YES
   ```
4. Confirmar que el servicio escucha:  
   ```bash
   sudo ss -tnlp | grep :21
   ```

### 🔧 Configuración del firewall (192.168.50.5)
Redirección de FTP hacia el servidor:  
```bash
# Habilitar reenvío
sudo sysctl -w net.ipv4.ip_forward=1

# Reglas NAT y FORWARD para FTP (puerto 21)
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 21 -j DNAT --to 192.168.50.3:21
sudo iptables -A FORWARD -p tcp -d 192.168.50.3 --dport 21 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -p tcp -d 192.168.50.3 --dport 21 -j MASQUERADE
```

### ✅ Validación desde el cliente (192.168.50.2)
```bash
telnet 192.168.50.5 21
```
Respuesta esperada:  
`220 (vsFTPd ...)`

Con FileZilla:  
- **Host**: `192.168.50.5`  
- **Cifrado**: FTP explícito (puerto 21) sobre TLS  
- **Usuario/Contraseña**: definidos en el servidor FTP  

---

## 🌐 2. DNS Maestro/Esclavo con Firewall

### 🔧 Configuración del servidor maestro (192.168.50.3)
En `/etc/bind/named.conf.local`:
```conf
zone "ejemplo.com" {
    type master;
    file "/etc/bind/db.ejemplo.com";
    allow-transfer { 192.168.50.4; };
};
```
Archivo de zona `/etc/bind/db.ejemplo.com`:
```dns
$TTL 604800
@   IN  SOA servidor1.ejemplo.com. root.ejemplo.com. (
        2     ; Serial
        604800 ; Refresh
        86400  ; Retry
        2419200 ; Expire
        604800 ) ; Negative Cache TTL

@       IN  NS  servidor1.ejemplo.com.
@       IN  NS  servidor2.ejemplo.com.
servidor1 IN A 192.168.50.3
servidor2 IN A 192.168.50.4
```

### 🔧 Configuración del servidor esclavo (192.168.50.4)
En `/etc/bind/named.conf.local`:
```conf
zone "ejemplo.com" {
    type slave;
    masters { 192.168.50.3; };
    file "/var/lib/bind/db.ejemplo.com";
};
```

### 🔧 Configuración del firewall (192.168.50.5)
Reglas NAT y FORWARD para DNS:
```bash
# DNS UDP/TCP → maestro
sudo iptables -t nat -A PREROUTING -i eth1 -p udp --dport 53 -j DNAT --to 192.168.50.3:53
sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 53 -j DNAT --to 192.168.50.3:53
sudo iptables -A FORWARD -p udp -d 192.168.50.3 --dport 53 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 192.168.50.3 --dport 53 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -p udp -d 192.168.50.3 --dport 53 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -p tcp -d 192.168.50.3 --dport 53 -j MASQUERADE
```

### ✅ Validación desde el cliente
```bash
dig @192.168.50.3 servidor1.ejemplo.com
dig @192.168.50.4 servidor1.ejemplo.com
dig @192.168.50.5 servidor1.ejemplo.com
```
Resultados:  
- Maestro y esclavo responden con `192.168.50.3`.  
- Firewall redirige correctamente consultas al maestro.  

---

## 🔒 3. DNS sobre TLS en el Cliente

### 🔧 Configuración en el cliente (192.168.50.2)
El cliente Ubuntu utiliza `systemd-resolved` (servicio de resolución local) con soporte de DNS sobre TLS (DoT).
```bash
systemctl status systemd-resolved
```

Comprobar que las consultas se realizan a través del resolvedor local `127.0.0.53`  y que TLS está activo:

```yaml
dig @127.0.0.53 www.google.com
```

### ✅ Validación
Debe resolverse con estatus `NOERROR` y mostrar la IP pública de Google y comprobar que flujo con WireShark.  

---

## 📌 Conclusiones
- Se configuró un **servidor FTP seguro** accesible desde cliente a través del firewall.  
- Se implementó un **sistema DNS maestro/esclavo**, con consultas redirigidas por el firewall.  
- El cliente puede realizar consultas con **DNS sobre TLS**, asegurando privacidad en las resoluciones.  
- Todas las pruebas (`dig`, `telnet`, conexión con FileZilla) validaron el correcto funcionamiento.  

---


📅 Parcial 2 de **Servicios Telemáticos**  
