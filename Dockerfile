ARG PYTHON_BASE_IMAGE=3.8-slim-buster

FROM ubuntu AS s6build
ARG S6_RELEASE
ENV S6_VERSION ${S6_RELEASE:-v2.1.0.0}
RUN apt-get update && apt-get install -y curl
RUN echo "$(dpkg --print-architecture)"
WORKDIR /tmp
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
  amd64) ARCH='amd64';; \
  arm64) ARCH='aarch64';; \
  armhf) ARCH='armhf';; \
  *) echo "unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
  esac \
  && set -ex \
  && echo $S6_VERSION \
  && curl -fsSLO "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-$ARCH.tar.gz"


FROM python:${PYTHON_BASE_IMAGE} AS build

ARG octoprint_ref
ENV octoprint_ref "1.6.1"

RUN apt-get update && apt-get install -y \
  avrdude \
  build-essential \
  cmake \
  curl \
  imagemagick \
  ffmpeg \
  fontconfig \
  g++ \
  git \
  haproxy \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libv4l-dev \
  openssh-client \
  v4l-utils \
  xz-utils \
  zlib1g-dev

# unpack s6
COPY --from=s6build /tmp /tmp
RUN s6tar=$(find /tmp -name "s6-overlay-*.tar.gz") \
  && tar xzf $s6tar -C / 

# Install octoprint
RUN	curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/OctoPrint/OctoPrint/archive/${octoprint_ref}.tar.gz \
	&& mkdir -p /opt/octoprint \
  && tar xzf ${octoprint_ref}.tar.gz --strip-components 1 -C /opt/octoprint --no-same-owner

WORKDIR /opt/octoprint
RUN pip install .
RUN mkdir -p /octoprint/octoprint /octoprint/plugins

# Copy services into s6 servicedir and set default ENV vars
COPY root /
ENV CAMERA_DEV /dev/video0
ENV MJPG_STREAMER_INPUT -n -r 640x480
ENV PIP_USER true
ENV PYTHONUSERBASE /octoprint/plugins
ENV PATH "${PYTHONUSERBASE}/bin:${PATH}"
# set WORKDIR 
WORKDIR /octoprint

RUN PYTHONUSERBASE=/usr/local/ pip install --no-cache-dir \
    "https://github.com/tg44/OctoPrint-Prometheus-Exporter/archive/refs/tags/0.1.7.zip" \
    "https://github.com/gdombiak/OctoPod/archive/refs/tags/3.11.zip" \
    "https://github.com/OllisGit/OctoPrint-PrintJobHistory/releases/download/1.14.0/master.zip" \
    "https://github.com/markwal/OctoPrint-SnapStream/archive/refs/tags/0.3.zip" \
    "https://github.com/OctoPrint/OctoPrint-FirmwareUpdater/archive/refs/tags/1.11.0.zip" \
    "https://github.com/Birkbjo/OctoPrint-Themeify/archive/refs/tags/v1.2.2.zip" \
    "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/refs/tags/2.2.8.zip" \
    "https://github.com/jneilliii/OctoPrint-TPLinkSmartplug/archive/refs/tags/1.0.1.zip" \
    "https://github.com/tideline3d/OctoPrint-GitFiles/archive/refs/tags/1.1.5_t3d_4.zip" \
    "https://github.com/jneilliii/OctoPrint-BedLevelVisualizer/archive/refs/tags/1.0.1.zip" \
    "https://github.com/OllisGit/OctoPrint-SpoolManager/releases/download/1.4.3/master.zip"
    
# port to access haproxy frontend
EXPOSE 80

VOLUME /octoprint

ENTRYPOINT ["/init"]