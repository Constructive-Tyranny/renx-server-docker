FROM ubuntu:eoan-20200313

EXPOSE 7777/udp
EXPOSE 6667/tcp

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        cabextract \
        gosu \
        gpg-agent \
        p7zip \
        pulseaudio-utils \
        software-properties-common \
        unzip \
        wget \
        winbind \
        zenity \
    && rm -rf /var/lib/apt/lists/*

# Install wine (Using RUN per line to make sure it gives a clear error.)
ARG WINEBRANCH
ARG WINE_VER
RUN wget https://dl.winehq.org/wine-builds/winehq.key
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add winehq.key
RUN apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main"
RUN dpkg --add-architecture i386
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-stable="5.0.0~eoan"
RUN rm -rf /var/lib/apt/lists/*
RUN rm winehq.key

# Download mono and gecko
ARG MONO_VER
ARG GECKO_VER
#RUN mkdir -p /usr/share/wine/mono /usr/share/wine/gecko \

RUN mkdir /opt/wine-stable/share/wine/mono \
    && wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono

# Download winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        -O /usr/bin/winetricks \
    && chmod +rx /usr/bin/winetricks

# Create user and take ownership of files
RUN groupadd -g 1010 wineuser \
    && useradd --shell /bin/bash --uid 1010 --gid 1010 --create-home --home-dir /home/wineuser wineuser \
    && chown -R wineuser:wineuser /home/wineuser

VOLUME /home/wineuser
COPY pulse-client.conf /etc/pulse/client.conf
COPY entrypoint.sh /usr/bin/entrypoint

WORKDIR /home/wineuser
ARG IMAGE_VER
ARG BUILD_DATE
ARG GIT_REV
LABEL \
    org.opencontainers.image.authors="CT" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Docker image for running the RenegadeX server through wine." \
    org.opencontainers.image.documentation="" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.revision="${GIT_REV}" \
    org.opencontainers.image.source="" \
    org.opencontainers.image.title="RenegadeX-Server-wine" \
    org.opencontainers.image.url="" \
    org.opencontainers.image.vendor="" \
    org.opencontainers.image.version="${IMAGE_VER}"

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/bash"]
