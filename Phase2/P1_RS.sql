/*
Table for station's basic info
id, name and operation hrs
*/
create table if not exists stations
(
  station_id   varchar(5)  not null,
  station_name  varchar(20) not null,
  open_time varchar(10),
  close_time varchar(10),
  stop_delay int,
  street varchar(20),
  town varchar(20),
  zip varchar(10),
  constraint pk_stations primary key (station_id)
);


/*
This table will only contains the RAIL LINE ID and the speed limit
*/
create table if not exists rail_lines(
    rail_id varchar(5) not null,
    speed_limit int not null check (speed_limit > 0),
    constraint pk_rail_lines primary key (rail_id)
);

/*
This table only contains the railline ID and the speed limit
*/
create table if not exists rail_distances(
  rail_id     varchar(5) not null,
  station_prev varchar(5),
  station_next varchar(5),
  station_distances int,
  constraint pk_rail_distances primary key (rail_id,station_prev,station_next),
  constraint fk_rail_distances_1 foreign key (rail_id) references rail_lines (rail_id),
  constraint fk_rail_distances_2 foreign key (station_prev) references stations (station_id),
  constraint fk_rail_distances_3 foreign key (station_next) references stations (station_id)
);

/*
The route id indicates a unique route
This table contains only route id
*/
create table if not exists routes(
    route_id varchar(20) not null,
    total_num int,
    stop_num int,
    stop_rate float,
    constraint pk_routes primary key (route_id)
);

/*
This table contains:
route id, station id, station number, stop status
as a foreign ref to routes and stations
*/
create table if not exists routes_and_station_status(
  route_id       varchar(20) not null,
  station_id     varchar(5)  not null,
  station_num    int,
  station_status boolean,
  constraint pk_routes_and_station_status primary key (route_id, station_id),
  constraint fk_routes_and_station_status_1 foreign key (route_id) references routes (route_id),
  constraint fk_routes_and_station_status_2 foreign key (station_id) references stations (station_id)
);

/*
This is the table for train
each train has a unique id
with a positive top speed and seats number
and price per mile
and a train can has no schedule -> not in use
*/
create table if not exists trains(
    train_id varchar(5) not null,
    train_name varchar(5),
    train_descript varchar(20),
    seats_num int not null check (seats_num > 0),
    top_speed int not null check (top_speed > 0),
    price_mile int,
    constraint pk_trains primary key (train_id)
);

/*
This table is used for seat reservations
*/
create table if not exists seats(
  train_id varchar(5) not null,
  seats_total int,
  seats_taken int,
  open_status boolean,
  constraint pk_seats primary key (train_id),
  constraint fk_seats_1 foreign key (train_id) references trains (train_id)
);

/*
Table for train_schedule
each schedule has a unique id
the train/route running on this schedule
and stations on this schedule
also arrival/depart time for each location
*/
create table if not exists train_schedule(
    route_id varchar(5) not null,
    day_of_week varchar(5),
    time_route varchar(5),
    train_id varchar(10),
    constraint pk_train_schedule primary key (route_id, train_id),
    constraint fk_train_schedule_1 foreign key (route_id) references routes (route_id),
    constraint fk_train_schedule_2 foreign key (train_id) references trains (train_id)
);



/*
each passanger has a unique id
and a related agent to get them ticket
*/
create table if not exists passangers(
    passanger_id varchar(10) not null,
    f_name varchar(20),
    l_name varchar(20),
    street varchar(20),
    town varchar(20),
    zip varchar(10),
    constraint pk_passangers primary key (passanger_id)
);

