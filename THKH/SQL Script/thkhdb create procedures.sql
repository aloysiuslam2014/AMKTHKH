USE master; 

GO
USE thkhdb;
/****************** Add Staff ******************/ 
GO
/****** Object:  StoredProcedure [dbo].[INSERT INTO  - staff]    Script Date: 10/30/2016 3:38:44 PM ******/ 
SET ANSI_NULLS ON 
GO
SET QUOTED_IDENTIFIER ON 
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - staff] 
 
    @pLogin          INT,  
    @pPassword        VARCHAR(64), 
    @pFirstName        VARCHAR(200),  
    @pLastName        VARCHAR(200), 
  @pNric          VARCHAR(100), 
  @pAddress        VARCHAR(300), 
  @pPostal        INT, 
  @pHomeTel        VARCHAR(100), 
  @pAltTel        VARCHAR(100) = NULL, 
  @pMobileTel        VARCHAR(100), 
  @pEmail          VARCHAR(200), 
  @pSex          CHAR(50) = 'M', 
  @pNationality      VARCHAR(100) = 'Singaporean', 
  @pDOB          DATE = '09/08/1965', 
  @pAge          INT, 
  @pRace          VARCHAR(150), 
  @pPermission      INT = 1, 
  @pPostion        VARCHAR(100) = 'Nurse', 
  --@pDateCreated      DATETIME, 
  --@pDateUpdated      DATETIME, 
  @pCreatedBy        VARCHAR(100) = 'MASTER', 
    @responseMessage    NVARCHAR(250) OUTPUT 
 
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
    HASHBYTES('SHA2_512', @pPassword),  @pPermission ,@pPostion, GETDATE(), 
    GETDATE(), @pCreatedBy) 
 
       SET @responseMessage='Success' 
 
    END TRY 
    BEGIN CATCH 
        SET @responseMessage=ERROR_MESSAGE()  
    END CATCH 
 
END; 
 
----------------------------------------------------- Validate Staff Login -----------------------------------------
GO
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
        
    
END; 
 
--------------------------------------- Check if Visitor Already Exists -----------------------------------------
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
 
-------------------------------------------- Edit Visitor Information -----------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE TO - VisitDetails]
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

------------------------------------- Get Visitor Details -----------------------------------------
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
 
----------------------------------------- Find Visitor -----------------------------------------
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
 
 
------------------------------------------- Check for more than 3 Visitors -----------------------------------------
GO
CREATE PROCEDURE [dbo].[SELECT FROM  - Validate_Check_In]

	@pPatient_id VARCHAR(100), -- need to get bedno?
	@pBed_no INT,
	@pResponseMessage NVARCHAR(250) OUTPUT
AS

BEGIN
    SET NOCOUNT ON
	
    BEGIN TRY
	 SELECT cicoid FROM [thkhdb].[dbo].[check_in_out] WHERE checkinTime < GETDATE() AND checkoutlid IS NULL

       SET @pResponseMessage='Success'
    END TRY

    BEGIN CATCH
        SET @pResponseMessage=ERROR_MESSAGE() 
    END CATCH

END;
 
--------------------------------------------- Check in Visitor -----------------------------------------
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - First_Check_In_Out] 
 
@pNric VARCHAR(100), 
@pTemperature VARCHAR(100), 
@pStaff_id INT, 
@pVisit_id INT, 
@pCheckinlid INT, -- Can be 1=Entrance, 2=Ward 1 & 4=Exit 
@pResponseMessage NVARCHAR(250) OUTPUT 
AS 
 
BEGIN 

	DECLARE @visitor_id INT

    SET NOCOUNT ON 
    BEGIN TRY 
	--IF EXISTS (SELECT visit_id FROM dbo.visit_details WHERE nric = @pNric AND CAST(dateCreated AS DATE) = CAST(GETDATE() AS DATE))
		--SET @visitor_id = (SELECT visit_id FROM dbo.visit_details WHERE nric = @pNric AND CAST(dateCreated AS DATE) = CAST(GETDATE() AS DATE))
        INSERT INTO check_in_out (nric, temperature, staff_id, visit_id, checkinlid,  
  checkinTime, checkoutlid, checkoutTime) 
        VALUES(@pNric, @pTemperature, @pStaff_id, @pVisit_id, @pCheckinlid, GETDATE(),  
   NULL, NULL) 
 		EXEC [UPDATE FROM - UserMovement] @nric = @pNric, @locationId = 1;
       SET @pResponseMessage='Success' 
    END TRY 
 
    BEGIN CATCH 
        SET @pResponseMessage=ERROR_MESSAGE()  
    END CATCH 
 
