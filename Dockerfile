FROM debian:bullseye-slim

RUN set -e; \
	apt-get update; \
	apt-get dist-upgrade -y; \
	apt-get install -y \
		curl \
		cython3 \
		git-core \
		ipmitool \
		libffi-dev \
		libhidapi-dev \
		libssl-dev \
		libsystemd-dev \
		libudev-dev \
		libusb-1.0-0-dev \
		pkg-config \
		psmisc \
		python3-pip \
		python3-setuptools \
		python3-libgpiod \
		python3-usb \
		python3-wheel \
		rustc \
		telnet \
		snmp; \
	apt-get clean; \
	:

ARG PIP_URI=git+https://github.com/pdudaemon/pdudaemon.git
RUN pip3 install ${PIP_URI}
RUN mkdir -p /etc/pdudaemon
COPY share/pdudaemon.conf /etc/pdudaemon/

ENTRYPOINT ["/usr/local/bin/pdudaemon"]
CMD ["--dbfile=/etc/pdudaemon/db.sqlite"]
EXPOSE 16421
