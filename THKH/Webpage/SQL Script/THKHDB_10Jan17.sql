-- http://stackoverflow.com/questions/1260952/how-to-execute-a-stored-procedure-within-c-sharp-program For running stored procedures in C#  
-- I declare this region… mine! -- 
-- http://stackoverflow.com/questions/7770924/how-to-use-output-parameter-in-stored-procedure This explains how to read from the output from stored procedures 
-- To store Visitor Registration Data  

USE master;     
  
IF EXISTS(SELECT * from sys.databases WHERE name='thkhdb')    
BEGIN    
	DECLARE @DatabaseName NVARCHAR(50)  
	SET @DatabaseName = 'thkhdb'  
  
	DECLARE @SQL varchar(max)  
  	
	SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + CONVERT(VARCHAR, SPId) + ';'  
	FROM MASTER..SysProcesses  
	WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId  
      
	SELECT @SQL   
	EXEC(@SQL)  
  
	DROP DATABASE thkhdb;   
END

GO
CREATE DATABASE thkhdb;   
  
GO
USE thkhdb;  


---------------------------------------------------------------------------------------------------------------------------------------------------- To store the format of Pass 
GO
CREATE TABLE PASS_FORMAT
(
	passFormat VARCHAR(MAX) NOT NULL
); 


--------------------------------------------------------------------------------------------------------------------------------------------------- To Store Staff Data  
GO
CREATE TABLE STAFF  
(
--	staff_id  NOT NULL, 
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
	age INT NOT NULL,  
	race VARCHAR(50) NOT NULL,  
	passwordHash BINARY(64) NOT NULL, -- Hash it With SHA2-512 and add salt to further pad with randomization bits.  
	salt UNIQUEIDENTIFIER ,  
	permission INT NOT NULL, -- Access Control Level  
	position VARCHAR(50) NOT NULL, -- Doctor, Nurse, Admin....  
	dateCreated DATETIME NOT NULL,  
	dateUpdated DATETIME NOT NULL,  
	createdBy VARCHAR(100)
); -- Logged in Admin_ID  
  

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
	bedNo INT PRIMARY KEY NOT NULL, 
	nric VARCHAR(15) NOT NULL, 
	patientFullName VARCHAR(150) NOT NULL,
	startDate DATETIME,
	endDate DATETIME
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
	race VARCHAR(50) NOT NULL, 
	mobileTel VARCHAR(20),  
	homeTel VARCHAR(20), -- Visitors may not be from Singapore so no +65  
	altTel VARCHAR(20),
	email VARCHAR(200),   
	homeAddress VARCHAR(200) NOT NULL,
	postalCode INT NOT NULL, 
	time_stamp DATETIME NOT NULL,  
	confirm INT NOT NULL,
	amend INT NOT NULL
);


-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visit
GO
CREATE TABLE VISIT
(
	visitRequestTime DATETIME NOT NULL, 
	patientNric VARCHAR(15),  
	visitorNric VARCHAR(15) NOT NULL,  
	patientFullName VARCHAR(150), 
	purpose VARCHAR(1000) NOT NULL,
	reason VARCHAR(1000),
	visitLocation VARCHAR(300),    
	bedNo INT,  
	QaID VARCHAR(100) NOT NULL,
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
		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('EXIT', 1, 0, '2000-01-01 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('T1', 1, 1, '2016-01-01 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (2, '1101,1202,1303')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('T2', 1, 1, '2016-03-03 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (3, '1104,3205,5306')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('T3', 1, 1, '2016-06-06 00:00', NULL)
		INSERT INTO TERMINAL_BED(terminalID, bedNoList)
		VALUES (4, '5107,5208,5309')

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('CAFETERIA', 1, 0, '2016-06-06 00:00', NULL)

		INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
		VALUES ('ENTRANCE', 1, 1, '2016-06-06 00:00', NULL)
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
		VALUES ('S123', '2016-12-29 14:00', 2, '2016-12-29 14:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 14:00', 3, '2016-12-29 17:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-29 14:00', 4, '2016-12-29 22:00')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-29 20:00', 2, '2016-12-29 19:50')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 17:00', 2, '2016-12-29 17:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 17:00', 3, '2016-12-29 23:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-29 17:00', 1, '2016-12-29 23:31')


	---------------------------NEXT MOVEMENT PERIOD---------------------------------

	INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 14:00', 2, '2016-12-30 14:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 14:00', 3, '2016-12-30 17:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-30 14:00', 4, '2016-12-30 22:00')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2016-12-30 20:00', 2, '2016-12-30 19:50')

	------------------------------------------------------------------------------

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 17:00', 2, '2016-12-30 17:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 17:00', 3, '2016-12-30 23:01')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2016-12-30 17:00', 1, '2016-12-30 23:31')


	---------------------------NEXT MOVEMENT PERIOD---------------------------------

	INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 14:00', 2, '2016-12-31 14:10')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 14:00', 3, '2016-12-31 17:02')

		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2016-12-31 14:00', 4, '2016-12-31 22:00')

    END 
