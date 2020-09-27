DROP INDEX guest_name;
DROP INDEX crop_name;
DROP INDEX crop_count;

DROP TRIGGER interest_trig;
DROP SEQUENCE interest_seq;

DROP TABLE SECTOR_TYPE CASCADE CONSTRAINTS;
DROP TABLE SECTOR CASCADE CONSTRAINTS;
DROP TABLE AREA CASCADE CONSTRAINTS;
DROP TABLE CROP CASCADE CONSTRAINTS;
DROP TABLE IRRIGATION_DATA CASCADE CONSTRAINTS;
DROP TABLE LIVING_QUARTERS CASCADE CONSTRAINTS;
DROP TABLE LIVING_QUARTERS_TYPE CASCADE CONSTRAINTS;
DROP TABLE INVENTORY CASCADE CONSTRAINTS;
DROP TABLE GUEST CASCADE CONSTRAINTS;
DROP TABLE INTEREST CASCADE CONSTRAINTS;
DROP TABLE GUEST_INTEREST CASCADE CONSTRAINTS;


CREATE TABLE INTEREST (
    id             NUMBER (10) NOT NULL PRIMARY KEY,
    interest_name  VARCHAR2 (255) NOT NULL UNIQUE
);

CREATE SEQUENCE interest_seq START WITH 1;
CREATE OR REPLACE TRIGGER interest_trig 
BEFORE INSERT ON INTEREST 
FOR EACH ROW

BEGIN
  SELECT interest_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/


CREATE TABLE IRRIGATION_DATA (
    id      NUMBER (10) NOT NULL PRIMARY KEY,
    time    NUMBER (5, 2) NOT NULL,
    amount  NUMBER (10,1) NOT NULL
);

CREATE TABLE LIVING_QUARTERS_TYPE (
    id    NUMBER (10) NOT NULL PRIMARY KEY,
    name  VARCHAR2 (255) NOT NULL UNIQUE
);

CREATE TABLE SECTOR_TYPE (
    id    NUMBER (10) NOT NULL PRIMARY KEY,
    type  VARCHAR2(255) NOT NULL UNIQUE
);

CREATE TABLE SECTOR (
    id              NUMBER (10) NOT NULL PRIMARY KEY,
    Sector_Type_id  NUMBER (10) NOT NULL,
    CONSTRAINT sector_sector_type_fk FOREIGN KEY ( Sector_Type_id )
    REFERENCES SECTOR_TYPE ( id )
    ON DELETE CASCADE
);

CREATE TABLE AREA (
    id         NUMBER (10) NOT NULL PRIMARY KEY,
    Sector_id  NUMBER (10) NOT NULL,
    area_square NUMBER(10, 2) DEFAULT 0.4 CHECK (area_square >= 0.3), 
    CONSTRAINT area_sector_fk FOREIGN KEY ( Sector_id )
    REFERENCES SECTOR ( id )
    ON DELETE CASCADE 
);

CREATE TABLE CROP (
    id   NUMBER (10) NOT NULL PRIMARY KEY,
    name VARCHAR2 (255) NOT NULL,
    count NUMBER (10) NOT NULL CHECK(count >= 5),
    vegetation_period NUMBER (5) NOT NULL,
    harvesting_period DATE NOT NULL CHECK(extract(month from harvesting_period) <= 9),
    Area_id INTEGER NOT NULL,
    CONSTRAINT crop_area_fk FOREIGN KEY (Area_id) REFERENCES AREA (id)
    ON DELETE CASCADE,
    Irrigation_Data_id INTEGER NOT NULL,
    CONSTRAINT crop_irrigation_data_fk FOREIGN KEY (Irrigation_Data_id)
    REFERENCES IRRIGATION_DATA (id)
    ON DELETE CASCADE
);

CREATE TABLE INVENTORY (
    id           NUMBER (10) NOT NULL PRIMARY KEY,
    name         VARCHAR2(255) NOT NULL,
    price        NUMBER (10) NOT NULL,
    count        NUMBER (5) NOT NULL,
    Area_id NUMBER (10) NOT NULL,
    CONSTRAINT inventory_area_fk FOREIGN KEY (Area_id) REFERENCES AREA (id)
    ON DELETE CASCADE,
    Interest_id NUMBER (10) NOT NULL,
    CONSTRAINT inventory_interest_fk FOREIGN KEY (Interest_id) REFERENCES INTEREST (id)
    ON DELETE CASCADE
);

CREATE TABLE LIVING_QUARTERS (
    id                      NUMBER (10) NOT NULL PRIMARY KEY,
    bed_count               NUMBER (10) NOT NULL,
    square                  NUMBER (10, 2) NOT NULL,
    Area_id NUMBER (10) NOT NULL,
    CONSTRAINT quarters_area_fk FOREIGN KEY (Area_id) REFERENCES AREA (id)
    ON DELETE CASCADE,
    Living_Quarters_Type_id NUMBER (10) NOT NULL,
    CONSTRAINT quarters_type_fk FOREIGN KEY (Living_Quarters_Type_id)
    REFERENCES LIVING_QUARTERS_TYPE (id)
    ON DELETE CASCADE
);

CREATE TABLE GUEST (
    id          NUMBER (10) NOT NULL PRIMARY KEY,
    first_name  VARCHAR2(255) NOT NULL,
    last_name   VARCHAR2(255) NOT NULL,
    living_quarters_id NUMBER (10),
    CONSTRAINT guest_quarters_fk FOREIGN KEY (living_quarters_id) REFERENCES LIVING_QUARTERS (id)
    ON DELETE CASCADE
);

