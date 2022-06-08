-----------------------------------------------------------------
-- Filename: CW.spUpdateWorkItemsFull.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateWorkItemsFull]    Script Date: 6/8/2022 11:27:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER   procedure [CW].[spUpdateWorkItemsFull]

as

------------------------------------------------- This procedure is used for taking in all work items from Cherwell

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

--Remove all approvals from the database and insert all the approvals from the JSON file
delete from [CW].[STAGE_WORK_ITEMS]

insert into [CW].[STAGE_WORK_ITEMS]
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



update CW.LastDataRefresh
set RefreshTime = getdate()

GO


