#!/bin/bash
# Automatically sign VMware modules after DKMS builds

KEY="/root/mok-keys/MOK.priv"
CERT="/root/mok-keys/MOK.der"
KERNEL=$(uname -r)
MODPATH="/lib/modules/$KERNEL/extra"

# Ensure keys exist
if [[ ! -f "$KEY" || ! -f "$CERT" ]]; then
    echo "❌ MOK key or cert not found. Exiting."
    exit 1
fi

# Sign modules if present
for mod in vmmon.ko vmnet.ko; do
    if [[ -f "$MODPATH/$mod" ]]; then
        echo "🔏 Signing $mod..."
        /usr/src/kernels/$KERNEL/scripts/sign-file sha256 "$KEY" "$CERT" "$MODPATH/$mod"
    else
        echo "⚠️ $mod not found in $MODPATH"
    fi
done