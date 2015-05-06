begin;

create temporary table best20 (
       boxer_id	       	      integer,
       owp		      float,
       outcome		      text,
       outcome_type	      text,
       rk		      integer
);

insert into best20
(boxer_id, owp, outcome, outcome_type, rk)
(
select
b.id,
(f.opponent_won+0.5*f.opponent_drew::float)/(f.opponent_won+f.opponent_lost+f.opponent_drew::float) as owp,
outcome,
outcome_type,
rank() over
  (partition by b.id
   order by
   (f.opponent_won+0.5*f.opponent_drew::float)/(f.opponent_won+f.opponent_lost+f.opponent_drew::float)
  desc) as rk
from boxrec.boxers b
join boxrec.fights f
  on f.boxer_id=b.id
where
b.rank <= 50
and (f.opponent_won+f.opponent_lost+f.opponent_drew) >= 20
);

copy
(
select
b.boxer_name,
b.rank,
b.debut,
sum(case when outcome='W' then 1 else 0 end) as wins,
sum(case when outcome='L' then 1 else 0 end) as losses,
sum(case when outcome='D' then 1 else 0 end) as draws,
sum(case when outcome='W' and outcome_type in ('KO','TKO') then 1
    else 0 end) as wko,
sum(case when outcome='L' and outcome_type in ('KO','TKO') then 1
    else 0 end) as lko,
avg(owp)::numeric(4,3) as owp20
from boxrec.boxers b
join best20 b20
on b20.boxer_id=b.id
where b.division='"Welterweight"'
--where TRUE
and b20.rk <= 20
group by b.boxer_name,b.rank,b.debut
order by owp20 desc
) to '/tmp/welterweights_active.csv' csv header;

copy
(
select
b.boxer_name,
b.rank,
b.debut,
sum(case when outcome='W' then 1 else 0 end) as wins,
sum(case when outcome='L' then 1 else 0 end) as losses,
sum(case when outcome='D' then 1 else 0 end) as draws,
sum(case when outcome='W' and outcome_type in ('KO','TKO') then 1
    else 0 end) as wko,
sum(case when outcome='L' and outcome_type in ('KO','TKO') then 1
    else 0 end) as lko,
avg(owp)::numeric(4,3) as owp20
from boxrec.boxers b
join best20 b20
on b20.boxer_id=b.id
where b.division='"Heavyweight"'
--where TRUE
and b20.rk <= 20
group by b.boxer_name,b.rank,b.debut
order by owp20 desc
) to '/tmp/heavyweights_active.csv' csv header;

commit;
