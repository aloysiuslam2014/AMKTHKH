-- http://stackoverflow.com/questions/1260952/how-to-execute-a-stored-procedure-within-c-sharp-program For running stored procedures in C#
-- To store Visitor Registration Data
USE master;   

IF EXISTS(SELECT * from sys.databases WHERE name='stepwise')  
BEGIN  
	DECLARE @DatabaseName nvarchar(50)
	SET @DatabaseName = 'stepwise'

	DECLARE @SQL varchar(max)

	SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
	FROM MASTER..SysProcesses
	WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId
    
	SELECT @SQL 
	EXEC(@SQL)

	DROP DATABASE stepwise;  
END 

GO
CREATE DATABASE stepwise; 

GO
USE stepwise;


CREATE TABLE stepwise.dbo.visitor
(visitor_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- Changed to self incremental value
firstName VARCHAR(200) NOT NULL,
lastName VARCHAR(200) NOT NULL,
nric VARCHAR(100) NOT NULL,
address VARCHAR(300) NOT NULL,
postalCode INT NOT NULL,
homeTel VARCHAR(100) NOT NULL, -- Visitors may not be from Singapore so no +65
altTel VARCHAR(100),
mobTel VARCHAR(100) NOT NULL,
email VARCHAR(200),
sex CHAR(50) NOT NULL,
nationality VARCHAR(100) NOT NULL,
dateOfBirth DATE NOT NULL,
age INT NOT NULL,
race VARCHAR(150) NOT NULL,
dateCreated DATETIME NOT NULL,
dateUpdated DATETIME NOT NULL,
createdBy VARCHAR(100)); -- Logged in staff_id or null if self-register


-- To Store Staff Data

CREATE TABLE stepwise.dbo.staff
(staff_id VARCHAR(50) PRIMARY KEY NOT NULL,
firstName VARCHAR(200) NOT NULL,
lastName VARCHAR(200) NOT NULL,
nric VARCHAR(100) NOT NULL,
address VARCHAR(300) NOT NULL,
postalCode INT NOT NULL,
homeTel VARCHAR(100) NOT NULL,
altTel VARCHAR(100),
mobTel VARCHAR(100) NOT NULL,
email VARCHAR(200) NOT NULL,
sex CHAR(50) NOT NULL,
nationality VARCHAR(100) NOT NULL,
dateOfBirth DATE NOT NULL,
age INT NOT NULL,
race VARCHAR(150) NOT NULL,
passwordHash BINARY(64) NOT NULL, -- Hash it With SHA2-512 and add salt to further pad with randomization bits.
salt UNIQUEIDENTIFIER ,
permission INT NOT NULL, -- Access Control Level
position VARCHAR(100) NOT NULL, -- Doctor, Nurse, Admin....
dateCreated DATETIME NOT NULL,
dateUpdated DATETIME NOT NULL,
createdBy VARCHAR(100)); -- Logged in Admin_ID

-- To Store Checkpoint Locations
GO
CREATE TABLE stepwise.dbo.locations
(lid INT PRIMARY KEY NOT NULL,
locationName VARCHAR(400) NOT NULL,
activated INT NOT NULL);

-- To Store Visit Details
GO
CREATE TABLE stepwise.dbo.visit_details
(visit_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
cicoid INT NOT NULL,
visitor_id INT NOT NULL,
visitTime DATETIME NOT NULL, --Patient can request for a visit time? Yes. Timeouts will occur if the patient is late by 15 mins for now
wingNo INT NOT NULL,
wardNo INT NOT NULL,
-- cubicleNo INT NOT NULL, -- This point of time ward is the best we got 
bedNo INT NOT NULL,
-- visit_status VARCHAR(50) NOT NULL, -- Pending, Rejected, Waitlist, Approved -- Registration will not be vetted. 
-- validatedBy VARCHAR(100) NOT NULL, -- Logged in staff_id
dateCreated DATETIME NOT NULL);

-- To Store Check-in Details
GO
CREATE TABLE stepwise.dbo.check_in_out
(cicoid INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
nric VARCHAR(100) NOT NULL,
temperature VARCHAR(100) NOT NULL,
staff_id INT NOT NULL,
visit_id INT NOT NULL,
checkinlid INT NOT NULL, -- Can be 1=Entrance, 2=Ward 1 & 4=Exit
checkinTime DATETIME NOT NULL,
checkoutlid INT,
checkoutTime DATETIME);

-- To Store Movement Details
GO
CREATE TABLE stepwise.dbo.movementTable
(moveid INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
nric VARCHAR(100) NOT NULL,
cicoid INT NOT NULL,
checkpointtimeid VARCHAR(500) NOT NULL); -- stored in the following format [timestamp]:LID

-- To Store Form Question IDs
GO
CREATE TABLE stepwise.dbo.form_qns
(qnid INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
question VARCHAR(500) NOT NULL,
optionstype INT NOT NULL);

