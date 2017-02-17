--======================= THKHDB TEST DATA =======================--

------------------------------------------------------------ Procedures for creating Terminal
 BEGIN
    -- Terminal_ID == 2 (FIXED VARIABLE)
    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('HOSPITAL ENTRANCE', 1, 1, '2016-06-06 00:00', NULL)

    -- Terminal_ID == 3 (FIXED VARIABLE)
    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('HOSPITAL EXIT', 1, 1, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Ward 1', 1, 1, '2016-01-01 00:00', NULL)
    INSERT INTO TERMINAL_BED(terminalID, bedNoList)
    VALUES (3, '1101,1102,1202,1303')

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Ward 2', 1, 1, '2016-03-03 00:00', NULL)
    INSERT INTO TERMINAL_BED(terminalID, bedNoList)
    VALUES (4, '1104,3205,5306')

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Ward 3', 1, 1, '2016-06-06 00:00', NULL)
    INSERT INTO TERMINAL_BED(terminalID, bedNoList)
    VALUES (5, '5107,5208,5309')

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Ward 4', 1, 1, '2016-06-06 00:00', NULL)
    INSERT INTO TERMINAL_BED(terminalID, bedNoList)
    VALUES (6, '5108,5508,5509')

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Entrance: Ambulance Bay', 1, 1, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Cafeteria', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Khoo Teck Puat Clinic', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Pharmacy', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Healing Hub', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('Community Hub Centre', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('B. Braun Dialysis Centre', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('NHG Diagnostics', 1, 0, '2016-06-06 00:00', NULL)

    INSERT INTO TERMINAL(tName, activated, tControl, startDate, endDate)
    VALUES ('TCM Medical Centre', 1, 0, '2016-06-06 00:00', NULL)
END;


------------------------------------------------------------- Procedures for creating Staff
BEGIN
	DECLARE @salt UNIQUEIDENTIFIER = NEWID()  
	DECLARE @pCreatedBy VARCHAR(50) = 'GrizzlyBadger'
    
	BEGIN TRY  
        INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Shahid', 'Abdul', 'S12345', '417 Pasir Ris', 123417, '999', '999', '999', 'abdulsr.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1991-01-01', HASHBYTES('SHA2_512', '123'),  123456 , 'Admin', 'Doctor', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Aloysius', 'Lam', 'S9332934A', 'SMU', 123417, '999', '999', '999', 'aloysiuslam.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Christopher', 'Teo', 'S9332464A', 'SMU', 123417, '999', '999', '999', 'mjteo.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Jason', 'Wu', 'S9122934A', 'SMU', 123417, '999', '999', '999', 'jasonwu.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Zheng Yuan', 'Yu', 'S9112934A', 'SMU', 123417, '999', '999', '999', 'zyyu.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

    INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Friedemann', 'Ang', 'S9022934A', 'SMU', 123417, '999', '999', '999', 'zkang.2014@smu.edu.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)
   
	INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('Edy', 'Chandra', 'S2138934A', 'SMU', 123417, '999', '999', '999', 'edy@amk.org.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Admin', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)
	
	INSERT INTO STAFF (firstName, lastName, nric, address, postalCode, homeTel, altTel, mobTel, email, sex, nationality, 
              dateOfBirth, PasswordHash, permission, accessProfile, position, dateCreated, dateUpdated, createdBy)  
        VALUES('THK', 'Nurse', 'S2548934A', 'SMU', 123417, '999', '999', '999', 'nurse@amk.org.sg', 'M', 'SINGAPOREAN', 
        '1992-01-01', HASHBYTES('SHA2_512', '123'),  123456, 'Front Desk', 'Admin', GETDATE(), GETDATE(), @pCreatedBy)  

END TRY  

    BEGIN CATCH  
        SELECT 'ERROR!' 
    END CATCH  
END;


