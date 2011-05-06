CREATE TABLE user(first_name varchar(64), last_name varchar(64), rfid varchar(10), email varchar(255), twitter_handle varchar(255));
CREATE TABLE keg(keg_id int, beer varchar(64), brewery varchar(64), description varchar(256), tapped_date datetime, 
				 killed_date datetime, active boolean, image_path varchar(255));
CREATE TABLE pour(rfid varchar(10), keg_id int, pour_date date, volume_ounces int);
CREATE TABLE temperature(temperature int, temperature_date date);

INSERT INTO user(rfid, first_name, last_name, email, twitter_handle) VALUES('2312A4B540', 'Dylan', 'Carney', 'dcarney@gmail.com', '@_dcarney_');
INSERT INTO user(rfid, first_name, last_name, email, twitter_handle) VALUES('2312A4B541', 'Chris', 'Castle', 'crcastle@gmail.com', '@crc');
INSERT INTO user(rfid, first_name, last_name, email) VALUES('2312A4B542', 'Carl', 'Krauss', '');
INSERT INTO user(rfid, first_name, last_name, email, twitter_handle) VALUES('2312A4B543', 'Garrett', 'Patterson', 'garrett.patterson@vivaki.com', '@thegarrettp');

INSERT INTO keg(keg_id, beer, brewery, description, tapped_date, active, image_path) 
VALUES(1, 'Mannys Pale Ale', 'Georgetown Brewery', 'A solid pale ale, brewed in Seattle least-douchey neighborhood.', 
	   '2011-03-12 01:23:45.666', 'false', 'images/MannysPint3.gif');
INSERT INTO keg(keg_id, beer, brewery, description, tapped_date, active, image_path) 
	VALUES(2, 'Curveball Blonde', 'Pyramid Brewery', 'A summery blend of, of... hops and bubbles. --Garrett Patterson', 
		   '2011-04-22 13:23:45.666', 'true', 'images/curveball.jpg');
  
INSERT INTO temperature(temperature, temperature_date) VALUES (39, '2011-03-12 01:23:46.666');
INSERT INTO temperature(temperature, temperature_date) VALUES (39, '2011-03-12 01:23:47.666');
INSERT INTO temperature(temperature, temperature_date) VALUES (39, '2011-03-12 01:23:48.666');

INSERT INTO pour(rfid, keg_id, pour_date, volume_ounces) VALUES('2312A4B541', 1, '2011-03-12 01:23:46.666', 16);
INSERT INTO pour(rfid, keg_id, pour_date, volume_ounces) VALUES('2312A4B542', 1, '2011-03-12 01:23:47.666', 32);