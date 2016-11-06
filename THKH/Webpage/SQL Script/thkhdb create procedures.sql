
---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for adding user and logging in 
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
 
---------------------------------------------------------------------------------------------------------------------------------------------------- Validate Staff Login 
GO 
/****** Object:  StoredProcedure [dbo].[SELECT FROM - login]    Script Date: 30/10/2016 15:48:06 ******/ 
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
 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- Check if Returning visitor 
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
 
---------------------------------------------------------------------------------------------------------------------------------------------------- Edit visitor info TO BE EDITED
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

---------------------------------------------------------------------------------------------------------------------------------------------------- Get Visitor Details 
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
 
---------------------------------------------------------------------------------------------------------------------------------------------------- Find visitor 
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
 
 
------------------------------------------------------------------------------------------------------------------------------------- Validate Check_in Attempt (More than 3 visitors?) TO BE EDITED
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
 
--------------------------------------------------------------------------------------------- Procedures for adding details in Check_In_Out   for the check in step
CREATE PROCEDURE [dbo].[INSERT INTO  - First_Check_In] 
 
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
 
-------------------------------------------------------------------- Procedures for updating details in Check_In_Out for the checkout step
GO 
CREATE PROCEDURE [dbo].[UPDATE TO - CheckOut] 
 
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
 
GO 
CREATE PROCEDURE [dbo].[UPDATE FROM - Locations] 
  @id INT 
AS 
BEGIN 
    SET NOCOUNT ON 
     
    BEGIN 
      Update locations set activated=1 where lid=@id; 
      select 'success'; 
    END 
END; 
 
 
---------------------------------------------------------------------------------------------------------------------------------------------------- Procedures for adding new visitor 
GO 
CREATE PROCEDURE [dbo].[INSERT INTO  - Registration] 
 
@pFirstName VARCHAR(200), 
-- @pLastName VARCHAR(200), 
@pNric VARCHAR(100), 
@pAddress VARCHAR(300), 
@pPostal INT, 
@pHomeTel VARCHAR(100), -- Visitors may not be from Singapore so no +65 
-- @pAltTel VARCHAR(100) = NULL, 
@pMobTel VARCHAR(100), 
@pEmail VARCHAR(200), 
@pSex CHAR(50), 
@pNationality VARCHAR(100), 
@pDOB DATE = '09/08/1965', 
-- @pAge INT, 
-- @pRace VARCHAR(150), 
-- @pdateCreated DATETIME, 
-- @pdateUpdated DATETIME, 
@pVisitTime DATETIME, 
@pWingNo INT, 
@pWardNo INT, 
@pCubicleNo INT, 
@pBedNo INT, 
@pcreatedBy VARCHAR(100) = 'MASTER', 
@pResponseMessage NVARCHAR(250) OUTPUT 
 
AS 
 
BEGIN 
    SET NOCOUNT ON 
 
IF EXISTS (SELECT visitor_id FROM dbo.visitor WHERE nric = @pNric) 
BEGIN TRY 
SET @pResponseMessage='Existing vistor' 
SELECT TOP 1 nric 
FROM [dbo].[visitor]  
END try 
 
BEGIN CATCH 
SET @pResponseMessage=ERROR_MESSAGE()  
END CATCH  
 
ELSE 
BEGIN TRY 
INSERT INTO visitor (firstName, lastName, nric, address, postalCode, homeTel, altTel, 
mobTel, email, sex, nationality, dateOfBirth, age, race, dateCreated, dateUpdated, createdBy) 
VALUES(@pFirstName, null, @pNric, @pAddress, @pPostal, @pHomeTel, null, 
@pMobTel, @pEmail, @pSex, @pNationality, @pDOB, null, null, GETDATE(), GETDATE(), @pCreatedBy) 
 
INSERT INTO visit_details (cicoid, visitTime, wingNo, wardNo, cubicleNo, bedNo, dateCreated) 
VALUES (null, @pVisitTime, @pWingNo, @pWardNo, @pCubicleNo, @pBedNo, GETDATE()) 
 
SET @pResponseMessage='Success' 
SELECT TOP 1 visitor_id  
FROM [dbo].[visitor] WHERE nric = @pNric 
END TRY 
 
BEGIN CATCH 
SET @pResponseMessage=ERROR_MESSAGE()  
END CATCH 
END; 

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
@nric varchar(50)  

AS  
BEGIN  
	SET NOCOUNT ON  
	
	DECLARE @return_value INT
	SET @return_value = 1
	
	IF EXISTS (SELECT TOP 1 moveid FROM dbo.movementTable 
	WHERE @nric = nric ORDER BY date DESC)
		SELECT @return_value
	
	ELSE
		SET @return_value = 0
		SELECT @return_value
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
