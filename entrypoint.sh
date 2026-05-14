#!/bin/sh
if [ ! -f /etc/ssh/sshd_config ]; then
    cp -r /etc/ssh.bak/. /etc/ssh/
fi
chown git:git /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys
exec /usr/sbin/sshd -D -e
