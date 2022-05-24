#!/bin/bash

echo "Copying configuration files into /etc/postgresql/11/main/"
ls -l /postgresql_shared/conf
cp /postgresql_shared/conf/* /etc/postgresql/11/main/
echo "Restarting postgresql"
# /etc/init.d/postgresql restart

if [ ! -d "/data/var/lib/postgresql/11/main" ]
then
  sudo -u postgres /usr/lib/postgresql/11/bin/initdb -D /data/var/lib/postgresql/11/main
fi

sudo -u postgres /usr/lib/postgresql/11/bin/pg_ctl -D "/data/var/lib/postgresql/11/main" -l /data/logfile start

string=$POSTGRESQL_PASSWORD
len=${#string}
if [ "$len" -gt "0" ]; then
echo "Changing postgres password because POSTGRESQL_PASSWORD env variable is set to non-zero-length string"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
else
echo "NOT changing postgres password because len=#{$string}"
fi

tail -F /var/log/postgresql/postgresql-11-main.log