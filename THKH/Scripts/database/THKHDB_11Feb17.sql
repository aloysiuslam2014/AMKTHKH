-- http://stackoverflow.com/questions/1260952/how-to-execute-a-stored-procedure-within-c-sharp-program For running stored procedures in C#  
-- I declare this region… mine! -- 
-- http://stackoverflow.com/questions/7770924/how-to-use-output-parameter-in-stored-procedure This explains how to read from the output from stored procedures 
-- To store Visitor Registration Data  


--USE [master]
--GO
--EXEC master.dbo.sp_addlinkedserver @server = N'150.200.1.227', @srvproduct=N'SQL Server'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'collation compatible', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'data access', @optvalue=N'true'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'dist', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'pub', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'rpc', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'rpc out', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'sub', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'connect timeout', @optvalue=N'0'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'collation name', @optvalue=null

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'lazy schema validation', @optvalue=N'false'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'query timeout', @optvalue=N'0'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'use remote collation', @optvalue=N'true'

--GO
--EXEC master.dbo.sp_serveroption @server=N'150.200.1.227', @optname=N'remote proc transaction promotion', @optvalue=N'true'

--GO
--USE [master]

--GO
--EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'150.200.1.227', @locallogin = NULL , @useself = N'False', @rmtuser = N'triage', @rmtpassword = N'triage'

--GO

USE master;     

IF EXISTS(SELECT * from sys.databases WHERE name='thkhdb')      
--IF EXISTS(SELECT * from sys.databases WHERE name='stepwise')    
BEGIN    
	DECLARE @DatabaseName NVARCHAR(50)  
	--SET @DatabaseName = 'stepwise' 
	SET @DatabaseName = 'thkhdb'  
  
	DECLARE @SQL varchar(max)  
  	
	SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + CONVERT(VARCHAR, SPId) + ';'  
	FROM MASTER..SysProcesses  
	WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId  
      
	SELECT @SQL   
	EXEC(@SQL)  
 	
	--DROP DATABASE stepwise;
	DROP DATABASE thkhdb;   
END

GO
--CREATE DATABASE stepwise;   
CREATE DATABASE thkhdb;   
  
GO
USE thkhdb;  
--USE stepwise;  


---------------------------------------------------------------------------------------------------------------------------------------------------- To store the format of Pass 
GO
CREATE TABLE PASS_FORMAT
(
	passFormat VARCHAR(MAX) NOT NULL
); 


-------------------------------------------------------------------------------------------------------
GO
CREATE TABLE MASTER_CONFIG  
(
  lowerTempLimit VARCHAR(15) NOT NULL,
  upperTempLimit VARCHAR(15) NOT NULL,
  warnTemp VARCHAR(15) NOT NULL,
  lowerTimeLimit VARCHAR(15) NOT NULL,
  upperTimeLimit VARCHAR(15) NOT NULL,
  visitLimit INT NOT NULL,
  dateUpdated DATETIME NOT NULL,
  updatedBy VARCHAR(100) NOT NULL
);



--------------------------------------------------------------------------------------------------------------------------------------------------- To Store Staff Data  
GO
CREATE TABLE STAFF  
(
	email VARCHAR(200) PRIMARY KEY NOT NULL,  
	firstName VARCHAR(50) NOT NULL,  
	lastName VARCHAR(50) NOT NULL,  
	nric VARCHAR(15) NOT NULL,  
	address VARCHAR(200) NOT NULL,  
	postalCode INT NOT NULL,  
	homeTel VARCHAR(20) NOT NULL,  
	altTel VARCHAR(20),  
	mobTel VARCHAR(20) NOT NULL,   
	sex CHAR(5) NOT NULL,  
	nationality VARCHAR(500) NOT NULL,  
	dateOfBirth DATE NOT NULL,  
	--age INT NOT NULL,  
	--race VARCHAR(50) NOT NULL,  
	passwordHash BINARY(64) NOT NULL, -- Hash it With SHA2-512 and add salt to further pad with randomization bits.  
	salt UNIQUEIDENTIFIER ,  
	permission INT NOT NULL, 
	accessProfile VARCHAR(100) NOT NULL,
	position VARCHAR(50) NOT NULL,  
	dateCreated DATETIME NOT NULL,  
	dateUpdated DATETIME NOT NULL,  
	createdBy VARCHAR(100)
);
  

------------------------------------------------------------------------------------------------------- Table to store Access Profile
GO
CREATE TABLE ACCESS_PROFILE  
(
  profileName VARCHAR(100) NOT NULL,
  accessRights VARCHAR(15) NOT NULL,
  dateUpdated DATETIME NOT NULL,
  updatedBy VARCHAR(100) NOT NULL
);


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient  
GO
CREATE TABLE ACCESS_RIGHT
(
	accessID INT PRIMARY KEY NOT NULL, 
	accessName VARCHAR(100) NOT NULL
); 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient  
GO
CREATE TABLE PATIENT 
(
	-- StartDate (DATETIME) & EndDate (DATETIME) to be considered
	bedNo INT NOT NULL, 
	nric VARCHAR(15) NOT NULL, 
	patientFullName VARCHAR(150) NOT NULL,
	startDate DATETIME,
	endDate DATETIME
	CONSTRAINT PK_PATIENT PRIMARY KEY (bedno, startDate)
); 

    
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Answers  
GO
CREATE TABLE QUESTIONAIRE_QNS 
(
	QQ_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	question VARCHAR(1000) NOT NULL, 
	qnsType VARCHAR(100) NOT NULL,  
	qnsValue VARCHAR(1000) NOT NULL,
	startDate DATETIME NOT NULL,
	endDate DATETIME NULL
); 


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Option Values  
GO
CREATE TABLE QUESTIONAIRE_QNS_LIST  
(
	Q_QuestionListID VARCHAR(100) PRIMARY KEY NOT NULL,  
	Q_Order VARCHAR(100),  -- List of QQ_IDs from QUESTIONAIRE_QNS. Format example: '1,3,4,2,5'  
	Q_Active INT NOT NULL,  -- 1 == Active, 0 == Inactive
	startDate DATETIME NOT NULL,
	endDate DATETIME NULL
);  


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question IDs 
GO
CREATE TABLE QUESTIONAIRE_ANS
(
	QA_ID VARCHAR(100) PRIMARY KEY NOT NULL, 
	Q_QuestionListID VARCHAR(100) NOT NULL, 
	QA_JSON NVARCHAR(MAX) NOT NULL,
	FOREIGN KEY (Q_QuestionListID) REFERENCES QUESTIONAIRE_QNS_LIST(Q_QuestionListID)
); 


-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visitors 
GO
CREATE TABLE VISITOR_PROFILE  
(
	nric VARCHAR(15) NOT NULL,
	fullName VARCHAR(150) NOT NULL,    
	gender CHAR(5) NOT NULL,  
	nationality VARCHAR(300) NOT NULL,  
	dateOfBirth DATE NOT NULL,  
	--race VARCHAR(50) NOT NULL, 
	mobileTel VARCHAR(20),  
	--homeTel VARCHAR(20),
	--altTel VARCHAR(20),
	--email VARCHAR(200),   
	homeAddress VARCHAR(200) NOT NULL,
	postalCode INT NOT NULL, 
	time_stamp DATETIME NOT NULL,  
	confirm INT NOT NULL,
	amend INT NOT NULL
);


--------------------------------------------------------------------------------------------------------------------------------------------------------------- Table to store Temperature
GO
CREATE TABLE TEMP_RANGE  
(
  lowerLimit VARCHAR(15) NOT NULL,
  upperLimit VARCHAR(15) NOT NULL,
  dateUpdated DATETIME NOT NULL,
  updatedBy VARCHAR(100) NOT NULL
);


-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visit
GO
CREATE TABLE VISIT
(
	visitRequestTime DATETIME NOT NULL, 
	--patientNric VARCHAR(15),  
	visitorNric VARCHAR(15) NOT NULL,  
	--patientFullName VARCHAR(150), 
	purpose VARCHAR(1000) NOT NULL,
	reason VARCHAR(1000),
	visitLocation VARCHAR(300),    
	bedNo VARCHAR(MAX),  
	QaID VARCHAR(100) NOT NULL,
	remarks VARCHAR(MAX),
	confirm INT   
	FOREIGN KEY (QaID) REFERENCES QUESTIONAIRE_ANS(QA_ID),
	CONSTRAINT PK_VISIT PRIMARY KEY (visitRequestTime, visitorNric)
);


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Check-in Details  
GO
CREATE TABLE CHECK_IN
(
	nric VARCHAR(15) NOT NULL,  
	visitActualTime DATETIME NOT NULL, 
	temperature VARCHAR(10) NOT NULL,  
	staffEmail VARCHAR(200) NOT NULL, 
	--FOREIGN KEY (nric) REFERENCES VISITOR_PROFILE(nric),
	FOREIGN KEY (staffEmail) REFERENCES STAFF(email),
	CONSTRAINT PK_CHECK_IN PRIMARY KEY (visitActualTime, nric) 
);  
   
  
----------------------------------------------------------------------------------------------------------------------------------------------------  
GO
CREATE TABLE TERMINAL
(
	terminalID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,    
	tName VARCHAR(100) NOT NULL, 
	--bedNoList VARCHAR(100) NOT NULL,
	activated INT NOT NULL,
	tControl INT NOT NULL,
	startDate DATETIME NOT NULL,
	endDate DATETIME
);


----------------------------------------------------------------------------------------------------------------------------------------------------  
GO
CREATE TABLE TERMINAL_BED
(
	terminalID INT PRIMARY KEY NOT NULL,    
	bedNoList VARCHAR(MAX) NOT NULL,
	FOREIGN KEY (terminalID) REFERENCES TERMINAL(terminalID),
);


----------------------------------------------------------------------------------------------------------------------------------------------------  
GO
CREATE TABLE TERMINAL_LINK
(
	terminalID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,    
	links VARCHAR(100) NOT NULL
	FOREIGN KEY (terminalID) REFERENCES TERMINAL(terminalID),
);


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Movement Details  
GO
CREATE TABLE MOVEMENT
(
	nric VARCHAR(15) NOT NULL,  
	visitActualTime DATETIME NOT NULL, 
	locationID INT, 
	locationTime DATETIME
	--mStatus INT
	FOREIGN KEY (locationID) REFERENCES TERMINAL(terminalID),
	CONSTRAINT PK_MOVEMENT PRIMARY KEY (visitActualTime, nric, locationTime)
); -- stored in the following format [timestamp]:LID  


----------------------------------------------------------------------------------------------------------------------------------------------------  
GO
CREATE TABLE KNOWLEDGE_DATA
(
	k_ID VARCHAR(100) PRIMARY KEY  NOT NULL,    
	k_data VARCHAR(MAX) NOT NULL, 
	uploadTime DATETIME NOT NULL
);


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for adding user and logging in  

/****** Object:  StoredProcedure [dbo].[INSERT INTO  - staff]    Script Date: 10/30/2016 3:38:44 PM ******/  
GO
SET ANSI_NULLS ON  

GO
SET QUOTED_IDENTIFIER ON  


------------------------------------------------------------------------------------------------------------ Function for Spliting String
GO
CREATE FUNCTION [dbo].[FUNC_SPLIT] 
(   
	@DelimitedString VARCHAR(8000),
    @Delimiter VARCHAR(100) 
)

RETURNS @tblArray TABLE
(
    Element VARCHAR(1000)
)

AS
BEGIN
DECLARE @Index SMALLINT,
		@Start SMALLINT,
		@DelSize SMALLINT

	SET @DelSize = LEN(@Delimiter)

	WHILE LEN(@DelimitedString) > 0
	BEGIN
		SET @Index = CHARINDEX(@Delimiter, @DelimitedString)

		IF @Index = 0
		BEGIN
			INSERT INTO @tblArray (Element)
			VALUES (LTRIM(RTRIM(@DelimitedString)))

			BREAK
		END
        
		ELSE
		BEGIN
			INSERT INTO @tblArray (Element)
			VALUES(LTRIM(RTRIM(SUBSTRING(@DelimitedString, 1,@Index - 1))))

			SET @Start = @Index + @DelSize
			SET @DelimitedString = SUBSTRING(@DelimitedString, @Start , LEN(@DelimitedString) - @Start + 1)

		END
	END

	RETURN
