# Primer Parcial Servicios Telemáticos - Laura Gallo

Este documento describe la implementación de:  
1. **Servidor Apache con autenticación PAM y lista de usuarios denegados**.  
2. **Servidor DNS Maestro/Esclavo con transferencia de zona**.  
3. **Exposición de servidor web local a Internet con Ngrok**.  

---

## 🔹 Parte 1 – Apache + PAM + Lista de usuarios denegados  

👉 **Servidor: 192.168.50.3**  

### Instalación
```bash
sudo apt update
sudo apt install apache2 libapache2-mod-authnz-pam libpam-pwdfile -y
```

### Configuración Apache
Archivo: `/etc/apache2/sites-available/000-default.conf`  

```apache
<Directory "/var/www/html/archivos_privados">
    AuthType Basic
    AuthName "Zona Privada"
    AuthBasicProvider PAM
    AuthPAMService apache
    Require valid-user

    # Denegar acceso a usuarios en lista negra
    AuthBasicAuthoritative Off
</Directory>
```

### Configuración PAM para Apache
Archivo: `/etc/pam.d/apache`  

```pam
auth    required   pam_unix.so
account required   pam_unix.so

# Bloquear usuarios en lista negra
auth    required   pam_listfile.so item=user sense=deny file=/etc/apache2/usuarios_denegados onerr=succeed
```

### Lista de usuarios denegados
Archivo: `/etc/apache2/usuarios_denegados`
```
usuario1
usuario2
```

### Reiniciar Apache
```bash
sudo systemctl restart apache2
```

---

## 🔹 Parte 2 – DNS Maestro/Esclavo con transferencia de zona  

👉 **Maestro: 192.168.50.3**  
👉 **Esclavo: 192.168.50.4**  
👉 **Cliente: 192.168.50.2**  

### Instalación Bind9
```bash
sudo apt update
sudo apt install bind9 -y
```

---

### Configuración Maestro `/etc/bind/named.conf.local`
```conf
zone "empresa.local" {
    type master;
    file "/etc/bind/db.empresa.local";
    allow-transfer { 192.168.50.4; };
};

zone "50.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.50";
    allow-transfer { 192.168.50.4; };
};
```

#### Zona directa `/etc/bind/db.empresa.local`
```dns
$TTL    604800
@   IN  SOA maestro.empresa.local. root.empresa.local. (
        3       ; Serial
        604800  ; Refresh
        86400   ; Retry
        2419200 ; Expire
        604800) ; Negative Cache TTL

@       IN  NS  maestro.empresa.local.
@       IN  NS  esclavo.empresa.local.

maestro IN  A   192.168.50.3
esclavo IN  A   192.168.50.4
www     IN  A   192.168.50.10
alias   IN  CNAME www
```

#### Zona inversa `/etc/bind/db.192.168.50`
```dns
$TTL    604800
@   IN  SOA maestro.empresa.local. root.empresa.local. (
        3       ; Serial
        604800  ; Refresh
        86400   ; Retry
        2419200 ; Expire
        604800) ; Negative Cache TTL

@       IN  NS  maestro.empresa.local.
@       IN  NS  esclavo.empresa.local.

3   IN  PTR maestro.empresa.local.
4   IN  PTR esclavo.empresa.local.
10  IN  PTR www.empresa.local.
```

---

### Configuración Esclavo `/etc/bind/named.conf.local`
```conf
zone "empresa.local" {
    type slave;
    masters { 192.168.50.3; };
    file "/var/cache/bind/db.empresa.local";
};

zone "50.168.192.in-addr.arpa" {
    type slave;
    masters { 192.168.50.3; };
    file "/var/cache/bind/db.192.168.50";
};
```

---

### Pruebas desde el cliente
```bash
# Probar resolución de nombre
dig @192.168.50.4 www.empresa.local

# Probar resolución inversa
dig @192.168.50.4 -x 192.168.50.10

# Probar transferencia de zona
dig @192.168.50.3 empresa.local AXFR
```

---

## 🔹 Parte 3 – Exponer servidor web con Ngrok  

👉 **Servidor web: 192.168.50.3 (Apache)**  

### Instalar Ngrok v3
```bash
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/
```

### Configurar token
```bash
ngrok config add-authtoken TU_TOKEN
```

### Crear página personalizada
Archivo: `/var/www/html/index.html`
```html
<html>
  <body>
    <h1>Hola</h1>
    <p>Servidor Apache expuesto con Ngrok</p>
  </body>
</html>
```

### Iniciar túnel
```bash
ngrok http 80
```

👉 Se generará una URL pública como:  
```
https://abcd1234.ngrok.io
```

Abrir esa URL en un navegador externo (celular con datos móviles).  

---

## ✅ Conclusión
- Se configuró Apache con autenticación PAM y lista negra de usuarios.  
- Se implementó un DNS Maestro/Esclavo con transferencia de zona y resolución inversa.  
- Se expuso un servidor web local a Internet usando Ngrok con página personalizada.  
