-----------------------------------------------------------------
-- Filename: CW.spUpdateApprovalsFull.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateApprovalsFull]    Script Date: 6/8/2022 11:24:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER procedure [CW].[spUpdateApprovalsFull]

------------------------------------------------- This procedure is used for taking in all approvals from Cherwell

as

--This bulk insert is used to convert UTF-8 enocoded data to Unicode, without it there are many encoding issues. See https://docs.microsoft.com/en-us/answers/questions/557648/utf-8-character-not-getting-converted-to-unicode-w.html for more information.
CREATE TABLE #temp (ident  int IDENTITY,
                    txt    varchar(MAX) NOT NULL)
BULK INSERT #temp FROM 'C:\Dev\AutomateFlowFiles\Approvals.txt'
WITH (FORMATFILE ='C:\Dev\AutomateFlowFiles\Encoding.fmt', CODEPAGE=65001)
SELECT * FROM #temp

DECLARE @JSON VARCHAR(MAX)	--Stores all the JSON data from the converted file data
SELECT @json = string_agg(txt, '') WITHIN GROUP (ORDER BY ident)
FROM  #temp

DROP TABLE #temp

--Remove all approvals from the database and insert all the approvals from the JSON file
delete from [CW].[STAGE_APPROVALS]

insert into [CW].[STAGE_APPROVALS]
Select * FROM OPENJSON (@JSON) 
with([Approval ID] int,
  [Status] varchar(32),
  [Approver Name] varchar(128),
  [Customer Approver Name] varchar(128),
  [Actual Approver Name] varchar(128),
  [Object Approval Type] varchar(128),
  [Actual Approved By] varchar(128),
  [Details] varchar(2048),
  [Approver Comment] varchar(2048),
  [Approver Email] varchar(128),							--Approver's email for all IT approvals
  [Customer Approver Email] varchar(128),					--Approver's email for all other approvals
  [Email Approver] varchar(128),
  [Parent Type Name] varchar(64),
  [Parent PublicID] int,
  [When Approved Denied] datetime)
GO