END


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Terminal
GO
CREATE PROCEDURE [dbo].[TEST_TERMINAL] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		-- Terminal_ID == 2 (FIXED VARIABLE)
		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('HOSPITAL ENTRANCE', 1, 1, '2016-06-06 00:00', NULL)

		-- Terminal_ID == 3 (FIXED VARIABLE)
		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('HOSPITAL EXIT', 1, 1, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Ward 1', 1, 1, '2016-01-01 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (4, '1101,1202,1303')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Ward 2', 1, 1, '2016-03-03 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (5, '1104,3205,5306')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Ward 3', 1, 1, '2016-06-06 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (6, '5107,5208,5309')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Ward 4', 1, 1, '2016-06-06 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (7, '5108,5508,5509')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Entrance: Ambulance Bay', 1, 1, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Cafeteria', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Khoo Teck Puat Clinic', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Pharmacy', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Healing Hub', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('Community Hub Centre', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('B. Braun Dialysis Centre', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('NHG Diagnostics', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('TCM Medical Centre', 1, 0, '2016-06-06 00:00', NULL)
    
	END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Terminal
GO
CREATE PROCEDURE [dbo].[TEST_MOVEMENT] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-10-10 07:00', 4, '2016-10-10 07:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-10-10 07:00', 1, '2016-10-10 08:00')
		---------------------------------------------------------------------- Exited

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-10-11 09:00', 4, '2016-10-11 09:05')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-10-11 09:00', 1, '2016-10-11 10:15')
		---------------------------------------------------------------------- Exited

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-11-20 20:00', 4, '2016-11-20 20:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-11-20 20:00', 1, '2016-11-20 21:07')
		---------------------------------------------------------------------- Exited

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 14:00', 4, '2016-12-29 14:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 14:00', 1, '2016-12-29 15:30')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 17:00', 5, '2016-12-29 17:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 17:00', 1, '2016-12-29 18:20')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 21:00', 6, '2016-12-29 21:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 21:00', 1, '2016-12-29 22:35')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-29 20:00', 4, '2016-12-29 19:50')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-29 20:00', 1, '2016-12-29 21:00')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 17:00', 4, '2016-12-29 17:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 17:00', 1, '2016-12-29 19:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 23:00', 5, '2016-12-29 23:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 23:00', 1, '2016-12-29 23:31')


	---------------------------NEXT MOVEMENT PERIOD---------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 14:30', 4, '2016-12-30 14:45')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 14:30', 1, '2016-12-30 15:50')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 16:00', 4, '2016-12-30 16:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 16:00', 1, '2016-12-30 16:50')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 18:00', 5, '2016-12-30 18:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 18:00', 1, '2016-12-30 19:12')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 20:00', 6, '2016-12-30 20:00')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 20:00', 1, '2016-12-30 21:12')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-30 20:00', 4, '2016-12-30 19:50')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-30 20:00', 1, '2016-12-30 20:45')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 17:00', 4, '2016-12-30 17:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 17:00', 1, '2016-12-30 18:11')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 19:00', 5, '2016-12-30 19:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 19:00', 1, '2016-12-30 21:31')


	---------------------------NEXT MOVEMENT PERIOD---------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 14:00', 4, '2016-12-31 14:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 14:00', 1, '2016-12-31 15:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 17:00', 5, '2016-12-31 17:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 17:00', 1, '2016-12-31 18:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 19:00', 6, '2016-12-31 18:57')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 19:00', 1, '2016-12-31 20:00')
    END 
END; 


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[TEST_CREATE_STAFF]      
   @pCreatedBy        VARCHAR(100) = 'MASTER',  
    @responseMessage   VARCHAR(250) OUTPUT  
  
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE @salt UNIQUEIDENTIFIER=NEWID()  
    
  BEGIN TRY  
        INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Shahid', 'Abdul', 'S12345', '417 Pasir Ris', 123417, '999', '999', '999', 'abdulsr.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1991-01-01', HASHBYTES('SHA2_512', '123'),  123456 , 'Admin', 'Doctor', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Aloysius', 'Lam', 'S9332934A', 'SMU', 123417, '999', '999', '999', 'aloysiuslam.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Christopher', 'Teo', 'S9332464A', 'SMU', 123417, '999', '999', '999', 'mjteo.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Jason', 'Wu', 'S9122934A', 'SMU', 123417, '999', '999', '999', 'jasonwu.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Zheng Yuan', 'Yu', 'S9112934A', 'SMU', 123417, '999', '999', '999', 'zyyu.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Friedemann', 'Ang', 'S9022934A', 'SMU', 123417, '999', '999', '999', 'zkang.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)
 	
	INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Edy', 'Chandra', 'S2138934A', 'SMU', 123417, '999', '999', '999', 'edy@amk.org.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  
  
       SET @responseMessage='Success'   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage=ERROR_MESSAGE()   
    END CATCH  
END;


----------------------------------------------------------------------------- Procedures for creating Permissions
GO
CREATE PROCEDURE [dbo].[TEST_PERMISSIONS] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (1,'Registration')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (2,'Form Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (4,'User Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (5,'Pass Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (3,'Terminal Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (6,'Contact Tracing')
    END 
END; 


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[TEST_CREATE_ADMIN]      
 	@pCreatedBy        VARCHAR(100) = 'MASTER',  
    @responseMessage   VARCHAR(250) OUTPUT  
  
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE @salt UNIQUEIDENTIFIER=NEWID()  
    
	BEGIN TRY  
        INSERT INTO staff (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
							dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Admin', 'Admin', 'S12345', 'THK Hospital', 123417, '999', '999', '999', 'admin@thk.com.sg', 'M', 'SINGAPOREAN', 
				'1991-01-01', HASHBYTES('SHA2_512', 'passadmin1'),  123456, 'Admin', 'Doctor', GETDATE(), GETDATE(), @pCreatedBy)  

       SET @responseMessage='Success'   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage=ERROR_MESSAGE()   
    END CATCH  
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Visitor
GO
CREATE PROCEDURE [dbo].[TEST_CHECK_IN] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2016-12-29 14:00', '36.7', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2016-12-30 14:30', '36.7', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2016-12-30 16:00', '36.7', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2016-12-31 14:00', '36.7', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2017-01-26 20:00', '36.7', 'asd@smu.edu.sg')
 		
		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S789', '2016-12-29 20:00', '36.9', 'asd@smu.edu.sg')
    END 
END;  


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
GO
CREATE PROCEDURE [dbo].[TEST_PATIENT] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
		VALUES (1101, 'S9876543E', 'Benny Tan', '2016-07-11 09:00', '2020-01-01 00:00')

		INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
		VALUES (1104, 'S2468269F', 'Nicholas Lim', '2016-08-14 09:00', '2020-01-01 00:00')
    END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Visitor
GO
CREATE PROCEDURE [dbo].[TEST_VISITOR_PROFILE] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S123', 'Jason', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 TAMPINES ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S456', 'Aloysius', 'M', 'SINGAPOREAN', '1990-10-11','987654321', 
				'BLK 476 WOODLANDS ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S789', 'Chris', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 BEDOK ST 44', 913476, GETDATE(), 0, 1)
		
		
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S246', 'Friedemann', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 JURONG ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S629', 'ZhengYuan', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 KEMBANGAN ST 44', 913476, GETDATE(), 0, 1)
  
    END 
END;   


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
GO
CREATE PROCEDURE [dbo].[TEST_VISIT] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO VISIT
		VALUES ('2016-12-29 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2016-12-30 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2016-12-30 16:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2016-12-31 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)
		
		INSERT INTO VISIT
		VALUES ('2017-01-26 20:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)  
    END 
END;

-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
GO
CREATE PROCEDURE [dbo].[TEST_QUESTIONNAIRE_ANS] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO QUESTIONAIRE_ANS
		VALUES ('FIRST_ANS_ID', 'First', 'JSON ANSWERS FOR QUESTIONNARIE (First)')
  
    END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for TESTING
GO
CREATE PROCEDURE [dbo].[TEST_QUESTIONAIRE_QNS] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Which country have you visited over the last 3 months? (If no, please select None)', 'ddList', 'None,Malaysia,USA,China,Russia', SYSDATETIME(), NULL)
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Were you diagnosed with fever over the last 3 days?', 'radio', 'Yes,No', SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '', SYSDATETIME(), NULL)

		-------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Which universe planet have you visited over the last 6 months? (If no, please select None)', 'ddList', 'None,Jupiter,Mars,Mercury,Saturn,Venus', SYSDATETIME(), NULL)
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Were you diagnosed with Alien-Virus over the last 3 days?', 'radio', 'Yes,No', SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '', SYSDATETIME(), NULL)

		-------------------------------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Which country have you visited over the last 3 months? (If no, please select None)', 'ddList', 'None,Malaysia,USA,China,Russia', SYSDATETIME(), NULL)
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Were you diagnosed with fever over the last 3 days?', 'radio', 'Yes,No', SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '', SYSDATETIME(), NULL)

    END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for TESTING
GO
CREATE PROCEDURE [dbo].[TEST_QUESTIONAIRE_QNS_LIST] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('First', '3,1,2', 1, SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('Second', '5,6,4', 0, SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('Third', '7,9,8', 0, '2016-01-01 00:00', SYSDATETIME())
    END 
END; 


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[CREATE_STAFF]     
	@pEmail          VARCHAR(200), 
  	@pPassword        VARCHAR(64),  
  	@pFirstName        VARCHAR(50),   
  	@pLastName        VARCHAR(50),  
 	@pNric          VARCHAR(15),  
 	@pAddress        VARCHAR(200),  
 	@pPostal        INT,  
 	@pHomeTel        VARCHAR(20),  
 	@pAltTel        VARCHAR(20) = NULL,  
 	@pMobileTel        VARCHAR(20),   
 	@pSex          CHAR(5) = 'M',  
 	@pNationality      VARCHAR(300) = 'Singaporean',  
 	@pDOB          DATE = '09/08/1965',  
 	--@pAge          INT,  
 	--@pRace          VARCHAR(50),  
 	@pPermission      INT = 1,
	@pAccessProfile		VARCHAR(100), 
 	@pPostion        VARCHAR(100) = 'Nurse',  
  --@pDateCreated      DATETIME,  
  --@pDateUpdated      DATETIME,  
 	@pCreatedBy        VARCHAR(100) = 'MASTER',  
    @responseMessage   NVARCHAR(250) OUTPUT  
  
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE @salt UNIQUEIDENTIFIER=NEWID()  
    
	BEGIN TRY  
        INSERT INTO staff (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
							dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES(@pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel, @pMobileTel, @pEmail, @pSex, @pNationality, 
				@pDOB, HASHBYTES('SHA2_512', @pPassword),  @pPermission, @pAccessProfile,@pPostion, GETDATE(), GETDATE(), @pCreatedBy)  
  
       SET @responseMessage='Success'   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage=ERROR_MESSAGE()   
    END CATCH  
END;
  
---------------------------------------------------------------------------------------------------------------------------------------------------- Validate Staff Login  

/****** Object:  StoredProcedure [dbo].[SELECT FROM - login]    Script Date: 30/10/2016 15:48:06 ******/  
GO
SET ANSI_NULLS ON  

GO
SET QUOTED_IDENTIFIER ON  

GO
CREATE PROCEDURE [dbo].[LOGIN] --You can use a User-defined function or a view instead of a procedure.  
    @pEmail VARCHAR(200),  
    @pPassword VARBINARY(64)  
       
AS  
BEGIN  
    SET NOCOUNT ON  

    SELECT * FROM dbo.staff 
	WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pEmail 
	AND PasswordHash = @pPassword      
END;  


------------------------------------------------------------------------------------------------------------------------ Procedures for checking if Staff exists 
GO
CREATE PROCEDURE [dbo].[CHECK_STAFF_EXISTS]  
@pStaff_Nric VARCHAR(10),  
@returnValue VARCHAR(30) OUTPUT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF NOT EXISTS (SELECT nric FROM STAFF WHERE nric = @pStaff_Nric) 			 
	BEGIN
		SET @responseMessage = 1
		SET @returnValue = 'Staff not found'
	END

    ELSE  
		SET @responseMessage = 0  
		SET @returnValue = 'Staff found'
END; 


------------------------------------------------------------------------------------------------ Procedure for retrieving User's permission access
GO
CREATE PROCEDURE [dbo].[GET_USER_PERMISSIONS] 
@responseMessage VARCHAR(500) OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  

  IF (EXISTS (SELECT * FROM dbo.ACCESS_RIGHT))  
  BEGIN
    SELECT * FROM dbo.ACCESS_RIGHT
    SET @responseMessage = '1'
  END
  ELSE
    SET @responseMessage = '0'
END;


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Updating Access Rights for staffs 
GO
CREATE PROCEDURE [dbo].[UPDATE_STAFF_ACCESS_RIGHT]  
@pStaff_Email VARCHAR(200),  
@pAccess_ID INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF EXISTS (SELECT email FROM STAFF WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaff_Email) 			 
	BEGIN
		IF EXISTS (SELECT accessID FROM ACCESS_RIGHT WHERE accessID = @pAccess_ID)
		BEGIN TRY
			UPDATE STAFF
			SET permission = @pAccess_ID
			WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaff_Email

			SET @responseMessage = 1
		END TRY 

		BEGIN CATCH
			SET @responseMessage = 0
		END CATCH

		ELSE  
      		SET @responseMessage = 0 
	END

    ELSE  
       SET @responseMessage = 0  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Adding Access Rights
GO
CREATE PROCEDURE [dbo].[ADD_ACCESS_RIGHT]  
@pAccess_ID INT,  
@pAccess_Name VARCHAR(100),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF NOT EXISTS (SELECT accessID FROM ACCESS_RIGHT WHERE accessID = @pAccess_ID) 			 
	BEGIN TRY
		INSERT INTO ACCESS_RIGHT (accessID, accessName)
		VALUES (@pAccess_ID, @pAccess_Name)

		SET @responseMessage = 1
	END  TRY
	BEGIN CATCH
		SET @responseMessage = 0
	END CATCH

    ELSE  
       SET @responseMessage = 0  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Updating Access Rights
GO
CREATE PROCEDURE [dbo].[UPDATE_ACCESS_RIGHT]  
@pAccess_ID INT,  
@pAccess_Name VARCHAR(100),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF EXISTS (SELECT accessID FROM ACCESS_RIGHT WHERE accessID = @pAccess_ID) 			 
	BEGIN TRY
		UPDATE ACCESS_RIGHT
		SET accessName = @pAccess_Name
		WHERE accessID = @pAccess_ID

		SET @responseMessage = 1
	END  TRY
	BEGIN CATCH
		SET @responseMessage = 0
	END CATCH

    ELSE  
       SET @responseMessage = 0  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Deleting Access Rights
GO
CREATE PROCEDURE [dbo].[REMOVE_ACCESS_RIGHT]  
@pAccess_ID INT,  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF EXISTS (SELECT accessID FROM ACCESS_RIGHT WHERE accessID = @pAccess_ID) 			 
	BEGIN TRY
		DELETE ACCESS_RIGHT
		WHERE accessID = @pAccess_ID

		SET @responseMessage = 1
	END  TRY
	BEGIN CATCH
		SET @responseMessage = 0
	END CATCH

    ELSE  
       SET @responseMessage = 0  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for verifying Staff
GO
CREATE PROCEDURE [dbo].[VERIFY_STAFF]  
@pEmail VARCHAR(200),  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF EXISTS (SELECT SUBSTRING(email, 1, CHARINDEX('@', email) - 1) 
				FROM dbo.STAFF WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pEmail)  
	BEGIN  
		SET @responseMessage = 1
	END  
    ELSE  
       SET @responseMessage = 0  
END; 
  

---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Retrieving every Staff
GO
CREATE PROCEDURE [dbo].[GET_STAFFS]  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pCountStaff INT
	SET @pCountStaff = (SELECT COUNT(nric) FROM dbo.STAFF) 	

	IF (@pCountStaff > 0)
	BEGIN
		SET @responseMessage = 1

		SELECT SUBSTRING(email, 1, CHARINDEX('@', email) - 1), firstName, lastName, permission, accessProfile 
		FROM dbo.STAFF 	  
	END
	
	ELSE
		SET @responseMessage = 0	  
END;


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Retrieving selected Staff
GO
CREATE PROCEDURE [dbo].[GET_SELECTED_STAFF]  
@pStaff_Email VARCHAR(100),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pCountStaff INT
	SET @pCountStaff = (SELECT COUNT(nric) FROM dbo.STAFF WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaff_Email) 	

	IF (@pCountStaff > 0)
	BEGIN
		SET @responseMessage = 1

		SELECT * FROM dbo.STAFF 
		WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaff_Email	  
	END
	
	ELSE
		SET @responseMessage = 0	  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Retrieving all Staffs
GO
CREATE PROCEDURE [dbo].[GET_ALL_STAFFS]  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pCount_Staffs INT
	SET @pCount_Staffs = (SELECT COUNT(nric) FROM STAFF) 	

	IF (@pCount_Staffs > 0)
	BEGIN
		SET @responseMessage = 1

		SELECT * FROM STAFF   
	END
	
	ELSE
		SET @responseMessage = 0	  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for updating Staff's profile
-- *NOTE: Are we allow Staffs' email (PK) to be updated? If we allow update, we would encounter
--		  FK constraint issues on certain tables/procedure. Unless, we set their NRICs as PK.

GO
CREATE PROCEDURE [dbo].[UPDATE_STAFF] 
@pEmail VARCHAR(200),
@pPassword VARCHAR(64) = '',
@pFirstName VARCHAR(50),
@pLastName VARCHAR(50),
@pNric VARCHAR(100),  
@pAddress VARCHAR(200),
@pPostalCode INT,  
@pHomeTel VARCHAR(20), 
@pAltTel VARCHAR(20),
@pMobileTel VARCHAR(20),
@pSex CHAR(5),
@pNationality VARCHAR(500),
@pDateOfBirth DATE,
--@pAge INT,
--@pRace VARCHAR(50),
@pPermission INT,
@pAccessProfile VARCHAR(100),
@pPosition VARCHAR(50),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		DECLARE @pDateUpdated DATETIME
		SET @pDateUpdated = SYSDATETIME();

		IF (EXISTS (SELECT email FROM STAFF WHERE nric= @pNric))
		BEGIN
			IF(@pPassword = '')
			BEGIN
				UPDATE STAFF
				SET firstName = @pFirstName, lastName = @pLastName, address = @pAddress, postalCode = @pPostalCode,
					homeTel = @pHomeTel, altTel = @pAltTel, mobTel = @pMobileTel, sex= @pSex, nationality = @pNationality, dateOfBirth = @pDateOfBirth,
					permission = @pPermission, accessProfile = @pAccessProfile, position = @pPosition, dateUpdated = @pDateUpdated
				WHERE nric = @pNRIC

			SET @responseMessage = 2
		END
		ELSE
		BEGIN
			UPDATE STAFF
			SET passwordHash = HASHBYTES('SHA2_512', @pPassword), firstName = @pFirstName, lastName = @pLastName, address = @pAddress, postalCode = @pPostalCode,
				homeTel = @pHomeTel, altTel = @pAltTel, mobTel = @pMobileTel, sex= @pSex, nationality = @pNationality, dateOfBirth = @pDateOfBirth,
				permission = @pPermission, accessProfile = @pAccessProfile, position = @pPosition, dateUpdated = @pDateUpdated
			WHERE nric = @pNRIC

			SET @responseMessage = 1 
		END
	END
    ELSE
		SET @responseMessage = 0  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END; 
  

-----------------------------------------------------------------------------------------------------  Procedures for confirming existing Patient
GO
CREATE PROCEDURE [dbo].[CONFIRM_PATIENT] 
@pPatientFullName NVARCHAR(150),
@pBedNo INT,
@responseMessage VARCHAR(500) OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  
  DECLARE @pPatient_Detail VARCHAR(500)

  IF(LEN(@pPatientFullName) > 5)
  BEGIN
    IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
    BEGIN
      SET @pPatient_Detail = (SELECT (nric + ',' + patientfullname + ',' + CAST(bedNo AS VARCHAR(100)))
      FROM PATIENT
      WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo)
      SET @responseMessage = @pPatient_Detail
    END
    ELSE
    BEGIN
      SET @responseMessage = '0'
    END
  END
  ELSE
  BEGIN
    IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName = @pPatientFullName AND bedNo = @pBedNo))  
    BEGIN
      SET @pPatient_Detail = (SELECT (nric + ',' + patientfullname + ',' + CAST(bedNo AS VARCHAR(100)))
      FROM PATIENT
      WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo)
      SET @responseMessage = @pPatient_Detail
    END
    ELSE
    BEGIN
      SET @responseMessage = '0'
    END
  END
END


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for creating visitor's profile
GO
CREATE PROCEDURE [dbo].[CREATE_VISITOR_PROFILE] 
@pNRIC VARCHAR(15),  
@pFullName VARCHAR(150),
@pGender CHAR(5),
@pNationality VARCHAR(300),
@pDateOfBirth DATE,
--@pRace VARCHAR(50),
@pMobileTel VARCHAR(20),
--@pHomeTel VARCHAR(20), 
--@pAltTel VARCHAR(20),
--@pEmail VARCHAR(200), 
@pHomeAddress VARCHAR(200),
@pPostalCode INT,  
@pTimestamp DATETIME = NULL,
@pConfirm INT = 0,
@pAmend INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		SET @pTimestamp = SYSDATETIME();
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pMobileTel, 
				@pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm, @pAmend)

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;

---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Getting Visitor's details
GO
CREATE PROCEDURE [dbo].[GET_VISITOR_DETAILS]  
@pVisitor_Nric VARCHAR(15),  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
  
	IF EXISTS (SELECT nric FROM dbo.VISITOR_PROFILE WHERE nric = @pVisitor_Nric)  
	BEGIN    
		SET @responseMessage = 1
		SELECT * FROM dbo.VISITOR_PROFILE WHERE nric = @pVisitor_Nric
	END 
	 
    ELSE  
       SET @responseMessage = 0  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for updating visitor's profile
GO
CREATE PROCEDURE [dbo].[UPDATE_VISITOR_PROFILE] 
@pNRIC VARCHAR(100),  
@pFullName VARCHAR(150),
@pGender CHAR(5),
@pNationality VARCHAR(300),
@pDateOfBirth DATE,
--@pRace VARCHAR(50),
@pMobileTel VARCHAR(20),
--@pHomeTel VARCHAR(20), 
--@pAltTel VARCHAR(20),
--@pEmail VARCHAR(200), 
@pHomeAddress VARCHAR(200),
@pPostalCode INT,  
@pTimestamp DATETIME = NULL,
@pConfirm INT = 1,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		SET @pTimestamp = SYSDATETIME();
		IF (EXISTS (SELECT TOP 1 nric FROM VISITOR_PROFILE WHERE nric= @pNRIC ORDER BY time_stamp DESC))
		BEGIN
			DECLARE @pLatestTimestamp DATETIME

			SET @pLatestTimestamp = (SELECT MAX(time_stamp) FROM VISITOR_PROFILE WHERE nric= @pNRIC)

			UPDATE VISITOR_PROFILE
			SET nric = @pNRIC, fullName = @pFullName, gender= @pGender, nationality = @pNationality, dateOfBirth = @pDateOfBirth, mobileTel = @pMobileTel, 
						homeAddress = @pHomeAddress, postalCode = @pPostalCode, time_stamp = @pTimestamp, confirm = '1'
			WHERE nric = @pNRIC AND time_stamp = @pLatestTimestamp 

			UPDATE VISITOR_PROFILE
			SET amend = 0
			WHERE nric = @pNRIC
		END
		
		ELSE
		BEGIN
			INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
			VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pMobileTel, 
				@pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm, 0)
		END
 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;  
  

---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for checking existing visitor
GO
CREATE PROCEDURE [dbo].[VISITOR_EXISTS]  
@pNRIC VARCHAR(15),  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @visitor_nric VARCHAR(100)
  
	IF EXISTS (SELECT nric FROM dbo.VISITOR_PROFILE WHERE nric = @pNric)  
	BEGIN  
		SET @visitor_nric = (SELECT TOP 1 nric  
		FROM [dbo].[VISITOR_PROFILE] WHERE nric = @pNRIC)  
  
		SET @responseMessage = 1
	END  
    ELSE  
       SET @responseMessage = 0  
END; 


-----------------------------------------------------------------------------------------------------  Procedures for retrieving Visitor's details  
GO
CREATE PROCEDURE [dbo].[GET_VISITOR]  
@pNRIC VARCHAR(15),  
@responseMessage INT OUTPUT,
@returnValue VARCHAR(MAX) OUTPUT
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @visitorInfo VARCHAR(1000),
	@len BIGINT
    
	BEGIN
		SET @len = 0
		SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + mobileTel + ',' + 
                               homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
		FROM [dbo].[VISITOR_PROFILE] 
		WHERE nric = @pNRIC AND amend = 1 AND confirm = 0
		ORDER BY time_stamp DESC)
		SET @len = LEN(@visitorInfo)

		IF (@len > 0)
		BEGIN
			SET @responseMessage = 1
			SET @returnValue = @visitorInfo
		END
		
		ELSE
		BEGIN
			SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + mobileTel + ',' + 
											homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
								FROM [dbo].[VISITOR_PROFILE] 
								WHERE nric = @pNRIC AND amend = 0 AND confirm = 1
								ORDER BY time_stamp DESC)
								SET @len = LEN(@visitorInfo)
								
			IF (@len > 0)
			BEGIN
				SET @responseMessage = 1
				SET @returnValue = @visitorInfo
			END
			ELSE
			BEGIN
				SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + mobileTel + ',' + 
												homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
									FROM [dbo].[VISITOR_PROFILE] 
									WHERE nric = @pNRIC AND amend = 0 AND confirm = 0
									ORDER BY time_stamp DESC)
        
				SET @len = LEN(@visitorInfo)
				IF (@len > 0)
				BEGIN
					SET @responseMessage = 1
					SET @returnValue = @visitorInfo
				END
				
				ELSE
				BEGIN
					SET @responseMessage = 0
					SET @returnValue = 'Visitor not found'
				END
			END
		END 
	END
END;


-----------------------------------------------------------------------------------------------------  Procedures for creating visits
GO
CREATE PROCEDURE [dbo].[CREATE_VISIT]
@pVisitRequestTime DATETIME,  
--@pPatientNRIC VARCHAR(15) = '',  
@pVisitorNRIC VARCHAR(15),  
--@pPatientFullName VARCHAR(150) = '',
@pPurpose VARCHAR(MAX) = '',
@pReason VARCHAR(MAX) = '',
@pVisitLocation VARCHAR(200) = '',
@pBedNo VARCHAR(MAX),
@pQaID VARCHAR(100),
@pRemarks VARCHAR(MAX),
@pConfirm INT = 0,
@responseMessage INT OUTPUT  
-- Might need a timestamp for entry creation time

AS  
BEGIN  
	SET NOCOUNT ON  

	--IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
	BEGIN
		INSERT INTO VISIT(visitRequestTime, visitorNric, purpose, reason, visitLocation, bedNo, QaID, remarks,confirm)
		VALUES (@pVisitRequestTime, @pVisitorNRIC, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, @pRemarks, @pConfirm)
	END
END; 


-----------------------------------------------------------------------------------------------------  Procedures for updating visits
GO
CREATE PROCEDURE [dbo].[UPDATE_VISIT]
@pVisitRequestTime DATETIME,  
--@pPatientNRIC VARCHAR(15) = '',  
@pVisitorNRIC VARCHAR(15),  
--@pPatientFullName VARCHAR(150) = '',
@pPurpose VARCHAR(MAX) = '',
@pReason VARCHAR(MAX) = '',
@pVisitLocation VARCHAR(150) = '',
@pBedNo VARCHAR(MAX),
@pQaID VARCHAR(100),
@pRemarks VARCHAR(MAX) = '',
@pConfirm INT = 1,
@responseMessage INT OUTPUT  
-- Might need a timestamp for entry creation time

AS  
BEGIN  
	SET NOCOUNT ON  
	-- Change NOT EXISTS to EXISTS once we have the patient information
	IF (EXISTS (SELECT visitorNric FROM dbo.VISIT WHERE visitorNric = @pVisitorNRIC 
		AND bedNo = @pBedNo AND visitLocation = @pVisitLocation AND visitRequestTime = @pVisitRequestTime))  
	BEGIN
		-- Have some logic to update visit
		UPDATE VISIT
		SET 
		--visitRequestTime = @pVisitRequestTime, 
		--patientNric = @pPatientNRIC, 
		--visitorNric = @pVisitorNRIC, 
		--patientFullName = @pPatientFullName, 
		purpose = @pPurpose, 
		reason = @pReason, 
		visitLocation = @pVisitLocation, 
		bedNo = @pBedNo, 
		QaID = @pQaID,
		remarks = @pRemarks,
		confirm = 1
		WHERE visitorNric = @pVisitorNRIC AND visitRequestTime = @pVisitRequestTime
	END

	ELSE
		INSERT INTO VISIT(visitRequestTime, visitorNric, purpose, reason, visitLocation, bedNo, QaID, remarks, confirm)
		VALUES (@pVisitRequestTime, @pVisitorNRIC, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, @pRemarks, 1)
END; 


-----------------------------------------------------------------------------------------------------  Procedures for retrieving Visit details   
GO
CREATE PROCEDURE [dbo].[GET_VISIT_DETAILS]  
@pNric VARCHAR(100),  
@responseMessage VARCHAR(MAX) OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  
  DECLARE @pVisit_Details VARCHAR(MAX)
  DECLARE @pLatestTimestamp DATETIME

  IF EXISTS (SELECT visitorNRIC FROM dbo.VISIT WHERE visitorNRIC = @pNric)  
  BEGIN
    SET @pLatestTimestamp = (SELECT MAX(visitRequestTime) FROM VISIT WHERE visitorNRIC = @pNric 
                 AND visitRequestTime = (SELECT MAX(visitRequestTime) FROM VISIT 
                 WHERE visitorNRIC = @pNric
                 AND YEAR(visitRequestTime) = YEAR(GETDATE())
                 AND MONTH(visitRequestTime) = MONTH(GETDATE())
                 AND DAY(visitRequestTime) = DAY(GETDATE())))

    SET @pVisit_Details = (SELECT (CONVERT(VARCHAR(100), visitRequestTime, 105) + ' ' + CONVERT(VARCHAR(10), visitRequestTime, 108) + ',' +  
                    visitorNric + ',' + purpose  + ',' + reason  + ',' +  visitLocation  + ',' + 
                    bedNo + ',' +  CAST(QaID AS VARCHAR(100))  + ',' +  remarks + ',' +  CAST(confirm AS VARCHAR(5)))
    FROM VISIT 
    WHERE visitorNRIC = @pNric AND visitRequestTime = @pLatestTimestamp)

    SET @responseMessage = @pVisit_Details
  END  

  ELSE
    SET @responseMessage = '0'
END;



---------------------------------------------------------------------------------------------------------- Procedure for confirming visitor's check-in
GO
CREATE PROCEDURE [dbo].[CONFIRM_CHECK_IN]  
@pNric VARCHAR(100),
@pActualTimeVisit DATETIME,
@pTemperature VARCHAR(10),
@pStaffEmail VARCHAR(200),
@responseMessage INT OUTPUT  
  
AS  
BEGIN 
  SET NOCOUNT ON
  SET @pActualTimeVisit = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
  DECLARE @pOriginal_Staff_Email VARCHAR(200)
  DECLARE @pCheckedOut INT
  DECLARE @pCheckedIn INT
  
  SET @pCheckedOut = (SELECT COUNT(*)
              FROM MOVEMENT WHERE nric = @pNric
              AND visitActualTime = (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric)
              AND locationID = 3)
  SET @PCheckedIn = (SELECT COUNT(*)
              FROM MOVEMENT WHERE nric = @pNric
              AND visitActualTime = (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric)
              AND locationID <> 3)
  SET @pOriginal_Staff_Email = (SELECT email FROM STAFF WHERE 
                  SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaffEmail)

  IF(@pCheckedIn > 0)
  BEGIN
	IF(@pCheckedOut = 0)
    BEGIN
      INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
      VALUES (@pNRIC, (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric), 3, (SELECT MAX(locationTime) FROM MOVEMENT WHERE nric = @pNric) + 1)
  
    END
  END

  BEGIN TRY  
    INSERT INTO CHECK_IN(nric, visitActualTime, temperature, staffEmail)
    VALUES (@pNRIC, @pActualTimeVisit, @pTemperature, @pOriginal_Staff_Email)

    SET @responseMessage = 1
  END TRY

    BEGIN CATCH  
       SET @responseMessage = 0  
  END CATCH
END;


