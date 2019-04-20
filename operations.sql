--加DROP TEMP TABLE
--1.1this is for customer add
drop function if exists InsertPass(first_name varchar, last_name varchar, street1 varchar, town1 varchar, zip1 varchar) cascade;

CREATE or replace function InsertPass(first_name varchar(20), last_name varchar(20), street1 varchar(20), town1 varchar(20), zip1 varchar(10)) returns void
AS
$$
  declare
  pass_id int;
  begin
    select MAX(passanger_id)+1 into pass_id from passangers;
    INSERT INTO passangers(passanger_id, f_name, l_name, street, town, zip)
    VALUES(pass_id, first_name, last_name, street1, town1, zip1);
  end;
$$language plpgsql;

create or replace function get_passanger(id int) returns table(pid int, fname varchar(10),lname varchar(10), str varchar(10), town varchar(10), zip varchar(10))
as
  $$
  begin
  return query
    select * from passangers where passanger_id = id;
  end;
  $$language plpgsql;

--select * from get_passanger(100706);

--1.1 this is for customer update
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
  drop table if exists dt, rid_day, arri, dest;
  create temp table dt as
    (select train_schedule.route_id, train_schedule.time_route from train_schedule where day_of_week = want_days);
  create temp table rid_day as
    (select r.route_id, r.station_id, r.station_num, r.station_status,dt.time_route from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
  delete from rid_day where station_status = false;
  create temp table arri as
    (select rid_day.route_id, rid_day.time_route, rid_day.station_num as sorder1 from rid_day where station_id = a_station);
  create temp table dest as
    (select rid_day.route_id, rid_day.time_route, rid_day.station_num as sorder2 from rid_day where station_id = d_station);

  return query
    select arri.route_id from (arri inner join dest on (arri.route_id = dest.route_id and arri.time_route = dest.time_route) and arri.sorder1 < dest.sorder2);
  end;
  $$language plpgsql;

--select * from single_search('Monday','1','8');

--1.2.2combination search
create or replace function combine_search(want_days varchar(10), a_station varchar(5), d_station varchar(5)) returns table(route_1 varchar(5), route_2 varchar(5), trans_station varchar(5)) as
  $$
  BEGIN
  drop table if exists dt, rid_day,arri, arri_order, arri_routes, dest, dest_order, dest_routes, tablea, tableb, tablec, comb_table;
  create temp table dt as
    (select train_schedule.route_id, train_schedule.time_route from train_schedule where day_of_week = want_days);
  create temp table rid_day as
    (select r.route_id, r.station_id, r.station_num, r.station_status,dt.time_route from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
  delete from rid_day where station_status = false;
  create temp table arri_routes as
     (select rid_day.route_id, rid_day.time_route from rid_day where station_id = a_station);
  create temp table arri as
      (select rid_day.route_id, rid_day.station_id, rid_day.station_num as sorder1 from (rid_day inner join arri_routes on (rid_day.route_id = arri_routes.route_id and rid_day.time_route = arri_routes.time_route)));
  create temp table arri_order as
      (select arri.route_id, arri.sorder1 from arri where arri.station_id = a_station);
  create temp table dest_routes as
  (select rid_day.route_id,rid_day.time_route from rid_day where station_id = d_station);
  create temp table dest as
    (select rid_day.route_id, rid_day.station_id, rid_day.station_num as sorder2 from (rid_day inner join dest_routes on (rid_day.route_id = dest_routes.route_id and rid_day.time_route = dest_routes.time_route)));
  create temp table dest_order as
    (select dest.route_id, dest.sorder2 from dest where dest.station_id = d_station);
  create temp table comb_table as
    (select arri.route_id as arid, dest.route_id as drid, arri.station_id as asid, dest.route_id as dsid, arri.sorder1 as aorder, dest.sorder2 as dorder from arri cross join dest);
  delete from comb_table where arid = drid;
  delete from comb_table where (asid = a_station or dsid = d_station or asid = d_station or dsid = a_station);
  create temp table tablea as
    (select arid, drid, asid,dsid, dorder from (comb_table inner join arri_order on (comb_table.aorder > arri_order.sorder1 and comb_table.arid = arri_order.route_id)));
  create temp table tableb as
    (select arid, drid,asid,dsid from (tablea inner join dest_order on (tablea.dorder < dest_order.sorder2 and tablea.drid = dest_order.route_id)));
  create temp table tablec as
    (select distinct arid, drid, asid, dsid from tableb);
  return query
    select arid, drid, asid from tablec where asid = dsid;

  end;
  $$language plpgsql;

--select * from combine_search('Monday','1','2');

--This is to show trains with available seats
create or replace function available_seats(route varchar(10)) returns table(train_id varchar(5)) as
  $$
  BEGIN
    drop table if exists t1,t2;
    create temp table t1 as
      (select distinct train_id from train_schedule where route_id = route);
    create temp table t2 as
      (select * from seats where train_id in (select train_id from t1));
  return query
    select t2.train_id from t2 where open_status = true;
  end;
  $$language plpgsql;

--select * from available_seats();

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
    drop table if exists temp_table, temp_table2, t1, t2;
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
        select t2.station_id, t1.station_id from (t1 join t2 on t1.station_num = t2.station_num + 1);
    else
      return query
        select t2.station_id, t2.station_id from (t1 join t2 on t1.station_num = t2.station_num - 1);
    end if;
  end;
  $$language plpgsql;

--select * from get_seq('22','1','8');

--1.2.4.7 and 1.2.4.8
create or replace function single_trip_dest_min(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(routeid varchar(10), dist int) as
  $$
  declare
    di integer;
  begin
    drop table if exists dt, rid_days, arri, dest, r1, r2;
    create temp table dt as
      (select train_schedule.route_id from train_schedule where day_of_week = want_days);
    create temp table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(route_id varchar(10), dist integer);

    while (select count(r1.route_id) from r1) <> 0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select min(r1.route_id) from r1), a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.curst = d.station_prev and t.targst = d.station_next));
      insert into r2(route_id, dist) values ((select min(r1.route_id) from r1), (select sum(station_distances) from j1));
      delete from r1 where r1.route_id = (select min(r1.route_id) from r1);
    end loop;

    return query
      select * from r2;
  end;
  $$language plpgsql;

