USE thkhdb
GO

DECLARE	@return_value int,
		@responseMessage nvarchar(250)

EXEC	@return_value = [dbo].[INSERT INTO  - staff]
		@pLogin = 1,
		@pPassword = N'123',
		@pFirstName = N'123',
		@pLastName = N'123',
		@pNric = N'123',
		@pAddress = N'123',
		@pPostal = 123,
		@pHomeTel = N'123',
		@pAltTel = N'123',
		@pMobileTel = N'123',
		@pEmail = N'123',
		@pSex = N'h',
		@pNationality = N'123',
		@pDOB = '2000-09-09',
		@pAge = 12,
		@pRace = N'123',
		@pPermission = 1,
		@pPostion = N'1',
		@pCreatedBy = N'master',
		@responseMessage = @responseMessage OUTPUT

SELECT	@responseMessage as N'@responseMessage'

SELECT	'Return Value' = @return_value

GO
