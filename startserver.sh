#!/bin/bash

POSTGRESQL_SHARED_DIRECTORY=/postgresql_shared
POSTGRESQL_USER=postgres
POSTGRESQL_UNIX_USER=postgres

# ls -l ${POSTGRESQL_SHARED_DIRECTORY}/conf
# echo "Restarting postgresql"
# /etc/init.d/postgresql restart

if [ ! -d "${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main" ]
then
  echo "${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main not exists, initing directory"
  sudo mkdir -p /${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main
  sudo chown -R ${POSTGRESQL_UNIX_USER} ${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql
  sudo chgrp -R ${POSTGRESQL_UNIX_USER}  ${POSTGRESQL_SHARED_DIRECTORY}/var/log/postgresql
  sudo -u ${POSTGRESQL_UNIX_USER} /usr/lib/postgresql/11/bin/initdb -D ${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main
fi
sudo mkdir -p ${POSTGRESQL_SHARED_DIRECTORY}/var/log/postgresql
sudo chmod 777  ${POSTGRESQL_SHARED_DIRECTORY}/var/log/postgresql
sudo chown -R ${POSTGRESQL_UNIX_USER}  ${POSTGRESQL_SHARED_DIRECTORY}/var/log/postgresql
sudo chgrp -R ${POSTGRESQL_UNIX_USER}  ${POSTGRESQL_SHARED_DIRECTORY}/var/log/postgresql

echo Copying configuration files from ${POSTGRESQL_SHARED_DIRECTORY} into /etc/postgresql/11/main
# sudo cp ${POSTGRESQL_SHARED_DIRECTORY}/conf/* /${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main/
sudo cp ${POSTGRESQL_SHARED_DIRECTORY}/conf/* /etc/postgresql/11/main

echo Starting postgresql
# sudo -u postgres /usr/lib/postgresql/11/bin/pg_ctl -D ${POSTGRESQL_SHARED_DIRECTORY}/var/lib/postgresql/11/main -l ${POSTGRESQL_SHARED_DIRECTORY}/logs/logfile start
sudo /etc/init.d/postgresql restart

string=$POSTGRESQL_POSTGRES_PASSWORD
len=${#string}
if [ "$len" -gt "0" ]; then
echo "Changing postgres password because POSTGRESQL_PASSWORD env variable is set to non-zero-length string"
sudo -u ${POSTGRESQL_UNIX_USER} psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_POSTGRES_PASSWORD';"
else
echo "NOT changing postgres password because len=#{$string}"
fi
echo Tailing log file at ${POSTGRESQL_SHARED_DIRECTORY}/startup.log
tail -F ${POSTGRESQL_SHARED_DIRECTORY}/startup.log