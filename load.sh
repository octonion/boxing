#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'boxing';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb boxing"
   eval $cmd
fi

psql boxing -f schema/create_schema.sql

cp csv/boxers.csv /tmp/boxers.csv
rpl -q ',"",' ',,' /tmp/boxers.csv
psql boxing -f loaders/load_boxers.sql
rm /tmp/boxers.csv

cp csv/fights.csv /tmp/fights.csv
rpl -q ',"",' ',,' /tmp/fights.csv
rpl -q ',?,' ',,' /tmp/fights.csv
rpl -q ',debut,' ',0,' /tmp/fights.csv
psql boxing -f loaders/load_fights.sql
rm /tmp/fights.csv