create or replace function single_trip_dest_max(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(routeid varchar(10), dist int) as
  $$
  declare
    di integer;
  begin
    drop table if exists dt, rid_days, arri, dest, r1, r2;
    create temp table dt as
      (select train_schedule.route_id from train_schedule where day_of_week = want_days);
    create temp table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(route_id varchar(10), dist integer);

    while (select count(r1.route_id) from r1) <> 0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select max(r1.route_id) from r1), a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.curst = d.station_prev and t.targst = d.station_next));
      insert into r2(route_id, dist) values ((select max(r1.route_id) from r1), (select sum(station_distances) from j1));
      delete from r1 where r1.route_id = (select min(r1.route_id) from r1);
    end loop;

    return query
      select * from r2;
  end;
  $$language plpgsql;


--select * from single_trip_dest('1','8','Monday');
--1.2.4.1this is to create the table with stops ascend
--search mode 1 for single 0 for combined
create or replace function stops_amount(rid varchar(10), a_station varchar(10), d_station varchar(10)) returns integer as
  $$
  begin
    drop table if exists tmp1, tmp2;
    create temp table tmp1 as
      (select station_id, station_num from routes_and_station_status where route_id = rid and station_status = true);
    create temp table tmp2 as
      (select tmp1.station_id, tmp1.station_num from tmp1 where (tmp1.station_num between (select station_num from tmp1 where tmp1.station_id = a_station) and (select station_num from tmp1 where tmp1.station_id = d_station)));
    return
      (select count(*) from tmp2);
  end;
  $$language plpgsql;

--select * from stops_amount('22','1','9');

create or replace function stops_min(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(rid varchar(10), stop_num integer) as
  $$
  begin
    drop table if exists dt, rid_days, r1,r2,arri,dest;
    create temp table dt as
      (select train_schedule.route_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id));

    create temp table r2 (rids varchar(10), numstop integer);
    while (select count(r1.route_id) from r1)<>0 loop
      insert into r2(rids, numstop) values ((select min(r1.route_id) from r1), (stops_amount((select min(r1.route_id) from r1), a_station, d_station)));
      delete from r1 where r1.route_id = (select min(r1.route_id) from r1);
    end loop;

    return query
      select * from r2;
  end;
  $$language plpgsql;

--select * from stops_min('1','9','Monday');


