-----------------------------------------------------------------
-- Filename: CW.spUpdateChangeRequestFull.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateChangeRequestsFull]    Script Date: 6/8/2022 11:25:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER procedure [CW].[spUpdateChangeRequestsFull]
as

------------------------------------------------- This procedure is used for taking in all Change Requests from Cherwell

--This bulk insert is used to convert UTF-8 enocoded data to Unicode, without it there are many encoding issues. See https://docs.microsoft.com/en-us/answers/questions/557648/utf-8-character-not-getting-converted-to-unicode-w.html for more information.
CREATE TABLE #temp (ident  int IDENTITY,
                    txt    varchar(MAX) NOT NULL)
BULK INSERT #temp FROM 'C:\Dev\AutomateFlowFiles\Changes.txt'
WITH (FORMATFILE ='C:\Dev\AutomateFlowFiles\Encoding.fmt', CODEPAGE=65001)
SELECT * FROM #temp

DECLARE @JSON VARCHAR(MAX)	--Stores all the JSON data from the converted file data
SELECT @json = string_agg(txt, '') WITHIN GROUP (ORDER BY ident)
FROM  #temp

--Remove all approvals from the database and insert all the approvals from the JSON file
delete from [CW].[STAGE_CHANGE_REQUESTS]

insert into [CW].[STAGE_CHANGE_REQUESTS]
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
		,[Scheduled End Date] datetime
		)
GO