------------------------------------------------------------- Procedures for creating Permissions
BEGIN
		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (1,'Registration')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (2,'Form Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (4,'User Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (5,'Pass Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (3,'Terminal Management')

		INSERT INTO ACCESS_RIGHT(accessID, accessName)
		VALUES (6,'Contact Tracing')
END;



---------------------------------------------------------------------- Testing MASTER_CONFIG
BEGIN
    INSERT INTO MASTER_CONFIG(lowerTempLimit, upperTempLimit, warnTemp, lowerTimeLimit, upperTimeLimit, visitLimit, dateUpdated, updatedBy)
    VALUES ('35', '39.9', '37.6', '09:00', '20:00', 3, SYSDATETIME(), 'MASTER')
END; 


------------------------------------------------------------------ Testing for ACCESS_PROFILE
BEGIN
    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Admin', 123456, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Infection Control', 2356, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Front Desk', 1, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Configurator', 234, SYSDATETIME(), 'MASTER')

    INSERT INTO ACCESS_PROFILE(profileName, accessRights, dateUpdated, updatedBy)
    VALUES ('Facilities', 3, SYSDATETIME(), 'MASTER')
END;


----------------------------------------------------------- Procedures for creating Patient
BEGIN
	-------------------------- Patient admitted in Ward 1 (Terminal_ID = 3) --------------------------
    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (1101, 'S9876543E', 'Benny Tan', '2016-07-11 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (1102, 'S2465269F', 'Jamie Tan', '2016-08-14 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (1202, 'S2222222A', 'Charles Long', '2016-06-12 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (1303, 'S3333333A', 'Donald Trump', '2016-06-12 09:00', '2020-01-01 00:00')

	-------------------------- Patient admitted in Ward 2 (Terminal_ID = 4) --------------------------
    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (1104, 'S2468269F', 'Nicholas Lim', '2016-08-14 09:00', '2020-01-01 00:00')

    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (3205, 'S1111111E', 'Aaron Pang', '2016-06-12 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5306, 'S4444444E', 'Elaine', '2016-06-12 09:00', '2020-01-01 00:00')

	-------------------------- Patient admitted in Ward 3 (Terminal_ID = 5) --------------------------
    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5107, 'S5555555F', 'Muhammad Farhan Bin Yusri', '2016-08-14 09:00', '2020-01-01 00:00')

    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5208, 'S6666666E', 'Si Gui Gong', '2016-06-12 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5309, 'S7777777E', 'Elaine Ang Xiao Hui', '2016-06-12 09:00', '2020-01-01 00:00')

	-------------------------- Patient admitted in Ward 4 (Terminal_ID = 6) --------------------------
    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5108, 'S8888888F', 'Holmes Sherlock', '2016-08-14 09:00', '2020-01-01 00:00')

    INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5508, 'S9999999E', 'Iris Xuan Li', '2016-06-12 09:00', '2020-01-01 00:00')

	INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
    VALUES (5509, 'S0000000E', 'Iris Xuan Lin', '2016-06-12 09:00', '2020-01-01 00:00')
END 


------------------------------------------------------------- Procedures for creating Visitor
BEGIN
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S123', 'Jason', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 TAMPINES ST 44', 913476, GETDATE(), 0, 1)
		
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S170', 'Shahid', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 PASIR RIS ST 44', 913476, GETDATE(), 0, 1)

		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S456', 'Aloysius', 'M', 'SINGAPOREAN', '1990-10-11','987654321', 
				'BLK 476 WOODLANDS ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S789', 'Chris', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 BEDOK ST 44', 913476, GETDATE(), 0, 1)
		
		
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S246', 'Friedemann', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 JURONG ST 44', 913476, GETDATE(), 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S629', 'ZhengYuan', 'M', 'SINGAPOREAN', '1990-10-11', '987654321', 
				'BLK 476 KEMBANGAN ST 44', 913476, GETDATE(), 0, 1)
END;


-------------------------------------------------------------------- Procedures for testing Q_Qns
BEGIN
    INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
    VALUES ('Which country have you visited over the last 3 months? (If no, please select None)', 'ddList', 'None,Malaysia,USA,China,Russia', SYSDATETIME(), NULL)
    
     INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
    VALUES ('Were you diagnosed with fever over the last 3 days?', 'radio', 'Yes,No', SYSDATETIME(), NULL)

    INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
    VALUES ('Do you have any family members who travelled to overseas over the last 3 months? Please list down their name(s) if  applicable', 'text', '', SYSDATETIME(), NULL)
---------------------------------------------------------------------------------------------------------------------------------—

    INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
    VALUES ('Have you suffered from any of the following symptoms in the past 7 days? Check those applicable', 'checkbox', 'Cough,Fever,Nasal Congestion,Diarrhoea,Breathing Difficulties', SYSDATETIME(), NULL)

---------------------------------------------------------------------------------------------------------------------------------------------------------—

    INSERT INTO QUESTIONAIRE_QNS(question, qnsType, qnsValue, startDate, endDate)
    VALUES ('Have you visited any of the following countries in the past 7 days? Check those applicable', 'checkbox', 'Australia,Canada,China', SYSDATETIME(), NULL)
END;


