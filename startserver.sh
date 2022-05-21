#!/bin/bash

echo "Copying configuration files into /etc/postgresql/11/main/"
ls -l /postgresql_shared/conf
cp /postgresql_shared/conf/* /etc/postgresql/11/main/
echo "Restarting postgresql"
/etc/init.d/postgresql restart

string=$POSTGRESQL_PASSWORD
len=#{$string}
if [ "$len" -gt "0" ]; then
echo "Changing postgres password because POSTGRESQL_PASSWORD env variable is set to non-zero-length string"
sudo -U postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
else
echo "NOT changing postgres password because len=#{$string}"
fi

tail -F /var/log/postgresql/postgresql-11-main.log
