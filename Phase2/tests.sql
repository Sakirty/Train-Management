
--stations with no pass
select station_id into temp1 from routes_and_station_status where station_status = false group by station_id order by station_id asc;
select station_id into temp2 from stations;
delete from temp2 where station_id in (select temp1.station_id from temp1);

