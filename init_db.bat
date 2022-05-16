echo off

REM
REM Copyright (c) John Rodley 2022. 
REM SPDX-FileCopyrightText:  John Rodley 2022. 
REM SPDX-License-Identifier: MIT
REM
REM Permission is hereby granted, free of charge, to any person obtaining a copy of this 
REM software and associated documentation files (the "Software"), to deal in the 
REM Software without restriction, including without limitation the rights to use, copy,
REM modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
REM and to permit persons to whom the Software is furnished to do so, subject to the 
REM following conditions:
REM
REM The above copyright notice and this permission notice shall be included in all 
REM copies or substantial portions of the Software.
REM
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
REM INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
REM PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
REM HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
REM CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
REM OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
REM
"D:\Program Files\PostgreSQL\12\bin\psql" -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"

REM terminate all connections
echo "terminate all connections"
"D:\Program Files\PostgreSQL\12\bin\psql" -U postgres -h localhost -p 5432 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '%1' AND pid <> pg_backend_pid();" "user=postgres dbname=postgres password='postgres'"
"D:\Program Files\PostgreSQL\12\bin\psql" -U postgres -h localhost -p 5432 -c "DROP DATABASE IF EXISTS %1" "user=postgres dbname=postgres password='postgres'"
"D:\Program Files\PostgreSQL\12\bin\psql" -U postgres -h localhost -p 5432 -c "CREATE DATABASE %1" "user=postgres dbname=postgres password='postgres'"
"D:\Program Files\PostgreSQL\12\bin\psql" -U postgres -d %1 -a -f create_tables.sql
migrate -source file://migrations -database postgres://postgres:postgres@localhost:5432/%1?sslmode=disable up

echo 'Creating template database rows with init_db.sql'
REM sudo -u postgres psql -a -U postgres -h $ICEBREAKER_DB_HOST -p 5432 -a -q -f init_db.sql  "user=postgres dbname=$ICEBREAKER_DB_NAME password='postgres'"

echo 'Done with init_db.sh'