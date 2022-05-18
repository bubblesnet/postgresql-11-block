cp /postgresql_conf/* /etc/postgresql/11/main/
/etc/init.d/postgresql restart
if [ -f "/postgresql_conf/init_db.sh" ]
then
  echo "File is found"
  chmod +x /postgresql_conf/init_db.sh
  /postgresql_conf/init_db.sh
  rm /init_db.sh
else
   echo "File is not found"
fi

/migrate -source file://postgresql_conf/migrations -database postgres://postgres:postgres@localhost:5432/$POSTGRESQL_DBNAME?sslmode=disable up
tail -F /var/log/postgresql/postgresql-11-main.log