END; 
 
---------------------------------------- Get Locations ---------------------------------------
--GO
--CREATE PROCEDURE [dbo].[SELECT FROM - Locations] 
--AS 
--BEGIN 
--    SET NOCOUNT ON 
     
--    BEGIN 
--      SELECT * FROM [dbo].[locations] as d where d.activated = 0 
--    END 
--END; 
 
---------------------------------------Check out Visitor -----------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE TO - Check_in_Out] 
 
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
 
--------------------------------- Update Location -----------------------------
--GO
--CREATE PROCEDURE [dbo].[UPDATE FROM - Locations] 
--  @id INT 
--AS 
--BEGIN 
--    SET NOCOUNT ON 
     
--    BEGIN 
--      Update locations set activated=1 where lid=@id; 
--      select 'success'; 
--    END 
--END; 
 
 
------------------------------- Add New Visitor -----------------------------------------
GO
CREATE PROCEDURE [dbo].[INSERT INTO  - Registration] 
 
@pFirstName VARCHAR(200) = '', 
@pLastName VARCHAR(200) = '', 
@pNric VARCHAR(100) = '', 
@pAddress VARCHAR(300) = '', 
@pPostal INT = 0, 
@pHomeTel VARCHAR(100) = 0, -- Visitors may not be from Singapore so no +65 
@pAltTel VARCHAR(100) = NULL, 
@pMobTel VARCHAR(100) = 0, 
@pEmail VARCHAR(200) = 0, 
@pSex CHAR(50) = '', 
@pNationality VARCHAR(100) = '', 
@pDOB DATETIME = '09/08/1965', 
@pAge INT = 23, 
@pRace VARCHAR(150) = '', 
-- @pdateCreated DATETIME, 
-- @pdateUpdated DATETIME, 
@pWingNo INT = NULL, 
@pWardNo INT = NULL, 
@pCubicleNo INT = NULL, 
@pBedNo INT = NULL, 
@pcreatedBy VARCHAR(100) = 'MASTER', 
@pVisitTime VARCHAR(100) = NULL,
@pPurpose VARCHAR(100) = '',
@pPatientName VARCHAR(100) = NULL,
@pPatientNric VARCHAR(100) = NULL,
@visitLocation VARCHAR(100) = NULL,
@visitPurpose VARCHAR(100) = NULL,
@approved VARCHAR(50) = 'No',
@pResponseMessage NVARCHAR(250) OUTPUT 
 
AS 
 
BEGIN 
    SET NOCOUNT ON 

DECLARE @visitor_id INT
 
IF EXISTS (SELECT visitor_id FROM dbo.visitor WHERE nric = @pNric) 
BEGIN TRY 
	BEGIN
	IF NOT EXISTS (SELECT visit_id FROM dbo.visit_details WHERE CAST(dateCreated AS DATE) = CAST(GETDATE() AS DATE))  -- Query visit_details. If entry date is not today, insert new visit_details row
		BEGIN
			SET @visitor_id = (SELECT visitor_id FROM dbo.visitor WHERE nric = @pNric)
			INSERT INTO visit_details (cicoid, visitor_id, visitTime, purpose, patientName, patientNRIC, wingNo, wardNo, cubicleNo, bedNo, visitLocation, visitPurpose, dateCreated, approved) 
			VALUES (null, @visitor_id, @pVisitTime, @pPurpose, @pPatientName, @pPatientNric, @pWingNo, @pWardNo, @pCubicleNo, @pBedNo, @visitLocation, @visitPurpose, GETDATE(), @approved)
			SET @pResponseMessage='Existing Visitor Success' 
		END
	END
END TRY 
 
BEGIN CATCH 
SET @pResponseMessage=ERROR_MESSAGE()  
END CATCH  
 
ELSE 
BEGIN TRY 

