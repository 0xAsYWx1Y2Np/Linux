#!/bin/bash
# ------------------------------------------------------------------------------
# Script Title: Fedora Security Hardening
# Author: Alessandro Salucci
# Date: 2025-05-06
# Description: Hardens Fedora (Workstation or KDE) for use in secure environments.
# Requirements: Fedora 40+, sudo privileges, Internet connection
# Usage: sudo bash fedora_hardening.sh
# ------------------------------------------------------------------------------

set -e

echo "[+] Updating system..."
dnf update -y && dnf upgrade -y
dnf install -y dnf-automatic firewalld fail2ban audit lynis clamav clamav-update clamav-server clamav-server-systemd usbguard snapper

echo "[+] Enabling automatic updates..."
systemctl enable --now dnf-automatic.timer

echo "[+] Configuring SELinux..."
setenforce 1
sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

echo "[+] Enabling firewalld..."
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo "[+] Activating Fail2Ban..."
systemctl enable --now fail2ban

echo "[+] Starting auditd..."
systemctl enable --now auditd

echo "[+] Updating ClamAV and enabling daemon..."
freshclam

if [ ! -f /etc/clamd.d/scan.conf ]; then
    echo "[+] Creating ClamAV scan configuration from example..."
    cp /usr/share/doc/clamav-server*/scan.conf.example /etc/clamd.d/scan.conf
fi

# Fix ClamAV configuration
sed -i 's/^User .*/User clamupdate/' /etc/clamd.d/scan.conf

grep -q '^User clamupdate' /etc/clamd.d/scan.conf || echo 'User clamupdate' >> /etc/clamd.d/scan.conf
grep -q '^LocalSocket /run/clamd.scan/clamd.sock' /etc/clamd.d/scan.conf || echo 'LocalSocket /run/clamd.scan/clamd.sock' >> /etc/clamd.d/scan.conf
grep -q '^LogFile /var/log/clamd.scan' /etc/clamd.d/scan.conf || echo 'LogFile /var/log/clamd.scan' >> /etc/clamd.d/scan.conf

mkdir -p /run/clamd.scan
chown clamupdate:clamupdate /run/clamd.scan

systemctl daemon-reexec
systemctl enable --now clamd@scan.service || echo "[!] Failed to enable clamd@scan.service — verify config manually."

echo "[+] Enabling USBGuard..."
systemctl enable --now usbguard

echo "[+] Configuring DNS over TLS (Cloudflare)..."
mkdir -p /etc/systemd/resolved.conf.d
cat <<EOF > /etc/systemd/resolved.conf.d/dns_over_tls.conf
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com
FallbackDNS=1.0.0.1#cloudflare-dns.com
DNSOverTLS=yes
EOF
systemctl restart systemd-resolved

echo "[+] Keyboard Layout: Setting Deutsch (Schweiz)..."
localectl set-keymap ch
localectl set-x11-keymap ch

echo "[+] Creating BTRFS snapshot configuration..."
snapper --config=root create-config /
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer


echo "[+] Fedora hardening complete. Run 'lynis audit system' to perform a security audit."
