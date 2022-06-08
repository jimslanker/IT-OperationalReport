-----------------------------------------------------------------
-- Filename: CW.spUpdateIncidentsFull.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateIncidentsFull]    Script Date: 6/8/2022 11:26:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER procedure [CW].[spUpdateIncidentsFull]

as

------------------------------------------------- This procedure is used for taking in all incidents from Cherwell

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

--Remove all incidents from the database and insert all the incidents from the JSON file
delete from [CW].[STAGE_INCIDENTS]

insert into [CW].[STAGE_INCIDENTS]
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

GO