----------------------------------------------------------------------------------------------------------- Procedure for creating movement 
GO
CREATE PROCEDURE [dbo].[CREATE_MOVEMENT] 
@pNRIC VARCHAR(15), 
@pLocationID INT, 
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pVisit_Date DATETIME
	SET @pVisit_Date = (SELECT TOP 1 visitActualTime FROM CHECK_IN WHERE nric = @pNRIC AND
						CONVERT(VARCHAR(10), visitActualTime, 103) = CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103)
						ORDER BY visitActualTime DESC) -- Compare Visit Date with System Date
	
	IF (@pVisit_Date != '')
    BEGIN TRY
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
	END TRY
	BEGIN CATCH  
		SET @responseMessage = 0 
	END CATCH 

	-- Visitor do not have any VISIT and CHECK_IN record
	ELSE
		SET @responseMessage = 0

		BEGIN TRY
			DECLARE @pSelected_Time DATETIME
			SET @pSelected_Time = (SELECT TOP 1 visitActualTime 
									FROM CHECK_IN WHERE nric = @pNRIC
									ORDER BY visitActualTime DESC)

			INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
			VALUES (@pNRIC, @pSelected_Time, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
			
			SET @responseMessage = 2 
		END TRY  

		BEGIN CATCH  
			SET @responseMessage = 0 
		END CATCH  

	--IF (@pVisit_Date != '')
 --   BEGIN TRY
	--	IF (SELECT COUNT(nric) FROM MOVEMENT WHERE nric = @pNRIC AND
	--		CONVERT(VARCHAR(10), @pVisit_Date, 103) = 
	--		CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103)) <= 0
	--	BEGIN		
	--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--		VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--		SET @responseMessage = 1 
	--	END
	--	ELSE 
	--		DECLARE @pLast_Visit_Time DATETIME
	--		SET @pLast_Visit_Time = (SELECT TOP 1 locationTime FROM MOVEMENT WHERE nric = @pNRIC AND 
	--						CONVERT(VARCHAR(10), visitActualTime, 103) = CONVERT(VARCHAR(10), @pVisit_Date, 103)
	--						ORDER BY locationTime DESC) 

	--		IF EXISTS (SELECT locationID FROM MOVEMENT WHERE nric = @pNRIC AND 
	--				   @pLast_Visit_Time = locationTime)
	--		BEGIN
	--			DECLARE @pCurrent_LocationID INT
	--			SET @pCurrent_LocationID = (SELECT locationID FROM MOVEMENT WHERE nric = @pNRIC AND 
	--										@pLast_Visit_Time = locationTime)
			
	--			--END END TRY BEGIN CATCH END CATCH END

	--			-- Scan in HOSPITAL ENTRANCE. Assuming that Exit_Time for 
	--			-- HOSPITAL ENTRANCE does not require to be traced. 
	--			IF (@pCurrent_LocationID = 2)
	--			BEGIN
	--				INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--				VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
	--			END

	--			IF (@pCurrent_LocationID = 1)
	--			BEGIN
	--				-- Checks if Terminal contains Beds
	--				IF EXISTS (SELECT bedNoList FROM TERMINAL_BED WHERE terminalID = @pLocationID)
	--				BEGIN
	--					-- Retrieve Patient's BedNo according to the Visitor's registered Visit
	--					DECLARE @pPatient_Bedno INT		
	--					SET @pPatient_Bedno = (SELECT p.bedNo FROM PATIENT p
	--						INNER JOIN VISIT v ON p.nric = v.patientNric
	--					WHERE v.visitorNric = @pNRIC AND
	--					CONVERT(VARCHAR(10), v.visitRequestTime, 103) = 
	--					CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103))
	--					--SELECT @pPatient_Bedno 
	--					--END END END END TRY BEGIN CATCH END CATCH END
	--					-- Checks if the Terminal contains the BedNo from the intended Visit 
	--					IF EXISTS (SELECT terminalID FROM TERMINAL_BED 
	--					WHERE bedNoList LIKE '%' + CAST(@pPatient_Bedno AS VARCHAR(10)) + '%' AND terminalID = @pLocationID)
	--					BEGIN
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						SET @responseMessage = 1
	--					END  
	--					--END END END END TRY BEGIN CATCH END CATCH END
	--					-- A case when visitor is not suppose to visit the patient 
	--					ELSE
	--						-- According to Eddy, he still wants to trace that particular visitor. 
	--						-- This will cater To Contact Tracing's TRACE_BY_SCAN_BED as well
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						-- Since visitor is not allow to visit the patient, he/he will be asked to leave.
	--						-- Thus, this insertion enables the record of the Exit_Time for Contact Tracing's TRACE_BY_SCAN_BED
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
							
	--						SET @responseMessage = 2
		
	--				END 
	--				--END END END TRY BEGIN CATCH END CATCH END
	--				ELSE
	--					-- For visiting Facility in the hospital. (E.g. Pharmacy, Cafeteria, etc)
	--					INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--					VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
						
	--					SET @responseMessage = 1

	--			END
	--			--END END TRY BEGIN CATCH END CATCH END

	--			-- For scanning out at the EXIT Terminal (LocationID = 1)
	--			IF (@pCurrent_LocationID != 1 AND @pLocationID = 1)
	--			BEGIN
	--				INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--				VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
					
	--				SET @responseMessage = 1
	--			END
	--			--END END TRY BEGIN CATCH END CATCH END

	--			-- For virtual exiting on visited Terminal, then add in their next intended Visit
	--			-- Into the MOVEMENT_TABLE
	--			IF (@pCurrent_LocationID != 1 AND @pLocationID != 1)
	--			BEGIN
	--				-- Checks if Terminal contains Beds
	--				IF EXISTS (SELECT bedNoList FROM TERMINAL_BED WHERE terminalID = @pLocationID)
	--				BEGIN
	--					-- Retrieve Patient's BedNo according to the Visitor's registered Visit
	--					DECLARE @pAnother_Patient_Bedno INT		
	--					SET @pAnother_Patient_Bedno = (SELECT p.bedNo FROM PATIENT p
	--						INNER JOIN VISIT v ON p.nric = v.patientNric
	--					WHERE v.visitorNric = @pNRIC AND
	--					CONVERT(VARCHAR(10), v.visitRequestTime, 103) = 
	--					CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103))

	--					-- Checks if the Terminal contains the BedNo from the intended Visit 
	--					IF EXISTS (SELECT terminalID FROM TERMINAL_BED 
	--					WHERE bedNoList LIKE '%' + CAST(@pAnother_Patient_Bedno AS VARCHAR(10)) + '%' AND terminalID = @pLocationID)
	--					BEGIN
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						SET @responseMessage = 1
	--					END   
	--					--END END END END TRY BEGIN CATCH END CATCH END

	--					-- A case when visitor is not suppose to visit the patient 
	--					ELSE
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						-- According to Eddy, he still wants to trace that particular visitor. 
	--						-- This will cater To Contact Tracing's TRACE_BY_SCAN_BED as well
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--						-- Since visitor is not allow to visit the patient, he/he will be asked to leave.
	--						-- Thus, this insertion enables the record of the Exit_Time for Contact Tracing's TRACE_BY_SCAN_BED
	--						INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--						VALUES (@pNRIC, @pVisit_Date, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
							
	--						SET @responseMessage = 2
	--				END  
	--				--END END END TRY BEGIN CATCH END CATCH END

	--				ELSE
	--					-- 'Virtual Exit' first before inserting Facility in the hospital
	--					INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--					VALUES (@pNRIC, @pVisit_Date, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

	--					-- For visiting Facility in the hospital. (E.g. Pharmacy, Cafeteria, etc)
	--					INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
	--					VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
						
	--					SET @responseMessage = 1
	--			END
	--			ELSE
	--				SET @responseMessage = 0
	--		END			
	--END TRY

	--BEGIN CATCH  
	--	SET @responseMessage = 0 
	--END CATCH  
END; 


----------------------------------------------------------------------------------------------------------- Procedure for Checking-Out all visitors 
GO
CREATE PROCEDURE [dbo].[CHECK_OUT_ALL] 
@responseMessage INT OUTPUT  
-- In the MOVEMENT Table: 
-- Assuming that LocationID = '3' for Checking-out at the 'HOSPITAL EXIT' Gantry   

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pVisitor_To_Checkout TABLE (visitor_nric VARCHAR(10))

	INSERT INTO @pVisitor_To_Checkout (visitor_nric)
		SELECT DISTINCT nric FROM MOVEMENT 
		WHERE nric NOT IN (SELECT nric FROM MOVEMENT WHERE locationID = 3)
	
	IF ((SELECT COUNT(visitor_nric) FROM @pVisitor_To_Checkout) > 0)
	BEGIN TRY
		INSERT INTO MOVEMENT (nric, visitActualTime, locationID, locationTime)
			SELECT ci.nric, ci.visitActualTime, 3, SYSDATETIME() 
			FROM CHECK_IN ci
				INNER JOIN @pVisitor_To_Checkout vc ON ci.nric = vc.visitor_nric

 		SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
	
	ELSE
		SET @responseMessage = 0 
END; 


-------------------------------------------------------------------------------------------------------- Procedure for adding Terminal
GO
CREATE PROCEDURE [dbo].[ADD_TERMINAL] 
@pTName VARCHAR(100),
@pTControl INT,
@pBedNoList VARCHAR(MAX) = NULL,
@responseMessage INT OUTPUT 
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	IF NOT EXISTS (SELECT terminalID FROM TERMINAL WHERE tName = @pTName)
	BEGIN TRY
		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES (@pTName, 0, @pTControl, SYSDATETIME(), NULL)

		IF (@pBedNoList != '' OR @pBedNoList IS NULL)
		BEGIN
			DECLARE @pTerminal_Id INT
			SET @pTerminal_Id = (SELECT terminalID FROM TERMINAL WHERE tName = @pTName)
		
			INSERT INTO TERMINAL_BED(terminalID, bedNoList)
			VALUES (@pTerminal_Id, @pBedNoList)
		END

 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
	
	ELSE
		SET @responseMessage = 0 
END; 


-------------------------------------------------------------------------------------------------------- Procedure for getting Inactive Terminal
GO
CREATE PROCEDURE [dbo].[GET_INACTIVE_TERMINAL]   
  
AS  
BEGIN  
	SET NOCOUNT ON  
   
	BEGIN TRY
		SELECT terminalID, tName
		FROM TERMINAL
		WHERE activated = 0 AND endDate IS NULL
	END TRY  

	BEGIN CATCH  
		SELECT '0' 
	END CATCH  
END;


-------------------------------------------------------------------------------------------------------- Procedure for getting all Terminals
GO
CREATE PROCEDURE [dbo].[GET_ALL_TERMINALS]   
  
AS  
BEGIN  
	SET NOCOUNT ON  
   
	BEGIN TRY
		SELECT terminalID, tName, activated, tControl
		FROM TERMINAL
		WHERE endDate IS NULL
	END TRY  

	BEGIN CATCH  
		SELECT '0' 
	END CATCH  
END;


------------------------------------------------------------------------------------------------------- Procedure for Deactivating all Terminal
GO
CREATE PROCEDURE [dbo].[DEACTIVATE_ALL_TERMINALS] 
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		UPDATE TERMINAL
		SET activated = 0

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;


------------------------------------------------------------------------------------------------------ Procedure for deleting Terminal
GO
CREATE PROCEDURE [dbo].[DELETE_ALL_TERMINALS] 
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	BEGIN TRY
		DELETE FROM TERMINAL_BED

		UPDATE TERMINAL
		SET endDate = SYSDATETIME()

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END; 


------------------------------------------------------------------------------------------------------ Procedure for deleting Terminal
GO
CREATE PROCEDURE [dbo].[DELETE_TERMINAL] 
@pTerminal_ID INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	BEGIN TRY
		DELETE FROM TERMINAL_BED 
		WHERE terminalID = @pTerminal_ID 

		UPDATE TERMINAL
		SET endDate = SYSDATETIME()
		WHERE terminalID = @pTerminal_ID

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END; 


------------------------------------------------------------------------------------------------------- Procedure for activating Terminal
GO
CREATE PROCEDURE [dbo].[ACTIVATE_TERMINAL] 
@pTerminal_ID INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		UPDATE TERMINAL
		SET activated = 1
		WHERE terminalID = @pTerminal_ID

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;


------------------------------------------------------------------------------------------------------- Procedure for deactivating Terminal
GO
CREATE PROCEDURE [dbo].[DEACTIVATE_TERMINAL] 
@pTerminal_ID INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		UPDATE TERMINAL
		SET activated = 0
		WHERE terminalID = @pTerminal_ID

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;


-------------------------------------------------------------------------------------------------------- Procedure for getting all Terminals
GO
CREATE PROCEDURE [dbo].[GET_ALL_FACILITIES]   
@responseMessage INT OUTPUT   
 
AS  
BEGIN  
	SET NOCOUNT ON  
   
	BEGIN TRY
		SELECT *
		FROM TERMINAL
		WHERE endDate IS NULL AND tControl = 0

		SET @responseMessage = 1
	END TRY  

	BEGIN CATCH  
		SELECT '0' 
		SET @responseMessage = 0
	END CATCH  
END;


-------------------------------------------------------------------------------------------------------- Procedure for adding Question
GO
CREATE PROCEDURE [dbo].[ADD_QUESTION] 
@pQuestion VARCHAR(1000),
@pQnsType VARCHAR(100),
@pQnsValue VARCHAR(1000),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	IF NOT EXISTS (SELECT QQ_ID FROM QUESTIONAIRE_QNS WHERE question = @pQuestion AND qnsType = @pQnsValue)
	BEGIN TRY
		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
		VALUES (@pQuestion, @pQnsType, @pQnsValue, SYSDATETIME(), NULL)

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
	
	ELSE
		SET @responseMessage = 0 
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Updating questionnaires' responses 
GO
CREATE PROCEDURE [dbo].[UPDATE_QUESTION]  
@pQQ_ID INT,
@pQuestion VARCHAR(1000),
@pQnsType VARCHAR(50),
@pQnsValue VARCHAR(1000),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF EXISTS (SELECT QQ_ID FROM QUESTIONAIRE_QNS WHERE QQ_ID = @pQQ_ID)
	BEGIN TRY  
			UPDATE QUESTIONAIRE_QNS
			SET question = @pQuestion, qnsType = @pQnsType, qnsValue = @pQnsValue, startDate = SYSDATETIME()
			WHERE QQ_ID = @pQQ_ID

		SET @responseMessage = 1 
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0
    END CATCH 

	ELSE
		SET @responseMessage = 0
END; 


-------------------------------------------------------------------------------------------------------- Procedure for Retrieving Question
GO
CREATE PROCEDURE [dbo].[GET_QUESTIONS] 
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	BEGIN TRY
		SELECT * FROM QUESTIONAIRE_QNS
		WHERE endDate IS NULL

 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH
        SET @responseMessage = 0 
    END CATCH  
END; 


------------------------------------------------------------------------------------------------------ Procedure for deleting Terminal
GO
CREATE PROCEDURE [dbo].[DELETE_QUESTION] 
@pQQ_ID INT,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	IF EXISTS (SELECT QQ_ID FROM QUESTIONAIRE_QNS WHERE QQ_ID = @pQQ_ID)
	BEGIN TRY
		UPDATE QUESTIONAIRE_QNS
		SET endDate = SYSDATETIME()
		WHERE QQ_ID = @pQQ_ID

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
	
	ELSE
		SET @responseMessage = 0 
END; 


---------------------------------------------------------------------------------------------------— Procedure for getting question order
GO
CREATE PROCEDURE [dbo].[GET_SELECTED_QUESTIONNARIE_ORDER]  
@pQ_QuestionList_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pOrder_QQ_ID VARCHAR(100)
  
	SELECT Q_Order 
	FROM QUESTIONAIRE_QNS_LIST 
	WHERE Q_QuestionListID = @pQ_QuestionList_ID AND endDate IS NULL

    SET @responseMessage = 1
END;


-----------------------------------------------------------------------------------------------------  Procedures for retrieving Active Questionnaries 
GO
CREATE PROCEDURE [dbo].[RETRIEVE_ACTIVE_QUESTIONNARIE]  
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pActiveQns TABLE (QQ_ID INT, listID VARCHAR(100), question VARCHAR(200), qnsType VARCHAR(20), qnsValue VARCHAR(200))
	DECLARE @pOrder_QQ_ID VARCHAR(100)
	 
	SET @pOrder_QQ_ID = (SELECT Q_Order FROM QUESTIONAIRE_QNS_LIST WHERE Q_Active = 1)
	 
	INSERT INTO @pActiveQns  
		SELECT QQ_ID, Q_QuestionListID, question, qnsType, qnsValue
		FROM QUESTIONAIRE_QNS qq JOIN QUESTIONAIRE_QNS_LIST qqList
		ON QQ_ID IN 
		(
			--SELECT split_data.VALUE
			--FROM QUESTIONAIRE_QNS_LIST 
			--CROSS APPLY STRING_SPLIT(Q_Order, ',') AS split_data
			--WHERE Q_Active = 1
			--SELECT * FROM dbo.FUNC_SPLIT(@pOrder_QQ_ID, ',')
			SELECT * FROM dbo.FUNC_SPLIT(@pOrder_QQ_ID, ',')
		) 
		AND Q_Active = 1 AND qq.endDate IS NULL
  
	IF EXISTS (SELECT question FROM @pActiveQns)
	BEGIN
		SET @responseMessage = 1
		SELECT listID, QQ_ID, question, qnsType, qnsValue FROM @pActiveQns 
		ORDER BY CHARINDEX(
             ','+CAST(QQ_ID AS VARCHAR)+',' ,
             ','+@pOrder_QQ_ID+',')
		
		RETURN
	END

	ELSE
		SET @responseMessage = 0
END;


-----------------------------------------------------------------------------------------------------  Procedures for Retrieving all list of questionnaires 
GO
CREATE PROCEDURE [dbo].[GET_ALL_QUESTIONNAIRE_LIST]  
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @pReturnCount INT
	SET @pReturnCount = (SELECT COUNT(Q_QuestionListID) FROM QUESTIONAIRE_QNS_LIST 
						 WHERE endDate IS NULL)

	IF (@pReturnCount > 0)
	BEGIN
		SELECT * FROM QUESTIONAIRE_QNS_LIST WHERE endDate IS NULL
      	SET @responseMessage = 1   
   	END
	
	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Adding a new list of questionnaires 
GO
CREATE PROCEDURE [dbo].[ADD_QUESTIONNARIE_LIST]  
@pQ_QuestionListID VARCHAR(100),
@pQ_Order VARCHAR(30),
@pQ_Active INT = 0,
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF NOT EXISTS (SELECT Q_QuestionListID FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionListID)
		BEGIN TRY  
       		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)  
       		VALUES(@pQ_QuestionListID, @pQ_Order, @pQ_Active, SYSDATETIME(), NULL)  
  
      	   SET @responseMessage = 1   
   		END TRY  

   		BEGIN CATCH  
       		SET @responseMessage = ERROR_MESSAGE()
   		END CATCH 
	
	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Adding a new list of blank questionnaires 
GO
CREATE PROCEDURE [dbo].[ADD_BLANK_QUESTIONNARIE_LIST]  
@pQ_QuestionListID VARCHAR(100),
@pQ_Active INT = 0,
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF NOT EXISTS (SELECT Q_QuestionListID FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionListID)
		BEGIN TRY  
       		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)  
       		VALUES(@pQ_QuestionListID, '', @pQ_Active, SYSDATETIME(), NULL)  
  
      	   SET @responseMessage = 1   
   		END TRY  

   		BEGIN CATCH  
       		SET @responseMessage = ERROR_MESSAGE()
   		END CATCH 
	
	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Updating a new list of questionnaires 
