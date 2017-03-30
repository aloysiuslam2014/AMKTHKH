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

USE MASTER;     

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


------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE TABLE SMS
(
  mid VARCHAR(500) NOT NULL,
  contactNumber VARCHAR(100) NOT NULL,
  messageBody VARCHAR(MAX) NOT NULL,
  sendTime DATETIME NOT NULL
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
  
-- Add Admin account into staff table --
INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('THK', 'admin', 'S2548934A', 'SMU', 123417, '999', '999', '999', 'admin@amk.org.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '@mkd3nt'),  123456, 'Front Desk', 'Admin', GETDATE(), GETDATE(), @pCreatedBy) ; 
------------------------------------------------------------------------------------------------------- Table to store Access Profile
GO
CREATE TABLE ACCESS_PROFILE  
(
  profileName VARCHAR(100) PRIMARY KEY NOT NULL,
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
CREATE TABLE VISIT
(
  visitRequestTime DATETIME NOT NULL, 
  --patientNric VARCHAR(15),  
  visitorNric VARCHAR(15) NOT NULL,  
  --patientFullName VARCHAR(150), 
  purpose VARCHAR(1000) NOT NULL,
  reason VARCHAR(1000),
  visitLocation VARCHAR(300),    
  bedNo VARCHAR(MAX),  
  QaID VARCHAR(100) NOT NULL,
  remarks VARCHAR(MAX),
  confirm INT,
  createdOn DATETIME   
  FOREIGN KEY (QaID) REFERENCES QUESTIONAIRE_ANS(QA_ID),
  CONSTRAINT PK_VISIT PRIMARY KEY (visitRequestTime, visitorNric, createdOn)
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



-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[CREATE_STAFF]     
   @pEmail          VARCHAR(200), 
   @pPassword        VARCHAR(64),  
   @pFirstName        VARCHAR(50),   
   @pLastName        VARCHAR(50),  
   @pNric          VARCHAR(15) = '',  
   @pAddress        VARCHAR(200) = '',  
   @pPostal        INT = '',  
   @pHomeTel        VARCHAR(20) = '',  
   @pAltTel        VARCHAR(20) = '',  
   @pMobileTel        VARCHAR(20) = '',   
   @pSex          CHAR(5),  
   @pNationality      VARCHAR(300),  
   @pDOB          DATE,   
   @pPermission      INT = 1,
   @pAccessProfile    VARCHAR(100), 
   @pPostion        VARCHAR(100),   
   @pCreatedBy        VARCHAR(100) = 'MASTER',  
   @responseMessage   NVARCHAR(250) OUTPUT  
  
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE @salt UNIQUEIDENTIFIER=NEWID()  
    
  BEGIN TRY  
        INSERT INTO staff (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES(@pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel, @pMobileTel, @pEmail, @pSex, @pNationality, 
        @pDOB, HASHBYTES('SHA2_512', @pPassword),  @pPermission, @pAccessProfile,@pPostion, GETDATE(), GETDATE(), @pCreatedBy)  
  
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
		SET @pDateUpdated = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00');

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
		SET @pTimestamp = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00');
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
		SET @pTimestamp = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00');
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
@pBedNo VARCHAR(MAX) = '',
@pQaID VARCHAR(100),
@pRemarks VARCHAR(MAX) = '',
@pConfirm INT = 0,
@responseMessage INT OUTPUT  
--Might need a timestamp for entry creation time

AS  
BEGIN  
  SET NOCOUNT ON  

  --IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
  BEGIN
    BEGIN TRY
      INSERT INTO VISIT(visitRequestTime, visitorNric, purpose, reason, visitLocation, bedNo, QaID, remarks, confirm, createdOn)
      VALUES (@pVisitRequestTime, @pVisitorNRIC, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, @pRemarks, @pConfirm, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

      SET @responseMessage = 1
    END TRY
    BEGIN CATCH
      SET @responseMessage = 0
    END CATCH
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
--Might need a timestamp for entry creation time

AS  
BEGIN  
  SET NOCOUNT ON  
  IF (EXISTS (SELECT visitorNric FROM dbo.VISIT WHERE visitorNric = @pVisitorNRIC 
        AND bedNo = @pBedNo AND visitLocation = @pVisitLocation AND visitRequestTime = @pVisitRequestTime))  
  BEGIN
  BEGIN TRY
    UPDATE VISIT
    SET 
    purpose = @pPurpose, 
    reason = @pReason, 
    visitLocation = @pVisitLocation, 
    bedNo = @pBedNo, 
    QaID = @pQaID,
    remarks = @pRemarks,
    confirm = 1,
    createdOn = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
    WHERE visitorNric = @pVisitorNRIC AND visitRequestTime = @pVisitRequestTime

    SET @responseMessage = 1
  END TRY
  BEGIN CATCH
    SET @responseMessage = 0
  END CATCH
  END

  ELSE
    BEGIN TRY
      INSERT INTO VISIT(visitRequestTime, visitorNric, purpose, reason, visitLocation, bedNo, QaID, remarks, confirm, createdOn)
      VALUES (@pVisitRequestTime, @pVisitorNRIC, @pPurpose, @pReason, @pVisitLocation, @pBedNo, @pQaID, @pRemarks, 1, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

      SET @responseMessage = 1
    END TRY
    BEGIN CATCH
      SET @responseMessage = 0
    END CATCH
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
@pActualTimeVisit DATETIME = NULL,
@pTemperature VARCHAR(10),
@pStaffEmail VARCHAR(200),
@responseMessage INT OUTPUT  
  
AS  
BEGIN 
  SET NOCOUNT ON
  SET @pActualTimeVisit = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
  DECLARE @pOriginal_Staff_Email VARCHAR(200)
  DECLARE @pLast_CheckIn_Time DATETIME
  DECLARE @pLast_Location_Id INT
  DECLARE @pLast_Location VARCHAR(150)

  --DECLARE @pCheckedOut INT
  --DECLARE @pCheckedIn INT
  
  --SET @pCheckedOut = (SELECT COUNT(*)
  --           FROM MOVEMENT WHERE nric = @pNric
  --           AND visitActualTime = (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric)
  --            AND locationID = 2)
  --SET @PCheckedIn = (SELECT COUNT(*)
  --            FROM MOVEMENT WHERE nric = @pNric
  --           AND visitActualTime = (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric)
  --            AND locationID <> 2)
  
  SET @pLast_CheckIn_Time = (SELECT MAX(locationTime) FROM MOVEMENT WHERE nric = @pNric)
  
  SET @pLast_Location_Id = (SELECT TOP 1 locationID FROM MOVEMENT 
						WHERE nric = @pNric AND locationTime = @pLast_CheckIn_Time)
  
  SET @pLast_Location = (SELECT tName FROM TERMINAL
						WHERE terminalID = @pLast_Location_Id)

  SET @pOriginal_Staff_Email = (SELECT email FROM STAFF WHERE 
                  SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaffEmail)

  --IF(@pCheckedIn > 0)
  --BEGIN
	IF(@pLast_Location NOT LIKE '%EXIT%') -- Visitor has not check out during their last visit
	BEGIN
      INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
      VALUES (@pNRIC, (SELECT MAX(visitActualTime) FROM MOVEMENT WHERE nric = @pNric 
						AND locationTime = @pLast_CheckIn_Time), 
			  2, @pActualTimeVisit)
    END
  --END

  BEGIN TRY  
    INSERT INTO CHECK_IN(nric, visitActualTime, temperature, staffEmail)
    VALUES (@pNRIC, @pActualTimeVisit, @pTemperature, @pOriginal_Staff_Email)

   INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
      VALUES (@pNRIC, @pActualTimeVisit, 1, DATEADD(ss,1,@pActualTimeVisit))

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
DECLARE @pLast_LocationID INT
SET @pVisit_Date = (SELECT TOP 1 visitActualTime FROM CHECK_IN WHERE nric = @pNRIC AND
					CONVERT(VARCHAR(10), visitActualTime, 103) = CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103)
					ORDER BY visitActualTime DESC) -- Compare Visit Date with System Date
SET @pLast_LocationID = (SELECT TOP 1 locationID FROM MOVEMENT WHERE nric = @pNRIC AND
						CONVERT(VARCHAR(10), locationTime, 103) = CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103)
						ORDER BY locationTime DESC)

DECLARE @pLast_Location VARCHAR(200)
SET @pLast_Location = (SELECT tName FROM TERMINAL WHERE terminalID = @pLast_LocationID)
  
IF (@pVisit_Date != '')
BEGIN TRY
	IF (@pLast_Location NOT LIKE '%EXIT%' OR @pLast_Location = '')
	BEGIN
		IF EXISTS (SELECT bedNoList FROM TERMINAL_BED WHERE terminalID = @pLocationID)
		BEGIN
			DECLARE @pVisitingBedTb TABLE (bedno VARCHAR(10))
			DECLARE @pTerminalBedTb TABLE (bedno VARCHAR(10))

			DECLARE @pVisiting_Bedno VARCHAR(MAX)
			DECLARE @pTerminal_Bedno VARCHAR(MAX)

			SET @pVisiting_Bedno = (SELECT TOP 1 bedNo FROM VISIT WHERE visitorNric = @pNric AND
									CONVERT(VARCHAR(10), visitRequestTime, 103) = CONVERT(VARCHAR(10), SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), 103)
									ORDER BY visitRequestTime DESC)
			SET	@pTerminal_Bedno = (SELECT bedNoList FROM TERMINAL_BED WHERE terminalID = @pLocationID)

			INSERT INTO @pVisitingBedTb 
				SELECT * FROM dbo.FUNC_SPLIT(@pVisiting_Bedno, ',')
			
			INSERT INTO @pTerminalBedTb 
				SELECT * FROM dbo.FUNC_SPLIT(@pTerminal_Bedno, ',')
      
			IF EXISTS (SELECT vb.bedno FROM @pVisitingBedTb vb WHERE vb.bedno IN (SELECT tb.bedno FROM @pTerminalBedTb tb))
			BEGIN
			-- Retrieve Patient's BedNo according to the Visitor's registered Visit
				INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
				VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

				SET @responseMessage = 1
			END      
			ELSE
			BEGIN
				-- If Patient's BedNo does not exist in Visitor's 
				INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
				VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
    
				SET @responseMessage = 2
			END
		END 

		ELSE
		BEGIN
			-- For visiting Facility in the hospital. (E.g. Pharmacy, Cafeteria, etc)
			INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
			VALUES (@pNRIC, @pVisit_Date, @pLocationID, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))

			SET @responseMessage = 1
		END
    END
    
	ELSE
    BEGIN
      -- Visitor has not registered at the counter or has already checked out
		SET @responseMessage = 3
    END

	END TRY
	BEGIN CATCH  
		SET @responseMessage = 0 
	END CATCH 
    
	-- Visitor do not have any VISIT and CHECK_IN record
	ELSE
	BEGIN
		SET @responseMessage = 0
	END
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
		WHERE nric NOT IN (SELECT nric FROM MOVEMENT WHERE locationID = 2)
	
	IF ((SELECT COUNT(visitor_nric) FROM @pVisitor_To_Checkout) > 0)
	BEGIN TRY
		INSERT INTO MOVEMENT (nric, visitActualTime, locationID, locationTime)
			SELECT ci.nric, ci.visitActualTime, 2, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
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
   
  IF (NOT EXISTS (SELECT terminalID FROM TERMINAL WHERE tName = @pTName) OR EXISTS(SELECT terminalID FROM TERMINAL WHERE tName = @pTName and endDate IS NOT NULL))
  BEGIN TRY
    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES (@pTName, 0, @pTControl, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), NULL)

    IF (@pBedNoList != '' OR @pBedNoList IS NULL)
    BEGIN
      DECLARE @pTerminal_Id INT
      SET @pTerminal_Id = (SELECT top 1 (terminalID) FROM TERMINAL WHERE tName = @pTName order by startDate desc)
    
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
		SET endDate = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')

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
		SET endDate = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
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
		WHERE terminalID = @pTerminal_ID AND endDate IS NULL
    
		IF (@@ROWCOUNT = 1)
			SET @responseMessage = 1  
		ELSE 
			SET @responseMessage = 0  
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
		VALUES (@pQuestion, @pQnsType, @pQnsValue, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), NULL)

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
			SET question = @pQuestion, qnsType = @pQnsType, qnsValue = @pQnsValue, startDate = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
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
		SET endDate = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
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
       		VALUES(@pQ_QuestionListID, @pQ_Order, @pQ_Active, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), NULL)  
  
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
       		VALUES(@pQ_QuestionListID, '', @pQ_Active, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'), NULL)  
  
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
		SET endDate = SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00')
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
                  AND nric NOT IN (SELECT DISTINCT nric FROM MOVEMENT WHERE locationID = 2
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
	WITH DAY_BED_CHECKINS(nric, visitActualTime, temperature, bedNo, visitLocation, qa_json)
	AS
	(
		SELECT ci.nric, ci.visitActualTime, ci.temperature, v.bedNo, v.visitLocation, qa.QA_JSON
		FROM CHECK_IN ci
		LEFT JOIN VISIT v ON v.visitorNric = ci.nric
		LEFT JOIN QUESTIONAIRE_ANS qa ON qa.QA_ID = v.QaID
		WHERE v.bedNo LIKE '%'+ @pBed_No_Var +'%'
		AND CAST(ci.visitActualTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
		AND v.confirm = 1
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
	SELECT DISTINCT dbc.visitLocation AS 'location',  dbc.bedNo AS 'bedNo', dbc.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbc.temperature AS 'temperature', dbc.nric AS 'nric', vp.fullName AS 'fullName', vp.gender AS 'gender', vp.dateOfBirth AS 'dob', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel', vp.homeAddress AS 'homeadd',  vp.postalCode AS 'postalcode', dbc.qa_json AS 'formAnswers', vp.confirm AS 'confirmed'
		FROM DAY_BED_CHECKINS dbc
		LEFT JOIN DAY_BED_EXITS dbe ON dbe.nric = dbc.nric AND dbe.visitActualTime = dbc.visitActualTime
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbc.nric
		WHERE vp.confirm = 1
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
		WITH DAY_BED_SCANS (nric, visitActualTime, temperature, locationID, locationTime, bedNoList, qa_json)
		AS
		(
			SELECT DISTINCT m.nric, m.visitActualTime, ci.temperature, m.locationID, m.locationTime, tb.bedNoList, qa.QA_JSON
			FROM MOVEMENT m
			LEFT JOIN TERMINAL_BED tb ON m.locationID = tb.terminalID
			LEFT JOIN CHECK_IN ci ON ci.nric = m.nric AND ci.visitActualTime = m.visitActualTime
			LEFT JOIN VISIT v ON v.visitorNric = m.nric
			LEFT JOIN QUESTIONAIRE_ANS qa ON qa.QA_ID = v.QaID
			WHERE tb.bedNoList LIKE '%'+ @pBed_No_Var +'%'
			AND CAST(m.locationTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
			AND v.confirm = 1
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
		SELECT DISTINCT v.visitLocation AS 'location',  v.bedNo AS 'bedNo', dbs.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbs.temperature AS 'temperature', dbs.nric AS 'nric', vp.fullName AS 'fullName', vp.gender AS 'gender', vp.dateOfBirth AS 'dob', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel', vp.homeAddress as 'homeadd', vp.postalCode as 'postalcode', dbs.qa_json AS 'formAnswers', vp.confirm AS 'confirmed'
		FROM DAY_BED_SCANS dbs 
		LEFT JOIN DAY_BED_EXITS dbe ON dbs.nric = dbe.nric AND dbe.visitActualTime = dbs.visitActualTime
		LEFT JOIN VISIT v ON v.visitorNric = dbs.nric AND CAST(v.visitRequestTime AS DATE) = CAST(dbs.visitActualTime AS DATE)
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbs.nric
		WHERE vp.confirm = 1
	END
END;


-------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[TRACE_BY_REG_LOC]  
@pStart_Date DATE,
@pEnd_Date DATE,
@pLocation VARCHAR(128),
@responseMessage INT OUT

AS  
BEGIN  
  SET NOCOUNT ON
  
  BEGIN
    SET @responseMessage = 1;

	------------------------------------------------ First retrieve all registered visits to the location
	------------------------------------------------ in question which checked in within query period
	WITH DAY_BED_CHECKINS(nric, visitActualTime, temperature, bedNo, visitLocation, qa_json)
	AS
	(
		SELECT DISTINCT ci.nric, ci.visitActualTime, ci.temperature, v.bedNo, v.visitLocation, qa.QA_JSON
		FROM CHECK_IN ci
		LEFT JOIN VISIT v ON v.visitorNric = ci.nric
		LEFT JOIN QUESTIONAIRE_ANS qa ON qa.QA_ID = v.QaID
		WHERE v.visitLocation LIKE '%' + @pLocation + '%'
		AND CAST(ci.visitActualTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
		AND v.confirm = 1
	),
	DAY_BED_EXITS (nric, visitActualTime, exitTerminal, exitTime)
		AS
		(
			SELECT dbc.nric, dbc.visitActualTime, t.tName, m.locationTime
			FROM DAY_BED_CHECKINS dbc	
			LEFT JOIN MOVEMENT M ON m.NRIC = dbc.nric
				AND m.visitActualTime = dbc.visitActualTime
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			WHERE t.tName LIKE 'EXIT%'
		)
	SELECT DISTINCT dbc.visitLocation AS 'location',  dbc.bedNo AS 'bedNo', dbc.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbc.temperature AS 'temperature', dbc.nric AS 'nric', vp.fullName AS 'fullName', vp.gender AS 'gender', vp.dateOfBirth AS 'dob', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel', vp.homeAddress AS 'homeadd', vp.postalCode AS 'postalcode', dbc.qa_json AS 'formAnswers', vp.confirm AS 'confirmed'
		FROM DAY_BED_CHECKINS dbc
		LEFT JOIN DAY_BED_EXITS dbe ON dbe.nric = dbc.nric AND dbe.visitActualTime = dbc.visitActualTime
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbc.nric
		WHERE vp.confirm = 1
  END
END;

-------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[TRACE_BY_SCAN_LOC]  -- Retrieve every visitor so long as they scanned in the given Bedno
@pStart_Date DATE,
@pEnd_Date DATE,
@pLocation VARCHAR(128),
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON

	BEGIN
		SET @responseMessage = 1;
		------------------------------------------------ First retrieve all visits to the location in question
		------------------------------------------------ which were scanned within the query period
		WITH DAY_BED_SCANS (nric, visitActualTime, temperature, locationID, locationTime, bedNoList, qa_json)
		AS
		(
			SELECT DISTINCT m.nric, m.visitActualTime, ci.temperature, m.locationID, m.locationTime, t.tName, qa.QA_JSON
			FROM MOVEMENT m
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			LEFT JOIN CHECK_IN ci ON ci.nric = m.nric AND ci.visitActualTime = m.visitActualTime
			LEFT JOIN VISIT v ON v.visitorNric = m.nric
			LEFT JOIN QUESTIONAIRE_ANS qa ON qa.QA_ID = v.QaID
			WHERE t.tName LIKE '%' + @pLocation + '%'
			AND CAST(m.locationTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
			AND v.confirm = 1
		),		
		------------------------------------------------ Find the corresponding exit terminals and exit times
		DAY_BED_EXITS (nric, visitActualTime, locationTime, exitTerminal, exitTime)
		AS
		(
			SELECT dbs.nric, dbs.visitActualTime, dbs.locationTime, t.tName, m.locationTime
			FROM DAY_BED_SCANS dbs	
			LEFT JOIN MOVEMENT M ON m.NRIC = dbs.nric
				AND m.visitActualTime = dbs.visitActualTime
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			WHERE t.tName LIKE 'EXIT%'
		)
		SELECT DISTINCT v.visitLocation AS 'location',  v.bedNo AS 'bedNo', dbs.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbs.temperature AS 'temperature', dbs.nric AS 'nric', vp.fullName AS 'fullName', vp.gender AS 'gender',vp.dateOfBirth AS 'dob', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel', vp.homeAddress AS 'homeadd', vp.postalCode AS 'postalcode', dbs.qa_json AS 'formAnswers', vp.confirm AS 'confirmed'
		FROM DAY_BED_SCANS dbs 
		LEFT JOIN DAY_BED_EXITS dbe ON dbs.nric = dbe.nric AND dbe.visitActualTime = dbs.visitActualTime
		LEFT JOIN VISIT v ON v.visitorNric = dbs.nric AND CAST(v.visitRequestTime AS DATE) = CAST(dbs.visitActualTime AS DATE)
		LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbs.nric
		WHERE vp.confirm = 1
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


-----------------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[RECORD_SMS]  
@pSID VARCHAR(500),
@pContact VARCHAR(100),
@pMessage VARCHAR(MAX),
@responseMessage INT OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  
  
  BEGIN TRY
    INSERT INTO SMS (mid, contactNumber, messageBody, sendTime)
    VALUES(@pSID, @pContact, @pMessage, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+08:00'))
  
    SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0
    END CATCH 
END;


---------------------------------------------------------------------------------------------------  Procedure for retrieving all visitors for dashboard  
GO
CREATE PROCEDURE [dbo].[GET_VISITORS_BY_DATES]  
@pStart_Date DATE,
@pEnd_Date DATE,
@responseMessage INT OUT

AS  
BEGIN  
  SET NOCOUNT ON
  
  BEGIN
    SET @responseMessage = 1;

	WITH DAY_BED_EXITS (nric, visitActualTime, exitTerminal, exitTime)
		AS
		(
			SELECT ci.nric, ci.visitActualTime, t.tName, m.locationTime
			FROM CHECK_IN ci	
			FULL OUTER JOIN MOVEMENT M ON m.NRIC = ci.nric
				AND m.visitActualTime = ci.visitActualTime
			LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
			WHERE t.tName LIKE 'EXIT%'
		)
	SELECT DISTINCT v.visitLocation AS 'location', v.bedNo AS 'bedno', ci.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', ci.nric AS 'nric', vp.gender AS 'gender', vp.dateOfBirth AS 'dob'
	FROM CHECK_IN ci
	LEFT JOIN VISITOR_PROFILE vp ON vp.nric = ci.nric
	LEFT JOIN VISIT v ON v.visitorNric = ci.nric
	LEFT JOIN DAY_BED_EXITS dbe ON dbe.nric = ci.nric AND dbe.visitActualTime = ci.visitActualTime
	WHERE vp.confirm = 1
	AND v.confirm = 1
	AND CAST(ci.visitActualTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
  END
END;

---------------------------------------------------------------------------------------------------  Procedure for retrieving location for dashboard  
GO
CREATE PROCEDURE [dbo].[GET_LOC_BY_BEDNO]  
@pBedno VarChar(100),
@responseMessage INT OUT

AS  
BEGIN  
  SET NOCOUNT ON
  
  BEGIN
    SET @responseMessage = 1;

	SELECT DISTINCT t.tName AS 'location'
	FROM TERMINAL t
	LEFT JOIN TERMINAL_BED tb ON t.terminalID = tb.terminalID
	WHERE tb.bedNoList LIKE '%'+ @pBedno +'%'
  END
END;


------------------------------------------------------------------------------------------- Procedures for Getting partial Patient's name
GO
CREATE PROCEDURE [dbo].[AUTOCOMPLETE_PATIENT_NAME]  
@pSearchTerm VARCHAR(100),   
@isNameSearch VARCHAR(100),   
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	DECLARE @pCount INT
	IF (@isNameSearch = 1)
			SET @pCount = (SELECT COUNT(Pat_Name) FROM [APPSVR].[AMKH_InhouseDB].[dbo].[Current_Patient_list] WHERE Pat_Name LIKE '%'+@pSearchTerm+'%')
	ELSE
			SET @pCount = (SELECT COUNT(Pat_Name) FROM [APPSVR].[AMKH_InhouseDB].[dbo].[Current_Patient_list] WHERE CONCAT(BedNo,WardNo)  like CONVERT(int,@pSearchTerm))
			
			
	IF (@pCount > 0)
	BEGIN   
		IF (@isNameSearch = 1)
			BEGIN
				SELECT Pat_Name as patientFullName,CONCAT(BedNo,WardNo) as bedNo 
				FROM  [APPSVR].[AMKH_InhouseDB].[dbo].[Current_Patient_list]
				WHERE Pat_Name LIKE '%'+@pSearchTerm+'%'
			END
		ELSE
			BEGIN
				SELECT  Pat_Name as patientFullName,CONCAT(BedNo,WardNo) as bedNo 
				FROM  [APPSVR].[AMKH_InhouseDB].[dbo].[Current_Patient_list]
				WHERE  CONCAT(BedNo,WardNo) = CONVERT(int,@pSearchTerm)
			END

		

		SET @responseMessage = 1
	END  
	 
    ELSE  
       SET @responseMessage = 0  
END; 


----------------------------------------------------------------------------------------------------- Procedure for retrieving every visitor so long as they scanned in the given Bedno
GO
CREATE PROCEDURE [dbo].[TRACE_BY_EXPRESS_ENTRY]
@pStart_Date DATE,
@pEnd_Date DATE,
@responseMessage INT OUT

AS  
BEGIN  
  SET NOCOUNT ON

  BEGIN
    SET @responseMessage = 1;
    ----------------------------------------------- First retrieve all visits to the location in question
    ----------------------------------------------- which were scanned within the query period
    WITH EXPRESS_SCANS (nric, visitActualTime, temperature, locationID, locationTime, bedNoList, qa_json)
    AS
    (
      SELECT DISTINCT m.nric, m.visitActualTime, ci.temperature, m.locationID, m.locationTime, t.tName, qa.QA_JSON
      FROM MOVEMENT m
      LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
      LEFT JOIN CHECK_IN ci ON ci.nric = m.nric AND ci.visitActualTime = m.visitActualTime
      LEFT JOIN VISIT v ON v.visitorNric = m.nric
      LEFT JOIN QUESTIONAIRE_ANS qa ON qa.QA_ID = v.QaID
      WHERE v.purpose = ''
      AND v.visitLocation = ''
      AND v.bedNo = ''
      AND t.tName LIKE 'ENTRANCE%'
      AND v.confirm = 1
      AND CAST(m.locationTime AS DATE) BETWEEN @pStart_Date AND @pEnd_Date
    ),    

    ----------------------------------------------- Find the corresponding exit terminals and exit times
    EXPRESS_EXITS (nric, visitActualTime, locationTime, exitTerminal, exitTime)
    AS
    (
      SELECT dbs.nric, dbs.visitActualTime, dbs.locationTime, t.tName, m.locationTime
      FROM EXPRESS_SCANS dbs  
      LEFT JOIN MOVEMENT M ON m.NRIC = dbs.nric
        AND m.visitActualTime = dbs.visitActualTime
      LEFT JOIN TERMINAL t ON m.locationID = t.terminalID
      WHERE t.tName LIKE 'EXIT%'
    )
    SELECT DISTINCT v.visitLocation AS 'location',  v.bedNo AS 'bedNo', dbs.visitActualTime AS 'checkin_time', dbe.exitTime AS 'exit_time', dbs.temperature AS 'temperature', dbs.nric AS 'nric', vp.fullName AS 'fullName', vp.gender AS 'gender',vp.dateOfBirth AS 'dob', vp.nationality AS 'nationality', vp.mobileTel AS 'mobileTel', vp.homeAddress AS 'homeadd', vp.postalCode AS 'postalcode', dbs.qa_json AS 'formAnswers', vp.confirm AS 'confirmed'
    FROM EXPRESS_SCANS dbs 
    LEFT JOIN EXPRESS_EXITS dbe ON dbs.nric = dbe.nric AND dbe.visitActualTime = dbs.visitActualTime
    LEFT JOIN VISIT v ON v.visitorNric = dbs.nric AND CAST(v.visitRequestTime AS DATE) = CAST(dbs.visitActualTime AS DATE)
    LEFT JOIN VISITOR_PROFILE vp ON vp.nric = dbs.nric
    WHERE vp.confirm = 1
  END
END;


--============= This is for Live DB to call the linked server & query the PATIENT DB ================================================================================================================
-------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[CONFIRM_HOSPITAL_PATIENT] 
@pPatientFullName NVARCHAR(150),
@pBedNo INT,
@responseMessage VARCHAR(500) OUTPUT

AS  
BEGIN  
  SET NOCOUNT ON  
  DECLARE @pPatient_Detail VARCHAR(500)
  DECLARE @pActiveQns TABLE (ADM_ID INT, Pat_NRIC VARCHAR(50), Pat_Name VARCHAR(200), ADM_Dt DATETIME, Bed VARCHAR(50))  

  INSERT INTO @pActiveQns
  SELECT * FROM OPENQUERY(APPSVR,'SELECT ADM_ID, Pat_NRIC, Pat_Name, ADM_Dt, Bed FROM [AMKH_InhouseDB].[dbo].[Current_Patient_list]')

  IF(LEN(@pPatientFullName) > 5)
  BEGIN
    IF EXISTS (SELECT ADM_ID FROM @pActiveQns WHERE Pat_Name LIKE '%' + @pPatientFullName + '%' AND Bed = @pBedNo)
    BEGIN
      SET @pPatient_Detail = (SELECT (Pat_NRIC + ',' + Pat_Name + ',' + CAST(Bed AS VARCHAR(100))) FROM @pActiveQns WHERE Pat_Name LIKE '%' + @pPatientFullName + '%' AND Bed = @pBedNo)
      SET @responseMessage = @pPatient_Detail
    END
    ELSE
    BEGIN
      SET @responseMessage = '0'
    END
    END
    ELSE
    BEGIN
    IF EXISTS (SELECT ADM_ID FROM @pActiveQns WHERE Pat_Name = @pPatientFullName AND Bed = @pBedNo)
    BEGIN
      SET @pPatient_Detail = (SELECT (Pat_NRIC + ',' + Pat_Name + ',' + CAST(Bed AS VARCHAR(100))) FROM @pActiveQns WHERE Pat_Name = @pPatientFullName AND Bed = @pBedNo)
    SET @responseMessage = @pPatient_Detail
    END
    ELSE
    BEGIN
      SET @responseMessage = '0'
    END
  END
END;


------------------------------------------------------------------------------ Get Patient's name
GO
CREATE PROCEDURE [dbo].[GET_HOSPITAL_PATIENT_NAME]  
@pBed_No VARCHAR(15),
@pPatient_Name VARCHAR(100) OUTPUT,   
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
  SET NOCOUNT ON  

  DECLARE @pBed_No_Int INT
  DECLARE @pActiveQns TABLE (Pat_Name VARCHAR(200), Bed VARCHAR(50))
  SET @pBed_No_Int = CONVERT(INT, @pBed_No)
  --SET @pBed_No_Int = CAST(@pBed_No AS INT)
  
  INSERT INTO @pActiveQns
  SELECT * FROM OPENQUERY(APPSVR,'SELECT Pat_Name, Bed FROM [AMKH_InhouseDB_Production].[dbo].[Current_Patient_list]')

  IF EXISTS (SELECT Pat_Name FROM @pActiveQns WHERE @pBed_No_Int = Bed)  
  BEGIN    
    SET @responseMessage = 1
    SET @pPatient_Name = (SELECT TOP 1 Pat_Name FROM @pActiveQns WHERE @pBed_No_Int = Bed)
  END  
   
    ELSE  
       SET @responseMessage = 0  
END;


--===========================================================================================================================================================================================
