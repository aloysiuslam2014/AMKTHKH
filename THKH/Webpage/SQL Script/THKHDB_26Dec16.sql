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
	qnsValue VARCHAR(1000) NOT NULL
); 


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Option Values  
GO
CREATE TABLE QUESTIONAIRE_QNS_LIST  
(
	Q_QuestionListID VARCHAR(100) PRIMARY KEY NOT NULL,  
	Q_Order VARCHAR(100),  -- List of QQ_IDs from QUESTIONAIRE_QNS. Format example: '1,3,4,2,5'  
	Q_Active INT NOT NULL  -- 1 == Active, 0 == Inactive
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
	confirm INT NOT NULL
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
	bedNoList VARCHAR(100) NOT NULL,
	activated INT NOT NULL
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
	CONSTRAINT PK_MOVEMENT PRIMARY KEY (visitActualTime, nric)
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
				'1991-01-01', 25, 'MY', HASHBYTES('SHA2_512', '123'),  1 , 'Doctor', GETDATE(), GETDATE(), @pCreatedBy)  
  
       SET @responseMessage='Success'   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage=ERROR_MESSAGE()   
    END CATCH  
END;  
  
-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
GO
CREATE PROCEDURE [dbo].[TEST_PATIENT] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
		VALUES (1, 'S987', 'Benjamin Gan', '2016-07-11 09:00', '2020-01-01 00:00')
  
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
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm)
		VALUES ('S123', 'JASON', 'M', 'SINGAPOREAN', '1990-10-11', 'Chinese', '987654321', 
				'7878787878', '5656565656', 'JASON@hotmail.com', 'BLK 476 TAMPINES ST 44', 913476, GETDATE(), 0)
  
    END 
END;  

-------------------------------------------------------------------------------------------------------------------------------- Procedures for TESTING
GO
CREATE PROCEDURE [dbo].[TEST_QUESTIONAIRE_QNS] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Which country have you visited over the last 3 months? (If no, please select None)', 'ddList', 'None,Malaysia,USA,China,Russia')
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Were you diagnosed with fever over the last 3 days?', 'radio', 'Yes,No')

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '')

		-------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Which universe planet have you visited over the last 6 months? (If no, please select None)', 'ddList', 'None,Jupiter,Mars,Mercury,Saturn,Venus')
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Were you diagnosed with Alien-Virus over the last 3 days?', 'radio', 'Yes,No')

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '')

		-------------------------------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Which country have you visited over the last 3 months? (If no, please select None)', 'ddList', 'None,Malaysia,USA,China,Russia')
		
 		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Were you diagnosed with fever over the last 3 days?', 'radio', 'Yes,No')

		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '')

    END 
END;


