#!/bin/bash

INSTALL_DIR='/opt/cloudera/parcels/CDH/lib'
USER=$1

PASSWORD=$2

HUE_DB_PASS=$3

export HUE_CONF_DIR="/var/run/cloudera-scm-agent/process/`ls -alrt /var/run/cloudera-scm-agent/process | grep HUE_SERVER | tail -1 | awk '{print $9}'`"

# set env variables for hue webserver
for line in `strings /proc/$(lsof -i :8888|grep -m1 python|awk '{ print $2 }')/environ|egrep -v "^HOME=|^TERM=|^PWD="`;do export $line;done

export HUE_IGNORE_PASSWORD_SCRIPT_ERRORS=1

export HUE_DATABASE_PASSWORD=$HUE_DB_PASS


${INSTALL_DIR}/hue/build/env/bin/hue shell <<EOF

from django.contrib.auth.models import User

from django.contrib.auth.models import Group

user = User.objects.create(username='${USER}')

user.set_password('${PASSWORD}')

user.is_active = True

user.is_superuser = True

group_obj = Group.objects.get(name="default")

user.groups.add(group_obj)

user.save()

EOF
