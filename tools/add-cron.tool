#!/bin/bash

# DESCRIPTION: adds a cron. Usage: add-cron my-app "* * * * * echo hello"
# DEPENDENCIES: none

JOURNAL=$1
CRON=$2

if [[ $# -lt 2 ]] ; then
    echo 'Must specify app name and cron. Usage: add-cron my-app "* * * * * echo hello"'
    exit 1
fi

echo "Actual crontab:"
echo ""
crontab -l > /tmp/mycron

if grep "$CRON" "/tmp/mycron"; then
    echo ""
    echo "Crontab already exists!"
else
    JOURNAL_CRON="$CRON | systemd-cat -t $JOURNAL"
    echo ""
    echo "Adding cron: $JOURNAL_CRON"
    #echo new cron into cron file
    echo "$JOURNAL_CRON" >> /tmp/mycron
    #install new cron file
    crontab /tmp/mycron
fi
rm /tmp/mycron

echo ""
echo "The logs will be accessible through systemd journal: journalctl -t $JOURNAL"