END; 


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[TEST_CREATE_STAFF]      
 	@pCreatedBy        VARCHAR(100) = 'MASTER',  
    @responseMessage   VARCHAR(250) OUTPUT  
  
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE @salt UNIQUEIDENTIFIER=NEWID()  
    
	BEGIN TRY  
        INSERT INTO staff (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
							dateOfBirth, age, race, PasswordHash, permission, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Shahid', 'Abdul', 'S12345', '417 Pasir Ris', 123417, '999', '999', '999', 'asd@smu.edu.sg', 'M', 'SINGAPOREAN', 
				'1991-01-01', 25, 'MY', HASHBYTES('SHA2_512', '123'),  123456 , 'Doctor', GETDATE(), GETDATE(), @pCreatedBy)  

		INSERT INTO staff (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
							dateOfBirth, age, race, PasswordHash, permission, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Aloysius', 'Lam', 'S9332934A', 'SMU', 123417, '999', '999', '999', 'aloysiuslam.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
				'1992-01-01', 25, 'MY', HASHBYTES('SHA2_512', '123'),  123456 , 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  
  
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
		VALUES (1, 'S9876543E', 'Benny Tan', '2016-07-11 09:00', '2020-01-01 00:00')
  
    END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Visitor
GO
CREATE PROCEDURE [dbo].[TEST_VISITOR_PROFILE] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S123', 'JASON', 'M', 'SINGAPOREAN', '1990-10-11', 'Chinese', '987654321', 
				'7878787878', '5656565656', 'JASON@hotmail.com', 'BLK 476 TAMPINES ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S456', 'Aloysius', 'M', 'SINGAPOREAN', '1990-10-11', 'Chinese', '987654321', 
				'7878787878', '5656565656', 'Aloys@hotmail.com', 'BLK 476 WOODLANDS ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S789', 'Chris', 'M', 'SINGAPOREAN', '1990-10-11', 'Chinese', '987654321', 
				'7878787878', '5656565656', 'chris@hotmail.com', 'BLK 476 BEDOK ST 44', 913476, GETDATE(), 0, 1)
		

		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S246', 'ZhengYuan', 'M', 'SINGAPOREAN', '1990-10-11', 'Chinese', '987654321', 
				'7878787878', '5656565656', 'zy@hotmail.com', 'BLK 476 KEMBANGAN ST 44', 913476, GETDATE(), 0, 1)
  
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
 	@pAge          INT,  
 	@pRace          VARCHAR(50),  
 	@pPermission      INT = 1,  
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
							dateOfBirth, age, race, PasswordHash, permission, position, dateCreated, dateUpdated, createdBy)  
        VALUES(@pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel, @pMobileTel, @pEmail, @pSex, @pNationality, 
				@pDOB, @pAge, @pRace, HASHBYTES('SHA2_512', @pPassword),  @pPermission ,@pPostion, GETDATE(), GETDATE(), @pCreatedBy)  
  
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

		SELECT SUBSTRING(email, 1, CHARINDEX('@', email) - 1), firstName, lastName, permission 
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
@pPassword VARCHAR(64),
@pFirstName VARCHAR(50),
@pLastName VARCHAR(50),
@pNric VARCHAR(100),  
@pAddress VARCHAR(200),
@pPostalCode INT,  
@pHomeTel VARCHAR(20), 
@pAltTel VARCHAR(20),
@pMobileTel VARCHAR(20),
@pSex CHAR(5),
@pNationality VARCHAR(500),
@pDateOfBirth DATE,
@pAge INT,
@pRace VARCHAR(50),
@pPermission INT,
@pPosition VARCHAR(50),
@pDateUpdated DATETIME,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		SET @pDateUpdated = SYSDATETIME();

		IF (EXISTS (SELECT email FROM STAFF WHERE nric= @pNric))
		BEGIN
			UPDATE STAFF
			SET passwordHash = HASHBYTES('SHA2_512', @pPassword), firstName = @pFirstName, lastName = @pLastName, address = @pAddress, postalCode = @pPostalCode,
				homeTel = @pHomeTel, altTel = @pAltTel, mobTel = @pMobileTel, sex= @pSex, nationality = @pNationality, dateOfBirth = @pDateOfBirth, age = @pAge,
				race = @pRace, permission = @pPermission, position = @pPosition, dateUpdated = @pDateUpdated
			WHERE nric = @pNRIC

			SET @responseMessage = 1 
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

	IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
	BEGIN
		SET @pPatient_Detail = (SELECT (nric + ',' + patientfullname + ',' + CAST(bedNo AS VARCHAR(100)))
		FROM PATIENT
		WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo)

		SET @responseMessage = @pPatient_Detail
	END

	ELSE
		SET @responseMessage = '0'