--------------------------------------------------------------- Procedures for testing Q_Qns_List
BEGIN
		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('First', '3,1,2', 1, SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('Second', '5,6,4', 0, SYSDATETIME(), NULL)

		INSERT INTO QUESTIONAIRE_QNS_LIST(Q_QuestionListID, Q_Order, Q_Active, startDate, endDate)
		VALUES ('Third', '7,9,8', 0, '2016-01-01 00:00', SYSDATETIME()) 
END;


--------------------------------------------------------------- Procedures for creating Patient
BEGIN
		INSERT INTO QUESTIONAIRE_ANS
		VALUES ('FIRST_ANS_ID', 'First', 'JSON ANSWERS FOR QUESTIONNARIE (First)')
END;




--============================== VISIT > CHECK_IN > MOVEMENT ==============================--

-------------------------------------------------------------------------------------------------------------------------------- Procedures for creating Patient
--BEGIN
--		INSERT INTO VISIT
--		VALUES ('2016-12-29 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

--		INSERT INTO VISIT
--		VALUES ('2016-12-30 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

--		INSERT INTO VISIT
--		VALUES ('2016-12-30 16:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)

--		INSERT INTO VISIT
--		VALUES ('2016-12-31 14:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)
		
--		INSERT INTO VISIT
--		VALUES ('2017-01-26 20:00', 'S123', 'Visiting', NULL, 'T1', '1101', 'FIRST_ANS_ID', '', 1)? 
--END;


------------------------------------------------------------------- Procedures for CHECK_IN
--BEGIN
--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S123', '2016-12-29 14:00', '36.7', 'abdulsr.2014@smu.edu.sg')

--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S123', '2016-12-30 14:30', '36.7', 'abdulsr.2014@smu.edu.sg')

--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S123', '2016-12-30 16:00', '36.7', 'abdulsr.2014@smu.edu.sg')

--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S123', '2016-12-31 14:00', '36.7', 'abdulsr.2014@smu.edu.sg')

--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S123', '2017-01-26 20:00', '36.7', 'abdulsr.2014@smu.edu.sg')
		
--		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
--		VALUES ('S789', '2016-12-29 20:00', '36.9', 'abdulsr.2014@smu.edu.sg')
--END 


---------------------------------------------------------- Procedures for creating MOVEMENT
--BEGIN
--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-10-10 07:00', 4, '2016-10-10 07:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-10-10 07:00', 1, '2016-10-10 08:00')
--		---------------------------------------------------------------------- Exited

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-10-11 09:00', 4, '2016-10-11 09:05')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-10-11 09:00', 1, '2016-10-11 10:15')
--		---------------------------------------------------------------------- Exited

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-11-20 20:00', 4, '2016-11-20 20:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-11-20 20:00', 1, '2016-11-20 21:07')
--		---------------------------------------------------------------------- Exited

--	------------------------------------------------------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 14:00', 4, '2016-12-29 14:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 14:00', 1, '2016-12-29 15:30')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 17:00', 5, '2016-12-29 17:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 17:00', 1, '2016-12-29 18:20')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 21:00', 6, '2016-12-29 21:01')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-29 21:00', 1, '2016-12-29 22:35')

--	------------------------------------------------------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S789', '2016-12-29 20:00', 4, '2016-12-29 19:50')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S789', '2016-12-29 20:00', 1, '2016-12-29 21:00')

--	------------------------------------------------------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-29 17:00', 4, '2016-12-29 17:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-29 17:00', 1, '2016-12-29 19:01')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-29 23:00', 5, '2016-12-29 23:01')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-29 23:00', 1, '2016-12-29 23:31')


--	---------------------------NEXT MOVEMENT PERIOD---------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 14:30', 4, '2016-12-30 14:45')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 14:30', 1, '2016-12-30 15:50')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 16:00', 4, '2016-12-30 16:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 16:00', 1, '2016-12-30 16:50')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 18:00', 5, '2016-12-30 18:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 18:00', 1, '2016-12-30 19:12')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 20:00', 6, '2016-12-30 20:00')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-30 20:00', 1, '2016-12-30 21:12')

--	------------------------------------------------------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S789', '2016-12-30 20:00', 4, '2016-12-30 19:50')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S789', '2016-12-30 20:00', 1, '2016-12-30 20:45')

--	------------------------------------------------------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-30 17:00', 4, '2016-12-30 17:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-30 17:00', 1, '2016-12-30 18:11')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-30 19:00', 5, '2016-12-30 19:01')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S456', '2016-12-30 19:00', 1, '2016-12-30 21:31')


--	---------------------------NEXT MOVEMENT PERIOD---------------------------------

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 14:00', 4, '2016-12-31 14:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 14:00', 1, '2016-12-31 15:10')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 17:00', 5, '2016-12-31 17:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 17:00', 1, '2016-12-31 18:02')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 19:00', 6, '2016-12-31 18:57')

