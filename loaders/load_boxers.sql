begin;

drop table if exists boxrec.boxers;

create table boxrec.boxers (
	division	      text,
	rank		      integer,
	id		      integer,
	cat		      text,
	boxer_name	      text,
	boxer_url	      text,
	points		      integer,
	won		      integer,
	wko		      integer,
	lost		      integer,
	lko		      integer,
	drew		      integer,
	record		      text,
	last6		      text[],
	debut		      integer,
	age		      integer,
	stance		      text,
	country_class	      text,
	country		      text,
	residence	      text,
	primary key (id)
);

copy boxrec.boxers from '/tmp/boxers.csv' with delimiter as ',' csv quote as '"';

commit;
