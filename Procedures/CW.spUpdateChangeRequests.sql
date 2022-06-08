-----------------------------------------------------------------
-- Filename: CW.spUpdateChangeRequests.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateChangeRequests]    Script Date: 6/8/2022 11:24:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [CW].[spUpdateChangeRequests]
AS
------------------------------------------------- This procedure is used for change requests modified within the past week
--This bulk insert is used to convert UTF-8 enocoded data to Unicode, without it there are many encoding issues. See https://docs.microsoft.com/en-us/answers/questions/557648/utf-8-character-not-getting-converted-to-unicode-w.html for more information.
CREATE TABLE #temp (
	ident INT IDENTITY
	,txt VARCHAR(MAX) NOT NULL
	)

BULK INSERT #temp
FROM 'C:\Dev\AutomateFlowFiles\Changes.txt' WITH (
		FORMATFILE = 'C:\Dev\AutomateFlowFiles\Encoding.fmt'
		,CODEPAGE = 65001
		)

SELECT *
FROM #temp

DECLARE @JSON VARCHAR(MAX) --Stores all the JSON data from the converted file data

SELECT @json = string_agg(txt, '') WITHIN
GROUP (
		ORDER BY ident
		)
FROM #temp

DROP TABLE #temp

--This table is used to store the data from the JSON file 
DECLARE @JSONTable TABLE (
	[ChangeType] [varchar](32) NULL
	,[OwnedByTeam] [varchar](64) NULL
	,[ChangeID] [int] NOT NULL
	,[RequestedBy] [varchar](128) NULL
	,[SAMAccountName] [varchar](128) NULL
	,[CreatedDateTime] [datetime] NULL
	,[Status] [varchar](32) NULL
	,[Description] [varchar](2048) NULL
	,[Category] [varchar](32) NULL
	,[CreatedBy] [varchar](128) NULL
	,[Division] [varchar](64) NULL
	,[Location] [varchar](64) NULL
	,[PrimaryCIDisplayName] [varchar](128) NULL
	,[PendingBusinessManagerAssessmentApproval] [bit] NULL
	,[PendingITOwnerAssessmentApproval] [bit] NULL
	,[PendingBusinessManagerDeployApproval] [bit] NULL
	,[PendingITOwnerDeployApproval] [bit] NULL
	,[LastModifiedDateTime] [datetime] NULL
	,[ChangeOwner] [varchar](128) NULL
	,[Title] [varchar](128) NULL
	,[PassedTestingDateTime] [datetime] NULL
	,[PassedTestingCertificationUser] [varchar](128) NULL
	,[StandardTemplateName] [varchar](128) NULL
	,[OwnedByEmail] VARCHAR(128)
	,[RequestedByEmail] VARCHAR(128)
	,[Priority] INT
	,[ScheduledEndDate] DATETIME
	)

--Insert the date from the JSON file into the table variable
INSERT INTO @JSONTable
SELECT [Change Type]
	,[Owned By Team]
	,[Change ID]
	,[Requested By]
	,[SAMAccountName]
	,[Created Date Time]
	,[Status]
	,[Description]
	,[Category]
	,[Created By]
	,[Division]
	,[Location]
	,[Primary CI display name]
	,[Pending Business Manager Assessment Approval]
	,[Pending IT Owner Assessment Approval]
	,[Pending Business Manager Deploy Approval]
	,[Pending IT Owner Deploy Approval]
	,[Last Modified Date Time]
	,[Change Owner]
	,Title
	,[Passed Testing Date Time]
	,[Passed Testing Certification User]
	,[Standard Template Name]
	,[Owned By Email]
	,[Email]
	,cast(replace(priority, 'p', '') AS INT) Priority
	,[Scheduled End Date]
FROM OPENJSON(@JSON) WITH (
		[Change Type] VARCHAR(32)
		,[Owned By Team] VARCHAR(64)
		,[Change ID] INT
		,[Requested By] VARCHAR(128)
		,[SAMAccountName] VARCHAR(128)
		,[Created Date Time] DATETIME
		,[Status] VARCHAR(32)
		,[Description] VARCHAR(2048)
		,[Category] VARCHAR(32)
		,[Created By] VARCHAR(128)
		,[Division] VARCHAR(64)
		,[Location] VARCHAR(64)
		,[Primary CI display name] VARCHAR(128)
		,[Pending Business Manager Assessment Approval] BIT
		,[Pending IT Owner Assessment Approval] BIT
		,[Pending Business Manager Deploy Approval] BIT
		,[Pending IT Owner Deploy Approval] BIT
		,[Last Modified Date Time] DATETIME
		,[Change Owner] VARCHAR(128)
		,Title VARCHAR(128)
		,[Passed Testing Date Time] DATETIME
		,[Passed Testing Certification User] VARCHAR(128)
		,[Standard Template Name] VARCHAR(128)
		,[Owned By Email] VARCHAR(128)
		,[Email] VARCHAR(128)
		,[Priority] VARCHAR(8)
		,[Scheduled End Date] DATETIME
		)