--		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
--		VALUES ('S123', '2016-12-31 19:00', 1, '2016-12-31 20:00')
--END;


--====================================== FULL RUN TESTING ======================================--

----------------------------------------------------------------------------- Created by Fried 
BEGIN

	BEGIN
		INSERT INTO PATIENT(bedNo, nric, patientFullName, startDate, endDate)
		VALUES (1202, 'S8888999Z', 'Li Bai Ka', '2015-01-13 10:00', '2016-06-25 17:30')
	END 

	BEGIN
		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S1111222A', 'Lim Bo Chap', 'M', 'SINGAPOREAN', '1982-10-25', '90001234', 
				'Blk 144 HDB Teck Whye', 680144, '2014-01-29 05:00:00 AM', 0, 1)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S3333444B', 'Tan Ah Boy', 'M', 'SINGAPOREAN', '1992-03-13','85554321', 
				'7 Jln Terang Bulan', 457285, '2015-01-29 12:00:00 PM', 1, 0)


		INSERT INTO VISITOR_PROFILE(nric, fullName, gender, nationality, dateOfBirth, mobileTel,
									homeAddress, postalCode, time_stamp, confirm, amend)
		VALUES ('S5555666Z', 'Ninjavan', 'F', 'MALAYSIAN', '1988-07-31', '87650000', 
				'Block 853 HDB Yishun', 760853, '2015-01-29 17:00:00', 0, 1)
	END

	BEGIN
		INSERT INTO QUESTIONAIRE_ANS
		VALUES('SECOND_ANS_ID', 'Second', 'JSON ANSWERS FOR QUESTIONNARIE (Second)')
	END

	BEGIN
		INSERT INTO VISIT
		VALUES ('2015-01-29 10:00:00', 'S1111222A', 'Visiting', NULL, NULL, '1202', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 12:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1202', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 14:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1202', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 16:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1202', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 18:00:00', 'S3333444B', 'Visiting', NULL, NULL, '1202', 'SECOND_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2015-01-29 19:00:00', 'S5555666Z', 'Other Purpose', 'Delivery', 'CAFETERIA', NULL, 'FIRST_ANS_ID', '', 1)
	END 

	BEGIN
		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S1111222A', '2015-01-29 09:00:00', '37.2', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S3333444B', '2015-01-29 12:30:00', '36.8', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S3333444B', '2015-01-29 17:30:00', '37.1', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', '37.0', 'abdulsr.2014@smu.edu.sg')
	END 

	BEGIN

		---------------------------------------------------------------------- Lim Bo Chap checks in earlier than time he registered to visit, and is automatically scanned in.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 1, '2015-01-29 09:15:00')
		---------------------------------------------------------------------- Lim Bo Chap scans at place he didn't register to visit.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 8, '2015-01-29 09:25:20')
		---------------------------------------------------------------------- Lim Bo Chap doesn't scan out.

		---------------------------------------------------------------------- Tan Ah Boy checks in, and is scanned in automatically. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 1, '2015-01-29 14:02:00')
		---------------------------------------------------------------------- Tan Ah Boy scans at place he registered to visit
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 3, '2015-01-29 14:10:00')
		---------------------------------------------------------------------- Tan Ah Boy scans out to grab a late lunch.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 12:30:00', 2, '2015-01-29 15:45:00')
		---------------------------------------------------------------------- Tan Ah Boy has to check in again since he scanned out. The system scans him in.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 1, '2015-01-29 17:31:00')
		---------------------------------------------------------------------- Tan Ah Boy scans at the place he registered to visit, again.
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 3, '2015-01-29 17:41:00')
		---------------------------------------------------------------------- Ninjavan scans in. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 1, '2015-01-29 18:47:00')
		---------------------------------------------------------------------- Tan Ah Boy scans out. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S3333444B', '2015-01-29 17:30:00', 2, '2015-01-29 19:00:00')
		---------------------------------------------------------------------- Ninjavan scans at place she didn't register to visit
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 3, '2015-01-29 19:10:00')
		---------------------------------------------------------------------- Ninjavan scans out. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S5555666Z', '2015-01-29 18:45:00', 2, '2015-01-29 19:35:00')
		---------------------------------------------------------------------- Lim Bo Chap is scanned out by the system. 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S1111222A', '2015-01-29 09:00:00', 2, '2015-01-29 23:50:00')
	END

END;


