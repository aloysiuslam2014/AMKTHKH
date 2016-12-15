-- http://stackoverflow.com/questions/1260952/how-to-execute-a-stored-procedure-within-c-sharp-program For running stored procedures in C#  
-- I declare this region… mine! -- 
-- http://stackoverflow.com/questions/7770924/how-to-use-output-parameter-in-stored-procedure This explains how to read from the output from stored procedures 
-- To store Visitor Registration Data  

USE master;     
  
IF EXISTS(SELECT * from sys.databases WHERE name='thkhdb')    
BEGIN    
	DECLARE @DatabaseName nvarchar(50)  
	SET @DatabaseName = 'thkhdb'  
  
	DECLARE @SQL varchar(max)  
  	
	SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'  
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
	email NVARCHAR(100) PRIMARY KEY NOT NULL,  
	firstName NVARCHAR(50) NOT NULL,  
	lastName NVARCHAR(50) NOT NULL,  
	nric VARCHAR(10) NOT NULL,  
	address VARCHAR(100) NOT NULL,  
	postalCode INT NOT NULL,  
	homeTel VARCHAR(15) NOT NULL,  
	altTel VARCHAR(15),  
	mobTel VARCHAR(15) NOT NULL,   
	sex CHAR(1) NOT NULL,  
	nationality VARCHAR(300) NOT NULL,  
	dateOfBirth DATE NOT NULL,  
	age INT NOT NULL,  
	race VARCHAR(20) NOT NULL,  
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
CREATE TABLE PATIENT 
(
	bedNo INT PRIMARY KEY NOT NULL, 
	nric VARCHAR(10) NOT NULL, 
	patientFullName NVARCHAR(100) NOT NULL
); 

    
---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Answers  
GO
CREATE TABLE QUESTIONAIRE_QNS 
(
	QQ_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	question VARCHAR(200) NOT NULL, 
	qnsType VARCHAR(50) NOT NULL,  
	qnsValue VARCHAR(200) NOT NULL
); 


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question Option Values  
GO
CREATE TABLE QUESTIONAIRE_QNS_LIST  
(
	Q_QuestionListID VARCHAR(150) PRIMARY KEY NOT NULL,  
	Q_Order  VARCHAR(50) NOT NULL, 
	Q_Active INT NOT NULL,  
	QQ_ID INT NOT NULL,
	FOREIGN KEY (QQ_ID) REFERENCES QUESTIONAIRE_QNS(QQ_ID)
);  


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Form Question IDs 
GO
CREATE TABLE QUESTIONAIRE_ANS 
(
	QaID INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	Q_QuestionListID VARCHAR(150) NOT NULL, 
	QA_JSON VARCHAR(MAX) NOT NULL,
	FOREIGN KEY (Q_QuestionListID) REFERENCES QUESTIONAIRE_QNS_LIST(Q_QuestionListID)
); 


-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visitors 
GO
CREATE TABLE VISITOR_PROFILE  
(
	nric VARCHAR(10) NOT NULL,
	fullName NVARCHAR(100) NOT NULL,    
	gender CHAR(1) NOT NULL,  
	nationality VARCHAR(300) NOT NULL,  
	dateOfBirth DATE NOT NULL,  
	race VARCHAR(20) NOT NULL, 
	mobileTel VARCHAR(15),  
	homeTel VARCHAR(15), -- Visitors may not be from Singapore so no +65  
	altTel VARCHAR(15),
	email VARCHAR(100),   
	homeAddress VARCHAR(100) NOT NULL,
	postalCode INT NOT NULL, 
	time_stamp DATETIME NOT NULL,  
	confirm INT NOT NULL
);


