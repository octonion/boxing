begin;

select
coalesce(b.boxer_name) as name,
exp(bf.estimate)::numeric(6,2) as str
from boxrec.boxers b
join boxrec._basic_factors bf
  on (bf.factor, bf.level) = ('boxer', b.id::text)
order by str desc
limit 50;

copy (
select
coalesce(b.boxer_name) as name,
exp(bf.estimate)::numeric(6,2) as str
from boxrec.boxers b
join boxrec._basic_factors bf
  on (bf.factor, bf.level) = ('boxer', b.id::text)
order by str desc
limit 50
) to '/tmp/current_ranking.csv' csv header;

commit;