------------------------------------------------------------------------------- Created by Jason
BEGIN
	BEGIN
		INSERT INTO VISIT
		VALUES ('2017-02-01 10:00:00', 'S123', 'Visiting', NULL, NULL, '1101,1104', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2017-02-01 12:00:00', 'S456', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2017-02-01 14:00:00', 'S789', 'Visiting', NULL, NULL, '1104', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2017-02-02 16:00:00', 'S246', 'Visiting', NULL, NULL, '1101', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2017-02-02 18:00:00', 'S629', 'Visiting', NULL, NULL, '1104', 'FIRST_ANS_ID', '', 1)

		INSERT INTO VISIT
		VALUES ('2017-02-01 19:00:00', 'S123', 'Other Purpose', 'Delivery', 'CAFETERIA', NULL, 'FIRST_ANS_ID', '', 1)
	END 

	BEGIN
		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2017-02-01 09:00:00', '37.2', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S456', '2017-02-01 12:15:00', '36.8', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S789', '2017-02-01 14:02:00', '37.1', 'abdulsr.2014@smu.edu.sg')

		INSERT INTO CHECK_IN (nric, visitActualTime, temperature, staffEmail)
		VALUES ('S123', '2017-02-01 18:45:00', '37.0', 'abdulsr.2014@smu.edu.sg')
    END 

	BEGIN

		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2017-02-01 09:00:00', 3, '2017-02-01 09:35:00')
		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2017-02-01 09:00:00', 4, '2017-02-01 11:00:20')
		---------------------------------------------------------------------- Nvr register
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2017-02-01 09:00:00', 5, '2017-02-01 14:12:20')
		---------------------------------------------------------------------- Nvr register
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2017-02-01 09:00:00', 2, '2017-02-01 18:00:20')
		----------------------------------------------------------------------
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S123', '2017-02-01 09:00:00', 8, '2017-02-01 19:04:20')
		---------------------------------------------------------------------- Does not scan the EXIT Terminal.

		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2017-02-01 12:00:00', 3, '2017-02-01 12:15:00')
		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S456', '2017-02-01 12:00:00', 2, '2017-02-01 14:10:00')
		---------------------------------------------------------------------- 
		
		----------------------------------------------------------------------
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2017-02-01 14:00:00', 4, '2017-02-01 15:45:00')
		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S789', '2017-02-01 17:30:00', 2, '2017-02-01 17:31:00')
		----------------------------------------------------------------------
	END

	BEGIN
		----------------------------------------------------------------------
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S246', '2017-02-02 16:00:00', 3, '2017-02-02 15:50:00')
		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S246', '2017-02-02 16:00:00', 2, '2017-02-02 17:11:00')
		----------------------------------------------------------------------

				----------------------------------------------------------------------
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S629', '2017-02-02 18:00:00', 5, '2017-02-02 18:02:00')
		---------------------------------------------------------------------- 
		INSERT INTO MOVEMENT(nric, visitActualTime, locationID, locationTime)
		VALUES ('S629', '2017-02-02 18:00:00', 2, '2017-02-02 20:07:00')
		----------------------------------------------------------------------
	END
END;


------------------------------------------------------------------------------------------created by fried
--GO
--CREATE PROCEDURE [dbo].[TEST_DATA_GENERATE]
--AS
--BEGIN
--  SET NOCOUNT ON

--    DECLARE  @return_value int,
--        @responseMessage varchar(250)

--    EXEC  @return_value = [dbo].[TEST_PERMISSIONS]
--    EXEC  @return_value = [dbo].[TEST_ACCESS_PROFILE]
--    EXEC  @return_value = [dbo].[TEST_CONFIG]
--    EXEC  @return_value = [dbo].[TEST_VISITOR_PROFILE]
--    EXEC  @return_value = [dbo].[TEST_TERMINAL]
--    EXEC  @return_value = [dbo].[TEST_QUESTIONAIRE_QNS_LIST]
--    EXEC  @return_value = [dbo].[TEST_QUESTIONAIRE_QNS]
--    EXEC  @return_value = [dbo].[TEST_QUESTIONNAIRE_ANS]
--    EXEC  @return_value = [dbo].[TEST_PATIENT]
--    EXEC  @return_value = [dbo].[TEST_MOVEMENT]
--    EXEC  @return_value = [dbo].[TEST_CREATE_STAFF]
--        @responseMessage = @responseMessage OUTPUT
--    EXEC  @return_value = [dbo].[TEST_CREATE_ADMIN]
--        @responseMessage = @responseMessage OUTPUT
--    EXEC  @return_value = [dbo].[TEST_CHECK_IN]
--    EXEC  @return_value = [dbo].[TEST_VISIT]
--    EXEC  @return_value = [dbo].[TEST_TRACING]
--END;

