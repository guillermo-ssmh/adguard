#!/bin/bash
# Script instalación AdGuardHome con Podman + systemd en AlmaLinux 9

set -e

# 1. Crear contenedor (solo si no existe)
if ! podman ps -a --format '{{.Names}}' | grep -q '^adguardhome$'; then
    echo "[+] Creando contenedor AdGuardHome..."
    podman run --name adguardhome \
	--restart=unless-stopped \
	-v /opt/adguard/work:/opt/adguardhome/work \
	-v /opt/adguard/conf:/opt/adguardhome/conf \
	-d \
	-p 53:53/tcp -p 53:53/udp \
	-p 67:67/udp -p 68:68/udp \
	-p 80:80/tcp \
	-p 443:443/tcp -p 443:443/udp \
	-p 3000:3000/tcp -p 784:784/udp \
	-p 853:853/tcp -p 853:853/udp \
	-p 5443:5443/tcp -p 5443:5443/udp \
	-p 8853:8853/udp \
	--network=host --cap-add=NET_ADMIN --cap-add=NET_RAW \
	adguard/adguardhome
else
    echo "[!] El contenedor AdGuardHome ya existe, saltando creación."
fi

# 2. Configurar firewall
echo "[+] Configurando firewall..."
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=dhcp

firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=784/udp
firewall-cmd --permanent --add-port=853/tcp
firewall-cmd --permanent --add-port=853/udp
firewall-cmd --permanent --add-port=5443/tcp
firewall-cmd --permanent --add-port=5443/udp
firewall-cmd --permanent --add-port=8853/udp

firewall-cmd --reload

# 3. Generar servicio systemd
echo "[+] Generando servicio systemd..."
mkdir -p /etc/systemd/system
podman generate systemd --name adguardhome --files --new
mv container-adguardhome.service /etc/systemd/system/

# 4. Activar y arrancar el servicio
echo "[+] Activando servicio..."
systemctl daemon-reload
systemctl enable container-adguardhome.service
systemctl start container-adguardhome.service

# 5. Verificación
echo "[+] Instalación completada."
systemctl status container-adguardhome.service --no-pager

