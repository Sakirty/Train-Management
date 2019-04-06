--1.1this is for customer add
drop procedure if exists insertpass(pass_id integer, first_name varchar, last_name varchar, street1 varchar, town1 varchar, zip1 varchar) cascade;

CREATE PROCEDURE InsertPass(pass_id int,first_name varchar(20), last_name varchar(20), street1 varchar(20), town1 varchar(20), zip1 varchar(10))
AS
$$
  begin
    select MAX(passanger_id)+1 into pass_id from passangers;
    INSERT INTO passangers(passanger_id, f_name, l_name, street, town, zip)
    VALUES(pass_id, first_name, last_name, street1, town1, zip1);
  end;
$$language plpgsql;

--1.1this is for customer update
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

--1.2.1single route trip search
create or replace function single_search(want_days varchar(10), a_station varchar(5), d_station varchar(5)) returns table(route_id varchar(5)) as
  $$
  BEGIN
  create temp table selected_route as (select * from routes_and_station_status where route_id = (select train_schedule.route_id from train_schedule where day_of_week = want_days));
  delete from selected_route where station_status = false;
  create temp table arri_table as (select route_id from selected_route where station_id = a_station);
  create temp table dest_table as (select route_id from selected_route where station_id = d_station);
  return query
    select route_id from (arri_table inner join dest_table on arri_table.route_id = dest_table.route_id) group by route_id;
  end;
  $$language plpgsql;

--1.2.2combination search
create or replace function combine_search(want_days varchar(10), a_station varchar(5), d_station varchar(5)) returns table(route_1 varchar(5), route_2 varchar(5), change_station varchar(10)) as
  $$
  BEGIN
  create temp table select_day as (select * from routes_and_station_status where route_id = (select train_schedule.route_id from train_schedule where day_of_week = want_days));
  delete from select_day where station_status = false;
  create temp table arri_table as (select route_id from select_day where station_id = a_station);
  create temp table dest_table as (select route_id from select_day where station_id = d_station);
  create temp table arr_des_table as (select arri_table.route_id as ar_id, dest_table.route_id as de_id, arri_table.station_id as a_sta, dest_table.station_id as d_sta from (arri_table inner join dest_table on arri_table.route_id <> dest_table.route_id));
  delete from arr_des_table where (a_sta = a_station) or (d_sta = d_station) or (a_sta = d_station) or (d_sta = a_station);
  return query
    select ar_id, de_id, a_sta from arr_des_table where a_sta = d_sta;
  end;
  $$language plpgsql;

--This is to show trains with available seats
create or replace function available_seats() returns table(train_id varchar(5)) as
  $$
  BEGIN
  return query
    select train_id from seats where open_status = true;
  end;
  $$language plpgsql;

--get seq of stations for searches
--helper for 1.2.4.3~1.2.4.8
--1 ->3
--curr last
--1 2
--2 3
create or replace function get_seq(routeid varchar(10),arri_id varchar(10), dest_id varchar(10)) returns table(curst varchar(10),targst varchar(10))as
  $$
  declare
    max1 varchar(10);
    max2 varchar(10);
  begin
    create temp table temp_table as (select station_id, station_num from routes_and_station_status where route_id = routeid);
    create temp table temp_table2 as  (select station_id, station_num from temp_table where (station_num between (select station_num from temp_table where station_id = arri_id) and (select station_num from temp_table where station_id = dest_id)));
    create temp table t1 as (select * from temp_table2);
    create temp table t2 as (select * from temp_table2);
    delete from t1 where station_id = arri_id;
    delete from t2 where station_id = dest_id;
    select max(station_num) into max1 from t1;
    select max(station_num) into max2 from t2;
    if max1 > max2 then
      return query
        select t1.station_id, t2.station_id from (t1 join t2 on t1.station_num = t2.station_num + 1);
    else
      return query
        select t1.station_id, t2.station_id from (t1 join t2 on t1.station_num = t2.station_num - 1);
    end if;
  end;
  $$language plpgsql;

--1.2.4.1this is to create the table with stops ascend
--search mode 1 for single 0 for combined
create or replace function few_stops() returns table(route_id varchar(5), stop_num int) as
  $$
  BEGIN
  return query
    select route_id, stop_num from routes group by route_id order by stop_num asc;
  end;
  $$language plpgsql;

--1.2.4.2this is to order the table run through most stations dec
create or replace function pass_most() returns table(route_id varchar(5), total_num int) as
  $$
  begin
    return query
      select route_id, total_num from routes order by total_num desc;
  end;
  $$language plpgsql;

--this is to calculate the lowest price
create or replace function lowest_price() returns table(route_id varchar(5)) as
  $$
  begin

  end;
  $$language plpgsql;

