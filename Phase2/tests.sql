
--stations with no pass
select station_id into temp1 from routes_and_station_status where station_status = false group by station_id order by station_id asc;
select station_id into temp2 from stations;
delete from temp2 where station_id in (select temp1.station_id from temp1);

--get all pass
select station_id,count(station_id) into temp1 from routes_and_station_status where station_status = false group by station_id;
delete from temp1 where count < (select count(route_id) from routes);

--select station_id,count(station_id) into temp2 from routes_and_station_status group by station_id;
select count(route_id) from routes;
--stations that all train pass but dont stop

select route_id into z from train_schedule group by route_id;
select * into z1 from routes_and_station_status;
delete from z1 where route_id not in (select route_id from z);
delete from z1 where station_status = true;
select station_id, count(station_id) into z2 from z1 group by station_id;
delete from z2 where count < (select count(route_id) from z1);

--
select distinct route_id, rail_id into z from routes_and_station_status left join rail_stations
  on routes_and_station_status.station_id = rail_stations.station_id;
--select route_id, rail_id into z1 from z;
select route_id, count(route_id) into z1 from z group by route_id;
delete from z2 where count = 1;
select count(route_id) from z2;

--

select route_id, station_id into z1 from routes_and_station_status;
select route_id, station_id into z2 from routes_and_station_status;

--
drop table tmp1;
create temp table tmp1 as
      (select station_id, station_num from routes_and_station_status where route_id = '22' and station_status = true);
select * from tmp1;

create temp table tmp2 as
      (select tmp1.station_id, tmp1.station_num from tmp1 where (tmp1.station_num between (select station_num from tmp1 where tmp1.station_id = '1') and (select station_num from tmp1 where tmp1.station_id = '9')));
select count(*) from tmp2;


select route_id, count(station_id) from routes_and_station_status group by route_id

drop table tr1, tr2, tr3, tr4;
create temp table tr1 as
      (select * from routes_and_station_status where route_id <> '85');
select * from tr1;

create temp table tr2 as
      (select route_id, count(station_id) from tr1 group by route_id);
select * from tr2;
    delete from tr2 where tr2.count <> (select count(station_id) from routes_and_station_status where route_id = '85');
    delete from tr1 where tr1.route_id not in (select tr2.route_id from tr2);

create temp table tr3 as
      (select * from routes_and_station_status where route_id = '85');
select * from tr3;

delete from tr1 where station_id not in (select station_id from tr3);

create temp table tr4 as
      (select route_id, count(station_id) from tr1 group by route_id);
select * from tr4;

delete from tr4 where count <> (select count(station_id) from routes_and_station_status where route_id = '85');
delete from tr1 where route_id not in (select route_id from tr4);