-------------------------------------------------------------------------------------------------------------------------------------------------- New table for visit
GO
CREATE TABLE VISIT
(
	visitRequestTime DATETIME NOT NULL, 
	patientNric VARCHAR(100),  
	visitorNric VARCHAR(100) NOT NULL,  
	patientFullName VARCHAR(100), 
	purpose VARCHAR(1000) NOT NULL,
	reason VARCHAR(1000),
	visitLocation VARCHAR(100),    
	bedNo INT,  
	QaID INT NOT NULL,
	confirm INT,   
	--FOREIGN KEY (QaID) REFERENCES QUESTIONAIRE_ANS(QaID),
	--FOREIGN KEY (patientNric) REFERENCES PATIENT(nric),
	CONSTRAINT PK_VISIT PRIMARY KEY (visitRequestTime, visitorNric)
);


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Check-in Details  
GO
CREATE TABLE CHECK_IN
(
	nric VARCHAR(10) NOT NULL,  
	visitActualTime DATETIME NOT NULL, 
	temperature VARCHAR(5) NOT NULL,  
	staffEmail NVARCHAR(100) NOT NULL, 
	--FOREIGN KEY (nric) REFERENCES VISITOR_PROFILE(nric),
	FOREIGN KEY (staffEmail) REFERENCES STAFF(email),
	CONSTRAINT PK_CHECK_IN PRIMARY KEY (visitActualTime, nric) 
);  
   
  
----------------------------------------------------------------------------------------------------------------------------------------------------  
GO
CREATE TABLE TERMINAL
(
	terminalID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,    
	tName VARCHAR(50) NOT NULL, 
	activated INT NOT NULL
);


---------------------------------------------------------------------------------------------------------------------------------------------------- To Store Movement Details  
GO
CREATE TABLE MOVEMENT
(
	nric VARCHAR(10) NOT NULL,  
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
	k_ID VARCHAR(50) PRIMARY KEY  NOT NULL,    
	k_data VARCHAR(MAX) NOT NULL, 
	uploadTime DATETIME NOT NULL
);


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for adding user and logging in  

/****** Object:  StoredProcedure [dbo].[INSERT INTO  - staff]    Script Date: 10/30/2016 3:38:44 PM ******/  
GO
SET ANSI_NULLS ON  

GO
SET QUOTED_IDENTIFIER ON  


-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
GO
CREATE PROCEDURE [dbo].[TEST_PATIENT] 
   
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN
		INSERT INTO PATIENT(bedNo, nric, patientFullName)
		VALUES (1, 'S987', 'Benjamin Gan')
  
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

-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Staff
GO
CREATE PROCEDURE [dbo].[CREATE_STAFF]   
@pEmail				NVARCHAR(200), 
@pPassword			VARCHAR(64),  
@pFirstName			NVARCHAR(200),   
@pLastName			NVARCHAR(200),  
@pNric				VARCHAR(100),  
@pAddress			VARCHAR(100),  
@pPostal			INT,  
@pHomeTel			VARCHAR(15),  
@pAltTel			VARCHAR(15) = NULL,  
@pMobileTel			VARCHAR(15),   
@pSex				CHAR(1) = 'M',  
@pNationality		VARCHAR(300) = 'Singaporean',  
@pDOB				DATE = '09/08/1965',  
@pAge				INT,  
@pRace				VARCHAR(50),  
@pPermission		INT = 1,  
@pPostion			VARCHAR(50) = 'Nurse',  
--@pDateCreated      DATETIME,  
--@pDateUpdated      DATETIME,  
@pCreatedBy			VARCHAR(100) = 'MASTER',  
@responseMessage	VARCHAR(200) OUTPUT  
  
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
    @pEmail NVARCHAR(100),  
    @pPassword VARBINARY(64)  
       
AS  
BEGIN  
    SET NOCOUNT ON  

    SELECT * FROM dbo.staff 
	WHERE SUBSTRING(email, 1, CHARINDEX('@', email) - 1) = @pEmail 
	AND PasswordHash = @pPassword      
END;  


---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for verifying Staff
GO
CREATE PROCEDURE [dbo].[VERIFY_STAFF]  
@pEmail NVARCHAR(100),  
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
  

---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for creating visitor's profile
GO
CREATE PROCEDURE [dbo].[CREATE_VISITOR_PROFILE] 
@pNRIC VARCHAR(10),  
@pFullName NVARCHAR(100),
@pGender CHAR(1),
@pNationality VARCHAR(300),
@pDateOfBirth DATE,
@pRace VARCHAR(50),
@pMobileTel VARCHAR(15),
@pHomeTel VARCHAR(15), 
@pAltTel VARCHAR(15),
@pEmail NVARCHAR(100), 
@pHomeAddress VARCHAR(100),
@pPostalCode INT,  
@pTimestamp DATETIME = SYSDATETIME,
@pConfirm INT = 0,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
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



