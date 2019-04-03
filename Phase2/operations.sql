--this is for customer add
drop procedure if exists insertpass(pass_id integer, first_name varchar, last_name varchar, street1 varchar, town1 varchar, zip1 varchar) cascade;

CREATE PROCEDURE InsertPass(pass_id int,first_name varchar(20), last_name varchar(20), street1 varchar(20), town1 varchar(20), zip1 varchar(10))
LANGUAGE SQL
AS $BODY$
    select MAX(passanger_id)+1 into pass_id from passangers;
    INSERT INTO passangers(passanger_id, f_name, l_name, street, town, zip)
    VALUES(pass_id, first_name, last_name, street1, town1, zip1);
$BODY$;
--this is for customer update
drop function if exists edit_pass() cascade;
drop trigger if exists check_pass on passangers;

create or replace function edit_pass() returns trigger as
  $$
  declare
    temp_id int;
  begin
		select passanger_id into temp_id from passangers where passanger_id = new.passanger_id;
		if temp_id IS NULL then
   		RAISE EXCEPTION 'THAT ID DOES NOT EXIST!';
		end if;
		return new;
	end;
  $$language plpgsql;

create trigger check_pass
  before update
  on passangers
  for each row
  execute procedure edit_pass();
--single route trip search
create or replace function single_search() returns setof record as
  $$
  BEGIN
  SELECT * into days_table from train_schedule where day_of_week = new.days_of_week;
  select * into days_table1 from routes_and_station_status where route_id = days_table.route_id;
  delete from days_table1 where station_status = false;
  select * into arri_table from days_table1 where station_id = ARRIVAL_STATION;
  select * into dest_table from days_table1 where station_id = DEST_STATION;
  select route_id from (arri_table join dest_table where arri_table.route_id = dest_table.route_id);
  return new;
  end;
  $$language plpgsql;

--combination search
create or replace function combine_search() returns setof record as
  $$
  BEGIN
  SELECT * into days_table from train_schedule where day_of_week = new.days_of_week;
  select * into days_table1 from routes_and_station_status where route_id = days_table.route_id;
  delete from days_table1 where station_status = false;
  select * into arri_table from days_table1 where station_id = ARRIVAL_STATION;
  select * into dest_table from days_table1 where station_id = DEST_STATION;
  select * into combine_table from (arri_table join dest_table where arri_table.route_id <> dest_table.route_id);
  delete from combine_table where station_id = ARRIVAL or station_id = DESTINATION;
  --select where arritable.stationid = desttable.stationid
  --return arritable.rid, desttable.rid, stationid
  return new;
  end;
  $$language plpgsql;

--This is to show trains with available seats
create or replace function available_seats() returns setof record as
  $$
  BEGIN
  execute 'create or replace temp view open_train as ' ||
          'select train_id into open_train from seats where open_status = true;';
  RETURN QUERY
  SELECT * FROM open_trians;
  --return new;
  end;
  $$language plpgsql;