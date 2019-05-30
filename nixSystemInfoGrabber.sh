#!/usr/bin/env bash
DIRECTORY="./systemInfo"
SYSINFOFILE="systeminfo.txt"
ROOTRUN="runningasroot.txt"
SOFTWAREDIRS=( "/usr/local/" "/usr/local/src/" "/usr/local/bin/" "/opt/" "/home/" "/var/" "/usr/src/" )
SOFTWAREFILE="software.txt"
DPKGFILE="dpkg.txt"
RPMFILE="rpm.txt"
SUIDFILE="suid.txt"
GUIDFILE="guid.txt"
WRFILE="worldwriteable.txt"
WEFILE="worldexecutable.txt"
WREFILE="worldwriteandexecutable.txt"
MOUNTFILE="mounts.txt"

if [ ! -d $DIRECTORY ]; then
  mkdir $DIRECTORY
fi

#Clean out previous run, if one existed. Add Date to top of file.
bash -c "date > $DIRECTORY/$SYSINFOFILE"
bash -c "date > $DIRECTORY/$ROOTRUN"
bash -c "date > $DIRECTORY/$SOFTWAREFILE"
bash -c "date > $DIRECTORY/$SUIDFILE"
bash -c "date > $DIRECTORY/$GUIDFILE"
bash -c "date > $DIRECTORY/$WRFILE"
bash -c "date > $DIRECTORY/$WEFILE"
bash -c "date > $DIRECTORY/$WREFILE"
bash -c "date > $DIRECTORY/$MOUNTFILE"

#Kernel and OS information
uname -a > $DIRECTORY/$SYSINFOFILE
cat /proc/version >> $DIRECTORY/$SYSINFOFILE
cat /etc/issue >> $DIRECTORY/$SYSINFOFILE

# What's running as root
ps aux | grep root >> $DIRECTORY/$ROOTRUN

for dir in ${SOFTWAREDIRS[*]}
do
    ls -alh $dir >> $DIRECTORY/$SOFTWAREFILE
done

# Determine OS platform taken from https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME

echo "System is "$DISTRO

# For systems with DPKG
if [[ $DISTRO =~ ^(Ubuntu|Debian)$ ]]; then
  bash -c "date > $DIRECTORY/$DPKGFILE"
  dpkg -l >> $DIRECTORY/$DPKGFILE
fi

# For systems with yum
if [[ $DISTRO =~ ^(CentOS|OpenSUSE|RedHatEnterpriseServer|Amazon*)$ ]]; then
  bash -c "date > $DIRECTORY/$RPMFILE"
  rpm -qa >> $DIRECTORY/$RPMFILE
fi

# Find SUID files
echo "Searching for SUID files..."
find / -perm -u=s -type f 2>/dev/null >> $DIRECTORY/$SUIDGFILE
echo "Complete"

# Find GUID files
echo "Searching for GUID files..."
find / -perm -g=s -type f 2>/dev/null >> $DIRECTORY/$GUIDFILE
echo "Complete"

#World writable files directories
echo "Searching for world writable files..."
find / -writable -type d 2>/dev/null >> $DIRECTORY/$WRFILE
find / -perm -222 -type d 2>/dev/null >> $DIRECTORY/$WRFILE
find / -perm -o w -type d 2>/dev/null >> $DIRECTORY/$WRFILE
echo "Complete"

# World executable folder
echo "Searching for world executable files..."
find / -perm -o x -type d 2>/dev/null >> $DIRECTORY/$WEFILE
echo "Complete"

# World writable and executable folders
echo "Searching for world write and executable files..."
find / \( -perm -o w -perm -o x \) -type d 2>/dev/null >> $DIRECTORY/$WREFILE
echo "Complete"

#Check for any unmounted file systems
mount -l >> $DIRECTORY/$MOUNTFILE
cat /etc/fstab >> $DIRECTORY/$MOUNTFILE

exit 0
