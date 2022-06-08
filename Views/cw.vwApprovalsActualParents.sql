-----------------------------------------------------------------
-- Filename: cw.vwApprovalsActualParents.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  View [CW].[vwApprovalsActualParents]    Script Date: 6/8/2022 11:17:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE OR ALTER view [CW].[vwApprovalsActualParents] as
SELECT  [ApprovalID]
      ,[Status]
      ,[ApproverName]
      ,[CustomerApproverName]
      ,[ActualApproverName]
      ,[ObjectApprovalType]
      ,[ActualApprovedBy]
      ,[Details]
      ,[ApproverComment]
      ,case when [CustomerApproverEmail] = '' then [ApproverEmail] else [CustomerApproverEmail] end ActualApproverEmail
      ,[EmailApprover]
      ,[ParentTypeName]
      ,[ParentPublicID]
      ,[WhenApprovedDenied]
	  ,case when ParentPublicID is not null and Details = '' then 'Incident' else ParentTypeName end ActualParentType
	  ,case when  ParentTypeName = 'Change Request' and Details like 'change %' then substring(details,charindex(' ',Details),charindex(':',Details) - charindex(' ',Details))																																		--If change Id is not given but available in details extract it by using a substring for 1st space and first :
	  when ParentTypeName = 'Work Item' and Details like 'Work Item (Task) ID %' then trim(substring(replace(details,CHAR(13),''),charindex('-',replace(details,CHAR(13),'')) + 1,charindex(CHAR(10),replace(details,CHAR(13),''))  - (charindex('-',replace(details,CHAR(13),'')) + 1)))							--Similar thing for Work Item except we have to deal with new line characters, all instances have a line(char(10)) after the id so we use that for the substring but some of those also have a carriage return before that so we just remove it from details
	  when ParentPublicID is not null and Details = '' then ParentPublicID
	  else null end ActualParentID
  FROM [CW].[STAGE_APPROVALS]
GO


