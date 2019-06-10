#!/bin/bash

##########
#
# This import-users script works in conjunction with the export users script running on 
# another system.  Export users is configured to upload a home.tar.gz file to $EXPORT_DIR
# which is then checked to see if that is different than the last imported users list
# (new keys or passwords).  If different then users are imported, if not then it is 
# ignored.
#
#########

## variables
CONF_DIR=/home/conf
EXPORT_DIR=/home/ubuntu/home.tar.gz

#enable logging
exec &> >( logger -t import_users )


import_users() {
echo "Importing users"

cp /home/ubuntu/home.tar.gz /root/home.tar.gz 
cd / && tar xpzf /root/home.tar.gz

for i in `egrep -o ^[a-zA-Z0-9]+: $CONF_DIR/passwd`; do
    if grep -q "^$i" /etc/passwd; then
        echo "User $i already exists"
    else
        echo "Adding user $i"
	grep ^$i $CONF_DIR/passwd >> /etc/passwd
        grep ^$i $CONF_DIR/group >> /etc/group
        grep ^$i $CONF_DIR/shadow >> /etc/shadow
    fi
done

for i in `ls /home`; do  
    chown $i:$i /home/$i 
    chown $i:$i /home/$i/.ssh/* 
done

echo "done"
}

echo "Starting user import."
while true
do
  if mountpoint -q /home
  then
    echo "/home mounted, checking for newer users file"

    OLD=$(md5sum /root/home.tar.gz | gawk '{print $1 }')
    NEW=$(md5sum $EXPORT_DIR | gawk '{print $1 }')

    if [ $OLD != $NEW ] 
    then
        echo "user file uppdated, running import."
	import_users
	break
    else
	echo "Nothing to do"
	break
    fi
  fi
  sleep 10
done

