-----------------------------------------------------------------
-- Filename: cw.vwOPEN_TICKETS_EMAIL.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  View [CW].[vwOPEN_TICKETS_EMAIL]    Script Date: 6/8/2022 11:20:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE OR ALTER view [CW].[vwOPEN_TICKETS_EMAIL] as
--Get user incident owner information
SELECT [ID] Ticket
      ,[OwnedBy] [UserName]
      ,cast(Description as varchar(300)) [Description]
      ,[OwnedByEmail] Email
	  ,'Assigned Incidents' EmailCategory
	  ,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(ID as varchar(16)) as Link
	  ,CustomerName
	  ,[OwnedBy]
	  ,[OwnedByEmail]
  FROM [CW].[STAGE_INCIDENTS]
  WHERE STATUS IN ('Assigned','Reopened','In Progress','New')  and OwnedByEmail is not null

  union
  --Get user incident creator information
  SELECT [ID]
      ,CreatedBy
      ,cast(Description as varchar(300)) [Description]
      ,CreatedByEmail
	  ,'Created Incidents'
	  ,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(ID as varchar(16)) as Link
	  ,CustomerName
	  ,[OwnedBy]
	  ,[OwnedByEmail]
  FROM [CW].[STAGE_INCIDENTS]
  WHERE STATUS IN ('Assigned','Reopened','In Progress','New')  and isnull(CreatedByEmail,'') <> ''

  union
--Get user change requestor information
  SELECT ChangeID
	  ,RequestedBy
	  ,cast(Description AS VARCHAR(300)) [Description]
	  ,RequestedByEmail
	  ,'Requested Changes'
	  ,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/changerequest/' + cast(ChangeID AS VARCHAR(16))
	  ,RequestedBy
	  ,ChangeOwner
	  ,OwnedByEmail
  FROM [CW].[STAGE_CHANGE_REQUESTS]
  WHERE STATUS not in ('Closed','','Review','Deploy') and ISNULL(RequestedByEmail,'') <> ''

  union
--Get user change owner information
  SELECT ChangeID
	  ,ChangeOwner
	  ,cast(Description AS VARCHAR(300)) [Description]
	  ,OwnedByEmail
	  ,'Assigned Changes'
	  ,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/changerequest/' + cast(ChangeID AS VARCHAR(16))
	  ,RequestedBy
	  ,ChangeOwner
	  ,OwnedByEmail
  FROM [CW].[STAGE_CHANGE_REQUESTS]
  WHERE STATUS not in ('Closed','','Review','Deploy') and ISNULL(OwnedByEmail,'') <> ''
GO


