begin;

select
coalesce(b.boxer_name) as name,
replace(replace(b.division,'"',''),'+',' ') as division,
exp(bf.estimate)::numeric(6,2) as str
from boxrec.boxers b
join boxrec._basic_factors bf
  on (bf.factor, bf.level) = ('boxer', b.id::text)
order by str desc
limit 250;

copy (
select
coalesce(b.boxer_name) as name,
replace(replace(b.division,'"',''),'+',' ') as division,
exp(bf.estimate)::numeric(6,2) as str
from boxrec.boxers b
join boxrec._basic_factors bf
  on (bf.factor, bf.level) = ('boxer', b.id::text)
order by str desc
limit 250
) to '/tmp/current_ranking.csv' csv header;

commit;
