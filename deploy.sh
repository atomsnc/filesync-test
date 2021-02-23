#!/bin/bash

HOME_DIR=
HOST_USER=
HOST_DIR=
HOST_DIR_SIZE=
LOGFILE=/var/log/filesync-lld.log

if [ -z "$1" ]; then
  echo "This script requires 1 commandline argument. Exiting."
  exit 1
fi

DEPLOYMENT_DIR="$1"

cd $DEPLOYMENT_DIR

SYSTEMD_SOURCE=filesync.service
SYSTEMD_TARGET=/etc/systemd/system/filesync.service
TIMER_SOURCE=filesync.timer
TIMER_TARGET=/etc/systemd/system/filesync.timer

#Make unison directory if not present.
if [ ! -d "$HOME_DIR/.unison" ] 
then
    mkdir $HOME_DIR/.unison
    chown $HOST_USER:$HOST_USER $HOME_DIR/.unison
fi

if [ ! -d "$HOST_DIR" ]
then
    mkdir $HOST_DIR
    chown $HOST_USER:$HOST_USER $HOST_DIR
fi

#Move sync.sh to opt
cp sync.sh /opt/

#Copy unison preferences out to the default location.
cp default.prf $HOME_DIR/.unison/
chown $HOST_USER:$HOST_USER $HOME_DIR/.unison/default.prf

#Copy timer and service files
if [ ! -f $SYSTEMD_TARGET ]; then
  cp $SYSTEMD_SOURCE $SYSTEMD_TARGET
  systemctl daemon-reload
fi
if ! cmp -s $SYSTEMD_SOURCE $SYSTEMD_TARGET > /dev/null 2>&1; then
  cp $SYSTEMD_SOURCE $SYSTEMD_TARGET
  systemctl daemon-reload
fi

if [ ! -f $TIMER_TARGET ]; then
  cp $TIMER_SOURCE $TIMER_TARGET
  systemctl daemon-reload
fi
if ! cmp -s $TIMER_SOURCE $TIMER_TARGET > /dev/null 2>&1; then
  cp $TIMER_SOURCE $TIMER_TARGET
  systemctl daemon-reload
fi

echo "[" >> $LOGFILE
echo "{	\"{#DIRPATH}\":\"$HOST_DIR\",	\"{#DIRSIZE}\":\"$hOST_DIR_SIZE\"	}," >>  $LOGFILE
echo "]" >> $LOGFILE



