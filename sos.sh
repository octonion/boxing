#!/bin/bash

psql boxing -c "drop table if exists boxrec._basic_factors;"
psql boxing -c "drop table if exists boxrec._parameter_levels;"

R --vanilla -f sos/lmer.R

psql boxing -c "vacuum full verbose analyze boxrec._basic_factors;"
psql boxing -c "vacuum full verbose analyze boxrec._parameter_levels;"

#psql boxing -f sos/normalize_factors.sql

#psql boxing -c "vacuum full verbose analyze boxrec._factors;"

psql boxing -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv
