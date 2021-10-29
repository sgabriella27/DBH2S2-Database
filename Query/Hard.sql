USE [Cheviot Police Station]

-- HARD (5)

-- 1
-- Create case report using cursor for case that has 'CA001' as it's CaseID. The case will contains of Case ID (obtained from Case ID), CaseStartDay and Date (obtained from CaseStartDate with 'dd mon yyyy' format), CaseStatus, CaseType, PerpetratorName (obtained from suspect name that has 'Guilty' as GuiltyStatus), DetectiveName (obtained from staff that handle the case and the role is detective), VictimName and VictimGender.
GO
DECLARE
	@case_id CHAR(5),
	@case_start_day VARCHAR(10),
	@case_start_date DATE,
	@case_status VARCHAR(20),
	@case_type VARCHAR(50),
	@perpetrator_name VARCHAR(100),
	@detective_name VARCHAR(100),
	@victim_name VARCHAR(100),
	@victim_gender VARCHAR(100)

DECLARE cursor_case_report CURSOR
FOR SELECT
		ch.CaseID,
		DATENAME(WEEKDAY, CaseStartDate),
		CONVERT(VARCHAR, CaseStartDate, 106),
		CaseStatus,
		CaseTypeName,
		PerpetratorName = SuspectName
	FROM
		CaseHeader ch
		JOIN CaseDetail cd
		ON ch.CaseID = cd.CaseID
		JOIN CaseType ct
		ON ch.CaseTypeID = ct.CaseTypeID
		JOIN Suspect s
		ON ch.CaseID = s.CaseID
	WHERE
		GuiltyStatus = 'Guilty' AND ch.CaseID = 'CA001'

OPEN cursor_case_report
FETCH NEXT FROM cursor_case_report INTO
	@case_id,
	@case_start_day,
	@case_start_date,
	@case_status,
	@case_type,
	@perpetrator_name

PRINT 'Case Report'
PRINT '==========='
PRINT FORMATMESSAGE('Case ID %10s %-10s %30s %1s %2s', ':', @case_id, @case_start_day, ',', CAST(@case_start_date AS VARCHAR))
PRINT FORMATMESSAGE('Case Status %6s %-10s', ':', @case_status)
PRINT FORMATMESSAGE('Case Type %8s %-10s', ':', @case_type)
PRINT FORMATMESSAGE('Perpetrator Name : %-10s', @perpetrator_name)
PRINT ''
CLOSE cursor_case_report

-- Victim
DECLARE cursor_victim CURSOR
FOR SELECT
		VictimName,
		VictimGender
	FROM
		CaseHeader ch
		JOIN Victim v
		ON ch.CaseID = v.CaseID
	WHERE
		ch.CaseID = 'CA001'

OPEN cursor_victim
FETCH NEXT FROM cursor_victim INTO
	@victim_name,
	@victim_gender

PRINT 'Victim Name and Gender : '
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '- ' + @victim_name + '(' + @victim_gender + ')'
		FETCH NEXT FROM cursor_victim INTO
			@victim_name,
			@victim_gender
	END

-- Detective
DECLARE cursor_detective CURSOR
FOR SELECT
		StaffName
	FROM
		Staff s
		JOIN StaffPosition sp
		ON s.StaffPositionID = sp.StaffPositionID
	WHERE
		StaffPositionName = 'Detective'

OPEN cursor_detective
FETCH NEXT FROM cursor_detective INTO
	@detective_name

PRINT ''
PRINT 'Detective Name : '
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '- ' + @detective_name
		FETCH NEXT FROM cursor_detective INTO
			@detective_name
	END

CLOSE cursor_victim
CLOSE cursor_detective

DEALLOCATE cursor_case_report
DEALLOCATE cursor_victim
DEALLOCATE cursor_detective

-- 2
-- Create cursor 'cursor_crime_evidence_distance' to display CaseID and all of the EvidenceName and EvidenceDistance (obtained from distance between Crime Scene and Evidence Location in kilometer) for case that has 'CA007' as the CaseID
GO
DECLARE
	@case_id CHAR(5),
	@evidence_name VARCHAR(50),
	@crime_scene_location GEOGRAPHY,
	@evidence_location GEOGRAPHY

