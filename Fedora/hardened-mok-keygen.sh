#!/bin/bash
# hardened-mok-keygen.sh
# Author: Alessandro Salucci
# Date: 2025-05-09
# Description: Generates a secure 4096-bit RSA MOK key for Secure Boot module signing
# Requirements: openssl, root
# Usage: sudo ./hardened-mok-keygen.sh

set -e

echo "🔐 Generating 4096-bit MOK RSA key with strict permissions..."

# Secure directory for key material
mkdir -p /root/mok-keys
chmod 700 /root/mok-keys
cd /root/mok-keys

# Generate 4096-bit RSA private key
openssl genrsa -out MOK.priv 4096
chmod 600 MOK.priv

# Generate self-signed DER certificate
openssl req -new -x509 -sha256 -key MOK.priv -out MOK.der -outform DER \
  -days 3650 -subj "/CN=Alessandro Salucci SecureBoot MOK/"

# Restrict access to cert too
chmod 644 MOK.der

echo "✅ Keys generated:"
echo "  • Private key: /root/mok-keys/MOK.priv"
echo "  • Certificate: /root/mok-keys/MOK.der (use this with mokutil)"