--Use a merge to update the stage table with the table variable, inserting new change requests and updating existing change requests
MERGE [CW].[STAGE_CHANGE_REQUESTS] AS T
USING @JSONTable AS S
	ON (T.ChangeID = S.ChangeID)
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[ChangeType]
			,[OwnedByTeam]
			,[ChangeID]
			,[RequestedBy]
			,[SAMAccountName]
			,[CreatedDateTime]
			,[Status]
			,[Description]
			,[Category]
			,[CreatedBy]
			,[Division]
			,[Location]
			,[PrimaryCIDisplayName]
			,[PendingBusinessManagerAssessmentApproval]
			,[PendingITOwnerAssessmentApproval]
			,[PendingBusinessManagerDeployApproval]
			,[PendingITOwnerDeployApproval]
			,[LastModifiedDateTime]
			,[ChangeOwner]
			,[Title]
			,[PassedTestingDateTime]
			,[PassedTestingCertificationUser]
			,[StandardTemplateName]
			,OwnedByEmail
			,RequestedByEmail
			,Priority
			,ScheduledEndDate
			)
		VALUES (
			s.[ChangeType]
			,s.[OwnedByTeam]
			,s.[ChangeID]
			,s.[RequestedBy]
			,s.[SAMAccountName]
			,s.[CreatedDateTime]
			,s.[Status]
			,s.[Description]
			,s.[Category]
			,s.[CreatedBy]
			,s.[Division]
			,s.[Location]
			,s.[PrimaryCIDisplayName]
			,s.[PendingBusinessManagerAssessmentApproval]
			,s.[PendingITOwnerAssessmentApproval]
			,s.[PendingBusinessManagerDeployApproval]
			,s.[PendingITOwnerDeployApproval]
			,s.[LastModifiedDateTime]
			,s.[ChangeOwner]
			,s.[Title]
			,s.[PassedTestingDateTime]
			,s.[PassedTestingCertificationUser]
			,s.[StandardTemplateName]
			,s.OwnedByEmail
			,s.RequestedByEmail
			,s.Priority
			,s.ScheduledEndDate
			)
WHEN MATCHED
	THEN
		UPDATE
		SET t.[ChangeType] = s.[ChangeType]
			,t.[OwnedByTeam] = s.[OwnedByTeam]
			,t.[ChangeID] = s.[ChangeID]
			,t.[RequestedBy] = s.[RequestedBy]
			,t.[SAMAccountName] = s.[SAMAccountName]
			,t.[CreatedDateTime] = s.[CreatedDateTime]
			,t.[Status] = s.[Status]
			,t.[Description] = s.[Description]
			,t.[Category] = s.[Category]
			,t.[CreatedBy] = s.[CreatedBy]
			,t.[Division] = s.[Division]
			,t.[Location] = s.[Location]
			,t.[PrimaryCIDisplayName] = s.[PrimaryCIDisplayName]
			,t.[PendingBusinessManagerAssessmentApproval] = s.[PendingBusinessManagerAssessmentApproval]
			,t.[PendingITOwnerAssessmentApproval] = s.[PendingITOwnerAssessmentApproval]
			,t.[PendingBusinessManagerDeployApproval] = s.[PendingBusinessManagerDeployApproval]
			,t.[PendingITOwnerDeployApproval] = s.[PendingITOwnerDeployApproval]
			,t.[LastModifiedDateTime] = s.[LastModifiedDateTime]
			,t.[ChangeOwner] = s.[ChangeOwner]
			,t.[Title] = s.[Title]
			,t.[PassedTestingDateTime] = s.[PassedTestingDateTime]
			,t.[PassedTestingCertificationUser] = s.[PassedTestingCertificationUser]
			,t.[StandardTemplateName] = s.[StandardTemplateName]
			,t.OwnedByEmail = s.OwnedBYEmail
			,t.RequestedByEmail = s.RequestedByEmail
			,t.Priority = s.Priority
			,t.ScheduledEndDate = s.ScheduledEndDate;
GO