DECLARE cursor_crime_evidence_distance CURSOR
FOR
	SELECT
		ch.CaseID,
		EvidenceName,
		geography::Point(CrimeSceneLatitude, CrimeSceneLongitude, 4326),
		geography::Point(EvidenceLatitude, EvidenceLongitude, 4326)
	FROM
		CaseHeader ch
		JOIN Evidence e
		ON ch.CaseID = e.CaseID
	WHERE
		ch.CaseID = 'CA007'

OPEN cursor_crime_evidence_distance
FETCH NEXT FROM cursor_crime_evidence_distance INTO
	@case_id,
	@evidence_name,
	@crime_scene_location,
	@evidence_location

PRINT '==================='
PRINT FORMATMESSAGE('| Case ID : %s |', @case_id)
PRINT '==================='
PRINT ''

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Evidence Name : %s', @evidence_name)
		PRINT FORMATMESSAGE('Distance From Crime Scene : %-2s KM', CAST(@crime_scene_location.STDistance(@evidence_location) / 1000 AS VARCHAR))
		PRINT '======================================'
		FETCH NEXT FROM cursor_crime_evidence_distance INTO
			@case_id,
			@evidence_name,
			@crime_scene_location,
			@evidence_location
	END

CLOSE cursor_crime_evidence_distance
DEALLOCATE cursor_crime_evidence_distance

-- 3
-- Create cursor named 'cursor_case_handled' that will print StaffID, StaffName and CaseHandled (obtained from how many case that every staff handled) where the case handled less than average
GO
DECLARE
	@staff_id CHAR(5),
	@staff_name VARCHAR(100),
	@case_handled INT

DECLARE cursor_case_handled CURSOR
FOR SELECT
	s.StaffID,
	StaffName,
	CaseHandled = COUNT(cd.CaseID)
FROM 
	CaseHeader ch
	JOIN CaseDetail cd
	ON ch.CaseID = cd.CaseID
	JOIN Staff s
	ON cd.StaffID = s.StaffID,
	(
		SELECT
			AVG(CountCase.cc) as ac
		FROM
			CaseHeader ch
			JOIN CaseDetail cd
			ON ch.CaseID = cd.CaseID
			JOIN Staff s
			ON cd.StaffID = s.StaffID,
			(
				SELECT
					StaffID,COUNT(cd.CaseID) as cc
				FROM
					CaseHeader ch
					JOIN CaseDetail cd
					ON ch.CaseID = cd.CaseID
				GROUP BY StaffId
			) as CountCase
	) as AvgCase
GROUP BY s.StaffID, StaffName, AvgCase.ac
HAVING COUNT(cd.CaseID) < AvgCase.ac

OPEN cursor_case_handled
FETCH NEXT FROM cursor_case_handled INTO
	@staff_id,
	@staff_name,
	@case_handled
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Staff ID %5s %-10s', ':', @staff_id)
		PRINT FORMATMESSAGE('Staff Name %3s %-10s', ':', @staff_name)
		PRINT FORMATMESSAGE('Case Handled %1s %-10s', ':', CAST(@case_handled AS VARCHAR))
		PRINT '==============================================================='
		FETCH NEXT FROM cursor_case_handled INTO
			@staff_id,
			@staff_name,
			@case_handled
	END

CLOSE cursor_case_handled
DEALLOCATE cursor_case_handled

-- 4
-- Order by date terus ambil case yang pertama terjadi tiap type
GO
DECLARE
	@case_id CHAR(5),
	@case_type_name VARCHAR(100),
	@case_start_date DATE

DECLARE cursor_first_case CURSOR
FOR SELECT 
		CaseID,
		CaseTypeName,
		CaseStartDate
	FROM 
		CaseHeader c
		JOIN CaseType ct
		ON c.CaseTypeID = ct.CaseTypeID
	WHERE 
		c.CaseID IN 
		(
			SELECT 
				(
					SELECT TOP 1
						CaseID
					FROM
						CaseHeader ch
						JOIN CaseType ct
						ON ch.CaseTypeID = ct.CaseTypeID
					WHERE 
						ct.CaseTypeID = c.CaseTypeID
					ORDER BY CaseStartDate
				) AS CaseTop
			FROM 
				CaseType c
		)

