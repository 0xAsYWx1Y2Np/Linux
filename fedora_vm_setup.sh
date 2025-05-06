#!/bin/bash
# ------------------------------------------------------------------------------
# Script Title: Fedora VM Environment Setup
# Author: Alessandro Salucci
# Date: 2025-05-05
# Description: Installs and configures libvirt/KVM/QEMU for VM usage.
# Requirements: Fedora 40+, virtualization support enabled in BIOS/UEFI
# Usage: sudo bash fedora_vm_setup.sh
# ------------------------------------------------------------------------------

set -e

echo "[+] Installing virtualization tools..."
dnf groupinstall -y "Virtualization"
dnf install -y virt-manager

echo "[+] Enabling libvirtd..."
systemctl enable --now libvirtd
usermod -aG libvirt $(whoami)

echo "[+] Checking virtualization status..."
virt-host-validate

echo "[+] Virtualization setup complete. Reboot required."
