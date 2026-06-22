#!/usr/bin/env bash
# Network audit script
# Scans lab subnet, reports open ports and services per host
# Run only against your own network

set -euo pipefail

SUBNET="192.168.1.0/24"
OUTFILE="audit-$(date +%Y%m%d-%H%M).txt"

echo "Installing nmap..."
sudo apt install -y nmap

echo "Scanning $SUBNET..."
sudo nmap -sV -O "$SUBNET" -oN "$OUTFILE"

echo "Results saved to $OUTFILE"