END; 


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for creating visitor's profile
GO
CREATE PROCEDURE [dbo].[CREATE_VISITOR_PROFILE] 
@pNRIC VARCHAR(15),  
@pFullName VARCHAR(150),
@pGender CHAR(5),
@pNationality VARCHAR(300),
@pDateOfBirth DATE,
@pRace VARCHAR(50),
@pMobileTel VARCHAR(20),
@pHomeTel VARCHAR(20), 
@pAltTel VARCHAR(20),
@pEmail VARCHAR(200), 
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
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pRace, @pMobileTel, 
				@pHomeTel, @pAltTel, @pEmail, @pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm, @pAmend)

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
@pRace VARCHAR(50),
@pMobileTel VARCHAR(20),
@pHomeTel VARCHAR(20), 
@pAltTel VARCHAR(20),
@pEmail VARCHAR(200), 
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
			SET nric = @pNRIC, fullName = @pFullName, gender= @pGender, nationality = @pNationality, dateOfBirth = @pDateOfBirth, race = @pRace, mobileTel = @pMobileTel, 
						homeTel = @pHomeTel, altTel = @pAltTel, email = @pEmail, homeAddress = @pHomeAddress, postalCode = @pPostalCode, time_stamp = @pTimestamp, confirm = '1'
			WHERE nric = @pNRIC AND time_stamp = @pLatestTimestamp 

			UPDATE VISITOR_PROFILE
			SET amend = 0
			WHERE nric = @pNRIC
		END
		
		ELSE
		BEGIN
			INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm, amend)
			VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pRace, @pMobileTel, 
				@pHomeTel, @pAltTel, @pEmail, @pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm, 0)
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
@returnValue VARCHAR(MAX) OUTPUT
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @visitorInfo VARCHAR(1000),
			@len BIGINT
 	 
	BEGIN
		SET @len = 0
		SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + race + ',' + mobileTel + ',' + 
					                     homeTel + ',' + altTel + ',' + email + ',' + homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
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
			SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + race + ',' + mobileTel + ',' + 
											 homeTel + ',' + altTel + ',' + email + ',' + homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
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
				SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + race + ',' + mobileTel + ',' + 
											 homeTel + ',' + altTel + ',' + email + ',' + homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108)) 
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
@pPatientNRIC VARCHAR(15) = '',  
@pVisitorNRIC VARCHAR(15),  
@pPatientFullName VARCHAR(150) = '',
@pPurpose VARCHAR(MAX) = '',
@pReason VARCHAR(MAX) = '',
@pVisitLocation VARCHAR(200) = '',
@pBedNo INT = 0,
@pQaID VARCHAR(100),
@pConfirm INT = 0,
@responseMessage INT OUTPUT  
-- Might need a timestamp for entry creation time

