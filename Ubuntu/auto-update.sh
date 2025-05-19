#!/bin/bash

###############################################################################
# Script Title: Ubuntu Auto Update Script
# Author: Alessandro Salucci
# Date: 2025-05-19
# Description: Fully automates system updates on Ubuntu Server, including
#              package list refresh, upgrades, and cleanup.
# Requirements: Must be run with sudo or as root. Tested on Ubuntu 20.04–24.04.
# Usage: sudo ./auto-update.sh
###############################################################################

LOG_FILE="/var/log/auto-update-$(date +%F).log"

echo "=== Starting full update: $(date) ===" | tee -a "$LOG_FILE"

# Update package list
apt-get update -y >> "$LOG_FILE" 2>&1

# Upgrade all packages
apt-get upgrade -y >> "$LOG_FILE" 2>&1

# Full distro upgrade (handles kernel & dependencies)
apt-get dist-upgrade -y >> "$LOG_FILE" 2>&1

# Autoremove unused packages
apt-get autoremove -y >> "$LOG_FILE" 2>&1

# Clean up cached .deb files
apt-get autoclean -y >> "$LOG_FILE" 2>&1

echo "=== Update complete: $(date) ===" | tee -a "$LOG_FILE"