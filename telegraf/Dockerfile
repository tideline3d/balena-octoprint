FROM telegraf:1.23.0

RUN apt update

RUN apt install sudo

COPY telegraf.conf /etc/telegraf/telegraf.conf

## For Pi specific hardware telemetry via Telegraf / vcgencmd
COPY ./telegraf.d /etc/telegraf/telegraf.d
COPY ./sudoers.d/* /etc/sudoers.d
COPY ./scripts/* /usr/local/bin