AS  
BEGIN  
	SET NOCOUNT ON  

	--IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
	BEGIN
		INSERT INTO VISIT(visitRequestTime, patientNric, visitorNric, patientFullName, purpose, reason, visitLocation, bedNo, QaID, confirm)
		VALUES (@pVisitRequestTime, @pPatientNRIC, @pVisitorNRIC, @pPatientFullName, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, @pConfirm)
	END
END; 


-----------------------------------------------------------------------------------------------------  Procedures for updating visits
GO
CREATE PROCEDURE [dbo].[UPDATE_VISIT]
@pVisitRequestTime DATETIME,  
@pPatientNRIC VARCHAR(15) = '',  
@pVisitorNRIC VARCHAR(15),  
@pPatientFullName VARCHAR(150) = '',
@pPurpose VARCHAR(MAX) = '',
@pReason VARCHAR(MAX) = '',
@pVisitLocation VARCHAR(150) = '',
@pBedNo INT = 0,
@pQaID VARCHAR(100),
@pConfirm INT = 1,
@responseMessage INT OUTPUT  
-- Might need a timestamp for entry creation time

AS  
BEGIN  
	SET NOCOUNT ON  
	-- Change NOT EXISTS to EXISTS once we have the patient information
	IF (EXISTS (SELECT visitorNric FROM dbo.VISIT WHERE visitorNric = @pVisitorNRIC 
		AND bedNo = @pBedNo AND visitRequestTime = @pVisitRequestTime))  
	BEGIN
		-- Have some logic to update visit
		UPDATE VISIT
		SET 
		--visitRequestTime = @pVisitRequestTime, 
		patientNric = @pPatientNRIC, 
		--visitorNric = @pVisitorNRIC, 
		patientFullName = @pPatientFullName, 
		purpose = @pPurpose, 
		reason = @pReason, 
		visitLocation = @pVisitLocation, 
		bedNo = @pBedNo, 
		QaID = @pQaID, 
		confirm = 1
		WHERE visitorNric = @pVisitorNRIC AND visitRequestTime = @pVisitRequestTime
	END

	ELSE
		INSERT INTO VISIT(visitRequestTime, patientNric, visitorNric, patientFullName, purpose, reason, visitLocation, bedNo, QaID, confirm)
		VALUES (@pVisitRequestTime, @pPatientNRIC, @pVisitorNRIC, @pPatientFullName, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, 1)
END; 


