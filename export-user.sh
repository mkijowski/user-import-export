#!/bin/bash

exec &> >( logger -t user_export )

#Run network tested to make sure we have a working network
# /root/net-test.sh

## Local conf directory and local priveleged user to store password hashes
CONF_DIR=/home/conf
PRIVELEGED_USER=mkijowski

## remote credentials (data will be uploaded here)
AWS_IP=
AWS_USER=ubuntu
AWS_KEY=/path/to/.pem
AWS_GOV_IP=
AWS_GOV_KEY=/path/to/.pem

## overwrite and re-generate shadow file incase user has changed password
echo "" > $CONF_DIR/shadow
for i in `egrep -o ^[a-zA-Z]+: $CONF_DIR/passwd`; do
        grep ^$i /etc/shadow >> $CONF_DIR/shadow
done


## backup user ssh keys and the passwd, shadow, and group files
## NOTE: these passwd shadow and group files are created by create-users.sh and 
## conain all non-system users (UID > 1000)
tar -cpzf $CONF_DIR/home.tar.gz \
        /home/*/.ssh/* \
        $CONF_DIR/passwd \
        $CONF_DIR/group \
        $CONF_DIR/shadow

chown $PRIVELEGED_USER:$PRIVELEGED_USER $CONF_DIR/*
chmod 660 $CONF_DIR/*

## upload data to remote system
scp -i $AWS_KEY $CONF_DIR/home.tar.gz $AWS_USER@$AWS_IP:/home/ubuntu/home.tar.gz
scp -i $AWS_GOV_KEY $CONF_DIR/home.tar.gz $AWS_USER@$AWS_GOV_IP:/home/ubuntu/home.tar.gz


