FROM resin/rpi-raspbian:stretch

LABEL maintainer="mt08xx@users.noreply.github.com"

ENV VERSION 0.01

RUN apt-get update && apt-get install -y \
	parprouted \
	dhcp-helper \
	hostapd \
	bcrelay \
	iproute2 \
	&& rm -rf /var/lib/apt/lists/*

ADD start.sh /bin/start.sh

ENTRYPOINT [ "/bin/start.sh" ]