--1.2.4.2this is to order the table run through most stations dec
create or replace function sta_amount(rid varchar(10), a_station varchar(10), d_station varchar(10)) returns integer as
  $$
  declare
    inoo integer;
  begin
    drop table if exists tmp1, tmp2;
    create temp table tmp1 as
      (select station_id, station_num from routes_and_station_status where route_id = rid);
    create temp table tmp2 as
      (select tmp1.station_id, tmp1.station_num from tmp1 where (tmp1.station_num between (select station_num from tmp1 where tmp1.station_id = a_station) and (select station_num from tmp1 where tmp1.station_id = d_station)));
    inoo := (select count(*) from tmp2);
    return inoo;
  end;
  $$language plpgsql;

--select * from sta_amount('22','1','9');

create or replace function pass_most(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(route_id varchar(5), total_num int) as
  $$
  begin
    drop table if exists dt, rid_days, r1,r2,arri,dest;
    create temp table dt as
      (select train_schedule.route_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    --delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id));

    create temp table r2 (rids varchar(10), numsta integer);
    while (select count(r1.route_id) from r1)<>0 loop
      insert into r2(rids, numsta) values ((select max(r1.route_id) from r1), (sta_amount((select min(r1.route_id) from r1), a_station, d_station)));
      delete from r1 where r1.route_id = (select max(r1.route_id) from r1);
    end loop;

    return query
      select * from r2;
  end;
  $$language plpgsql;

--select * from pass_most('1','9','Monday')
--1.2.4.3this is to calculate the lowest price
create or replace function low_price(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(rid varchar(10), dist integer, price integer) as
  $$
  begin
  drop table if exists dt, rid_days, arri, dest,r1,r2,r3,r4;
  create temp table dt as
      (select train_schedule.route_id, train_schedule.train_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(rid varchar(10), dists integer);
    while (select count(r1.route_id) from r1) <> 0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select min(r1.route_id) from r1),a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.targst = d.station_prev and t.targst = d.station_next));
      insert into r2(rid, dists) VALUES ((select min(r1.route_id) from r1),(select sum(j1.station_distances) from j1));
      delete from r1 where r1.route_id = (select min(r1.route_id) from r1);
    end loop;
    create temp table r3 as
      (select r2.rid as rid, r2.dists as dists, dt.train_id from r2 join dt on r2.rid = dt.route_id);
    create temp table r4 as
      (select r3.rid, r3.dists, r3.dists*price_mile as price from (r3 join trains on r3.train_id = trains.train_id));
    return query
      select * from r4;
    end;
  $$language plpgsql;

--select * from low_prince('1','9','Monday');

--1.2.4.4
create or replace function high_price(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(rid varchar(10), dist integer, price integer) as
  $$
  begin
  drop table if exists dt, rid_days, arri, dest,r1,r2,r3,r4;
  create temp table dt as
      (select train_schedule.route_id, train_schedule.train_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(rid varchar(10), dists integer);
    while (select count(r1.route_id) from r1) <> 0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select min(r1.route_id) from r1),a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.targst = d.station_prev and t.targst = d.station_next));
      insert into r2(rid, dists) VALUES ((select max(r1.route_id) from r1),(select sum(j1.station_distances) from j1));
      delete from r1 where r1.route_id = (select max(r1.route_id) from r1);
    end loop;
    create temp table r3 as
      (select r2.rid as rid, r2.dists as dists, dt.train_id from r2 join dt on r2.rid = dt.route_id);
    create temp table r4 as
      (select r3.rid, r3.dists, r3.dists*price_mile as price from (r3 join trains on r3.train_id = trains.train_id));
    return query
      select * from r4;
    end;
  $$language plpgsql;
--1.2.4.5
create or replace function least_time(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(rid varchar(10), dists integer, duration integer) as
  $$
  begin
    create temp table dt as
      (select train_schedule.route_id, train_schedule.train_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(rid varchar(10), dists integer);
    while (select count(r1.route_id) from r1)<>0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select min(r1.route_id) from r1),a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.targst = d.station_prev and t.targst = d.station_next));
      insert into r2(rid, dists) VALUES ((select min(r1.route_id) from r1),(select sum(j1.station_distances) from j1));
      delete from r1 where r1.route_id = (select min(r1.route_id) from r1);
    end loop;
    create temp table r3 as
      (select r2.rid as rid, r2.dists as dists, dt.train_id from r2 join dt on r2.rid = dt.route_id);
    create temp table r4 as
      (select r3.rid, r3.dists, r3.dists/top_speed as tyme from (r3 join trains on r3.train_id = trains.train_id));
    return query
      select * from r4;
  end;
  $$language plpgsql;
