#!/bin/bash
# package:		Part of vpl-jail-system
# copyright:    Copyright (C) 2014 Juan Carlos Rodriguez-del-Pino
# license:      GNU/GPL, see LICENSE.txt or http://www.gnu.org/licenses/gpl.txt
# Description:  Script to install vpl-jail-system (Ubuntu 12 and CentOS)

function add_envars {
    cd $VPLJAIL_INSTALL_DIR
    if [ -n "${JAIL_PORT}" ] ; then
        echo "JAIL_PORT exists, added to conf file"
        echo "PORT=${JAIL_PORT}" >> vpl-jail-system.conf
    else
        echo "JAIL_PORT doenst exist"
    fi

    if [ -n "${JAIL_SECURE_PORT}" ] ; then
        echo "JAIL_SECURE_PORT exists, added to conf file"
        echo "PORT=${JAIL_SECURE_PORT}" >> vpl-jail-system.conf
    else
        echo "JAIL_SECURE_PORT doenst exist,"
    fi
}

function vpl_generate_selfsigned_certificate {
	echo "Generating self-signed SSL certificate"
	#Generate key
	openssl genrsa -passout pass:12345678 -des3 -out key.pem 1024
	#Generate certificate for this server
	local SUBJOPT="-subj"
	local SUBJ="/C=ES/ST=State/L=Location/O=VPL/OU=Execution server/CN=$FQDN"
	openssl req -new $SUBJOPT "$SUBJ" -key key.pem -out certini.pem -passin pass:12345678
	#Remove key password
	cp key.pem keyini.pem
	openssl rsa -in keyini.pem -out key.pem -passin pass:12345678
	#Generate self signed certificate for 5 years
	openssl x509 -in certini.pem -out cert.pem -req -signkey key.pem -days 1826 
}
if [ ! -f $VPLJAIL_INSTALL_DIR/cert.pem ] ; then
	cd /tmp/
	vpl_generate_selfsigned_certificate
	cp key.pem $VPLJAIL_INSTALL_DIR
	cp cert.pem $VPLJAIL_INSTALL_DIR
	chmod 600 $VPLJAIL_INSTALL_DIR/*.pem
	rm key.pem keyini.pem certini.pem cert.pem
else
	echo "Found SSL certificate => Don't create new one"
fi

printenv
add_envars
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
