#!/usr/bin/env bash

set -euo pipefail
set -x

if [[ $EUID -ne 0 ]]; then
	echo "This uninstaller must be run as root. Re-run with: sudo ./uninstall.sh"
	exit 1
fi

# Disable and stop the cleanup service if present
systemctl disable clean-up-k8s.service || true
systemctl stop clean-up-k8s.service || true
systemctl reset-failed clean-up-k8s.service || true

# Remove systemd units and drop-ins
rm -f /etc/systemd/system/clean-up-k8s.service
rm -f /etc/systemd/system/snap.k8s.k8sd.service.d/override.conf || true

# Remove now-empty drop-in directories (ignore errors if not empty/missing)
rmdir /etc/systemd/system/snap.k8s.k8sd.service.d 2>/dev/null || true

# Reload systemd to pick up changes
systemctl daemon-reload

# Remove the helper script
rm -f /usr/local/bin/fix-k8s.sh

echo "Uninstalled k8s pre-start cleanup (k8sd dependency)."
