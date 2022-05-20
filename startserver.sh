echo "Copying configuration files into /etc/postgresql/11/main/"
ls -l /postgresql_shared/conf
cp /postgresql_shared/conf/* /etc/postgresql/11/main/
echo "Restarting postgresql"
/etc/init.d/postgresql restart
echo "Changing postgres password to $POSTGRESQL_PASSWORD"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
echo "Running migrations from /postgresql_shared/migrations"
ls -l /postgresql_shared/migrations
/migrate -source file://postgresql_shared/migrations -database postgres://postgres:postgres@localhost:5432/$POSTGRESQL_DBNAME?sslmode=disable up
tail -F /var/log/postgresql/postgresql-11-main.log
