# KhazarOS — Fedora 40 Silverblue-based Live ISO
# Built with: livecd-creator -c khazaros.ks

lang en_US.UTF-8
keyboard us
timezone UTC
selinux --enforcing
firewall --enabled
bootloader --timeout=5

%include /usr/share/spin-kickstarts/fedora-live-base.ks

part / --size 8192 --fstype ext4

%packages
@core
@standard
@workstation-product-environment
@gnome-desktop
@networkmanager-submodules
@multimedia
@printing

# Remove Fedora branding, add ours
-fedora-release
-fedora-release-identity
-fedora-logos
-fedora-workstation-backgrounds
-generic-release
-generic-logos

# Khazar branding (we provide these as RPMs or files)
# khazar-release
# khazar-logos
# khazar-backgrounds

# Development tools
gcc
make
git

# Audio
pulseaudio-utils

# Network tools
NetworkManager-wifi

# Fonts
dejavu-sans-fonts
jetbrains-mono-fonts

# Icons
papirus-icon-theme

# Utilities
socat
python3
zenity

%end

%post --erroronfail
#!/bin/bash
set -e

# ── Khazar user ────────────────────
groupadd -r khazar 2>/dev/null || true
useradd -r -s /sbin/nologin -d /var/lib/khazar -g khazar khazar 2>/dev/null || true
mkdir -p /var/lib/khazar/{bin,models} /run/khazar /etc/khazar/policies
chown -R khazar:khazar /var/lib/khazar /run/khazar /etc/khazar

# ── OS Identity ─────────────────────
cat > /etc/os-release << 'EOF'
NAME="KhazarOS"
VERSION="0.1.0 (Xezer)"
ID="khazaros"
ID_LIKE="fedora"
VERSION_ID="0.1.0"
PRETTY_NAME="KhazarOS 0.1.0"
ANSI_COLOR="0;31"
HOME_URL="https://github.com/Khazar-System-Distribution/khazar-distro"
EOF

echo "KhazarOS 0.1.0" > /etc/issue
ln -sf khazar-release /etc/system-release 2>/dev/null || true

# ── Install Khazar binaries ─────────
# These are copied from the build directory by the CI
if [ -d /tmp/khazar-bin ]; then
    cp /tmp/khazar-bin/* /usr/local/bin/ 2>/dev/null || true
    chmod +x /usr/local/bin/ai-* 2>/dev/null || true
    cp /tmp/khazar-bin/kha /usr/bin/ 2>/dev/null || true
    chmod +x /usr/bin/kha 2>/dev/null || true
fi

# ── Configs ─────────────────────────
if [ -d /tmp/khazar-config ]; then
    cp /tmp/khazar-config/*.toml /etc/khazar/ 2>/dev/null || true
fi

# ── systemd services ────────────────
if [ -d /tmp/khazar-systemd ]; then
    cp /tmp/khazar-systemd/*.service /etc/systemd/system/ 2>/dev/null || true
    cp /tmp/khazar-systemd/khazar.target /etc/systemd/system/ 2>/dev/null || true
fi

systemctl enable khazar.target 2>/dev/null || true

# ── GNOME defaults ──────────────────
cat > /usr/share/glib-2.0/schemas/00-khazar-defaults.gschema.override << 'GSETTINGS'
[org.gnome.desktop.interface]
gtk-theme='Adwaita-dark'
color-scheme='prefer-dark'
font-name='DejaVu Sans 10'
GSETTINGS
glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true

# ── Cleanup ─────────────────────────
rm -rf /tmp/khazar-*
%end