-------------------------------------------------------------------------------------------------------------------------------- Procedures for TESTING
GO
CREATE PROCEDURE [dbo].[TEST_QUESTIONAIRE_QNS_LIST] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active)
		VALUES ('First', '3,1,2', 1)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active)
		VALUES ('Second', '5,6,4', 0)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active)
		VALUES ('Third', '7,9,8', 0)
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
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
		SET @pTimestamp = SYSDATETIME();
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm)
		VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pRace, @pMobileTel, 
				@pHomeTel, @pAltTel, @pEmail, @pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm)

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
		END
		
		ELSE
		BEGIN
			INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, race, mobileTel,
									homeTel, altTel, email, homeAddress, postalCode, time_stamp, confirm)
			VALUES (@pNRIC, @pFullName, @pGender, @pNationality, @pDateOfBirth, @pRace, @pMobileTel, 
				@pHomeTel, @pAltTel, @pEmail, @pHomeAddress, @pPostalCode, @pTimestamp, @pConfirm)
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
	DECLARE @visitorInfo VARCHAR(1000) 
 	
	--IF EXISTS (SELECT nric FROM dbo.VISITOR_PROFILE WHERE nric = @pNric)  
	BEGIN
		SET @visitorInfo = (SELECT TOP 1 (nric + ',' + fullName + ',' + gender + ',' + nationality + ',' + CONVERT(VARCHAR(100), dateOfBirth, 105) + ',' + race + ',' + mobileTel + ',' + 
					                     homeTel + ',' + altTel + ',' + email + ',' + homeAddress + ',' + CAST(postalCode AS VARCHAR(20)) + ',' + CONVERT(VARCHAR(100), time_stamp, 105) + ' ' + CONVERT(VARCHAR(10), time_stamp, 108))
		FROM [dbo].[VISITOR_PROFILE] 
		WHERE nric = @pNRIC)

		IF (@visitorInfo IS NULL) 
		BEGIN
			SET @responseMessage = 0
			SET @returnValue = 'Visitor not found'
		END
		ELSE
			SET @responseMessage = 1
			SET @returnValue = @visitorInfo
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

	-- Change NOT EXISTS to EXISTS once we have the patient information
	IF (NOT EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
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
	IF (EXISTS (SELECT nric FROM dbo.PATIENT WHERE patientFullName LIKE '%' + @pPatientFullName + '%' AND bedNo = @pBedNo))  
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
	DECLARE @pOriginal_Staff_Email VARCHAR(200)
	
	SET @pOriginal_Staff_Email = (SELECT email FROM STAFF WHERE 
								  SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pStaffEmail)
  
	IF (NOT EXISTS (SELECT nric FROM dbo.CHECK_IN WHERE staffEmail = @pOriginal_Staff_Email))  
	BEGIN  
		DECLARE @pSelectedVisitDate DATETIME

		INSERT INTO CHECK_IN(nric, visitActualTime, temperature, staffEmail)
		VALUES (@pNRIC, @pActualTimeVisit, @pTemperature, @pOriginal_Staff_Email)

		SET @pSelectedVisitDate = (SELECT TOP 1 time_stamp FROM VISITOR_PROFILE WHERE nric = @pNRIC ORDER BY time_stamp DESC)

		SET @responseMessage = 1
	END  

    ELSE  
       SET @responseMessage = 0  
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
		IF (@pVisit_Date != NULL)
			INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
			VALUES (@pNRIC, @pVisit_Date, @pLocationID, SYSDATETIME())

 			SET @responseMessage = 1   
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
END; 


-------------------------------------------------------------------------------------------------------- Procedure for adding Terminal
GO
CREATE PROCEDURE [dbo].[ADD_TERMINAL] 
@pTName VARCHAR(100),
@pBedNoList VARCHAR(100),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	IF NOT EXISTS (SELECT terminalID FROM TERMINAL WHERE tName = @pTName)
	BEGIN TRY
		INSERT INTO TERMINAL(tName, bedNoList, activated)
		VALUES (@pTName, @pBedNoList, 0)

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
		WHERE activated = 0
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
		SELECT terminalID, tName, activated
		FROM TERMINAL
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
		DELETE FROM TERMINAL

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
		DELETE FROM TERMINAL
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
		INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue)
		VALUES (@pQuestion, @pQnsType, @pQnsValue)

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
		DELETE FROM QUESTIONAIRE_QNS
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
	DECLARE @pActiveQns TABLE (listID VARCHAR(100), question VARCHAR(200), qnsType VARCHAR(20), qnsValue VARCHAR(200))
	DECLARE @pOrder_QQ_ID VARCHAR(100)

	SET @pOrder_QQ_ID = (SELECT Q_Order FROM QUESTIONAIRE_QNS_LIST WHERE Q_Active = 1)

	INSERT INTO @pActiveQns  
		SELECT Q_QuestionListID, question, qnsType, qnsValue
		FROM QUESTIONAIRE_QNS JOIN QUESTIONAIRE_QNS_LIST
		ON QQ_ID IN 
		(
			--SELECT split_data.VALUE
			--FROM QUESTIONAIRE_QNS_LIST 
			--CROSS APPLY STRING_SPLIT(Q_Order, ',') AS split_data
			--WHERE Q_Active = 1
			SELECT * FROM dbo.FUNC_SPLIT(@pOrder_QQ_ID, ',')
		) 
		AND Q_Active = 1
  
	IF EXISTS (SELECT question FROM @pActiveQns)
	BEGIN
		SET @responseMessage = 1
		SELECT * FROM @pActiveQns 
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
	SET @pReturnCount = (SELECT COUNT(Q_QuestionListID) FROM QUESTIONAIRE_QNS_LIST)

	IF (@pReturnCount > 0)
	BEGIN
		SELECT * FROM QUESTIONAIRE_QNS_LIST
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
       		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active)  
       		VALUES(@pQ_QuestionListID, @pQ_Order, @pQ_Active)  
  
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
       		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active)  
       		VALUES(@pQ_QuestionListID, '', @pQ_Active)  
  
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
	
	SET @pOrder_QQ_ID = (SELECT Q_Order FROM QUESTIONAIRE_QNS_LIST WHERE Q_QuestionListID = @pQ_QuestionList_ID)

	INSERT INTO @pSelected_Qns  
		SELECT QQ_ID, question, qnsType, qnsValue
		FROM QUESTIONAIRE_QNS 
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
		DELETE FROM QUESTIONAIRE_QNS_LIST
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


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors who have contacted with the Patient  
GO
CREATE PROCEDURE [dbo].[TRACE_BY_PATIENT_NRIC]  
@pBedNo INT,
@pStartDate DATETIME,
@pEndDate DATETIME,
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON  

	IF EXISTS (SELECT nric FROM PATIENT WHERE bedNo = @pBedNo AND startDate = @pStartDate AND endDate = @pEndDate)
	BEGIN TRY  
		SET @responseMessage = 1 

		SELECT a.visitorNric FROM VISIT a
			INNER JOIN PATIENT b ON a.patientNric = b.nric
			INNER JOIN MOVEMENT c ON a.visitorNric = c.nric
		WHERE b.bedNo = @pBedNo AND b.startDate = @pStartDate AND b.endDate = @pEndDate 

		RETURN
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = ERROR_MESSAGE()
    END CATCH 

	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Terminal  
