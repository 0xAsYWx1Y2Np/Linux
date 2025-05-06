#!/bin/bash
# ------------------------------------------------------------------------------
# Script Title: Fedora Maintenance & Update Script
# Author: Alessandro Salucci
# Date: 2025-05-05
# Description: Automates weekly system maintenance tasks.
# Requirements: Fedora 40+, sudo privileges
# Usage: sudo bash fedora_maintenance.sh
# ------------------------------------------------------------------------------

echo "[+] Updating all packages..."
dnf upgrade -y

echo "[+] Refreshing ClamAV database..."
freshclam

echo "[+] Running Lynis system audit..."
lynis audit system

echo "[+] Creating BTRFS snapshot..."
snapper create --description "weekly-maintenance"

echo "[+] Maintenance complete."
