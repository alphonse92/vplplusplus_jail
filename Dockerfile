FROM ubuntu:16.04

ENV VPLJAIL_SYS_VERSION=2.5.2
ENV VPLJAIL_INSTALL_DIR /etc/vpl
ENV FQDN localhost

RUN apt-get -qq update && apt-get -yqq install --no-install-recommends  curl apt-utils autotools-dev automake

ENV TEMP /tmp/
WORKDIR $TEMP
RUN curl http://vpl.dis.ulpgc.es/releases/vpl-jail-system-$VPLJAIL_SYS_VERSION.tar.gz | tar -zxC ./
ENV DEBIAN_FRONTEND noninteractive

WORKDIR $TEMP/vpl-jail-system-$VPLJAIL_SYS_VERSION/
# THe next run statement will install the dependencies that  im needing.
# These packages are installed by VPL, but i want to create
# A cache layer for these dependencies
RUN  apt-get update -y  && apt-get install -y software-properties-common && add-apt-repository universe &> /dev/null 
# Install dependencies by my own
RUN  apt-get install -y make  \ 
	# VPL core packages
	lsb lsb-core \
	g++ \
	openssl \
	libssl-dev \
	iptables \
	xorg \
	dbus-x11 \
	tightvncserver \
	xfonts-75dpi \
	xfonts-100dpi \
	openbox \
	gconf2 \
	xterm \
	firefox \
	wget \
	curl \
net-tools

RUN apt-get install -y software-properties-common && apt-get update -y && add-apt-repository universe  \
	&& apt-get update -y 

RUN  apt-get install -y \
	default-jre  openjdk-8-jre  \
	default-jdk  openjdk-8-jdk  \
  && update-alternatives --config java && update-alternatives --auto java \
	&& update-alternatives --auto javac\
	&& apt-get install -y \
	gcc \
	openjfx \
	checkstyle \
	junit4 \
	junit 

# We will say yes to create a certificate
# We will say yes to create a wildcard for the cert
# We will say to the rest of questions
RUN printf 'y\ny\nn\nn\nn\nn\nn\nn\nn' | ./install-vpl-sh ; exit 0
# GO to the vpl service folder
WORKDIR $VPLJAIL_INSTALL_DIR
# Allow to execute
# Install supervisor
RUN apt-get install -y supervisor 
# Copy the new entrypoint
COPY ./app/entrypoint.sh .
RUN chmod +x ./entrypoint.sh
# Run all of this shit
CMD ["./entrypoint.sh"]