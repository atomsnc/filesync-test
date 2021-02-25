#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "This script requires 2 commandline argument. Exiting."
  exit 1
fi

#Source the variables
source vars

HOST1="$1"
HOST2="$2"

#Create directories
if [ ! -d "$HOST1" ] 
then
    mkdir $HOST1
fi
if [ ! -d "$HOST2" ] 
then
    mkdir $HOST2
fi

#Copy template files
cp default.prf $HOST1/
cp default.prf $HOST2/

cp sync.sh $HOST1/
cp sync.sh $HOST2/

cp deploy.sh $HOST1/
cp deploy.sh $HOST2/

cp filesync.service $HOST1/
cp filesync.service $HOST2/

cp filesync.timer $HOST1/
cp filesync.timer $HOST2/

#Add root variable values in default.prf
sed -i "0,/#root=/{s;#root=;root=$HOST1_DIR;}" $HOST1/default.prf
sed -i "0,/#root=/{s;#root=;root=ssh://$HOST2_USER@$HOST2_HOSTNAME/$HOST2_DIR;}" $HOST1/default.prf

for word in $HOST1_IGNORE; do
	echo "ignore=$word" >> $HOST1/default.prf
done

sed -i "0,/#root=/{s;#root=;root=$HOST2_DIR;}" $HOST2/default.prf
sed -i "0,/#root=/{s;#root=;root=ssh://$HOST1_USER@$HOST1_HOSTNAME/$HOST1_DIR;}" $HOST2/default.prf

for word in $HOST2_IGNORE; do
	echo "ignore=$word" >> $HOST2/default.prf
done

#Add variable values in sync.sh
sed -i "/^DIR_LOCAL=/ s;$;$HOST1_DIR;" $HOST1/sync.sh
sed -i "/^DIR_REMOTE=/ s;$;$HOST2_DIR;" $HOST1/sync.sh
sed -i "/^MAX_SIZE_DIR_LOCAL=/ s;$;$HOST1_MAX_SIZE_DIR;" $HOST1/sync.sh
sed -i "/^MAX_SIZE_DIR_REMOTE=/ s;$;$HOST2_MAX_SIZE_DIR;" $HOST1/sync.sh
sed -i "/^HOSTNAME_REMOTE=/ s;$;$HOST2_HOSTNAME;" $HOST1/sync.sh
sed -i "/^HOST_USER_REMOTE=/ s;$;$HOST2_USER;" $HOST1/sync.sh
sed -i "/^HOST_USER=/ s;$;$HOST1_USER;" $HOST1/sync.sh

sed -i "/^DIR_LOCAL=/ s;$;$HOST2_DIR;" $HOST2/sync.sh
sed -i "/^DIR_REMOTE=/ s;$;$HOST1_DIR;" $HOST2/sync.sh
sed -i "/^MAX_SIZE_DIR_LOCAL=/ s;$;$HOST2_MAX_SIZE_DIR;" $HOST2/sync.sh
sed -i "/^MAX_SIZE_DIR_REMOTE=/ s;$;$HOST1_MAX_SIZE_DIR;" $HOST2/sync.sh
sed -i "/^HOSTNAME_REMOTE=/ s;$;$HOST1_HOSTNAME;" $HOST2/sync.sh
sed -i "/^HOST_USER_REMOTE=/ s;$;$HOST1_USER;" $HOST2/sync.sh
sed -i "/^HOST_USER=/ s;$;$HOST2_USER;" $HOST2/sync.sh

#Add home variable value in deploy.sh
sed -i "/^HOME_DIR=/ s;$;$HOST1_HOME;" $HOST1/deploy.sh
sed -i "/^HOST_DIR=/ s;$;$HOST1_DIR;" $HOST1/deploy.sh
sed -i "/^HOST_USER=/ s;$;$HOST1_USER;" $HOST1/deploy.sh
sed -i "/^HOST_DIR_SIZE=/ s;$;$HOST1_MAX_SIZE_DIR;" $HOST1/deploy.sh

sed -i "/^HOME_DIR=/ s;$;$HOST2_HOME;" $HOST2/deploy.sh
sed -i "/^HOST_DIR=/ s;$;$HOST2_DIR;" $HOST2/deploy.sh
sed -i "/^HOST_USER=/ s;$;$HOST2_USER;" $HOST2/deploy.sh
sed -i "/^HOST_DIR_SIZE=/ s;$;$HOST2_MAX_SIZE_DIR;" $HOST2/deploy.sh

#Add variables to filesync.service
sed -i "/^WorkingDirectory=/ s;$;$HOST1_DIR;" $HOST1/filesync.service
sed -i "/^User=/ s;$;$HOST1_USER;" $HOST1/filesync.service

sed -i "/^WorkingDirectory=/ s;$;$HOST2_DIR;" $HOST2/filesync.service
sed -i "/^User=/ s;$;$HOST2_USER;" $HOST2/filesync.service

#Add variables to filesync.timer
sed -i '/^OnCalendar=/ s;$;*:0/2:0;' $HOST1/filesync.timer

sed -i '/^OnCalendar=/ s;$;*:1/2:0;' $HOST2/filesync.timer




