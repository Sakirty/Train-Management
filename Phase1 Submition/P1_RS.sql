/*
Table for station's basic info
id, name and operation hrs
*/
create table if not exists stations
(
  station_id   varchar(5)  not null,
  station_name  varchar(20) not null,
  hrs_operation int,
  constraint pk_stations primary key (station_id)
);

/*
each id has a location in form of location, city, zip
fk from station
*/
create table if not exists stations_location(
  station_id   varchar(5)  not null,
  station_location varchar(30) not null,
  station_city varchar(30) not null,
  station_zip int not null,
  constraint pk_stations_location primary key (station_id),
  constraint fk_stations_location foreign key (station_id) references stations (station_id)
);

/*
each location can have multi connections
one station id can have multi connedted stations
so the pk here is a pair
*/
create table if not exists stations_connection(
    station_id varchar(5) not null,
    connected_id varchar(5) not null,
    distance_between int not null,
    constraint pk_stations_connection primary key (station_id, connected_id),
    constraint fk_stations_connection foreign key (station_id) references stations (station_id)
);

/*
a rail will be given a rail id
and all stations on that rail will be reference to that id, we have prev/curr/next station
identified by their ststion id (can be later join with stations_connection for distance calculation)
speed limit should be positive
*/
create table if not exists rail_lines(
    rail_id varchar(5) not null,
    curr_station_id varchar(5) not null,
    prev_station_id varchar(5),
    next_station_id varchar(5),
    speed_limit int not null check (speed_limit > 0),
    constraint pk_rail_lines primary key (rail_id, curr_station_id)
);

/*
The route id indicates a unique route
pass_stations indicates all stations on this route
if station_status:
    0 for start location
    1 for will stop at
    2 for will not stop, only pass by
    3 for end station
*/
create table if not exists routes(
    route_id varchar(20) not null,
    pass_stations varchar(5) not null,
    station_status int not null,
    constraint pk_routes primary key (route_id, pass_stations)
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
    top_speed int not null check (top_speed > 0),
    seats_num int not null check (seats_num > 0),
    price_mile int,
    number_of_schedule int,
    constraint pk_trains primary key (train_id)
);

/*
Table for train_schedule
each schedule has a unique id
the train/route running on this schedule
and stations on this schedule
also arrival/depart time for each location
*/
create table if not exists train_schedule(
    schedule_id varchar(5) not null,
    train_id varchar(5) not null,
    rail_id varchar(5) not null,
    station_id varchar(5) not null,
    depart_time varchar(10),
    arrival_time varchar(10),
    constraint pk_train_schedule primary key (schedule_id),
    constraint fk_train_schedule_1 foreign key (rail_id) references rail_lines (rail_id),
    constraint fk_train_schedule_2 foreign key (train_id) references trains (train_id)
);

/*
This is the agent for serving passangers
1 agent can serve multi-passangers
*/
create table if not exists agents(
    agent_id varchar(10) not null,
    f_name varchar(20),
    l_name varchar(20),
    email_addr varchar(20),
    phone_number varchar(20),
    constraint pk_agent primary key (agent_id)
);

/*
each passanger has a unique id
and a related agent to get them ticket
*/
create table if not exists passangers(
    passanger_id varchar(10) not null,
    f_name varchar(20),
    l_name varchar(20),
    email_addr varchar(20),
    phone_number varchar(20),
    home_addr varchar(40),
    agent_id varchar(10),
    constraint pk_passangers primary key (passanger_id),
    constraint fk_passangers foreign key (agent_id) references agents (agent_id)
);