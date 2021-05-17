#!/bin/sh
set -e

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- octoprint --basedir /octoprint/octoprint config set --json webcam "{\"ffmpeg\":\"/usr/bin/ffmpeg\",\"snapshot\":\"http://10.1.2.101:8080/images/live.jpg\",\"stream\":\"http://10.1.2.101:8080/hls/live.stream.m3u8\"}" "$@"
fi

exec "$@"