#!/usr/bin/env bash

set -e
set -x

cp -prv etc-systemd-system/* /etc/systemd/system
chown -R root:root /etc/systemd/system/clean-up-k8s.service /etc/systemd/system/snap.k8s.k8s-dqlite.service.d/

cp usr-local-bin/fix-k8s.sh /usr/local/bin/
chown root:root /usr/local/bin/fix-k8s.sh
chmod +x /usr/local/bin/fix-k8s.sh

sudo systemctl daemon-reload
sudo systemctl enable clean-up-k8s.service

echo "Pre-start cleanup for k8s is installed as a dependency of dqlite."
