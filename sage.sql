-- ============================================================
--  SAGE — Women Safety Management & Tracking System
--  sage.sql  |  Full schema based on EER diagram + improvements
-- ============================================================

DROP DATABASE IF EXISTS sage;
CREATE DATABASE sage;
USE sage;

-- ─────────────────────────────────────────────
--  CORE TABLES
-- ─────────────────────────────────────────────

CREATE TABLE `User` (
    user_id    INT          PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(50)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL UNIQUE,
    email      VARCHAR(50)  UNIQUE,
    password   VARCHAR(255) NOT NULL,       -- store bcrypt hash only, never plain text
    created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Location (
    location_id INT          PRIMARY KEY AUTO_INCREMENT,
    latitude    DECIMAL(9,6) NOT NULL,
    longitude   DECIMAL(9,6) NOT NULL,
    address     VARCHAR(100),
    recorded_at DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- EER: User "Shares" Location
CREATE TABLE User_Location (
    user_id     INT NOT NULL,
    location_id INT NOT NULL,
    shared_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, location_id),
    FOREIGN KEY (user_id)     REFERENCES `User`(user_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- FIX: added location_id FK so every SOS knows where it happened
CREATE TABLE SOS_Alert (
    sos_id      INT         PRIMARY KEY AUTO_INCREMENT,
    user_id     INT         NOT NULL,
    location_id INT,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    timestamp   DATETIME    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)     REFERENCES `User`(user_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Emergency_Contact (
    contact_id INT         PRIMARY KEY AUTO_INCREMENT,
    user_id    INT         NOT NULL,
    name       VARCHAR(50) NOT NULL,
    phone      VARCHAR(20) NOT NULL,
    relation   VARCHAR(30),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

-- EER: Emergency Services with Availability attribute + "is a" subtypes
CREATE TABLE Emergency_Service (
    service_id   INT          PRIMARY KEY AUTO_INCREMENT,
    type         VARCHAR(20)  NOT NULL CHECK (type IN ('AMBULANCE','POLICE','NGO','OTHER')),
    name         VARCHAR(100) NOT NULL,
    contact      VARCHAR(20),
    availability VARCHAR(50)  DEFAULT 'AVAILABLE',
    location_id  INT,
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- EER "is a" subtypes
CREATE TABLE Ambulance (
    service_id     INT PRIMARY KEY,
    vehicle_number VARCHAR(20),
    hospital_name  VARCHAR(100),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id)
);

CREATE TABLE Police_Station (
    service_id   INT PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    area         VARCHAR(100),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id)
);

CREATE TABLE NGO (
    service_id INT PRIMARY KEY,
    ngo_name   VARCHAR(100) NOT NULL,
    focus_area VARCHAR(100),
    website    VARCHAR(200),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id)
);

-- EER: Safety_Product with Link attribute; price as DECIMAL
CREATE TABLE Safety_Product (
    product_id  INT           PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)  NOT NULL,
    category    VARCHAR(50),
    price       DECIMAL(10,2),
    description VARCHAR(500),
    link        VARCHAR(255)
);

CREATE TABLE Safety_Tips (
    tip_id      INT          PRIMARY KEY AUTO_INCREMENT,
    title       VARCHAR(100) NOT NULL,
    category    VARCHAR(50),
    description VARCHAR(500),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- FIX: name, description, rating constraint added
CREATE TABLE Safe_Zone (
    zone_id     INT         PRIMARY KEY AUTO_INCREMENT,
    location_id INT         NOT NULL,
    name        VARCHAR(100),
    type        VARCHAR(50),
    description VARCHAR(300),
    rating      INT         CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- EER: Incident has Evidence attribute, Date & Time, Occurs at Location
CREATE TABLE Incident_Report (
    report_id   INT          PRIMARY KEY AUTO_INCREMENT,
    user_id     INT          NOT NULL,
    location_id INT,
    type        VARCHAR(50),
    description VARCHAR(500),
    evidence    VARCHAR(255),
    reported_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)     REFERENCES `User`(user_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- EER: Notification with N_type attribute; added is_read + timestamp
CREATE TABLE Notification (
    notification_id INT          PRIMARY KEY AUTO_INCREMENT,
    user_id         INT          NOT NULL,
    message         VARCHAR(255) NOT NULL,
    n_type          VARCHAR(30)  DEFAULT 'GENERAL',  -- SOS, JOURNEY, ALERT, GENERAL
    is_read         TINYINT(1)   DEFAULT 0,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Feedback (
    feedback_id  INT         PRIMARY KEY AUTO_INCREMENT,
    user_id      INT         NOT NULL,
    rating       INT         CHECK (rating BETWEEN 1 AND 5),
    comments     VARCHAR(500),
    submitted_at DATETIME    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

CREATE TABLE Risk_Analysis (
    analysis_id INT         PRIMARY KEY AUTO_INCREMENT,
    user_id     INT         NOT NULL,
    risk_level  VARCHAR(20) NOT NULL,
    analysed_at DATETIME    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

-- EER: Evidence "Contains" SOS — File_type + File_path attributes
CREATE TABLE Evidence (
    evidence_id INT          PRIMARY KEY AUTO_INCREMENT,
    sos_id      INT          NOT NULL,
    file_type   VARCHAR(20)  NOT NULL,   -- PHOTO, VIDEO, AUDIO
    file_path   VARCHAR(255) NOT NULL,
    uploaded_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sos_id) REFERENCES SOS_Alert(sos_id)
);

-- ─────────────────────────────────────────────
--  JOURNEY TRACKING (beyond EER)
-- ─────────────────────────────────────────────

CREATE TABLE Journey (
    journey_id       INT         PRIMARY KEY AUTO_INCREMENT,
    user_id          INT         NOT NULL,
    origin_id        INT,
    destination_id   INT,
    expected_arrival DATETIME,
    actual_arrival   DATETIME,
    status           VARCHAR(20) DEFAULT 'IN_PROGRESS',  -- IN_PROGRESS, COMPLETED, OVERDUE
    started_at       DATETIME    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)        REFERENCES `User`(user_id),
    FOREIGN KEY (origin_id)      REFERENCES Location(location_id),
    FOREIGN KEY (destination_id) REFERENCES Location(location_id)
);

CREATE TABLE Journey_Waypoint (
    waypoint_id INT      PRIMARY KEY AUTO_INCREMENT,
    journey_id  INT      NOT NULL,
    location_id INT      NOT NULL,
    pinged_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (journey_id)  REFERENCES Journey(journey_id),
    FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- ─────────────────────────────────────────────
--  AUDIT LOG (beyond EER)
-- ─────────────────────────────────────────────

CREATE TABLE Audit_Log (
    log_id    INT          PRIMARY KEY AUTO_INCREMENT,
    user_id   INT,
    action    VARCHAR(100) NOT NULL,
    detail    VARCHAR(500),
    logged_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `User`(user_id)
);

-- ─────────────────────────────────────────────
--  JUNCTION TABLES
-- ─────────────────────────────────────────────

-- EER: User "Views" Safety_Product
CREATE TABLE User_Product (
    user_id    INT,
    product_id INT,
    viewed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id)    REFERENCES `User`(user_id),
    FOREIGN KEY (product_id) REFERENCES Safety_Product(product_id)
);

-- EER: User "Views" Safety_Tips
CREATE TABLE User_Tips (
    user_id   INT,
    tip_id    INT,
    viewed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, tip_id),
    FOREIGN KEY (user_id) REFERENCES `User`(user_id),
    FOREIGN KEY (tip_id)  REFERENCES Safety_Tips(tip_id)
);

CREATE TABLE SOS_Notification (
    sos_id          INT,
    notification_id INT,
    PRIMARY KEY (sos_id, notification_id),
    FOREIGN KEY (sos_id)          REFERENCES SOS_Alert(sos_id),
    FOREIGN KEY (notification_id) REFERENCES Notification(notification_id)
);

-- EER: SOS "Req. Assist" Emergency_Service
CREATE TABLE SOS_Service (
    sos_id       INT,
    service_id   INT,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sos_id, service_id),
    FOREIGN KEY (sos_id)     REFERENCES SOS_Alert(sos_id),
    FOREIGN KEY (service_id) REFERENCES Emergency_Service(service_id)
);

-- EER: Emergency_Contact "Notifies"
CREATE TABLE Contact_Notification (
    contact_id      INT,
    notification_id INT,
    PRIMARY KEY (contact_id, notification_id),
    FOREIGN KEY (contact_id)      REFERENCES Emergency_Contact(contact_id),
    FOREIGN KEY (notification_id) REFERENCES Notification(notification_id)
);

-- ─────────────────────────────────────────────
--  FUNCTIONS
-- ─────────────────────────────────────────────

DELIMITER //

CREATE FUNCTION contactcount(u_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Emergency_Contact
    WHERE user_id = u_id;
    RETURN total;
END //

-- FIX: changed DETERMINISTIC to READS SQL DATA (reads from tables)
CREATE FUNCTION getrisklevel(u_id INT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE sos_count     INT;
    DECLARE contact_count INT;
    DECLARE risk          VARCHAR(20);

    SELECT COUNT(*) INTO sos_count
    FROM SOS_Alert
    WHERE user_id = u_id;

    SET contact_count = contactcount(u_id);

    IF contact_count = 0 THEN
        SET risk = 'HIGH';
    ELSEIF sos_count > 5 THEN
        SET risk = 'HIGH';
    ELSEIF sos_count BETWEEN 3 AND 5 THEN
        SET risk = 'MEDIUM';
    ELSE
        SET risk = 'LOW';
    END IF;

    RETURN risk;
END //

DELIMITER ;

-- ─────────────────────────────────────────────
--  TRIGGERS
-- ─────────────────────────────────────────────

DELIMITER //

CREATE TRIGGER duplicate_contact
BEFORE INSERT ON Emergency_Contact
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Emergency_Contact
        WHERE user_id = NEW.user_id
          AND phone   = NEW.phone
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Duplicate contact not allowed for this user';
    END IF;
END //

-- On SOS: auto-notify + audit log
CREATE TRIGGER after_sos
AFTER INSERT ON SOS_Alert
FOR EACH ROW
BEGIN
    INSERT INTO Notification (user_id, message, n_type)
    VALUES (NEW.user_id, 'SOS Triggered! Emergency contacts have been alerted.', 'SOS');

    INSERT INTO Audit_Log (user_id, action, detail)
    VALUES (NEW.user_id, 'SOS_TRIGGERED',
            CONCAT('sos_id=', NEW.sos_id, ' status=', NEW.status));
END //

-- On SOS: update risk analysis
CREATE TRIGGER update_risk
AFTER INSERT ON SOS_Alert
FOR EACH ROW
BEGIN
    INSERT INTO Risk_Analysis (user_id, risk_level)
    VALUES (NEW.user_id, getrisklevel(NEW.user_id));
END //

-- On waypoint insert: mark journey OVERDUE if past ETA
CREATE TRIGGER check_journey_overdue
AFTER INSERT ON Journey_Waypoint
FOR EACH ROW
BEGIN
    UPDATE Journey
    SET status = 'OVERDUE'
    WHERE journey_id       = NEW.journey_id
      AND status           = 'IN_PROGRESS'
      AND expected_arrival < NOW();
END //

-- On OVERDUE journey: auto-trigger SOS
CREATE TRIGGER sos_on_overdue
AFTER UPDATE ON Journey
FOR EACH ROW
BEGIN
    IF NEW.status = 'OVERDUE' AND OLD.status = 'IN_PROGRESS' THEN
        INSERT INTO SOS_Alert (user_id, status)
        VALUES (NEW.user_id, 'AUTO_JOURNEY');

        INSERT INTO Audit_Log (user_id, action, detail)
        VALUES (NEW.user_id, 'AUTO_SOS_JOURNEY',
                CONCAT('journey_id=', NEW.journey_id));
    END IF;
END //

DELIMITER ;

-- ─────────────────────────────────────────────
--  STORED PROCEDURES
-- ─────────────────────────────────────────────

DELIMITER //

-- FIX: removed duplicated procedures; added loc_id param to CreateSOS
CREATE PROCEDURE CreateSOS(
    IN u_id       INT,
    IN sos_status VARCHAR(20),
    IN loc_id     INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `User` WHERE user_id = u_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    ELSE
        INSERT INTO SOS_Alert (user_id, status, location_id)
        VALUES (u_id, sos_status, loc_id);
    END IF;
END //

-- FIX: returns new location ID via OUT param
CREATE PROCEDURE SaveLocation(
    IN  lat    DECIMAL(9,6),
    IN  lng    DECIMAL(9,6),
    IN  addr   VARCHAR(100),
    OUT new_id INT
)
BEGIN
    INSERT INTO Location (latitude, longitude, address)
    VALUES (lat, lng, addr);
    SET new_id = LAST_INSERT_ID();
END //

-- FIX: location_id param added to AddReport
CREATE PROCEDURE AddReport(
    IN u_id   INT,
    IN loc_id INT,
    IN r_type VARCHAR(50),
    IN descr  VARCHAR(500)
)
BEGIN
    INSERT INTO Incident_Report (user_id, location_id, type, description)
    VALUES (u_id, loc_id, r_type, descr);
END //

-- FIX: n_type param added to AddNotification
CREATE PROCEDURE AddNotification(
    IN u_id  INT,
    IN msg   VARCHAR(255),
    IN ntype VARCHAR(30)
)
BEGIN
    INSERT INTO Notification (user_id, message, n_type)
    VALUES (u_id, msg, ntype);
END //

CREATE PROCEDURE StartJourney(
    IN u_id    INT,
    IN orig_id INT,
    IN dest_id INT,
    IN eta     DATETIME
)
BEGIN
    INSERT INTO Journey (user_id, origin_id, destination_id, expected_arrival)
    VALUES (u_id, orig_id, dest_id, eta);
END //

CREATE PROCEDURE CompleteJourney(IN j_id INT)
BEGIN
    UPDATE Journey
    SET status         = 'COMPLETED',
        actual_arrival = NOW()
    WHERE journey_id = j_id;
END //

-- Useful query: get all active SOS with location
CREATE PROCEDURE GetActiveSOS()
BEGIN
    SELECT
        s.sos_id,
        u.name,
        u.phone,
        s.status,
        s.timestamp,
        l.latitude,
        l.longitude,
        l.address
    FROM SOS_Alert s
    JOIN `User`        u ON s.user_id     = u.user_id
    LEFT JOIN Location l ON s.location_id = l.location_id
    WHERE s.status IN ('ACTIVE', 'AUTO_JOURNEY')
    ORDER BY s.timestamp DESC;
END //

-- Useful query: risk summary for all users
CREATE PROCEDURE GetRiskSummary()
BEGIN
    SELECT
        u.user_id,
        u.name,
        u.phone,
        getrisklevel(u.user_id) AS risk_level,
        contactcount(u.user_id) AS contact_count
    FROM `User` u
    ORDER BY risk_level ASC;
END //

DELIMITER ;

-- ─────────────────────────────────────────────
--  SAMPLE DATA
-- ─────────────────────────────────────────────

INSERT INTO `User` (name, phone, email, password) VALUES
('Priya Sharma',  '9876543210', 'priya@example.com',  '$2b$12$samplehash1'),
('Ananya Mehta',  '9876543211', 'ananya@example.com', '$2b$12$samplehash2'),
('Riya Desai',    '9876543212', 'riya@example.com',   '$2b$12$samplehash3');

INSERT INTO Location (latitude, longitude, address) VALUES
(18.5204, 73.8567, 'Pune Railway Station'),
(18.5314, 73.8446, 'Shivajinagar, Pune'),
(18.4996, 73.8658, 'Koregaon Park, Pune');

INSERT INTO Emergency_Service (type, name, contact, availability) VALUES
('POLICE',    'Pune City Police HQ',    '100',        'AVAILABLE'),
('AMBULANCE', 'Pune Ambulance Service', '108',        'AVAILABLE'),
('NGO',       'iCall Women Helpline',   '9152987821', 'AVAILABLE');

INSERT INTO Police_Station  (service_id, station_name, area)
    VALUES (1, 'Pune City Police HQ', 'Shivajinagar');
INSERT INTO Ambulance       (service_id, vehicle_number, hospital_name)
    VALUES (2, 'MH12-AB-1234', 'Ruby Hall Clinic');
INSERT INTO NGO             (service_id, ngo_name, focus_area, website)
    VALUES (3, 'iCall', 'Mental Health & Women Safety', 'https://icallhelpline.org');

INSERT INTO Emergency_Contact (user_id, name, phone, relation) VALUES
(1, 'Rahul Sharma', '9123456789', 'Brother'),
(1, 'Meena Sharma', '9123456780', 'Mother'),
(2, 'Karan Mehta',  '9123456781', 'Father');

INSERT INTO Safety_Tips (title, category, description) VALUES
('Share your live location',     'Digital Safety',  'Always share your live location with a trusted contact when travelling alone at night.'),
('Trust your instincts',         'Personal Safety', 'If a situation feels unsafe, leave immediately. Your instincts are your best defence.'),
('Keep emergency numbers handy', 'Preparedness',    'Save 100 (Police), 108 (Ambulance) and womens helpline 1091 on speed dial.');

INSERT INTO Safety_Product (name, category, price, description, link) VALUES
('Personal Alarm Keychain', 'Self Defence', 299.00,  '130dB alarm to attract attention in emergencies', 'https://example.com/alarm'),
('Pepper Spray',            'Self Defence', 450.00,  'Legal-strength pepper spray with safety lock',    'https://example.com/spray'),
('GPS Tracker Watch',       'Tracking',     2999.00, 'Real-time GPS watch with SOS button',             'https://example.com/watch');
