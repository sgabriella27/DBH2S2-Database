USE [Cheviot Police Station]

-- EASY (8)

-- 1
-- Create cursor name 'cursor_suspect_view' that will print all of the suspect name that is guilty (declare cursor)
DECLARE
	@suspect_name	VARCHAR(100),
	@guilty_status	VARCHAR(50)

DECLARE cursor_suspect_view CURSOR
FOR SELECT
		SuspectName,
		GuiltyStatus
	FROM
		Suspect
	WHERE
		GuiltyStatus = 'Guilty'

OPEN cursor_suspect_view
FETCH NEXT FROM cursor_suspect_view INTO
	@suspect_name,
	@guilty_status

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Victim Name : ' + @suspect_name + ' ; Guilty Status : ' + @guilty_status
		PRINT '==========================================================='
		FETCH NEXT FROM cursor_suspect_view INTO
			@suspect_name,
			@guilty_status
	END

CLOSE cursor_suspect_view
DEALLOCATE cursor_suspect_view

-- 2
-- Create trigger named 'trigger_deleted_evidence' on Victim table that will show the evidence id and evidence name of the deleted evidence
GO
CREATE TRIGGER trigger_deleted_evidence
ON Evidence
FOR DELETE
AS
DECLARE @evidence_id_deleted VARCHAR(100)
DECLARE @evidence_name_deleted VARCHAR(100)
	SELECT
		@evidence_id_deleted = EvidenceID,
		@evidence_name_deleted = EvidenceName
	FROM deleted

	PRINT 'Deleted Evidence'
	PRINT '================'
	PRINT 'Evidence ID : ' + @evidence_id_deleted
	PRINT 'Evidence Name : ' + @evidence_name_deleted

BEGIN TRAN
DELETE FROM Evidence
WHERE EvidenceID = 'EV027'
ROLLBACK

-- 3
-- Create trigger named 'trigger_new_trial' on Trial table that will show the TrialID and the TrialProcessDate (obtained by adding 7 days after the Trial Date) for every new inserted trial
GO
CREATE TRIGGER trigger_new_trial
ON Trial
FOR INSERT
AS
DECLARE @trial_id_inserted CHAR(5)
DECLARE @trial_process_date DATE
	SELECT
		@trial_id_inserted = TrialID,
		@trial_process_date = DATEADD(DAY, 7, TrialDate)
	FROM inserted

	PRINT 'New Trial'
	PRINT '========='
	PRINT 'Trial ID: ' + @trial_id_inserted
	PRINT 'Trial Process Date: ' + CAST(@trial_process_date AS VARCHAR)

BEGIN TRAN
INSERT INTO Trial
VALUES ('TR101', 'CA020', 'ST027', GETDATE())
ROLLBACK

-- 4
-- Create cursor named 'cursor_case_view' that will print all of the content in case header table
GO
DECLARE
	@case_id CHAR(5),
	@case_type_id CHAR(5),
	@case_start_date DATE,
	@case_end_date DATE,
	@case_status VARCHAR(10),
	@crime_scene_longitude DECIMAL(9, 6),
	@crime_scene_latitude DECIMAL(9, 6)

DECLARE cursor_case_view CURSOR
FOR SELECT
		CaseID,
		CaseTypeID,
		CaseStartDate,
		CaseEndDate,
		CaseStatus,
		CrimeSceneLongitude,
		CrimeSceneLatitude
	FROM
		CaseHeader

OPEN cursor_case_view
FETCH NEXT FROM cursor_case_view INTO
	@case_id,
	@case_type_id,
	@case_start_date,
	@case_end_date,
	@case_status,
	@crime_scene_longitude,
	@crime_scene_latitude

