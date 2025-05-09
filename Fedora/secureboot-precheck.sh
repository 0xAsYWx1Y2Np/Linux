#!/bin/bash
# secureboot-precheck.sh
# Author: Alessandro Salucci
# Date: 2025-05-09
# Description: Checks if Fedora is Secure Boot ready (signed kernel, shim, grub)
# Requirements: pesign, mokutil, root privileges
# Usage: sudo ./secureboot-precheck.sh
# --------------------------------------------------------------------------------
# Before running the script
# --------------------------
# Install Required Tools
# --------------------------------------------------------------------------------
# sudo dnf install pesign mokutil
# chmod +x secureboot-precheck.sh

echo "🔒 Secure Boot Readiness Check for Fedora"
echo "----------------------------------------"

# Check Secure Boot status
mokutil --sb-state

# Check for shim, grub2, kernel packages
echo -e "\n📦 Checking signed bootloader components:"
rpm -q shim-x64 grub2-efi-x64 grub2-common kernel

# Check current kernel signature
KERNEL_IMG="/boot/vmlinuz-$(uname -r)"
echo -e "\n🔍 Verifying kernel signature for: $KERNEL_IMG"

if command -v pesign >/dev/null; then
    if pesign -S -i "$KERNEL_IMG" | grep -q "The signature is valid"; then
        echo "✅ Kernel is signed"
    else
        echo "❌ Kernel is NOT signed — Secure Boot will fail"
    fi
else
    echo "⚠️  pesign not installed. Run: sudo dnf install pesign"
fi

# Check for shim presence
echo -e "\n🔍 Checking if shim is present in EFI partition:"
if [[ -f /boot/efi/EFI/fedora/shimx64.efi ]]; then
    echo "✅ Shim is present"
else
    echo "❌ Shim missing. Install: sudo dnf install shim-x64"
fi

echo -e "\n✅ Pre-check complete. If all checks passed, you're safe to enable Secure Boot in BIOS."