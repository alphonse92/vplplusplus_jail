FROM ubuntu:16.04

ENV VPLJAIL_SYS_VERSION=2.2.2
ENV VPLJAIL_INSTALL_DIR /etc/vpl
ENV FQDN localhost

RUN apt-get -qq update && apt-get -yqq install --no-install-recommends vim curl apt-utils autotools-dev automake  \
	openssl libssl-dev gconf2 firefox \
	make g++ gcc gdb nodejs php7.0-cli php7.0-sqlite python pydb python-tk \
	 locales supervisor && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LC_ALL en_US.UTF-8

WORKDIR /tmp/vpl-jail-system-$VPLJAIL_SYS_VERSION/
RUN 	curl http://vpl.dis.ulpgc.es/releases/vpl-jail-system-$VPLJAIL_SYS_VERSION.tar.gz | tar -zxC /tmp/ \
	&& ./configure && make && mkdir $VPLJAIL_INSTALL_DIR && cp src/vpl-jail-server $VPLJAIL_INSTALL_DIR \
	&& cp vpl-jail-system.conf $VPLJAIL_INSTALL_DIR \
	&& chmod 600 $VPLJAIL_INSTALL_DIR/vpl-jail-system.conf && cp vpl_*.sh /etc/vpl && chmod +x /etc/vpl/*.sh \
	&& cp vpl-jail-system.initd /etc/init.d/vpl-jail-system && chmod +x /etc/init.d/vpl-jail-system \
	&& mkdir /var/vpl-jail-system && chmod 0600 /var/vpl-jail-system \
	&& printf "[supervisord]\nnodaemon=false\n[program:vpl-jail-system]\ncommand=/etc/init.d/vpl-jail-system start" >> /etc/supervisor/supervisord.conf \
	&& rm -rf /tmp/vpl-jail-system-$VPLJAIL_SYS_VERSION/

RUN apt-get update -y  \ 
    && apt-get -yqq install --no-install-recommends  software-properties-common \
    && add-apt-repository ppa:openjdk-r/ppa \
    && apt-get update -y
RUN apt-get install -y default-jdk openjdk-7-jdk checkstyle junit4 junit
WORKDIR /etc/vpl/
COPY ./app/entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]