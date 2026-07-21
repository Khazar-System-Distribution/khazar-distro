# KhazarOS — Fedora Silverblue fork
# Based on Universal Blue (ublue-os)
# Builds a complete AI-powered desktop OS

FROM ghcr.io/ublue-os/silverblue-main:40

# ── Khazar user ────────────────────────────
RUN groupadd -r khazar 2>/dev/null || true && \
    useradd -r -s /sbin/nologin -d /var/lib/khazar -g khazar khazar 2>/dev/null || true
RUN mkdir -p /var/lib/khazar/{bin,models} /run/khazar /etc/khazar/policies && \
    chown -R khazar:khazar /var/lib/khazar /run/khazar /etc/khazar

# ── Dependencies ───────────────────────────
RUN rpm-ostree install --apply-live \
    papirus-icon-theme \
    jetbrains-mono-fonts \
    dejavu-sans-fonts \
    gnome-tweaks \
    NetworkManager-wifi \
    pulseaudio-utils

# ── Khazar AI Platform (pre-compiled) ─────
COPY system/usr/local/bin/ /usr/local/bin/
COPY system/usr/lib/ /usr/lib/
COPY system/etc/khazar/ /etc/khazar/
COPY system/etc/systemd/system/ /etc/systemd/system/
RUN chmod +x /usr/local/bin/* 2>/dev/null || true

# ── CLI ───────────────────────────────────
COPY system/usr/local/bin/kha /usr/bin/kha
RUN chmod +x /usr/bin/kha

# ── systemd daemons ───────────────────────
RUN systemctl enable khazar.target && \
    systemctl enable khazar-identity.service && \
    systemctl enable ai-rule-engine.service && \
    systemctl enable ai-policy-engine.service && \
    systemctl enable ai-orchestrator.service && \
    systemctl enable ai-desktop-agent.service && \
    systemctl enable ai-package-agent.service && \
    systemctl enable ai-network-agent.service && \
    systemctl enable ai-power-agent.service && \
    systemctl enable ai-audio-agent.service

# ── OS Identity ────────────────────────────
COPY system/etc/os-release /usr/lib/os-release
COPY system/etc/issue /etc/issue
COPY system/usr/share/khazar /usr/share/khazar

# ── GNOME Theme ────────────────────────────
COPY system/usr/share/themes /usr/share/themes
COPY system/usr/share/gnome-shell/extensions /usr/share/gnome-shell/extensions
COPY system/usr/share/glib-2.0/schemas/00-khazar-defaults.gschema.override \
     /usr/share/glib-2.0/schemas/
RUN glib-compile-schemas /usr/share/glib-2.0/schemas/

# ── GRUB + Plymouth ────────────────────────
COPY system/boot /boot
COPY system/usr/share/plymouth /usr/share/plymouth
RUN plymouth-set-default-theme khazar 2>/dev/null || true

# ── Wallpaper ──────────────────────────────
COPY system/usr/share/backgrounds /usr/share/backgrounds
COPY system/usr/share/icons /usr/share/icons

# ── Cleanup ────────────────────────────────
RUN rm -rf /var/cache/* /tmp/*
RUN rpm-ostree cleanup -m

# ── Metadata ───────────────────────────────
LABEL distro.name="KhazarOS"
LABEL distro.version="0.1.0"
LABEL distro.family="Fedora Silverblue"
LABEL distro.homepage="https://github.com/Khazar-System-Distribution/khazar-distro"

CMD ["/sbin/init"]