GO
CREATE PROCEDURE [dbo].[UPDATE_QUESTIONNARIE_LIST]  
@pQ_QuestionList_ID VARCHAR(100),
@pQ_Order VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	
	IF EXISTS (SELECT Q_QuestionListID FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionList_ID)
	BEGIN TRY  
		UPDATE QUESTIONAIRE_QNS_LIST
		SET Q_Order = @pQ_Order 
		WHERE Q_QuestionListID = @pQ_QuestionList_ID
  
		SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = ERROR_MESSAGE()
    END CATCH 
	
	ELSE
		SET @responseMessage = 0	
END;


-----------------------------------------------------------------------------------------------------  Procedures for Activating the list of questionnaires 
GO
CREATE PROCEDURE [dbo].[ACTIVATE_QUESTIONNARIE_LIST]  
@pQ_QuestionList_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	
	UPDATE QUESTIONAIRE_QNS_LIST
	SET Q_Active = 0
	WHERE Q_QuestionListID != @pQ_QuestionList_ID

	IF EXISTS (SELECT Q_QuestionListID FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionList_ID)
	BEGIN TRY  
		UPDATE QUESTIONAIRE_QNS_LIST
		SET Q_Active = 1 
		WHERE Q_QuestionListID = @pQ_QuestionList_ID
  
		SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = ERROR_MESSAGE()
    END CATCH 
	
	ELSE
		SET @responseMessage = 0
END;


-----------------------------------------------------------------------------------------------------  Procedures for Activating the list of questionnaires 
GO
CREATE PROCEDURE [dbo].[GET_SELECTED_QUESTIONNARIE]  
@pQ_QuestionList_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pOrder_QQ_ID VARCHAR(100)
	DECLARE @pSelected_Qns TABLE (qqID INT, question VARCHAR(200), qnsType VARCHAR(20), qnsValue VARCHAR(200))
	
	SET @pOrder_QQ_ID = (SELECT Q_Order FROM QUESTIONAIRE_QNS_LIST 
						 WHERE Q_QuestionListID = @pQ_QuestionList_ID AND endDate IS NULL)

	INSERT INTO @pSelected_Qns  
		SELECT QQ_ID, question, qnsType, qnsValue
		FROM QUESTIONAIRE_QNS qq
		INNER JOIN QUESTIONAIRE_QNS_LIST ON QQ_ID IN 
		(
			SELECT * FROM dbo.FUNC_SPLIT(@pOrder_QQ_ID, ',')
		) 
		WHERE Q_QuestionListID = @pQ_QuestionList_ID

	IF EXISTS (SELECT qqID FROM @pSelected_Qns)
	BEGIN
		SET @responseMessage = 1
		SELECT * FROM @pSelected_Qns 
		RETURN
	END

	ELSE
		SET @responseMessage = 0
END;


-----------------------------------------------------------------------------------------------------  Procedures for Deleting the list of questionnaires 
GO
CREATE PROCEDURE [dbo].[DELETE_QUESTIONNARIE_LIST]  
@pQ_QuestionList_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	
	IF EXISTS (SELECT Q_QuestionListID FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionList_ID)
	BEGIN TRY  
		UPDATE QUESTIONAIRE_QNS_LIST
		SET endDate = SYSDATETIME()
		WHERE Q_QuestionListID = @pQ_QuestionList_ID
  
		SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = ERROR_MESSAGE()
    END CATCH 
	
	ELSE
		SET @responseMessage = 0
END;


-----------------------------------------------------------------------------------------------------  Procedures for Inserting questionnaires' responses 
GO
CREATE PROCEDURE [dbo].[INSERT_QUESTIONNARIE_RESPONSE]  
@pQA_ID VARCHAR(100),
@pQ_QuestionListID VARCHAR(100),
@pQA_JSON NVARCHAR(MAX),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY  
        INSERT INTO QUESTIONAIRE_ANS(QA_ID,Q_QuestionListID, QA_JSON)  
        VALUES(@pQA_ID, @pQ_QuestionListID, @pQA_JSON)  
  
       SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = ERROR_MESSAGE()
    END CATCH 
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Retrieving questionnaires' responses 
GO
CREATE PROCEDURE [dbo].[GET_QUESTIONNARIE_RESPONSE]  
@pQA_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF EXISTS (SELECT QA_ID FROM QUESTIONAIRE_ANS WHERE QA_ID = @pQA_ID)
	BEGIN TRY  
		SET @responseMessage = 1 
		SELECT QA_JSON FROM QUESTIONAIRE_ANS WHERE QA_ID = @pQA_ID
 		
		RETURN  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0
    END CATCH 

	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Updating questionnaires' responses 
GO
CREATE PROCEDURE [dbo].[UPDATE_QUESTIONNARIE_RESPONSE]  
@pQA_ID VARCHAR(100),
@pQA_JSON NVARCHAR(MAX),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF EXISTS (SELECT QA_ID FROM QUESTIONAIRE_ANS WHERE QA_ID = @pQA_ID)
	BEGIN TRY  
		UPDATE QUESTIONAIRE_ANS
		SET QA_JSON = @pQA_JSON
		WHERE QA_ID = @pQA_ID

		SET @responseMessage = 1 
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0
    END CATCH 

	ELSE
		SET @responseMessage = 0
END; 


---------------------------------------------------------------------------------------------------------  Procedures for Deleting Unconfirm Visit and Visitor's Profile based on datetime range
GO
CREATE PROCEDURE [dbo].[PURGE_UNCONFIRM_VISIT] 
@pStartDate DATETIME,
@pEndDate DATETIME,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pClear_QA_IDs TABLE (QA_ID INT)

	BEGIN
		INSERT INTO @pClear_QA_IDs
			SELECT QaID FROM VISIT
			WHERE confirm = 0 AND TRY_CONVERT(DATE, visitRequestTime, 120) 
				  BETWEEN TRY_CONVERT(DATE, @pStartDate, 120) AND TRY_CONVERT(DATE, @pEndDate, 120)
	END

	BEGIN TRY
		DELETE FROM VISITOR_PROFILE
		WHERE confirm = 0
		AND nric IN (SELECT visitorNric FROM VISIT 
					 WHERE confirm = 0 AND TRY_CONVERT(DATE, visitRequestTime, 120) 
					 BETWEEN TRY_CONVERT(DATE, @pStartDate, 120) AND TRY_CONVERT(DATE, @pEndDate, 120))

 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  


	BEGIN TRY
		DELETE FROM VISIT
		WHERE confirm = 0
		AND TRY_CONVERT(DATETIME, visitRequestTime, 120) BETWEEN TRY_CONVERT(DATETIME, @pStartDate, 120)
		AND TRY_CONVERT(DATETIME, @pEndDate, 120)

 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH 


	BEGIN TRY
		DELETE FROM QUESTIONAIRE_ANS
		WHERE QA_ID IN (SELECT * FROM @pClear_QA_IDs)

 		SET @responseMessage = 1  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END;


---------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
GO
CREATE PROCEDURE [dbo].[TRACE_VISITOR_BY_LOCATION]  
@pStart_Date DATETIME,
@pEnd_Date DATETIME,
@pLocation VARCHAR(100),
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON
	DECLARE @pMovement_Within_Range TABLE (visitor_nric VARCHAR(15))
	DECLARE @pVisitor_count INT
	
	INSERT INTO @pMovement_Within_Range
		SELECT DISTINCT m.nric FROM MOVEMENT m
			INNER JOIN TERMINAL t ON m.locationID = t.terminalID
		WHERE locationTime BETWEEN @pStart_Date AND @pEnd_Date
		AND t.tName = @pLocation

	SET @pVisitor_count = (SELECT COUNT(visitor_nric) FROM @pMovement_Within_Range)

	IF (@pVisitor_count > 0)
	BEGIN
		SELECT * FROM VISITOR_PROFILE 
		WHERE nric IN (SELECT visitor_nric FROM @pMovement_Within_Range)

		SET @responseMessage = 1
	END

	ELSE
		SET @responseMessage = 0
END; 


---------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
GO
CREATE PROCEDURE [dbo].[GET_TRACE_TERMINALS]  
@pStart_Date DATETIME,
@pEnd_Date DATETIME,
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON
	DECLARE @pSelected_Terminals TABLE (tId INT, tName VARCHAR(100), activated INT, tControl INT, 
										startDate DATETIME, endDate DATETIME)
	DECLARE @pTerminal_count INT

	BEGIN
	INSERT INTO @pSelected_Terminals
		SELECT * FROM TERMINAL
		WHERE endDate IS NULL 
		AND startDate >= @pStart_Date
		AND startDate <= @pEnd_Date 
	END

	BEGIN
	INSERT INTO @pSelected_Terminals
		SELECT * FROM TERMINAL
		WHERE endDate IS NOT NULL 
		AND startDate <= @pEnd_Date AND endDate >= @pStart_Date
	END

	SET @pTerminal_count = (SELECT DISTINCT COUNT(tId) FROM @pSelected_Terminals)

	IF (@pTerminal_count > 0)
	BEGIN
		SELECT DISTINCT * FROM @pSelected_Terminals 

		SET @responseMessage = 1
	END

	ELSE
		SET @responseMessage = 0
END; 


