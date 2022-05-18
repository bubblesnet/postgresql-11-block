# postgresql-11-block

Server configuration:

The block copies all the files from a shared/persistent directory named /postgresql_conf to the postgresql configuration directory.
If you want to override any of the postgresql defaults, put the entire configuration file in the shared directory.  To automate this,
have your own container copy the configuration file to the shared directory and have postgresql DEPEND on that
container in the dockercompose.yml file.  For example:

```
  mycontainer: # copies config files to /activemq_conf
    volumes:
      - 'resin-data:/postgresql_conf'

  postgresql:
    image: bh.cr/g_john_rodley1/postgresql-11-block
    volumes:
      - 'resin-data:/postgresql_conf'
    depends-on:
      - mycontainer  # don't start postgres until mycontainer has copied the right files into /postgresql_conf
```

The configuration files of most interest are postgresql.conf and pg_hba.conf.  The repo contains
a sample of each.

postgresql.conf:

* data_directory - if you leave the default data directory which points to containerized storage then your database will disappear on every deployment.

pg_hba.conf:

You will likely want to add lines allowing both your local network and other containers to access
the database.  See the sample.  Example:
```
host    all             all             192.168.21.237/32            md5
host    all             all             172.0.0.0/8            md5
```

Database initialization and migration:

If a file named "init_db.sh" exists in the shared directory /postgresql_conf it will be
executed on startup AND THEN DELETED so that it will only run once.

This block includes the migrate tool from https://github.com/golang-migrate.

The migration tool will be run in the directory /postgresql_config/migrations to get
the database up to the latest migration.

Environment variables:

* POSTGRESQL_DBNAME   set this to the name of the database we need to run migrations against
