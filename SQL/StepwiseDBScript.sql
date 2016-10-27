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
(visitor_id INT PRIMARY KEY NOT NULL,
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
(staff_id INT PRIMARY KEY NOT NULL,
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
locationName VARCHAR(400) NOT NULL);

-- To Store Visit Details
GO
CREATE TABLE stepwise.dbo.visit_details
(visit_id INT PRIMARY KEY NOT NULL,
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
(cicoid INT PRIMARY KEY,
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
(moveid INT PRIMARY KEY NOT NULL,
nric VARCHAR(100) NOT NULL,
cicoid INT NOT NULL,
checkpointtimeid VARCHAR(500) NOT NULL); -- stored in the following format [timestamp]:LID

-- To Store Form Question IDs
GO
CREATE TABLE stepwise.dbo.form_qns
(qnid INT PRIMARY KEY NOT NULL,
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
CREATE PROCEDURE [dbo].[INSERT INTO  - staff]

    @pLogin					INT, 
    @pPassword				NVARCHAR(50),
    @pFirstName				VARCHAR(200), 
    @pLastName				VARCHAR(200),
	@pNric					VARCHAR(100),
	@pAddress				VARCHAR(300),
	@pPostal				INT,
	@pHomeTel				VARCHAR(100),
	@pAltTel				VARCHAR(100) = NULL,
	@pMobileTel				VARCHAR(100),
	@pEmail					VARCHAR(200),
	@pSex					CHAR(50) = 'M',
	@pNationality			VARCHAR(100) = 'Singaporean',
	@pDOB					DATE = '09/08/1965',
	@pAge					INT,
	@pRace					VARCHAR(150),
	@pPermission			INT = 1,
	@pPostion				VARCHAR(100) = 'Nurse',
	--@pDateCreated			DATETIME,
	--@pDateUpdated			DATETIME,
	@pCreatedBy				VARCHAR(100) = 'MASTER',
    @responseMessage		NVARCHAR(250) OUTPUT

AS

BEGIN

    SET NOCOUNT ON

    DECLARE @salt UNIQUEIDENTIFIER=NEWID()
    BEGIN TRY

        INSERT INTO staff (staff_id, firstName, lastName, nric, address, postalCode, homeTel, altTel,
		mobTel, email, sex, nationality, dateOfBirth, age, race, PasswordHash, Salt, permission,
		position, dateCreated, dateUpdated, createdBy)
        VALUES(@pLogin, @pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel,
		@pMobileTel, @pEmail, @pSex, @pNationality, @pDOB, @pAge, @pRace, 
		HASHBYTES('SHA2_512', @pPassword+CAST(@salt AS NVARCHAR(36))), @salt, @pPermission ,@pPostion, GETDATE(),
		GETDATE(), @pCreatedBy)

       SET @responseMessage='Success'

    END TRY
    BEGIN CATCH
        SET @responseMessage=ERROR_MESSAGE() 
    END CATCH

END;




GO
CREATE PROCEDURE [dbo].[SELECT FROM - login] --You can use a User-defined function or a view instead of a procedure.
    @pNric NVARCHAR(254),
    @pPassword NVARCHAR(50),
    @responseMessage NVARCHAR(250)='' OUTPUT
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @userID INT

    IF EXISTS (SELECT TOP 1 staff_id FROM dbo.staff WHERE nric=@pNric)
    BEGIN
        SET @userID=(SELECT staff_id FROM dbo.staff WHERE nric=@pNric AND PasswordHash=HASHBYTES('SHA2_512', @pPassword+CAST(Salt AS NVARCHAR(36))))

       IF(@userID IS NULL)
           SET @responseMessage='Incorrect password'
       ELSE 
           SET @responseMessage='User successfully logged in'
    END
    ELSE
       SET @responseMessage='Invalid login'
END;