-- To Store Form Question Option Values
GO
CREATE TABLE stepwise.dbo.form_qns_options
(qnoptid INT PRIMARY KEY NOT NULL,
qnid INT NOT NULL,
optionvalue VARCHAR(400) NOT NULL);

-- To Store Form Question Answers
GO
CREATE TABLE stepwise.dbo.form_ans
(ansid INT PRIMARY KEY NOT NULL,
qnid INT NOT NULL,
visitid INT NOT NULL,
answer VARCHAR(1000) NOT NULL);

-- Procedures for adding user and logging in
GO
/****** Object:  StoredProcedure [dbo].[INSERT INTO  - staff]    Script Date: 10/30/2016 3:38:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - staff]

    @pLogin          INT, 
    @pPassword        VARCHAR(64),
    @pFirstName        VARCHAR(200), 
    @pLastName        VARCHAR(200),
  @pNric          VARCHAR(100),
  @pAddress        VARCHAR(300),
  @pPostal        INT,
  @pHomeTel        VARCHAR(100),
  @pAltTel        VARCHAR(100) = NULL,
  @pMobileTel        VARCHAR(100),
  @pEmail          VARCHAR(200),
  @pSex          CHAR(50) = 'M',
  @pNationality      VARCHAR(100) = 'Singaporean',
  @pDOB          DATE = '09/08/1965',
  @pAge          INT,
  @pRace          VARCHAR(150),
  @pPermission      INT = 1,
  @pPostion        VARCHAR(100) = 'Nurse',
  --@pDateCreated      DATETIME,
  --@pDateUpdated      DATETIME,
  @pCreatedBy        VARCHAR(100) = 'MASTER',
    @responseMessage    NVARCHAR(250) OUTPUT

AS

BEGIN

    SET NOCOUNT ON

    DECLARE @salt UNIQUEIDENTIFIER=NEWID()
    BEGIN TRY

        INSERT INTO staff (staff_id, firstName, lastName, nric, address, postalCode, homeTel, altTel,
    mobTel, email, sex, nationality, dateOfBirth, age, race, PasswordHash, permission,
    position, dateCreated, dateUpdated, createdBy)
        VALUES(@pLogin, @pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel,
    @pMobileTel, @pEmail, @pSex, @pNationality, @pDOB, @pAge, @pRace, 
    HASHBYTES('SHA2_512', @pPassword),  @pPermission ,@pPostion, GETDATE(),
    GETDATE(), @pCreatedBy)

       SET @responseMessage='Success'

    END TRY
    BEGIN CATCH
        SET @responseMessage=ERROR_MESSAGE() 
    END CATCH

END;

-- Validate Staff Login
GO
/****** Object:  StoredProcedure [dbo].[SELECT FROM - login]    Script Date: 30/10/2016 15:48:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SELECT FROM - login] --You can use a User-defined function or a view instead of a procedure.
    @pNric NVARCHAR(254),
    @pPassword varbinary(64)
     
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @userID INT

    SELECT * FROM dbo.staff WHERE staff_id=@pNric AND PasswordHash=@pPassword
       
   
END
;

-- Procedures for adding new visitor
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - Registration]

	@pVisitor_id INT,
	@pFirstName VARCHAR(200),
	@pLastName VARCHAR(200),
	@pNric VARCHAR(100),
	@pAddress VARCHAR(300),
	@pPostal INT,
	@pHomeTel VARCHAR(100), -- Visitors may not be from Singapore so no +65
	@pAltTel VARCHAR(100) = NULL,
	@pMobTel VARCHAR(100),
	@pEmail VARCHAR(200),
	@pSex CHAR(50),
	@pNationality VARCHAR(100),
	@pDOB DATE = '09/08/1965',
	@pAge INT,
	@prace VARCHAR(150),
	-- @pdateCreated DATETIME,
	-- @pdateUpdated DATETIME,
	@pcreatedBy VARCHAR(100) = 'MASTER',
	@pResponseMessage NVARCHAR(250) OUTPUT

AS

BEGIN
    SET NOCOUNT ON

	IF EXISTS (SELECT visitor_id FROM dbo.visitor WHERE nric = @pNric)
		BEGIN TRY
		SET @pResponseMessage='Existing vistor'
		SELECT TOP 1 visitor_id 
			FROM [dbo].[visitor] WHERE nric = @pNric
		END try

		BEGIN CATCH
			SET @pResponseMessage=ERROR_MESSAGE() 
		END CATCH	
	ELSE
		BEGIN TRY
			INSERT INTO visitor (visitor_id, firstName, lastName, nric, address, postalCode, homeTel, altTel,
			mobTel, email, sex, nationality, dateOfBirth, age, race, dateCreated, dateUpdated, createdBy)
			VALUES(@pVisitor_id, @pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel,
			@pMobTel, @pEmail, @pSex, @pNationality, @pDOB, @pAge, @pRace, GETDATE(), GETDATE(), @pCreatedBy)

			SET @pResponseMessage='Success'
			SELECT TOP 1 visitor_id 
				FROM [dbo].[visitor] WHERE nric = @pNric
		END TRY

		BEGIN CATCH
			SET @pResponseMessage=ERROR_MESSAGE() 
		END CATCH
END;



-- Returning visitor
GO
CREATE PROCEDURE [dbo].[SELECT FROM - ReturningVisitor]
    @pNRIC VARCHAR(100),
	@responseMessage NVARCHAR(250) OUTPUT

AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (SELECT * FROM dbo.visitor WHERE nric = @pNric)
		BEGIN
			SET @responseMessage='Existing visitor'

			SELECT TOP 1 visitor_id 
			FROM [dbo].[visitor] WHERE nric = @pNric
		END
		
    ELSE
       SET @responseMessage='Non-existing visitor'
END;


-- Get Visitor Details
GO
CREATE PROCEDURE [dbo].[SELECT FROM - VisitorDetails]
    @pNRIC VARCHAR(100),
	@responseMessage NVARCHAR(250) OUTPUT

AS
BEGIN
    SET NOCOUNT ON
	DECLARE @userID INT

    IF EXISTS (SELECT nric FROM dbo.visitor WHERE nric = @pNric)
		
		BEGIN
			SET @userID = (SELECT TOP 1 visitor_id
			FROM [dbo].[visitor] WHERE nric = @pNRIC)

				SELECT firstName, lastName, mobTel FROM dbo.visitor WHERE nric = @pNric
				SET @responseMessage='Visitor found'
		END
    ELSE
       SET @responseMessage='Visitor not found'
END;

-- Find visitor
GO
CREATE PROCEDURE [dbo].[SELECT FROM - FindVisitor]
    @pNRIC VARCHAR(100),
	@responseMessage NVARCHAR(250) OUTPUT

AS
BEGIN
    SET NOCOUNT ON
	DECLARE @userID INT

    IF EXISTS (SELECT * FROM dbo.visitor WHERE nric = @pNric)
		
		BEGIN
			SET @userID = (SELECT TOP 1 visitor_id
			FROM [dbo].[visitor] WHERE nric = @pNRIC)

			IF(@userID IS NULL)
				SET @responseMessage='Visitor not found'
			ELSE 
				SET @responseMessage='Visitor found'

				SELECT TOP 1 * 
				FROM [dbo].[visit_details] WHERE visitor_id = @userID
		END
    ELSE
       SET @responseMessage='Visitor not found'
END;



-- Procedures for adding details in Check_In_Out
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - First_Check_In]

	@pNric VARCHAR(100),
	@pTemperature VARCHAR(100),
	@pStaff_id INT,
	@pVisit_id INT,
	@pCheckinlid INT, -- Can be 1=Entrance, 2=Ward 1 & 4=Exit
	@pResponseMessage NVARCHAR(250) OUTPUT
AS

BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        INSERT INTO check_in_out (nric, temperature, staff_id, visit_id, checkinlid, 
								  checkinTime, checkoutlid, checkoutTime)
        VALUES(@pNric, @pTemperature, @pStaff_id, @pVisit_id, @pCheckinlid, GETDATE(), 
			   NULL, NULL)

       SET @pResponseMessage='Success'
    END TRY

    BEGIN CATCH
        SET @pResponseMessage=ERROR_MESSAGE() 
    END CATCH

END;

GO

CREATE PROCEDURE [dbo].[SELECT FROM - Locations]
AS
BEGIN
    SET NOCOUNT ON
		
		BEGIN
			SELECT * FROM [dbo].[locations] as d where d.activated = 0
		END
END;

-- Procedures for updating details in Check_In_Out
GO
CREATE PROCEDURE [dbo].[UPDATE - Check_In]

	@pCicoid INT,
	@pNric VARCHAR(100),
	@pTemperature VARCHAR(100),
	@pStaff_id INT,
	@pVisit_id INT,
	@pCheckinlid INT, -- Can be 1=Entrance, 2=Ward 1 & 4=Exit
	@pCheckinTime DATETIME,
	@pCheckoutlid INT,
	@pCheckoutTime DATETIME,
	@pResponseMessage NVARCHAR(250) OUTPUT
AS

BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        UPDATE check_in_out 
		SET staff_id = @pStaff_id, -- Removed CICOID as it is self incremental
			temperature = @pTemperature,
			checkinlid = @pCheckinlid, 
			checkinTime = @pCheckinTime, 
			checkoutlid = @pCheckoutlid, 
			checkoutTime = @pCheckoutTime
        WHERE nric = @pNric

       SET @pResponseMessage='Successfully Updated'
    END TRY

    BEGIN CATCH
        SET @pResponseMessage=ERROR_MESSAGE() 
    END CATCH

END;