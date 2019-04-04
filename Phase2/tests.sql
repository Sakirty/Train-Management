
--stations with no pass
select station_id into temp1 from routes_and_station_status where station_status = false group by station_id order by station_id asc;
select station_id into temp2 from stations;
delete from temp2 where station_id in (select temp1.station_id from temp1);

--get all pass
select station_id,count(station_id) into temp1 from routes_and_station_status where station_status = false group by station_id;
delete from temp1 where count < (select count(route_id) from routes);

--select station_id,count(station_id) into temp2 from routes_and_station_status group by station_id;
select count(route_id) from routes;