#!/bin/bash
# KhazarOS — REAL ISO Builder (run on Fedora 40+)
# Produces: khazaros.iso (bootable, 3-6 GB)
#
# Requirements: Fedora 40+, podman, 20GB free disk
# Install: sudo dnf install podman && pip install bootc-image-builder

set -e

VERSION="${1:-0.1.0}"
IMAGE="khazaros:${VERSION}"
ISO="khazaros-${VERSION}-x86_64.iso"

echo "=============================================="
echo "  KhazarOS ISO Builder v${VERSION}"
echo "  Building REAL bootable distro image"
echo "  Time: ~15-20 minutes (first run downloads Fedora)"
echo "=============================================="
echo ""

# 1. Build container
echo "[1/4] Building container image (this downloads Fedora Silverblue)..."
podman build --tag "$IMAGE" -f distro/bootc/Containerfile .

# 2. Install bootc-image-builder if needed
if ! command -v bootc-image-builder &>/dev/null; then
    echo "[*] Installing bootc-image-builder..."
    pip install --user bootc-image-builder
    export PATH="$HOME/.local/bin:$PATH"
fi

# 3. Build ISO
echo "[2/4] Building bootable ISO (requires root)..."
sudo -E "$HOME/.local/bin/bootc-image-builder" \
    --type iso \
    localhost/"$IMAGE" \
    "$ISO"

# 4. Verify
echo "[3/4] Verifying ISO..."
ls -lah "$ISO"
echo ""
echo "SHA256: $(sha256sum "$ISO" | cut -d' ' -f1)"
echo ""

# 5. Done
echo "=============================================="
echo "  ISO READY: $ISO"
echo "=============================================="
echo ""
echo "  Test in QEMU:"
echo "    qemu-system-x86_64 -m 4096 -enable-kvm -hda $ISO"
echo ""
echo "  Write to USB:"
echo "    sudo dd if=$ISO of=/dev/sdX bs=4M status=progress"
echo ""
echo "  VirtualBox:"
echo "    Create VM -> Use existing disk -> $ISO"
