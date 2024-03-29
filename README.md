# postgresql-11-block

Current status of this block.  I use it in one fleet and works pretty well for my purposes.

You have to run the database setup and initialization and migrations from one of the other 
containers, which means installing psql in the other container.

Server configuration:

The block copies all the files from a shared/persistent directory named /postgresql_shared/conf to the postgresql configuration directory.
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

All application-specific database work are the responsibility of the client container. 

Environment variables user in this container:

* POSTGRESQL_UNIX_USER   unix username of the user who owns/runs the postgresql processes/files, typically "postgres".  Only tested where POSTGRESQL_UNIX_USER and POSTGRESQL_POSTGRES_USER are both set to "postgres"
* POSTGRESQL_POSTGRES_USER   POSTGRES username of the user who owns and has ALL rights within the postgresql installation, typically "postgres".
* POSTGRESQL_POSTGRES_PASSWORD   postgres password (not unix password) for the postgres user IN POSTGRES. The block resets the postgres user password to this value on startup.
* POSTGRESQL_SYSTEM_DBNAME   name of the system database, typically postgres
* POSTGRESQL_SHARED_DIRECTORY   full path to root shared directory (among containers) under which postgresql container will create additional directories to run postgres, typically /postgresql_shared



