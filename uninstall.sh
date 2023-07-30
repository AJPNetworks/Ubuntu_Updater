#!/bin/bash

if [ -d /var/spool/cron/crontabs ] && grep -q '/usr/bin/fullaptupgrade' /var/spool/cron/crontabs/root; then
    (crontab -l | grep -v '/usr/bin/fullaptupgrade') | crontab -
fi

if [ -d /var/spool/cron ] && grep -q '/usr/bin/fullaptupgrade' /var/spool/cron/root; then
    (crontab -l | grep -v '/usr/bin/fullaptupgrade') | crontab -
fi

sudo rm -f /etc/logrotate.d/fullaptupgrade

sudo rm -f /var/log/update_server.log

sudo rm -f /usr/bin/fullaptupgrade

if [ -d /var/spool/cron/crontabs ] && grep -q '/usr/bin/fullaptupgrade' /var/spool/cron/crontabs/root; then
    (crontab -l | grep -v '/usr/bin/fullaptupgrade') | crontab -
fi

echo "Auto-update and log rotation uninstallation completed!"
