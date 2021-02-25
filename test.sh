#!/bin/bash

echo "Running test script"

if [ -z "$1" ]; then
  echo "This script requires 1 commandline argument. Exiting."
  exit 1
fi

WORKING_DIR="$1"

#Create testing folder
if [ ! -d "$WORKING_DIR"/test1 ]
then
    mkdir "$WORKING_DIR"/test1
fi

if [ ! -d "$WORKING_DIR"/test2 ]
then
    mkdir "$WORKING_DIR"/test2
fi

#Make unison directory if not present.
#if [ ! -d "~/.unison" ] 
#then
#    mkdir ~/.unison
#    chown jenkins:jenkins ~/.unison
#fi

cp default.prf testing.prf

#Add root variable values in testing.prf
sed -i "0,/#root=/{s;#root=;root=$WORKING_DIR/test1;}" testing.prf
sed -i "0,/#root=/{s;#root=;root=$WORKING_DIR/test2;}" testing.prf

#Move testing to ~/.unison folder
mv testing.prf ~/.unison/

echo "12345" > "$WORKING_DIR"/test1/init
sleep 1
echo "123456789" > "$WORKING_DIR"/test2/init2

unison testing

echo "Unison Init"
if [ ! $(cksum "$WORKING_DIR"/test1/init | cut -d" " -f1) = $(cksum "$WORKING_DIR"/test2/init | cut -d" " -f1) ]
then 
	echo "File not same. Exiting."
	rm ~/.unison/testing.prf
	exit 1
fi
if [ ! $(cksum "$WORKING_DIR"/test1/init2 | cut -d" " -f1) = $(cksum "$WORKING_DIR"/test2/init2 | cut -d" " -f1) ]
then 
	echo "File not same. Exiting."
	rm ~/.unison/testing.prf
	exit 1
fi

echo "Unison Init passed."

rm "$WORKING_DIR"/test1/init

unison testing

echo "Unison Delete"
if [ -f "$WORKING_DIR"/test2/init ]
then
    echo "File still exists. Exiting."
    rm ~/.unison/testing.prf
	exit 1
fi

echo "Unison Delete passed."

echo "12345" > "$WORKING_DIR"/test2/init

unison testing

echo "Unison Add"
if [ ! -f "$WORKING_DIR"/test1/init ]
then
    echo "File doesn't exist. Exiting."
    rm ~/.unison/testing.prf
	exit 1
fi
if [ ! $(cksum "$WORKING_DIR"/test1/init | cut -d" " -f1) = $(cksum "$WORKING_DIR"/test2/init | cut -d" " -f1) ]
then 
	echo "File not same. Exiting."
	rm ~/.unison/testing.prf
	exit 1
fi

echo "Unison Add passed."

echo "All tests passed."
