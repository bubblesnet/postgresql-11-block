cp /postgresql_shared/conf/* /etc/postgresql/11/main/
/etc/init.d/postgresql restart
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRESQL_PASSWORD';"
/migrate -source file://postgresql_shared/migrations -database postgres://postgres:postgres@localhost:5432/$POSTGRESQL_DBNAME?sslmode=disable up
tail -F /var/log/postgresql/postgresql-11-main.log