--1.2.5This is to add reservation
create or replace procedure add_resv(new_passanger_id int, route varchar(10), new_day varchar(10)) as
  $$
    insert into reservations(passanger_id, route_id, day_of_week) values (new_passanger_id, route, new_day);
  end;
  $$language plpgsql;

--this is for 1.3.1
create or replace function all_pass(want_station varchar(5), want_day varchar(10), want_time varchar(10)) returns table(want_train varchar(5)) as
  $$
  begin
  create temp table temp_schedule as (select * from train_schedule where day_of_week = want_day and time_route = want_time);
  create temp table temp_stations as (select route_id from routes_and_station_status where station_id = want_station and station_status = false);
  return query
    select train_id from temp_schedule where route_id = temp_stations.route_id group by train_id;
  end;
  $$language plpgsql;

--this is for 1.3.2
create or replace function pass_multi() returns table(multi_route varchar(5)) as
  $$
  begin
    create temp table t1 as (select distinct route_id, rail_id from routes_and_station_status left join rail_stations
  on routes_and_station_status.station_id = rail_stations.station_id);
    create temp table t2 as (select route_id, count(route_id) from t1 group by route_id);
    delete from t2 where count = 1;
    return query
      select route_id from t2;
  end;
  $$language plpgsql;

--this is for 1.3.3


--this is for 1.3.4
create or replace function all_trian_pass_through() returns table(null_station varchar(10)) as
  $$
  begin
    create temp table t1 as (select route_id from train_schedule group by route_id);
    create temp table t2 as (select * from routes_and_station_status);
    delete from t2 where route_id not in (select route_id from t1);
    delete from t2 where station_status = true;
    create temp table t3 as (select station_id, count(station_id) from t2 group by station_id);
    delete from t3 where count < (select count(route_id) from t2);
    return query
      select station_id from t3;
  end;
  $$language plpgsql;

--this is for 1.3.5
create or replace function never_pass(want_staton varchar(5)) returns table(np_train varchar(5)) as
  $$
  begin
  --select route_id from routes_and_station_status where station_status = false and station_id = want_staton;
  return query
    select train_id from train_schedule where route_id = (select route_id from routes_and_station_status where station_status = false and station_id = want_staton) group by train_id;

  end;
  $$language plpgsql;

--this is for 1.3.6
create or replace function pass_rate(percentage float) returns table(p_route varchar(10)) as
  $$
  begin
  return query
    select route_id from routes where stop_rate >= percentage group by route_id;
  end;
  $$language plpgsql;

--this is 1.3.7
create or replace function display_route(want_route varchar(5)) returns table(day_get varchar(10), time_get varchar(10), train_get varchar(10)) as
  $$
  begin
    return query
      select day_of_week, time_route, train_id from train_schedule where route_id = want_route;
  end;
  $$language plpgsql;
--this is 1.3.8

--some triggers
create or replace function incr_seat() returns trigger as
  $$
  declare
    taken integer;
		limt integer;
  begin
		select seats_taken into taken from seats where train_id = new.train_id;
		select seats_total into limt from seats where train_id = new.train_id;
		if taken < limt then
			update seats set seats_taken = taken + 1 where train_id = new.train_id;
			if seats_taken = limt - 1 then
				update seats set open_status = False where train_id = new.train_id;
			end if;
		end if;
		return new;
  end;
  $$ language plpgsql;

create trigger incr_trigger
  after insert
  on seats
  for each row
  execute procedure incr_seat();

create or replace function desc_seat() returns trigger as
  $$
  declare
    taken integer;
		limt integer;
  begin
		select seats_taken into taken from seats where train_id = new.train_id;
		select seats_total into limt from seats where train_id = new.train_id;
		if taken < limt then
			update seats set seats_taken = taken - 1 where train_id = new.train_id;
			if seats_taken < limt then
				update seats set open_status = true where train_id = new.train_id;
			end if;
		end if;
		return new;
  end;
  $$ language plpgsql;

create trigger desc_trigger
  after delete or update
  on seats
  for each row
  execute procedure desc_seat();

create or replace function no_add() returns trigger as
  $$
  declare
    open_1 boolean;
  begin
		select open_status into open_1 from seats where train_id = new.train_id;
		if open_1 = FALSE then
   		RAISE EXCEPTION 'CANNOT INSERT, NOT OPEN';
		end if;
		return new;
	end;
  $$language plpgsql;

create trigger rej_add
  before insert
  on seats
  for each row
  execute procedure no_add();


--2.3 delete the database
create or replace procedure delete_databse() as
  $$
  begin
    drop database if exists postgres;
  end;
  $$language plpgsql;

