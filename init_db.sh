#
# Copyright (c) John Rodley 2022. 
# SPDX-FileCopyrightText:  John Rodley 2022. 
# SPDX-License-Identifier: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this 
# software and associated documentation files (the "Software"), to deal in the 
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

if [ $NODE_ENV = "production" ]
then
  echo "Re-init database automatically in $NODE_ENV even though we shouldnt do that"
#  echo "Cant re-init database automatically in $NODE_ENV"
#  exit 0;
elif [ $NODE_ENV = "development" ]
then
  if [ $INIT_DB = "TRUE" ]
  then
    echo "Skipping INIT_DB in environment $NODE_ENV because INIT_DB env var is set to {$INIT_DB}"
  else
    echo "Skipping INIT_DB in environment $NODE_ENV because INIT_DB env var is set to {$INIT_DB} must be TRUE to init"
    exit 0;
  fi
elif [ $NODE_ENV = "CI" ]
then
  echo "initializing DB because environment is $NODE_ENV"
elif [ $NODE_ENV = "test" ]
then
  echo "initializing DB because environment is $NODE_ENV"
else
  echo "Skipping INIT_DB because NODE_ENV has invalid value $NODE_ENV"
  exit 0;
fi

# if the data directory doesn't exist, make it
mkdir -p /data/var/lib/postgresql/11/main
# cp -r /var/lib/postgresql/11/main/* /data/var/lib/postgresql/11/main

chmod 700 /data/var/lib/postgresql/11/main
chown -R postgres /data/var/lib/postgresql/*
chgrp -R postgres /data/var/lib/postgresql/*

# sudo -u postgres psql
# ALTER USER postgres PASSWORD 'postgres';
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# terminate all connections
echo "terminate all connections"
sudo -u postgres psql -h $ICEBREAKER_DB_HOST -p 5432 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'icebreaker' AND pid <> pg_backend_pid();" "user=postgres dbname=postgres password='postgres'"
# create database
sudo -u postgres psql -h $ICEBREAKER_DB_HOST -p 5432 -c "DROP DATABASE IF EXISTS $ICEBREAKER_DB_NAME" "user=postgres dbname=postgres password='postgres'"
sudo -u postgres psql -h $ICEBREAKER_DB_HOST -p 5432 -c "CREATE DATABASE $ICEBREAKER_DB_NAME" "user=postgres dbname=postgres password='postgres'"
sudo -u postgres psql -U postgres -d icebreaker -a -f create_tables.sql

echo 'Creating template database rows with init_db.sql'
#sudo -u postgres psql -a -h $ICEBREAKER_DB_HOST -p 5432 -a -q -f init_db.sql  "user=postgres dbname=$ICEBREAKER_DB_NAME password='postgres'"

cd /go/bin
./importer_rpi3
echo 'Done with init_db.sh'