PRINT 'Case'
PRINT '===='
PRINT ''
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Case ID %15s %-10s', ':', @case_id)
		PRINT FORMATMESSAGE('Case Type ID %10s %-10s', ':', @case_type_id)
		PRINT FORMATMESSAGE('Case Start Date %7s %-10s', ':', CAST(@case_start_date AS VARCHAR))
		IF @case_end_date IS NULL
			PRINT FORMATMESSAGE('Case End Date %9s %-10s', ':', '-')
		ELSE
			PRINT FORMATMESSAGE('Case End Date %9s %-10s', ':', CAST(@case_end_date AS VARCHAR))
		PRINT FORMATMESSAGE('Case Status %11s %-10s', ':', @case_status)
		PRINT FORMATMESSAGE('Crime Scene Longitude %1s %-10s', ':', CAST(@crime_scene_longitude AS VARCHAR))
		PRINT FORMATMESSAGE('Crime Scene Latitude %2s %-10s', ':', CAST(@crime_scene_latitude AS VARCHAR))
		PRINT '========================================================'
		FETCH NEXT FROM cursor_case_view INTO
			@case_id,
			@case_type_id,
			@case_start_date,
			@case_end_date,
			@case_status,
			@crime_scene_longitude,
			@crime_scene_latitude
	END

CLOSE cursor_case_view
DEALLOCATE cursor_case_view

-- 5
-- Create cursor name 'cursor_victim_suspect_count' that will print CaseID, VictimCount (obtained from how many victim in each case) and SuspectCount (obtained from how many suspect in each case) 
GO
DECLARE
	@case_id CHAR(5),
	@victim_count INT,
	@suspect_count INT

DECLARE cursor_victim_suspect_count CURSOR
FOR
	SELECT
		ch.CaseID,
		VictimCount = COUNT(VictimID),
		SuspectCount = COUNT(SuspectID)
	FROM
		CaseHeader ch
		JOIN Victim v
		ON ch.CaseID = v.CaseID
		JOIN Suspect s
		ON ch.CaseID = s.CaseID
	GROUP BY ch.CaseID

OPEN cursor_victim_suspect_count
FETCH NEXT FROM cursor_victim_suspect_count INTO
	@case_id,
	@victim_count,
	@suspect_count

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT FORMATMESSAGE('Case ID %3s %-10s', ':', @case_id)
		PRINT FORMATMESSAGE('Victim %4s %-10s', ':', CAST(@victim_count AS VARCHAR) + ' people')
		PRINT FORMATMESSAGE('Suspect %3s %-10s', ':', CAST(@suspect_count AS VARCHAR) + ' people')
		PRINT '========================='
		FETCH NEXT FROM cursor_victim_suspect_count INTO
			@case_id,
			@victim_count,
			@suspect_count
	END

CLOSE cursor_victim_suspect_count
DEALLOCATE cursor_victim_suspect_count

-- 6
-- Create cursor named 'cursor_case_type' that will print all of CaseTypeID and CaseTypeName from CaseType table
GO
DECLARE
	@case_type_id CHAR(5),
	@case_type_name VARCHAR(50)

DECLARE cursor_case_type CURSOR
FOR SELECT
		CaseTypeID,
		CaseTypeName
	FROM
		CaseType

OPEN cursor_case_type
FETCH NEXT FROM cursor_case_type INTO
	@case_type_id,
	@case_type_name

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Case Type ID : ' + @case_type_id
		PRINT 'Case Type Name : ' + @case_type_name
		PRINT '==============================='
		FETCH NEXT FROM cursor_case_type INTO
			@case_type_id,
			@case_type_name
	END

CLOSE cursor_case_type
DEALLOCATE cursor_case_type

-- 7
-- Create trigger named 'trigger_delete_victim' that will print success message when one data from victim table deleted
GO
CREATE TRIGGER trigger_delete_victim
ON Victim
FOR DELETE
AS
	PRINT 'Victim successfully deleted!'

BEGIN TRAN
DELETE FROM Victim
WHERE VictimID = 'VI070'
ROLLBACK
DROP TRIGGER trigger_delete_victim

-- 8
-- Drop all trigger you have made (bar bar drop satu" gapapa)
GO
DECLARE
	@trigger_name VARCHAR(100)

DECLARE cursor_delete_trigger CURSOR
FOR SELECT
	name
FROM
	sys.triggers

OPEN cursor_delete_trigger
FETCH NEXT FROM cursor_delete_trigger INTO
	@trigger_name

WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC('DROP TRIGGER ' + @trigger_name + ' ON DATABASE')
		FETCH NEXT FROM cursor_delete_trigger INTO
			@trigger_name
	END

CLOSE cursor_delete_trigger
DEALLOCATE cursor_delete_trigger