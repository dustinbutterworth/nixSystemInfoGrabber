#!/bin/sh
DIRECTORY="./systemInfo"

if [ ! -d $DIRECTORY ]; then
  mkdir $DIRECTORY
fi
uname -a > ./$DIRECTORY/systeminfo.txt
cat /proc/version >> ./$DIRECTORY/systeminfo.txt
cat /etc/issue >> ./$DIRECTORY/systeminfo.txt
