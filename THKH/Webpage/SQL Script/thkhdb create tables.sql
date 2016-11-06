--http://stackoverflow.com/questions/7770924/how-to-use-output-parameter-in-stored-procedure This explains how to read from the output from stored procedures
-- To store Visitor Registration Data 
USE master;   

IF EXISTS(SELECT * from sys.databases WHERE name='thkhdb')  
BEGIN  
	DECLARE @DatabaseName nvarchar(50)
	SET @DatabaseName = 'thkhdb'

	DECLARE @SQL varchar(max)

	SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
	FROM MASTER..SysProcesses
	WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId
    
	SELECT @SQL 
	EXEC(@SQL)

	DROP DATABASE thkhdb;  
END 

GO
CREATE DATABASE thkhdb; 

GO
USE thkhdb; 
 
-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visitors

CREATE TABLE visitor 
(visitor_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Changed to self incremental value 
firstName VARCHAR(200) NOT NULL, 
lastName VARCHAR(200), 
nric VARCHAR(100) NOT NULL, 
address VARCHAR(300), 
postalCode INT NOT NULL, 
homeTel VARCHAR(100), -- Visitors may not be from Singapore so no +65 
altTel VARCHAR(100), 
mobTel VARCHAR(100), 
email VARCHAR(200), 
sex CHAR(50) NOT NULL, 
nationality VARCHAR(100), 
dateOfBirth DATE NOT NULL, 
age INT, 
race VARCHAR(150), 
dateCreated DATETIME, 
dateUpdated DATETIME, 
createdBy VARCHAR(100)); -- Logged in staff_id or null if self-register 
 
 
--------------------------------------------------------------------------------------------------------------------------------------------------- To Store Staff Data 
CREATE TABLE staff 
(staff_id VARCHAR(50) PRIMARY KEY NOT NULL, 
firstName VARCHAR(200) NOT NULL, 
lastName VARCHAR(200) NOT NULL, 
nric VARCHAR(100) NOT NULL, 
address VARCHAR(300) NOT NULL, 
postalCode INT NOT NULL, 
homeTel VARCHAR(100) NOT NULL, 
altTel VARCHAR(100), 
mobTel VARCHAR(100) NOT NULL, 
email VARCHAR(200) NOT NULL, 
sex CHAR(50) NOT NULL, 
nationality VARCHAR(100) NOT NULL, 
dateOfBirth DATE NOT NULL, 
age INT NOT NULL, 
race VARCHAR(150) NOT NULL, 
passwordHash BINARY(64) NOT NULL, -- Hash it With SHA2-512 and add salt to further pad with randomization bits. 
salt UNIQUEIDENTIFIER , 
permission INT NOT NULL, -- Access Control Level 
position VARCHAR(100) NOT NULL, -- Doctor, Nurse, Admin.... 
dateCreated DATETIME NOT NULL, 
dateUpdated DATETIME NOT NULL, 
createdBy VARCHAR(100)); -- Logged in Admin_ID 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Checkpoint Locations 
CREATE TABLE locations 
(lid INT PRIMARY KEY NOT NULL, 
locationName VARCHAR(400) NOT NULL, 
activated INT NOT NULL); 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Visit Details 
CREATE TABLE visit_details 
(visit_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
cicoid INT, -- NOT NULL Initially 
visitor_id INT, 
visitTime DATETIME, --Patient can request for a visit time? Yes. Timeouts will occur if the patient is late by 15 mins for now 
wingNo INT, 
wardNo INT, 
cubicleNo INT, -- This point of time ward is the best we got  
bedNo INT, 
-- visit_status VARCHAR(50) NOT NULL, -- Pending, Rejected, Waitlist, Approved -- Registration will not be vetted.  
-- validatedBy VARCHAR(100) NOT NULL, -- Logged in staff_id 
dateCreated DATETIME 
CONSTRAINT FK1 FOREIGN KEY (visitor_id) REFERENCES thkhdb.dbo.visitor(visitor_id)); 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Check-in Details 
CREATE TABLE check_in_out 
(cicoid INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
nric VARCHAR(100) NOT NULL, 
temperature VARCHAR(100) NOT NULL, 
staff_id INT NOT NULL, 
visit_id INT NOT NULL, 
checkinlid INT NOT NULL, -- Can be 1=Entrance, 2=Ward 1 & 4=Exit 
checkinTime DATETIME NOT NULL, 
checkoutlid INT, 
checkoutTime DATETIME); 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Movement Details 
CREATE TABLE movementTable 
(moveid INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
nric VARCHAR(100) NOT NULL, 
cicoid INT NOT NULL, 
date DATETIME NOT NULL,
checkpointtimeid VARCHAR(500) NOT NULL); -- stored in the following format [timestamp]:LID 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question IDs
CREATE TABLE form_qns
(qnid INT PRIMARY KEY NOT NULL,
question VARCHAR(MAX) NOT NULL,
optionstype INT NOT NULL);
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Option Values 
CREATE TABLE form_qns_options 
(qnoptid INT PRIMARY KEY NOT NULL, 
qnid INT NOT NULL, 
optionvalue VARCHAR(400) NOT NULL); 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Answers 
CREATE TABLE dbo.form_ans 
(ansid INT PRIMARY KEY NOT NULL, 
qnid INT NOT NULL, 
visitid INT NOT NULL, 
answer VARCHAR(1000) NOT NULL); 
 