--1.2.4.6
create or replace function most_time(a_station varchar(10), d_station varchar(10), want_days varchar(10)) returns table(rid varchar(10), dists integer, duration integer) as
  $$
  begin
    create temp table dt as
      (select train_schedule.route_id, train_schedule.train_id from train_schedule where day_of_week = want_days);
    create table rid_days as
      (select r.route_id, r.station_id, r.station_num, r.station_status from routes_and_station_status as r inner join dt on r.route_id = dt.route_id);
    delete from rid_days where station_status = false;
    create temp table arri as
      (select rid_days.route_id, rid_days.station_num as sorder1 from rid_days where station_id = a_station);
    create temp table dest as
      (select rid_days.route_id, rid_days.station_num as sorder2 from rid_days where station_id = d_station);
    create temp table r1 as
      (select arri.route_id from (arri inner join dest on arri.route_id = dest.route_id and arri.sorder1 < dest.sorder2));
    create temp table r2(rid varchar(10), dists integer);
    while (select count(r1.route_id) from r1)<>0 loop
      drop table if exists tt1, j1;
      create temp table tt1 as
        (select * from get_seq((select min(r1.route_id) from r1),a_station, d_station));
      create temp table j1 as
        (select * from tt1 as t join rail_distances as d on (t.targst = d.station_prev and t.targst = d.station_next));
      insert into r2(rid, dists) VALUES ((select max(r1.route_id) from r1),(select sum(j1.station_distances) from j1));
      delete from r1 where r1.route_id = (select max(r1.route_id) from r1);
    end loop;
    create temp table r3 as
      (select r2.rid as rid, r2.dists as dists, dt.train_id from r2 join dt on r2.rid = dt.route_id);
    create temp table r4 as
      (select r3.rid, r3.dists, r3.dists/top_speed as tyme from (r3 join trains on r3.train_id = trains.train_id));
    return query
      select * from r4;
  end;
  $$language plpgsql;

--1.2.4.7, 1.2.4.8
create or replace function lowest_distance(route varchar(5), start_st varchar(10), end_st varchar(10)) returns table(route1 varchar(5), start_st1 varchar(10), end_st1 varchar(10)) as
  $$
  declare
    mem1 varchar(10);
    mem2 varchar(10);
    dist int;
  begin
    drop table if exists t1, t2;
    create temp table t1 as (select * from routes_and_station_status where route_id = route);
    select station_num into mem1 from t1 where station_id = start_st;
    select station_num into mem2 from t1 where station_id = end_st;
    delete from t1 where station_num < mem1;
    delete from t1 where station_num > mem2;
    create temp table t2 as (select * from rail_distances where rail_distances.station_prev = t1.station_id);
    select sum(t2.station_distances) into dist from t2;

  end;
  $$language plpgsql;


--1.2.5This is to add reservation
create or replace procedure add_resv(new_passanger_id int, route varchar(10), new_day varchar(10), start_sta1 varchar(10), end_sta1 varchar(10)) as
  $$
  begin
    insert into reservations(passanger_id, route_id, day_of_week, start_sta, end_sta) values (new_passanger_id, route, new_day, start_sta1, end_sta1);
  end;
  $$language plpgsql;

create or replace function resv_update() returns trigger as
  $$
  declare
    want_day varchar(10);
    want_route varchar(10);
    stats_seat boolean;
    seats_occu int;
  begin
    drop table if exists t1;
    select new_day into want_day from reservations;
    select route into want_route from reservations;
    select open_status into stats_seat from seats;
    select seats_taken into seats_occu from seats;
    create temp table t1 as (select * from train_schedule where day_of_week = want_day);
    delete from t1 where route_id <> want_route;
    if stats_seat = true then
      update seats set seats_taken = seats_occu + 1 where seats.train_id = t1.train_id;
      if seats_occu = seats.seats_total - 1 then
          update seats set open_status = false where seats.train_id = t1.train_id;
      end if;
    end if;
    return new;
  end;
  $$language plpgsql;

create trigger do_update
  after insert
  on reservations
  for each row
  execute procedure resv_update();

