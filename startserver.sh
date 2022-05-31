#!/bin/bash

POSTGRESQL_SHARED_DIRECTORY=/postgresql_shared
POSTGRESQL_USER=postgres
POSTGRESQL_UNIX_USER=postgres

# ls -l ${POSTGRESQL_SHARED_DIRECTORY}/conf
# echo "Restarting postgresql"
# /etc/init.d/postgresql restart

if [ ! -d "${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main" ]
then
  sudo -u ${POSTGRESQL_USER} /usr/lib/postgresql/11/bin/initdb -D ${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main
fi
sudo mkdir -p ${POSTGRESQL_SHARED_DIRECTORY}/logs
sudo chmod 777 ${POSTGRESQL_SHARED_DIRECTORY}/logs
sudo chown -R ${POSTGRESQL_UNIX_USER} ${POSTGRESQL_SHARED_DIRECTORY}/logs
sudo chgrp -R ${POSTGRESQL_UNIX_USER} ${POSTGRESQL_SHARED_DIRECTORY}/logs

echo Copying configuration files from ${POSTGRESQL_SHARED_DIRECTORY} into /${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main/
sudo cp ${POSTGRESQL_SHARED_DIRECTORY}/conf/* /${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main/

echo Starting postgresql
sudo -u postgres /usr/lib/postgresql/11/bin/pg_ctl -D ${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main -l ${POSTGRESQL_SHARED_DIRECTORY}/logs/logfile start

string=$POSTGRESQL_PASSWORD
len=${#string}
if [ "$len" -gt "0" ]; then
echo "Changing postgres password because POSTGRESQL_PASSWORD env variable is set to non-zero-length string"
sudo -u ${POSTGRESQL_UNIX_USER} psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
else
echo "NOT changing postgres password because len=#{$string}"
fi
echo Tailing log file at ${POSTGRESQL_SHARED_DIRECTORY}/logs/logfile
tail -F ${POSTGRESQL_SHARED_DIRECTORY}/logs/logfile