#!/usr/bin/bash

# we should be run by systemd before the dqlite service starts, so we shouldn't
# need to stop/start the k8s snap. TODO: add a check to see if the snap is running and stop it.

#sudo snap stop k8s

echo "Cleaning up any leftover dqlite socket..."
rm -f /var/snap/k8s/common/var/lib/k8s-dqlite/k8s-dqlite.sock
echo "Finished pre-start cleanup"
#sudo snap start k8s
