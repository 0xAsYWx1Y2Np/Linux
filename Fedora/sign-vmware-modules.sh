# /etc/dkms/sign-vmware-modules.sh
#!/bin/bash
# Automatically sign VMware modules after DKMS builds
KEY="/root/mok-keys/MOK.priv"
CERT="/root/mok-keys/MOK.der"
MODPATH="/lib/modules/$kernel/extra"

for mod in vmmon.ko vmnet.ko; do
    if [[ -f "$MODPATH/$mod" ]]; then
        echo "🔏 Signing $mod..."
        /usr/src/kernels/$kernel/scripts/sign-file sha256 "$KEY" "$CERT" "$MODPATH/$mod"
    fi
done