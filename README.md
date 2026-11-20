# RTL8189FS Driver for Armbian on HG680P

Precompiled RTL8189FS SDIO Wi-Fi driver modules for the HG680P (Amlogic S905X).

This repository contains four kernel-specific modules built and tested during experiments 3–5.

## Hardware

- Device: HG680P
- SoC: Amlogic S905X
- Wi-Fi chipset: Realtek RTL8189FS SDIO
- SDIO ID: 024C:F179
- Architecture: ARM64

## Supported Kernels

| Kernel | Module | STA | AP |
|---|---|---|---|
| 6.12.114-ophub | 8189fs-6.12.114-ophub.ko | PASS | Not tested |
| 6.12.117-ophub | 8189fs-6.12.117-ophub.ko | PASS | Not tested |
| 6.18.59-ophub | 8189fs-6.18.59-ophub.ko | PASS | PASS |
| 6.18.63-ophub | 8189fs-6.18.63-ophub.ko | PASS | PASS |

Concurrent STA + AP operation was also tested successfully on kernel 6.18.63.

**Important:** The module must match the exact kernel build. Modules built for different kernel versions are not interchangeable.

Check the running kernel:

    uname -r

## Tested Distributions

The following distributions were included in testing:

- Debian Bookworm
- Debian Trixie
- Ubuntu Noble
- Ubuntu Resolute

Kernels 6.18.59 and 6.18.63 passed the Wi-Fi tests across Bookworm, Trixie, and Ubuntu Noble.

Kernels 6.12.114 and 6.12.117 were built and tested on Ubuntu Resolute.

The distribution alone does not determine module compatibility. The exact kernel version and build must match.

## Package Contents

- `8189fs.ko`: Master module, identical to the 6.18.63 module
- `8189fs-6.12.114-ophub.ko`: Kernel 6.12.114 module
- `8189fs-6.12.117-ophub.ko`: Kernel 6.12.117 module
- `8189fs-6.18.59-ophub.ko`: Kernel 6.18.59 module
- `8189fs-6.18.63-ophub.ko`: Kernel 6.18.63 module
- `rtl8189fs-kernel-6.12.patch`: Kernel 6.12 compatibility patch
- `rtl8189fs-kernel-6.18.patch`: Kernel 6.18 compatibility patch
- `install.sh`: Automatic installer
- `uninstall.sh`: Uninstaller
- `BUILD-INFO.txt`: Build environments and test details
- `SHA256SUMS`: Module checksums

The public package does not include the complete driver source code.

## Installation

Extract the package and enter its directory.

Check the running kernel:

    uname -r

Run the installer as root:

    sudo ./install.sh

The installer selects the module matching the running kernel and checks its vermagic and RTL8189FS SDIO device alias.

An existing module is backed up separately for each kernel before replacement.

Reboot after installation.

## Uninstallation

If the RTL8189FS driver is currently loaded, unload it first:

    sudo modprobe -r 8189fs

**Note:** If you are connected through this Wi-Fi adapter, your connection will be disconnected. Use a wired connection or local console.

Run the uninstaller as root:

    sudo ./uninstall.sh

The uninstaller removes the installed driver and restores the original compatible module backup when available.

Backups are stored under:

    /var/backups/rtl8189fs/

If no original backup exists, the installed driver is removed without restoring another module.

Reboot after uninstallation.
## Manual Loading Test

Unload the currently loaded driver:

    sudo modprobe -r 8189fs

Insert the module matching the running kernel. For example:

    sudo insmod ./8189fs-6.12.117-ophub.ko

Check the driver and interfaces:

    lsmod | grep 8189
    ip link
    dmesg | tail -30

Manual loading does not survive reboot.

## Test Summary

All four kernel versions passed module loading, Wi-Fi interface detection, scanning, STA connection, and internet connectivity tests.

AP mode was tested successfully on kernels 6.18.59 and 6.18.63. Concurrent STA + AP operation was tested successfully on 6.18.63.

AP mode was not tested on kernels 6.12.114 and 6.12.117.

## Important Notes

- Always use the module matching the exact supported kernel.
- Modules built for different kernel versions are not interchangeable.
- Compatibility with other kernel builds is untested.
- Keep an alternative recovery method before replacing an existing Wi-Fi driver.
- Firmware is embedded in the driver source.

## Original Driver Source

Repository: https://github.com/jwrdegoede/rtl8189ES_linux

Branch: `rtl8189fs`

Source commit: `13bbdbc`