---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for updating visitor's profile
GO
CREATE PROCEDURE [dbo].[UPDATE_VISITOR_PROFILE] 
@pNRIC VARCHAR(10),  
@pFullName NVARCHAR(100),
@pGender CHAR(1),
@pNationality VARCHAR(300),
@pDateOfBirth DATE,
@pRace VARCHAR(50),
@pMobileTel VARCHAR(15),
@pHomeTel VARCHAR(15), 
@pAltTel VARCHAR(15),
@pEmail NVARCHAR(100), 
@pHomeAddress VARCHAR(100),
@pPostalCode INT,  
@pTimestamp DATETIME = SYSDATETIME,
@pConfirm INT = 1,
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  

	BEGIN TRY
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
@pNRIC VARCHAR(10),  
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @visitor_nric VARCHAR(10)
  
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
@pNRIC VARCHAR(10),  
@responseMessage INT OUTPUT,
@returnValue VARCHAR(1000) OUTPUT
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @visitorInfo VARCHAR(MAX) 
 	
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


-----------------------------------------------------------------------------------------------------  Procedures for confirming existing Patient
GO
CREATE PROCEDURE [dbo].[CONFIRM_PATIENT] 
@pPatientFullName NVARCHAR(100),
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


-----------------------------------------------------------------------------------------------------  Procedures for creating visits
GO
CREATE PROCEDURE [dbo].[CREATE_VISIT]
@pVisitRequestTime DATETIME,  
@pPatientNRIC VARCHAR(10) = '',  
@pVisitorNRIC VARCHAR(10),  
@pPatientFullName NVARCHAR(100) = '',
@pPurpose VARCHAR(1000) = '',
@pReason VARCHAR(1000) = '',
@pVisitLocation VARCHAR(100) = '',
@pBedNo INT = 0,
@pQaID INT,
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
@pPatientNRIC VARCHAR(10) = '',  
@pVisitorNRIC VARCHAR(10),  
@pPatientFullName NVARCHAR(100) = '',
@pPurpose VARCHAR(1000) = '',
@pReason VARCHAR(1000) = '',
@pVisitLocation VARCHAR(100) = '',
@pBedNo INT = 0,
@pQaID INT,
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
@pNric VARCHAR(10),  
@responseMessage VARCHAR(1000) OUTPUT

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
										CAST(bedNo AS VARCHAR(100)) + ',' +  CAST(QaID AS VARCHAR(100))  + ',' +  CAST(confirm AS VARCHAR(100)))
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
@pNric VARCHAR(10),
@pActualTimeVisit DATETIME,
@pTemperature VARCHAR(10),
@pStaffEmail NVARCHAR(100),
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
@pNRIC VARCHAR(10), 
@pLocationID INT, 
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @pVisit_Date DATETIME
	DECLARE @pTerminalCheck INT

	SET @pTerminalCheck = (SELECT activated FROM TERMINAL WHERE terminalID = @pLocationID)

	IF (@pTerminalCheck = 1)
	BEGIN
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
	END
	 
	ELSE
		SET @responseMessage = 0 	
END; 


-------------------------------------------------------------------------------------------------------- Procedure for adding Terminal
GO
CREATE PROCEDURE [dbo].[ADD_TERMINAL] 
@pTName VARCHAR(50),
@responseMessage INT OUTPUT  
  
AS  
BEGIN  
	SET NOCOUNT ON  
 	
	IF NOT EXISTS (SELECT terminalID FROM TERMINAL WHERE tName = @pTName)
	BEGIN TRY
		INSERT INTO TERMINAL(tName, activated)
		VALUES (@pTName, 0)

 		SET @responseMessage = 1  
  
    END TRY  

    BEGIN CATCH  
        SET @responseMessage = 0 
    END CATCH  
	
	ELSE
		SET @responseMessage = 0 
END; 


-------------------------------------------------------------------------------------------------------- Procedure for getting Terminal
GO
CREATE PROCEDURE [dbo].[GET_TERMINAL]   
  
AS  
BEGIN  
	SET NOCOUNT ON  
   
	BEGIN TRY
		SELECT terminalID AS lid, tName AS locationName
		FROM TERMINAL WHERE activated = 0
	END TRY  

	BEGIN CATCH  
		SELECT '0' 
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

END; 
