CREATE DATABASE sage;
USE sage;

CREATE TABLE `User`(
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(50),
    password VARCHAR(255)
);

CREATE TABLE Location (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    address VARCHAR(100)
);

CREATE TABLE SOS_Alert (
    sos_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    status VARCHAR(20),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Emergency_Contact (
    contact_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(50),
    phone VARCHAR(20),
    relation VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Police_Station (
    station_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    area VARCHAR(50),
    contact VARCHAR(20)
);

CREATE TABLE Hospital (
    hospital_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    contact VARCHAR(20)
);

CREATE TABLE Emergency_Service (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    type VARCHAR(20),
    contact VARCHAR(20)
);

CREATE TABLE Safety_Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    category VARCHAR(50),
    price INT,
    description VARCHAR(200)
);

CREATE TABLE Safety_Tips (
    tip_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    category VARCHAR(50),
    description VARCHAR(200)
);

CREATE TABLE Safe_Zone (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT,
    type VARCHAR(50),
    rating INT,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Incident_Report (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    type VARCHAR(50),
    description VARCHAR(500),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Notification (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    message VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    rating INT,
    comments VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Risk_Analysis (
    analysis_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    risk_level VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Evidence (
    evidence_id INT PRIMARY KEY AUTO_INCREMENT,
    sos_id INT,
    type VARCHAR(20),
    file_path VARCHAR(100),
    FOREIGN KEY (sos_id) REFERENCES SOS_Alert(sos_id)
);

CREATE TABLE User_Product (
    user_id INT,
    product_id INT,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id),
    FOREIGN KEY (product_id) REFERENCES Safety_Product(product_id)
);

CREATE TABLE User_Tips (
    user_id INT,
    tip_id INT,
    PRIMARY KEY (user_id, tip_id),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id),
    FOREIGN KEY (tip_id) REFERENCES Safety_Tips(tip_id)
);

CREATE TABLE SOS_Notification (
    sos_id INT,
    notification_id INT,
    PRIMARY KEY (sos_id, notification_id),
    FOREIGN KEY (sos_id) REFERENCES SOS_Alert(sos_id),
    FOREIGN KEY (notification_id) REFERENCES Notification(notification_id)
);

CREATE TABLE Service_Police (
    service_id INT,
    station_id INT,
    PRIMARY KEY (service_id, station_id),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id),
    FOREIGN KEY (station_id) REFERENCES Police_Station(station_id)
);

CREATE TABLE Service_Hospital (
    service_id INT,
    hospital_id INT,
    PRIMARY KEY (service_id, hospital_id),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id),
    FOREIGN KEY (hospital_id) REFERENCES Hospital(hospital_id)
);


delimiter //
create trigger duplicate_contact
before insert on Emergency_Contact 
for each row
begin
if exists (
	select 1 from Emergency_Contact where
    user_id=NEW.user_id
    and 
    phone = new.phone
)
then 
	signal sqlstate '45000'
    set message_text = 'Duplicate Contact Not Allowed ' ;
	end if ;

end //
 delimiter ;


delimiter //
create trigger after_sos  
after insert on sos_alert  
for each row  
begin  
    insert into notification(user_id, message)  
    values (new.user_id, 'SOS Triggered!');  
end //
delimiter ;


delimiter //
create trigger update_risk  
after insert on sos_alert  
for each row  
begin  
    insert into risk_analysis(user_id, risk_level)  
    values (  
        new.user_id,  
        (select getrisklevel(new.user_id))  
    );  
end //
delimiter ;


delimiter //
create function contactcount(u_id int)
returns int
deterministic 
begin
	declare total int;
    select count(*) into total
    from emergency_contact
    where user_id = u_id;
    
    return total;
end //
delimiter ;


delimiter //
create function getrisklevel(u_id int)
returns varchar(20)
deterministic
begin
	declare sos_count int;
    declare contact_count int;
    declare risk varchar(50);
    
    select count(*) into sos_count
    from sos_alert
    where user_id = u_id;
    
    set contact_count = contactcount(u_id);
    
    if contact_count = 0 then
		set risk = "HIGH";
	elseif sos_count > 5 then
        set risk = 'HIGH';
    elseif sos_count between 3 and 5 then
        set risk = 'MEDIUM';
    else
        set risk = 'LOW';
    end if;
    return risk;
end //
delimiter ;


delimiter //
create procedure createsos (in u_id int, in sos_status varchar(20))
begin 
	if not exists (select 1 from `user` where user_id = u_id) then
		signal sqlstate '45000'
        set message_text = "User does not exist";
	else
		insert into sos_alert(user_id, status) values (u_id, sos_status);
	end if;
end //
delimiter ;


delimiter //
create procedure SaveLocation(
in lat decimal(9,6),
in lng decimal(9,6),
in addr varchar(100)
)
begin
insert into Location(latitude, longitude, address)
values (lat, lng, addr);
end//
delimiter ;

delimiter //
create procedure AddReport(
in u_id int, 
in r_type varchar(50),
in descr varchar(500)
)
begin
insert into Incident_Report(user_id, type, description)
values(u_id, r_type, descr);
end //
delimiter ;

delimiter //
create procedure AddNotification(
in u_id int,
in msg varchar(100)
)
begin 
insert into Notification(user_id, message)
values(u_id, msg);
end //
delimiter ;

delimiter //
create procedure SaveLocation(
in lat decimal(9,6),
in lng decimal(9,6),
in addr varchar(100)
)
begin
insert into Location(latitude, longitude, address)
values (lat, lng, addr);
end//
delimiter ;


delimiter //
create procedure AddReport(
in u_id int, 
in r_type varchar(50),
in descr varchar(500)
)
begin
insert into Incident_Report(user_id, type, description)
values(u_id, r_type, descr);
end //
delimiter ;


delimiter //
create procedure AddNotification(
in u_id int,
in msg varchar(100)
)
begin 
insert into Notification(user_id, message)
values(u_id, msg);
end //
delimiter ;