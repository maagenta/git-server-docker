#!/bin/sh
if [ ! -f /etc/ssh/sshd_config ]; then
    cp -r /etc/ssh.bak/. /etc/ssh/
fi
exec /usr/sbin/sshd -D
