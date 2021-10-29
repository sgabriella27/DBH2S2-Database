USE [Cheviot Police Station]

-- MEDIUM (7)

-- 1
-- Create trigger named 'trigger_drop_table' that will prevent the user for dropping table in the database
GO
CREATE TRIGGER trigger_drop_table
ON DATABASE
FOR DROP_TABLE
AS
	PRINT('You cannot drop any table in Cheviot Police Station Database!')
	ROLLBACK

DROP TRIGGER trigger_drop_table ON DATABASE

BEGIN TRAN
DROP TABLE Trial
ROLLBACK

-- 2
-- Create trigger named 'trigger_new_position' that print all the data from StaffPosition table and also the new data
GO
CREATE TRIGGER trigger_new_position
ON StaffPosition
FOR INSERT
AS
DECLARE @staff_position_id CHAR(5)
DECLARE @staff_position_name VARCHAR(100)
	DECLARE cursor_new_position CURSOR
	FOR SELECT
		s.StaffPositionID,
		s.StaffPositionName
	FROM
		inserted i,
		StaffPosition s

OPEN cursor_new_position
FETCH NEXT FROM cursor_new_position INTO
	@staff_position_id,
	@staff_position_name

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Staff Position ID %3s %-10s', ':', @staff_position_id)
		PRINT FORMATMESSAGE('Staff Position Name %1s %-10s', ':', @staff_position_name)
		PRINT '======================================================'
		FETCH NEXT FROM cursor_new_position INTO
			@staff_position_id,
			@staff_position_name
	END

CLOSE cursor_new_position
DEALLOCATE cursor_new_position
DROP TRIGGER trigger_new_position

BEGIN TRAN
INSERT INTO StaffPosition VALUES ('SP008', 'Undercover Agent')
ROLLBACK

-- 3
-- Create trigger 'trigger_new_staff' that use a cursor named 'cursor_new_staff' that will print all new data when inserted into Staff table
GO
CREATE TRIGGER trigger_new_staff
ON Staff
FOR INSERT
AS
DECLARE @staff_id CHAR(5)
DECLARE @staff_position_id CHAR(5)
DECLARE @staff_name VARCHAR(100)
DECLARE @staff_phone_number VARCHAR(20)
DECLARE @staff_address VARCHAR(100)
DECLARE @staff_gender VARCHAR(10)
	DECLARE cursor_new_staff CURSOR
	FOR SELECT
		StaffID,
		StaffPositionID,
		StaffName,
		StaffPhoneNumber,
		StaffAddress,
		StaffGender
	FROM
		inserted

	OPEN cursor_new_staff
	FETCH NEXT FROM cursor_new_staff INTO
			@staff_id,
			@staff_position_id,
			@staff_name,
			@staff_phone_number,
			@staff_address,
			@staff_gender

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Staff ID %11s %-10s', ':', @staff_id)
		PRINT FORMATMESSAGE('Staff Position ID %2s %-10s', ':', @staff_position_id)
		PRINT FORMATMESSAGE('Staff Name %9s %-10s', ':', @staff_name)
		PRINT FORMATMESSAGE('Staff Phone Number %1s %-10s', ':', @staff_phone_number)
		PRINT FORMATMESSAGE('Staff Address %6s %-10s', ':', @staff_address)
		PRINT FORMATMESSAGE('Staff Gender %7s %-10s', ':', @staff_gender)
		PRINT '======================================================'
		FETCH NEXT FROM cursor_new_staff INTO
			@staff_id,
			@staff_position_id,
			@staff_name,
			@staff_phone_number,
			@staff_address,
			@staff_gender
	END

CLOSE cursor_new_staff
DEALLOCATE cursor_new_staff
DROP TRIGGER trigger_new_staff
	
BEGIN TRAN
INSERT INTO Staff
VALUES
	('ST036', 'SP002', 'Orelle Mawd', 		'849-619-4129', '56891 Delaware Street', 'Male'),
	('ST037', 'SP002', 'Elana Yurmanovev', 	'772-163-6077', '22 Independence Court', 'Male')
ROLLBACK

