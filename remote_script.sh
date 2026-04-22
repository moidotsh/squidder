#!/bin/bash
set -e

PASSWORD="$1"

echo "Updating package lists"
apt update

echo "Installing squid, apache2-utils, and mosh"
apt install -y squid apache2-utils mosh

echo "Stopping squid that auto-started during install"
systemctl stop squid.service 2>/dev/null || true
rm -f /run/squid.pid

echo "Clearing conf.d drop-in configs to prevent conflicts"
rm -f /etc/squid/conf.d/*.conf

echo "Copying staged squid.conf into place"
cp ~/squid.conf.custom /etc/squid/squid.conf

echo "Validating squid config"
squid -k parse

echo "Initializing cache directory"
squid -z

echo "Creating user jihane in password file"
htpasswd -bc /etc/squid/passwords jihane "$PASSWORD"

echo "Restarting squid service"
if ! systemctl restart squid.service; then
    echo "ERROR: squid failed to start"
    journalctl -u squid.service --no-pager -n 30
    exit 1
fi

echo "Configuring firewall"
if command -v ufw >/dev/null 2>&1; then
    ufw allow 22/tcp
    ufw allow 60000:61000/udp
    ufw allow 3128/tcp
    echo "y" | ufw enable
else
    echo "Installing ufw"
    apt install -y ufw
    ufw allow 22/tcp
    ufw allow 60000:61000/udp
    ufw allow 3128/tcp
    echo "y" | ufw enable
fi

echo "Done. Squid proxy is running on port 3128"