--------------------------------------------------------------------------------------------------------- Checks number of visitors checked in to a particular bed number
GO 
CREATE PROCEDURE [dbo].[CHECK_NUM_VISITORS] 
@pBedNo INT,
@pLimit INT = 3,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
  SET NOCOUNT ON  

  BEGIN TRY
    SET @responseMessage = CAST((SELECT COUNT(DISTINCT nric) AS num FROM CHECK_IN a JOIN VISIT b
                  ON a.nric = b.visitorNric
                  AND DAY(a.visitActualTime) = DAY(GETDATE())
                                  AND MONTH(a.visitActualTime) = MONTH(GETDATE()) 
                                  AND YEAR(a.visitActualTime) = YEAR(GETDATE())
                  AND DAY(a.visitActualTime) = DAY(b.visitRequestTime)
                                  AND MONTH(a.visitActualTime) = MONTH(b.visitRequestTime) 
                                  AND YEAR(a.visitActualTime) = YEAR(b.visitRequestTime)
                  AND bedNo = @pBedNo
                  AND nric NOT IN (SELECT DISTINCT nric FROM MOVEMENT WHERE locationID = 3
                                  AND DAY(visitActualTime) = DAY(GETDATE())
                                  AND MONTH(visitActualTime) = MONTH(GETDATE()) 
                                  AND YEAR(visitActualTime) = YEAR(GETDATE()))) AS INT)
    END TRY  
    BEGIN CATCH
        SET @responseMessage = 0 
    END CATCH  
END; 



---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Retrieving Pass Format
GO
CREATE PROCEDURE [dbo].[GET_PASS_FORMAT]  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		SELECT * FROM PASS_FORMAT   

		SET @responseMessage = 1
	END TRY
	
	BEGIN CATCH
		SET @responseMessage = 0	
	END CATCH  
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Updating Pass Format
GO
CREATE PROCEDURE [dbo].[SET_PASS_FORMAT]  
@pPass_Format VARCHAR(MAX),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN 
		DECLARE @pCount_pass INT
		SET @pCount_pass = (SELECT COUNT(passFormat) FROM PASS_FORMAT)

		BEGIN TRY
		IF (@pCount_pass > 0)
			UPDATE PASS_FORMAT
			SET passFormat = @pPass_Format

		ELSE
			INSERT INTO  PASS_FORMAT
			VALUES (@pPass_Format)   

			SET @responseMessage = 1
		END TRY
  
		BEGIN CATCH
			SET @responseMessage = 0  
		END CATCH  
	END
END;


---------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
--GO
--CREATE PROCEDURE [dbo].[TRACE_BY_REG_BED]  
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pBed_No INT,
--@responseMessage INT OUT
---- @pVisits NVARCHAR(MAX) OUTPUT

--AS  
--BEGIN  
--  SET NOCOUNT ON
  
--  DECLARE @pVisitor_Profile TABLE (
--    visitLocation VARCHAR(100),
--    bedno INT,
--    visitActualTime DATETIME,
--    exitTime DATETIME,
--    visitorNric VARCHAR(15),
--    fullName VARCHAR(150),
--    nationality VARCHAR(300), 
--    mobileTel VARCHAR(20))
  
--  DECLARE @pvisitor_count INT

--  DECLARE @pExit_Time TABLE (exitTime DATETIME)


--  BEGIN
--    INSERT INTO @pVisitor_Profile
--      SELECT DISTINCT v.visitLocation, v.bedNo, ci.visitActualTime, 
--              (
--                SELECT TOP 1 m.locationTime FROM MOVEMENT m
--                WHERE m.locationTime BETWEEN @pStart_Date AND @pEnd_Date
--                AND m.nric = v.visitorNric
--				AND CONVERT(VARCHAR(10), m.locationTime, 103) = 
--					CONVERT(VARCHAR(10),  ci.visitActualTime, 103)
--                AND m.locationTime > ci.visitActualTime 
--                AND m.locationID = 1            
--               ),              
--              vp.nric, vp.fullName, vp.nationality, vp.mobileTel
--      FROM VISITOR_PROFILE vp
--        INNER JOIN VISIT v ON vp.nric = v.visitorNric
--        INNER JOIN CHECK_IN ci ON vp.nric = ci.nric
--      WHERE ci.visitActualTime BETWEEN @pStart_Date AND @pEnd_Date
--	  AND v.confirm = 1
--      AND v.bedNo = @pBed_No

--  END

--  BEGIN
--    DECLARE @pCount_Visit INT
--    SET @pCount_Visit = (SELECT COUNT(visitorNric) FROM @pVisitor_Profile)
    
--    IF (@pCount_Visit > 0)
--    BEGIN
--      --SET @pVisits = (SELECT * FROM @pVisitor_Profile 
--					  --FOR JSON PATH, ROOT('Visits'))

--	  SELECT * FROM @pVisitor_Profile 

--      SET @responseMessage = 1
--    END
    
--    ELSE
--      SET @responseMessage = 0
--  END
--END;


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
--GO
--CREATE PROCEDURE [dbo].[TRACE_BY_SCAN_BED]  -- Retrieve every visitor so long as they scanned in the given Bedno
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pBed_No INT,
--@responseMessage INT OUT
----@pVisits NVARCHAR(MAX) OUTPUT

--AS  
--BEGIN  
--	SET NOCOUNT ON
	
--	DECLARE @pBed_No_Var VARCHAR(10)
--	SET @pBed_No_Var = CAST(@pBed_No AS VARCHAR(10))

--	DECLARE @pVisitor_Profile TABLE (
--		visitLocation VARCHAR(100),
--		bedno INT,
--		visitActualTime DATETIME,
--		exitTime DATETIME,
--		visitorNric VARCHAR(15),
--		fullName VARCHAR(150),
--		nationality VARCHAR(300), 
--		mobileTel VARCHAR(20))

--	DECLARE @pLocation_Name VARCHAR(100)
--	SET @pLocation_Name = (SELECT tName FROM TERMINAL WHERE terminalID = (
--							SELECT terminalID FROM TERMINAL_BED 
--							WHERE bedNoList LIKE '%'+ @pBed_No_Var +'%'))

--	BEGIN
--		INSERT INTO @pVisitor_Profile
--			SELECT DISTINCT @pLocation_Name, 
--							(SELECT * FROM dbo.FUNC_SPLIT(
--									(SELECT bedNoList FROM TERMINAL_BED 
--									 WHERE bedNoList LIKE '%'+ @pBed_No_Var +'%'),',')
--							 WHERE Element = @pBed_No_Var) AS Bed_No,
--							m2.visitActualTime, 
--							(
--								SELECT TOP 1 m.locationTime FROM MOVEMENT m
--								WHERE m.locationTime BETWEEN @pStart_Date AND @pEnd_Date
--								AND m.nric = vp.nric
--								AND m.locationTime > m2.visitActualTime
--								AND m.locationID = 1					
--							 ),							
--							vp.nric, vp.fullName, vp.nationality, vp.mobileTel
--			FROM VISITOR_PROFILE vp
--				INNER JOIN MOVEMENT m2 ON m2.nric = vp.nric
--				INNER JOIN TERMINAL_BED tb ON tb.terminalID = m2.locationID
--			WHERE m2.visitActualTime BETWEEN @pStart_Date AND @pEnd_Date
--			AND m2.locationID = (SELECT terminalID FROM TERMINAL_BED tb2
--								 WHERE tb2.bedNoList LIKE '%'+ @pBed_No_Var +'%')

--	END

--	BEGIN
--		DECLARE @pCount_Visit INT
--		SET @pCount_Visit = (SELECT COUNT(visitorNric) FROM @pVisitor_Profile)
		
--		IF (@pCount_Visit > 0)
--		BEGIN
--			--SET @pVisits = (SELECT * FROM @pVisitor_Profile 
--			--				FOR JSON PATH, ROOT('Visits'))
			
--			SELECT * FROM @pVisitor_Profile

--			SET @responseMessage = 1
--		END
		
--		ELSE
--			SET @responseMessage = 0
--	END
--END;


---------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
GO
CREATE PROCEDURE [dbo].[TRACE_BY_REG_BED]  
@pStart_Date DATE,
@pEnd_Date DATE,
@pBed_No INT,
@responseMessage INT OUT

AS  
BEGIN  
  SET NOCOUNT ON
  
  DECLARE @pBed_No_Var VARCHAR(10)
	SET @pBed_No_Var = CAST(@pBed_No AS VARCHAR(10))

  BEGIN
    SET @responseMessage = 1;

	------------------------------------------------ First retrieve all registered visits to the bed
	------------------------------------------------ in question which checked in within query period
	WITH DAY_BED_CHECKINS(nric, visitActualTime, bedNo, visitLocation)
	AS
	(
		SELECT ci.nric, ci.visitActualTime, v.bedNo, v.visitLocation
		FROM CHECK_IN ci
		LEFT JOIN VISIT v ON v.visitorNric = ci.nric
		WHERE v.bedNo LIKE '%'+ @pBed_No_Var +'%'
		AND CAST(ci.visitActualTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
	),
	DAY_BED_EXITS (nric, visitActualTime, exitTerminal, exitTime)
		AS
		(
			SELECT dbc.nric, dbc.visitActualTime, t.tName, m.locationTime
			FROM DAY_BED_CHECKINS dbc	
			FULL OUTER JOIN MOVEMENT M ON m.NRIC = dbc.nric
				AND m.visitActualTime = dbc.visitActualTime
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			WHERE t.tName LIKE 'EXIT%'
		)
	SELECT DISTINCT dbc.visitLocation AS 'location',  dbc.bedNo AS 'bedNo', dbc.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbc.nric AS 'nric', vp.fullName AS 'fullName', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel'
		FROM DAY_BED_CHECKINS dbc
		LEFT JOIN DAY_BED_EXITS dbe ON dbe.nric = dbc.nric AND dbe.visitActualTime = dbc.visitActualTime
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbc.nric
  END
END;


---------------------------------------------------------------------------------------------------  Procedures for Tracing Visitors by Check-In  
GO
CREATE PROCEDURE [dbo].[TRACE_BY_SCAN_BED]  -- Retrieve every visitor so long as they scanned in the given Bedno
@pStart_Date DATE,
@pEnd_Date DATE,
@pBed_No INT,
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON

	DECLARE @pBed_No_Var VARCHAR(10)
	SET @pBed_No_Var = CAST(@pBed_No AS VARCHAR(10))

	BEGIN
		SET @responseMessage = 1;
		------------------------------------------------ First retrieve all visits to the bed in question
		------------------------------------------------ which were scanned within the query period
		WITH DAY_BED_SCANS (nric, visitActualTime, locationID, locationTime, bedNoList)
		AS
		(
			SELECT m.nric, m.visitActualTime, m.locationID, m.locationTime, tb.bedNoList
			FROM MOVEMENT m
			LEFT JOIN TERMINAL_BED tb ON m.locationID = tb.terminalID
			WHERE tb.bedNoList LIKE '%'+ @pBed_No_Var +'%'
			AND CAST(m.locationTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
		),		
		------------------------------------------------ Find the corresponding exit terminals and exit times
		DAY_BED_EXITS (nric, visitActualTime, locationTime, exitTerminal, exitTime)
		AS
		(
			SELECT dbs.nric, dbs.visitActualTime, dbs.locationTime, t.tName, m.locationTime
			FROM DAY_BED_SCANS dbs	
			FULL OUTER JOIN MOVEMENT M ON m.NRIC = dbs.nric
				AND m.visitActualTime = dbs.visitActualTime
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			WHERE t.tName LIKE 'EXIT%'
		)
		SELECT DISTINCT v.visitLocation AS 'location',  v.bedNo AS 'bedNo', dbs.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbs.nric AS 'nric', vp.fullName AS 'fullName', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel'
		FROM DAY_BED_SCANS dbs 
		LEFT JOIN DAY_BED_EXITS dbe ON dbs.nric = dbe.nric AND dbe.visitActualTime = dbs.visitActualTime
		LEFT JOIN VISIT v ON v.visitorNric = dbs.nric AND CAST(v.visitRequestTime AS DATE) = CAST(dbs.visitActualTime AS DATE)
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbs.nric
	END
END;




-------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE_CONFIG] 
@pLowTemp VARCHAR(15),
@pHighTemp VARCHAR(15),
@pWarnTemp VARCHAR(15),
@pLowTime VARCHAR(15),
@pHighTime VARCHAR(15),
@pVisLim INT,
@pUpdatedBy VARCHAR(200),
@responseMessage INT OUTPUT 

AS  
BEGIN  
  SET NOCOUNT ON  
  BEGIN TRY
    INSERT INTO MASTER_CONFIG (lowerTempLimit, upperTempLimit, warnTemp, lowerTimeLimit, upperTimeLimit, visitLimit, dateUpdated, updatedBy) 
    VALUES (@pLowTemp, @pHighTemp, @pWarnTemp, @pLowTime, @pHighTime, @pVisLim, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), @pUpdatedBy)

    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0
  END CATCH