-----------------------------------------------------------------------------------------------------  Procedures for retrieving Visitor's details  
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
								 WHERE visitRequestTime <= SYSDATETIME() 
								 OR CONVERT(VARCHAR(20), visitRequestTime, 105) = CONVERT(VARCHAR(20), SYSDATETIME(), 105)))

		SET @pVisit_Details = (SELECT (CONVERT(VARCHAR(100), visitRequestTime, 105) + ' ' + CONVERT(VARCHAR(10), visitRequestTime, 108) + ',' +  
										patientNric + ',' + visitorNric + ',' + patientFullName + ',' + purpose  + ',' + reason  + ',' +  visitLocation  + ',' + 
										CAST(bedNo AS VARCHAR(100)) + ',' +  CAST(QaID AS VARCHAR(100))  + ',' +  CAST(confirm AS VARCHAR(5)))
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
	SET @pActualTimeVisit = SYSDATETIME()
	DECLARE @pOriginal_Staff_Email VARCHAR(200)
	
	SET @pOriginal_Staff_Email = (SELECT email FROM STAFF WHERE 
								  SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaffEmail)
  
	--IF (NOT EXISTS (SELECT nric FROM dbo.CHECK_IN WHERE staffEmail = @pOriginal_Staff_Email))  
	BEGIN TRY  
		--DECLARE @pSelectedVisitDate DATETIME

		INSERT INTO CHECK_IN(nric, visitActualTime, temperature, staffEmail)
		VALUES (@pNRIC, @pActualTimeVisit, @pTemperature, @pOriginal_Staff_Email)

		--SET @pSelectedVisitDate = (SELECT TOP 1 time_stamp FROM VISITOR_PROFILE WHERE nric = @pNRIC ORDER BY time_stamp DESC)

		SET @responseMessage = 1
	END TRY

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
	SET @pVisit_Date = (SELECT visitActualTime FROM CHECK_IN WHERE nric = @pNRIC AND
						CONVERT(VARCHAR(10), visitActualTime, 103) = CONVERT(VARCHAR(10), SYSDATETIME(), 103)) -- Compare Visit Date with System Date

	BEGIN TRY
		IF (@pVisit_Date != '')
		BEGIN
			INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
			VALUES (@pNRIC, @pVisit_Date, @pLocationID, SYSDATETIME())

 			SET @responseMessage = 1  
		END
		
		ELSE
			SET @responseMessage = 0 
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END; 


----------------------------------------------------------------------------------------------------------- Procedure for Checking-Out all visitors 
GO
CREATE PROCEDURE [dbo].[CHECK_OUT_ALL] 
@responseMessage INT OUTPUT  
-- In the MOVEMENT Table: 
-- Assuming that LocationID = '1' for Checking-out at the 'Exit' Gantry   

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pVisitor_To_Checkout TABLE (visitor_nric VARCHAR(10))

	INSERT INTO @pVisitor_To_Checkout (visitor_nric)
		SELECT DISTINCT nric FROM MOVEMENT 
		WHERE nric NOT IN (SELECT nric FROM MOVEMENT WHERE locationID = 1)
	
	IF ((SELECT COUNT(visitor_nric) FROM @pVisitor_To_Checkout) > 0)
	BEGIN TRY
		INSERT INTO MOVEMENT (nric, visitActualTime, locationID, locationTime)
			SELECT ci.nric, ci.visitActualTime, 1, SYSDATETIME() 
			FROM CHECK_IN ci
				INNER JOIN @pVisitor_To_Checkout vc ON
				ci.nric = vc.visitor_nric

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

----------------------------------------------------------------------------------------------------- Procedure for getting question order
GO
CREATE PROCEDURE [dbo].[GET_SELECTED_QUESTIONNARIE_ORDER]  
@pQ_QuestionList_ID VARCHAR(100),
@responseMessage INT OUTPUT

AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pOrder_QQ_ID VARCHAR(100)
	
	SELECT Q_Order FROM QUESTIONAIRE_QNS_LIST 
						 WHERE Q_QuestionListID = @pQ_QuestionList_ID AND endDate IS NULL

		SET @responseMessage = 1
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


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors who have contacted with the Patient  
--GO
--CREATE PROCEDURE [dbo].[TRACE_BY_PATIENT_NRIC]  
--@pBedNo INT,
--@pStartDate DATETIME,
--@pEndDate DATETIME,
--@responseMessage INT OUT

--AS  
--BEGIN  
--	SET NOCOUNT ON  

--	IF EXISTS (SELECT nric FROM PATIENT WHERE bedNo = @pBedNo AND 
--				startDate <= @pEndDate AND endDate >= @pStartDate)
--	BEGIN TRY  
--		SET @responseMessage = 1 

--		SELECT a.visitorNric FROM VISIT a
--			INNER JOIN PATIENT b ON a.patientNric = b.nric
--			INNER JOIN MOVEMENT c ON a.visitorNric = c.nric
--		WHERE b.bedNo = @pBedNo AND b.startDate = @pStartDate AND b.endDate = @pEndDate 
--    END TRY  

--    BEGIN CATCH  
--        SET @responseMessage = 0
--    END CATCH 

--	ELSE
--		SET @responseMessage = 0
--END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Terminal  
--GO
--CREATE PROCEDURE [dbo].[VISITOR_BY_TERMINAL]  
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pTerminal_ID INT,
--@responseMessage INT OUT

--AS  
--BEGIN  
--	SET NOCOUNT ON
	--DECLARE @pTrace_Visitor TABLE (vNRIC VARCHAR(10), startDate DATETIME, endDate DATETIME)
	--DECLARE @pCountVisitor INT

	--INSERT INTO @pTrace_Visitor
		--SELECT vp.nric, m.locationTime, (SELECT TOP 1 locationTime FROM MOVEMENT 
										 --WHERE locationTime > @pEnd_Date ORDER BY locationTime ASC) 
		--FROM VISITOR_PROFILE vp INNER JOIN MOVEMENT m 
		--ON vp.nric = m.nric
		--WHERE m.locationID = @pTerminal_ID
		--AND m.locationTime >= @pStart_Date
	
	--SET @pCountVisitor = (SELECT COUNT(DISTINCT vNRIC) FROM @pTrace_Visitor)
	
	--IF (@pCountVisitor > 0)
	--BEGIN
		--SET @responseMessage = 1
		--SELECT * FROM @pTrace_Visitor
		--ORDER BY vNRIC ASC
	--END

	--ELSE
		--SET @responseMessage = 0
--END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
--GO
--CREATE PROCEDURE [dbo].[CHECKIN_BY_VISITOR]  
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pVisitor_Nric VARCHAR(15),
--@responseMessage INT OUT

--AS  
--BEGIN  
--	SET NOCOUNT ON
--	DECLARE @pTrace_Visitor TABLE (vNRIC VARCHAR(10), vFullName VARCHAR(200), checkin_time DATETIME)
--	DECLARE @pCountVisitor INT

--	INSERT INTO @pTrace_Visitor
--		SELECT vp.nric, vp.fullName, ci.visitActualTime
--		FROM VISITOR_PROFILE vp
--			INNER JOIN CHECK_IN ci ON vp.nric = ci.nric
--		WHERE vp.nric = @pVisitor_Nric
--		AND ci.visitActualTime BETWEEN @pStart_Date AND @pEnd_Date
	
--	SET @pCountVisitor = (SELECT COUNT(DISTINCT vNRIC) FROM @pTrace_Visitor)
	
--	IF (@pCountVisitor > 0)
--	BEGIN
--		SET @responseMessage = 1
--		SELECT * FROM @pTrace_Visitor
--		ORDER BY vNRIC
--	END

--	ELSE
--		SET @responseMessage = 0
--END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
--GO
--CREATE PROCEDURE [dbo].[BedNO_BY_TERMINAL]  
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pPatient_Nric VARCHAR(15),
--@responseMessage INT OUT

--AS  
--BEGIN  
--	SET NOCOUNT ON
--	DECLARE @pTrace_Patient TABLE (pNRIC VARCHAR(10), pBedNo INT)
--	DECLARE @pReturn_Terminal TABLE (terminalID INT)
--	DECLARE @pCount INT
--	DECLARE @pPatient_BedNo VARCHAR(10)
	
--	INSERT INTO @pTrace_Patient
--		SELECT nric, bedNo
--		FROM PATIENT
--		WHERE nric = @pPatient_Nric
--		AND startDate <= @pEnd_Date
--		AND endDate >= @pStart_Date
	
--	INSERT INTO @pReturn_Terminal
--		SELECT terminalID
--		FROM TERMINAL_BED tb INNER JOIN @pTrace_Patient tp 
--		ON tp.pBedNo IN 
--		(
--			SELECT * FROM dbo.FUNC_SPLIT(tb.bedNoList, ',')
--		)

--	SET @pCount = (SELECT COUNT(DISTINCT terminalID) FROM @pReturn_Terminal)
	
--	IF (@pCount > 0)
--	BEGIN
--		SET @responseMessage = 1
--		SELECT * FROM @pReturn_Terminal
--	END

--	ELSE
--		SET @responseMessage = 0
--END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
--GO
--CREATE PROCEDURE [dbo].[GET_TERMINAL_BY_TRACE]  
--@pStart_Date DATETIME,
--@pEnd_Date DATETIME,
--@pLevel VARCHAR(50),
--@pData VARCHAR(50),
--@responseMessage INT OUT

--AS  
--BEGIN  
--	SET NOCOUNT ON
--	DECLARE @pBedNo_Within_Date TABLE (tID INT, tName VARCHAR(100), bedNo VARCHAR(10))
--	DECLARE @pVaild_Bed TABLE (bedNo VARCHAR(50))
--	DECLARE @pInvaild_Bed TABLE (invaild_bedNo VARCHAR(50))
--	DECLARE @pReturn_Terminal TABLE (tID INT, tName VARCHAR(100))
	
--	BEGIN
--		INSERT INTO @pBedNo_Within_Date
--			SELECT t.terminalID, tName, beds.Element FROM TERMINAL t
--				INNER JOIN TERMINAL_BED tb ON t.terminalID = tb.terminalID 
--				OUTER APPLY dbo.FUNC_SPLIT(tb.bedNoList, ',') beds
--			WHERE startDate <= @pEnd_Date
--			AND endDate >= @pStart_Date
--	END

--	IF ((SELECT COUNT(bedno) FROM @pBedNo_Within_Date) > 0)
--	BEGIN 
--		INSERT INTO @pVaild_Bed
--			SELECT * FROM dbo.FUNC_SPLIT(@pData, ',')

--		INSERT INTO @pReturn_Terminal
--			SELECT CASE 
--						WHEN @pLevel = 'ward' AND @pData = (SELECT SUBSTRING(bedNo, 1, 1)) 
--						THEN (SELECT DISTINCT tID)

--						WHEN @pLevel = 'wing' AND @pData = (SELECT SUBSTRING(bedNo, 2, 2)) 
--						THEN (SELECT DISTINCT tID)
--					END AS Terminal_ID, tName
--			FROM @pBedNo_Within_Date

--		INSERT INTO @pReturn_Terminal
--			SELECT CASE WHEN @pLevel = 'bed' AND bedNo IN (SELECT * FROM @pVaild_Bed) 
--						THEN (SELECT DISTINCT tID)
--					END AS Terminal_ID, tName
--			FROM @pBedNo_Within_Date

--		INSERT INTO @pInvaild_Bed
--			SELECT CASE WHEN @pLevel = 'bed' AND bedNo NOT IN (SELECT bedNo FROM @pBedNo_Within_Date) 
--						THEN (SELECT bedNo)
--					END AS Bed_No
--			FROM @pVaild_Bed		
--	END 

--	ELSE
--		SET @responseMessage = 0
	
--	IF ((SELECT COUNT(tID) FROM @pReturn_Terminal) > 0)
--		SELECT DISTINCT tID, tName 
--		FROM @pReturn_Terminal WHERE tID IS NOT NULL
--	ELSE 
--		SET @responseMessage = 0

--	IF ((SELECT COUNT(tID) FROM @pReturn_Terminal) > 0 AND @pLevel = 'bed')
--		SELECT DISTINCT tID, tName 
--		FROM @pReturn_Terminal WHERE tID IS NOT NULL
--	ELSE 
--		SET @responseMessage = 0
	
--	IF (@pLevel = 'bed' AND (SELECT COUNT(*) FROM @pInvaild_Bed) > 0)
--		SELECT invaild_bedNo FROM @pInvaild_Bed	WHERE invaild_bedNo IS NOT NULL
--END; 


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
		SET @responseMessage = CAST((SELECT COUNT(DISTINCT nric) AS checkedIn 
									 FROM MOVEMENT
									 WHERE locationID <> 1 
									 AND nric IN (SELECT DISTINCT nric FROM CHECK_IN
												  WHERE nric IN (SELECT visitorNric FROM VISIT WHERE bedNo = @pBedNo) 
												  AND DAY(visitActualTime) = DAY(GETDATE()) 
												  AND MONTH(visitActualTime) = MONTH(GETDATE()) 
												  AND YEAR(visitActualTime) = YEAR(GETDATE())) 
												  AND nric NOT IN (SELECT DISTINCT nric FROM MOVEMENT WHERE locationID = 1
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

	BEGIN TRY
		UPDATE PASS_FORMAT
		SET passFormat = @pPass_Format   

		SET @responseMessage = 1
	END TRY
	
	BEGIN CATCH
		SET @responseMessage = 0	
	END CATCH  
END; 


