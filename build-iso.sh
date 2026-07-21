#!/bin/bash
# KhazarOS — Build bootable ISO from source
# 
# This is how Pardus/Tails/Kali build their distros:
#   1. Take a base distro (Fedora Silverblue)
#   2. Add your packages + branding
#   3. Build ISO
#
# Requirements: Fedora 40+, podman, 20GB disk
# First run: ~20 min (downloads base image)
# Subsequent: ~3 min (cached)

set -e
V="${1:-0.1.0}"

echo "=============================================="
echo "  KhazarOS v${V} — ISO Builder"
echo "  Base: Fedora Silverblue 40"
echo "=============================================="
echo ""

# 1. Build Khazar if not already built
if [ ! -f "components/orchestrator/ai-orchestrator" ]; then
    echo "[1/3] Building Khazar platform..."
    make clean &>/dev/null || true
    make all
fi

# 2. Copy binaries to system overlay
echo "[2/3] Preparing system overlay..."
mkdir -p system/usr/local/bin system/etc/khazar/policies system/usr/lib

for comp in orchestrator rule-engine policy-engine model-runtime intent-classifier; do
    cp components/$comp/ai-$comp system/usr/local/bin/ 2>/dev/null || true
done
for agent in desktop package network power audio; do
    cp agents/${agent}-agent/ai-${agent}-agent system/usr/local/bin/ 2>/dev/null || true
done
cp sdk/libai-sdk.a system/usr/lib/ 2>/dev/null || true
cp distro/cli/kha system/usr/local/bin/
chmod +x system/usr/local/bin/*

# 3. Build container + ISO
echo "[3/3] Building container image + ISO..."
echo "       (First run downloads Fedora Silverblue — ~3GB)"
echo ""

podman build --tag khazaros:${V} -f Containerfile .

# Convert container to ISO
if command -v bootc-image-builder &>/dev/null; then
    sudo bootc-image-builder \
        --type anaconda-iso \
        --rootfs xfs \
        localhost/khazaros:${V} \
        khazaros-${V}-x86_64.iso
else
    echo ""
    echo "bootc-image-builder not installed."
    echo "Install: pip install bootc-image-builder"
    echo ""
    echo "Pushing to ghcr.io instead..."
    echo "Then download ISO from GitHub Releases."
    echo ""
    echo "Or export as tar:"
    podman save khazaros:${V} | gzip > khazaros-${V}-x86_64.tar.gz
    echo "  -> khazaros-${V}-x86_64.tar.gz ($(du -h khazaros-${V}-x86_64.tar.gz | cut -f1))"
fi

echo ""
echo "=============================================="
ls -lah khazaros-* 2>/dev/null || echo "Build the distro on a Fedora 40+ machine with podman installed."
echo "=============================================="
