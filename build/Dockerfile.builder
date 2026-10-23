# CozyHaze OS - Docker Build Container
# Ermöglicht den reproduzierbaren ISO-Build auf jedem Linux- oder Docker-fähigen Host

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Notwendige Build-Werkzeuge installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    live-build \
    debootstrap \
    xorriso \
    squashfs-tools \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-pil \
    rsync \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Einstiegspunkt zum Ausführen des Build-Skripts
ENTRYPOINT ["/bin/bash", "/workspace/build/build-iso.sh"]
