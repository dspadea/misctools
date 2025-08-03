#!/usr/bin/bash

# After a reboot or ungraceful shutdown, the k8s snap may not start properly.
# Logs indicate that it is unable to open the k8s-dqlite.sock file. Having a look at 
# the documentation for domain sockets, it seems like the file must not exist before
# a bind is made to it. Simply removing that file allows the bind to work properly, and 
# k8s starts up as expected.

sudo snap stop k8s
rm /var/snap/k8s/common/var/lib/k8s-dqlite/k8s-dqlite.sock
sudo snap start k8s
