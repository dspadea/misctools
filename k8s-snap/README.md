# k8s-snap: pre-start cleanup for k8s k8sd

This folder provides a small systemd "oneshot" service that runs before the `k8s` snap's control-plane service (k8sd) starts. It removes a stale dqlite socket file that can be left behind after an ungraceful shutdown and otherwise prevents k8s from starting.

- Target environment: Linux hosts running the Canonical `k8s` snap with systemd.
- Problem addressed: Failed start of `snap.k8s.k8sd.service` due to a leftover socket file.
- What it does: Installs a pre-start cleanup unit plus a helper script that deletes the stale socket before k8sd starts.

> Note: This is not intended for macOS; it requires systemd and the `k8s` snap on a Linux host.

## How it works

- `usr-local-bin/fix-k8s.sh` deletes the stale socket: `/var/snap/k8s/common/var/lib/k8s-dqlite/k8s-dqlite.sock`.
- `etc-systemd-system/clean-up-k8s.service` is a `Type=oneshot` unit that calls the script and then exits.
- `etc-systemd-system/snap.k8s.k8sd.service.d/override.conf` declares that k8sd:
  - Requires `clean-up-k8s.service`
  - Starts After `clean-up-k8s.service`
  
This ensures cleanup happens before k8sd every time it starts.

## Files

- `setup.sh` — installer that copies units and script into place and enables the cleanup service.
- `etc-systemd-system/clean-up-k8s.service` — oneshot unit that runs the cleanup.
- `etc-systemd-system/snap.k8s.k8sd.service.d/override.conf` — drop-in to wire the dependency and ordering.
- `usr-local-bin/fix-k8s.sh` — script that removes the stale dqlite socket.

## Install

> Requires root. Run on the Linux host that has the `k8s` snap and systemd.

From this `k8s-snap/` directory:

```sh
sudo ./setup.sh
```

What the installer does:
- Copies the service and drop-in to `/etc/systemd/system` and sets ownership to `root:root`.
- Installs `/usr/local/bin/fix-k8s.sh` and makes it executable.
- Reloads systemd and enables `clean-up-k8s.service`.

## Verify

- Check service status:

```sh
systemctl status clean-up-k8s.service
```

- See recent logs:

```sh
journalctl -u clean-up-k8s.service -n 50 --no-pager
```

- Ensure k8sd is ordered after the cleanup:

```sh
systemctl cat snap.k8s.k8sd.service
```
Look for the drop-in showing `Requires=clean-up-k8s.service` and `After=clean-up-k8s.service`.

## Manual run (optional)

You can invoke the cleanup manually if needed:

```sh
sudo systemctl start clean-up-k8s.service
```

## Uninstall

If you want to remove this setup:

```sh
sudo ./uninstall.sh
```

Or manually:

```sh
systemctl disable clean-up-k8s.service
rm -f /etc/systemd/system/clean-up-k8s.service
rm -f /etc/systemd/system/snap.k8s.k8sd.service.d/override.conf
systemctl daemon-reload
rm -f /usr/local/bin/fix-k8s.sh
```

## Troubleshooting

- Different snap or path: If your environment uses a different service name or socket path, adjust the unit and script accordingly.
- Permissions: `setup.sh` must run as root. The script itself uses absolute paths and assumes `/usr/bin/bash` exists (typical on Ubuntu/Debian). If your distro uses `/bin/bash`, update the shebang in `usr-local-bin/fix-k8s.sh`.
- Not using systemd: This approach requires systemd; it will not work on init systems like SysV or OpenRC.

## Security notes

- The installer sets ownership to `root:root` and marks the cleanup script executable. Review the script before installing in sensitive environments.
