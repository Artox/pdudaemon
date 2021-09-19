FROM alpine:3.14 AS rdepends

RUN set -e; \
	arch=$(cat /etc/apk/arch); \
	wget https://github.com/Artox/alpine-systemd/releases/download/1/libsystemd-249-r0.$arch.apk; \
	wget https://github.com/Artox/alpine-python-systemd/releases/download/1/py3-systemd-234-r0.$arch.apk; \
	apk --allow-untrusted --no-cache add *.apk; \
	rm -f *.apk; \
	:

RUN sed -i "s;^#\(.*\)/community;\1/community;g" /etc/apk/repositories

RUN apk --no-cache add \
	python3 \
	py3-pexpect \
	py3-requests \
	py3-paramiko \
	py3-pyserial \
	py3-setuptools \
	py3-hidapi \
	py3-snmp \
	py3-asn1 \
	py3-usb \
	py3-libgpiod \
	py3-ply \
	py3-pycryptodomex

FROM rdepends AS build

RUN apk add py3-pip

COPY . /work
WORKDIR /work
RUN pip3 install --root=/dist .

FROM rdepends AS run

RUN apk add curl ipmitool psmisc
# TODO: add more runtime dependencies

COPY --from=build /dist /

RUN mkdir -p /etc/pdudaemon
COPY share/pdudaemon.conf /etc/pdudaemon/

ENTRYPOINT ["/usr/bin/pdudaemon"]
CMD ["--dbfile=/etc/pdudaemon/db.sqlite"]
EXPOSE 16421
