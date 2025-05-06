#!/bin/bash
# ------------------------------------------------------------------------------
# Script Title: Fedora Security Hardening
# Author: Alessandro Salucci
# Date: 2025-05-05
# Description: Hardens Fedora (Workstation or KDE) for use in secure environments.
# Requirements: Fedora 40+, sudo privileges, Internet connection
# Usage: sudo bash fedora_hardening.sh
# ------------------------------------------------------------------------------

set -e

echo "[+] Updating system..."
dnf update -y && dnf upgrade -y
dnf install -y dnf-automatic firewalld fail2ban audit lynis clamav clamav-update usbguard snapper

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
systemctl enable --now clamd@scan

echo "[+] Enabling USBGuard..."
systemctl enable --now usbguard
usbguard generate-policy > /etc/usbguard/rules.conf
systemctl restart usbguard

echo "[+] Configuring DNS over TLS (Cloudflare)..."
cat >> /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1
FallbackDNS=1.0.0.1
DNSOverTLS=yes
EOF
systemctl restart systemd-resolved

echo "[+] Keyboard Layout: Setting Deutsch (Schweiz)..."
localectl set-keymap ch

echo "[+] Creating BTRFS snapshot configuration..."
snapper -c root create-config /

echo "[+] Security hardening complete."