-- 4
-- Create trigger named 'trigger_prevent_future_case' that can prevent the user from inserting new case with start date more than current date
GO
CREATE TRIGGER trigger_prevent_future_case
ON CaseHeader
INSTEAD OF INSERT
AS
DECLARE @case_id CHAR(5)
DECLARE @case_type_id CHAR(5)
DECLARE @case_start_date DATE
DECLARE @case_end_date DATE
DECLARE @case_status VARCHAR(10)
DECLARE @crime_scene_longitude DECIMAL(9, 6)
DECLARE @crime_scene_latitude DECIMAL(9, 6)
	SELECT
		@case_id = CaseID,
		@case_type_id = CaseTypeID,
		@case_start_date = CaseStartDate,
		@case_end_date = CaseEndDate, 
		@case_status = CaseStatus,
		@crime_scene_longitude = CrimeSceneLongitude,
		@crime_scene_latitude = CrimeSceneLatitude
	FROM inserted

	IF @case_start_date > GETDATE()
	BEGIN
		PRINT 'You cannot insert case with start date more than current date'
		RETURN
	END
	
	INSERT INTO CaseHeader
	VALUES (@case_id, @case_type_id, @case_start_date, @case_end_date, @case_status, @crime_scene_longitude, @crime_scene_latitude)
	PRINT 'Insert new case success!'

BEGIN TRAN
	INSERT INTO CaseHeader VALUES('CA021', 'CT003', DATEADD(DAY, 1, GETDATE()), NULL, 'On Going', 51.678158, 15.4217858)
	INSERT INTO CaseHeader VALUES('CA021', 'CT003', GETDATE(), NULL, 'On Going', 51.678158, 15.4217858)
ROLLBACK
DROP TRIGGER trigger_prevent_future_case

-- 5
-- Create cursor name 'cursor_role' that will print SuspectName, VictimName and StaffName also print their role (obtained from each person role).
GO
DECLARE
	@name VARCHAR(100),
	@role VARCHAR(100)

DECLARE cursor_role CURSOR
FOR SELECT
	SuspectName, 
	'Suspect'
FROM
	Suspect
UNION
SELECT
	VictimName, 
	'Victim'
FROM
	Victim
UNION
SELECT
	StaffName,
	StaffPositionName
FROM
	Staff s
	JOIN StaffPosition sp
	ON s.StaffPositionID = sp.StaffPositionID

OPEN cursor_role
FETCH NEXT FROM cursor_role INTO
	@name,
	@role

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Name : ' + @name
		PRINT 'Role : ' + @role
		PRINT '========================='
		FETCH NEXT FROM cursor_role INTO
			@name,
			@role
	END

CLOSE cursor_role
DEALLOCATE cursor_role

-- 6
-- Create cursor name 'cursor_staff_view' that will print all of the staff name and position id (lompat 2")
DECLARE
	@staff_name	VARCHAR(100),
	@staff_phone_number	VARCHAR(20)

DECLARE cursor_staff_view SCROLL CURSOR
FOR SELECT
		StaffName,
		StaffPhoneNumber
	FROM
		Staff

OPEN cursor_staff_view
FETCH RELATIVE 2 FROM cursor_staff_view INTO
	@staff_name,
	@staff_phone_number

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Staff Name : ' + @staff_name + ' - Staff Phone Number : ' + @staff_phone_number
		PRINT '=========================================================================='
		FETCH RELATIVE 2 FROM cursor_staff_view INTO
			@staff_name,
			@staff_phone_number
	END

CLOSE cursor_staff_view
DEALLOCATE cursor_staff_view

-- 7
-- Create cursor named 'cursor_staff_position' to print all of StaffPositionID and StaffPositionName backwards.
GO
DECLARE
	@staff_position_id CHAR(5),
	@staff_position_name VARCHAR(100)

DECLARE cursor_staff_position SCROLL CURSOR
FOR SELECT
		StaffPositionID,
		StaffPositionName
	FROM
		StaffPosition

OPEN cursor_staff_position
FETCH LAST FROM cursor_staff_position INTO
	@staff_position_id,
	@staff_position_name

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Staff Position ID : ' + @staff_position_id
		PRINT 'Staff Position Name : ' + @staff_position_name
		PRINT '=============================================='
		FETCH PRIOR FROM cursor_staff_position INTO
			@staff_position_id,
			@staff_position_name
	END

CLOSE cursor_staff_position
DEALLOCATE cursor_staff_position