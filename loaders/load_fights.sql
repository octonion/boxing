begin;

drop table if exists boxrec.fights;

create table boxrec.fights (
	boxer_division	      text,
	boxer_id	      integer,
	boxer_name	      text,
	fight_date	      date,
	date_url	      text,
	card_url	      text,
	opponent_id	      integer,
	opponent_cat	      text,
	opponent_name	      text,
	opponent_url	      text,
	opponent_won	      integer,
	opponent_lost	      integer,
	opponent_drew	      integer,
	opponent_record	      text,
	opponent_last6	      text[],
	location	      text,
	outcome		      text,
	outcome_type	      text,
	rounds		      integer,
	scheduled	      text,
	fight_division	      text,
	boxer_pre	      integer,
	boxer_post	      integer,
	opponent_pre	      integer,
	opponent_post	      integer,
	fight_url	      text
);

copy boxrec.fights from '/tmp/fights.csv' with delimiter as ',' csv quote as '"';

commit;