INSERT INTO visitor (firstName, lastName, nric, address, postalCode, homeTel, altTel, 
mobTel, email, sex, nationality, dateOfBirth, age, race, dateCreated, dateUpdated, createdBy) 
VALUES(@pFirstName, @pLastName, @pNric, @pAddress, @pPostal, @pHomeTel, @pAltTel, 
@pMobTel, @pEmail, @pSex, @pNationality, @pDOB, '23', 'Chinese', GETDATE(), GETDATE(), @pCreatedBy) 

SET @visitor_id = (SELECT visitor_id FROM dbo.visitor WHERE nric = @pNric)
 
INSERT INTO visit_details (cicoid, visitor_id, visitTime, purpose, patientName, patientNRIC, wingNo, wardNo, cubicleNo, bedNo, visitLocation, visitPurpose, dateCreated, approved) 
VALUES (null, @visitor_id, @pVisitTime, @pPurpose, @pPatientName, @pPatientNric, @pWingNo, @pWardNo, @pCubicleNo, @pBedNo, @visitLocation, @visitPurpose, GETDATE(), @approved) 
 
SET @pResponseMessage='Success' 
SELECT TOP 1 visitor_id  
FROM [dbo].[visitor] WHERE nric = @pNric 
END TRY 
 
BEGIN CATCH 
SET @pResponseMessage=ERROR_MESSAGE()  
END CATCH 
END; 

----------------------------------------- Find Staff -----------------------------------------
GO
CREATE PROCEDURE [dbo].[Find Staff] 
  @id NVARCHAR(13),  
  @resp int Output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 IF EXISTS (SELECT * FROM dbo.staff WHERE nric = @id)
    set @resp=1;
  ELSE
	set @resp=0;
END

------------------------------------- Update Visitors' Movements ------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE FROM - UserMovement]  
@nric varchar(100),
@locationId INT,
@return_value INT
AS  
BEGIN  
  SET NOCOUNT ON  
  
  DECLARE @return_value INT
  SET @return_value = 1

  DECLARE @updateCheckIn VARCHAR(500),
		@cicoId INT

  SET @updateCheckIn = (SELECT TOP 1 checkpointtimeid FROM dbo.movementTable 
        WHERE @nric = nric AND date != '' AND
        (SELECT CONVERT(VARCHAR(10), SYSDATETIME(), 105) AS [DD-MM-YYYY])= date ORDER BY date DESC)
  SET @cicoId = (SELECT TOP 1 cicoid FROM dbo.check_in_out 
        WHERE @nric = nric AND checkinTime != '' AND
        (SELECT CONVERT(VARCHAR(10), SYSDATETIME(), 105) AS [DD-MM-YYYY])= (SELECT CONVERT(VARCHAR(10), checkinTime, 105) AS [DD-MM-YYYY]))

  IF @updateCheckIn IS NOT NULL
  BEGIN TRY
    UPDATE dbo.movementTable
    SET checkpointtimeid = ',' + @updateCheckIn + '' + CAST(@locationId AS VARCHAR(3)) + '' +  CAST(date AS VARCHAR(10))
    WHERE nric = @nric
	SET @return_value = 1
    SELECT @return_value
    END TRY 
  
  BEGIN CATCH  
    SET @return_value = 0
    SELECT @return_value
  END CATCH
  
  ELSE
  BEGIN TRY
    INSERT INTO dbo.movementTable
    VALUES(@nric, @cicoId, GETDATE(),NULL)

    SELECT @return_value
  End TRY
  
  BEGIN CATCH  
    SET @return_value = 0
    SELECT @return_value
  END CATCH   
END;
------------------------------------------ Update Location ----------------------------------------------------
GO
CREATE PROCEDURE [dbo].[UPDATE FROM - Locations]  
@id INT  
AS  
BEGIN  
SET NOCOUNT ON  
IF EXISTS (SELECT * FROM dbo.locations WHERE lid = @id) 
    BEGIN  
DECLARE @term_activate INT
DECLARE @return_value INT

SET @term_activate = 0
SET @return_value = 1
IF @term_activate = (SELECT activated FROM dbo.locations 
WHERE lid = @id)
     Update locations SET activated = 1 WHERE lid = @id; 
ELSE
SET @return_value = 0
END

SELECT @return_value;
--SELECT COALESCE(
--(SELECT activated FROM dbo.locations WHERE lid = @id), 0) 
END; 