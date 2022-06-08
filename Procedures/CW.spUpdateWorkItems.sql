-----------------------------------------------------------------
-- Filename: CW.spUpdateWorkItems.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateWorkItems]    Script Date: 6/8/2022 11:27:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER procedure [CW].[spUpdateWorkItems]

as

------------------------------------------------- This procedure is used for work items modified within the past week

--This bulk insert is used to convert UTF-8 enocoded data to Unicode, without it there are many encoding issues. See https://docs.microsoft.com/en-us/answers/questions/557648/utf-8-character-not-getting-converted-to-unicode-w.html for more information.
CREATE TABLE #temp (ident  int IDENTITY,
                    txt    varchar(MAX) NOT NULL)
BULK INSERT #temp FROM 'C:\Dev\AutomateFlowFiles\WorkItems.txt'
WITH (FORMATFILE ='C:\Dev\AutomateFlowFiles\Encoding.fmt', CODEPAGE=65001)
SELECT * FROM #temp

DECLARE @JSON VARCHAR(MAX)	--Stores all the JSON data from the converted file data
SELECT @json = string_agg(txt, '') WITHIN GROUP (ORDER BY ident)
FROM  #temp

DROP TABLE #temp

--This table is used to store the data from the JSON file 
declare @JSONTable table(
	[TaskID] [int] NOT NULL,
	[Title] [varchar](1024) NOT NULL,
	[OwnedBy] [varchar](128) NOT NULL,
	[Description] [varchar](1024) NOT NULL,
	[OwnedByTeam] [varchar](128) NOT NULL,
	[ParentPublicID] [int] NOT NULL,
	[ParentTypeName] [varchar](32) NOT NULL,
	[ConfigItemDisplayName] [varchar](128) NOT NULL,
	[ClosedBy] [varchar](128) NULL,
	[ClosedDateTime] [datetime] NULL,
	[Status] [varchar](32) NULL,
	[CreatedBy] [varchar](128) NULL,
	[Type] [varchar](64) NULL,
	[IncidentSubcategory] [varchar](128) NULL,
	[IncidentCategory] [varchar](128) NULL,
	[LastModifiedDateTime] [datetime] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL)

--Insert the date from the JSON file into the table variable
insert into @JSONTable
Select * FROM OPENJSON (@JSON) 
with([Task ID] int,
Title varchar(1024),
[Owned By] varchar(128),
Description varchar(1024),
[Owned By Team] varchar(128),
[Parent PublicID] int,
[Parent Type Name] varchar(32),
[Config Item Display Name] varchar(128),
[Closed By] varchar(128),
[Closed Date Time] datetime,
[Status] varchar(32),
[Created By] varchar(128),
[Type] varchar(64),
[Incident Subcategory] varchar(128),
[Incident Category] varchar(128),
[Last Modified Date Time] datetime,
[Created Date Time] datetime)


--Use a merge to update the stage table with the table variable, inserting new work items and updating existing work items
MERGE [CW].[STAGE_WORK_ITEMS] AS T
USING @JSONTable AS S
ON (T.TaskID = S.TaskID) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT([TaskID],[Title],[OwnedBy],[Description],[OwnedByTeam],[ParentPublicID],[ParentTypeName],[ConfigItemDisplayName],[ClosedBy],[ClosedDateTime],[Status],[CreatedBy],[Type],[IncidentSubcategory],[IncidentCategory],[LastModifiedDateTime],[CreatedDateTime]) 
    VALUES (s.[TaskID],s.[Title],s.[OwnedBy],s.[Description],s.[OwnedByTeam],s.[ParentPublicID],s.[ParentTypeName],s.[ConfigItemDisplayName],s.[ClosedBy],s.[ClosedDateTime],s.[Status],s.[CreatedBy],s.[Type],s.[IncidentSubcategory],s.[IncidentCategory],s.[LastModifiedDateTime],s.[CreatedDateTime])
WHEN MATCHED
    THEN UPDATE SET
t.[TaskID] = s.[TaskID],
t.[Title] = s.[Title],
t.[OwnedBy] = s.[OwnedBy],
t.[Description] = s.[Description],
t.[OwnedByTeam] = s.[OwnedByTeam],
t.[ParentPublicID] = s.[ParentPublicID],
t.[ParentTypeName] = s.[ParentTypeName],
t.[ConfigItemDisplayName] = s.[ConfigItemDisplayName],
t.[ClosedBy] = s.[ClosedBy],
t.[ClosedDateTime] = s.[ClosedDateTime],
t.[Status] = s.[Status],
t.[CreatedBy] = s.[CreatedBy],
t.[Type] = s.[Type],
t.[IncidentSubcategory] = s.[IncidentSubcategory],
t.[IncidentCategory] = s.[IncidentCategory],
t.[LastModifiedDateTime] = s.[LastModifiedDateTime],
t.[CreatedDateTime] = s.[CreatedDateTime];


----------------------------Update last data refresh with current time

update CW.LastDataRefresh
set RefreshTime = getdate()
GO


