FROM ubuntu:eoan-20200313

EXPOSE 7777/udp

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

# Install Mono (complete)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends mono-complete \
    && rm -rf /var/lib/apt/lists/* \

# Install wine
ARG WINEBRANCH
ARG WINE_VER
RUN wget https://dl.winehq.org/wine-builds/winehq.key
RUN APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add winehq.key
RUN apt-add-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ eoan main"
RUN dpkg --add-architecture i386
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-stable="${WINE_VER}"
RUN rm -rf /var/lib/apt/lists/*
RUN rm winehq.key

# Download mono and gecko
ARG MONO_VER
ARG GECKO_VER
#RUN mkdir -p /usr/share/wine/mono /usr/share/wine/gecko \
#    && wget https://dl.winehq.org/wine/wine-mono/${MONO_VER}/wine-mono-${MONO_VER}.msi \
#        -O /usr/share/wine/mono/wine-mono-${MONO_VER}.msi \
#    && wget https://dl.winehq.org/wine/wine-gecko/${GECKO_VER}/wine_gecko-${GECKO_VER}-x86.msi \
#        -O /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86.msi \
#    && wget https://dl.winehq.org/wine/wine-gecko/${GECKO_VER}/wine_gecko-${GECKO_VER}-x86_64.msi \
#        -O /usr/share/wine/gecko/wine-gecko-${GECKO_VER}-x86_64.msi
RUN mkdir /opt/wine-stable/share/wine/mono \
    && wget -O - https://dl.winehq.org/wine/wine-mono/4.9.4/wine-mono-bin-4.9.4.tar.gz |tar -xzv -C /opt/wine-stable/share/wine/mono 
RUN mkdir /opt/wine-stable/share/wine/gecko \
    && wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine_gecko-2.47.1-x86.msi \
    && wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.1-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.1/wine_gecko-2.47.1-x86_64.msi 

# Download winetricks
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
        -O /usr/bin/winetricks \
    && chmod +rx /usr/bin/winetricks
    && winetricks

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
