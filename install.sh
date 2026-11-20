#!/bin/bash
set -e

KVER="$(uname -r)"
DIR="$(cd "$(dirname "$0")" && pwd)"

case "$KVER" in
    6.12.117-ophub)
        MODULE="$DIR/8189fs-6.12.117-ophub.ko"
        ;;

    6.12.114-ophub)
        MODULE="$DIR/8189fs-6.12.114-ophub.ko"
        ;;
    6.18.63-ophub)
        MODULE="$DIR/8189fs-6.18.63-ophub.ko"
        ;;
    6.18.59-ophub)
        MODULE="$DIR/8189fs-6.18.59-ophub.ko"
        ;;
    *)
        echo "ERROR: Unsupported kernel: $KVER"
        echo "Supported kernels: 6.12.117-ophub, 6.12.114-ophub, 6.18.63-ophub, 6.18.59-ophub"
        exit 1
        ;;
esac

TARGET="/lib/modules/$KVER/kernel/drivers/net/wireless/realtek/rtl8189fs/8189fs.ko"
BACKUP="/var/backups/rtl8189fs/$KVER/8189fs.ko.original"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

if [ ! -s "$MODULE" ]; then
    echo "ERROR: Driver module missing or empty: $MODULE"
    exit 1
fi

VERMAGIC="$(modinfo -F vermagic "$MODULE")"
case "$VERMAGIC" in
    "$KVER "*) ;;
    *) echo "ERROR: Module vermagic mismatch."; exit 1 ;;
esac

if ! modinfo -F alias "$MODULE" | grep -Fq 'v024CdF179'; then
    echo "ERROR: Expected RTL8189FS SDIO alias not found."
    exit 1
fi

mkdir -p "$(dirname "$BACKUP")"

if [ -f "$TARGET" ] && [ ! -f "$BACKUP" ]; then
    cp -a "$TARGET" "$BACKUP"
    echo "Original module backed up."
fi

install -D -m 0644 "$MODULE" "$TARGET"
depmod -a "$KVER"

echo "RTL8189FS installed successfully."
echo "Kernel: $KVER"
echo "Module: $(basename "$MODULE")"
echo "Reboot to load the installed module."
