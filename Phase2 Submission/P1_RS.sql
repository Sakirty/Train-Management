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
a rail will be given a rail id
and all stations on that rail will be reference to that id, we have prev/curr/next station
identified by their ststion id (can be later join with stations_connection for distance calculation)
speed limit should be positive
*/
create table if not exists rail_lines(
    rail_id varchar(5) not null,
    speed_limit int not null check (speed_limit > 0),
    station_list varchar(255),
    distance_list varchar(255),
    constraint pk_rail_lines primary key (rail_id)
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
    station_lists varchar(1000),
    stop_list varchar(1000),
    constraint pk_routes primary key (route_id)
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
This is the agent for serving passangers
1 agent can serve multi-passangers
其实没有agent
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
    street varchar(20),
    town varchar(20),
    zip varchar(10),
    constraint pk_passangers primary key (passanger_id)
);