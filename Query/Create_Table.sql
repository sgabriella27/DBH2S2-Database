CREATE DATABASE [Cheviot Police Station]
USE [Cheviot Police Station]

CREATE TABLE StaffPosition (
	StaffPositionID CHAR(5) PRIMARY KEY,
	StaffPositionName VARCHAR(50)
)

CREATE TABLE Staff (
	StaffID CHAR(5) PRIMARY KEY,
	StaffPositionID CHAR(5) FOREIGN KEY REFERENCES StaffPosition(StaffPositionID),
	StaffName VARCHAR(100),
	StaffPhoneNumber VARCHAR(50),
	StaffAddress VARCHAR(100),
	StaffGender VARCHAR(10)
)

CREATE TABLE CaseType (
	CaseTypeID CHAR(5) PRIMARY KEY,
	CaseTypeName VARCHAR(100)
)

CREATE TABLE CaseHeader (
	CaseID CHAR(5) PRIMARY KEY,
	CaseTypeID CHAR(5) FOREIGN KEY REFERENCES CaseType(CaseTypeID),
	CaseStartDate DATE,
	CaseEndDate DATE,
	CaseStatus VARCHAR(10),
	CrimeSceneLongitude DECIMAL(9,6),
	CrimeSceneLatitude DECIMAL(9,6)
)

CREATE TABLE CaseDetail (
	CaseID CHAR(5) FOREIGN KEY REFERENCES CaseHeader(CaseID),
	StaffID CHAR(5) FOREIGN KEY REFERENCES Staff(StaffID),
	PRIMARY KEY(CaseID, StaffID)
)

CREATE TABLE Suspect (
	SuspectID CHAR(5) PRIMARY KEY,
	CaseID CHAR(5) FOREIGN KEY REFERENCES CaseHeader(CaseID),
	SuspectName VARCHAR(100),
	SuspectAddress VARCHAR(100),
	SuspectPhoneNumber VARCHAR(50),
	SuspectGender VARCHAR(10),
	GuiltyStatus VARCHAR(10)
)

CREATE TABLE Trial (
	TrialID CHAR(5) PRIMARY KEY,
	CaseID CHAR(5) FOREIGN KEY REFERENCES CaseHeader(CaseID),
	StaffID CHAR(5) FOREIGN KEY REFERENCES Staff(StaffID),
	TrialDate DATE
)

CREATE TABLE Evidence (
	EvidenceID CHAR(5) PRIMARY KEY,
	CaseID CHAR(5) FOREIGN KEY REFERENCES CaseHeader(CaseID),
	EvidenceName VARCHAR(100),
	EvidenceLongitude DECIMAL(9,6),
	EvidenceLatitude DECIMAL(9,6)
)

CREATE TABLE Victim (
	VictimID CHAR(5) PRIMARY KEY,
	CaseID CHAR(5) FOREIGN KEY REFERENCES CaseHeader(CaseID),
	VictimName VARCHAR(100),
	VictimAddress VARCHAR(100),
	VictimGender VARCHAR(10)
)