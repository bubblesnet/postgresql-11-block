#!/bin/bash

echo "Copying configuration files into /etc/postgresql/11/main/"
ls -l /postgresql_shared/conf
cp /postgresql_shared/conf/* /etc/postgresql/11/main/
echo "Restarting postgresql"
/etc/init.d/postgresql restart

echo "Changing postgres password to $POSTGRESQL_PASSWORD"
string=$POSTGRESQL_PASSWORD
len=#{$string}
if [ $len -gt 0 ]; then
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
sudo psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
fi

tail -F /var/log/postgresql/postgresql-11-main.log
