-----------------------------------------------------------------
-- Filename: CW.spUpdateApprovals.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spUpdateApprovals]    Script Date: 6/8/2022 11:23:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER procedure [CW].[spUpdateApprovals]

as

------------------------------------------------- This procedure is used for approvals modified within the past week

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

--This table is used to store the data from the JSON file 
declare @JSONTable table (
	[ApprovalID] [int] NOT NULL,
	[Status] [varchar](32) NULL,
	[ApproverName] [varchar](128) NULL,
	[CustomerApproverName] [varchar](128) NULL,
	[ActualApproverName] [varchar](128) NULL,
	[ObjectApprovalType] [varchar](128) NULL,
	[ActualApprovedBy] [varchar](128) NULL,
	[Details] [varchar](2048) NULL,
	[ApproverComment] [varchar](2048) NULL,
	[ApproverEmail] [varchar](128) NULL,
	[CustomerApproverEmail] [varchar](128) NULL,
	[EmailApprover] [varchar](128) NULL,
	[ParentTypeName] [varchar](64) NULL,
	[ParentPublicID] [int] NULL,
	[WhenApprovedDenied] [datetime] NULL)

--Insert the date from the JSON file into the table variable
insert into @JSONTable
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

--Use a merge to update the stage table with the table variable, inserting new approvals and updating existing approvals
  MERGE [CW].[STAGE_APPROVALS] AS T
USING @JSONTable AS S
ON (T.ApprovalID = S.ApprovalID) 
WHEN NOT MATCHED BY TARGET 
    THEN INSERT([ApprovalID],[Status],[ApproverName],[CustomerApproverName],[ActualApproverName],[ObjectApprovalType],[ActualApprovedBy],[Details],[ApproverComment],[ApproverEmail],[CustomerApproverEmail],[EmailApprover],[ParentTypeName],[ParentPublicID],[WhenApprovedDenied]) 
    VALUES (s.[ApprovalID],s.[Status],s.[ApproverName],s.[CustomerApproverName],s.[ActualApproverName],s.[ObjectApprovalType],s.[ActualApprovedBy],s.[Details],s.[ApproverComment],s.[ApproverEmail],s.[CustomerApproverEmail],s.[EmailApprover],s.[ParentTypeName],s.[ParentPublicID],s.[WhenApprovedDenied])
WHEN MATCHED
    THEN UPDATE SET
t.[ApprovalID] = s.[ApprovalID],
t.[Status] = s.[Status],
t.[ApproverName] = s.[ApproverName],
t.[CustomerApproverName] = s.[CustomerApproverName],
t.[ActualApproverName] = s.[ActualApproverName],
t.[ObjectApprovalType] = s.[ObjectApprovalType],
t.[ActualApprovedBy] = s.[ActualApprovedBy],
t.[Details] = s.[Details],
t.[ApproverComment] = s.[ApproverComment],
t.[ApproverEmail] = s.[ApproverEmail],
t.[CustomerApproverEmail] = s.[CustomerApproverEmail],
t.[EmailApprover] = s.[EmailApprover],
t.[ParentTypeName] = s.[ParentTypeName],
t.[ParentPublicID] = s.[ParentPublicID],
t.[WhenApprovedDenied] = s.[WhenApprovedDenied];
GO