OPEN cursor_first_case
FETCH NEXT FROM cursor_first_case INTO
	@case_id,
	@case_type_name,
	@case_start_date
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Case ID %8s %-10s', ':', @case_id)
		PRINT '========================='
		PRINT FORMATMESSAGE('Case Type Name %2s %-10s', ':', @case_type_name)
		PRINT FORMATMESSAGE('Case Start Date %1s %-10s', ':', CAST(@case_start_date AS VARCHAR))
		PRINT ''
		FETCH NEXT FROM cursor_first_case INTO
			@case_id,
			@case_type_name,
			@case_start_date
	END

CLOSE cursor_first_case
DEALLOCATE cursor_first_case

-- 5
-- Create Trigger for soft delete staff
GO
CREATE TRIGGER CheviotSecurityTrigger
ON Evidence
INSTEAD OF Delete, Update
AS
PRINT 'System user '+SYSTEM_USER+' with login '+CURRENT_USER+ ' tried to perform the following detail'
DECLARE @EvidenceId CHAR(5), @CaseId CHAR(5), @EvidenceName VARCHAR(100), 	@EvidenceLongitude DECIMAL(9,6),@EvidenceLatitude DECIMAL(9,6)
IF(EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted))
BEGIN 
		PRINT 'Update'
		SELECT @EvidenceId=EvidenceId, 
		@CaseId=CaseId, 
		@EvidenceName=EvidenceName, 
		@EvidenceLongitude=EvidenceLongitude,
		@EvidenceLatitude =EvidenceLatitude 
		FROM deleted
		PRINT 'Old data'
		PRINT 'EvidenceId        : '+@EvidenceId
		PRINT 'CaseId            : '+@CaseId
		PRINT 'EvidenceName      : '+@EvidenceName
		PRINT 'EvidenceLongitude : '+CAST(@EvidenceLongitude AS VARCHAR)
		PRINT 'EvidenceLatitude  : '+CAST(@EvidenceLatitude AS VARCHAR)

		SELECT @EvidenceId=EvidenceId, 
		@CaseId=CaseId, 
		@EvidenceName=EvidenceName, 
		@EvidenceLongitude=EvidenceLongitude,
		@EvidenceLatitude =EvidenceLatitude 
		FROM inserted
		PRINT 'New data'
		PRINT 'EvidenceId        : '+@EvidenceId
		PRINT 'CaseId            : '+@CaseId
		PRINT 'EvidenceName      : '+@EvidenceName
		PRINT 'EvidenceLongitude : '+CAST(@EvidenceLongitude AS VARCHAR)
		PRINT 'EvidenceLatitude  : '+CAST(@EvidenceLatitude AS VARCHAR)

END 
ELSE 
BEGIN 
		PRINT 'Delete'
		SELECT @EvidenceId=EvidenceId, 
		@CaseId=CaseId, 
		@EvidenceName=EvidenceName, 
		@EvidenceLongitude=EvidenceLongitude,
		@EvidenceLatitude =EvidenceLatitude 
		FROM deleted
		PRINT 'Deleted data'
		PRINT 'EvidenceId        : '+@EvidenceId
		PRINT 'CaseId            : '+@CaseId
		PRINT 'EvidenceName      : '+@EvidenceName
		PRINT 'EvidenceLongitude : '+CAST(@EvidenceLongitude AS VARCHAR)
		PRINT 'EvidenceLatitude  : '+CAST(@EvidenceLatitude AS VARCHAR)

END

BEGIN TRAN
UPDATE Evidence 
SET EvidenceName = 'Evidence'
WHERE EvidenceID = 'EV050'
ROLLBACK

BEGIN TRAN
DELETE Evidence
WHERE EvidenceID = 'EV050'
ROLLBACK