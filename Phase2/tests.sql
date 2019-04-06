
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