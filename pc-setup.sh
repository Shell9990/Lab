#!/usr/bin/env bash
# PC setup script
# Installs: Samba storage server, Jellyfin media streaming
# OS: Debian

set -euo pipefail

echo "Updating system..."
sudo apt update && sudo apt full-upgrade -y

echo "Installing Samba..."
sudo apt install -y samba samba-common-bin

echo "Creating shared storage directory..."
sudo mkdir -p /srv/storage
sudo chown nobody:nogroup /srv/storage
sudo chmod 0775 /srv/storage

echo "Adding Samba share config..."
cat <<EOF | sudo tee -a /etc/samba/smb.conf

[storage]
   path = /srv/storage
   browseable = yes
   read only = no
   guest ok = no
   valid users = $USER
EOF

echo "Setting Samba password for current user..."
sudo smbpasswd -a "$USER"
sudo systemctl restart smbd

echo "Installing Jellyfin..."
curl -fsSL https://repo.jellyfin.org/install-debian.sh | sudo bash

echo "Installing firewall and intrusion prevention..."
sudo apt install -y ufw fail2ban
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.1.0/24 to any port 445
sudo ufw allow from 192.168.1.0/24 to any port 139
sudo ufw allow 8096/tcp
sudo ufw --force enable
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Hardening SSH..."
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Setup complete."
echo "Jellyfin: http://<pc-ip>:8096"
echo "Samba share: \\\\<pc-ip>\\storage"
