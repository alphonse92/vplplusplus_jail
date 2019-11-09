#!/bin/bash
./vpl-jail-system stop >> /dev/null
## Config the jail
echo "PORT=${JAIL_PORT}" >> /etc/vpl/vpl-jail-system.conf
echo "SECURE_PORT=${JAIL_SECURE_PORT}" >> /etc/vpl/vpl-jail-system.conf
## Install the jail in supervisor
printf "[supervisord]\nnodaemon=false\n[program:vpl]\ncommand=/etc/vpl/vpl-jail-system start" >> /etc/supervisor/supervisord.conf  
service supervisor start
## Tail the logs
echo ""
echo "Vpl Jail is listening on ${JAIL_PORT} and secure on  ${JAIL_SECURE_PORT}"
echo ""
tail -f /var/log/supervisor/supervisord.log