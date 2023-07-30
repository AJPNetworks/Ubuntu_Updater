#!/bin/bash

if [ ! -d /var/spool/cron/crontabs ] && [ ! -d /var/spool/cron ]; then
    echo "Error: Could not find the cron tab location."
    exit 1
fi

if ! command -v wget &>/dev/null; then
    echo "Error: 'wget' command not found. Please install 'wget' to proceed."
    exit 1
fi

cat << 'EOF' > fullaptupgrade.sh
#!/bin/bash

if [[ "$1" == "--uninstall" ]]; then
    echo "Uninstalling the software..."

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

    # Exit after uninstallation
    exit 0
fi


LOG_FILE="/var/log/update_server.log"
exec &>> "\$LOG_FILE"

echo "--------------------------------------"
echo "\$(date): Starting server update"

sudo apt-get update

sudo apt-get dist-upgrade -y

sudo apt-get autoremove -y

echo "\$(date): Server update completed"

EOF

cat << 'EOF' > update_server_logrotate
/var/log/update_server.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    create 644 root root
}
EOF

if [ -d /var/spool/cron/crontabs ]; then
    CRON_TAB_LOCATION="/var/spool/cron/crontabs/root"
else
    CRON_TAB_LOCATION="/var/spool/cron/root"
fi

sudo mv fullaptupgrade.sh /usr/bin/fullaptupgrade
sudo mv update_server_logrotate /etc/logrotate.d/fullaptupgrade
sudo chmod +x /usr/bin/fullaptupgrade
sudo touch /var/log/update_server.log
sudo chmod 644 /var/log/update_server.log

sudo sh -c 'echo "0 0 * * * /usr/bin/auto_server_upgrade_uninstall.sh" >> /var/spool/cron/crontabs/root'


echo "Auto-update and log rotation setup completed!"
