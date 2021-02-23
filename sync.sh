#!/bin/bash

DIR_LOCAL=
DIR_REMOTE=
MAX_SIZE_DIR_LOCAL=
MAX_SIZE_DIR_REMOTE=
HOSTNAME_REMOTE=
HOST_USER_REMOTE=
HOST_USER=
LOGFILE=/var/log/filesync-status.log

#Check if job already running
if [ $(who -s | grep $HOST_USER | grep -c "$HOSTNAME_REMOTE"')') -ne 0 ]; then
        echo "Job already running from remote computer. Skipping."
        exit 0
fi


SIZE_DIR_LOCAL=$(du -k --max-depth=0 "$DIR_LOCAL" | cut -f1)
echo "Size of $DIR_LOCAL is $SIZE_DIR_LOCAL bytes."

SIZE_DIR_REMOTE=$(ssh $HOST_USER_REMOTE@$HOSTNAME_REMOTE du -k --max-depth=0 "$DIR_REMOTE" | cut -f1)
echo "Size of $DIR_REMOTE is $SIZE_DIR_REMOTE bytes."

#Check if local directory is over max limit
OVERLIMIT_LOCAL=$(echo $SIZE_DIR_LOCAL'>'$MAX_SIZE_DIR_LOCAL | bc -l)

#Check if remote directory is over max limit
OVERLIMIT_REMOTE=$(echo $SIZE_DIR_REMOTE'>'$MAX_SIZE_DIR_REMOTE | bc -l)

#Cross-check local-size against remote max-size
OVERLIMIT_LOCAL_REMOTE=$(echo $SIZE_DIR_LOCAL'>'$MAX_SIZE_DIR_REMOTE | bc -l)

#Cross-check remote-size agaist local max-size
OVERLIMIT_REMOTE_LOCAL=$(echo $SIZE_DIR_REMOTE'>'$MAX_SIZE_DIR_LOCAL | bc -l)

#Check local overlimit
if [ $OVERLIMIT_LOCAL -eq 1 ]; then
	echo "Folder $DIR_LOCAL is overlimit."
	echo "Setting overlimit watch to 1."
	echo 4 > $LOGFILE
	exit 0
fi

#Check remote overlimit
if [ $OVERLIMIT_REMOTE -eq 1 ]; then
	echo "Folder $DIR_REMOTE is overlimit."
	echo "Here REMOTE will set overlimit to 1."
	exit 0
fi

#Cross-check local size against remote limit. If bigger, set error code.
if [ $OVERLIMIT_LOCAL_REMOTE -eq 1 ]; then
	echo "Folder $DIR_LOCAL too big against remote limit."
	echo "Setting overlimit watch to 1."
	echo 4 > $LOGFILE
	exit 0
fi

#Cross-check remote size against local limit. If bigger, just exit. 
#We want the remote to set code, so error shows up correctly in monitoring against the problematic box.
if [ $OVERLIMIT_REMOTE_LOCAL -eq 1 ]; then
	echo "FOlder $DIR_REMOTE too big against local limit."
	echo "Here REMOTE will set overlimit to 1."
	exit 0
fi

/usr/bin/unison default

echo $? > $LOGFILE
