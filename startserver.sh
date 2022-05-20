cp /postgresql_shared/conf/* /etc/postgresql/11/main/
/etc/init.d/postgresql restart
if [ -f "/postgresql_shared/bin/init_db.sh" ]
then
  echo "/postgresql_shared/bin/init_db.sh file is found, running init"
  chmod +x /postgresql_shared/bin/init_db.sh
  /postgresql_shared/bin/init_db.sh
  rm /postgresql_shared/bin/init_db.sh
else
   echo "/postgresql_shared/bin/init_db.sh file is not found, skipping init"
fi

/migrate -source file://postgresql_shared/migrations -database postgres://postgres:postgres@localhost:5432/$POSTGRESQL_DBNAME?sslmode=disable up
tail -F /var/log/postgresql/postgresql-11-main.log