GO
CREATE PROCEDURE [dbo].[VISITOR_BY_TERMINAL]  
@pStart_Date DATETIME,
@pEnd_Date DATETIME,
@pTerminal_ID INT,
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON
	DECLARE @pTrace_Visitor TABLE (vNRIC VARCHAR(10), startDate DATETIME, endDate DATETIME)
	DECLARE @pCountVisitor INT

	INSERT INTO @pTrace_Visitor
		SELECT vp.nric, m.locationTime, (SELECT TOP 1 locationTime FROM MOVEMENT 
										 WHERE locationTime > @pEnd_Date ORDER BY locationTime ASC) 
		FROM VISITOR_PROFILE vp INNER JOIN MOVEMENT m 
		ON vp.nric = m.nric
		WHERE m.locationID = @pTerminal_ID
		AND m.locationTime >= @pStart_Date
	
	SET @pCountVisitor = (SELECT COUNT(DISTINCT vNRIC) FROM @pTrace_Visitor)
	
	IF (@pCountVisitor > 0)
	BEGIN
		SET @responseMessage = 1
		SELECT * FROM @pTrace_Visitor
		ORDER BY vNRIC ASC
	END

	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
GO
CREATE PROCEDURE [dbo].[CHECKIN_BY_VISITOR]  
@pStart_Date DATETIME,
@pEnd_Date DATETIME,
@pVisitor_Nric VARCHAR(15),
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON
	DECLARE @pTrace_Visitor TABLE (vNRIC VARCHAR(10), vFullName VARCHAR(200), checkin_time DATETIME)
	DECLARE @pCountVisitor INT

	INSERT INTO @pTrace_Visitor
		SELECT vp.nric, vp.fullName, ci.visitActualTime
		FROM VISITOR_PROFILE vp
			INNER JOIN CHECK_IN ci ON vp.nric = ci.nric
		WHERE vp.nric = @pVisitor_Nric
		AND ci.visitActualTime BETWEEN @pStart_Date AND @pEnd_Date
	
	SET @pCountVisitor = (SELECT COUNT(DISTINCT vNRIC) FROM @pTrace_Visitor)
	
	IF (@pCountVisitor > 0)
	BEGIN
		SET @responseMessage = 1
		SELECT * FROM @pTrace_Visitor
		ORDER BY vNRIC
	END

	ELSE
		SET @responseMessage = 0
END; 


-----------------------------------------------------------------------------------------------------  Procedures for Tracing Visiors by Check-In  
GO
CREATE PROCEDURE [dbo].[BedNO_BY_TERMINAL]  
@pStart_Date DATETIME,
@pEnd_Date DATETIME,
@pPatient_Nric VARCHAR(15),
@responseMessage INT OUT

AS  
BEGIN  
	SET NOCOUNT ON
	DECLARE @pTrace_Patient TABLE (pNRIC VARCHAR(10), pBedNo INT)
	DECLARE @pReturn_Terminal TABLE (terminalID INT)
	DECLARE @pCount INT
	DECLARE @pPatient_BedNo VARCHAR(10)
	
	INSERT INTO @pTrace_Patient
		SELECT nric, bedNo
		FROM PATIENT
		WHERE nric = @pPatient_Nric
		AND startDate >= @pStart_Date
		AND endDate <= @pEnd_Date	
	
	INSERT INTO @pReturn_Terminal
		SELECT terminalID
		FROM TERMINAL t INNER JOIN @pTrace_Patient tp 
		ON tp.pBedNo IN 
		(
			SELECT * FROM dbo.FUNC_SPLIT(t.bedNoList, ',')
		)

	SET @pCount = (SELECT COUNT(DISTINCT terminalID) FROM @pReturn_Terminal)
	
	IF (@pCount > 0)
	BEGIN
		SET @responseMessage = 1
		SELECT * FROM @pReturn_Terminal
	END

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




