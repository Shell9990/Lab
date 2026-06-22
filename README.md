# Home Lab Network

Two-device home lab. Static IPs assigned via router. Scripts automate base package installation for each device.

## Hardware

a) Raspberry Pi 2, Debian (no DE) - VPN, DNS filtering, print server
b) PC, i3 5th gen, 4GB RAM, Debian - storage server, media streaming

## Network layout

| Device | Role | IP |
|---|---|---|
| Router | Gateway | 192.168.1.1 |
| Raspberry Pi 2 | VPN/Pi-hole/print server | 192.168.1.x |
| PC | Storage/media server | 192.168.1.x |
| Printer | Network printer | 192.168.1.x |
| Personal PC | Client | 192.168.1.x |

Fill in actual addresses for your network.

## Raspberry Pi (`pi-setup.sh`)

Installs:

1. WireGuard - VPN server, lightweight enough for Pi 2 hardware
2. Pi-hole - network-wide DNS ad and tracker blocking
3. CUPS - network print server

Run:

```
chmod +x pi-setup.sh
./pi-setup.sh
```

After running, write `/etc/wireguard/wg0.conf` manually with your peer details, then:

```
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

CUPS admin interface: `https://<pi-ip>:631`

## PC (`pc-setup.sh`)

Installs:

1. Samba - file storage share
2. Jellyfin - media streaming server

Run:

```
chmod +x pc-setup.sh
./pc-setup.sh
```

Jellyfin web interface: `http://<pc-ip>:8096`
Samba share: `\\<pc-ip>\storage`

## Security

Both devices include firewall and intrusion prevention rules.

a) ufw - default deny incoming, only required ports opened
b) fail2ban - blocks repeated failed SSH login attempts
c) SSH root login disabled on both devices
d) Samba and CUPS access restricted to LAN subnet only
e) WireGuard provides encrypted remote access instead of exposing services directly to the internet
f) Pi-hole adds DNS-layer filtering against malicious and tracking domains

### Network audit (`network-audit.sh`)

Runs an nmap scan against the lab subnet and logs open ports and service versions per host. Used to verify only intended ports are exposed after setup.

Run:

```
chmod +x network-audit.sh
./network-audit.sh
```

Edit the `SUBNET` variable to match your network.

### Skills demonstrated

a) Network segmentation and firewall configuration
b) VPN deployment (WireGuard)
c) DNS-layer security filtering
d) Brute-force protection (fail2ban)
e) Network reconnaissance and service enumeration (nmap)

## Notes

a) Both scripts assume a fresh Debian install with sudo access
b) Static IPs handled via router DHCP reservation, not in scripts
c) WireGuard peer config is network-specific and not automated