CREATE TABLE GUEST_INTEREST
(
    Guest_id NUMBER (10) NOT NULL REFERENCES GUEST,
    Interest_id NUMBER (10) NOT NULL REFERENCES INTEREST,
    PRIMARY KEY (Guest_id, Interest_id)
);

CREATE INDEX guest_name on GUEST(first_name, last_name);
CREATE UNIQUE INDEX  crop_name on CROP(name);
CREATE INDEX crop_count on CROP(count) REVERSE;

INSERT ALL
  INTO SECTOR_TYPE (id, type) VALUES (1, 'хозяйственный')
  INTO SECTOR_TYPE (id, type) VALUES (2, 'жилищный')
  INTO SECTOR_TYPE (id, type) VALUES (3, 'рекреационный')
SELECT * FROM dual;

INSERT ALL
 INTO SECTOR (id, Sector_Type_id) VALUES (1, 1)
 INTO SECTOR (id, Sector_Type_id) VALUES (2, 2)
 INTO SECTOR (id, Sector_Type_id) VALUES (3, 3)
SELECT * FROM dual;

INSERT ALL
  INTO INTEREST (interest_name) VALUES ('шашки')
  INTO INTEREST (interest_name) VALUES ('шахматы')
  INTO INTEREST (interest_name) VALUES ('футбол')
SELECT * FROM dual;

INSERT ALL
 INTO AREA (id, Sector_id) VALUES (1, 1)
 INTO AREA (id, Sector_id) VALUES (2, 1)
 INTO AREA (id, Sector_id) VALUES (3, 2)
 INTO AREA (id, Sector_id) VALUES (4, 3)
SELECT * FROM dual;

INSERT ALL
  INTO IRRIGATION_DATA (id, time, amount) VALUES (1, 5, 15)
  INTO IRRIGATION_DATA (id, time, amount) VALUES (2, 8, 20)
  INTO IRRIGATION_DATA (id, time, amount) VALUES (3, 3, 30)
SELECT * FROM dual;

INSERT ALL
  INTO LIVING_QUARTERS_TYPE (id, name) VALUES (1, 'комната')
  INTO LIVING_QUARTERS_TYPE (id, name) VALUES (2, 'коттедж')
  INTO LIVING_QUARTERS_TYPE (id, name) VALUES (3, 'отель')
SELECT * FROM dual;

INSERT ALL
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (1, 1, 16, 3, 1)
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (2, 1, 30, 3, 1)
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (3, 2, 25, 3, 1)
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (4, 3, 30, 3, 1)
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (5, 8, 150, 3, 2)
 INTO LIVING_QUARTERS (id, bed_count, square, Area_id, Living_Quarters_Type_id) VALUES (6, 3, 70, 3, 3)
SELECT * FROM dual;

INSERT ALL
 INTO GUEST (id, first_name, last_name, living_quarters_id) VALUES (1, 'Иван', 'Иванов', 3)
 INTO GUEST (id, first_name, last_name, living_quarters_id) VALUES (2, 'Петр', 'Петров', 2) 
 INTO GUEST (id, first_name, last_name, living_quarters_id) VALUES (3, 'Василий', 'Сидоров', 3)
 INTO GUEST (id, first_name, last_name, living_quarters_id) VALUES (4, 'Джон', 'Брэди', 1)
SELECT * FROM dual;

INSERT ALL
 INTO GUEST_INTEREST (Guest_id, Interest_id) VALUES (1, 1)
 INTO GUEST_INTEREST (Guest_id, Interest_id) VALUES (1, 3) 
 INTO GUEST_INTEREST (Guest_id, Interest_id) VALUES (2, 2)
 INTO GUEST_INTEREST (Guest_id, Interest_id) VALUES (4, 2)
SELECT * FROM dual;

INSERT ALL
 INTO CROP (id, name, count, vegetation_period, harvesting_period, Area_id, Irrigation_Data_id) VALUES (1, 'Помидор', 50, 100, TO_DATE('2003/04/09 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),  1, 1)
 INTO CROP (id, name, count, vegetation_period, harvesting_period, Area_id, Irrigation_Data_id) VALUES (2, 'Тыква', 100, 110, TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),  1, 2)
 INTO CROP (id, name, count, vegetation_period, harvesting_period, Area_id, Irrigation_Data_id) VALUES (3, 'Арбуз', 70, 105, TO_DATE('2003/05/15 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),  1, 3)
SELECT * FROM dual;

INSERT ALL
 INTO INVENTORY (id, name, price, count, Area_id, Interest_id) VALUES (1, 'шахматная доска', 8, 50, 3, 2)
 INTO INVENTORY (id, name, price, count, Area_id, Interest_id) VALUES (2, 'набор фигурок шахмат', 25, 20, 3, 2)
 INTO INVENTORY (id, name, price, count, Area_id, Interest_id) VALUES (3, 'мяч футбольный', 160, 20, 3, 3)
 INTO INVENTORY (id, name, price, count, Area_id, Interest_id) VALUES (4, 'перчатки вратарские', 2, 20, 3, 3)
 INTO INVENTORY (id, name, price, count, Area_id, Interest_id) VALUES (5, 'доска для шашек', 10, 20, 3, 1)
SELECT * FROM dual;