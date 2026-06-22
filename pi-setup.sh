#!/usr/bin/env bash
# Raspberry Pi 2 setup script
# Installs: WireGuard VPN, Pi-hole, CUPS print server
# OS: Debian (no desktop environment)

set -euo pipefail

echo "Updating system..."
sudo apt update && sudo apt full-upgrade -y

echo "Enabling IP forwarding (needed for VPN routing)..."
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Installing WireGuard..."
sudo apt install -y wireguard wireguard-tools qrencode

echo "Generating WireGuard keypair..."
sudo mkdir -p /etc/wireguard
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
sudo chmod 600 /etc/wireguard/privatekey

echo "Installing Pi-hole..."
curl -sSL https://install.pi-hole.net | sudo bash

echo "Installing CUPS print server..."
sudo apt install -y cups cups-client printer-driver-all
sudo usermod -aG lpadmin "$USER"
sudo cupsctl --remote-admin --remote-any --share-printers
sudo systemctl restart cups

echo "Installing firewall and intrusion prevention..."
sudo apt install -y ufw fail2ban
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 53
sudo ufw allow 80/tcp
sudo ufw allow 51820/udp
sudo ufw allow from 192.168.1.0/24 to any port 631
sudo ufw --force enable
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Hardening SSH..."
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Setup complete."
echo "Next steps: write /etc/wireguard/wg0.conf manually, see README."