--this is for 1.3.1
create or replace function all_pass(want_station varchar(5), want_day varchar(10), want_time varchar(10)) returns table(want_train varchar(5)) as
  $$
  begin
  drop table if exists temp_schedule, temp_stations;
  create temp table temp_schedule as (select * from train_schedule where day_of_week = want_day and time_route = want_time);
  create temp table temp_stations as (select route_id from routes_and_station_status where station_id = want_station);
  --create temp table ts2 as (select * from temp_schedule where temp_schedule.route_id in(select route_id from temp_stations));
  return query
    select train_id from temp_schedule where temp_schedule.route_id in (select route_id from temp_stations) group by train_id;
  end;
  $$language plpgsql;

--select * from all_pass('1','Sunday','04:46');

--this is for 1.3.2
create or replace function pass_multi() returns table(multi_route varchar(5)) as
  $$
  begin
    drop table if exists t1, t2;
    create temp table t1 as (select distinct route_id, rail_id from routes_and_station_status left join rail_stations
  on routes_and_station_status.station_id = rail_stations.station_id);
    create temp table t2 as (select route_id, count(route_id) from t1 group by route_id);
    delete from t2 where count = 1;
    return query
      select route_id from t2;
  end;
  $$language plpgsql;

--select * from pass_multi();

--this is for 1.3.3
create or replace function same_stations(routeid varchar(10)) returns table(rid varchar(10)) as
  $$
  begin
    drop table if exists tr1, tr2, tr3, tr4;
  create temp table tr1 as
      (select * from routes_and_station_status where route_id <> routeid);
  --select * from tr1;
  create temp table tr2 as
      (select route_id, count(station_id) from tr1 group by route_id);
  --select * from tr2;
  delete from tr2 where tr2.count <> (select count(station_id) from routes_and_station_status where route_id = routeid);
   delete from tr1 where tr1.route_id not in (select tr2.route_id from tr2);

  create temp table tr3 as
      (select * from routes_and_station_status where route_id = routeid);
  --select * from tr3;

  delete from tr1 where station_id not in (select station_id from tr3);

  create temp table tr4 as
      (select route_id, count(station_id) from tr1 group by route_id);
  --select * from tr4;

  delete from tr4 where count <> (select count(station_id) from routes_and_station_status where route_id = routeid);
  delete from tr1 where route_id not in (select route_id from tr4);

  return query
    select route_id from tr4;
  end;
  $$language plpgsql;

--select * from same_stations('85');

--this is for 1.3.4
create or replace function all_trian_pass_through() returns table(null_station varchar(10)) as
  $$
  begin
    drop table if exists t1, t2, t3;
    create temp table t1 as
      (select train_schedule.route_id as rid1, train_schedule.train_id as tid1 from train_schedule);
    create temp table t2 as
      (select tid1, routes_and_station_status.station_id as sid1 from t1 join routes_and_station_status on rid1 = routes_and_station_status.route_id);
    create temp table t3 as
      (select sid1, count(distinct tid1) as cot from t2 group by sid1);
    return query
      select sid1 from t3 where cot = (select count(trains.train_id) from trains);
  end;
  $$language plpgsql;

--select * from all_trian_pass_through();

--this is for 1.3.5
create or replace function never_pass(want_staton varchar(5)) returns table(np_train varchar(5)) as
  $$
  begin
  drop table if exists t1,t2,t3;
  create temp table t1 as
    (select * from routes_and_station_status where station_id = want_staton);
  delete from t1 where station_status = false;
  create temp table t2 as
    (select t1.route_id from t1 group by route_id);
  create temp table t3 as
    (select * from train_schedule);
  delete from t3 where t3.route_id not in (select t2.route_id from t2);
  return query
    select distinct train_id from t3;
  end;
  $$language plpgsql;

--select * from never_pass('1');

--this is for 1.3.6
create or replace function pass_rate(percentage float) returns table(p_route varchar(10)) as
  $$
  begin
  return query
    select route_id from routes where stop_rate >= percentage group by route_id;
  end;
  $$language plpgsql;

--select * from pass_rate(20.00);

--this is 1.3.7
create or replace function display_route(want_route varchar(5)) returns table(day_get varchar(10), time_get varchar(10), train_get varchar(10)) as
  $$
  begin
    return query
      select day_of_week, time_route, train_id from train_schedule where route_id = want_route;
  end;
  $$language plpgsql;

--select * from display_route('Monday');
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