END;


------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[GET_CONFIG] 
@responseMessage VARCHAR(500) OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  

  IF (EXISTS (SELECT * FROM dbo.MASTER_CONFIG))  
  BEGIN
    SELECT TOP 1 * FROM dbo.MASTER_CONFIG ORDER BY dateUpdated DESC
    SET @responseMessage = '1'
  END
  ELSE
    SET @responseMessage = '0'
END;


-------------------------------------------------------------------------------------------------- Procedure to create access profile
GO
CREATE PROCEDURE CREATE_ACCESS_PROFILE
@pProfileName VARCHAR(100),
@pAccessRights VARCHAR(15),
@pUpdatedBy VARCHAR(100),
@responseMessage INT OUTPUT

AS
BEGIN
  SET NOCOUNT ON
  
  BEGIN TRY
    INSERT INTO ACCESS_PROFILE (profileName, accessRights, dateUpdated, updatedBy)
    VALUES (@pProfileName, @pAccessRights, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), @pUpdatedBy)
    
    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0  
  END CATCH
END;


------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE_ACCESS_PROFILE]
@pProfileName VARCHAR(100),
@pAccessRights VARCHAR(15),
@pUpdatedBy VARCHAR(100),
@responseMessage INT OUTPUT

AS
BEGIN
  SET NOCOUNT ON
    
  BEGIN TRY
    IF EXISTS(SELECT profileName FROM ACCESS_PROFILE WHERE profileName = @pProfileName)
    BEGIN
    UPDATE ACCESS_PROFILE
    SET accessRights = @pAccessRights, dateUpdated = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), updatedBy = @pUpdatedBy
    WHERE profileName = @pProfileName
    END
    ELSE
    BEGIN
      INSERT INTO ACCESS_PROFILE (profileName, accessRights, dateUpdated, updatedBy)
      VALUES (@pProfileName, @pAccessRights, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), @pUpdatedBy)
    END

    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0  
  END CATCH
END;


----------------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE DELETE_ACCESS_PROFILE
@pProfileName VARCHAR(100),
@responseMessage INT OUTPUT

AS
BEGIN
  SET NOCOUNT ON
    
  BEGIN TRY
    DELETE FROM ACCESS_PROFILE 
    WHERE profileName = @pProfileName
      
    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0  
  END CATCH
END;


-------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE GET_ACCESS_PROFILES
@responseMessage INT OUTPUT

AS
BEGIN
  SET NOCOUNT ON
    
  BEGIN TRY
    SELECT * FROM ACCESS_PROFILE
      
    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0  
  END CATCH
END;


---------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[GET_SELECTED_PROFILE]
@pProfileName VARCHAR(100),
@responseMessage INT OUTPUT

AS
BEGIN
  SET NOCOUNT ON
    
  BEGIN TRY
    SELECT * FROM ACCESS_PROFILE
    WHERE profileName = @pProfileName
      
    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0  
  END CATCH
END;



------------------------------------------------------------------------------------------ Created by fried
GO
CREATE PROCEDURE [dbo].[TEST_TRACING] 

AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
		VALUES (1101, 'S8888999Z', 'Li Bai Ka', '2015-01-13 10:00', '2016-06-25 17:30')
    END 

	BEGIN
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S1111222A', 'Lim Bo Chap', 'M', 'SINGAPOREAN', '1982-10-25', '90001234', 
				'Blk 144 HDB Teck Whye', 680144, '2014-01-29 05:00:00 AM', 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S3333444B', 'Tan Ah Boy', 'M', 'SINGAPOREAN', '1992-03-13','85554321', 
				'7 Jln Terang Bulan', 457285, '2015-01-29 12:00:00 PM', 1, 0)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S5555666Z', 'Ninjavan', 'F', 'MALAYSIAN', '1988-07-31', '87650000', 
				'Block 853 HDB Yishun', 760853, '2015-01-29 17:00:00', 0, 1)  
    END

	BEGIN
		INSERT INTO QUESTIONAIRE_ANS
		VALUES('SECOND_ANS_ID', 'SECOND', 'JSON ANSWERS FOR QUESTIONNARIE (Second)')
	END

	BEGIN
		INSERT INTO VISIT
		VALUES ('2015-01-29 10:00:00', 'S1111222A', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 12:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 14:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 16:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 18:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1101', 'SECOND_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 19:00:00', 'S5555666Z', 'Other Purpose', 'Delivery', 'CAFETERIA', NULL, 'FIRST_ANS_ID', '', 1)
	END 

	BEGIN
		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S1111222A', '2015-01-29 09:00:00', '37.2', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S3333444B', '2015-01-29 12:30:00', '36.8', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S3333444B', '2015-01-29 17:30:00', '37.1', 'asd@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', '37.0', 'asd@smu.edu.sg')
    END 

	BEGIN

		---------------------------------------------------------------------- Lim Bo Chap checks in earlier than time he registered to visit, and doesn't scan in.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 2, '2015-01-29 09:15:00')
		---------------------------------------------------------------------- Lim Bo Chap scans at place he didn't register to visit.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 7, '2015-01-29 09:15:20')
		---------------------------------------------------------------------- Lim Bo Chap doesn't scan out.

		---------------------------------------------------------------------- Tan Ah Boy scans in. He was checked in exactly between two registered visits.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 2, '2015-01-29 14:02:00')
		---------------------------------------------------------------------- Tan Ah Boy scans at place he registered to visit
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 4, '2015-01-29 14:10:00')
		---------------------------------------------------------------------- Tan Ah Boy scans out to grab a late lunch.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 3, '2015-01-29 15:45:00')
		---------------------------------------------------------------------- Tan Ah Boy has to check in again since he scanned out. The system scans him in.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 2, '2015-01-29 17:31:00')
		---------------------------------------------------------------------- Tan Ah Boy scans at the place he registered to visit, again.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 4, '2015-01-29 17:39:00')
		---------------------------------------------------------------------- Ninjavan scans in. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 2, '2015-01-29 18:47:00')
		---------------------------------------------------------------------- Tan Ah Boy scans out. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 3, '2015-01-29 19:00:00')
		---------------------------------------------------------------------- Ninjavan scans at place she didn't register to visit
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 4, '2015-01-29 19:10:00')
		---------------------------------------------------------------------- Ninjavan scans out. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 3, '2015-01-29 19:35:00')
		---------------------------------------------------------------------- Lim Bo Chap is scanned out by the system. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 3, '2015-01-29 23:50:00')
	END

END;


------------------------------------------------------------------------------------------created by fried
GO
CREATE PROCEDURE [dbo].[TEST_DATA_GENERATE]
AS
BEGIN
  SET NOCOUNT ON

    DECLARE  @return_value int,
        @responseMessage varchar(250)

    EXEC  @return_value = [dbo].[TEST_PERMISSIONS]
    EXEC  @return_value = [dbo].[TEST_ACCESS_PROFILE]
    EXEC  @return_value = [dbo].[TEST_CONFIG]
    EXEC  @return_value = [dbo].[TEST_VISITOR_PROFILE]
    EXEC  @return_value = [dbo].[TEST_TERMINAL]
    EXEC  @return_value = [dbo].[TEST_QUESTIONAIRE_QNS_LIST]
    EXEC  @return_value = [dbo].[TEST_QUESTIONAIRE_QNS]
    EXEC  @return_value = [dbo].[TEST_QUESTIONNAIRE_ANS]
    EXEC  @return_value = [dbo].[TEST_PATIENT]
    EXEC  @return_value = [dbo].[TEST_MOVEMENT]
    EXEC  @return_value = [dbo].[TEST_CREATE_STAFF]
        @responseMessage = @responseMessage OUTPUT
    EXEC  @return_value = [dbo].[TEST_CREATE_ADMIN]
        @responseMessage = @responseMessage OUTPUT
    EXEC  @return_value = [dbo].[TEST_CHECK_IN]
    EXEC  @return_value = [dbo].[TEST_VISIT]
    EXEC  @return_value = [dbo].[TEST_TRACING]
END;


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for Getting Patient's name
GO
CREATE PROCEDURE [dbo].[GET_PATIENT_NAME]  
@pBed_No VARCHAR(15),
@pPatient_Name VARCHAR(100) OUTPUT,   
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @pBed_No_Int INT
	SET @pBed_No_Int = CONVERT(INT, @pBed_No)
	--SET @pBed_No_Int = CAST(@pBed_No AS INT)
  
	IF EXISTS (SELECT patientFullName FROM PATIENT WHERE @pBed_No_Int = bedNo)  
	BEGIN    
		SET @responseMessage = 1
		SET @pPatient_Name = (SELECT TOP 1 patientFullName FROM PATIENT 
							  WHERE @pBed_No_Int = bedNo ORDER BY startDate DESC)
	END  
	 
    ELSE  
       SET @responseMessage = 0  
END; 


----------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[TEST_CONFIG] 
   
AS  
BEGIN  
  SET NOCOUNT ON  

  BEGIN
    INSERT INTO MASTER_CONFIG(lowerTempLimit, upperTempLimit, warnTemp, lowerTimeLimit, upperTimeLimit, visitLimit, dateUpdated, updatedBy)
    VALUES ('35', '39.9', '37.6', '09:00', '20:00', 3, SYSDATETIME(), 'MASTER')

    END 
END; 


------------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[TEST_ACCESS_PROFILE] 
   
AS  
BEGIN  
  SET NOCOUNT ON  

  BEGIN
    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Admin', 123456, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Infection Control', 2356, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Front Desk', 1, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Configurator', 234, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Facilities', 3, SYSDATETIME(), 'MASTER')

    END 
END;


--============= This is for Live DB to call the linked server & query the PATIENT DB ================================================================================================================
--GO
--CREATE PROCEDURE [dbo].[CONFIRM_HOSPITAL_PATIENT] 
--@pPatientFullName NVARCHAR(150),
--@pBedNo INT,
--@responseMessage VARCHAR(500) OUTPUT

--AS  
--BEGIN  
--  SET NOCOUNT ON  
--  DECLARE @pPatient_Detail VARCHAR(500)
--  DECLARE @pActiveQns TABLE (ADM_ID INT, Pat_NRIC VARCHAR(50), Pat_Name VARCHAR(200), ADM_Dt DATETIME, Bed VARCHAR(50))  

--  INSERT INTO @pActiveQns
--  SELECT * FROM OPENQUERY(APPSVR,'SELECT ADM_ID, Pat_NRIC, Pat_Name, ADM_Dt, Bed FROM [AMKH_InhouseDB].[dbo].[Current_Patient_list]')

--  IF(LEN(@pPatientFullName) > 5)
--  BEGIN
--    IF EXISTS (SELECT ADM_ID FROM @pActiveQns WHERE Pat_Name LIKE '%' + @pPatientFullName + '%' AND Bed = @pBedNo)
--    BEGIN
--      SET @pPatient_Detail = (SELECT (Pat_NRIC + ',' + Pat_Name + ',' + CAST(Bed AS VARCHAR(100))) FROM @pActiveQns WHERE Pat_Name LIKE '%' + @pPatientFullName + '%' AND Bed = @pBedNo)
--      SET @responseMessage = @pPatient_Detail
--    END
--    ELSE
--    BEGIN
--      SET @responseMessage = '0'
--    END
--    END
--    ELSE
--    BEGIN
--    IF EXISTS (SELECT ADM_ID FROM @pActiveQns WHERE Pat_Name = @pPatientFullName AND Bed = @pBedNo)
--    BEGIN
--      SET @pPatient_Detail = (SELECT (Pat_NRIC + ',' + Pat_Name + ',' + CAST(Bed AS VARCHAR(100))) FROM @pActiveQns WHERE Pat_Name = @pPatientFullName AND Bed = @pBedNo)
--    SET @responseMessage = @pPatient_Detail
--    END
--    ELSE
--    BEGIN
--      SET @responseMessage = '0'
--    END
--  END
--END;


--===========================================================================================================================================================================================




