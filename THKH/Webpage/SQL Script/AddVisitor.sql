USE thkhdb
GO

INSERT INTO [dbo].[visitor]
           ([firstName]
           ,[lastName]
           ,[nric]
           ,[address]
           ,[postalCode]
           ,[homeTel]
           ,[altTel]
           ,[mobTel]
           ,[email]
           ,[sex]
           ,[nationality]
           ,[dateOfBirth]
           ,[age]
           ,[race]
           ,[dateCreated]
           ,[dateUpdated]
           ,[createdBy])
     VALUES
           ('Aloysius',
           'Lam',
           'S9332934A',
           'Beans Road',
           377629,
           '234',
           '345',
           '97414463',
           'beans@hotmail.com',
           'M',
           'Singaporean',
           '1965-08-09',
           '51',
           'Chinese',
           GETDATE(),
           GETDATE(),
           'master'),
		   ('Thomas',
           'Lee',
           'S9832934A',
           'Beans Road',
           378729,
           '234',
           '345',
           '97654463',
           'behus@hotmail.com',
           'M',
           'Singaporean',
           '1999-12-09',
           '51',
           'Chinese',
           GETDATE(),
           GETDATE(),
           'MASTER'),
		   ('Cheryl',
           'Tan',
           'S9112934A',
           'Red Road',
           377119,
           '234',
           '345',
           '92314463',
           'btgns@hotmail.com',
           'F',
           'Singaporean',
           '1993-11-09',
           '2',
           'Chinese',
           GETDATE(),
           GETDATE(),
           'MASTER'),
		   ('Melissa',
           'Ang',
           'S9152934A',
           'Mels Road',
           363629,
           '234',
           '345',
           '97411163',
           'iuhds@hotmail.com',
           'F',
           'Chinese National',
           '1991-08-30',
           '1',
           'Chinese',
           GETDATE(),
           GETDATE(),
           'MASTER')
GO


