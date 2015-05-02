#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'boxing';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb boxing"
   eval $cmd
fi

psql boxing -f schema/create_schema.sql

cat csv/boxers_*.csv >> /tmp/boxers.csv
rpl -q ',"",' ',,' /tmp/boxers.csv
psql boxing -f loaders/load_boxers.sql
rm /tmp/boxers.csv

cat csv/fights_*.csv >> /tmp/fights.csv
rpl -q ',"",' ',,' /tmp/fights.csv
rpl -q ',?,' ',,' /tmp/fights.csv
rpl -q ',debut,' ',0,' /tmp/fights.csv
psql boxing -f loaders/load_fights.sql
rm /tmp/fights.csv
