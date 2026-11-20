#!/bin/bash
set -e

KVER="$(uname -r)"
TARGET="/lib/modules/$KVER/kernel/drivers/net/wireless/realtek/rtl8189fs/8189fs.ko"
BACKUP="/var/backups/rtl8189fs/$KVER/8189fs.ko.original"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

case "$KVER" in
    6.12.117-ophub|6.12.114-ophub|6.18.63-ophub|6.18.59-ophub) ;;
    *)
        echo "ERROR: Unsupported kernel: $KVER"
        exit 1
        ;;
esac

if lsmod | grep -q '^8189fs '; then
    echo "ERROR: Driver is loaded. Run 'modprobe -r 8189fs' first."
    exit 1
fi

if [ -f "$BACKUP" ]; then
    OLDVERMAGIC="$(modinfo -F vermagic "$BACKUP" 2>/dev/null || true)"
    case "$OLDVERMAGIC" in
        "$KVER "*)
            install -D -m 0644 "$BACKUP" "$TARGET"
            echo "Compatible original module restored."
            ;;
        *)
            rm -f "$TARGET"
            echo "Original backup is incompatible."
            echo "Backup retained at: $BACKUP"
            ;;
    esac
else
    rm -f "$TARGET"
    echo "Installed module removed. No original backup existed."
fi

depmod -a "$KVER"
echo "Uninstall completed. Reboot to apply changes."
