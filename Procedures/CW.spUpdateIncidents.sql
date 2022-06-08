-----------------------------------------------------------------
-- Filename: CW.spUpdateIncidents.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateIncidents]    Script Date: 6/8/2022 11:26:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER procedure [CW].[spUpdateIncidents]

as

------------------------------------------------- This procedure is used for incidents modified within the past week

--This bulk insert is used to convert UTF-8 enocoded data to Unicode, without it there are many encoding issues. See https://docs.microsoft.com/en-us/answers/questions/557648/utf-8-character-not-getting-converted-to-unicode-w.html for more information.
CREATE TABLE #temp (ident  int IDENTITY,
                    txt    varchar(MAX) NOT NULL)
BULK INSERT #temp FROM 'C:\Dev\AutomateFlowFiles\Incidents.txt'
WITH (FORMATFILE ='C:\Dev\AutomateFlowFiles\Encoding.fmt', CODEPAGE=65001)
SELECT * FROM #temp


DECLARE @JSON VARCHAR(MAX)	--Stores all the JSON data from the converted file data
SELECT @json = string_agg(txt, '') WITHIN GROUP (ORDER BY ident)
FROM  #temp

  DROP TABLE #temp

--This table is used to store the data from the JSON file 
declare @JSONTable table (
	[Type] [varchar](64) NULL,
	[OwnedByTeam] [varchar](64) NULL,
	[OwnedBy] [varchar](64) NULL,
	[ID] [int] NOT NULL,
	[CustomerName] [varchar](128) NULL,
	[FriendlyName] [varchar](128) NULL,
	[CreatedDateTime] [datetime] NULL,
	[Status] [varchar](32) NULL,
	[Description] [varchar](2048) NULL,
	[Location] [varchar](64) NULL,
	[SLAResolveByDeadline] [datetime] NULL,
	[ConfigurationItem] [varchar](128) NULL,
	[Non-ValidatedResponse] [varchar](2048) NULL,
	[CallSource] [varchar](128) NULL,
	[Cause] [varchar](128) NULL,
	[CloseDescription] [varchar](2048) NULL,
	[ClosedBy] [varchar](64) NULL,
	[ClosedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](64) NULL,
	[LastModifiedDateTime] [datetime] NULL,
	[RequesterDepartment] [varchar](128) NULL,
	[Withdraw] [bit] NULL,
	[Category] [varchar](128) NULL,
	[Subcategory] [varchar](128) NULL,
	[OrderID] [int] NULL,
	[SmartClassifySearchString] [varchar](128) NULL,
	[Service] [varchar](128) NULL,
	[StatDateTimeResolved] [datetime] NULL,
	[Division] [varchar](64) NULL,
	[Priority] [int] NULL,
    [OwnedByEmail] varchar(128),
    [CreatedByEmail] varchar(128))

--Insert the date from the JSON file into the table variable
insert into @JSONTable
Select * FROM OPENJSON (@JSON) 
with([Type] varchar(64),
  [Owned By Team] varchar(64),
  [Owned By] varchar(64),
  [ID] int,
  [Customer Name] varchar(128),
  [Friendly Name] varchar(128),
  [Created Date Time] datetime,
  [Status] varchar(32),
  [Description] varchar(2048),
  [Location] varchar(64),
  [SLA Resolve By Deadline] datetime,
  [Configuration Item] varchar(128),
  [Non-Validated Response] varchar(2048),
  [Call Source] varchar(128),
  [Cause] varchar(128),
  [Close Description] varchar(2048),
  [Closed By] varchar(64),
  [Closed Date Time] datetime,
  [Created By] varchar(64),
  [Last Modified Date Time] datetime,
  [Requester Department] varchar(128),
  [Withdraw] bit,
  [Category] varchar(128),
  [Subcategory] varchar(128),
  [Order ID] int,
  [Smart Classify Search String] varchar(128),
  [Service] varchar(128),
  [stat_Date Time Resolved] datetime,
  [Division] varchar(64),
  [Priority] int,
  [Email] varchar(128),
  [Created By Email] varchar(128))

--Use a merge to update the stage table with the table variable, inserting new incidents and updating existing incidents
MERGE [CW].[STAGE_INCIDENTS] AS T
USING @JSONTable AS S
ON (T.id = S.id) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT([Type],[OwnedByTeam],[OwnedBy],[ID],[CustomerName],[FriendlyName],[CreatedDateTime],[Status],[Description],[Location],[SLAResolveByDeadline],[ConfigurationItem],[Non-ValidatedResponse],[CallSource],[Cause],[CloseDescription],[ClosedBy],[ClosedDateTime],[CreatedBy],[LastModifiedDateTime],[RequesterDepartment],[Withdraw],[Category],[Subcategory],[OrderID],[SmartClassifySearchString],[Service],[StatDateTimeResolved],[Division],[Priority],[OwnedByEmail],[CreatedByEmail]) 
    VALUES (s.[Type],s.[OwnedByTeam],s.[OwnedBy],s.[ID],s.[CustomerName],s.[FriendlyName],s.[CreatedDateTime],s.[Status],s.[Description],s.[Location],s.[SLAResolveByDeadline],s.[ConfigurationItem],s.[Non-ValidatedResponse],s.[CallSource],s.[Cause],s.[CloseDescription],s.[ClosedBy],s.[ClosedDateTime],s.[CreatedBy],s.[LastModifiedDateTime],s.[RequesterDepartment],s.[Withdraw],s.[Category],s.[Subcategory],s.[OrderID],s.[SmartClassifySearchString],s.[Service],s.[StatDateTimeResolved],s.[Division],s.[Priority],s.[OwnedByEmail],s.[CreatedByEmail])
WHEN MATCHED
    THEN UPDATE SET
t.[Type] = s.[Type],
t.[OwnedByTeam] = s.[OwnedByTeam],
t.[OwnedBy] = s.[OwnedBy],
t.[ID] = s.[ID],
t.[CustomerName] = s.[CustomerName],
t.[FriendlyName] = s.[FriendlyName],
t.[CreatedDateTime] = s.[CreatedDateTime],
t.[Status] = s.[Status],
t.[Description] = s.[Description],
t.[Location] = s.[Location],
t.[SLAResolveByDeadline] = s.[SLAResolveByDeadline],
t.[ConfigurationItem] = s.[ConfigurationItem],
t.[Non-ValidatedResponse] = s.[Non-ValidatedResponse],
t.[CallSource] = s.[CallSource],
t.[Cause] = s.[Cause],
t.[CloseDescription] = s.[CloseDescription],
t.[ClosedBy] = s.[ClosedBy],
t.[ClosedDateTime] = s.[ClosedDateTime],
t.[CreatedBy] = s.[CreatedBy],
t.[LastModifiedDateTime] = s.[LastModifiedDateTime],
t.[RequesterDepartment] = s.[RequesterDepartment],
t.[Withdraw] = s.[Withdraw],
t.[Category] = s.[Category],
t.[Subcategory] = s.[Subcategory],
t.[OrderID] = s.[OrderID],
t.[SmartClassifySearchString] = s.[SmartClassifySearchString],
t.[Service] = s.[Service],
t.[StatDateTimeResolved] = s.[StatDateTimeResolved],
t.[Division] = s.[Division],
t.[Priority] = s.[Priority],
t.OwnedByEmail = s.OwnedByEmail,
t.CreatedByEmail = s.CreatedByEmail;
GO


