-----------------------------------------------------------------
-- Filename: cw.vwItOperationReport.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  View [CW].[vwItOperationReport]    Script Date: 6/8/2022 11:18:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [CW].[vwItOperationReport] as
SELECT inc.[Type]
      ,inc.[OwnedByTeam]
      ,inc.[OwnedBy]
      ,inc.[ID]
      ,inc.[CustomerName]
      ,inc.[FriendlyName]
      ,inc.[CreatedDateTime]
	  ,cast(inc.[CreatedDateTime] as date) [CreatedDate]
      ,inc.[Status]
      ,inc.[Description]
      ,inc.[Location]
      ,inc.[SLAResolveByDeadline]
      ,inc.[ConfigurationItem]
      ,inc.[Non-ValidatedResponse]
      ,inc.[CallSource]
      ,inc.[Cause]
      ,inc.[CloseDescription]
      ,inc.[ClosedBy]
      ,inc.[ClosedDateTime]
      ,inc.[CreatedBy]
      ,inc.[LastModifiedDateTime]
      ,inc.[RequesterDepartment]
      ,inc.[Withdraw]
      ,inc.[Category]
      ,inc.[Subcategory]
      ,inc.[OrderID]
      ,inc.[SmartClassifySearchString]
      ,inc.[Service]
      ,case when inc.Status <> 'Reopened' then  inc.[StatDateTimeResolved] else null end [StatDateTimeResolved]
	  ,case when inc.Status <> 'Reopened' then  cast(inc.[StatDateTimeResolved] as date) else null end [StatDateResolved]
      ,inc.[Division]
      ,inc.[Priority]
	  ,case inc.[OwnedByTeam]
when 'METL-Quality IS' then 'APPS'
when 'TIME-Apps-TIMET' then 'APPS'
when 'METL-Apps-SAP' then 'APPS'
when 'METL-BI (Web/SP/BI)' then 'APPS'
when 'SMC-Apps-NHD' then 'APPS'
when 'METL-Apps-SAP-Master Data' then 'APPS'
when 'SMC-Apps-SMW' then 'APPS'
when 'METL-BASIS/DBA/SAP_SEC' then 'APPS'
when 'WGFC-DVTX-Oracle' then 'APPS'
when 'METL-Apps-SAP-HR / HCM' then 'APPS'
when 'WGFC-DVTX-Database Team' then 'APPS'
when 'WGFC-EGY-Oracle' then 'APPS'
when 'SMC-EPM' then 'APPS'
when 'SMC-Apps-Revert' then 'APPS'
when 'SMC-Apps-HBEN' then 'APPS'
when 'METL-SAP-MII' then 'APPS'
when 'METL-SAP-Security' then 'APPS'
when 'METL-SAP-Vendor Master US' then 'APPS'
when 'SMC-Apps-Schulz' then 'APPS'
when 'TIME-Apps-STAR' then 'APPS'
when 'METL-Security/Compliance' then 'Compliance'
when 'Enterprise ITSM' then 'Corporate'
when 'Enterprise Network' then 'Corporate'
when 'Enterprise Admins' then 'Corporate'
when 'Enterprise Security' then 'Corporate'
when 'Enterprise eDiscovery' then 'Corporate'
when 'Enterprise SyteLine Cloud MDM' then 'Corporate'
when 'Enterprise SCCM' then 'Corporate'
when 'Enterprise SyteLine Cloud MDM' then 'Corporate'
when 'CORP-Service Desk' then 'Corporate'
when 'CORP-EPM Application ARC' then 'Corporate'
when 'CORP-Portal' then 'Corporate'
when 'CORP-Archer' then 'Corporate'
when 'CORP-Bitlocker' then 'Corporate'
when 'CORP-Bluecoat/SSLV' then 'Corporate'
when 'CORP-Corp-Data Team' then 'Corporate'
when 'CORP-EPM' then 'Corporate'
when 'CORP-Fixed Asset Report' then 'Corporate'
when 'CORP-FP&A' then 'Corporate'
when 'CORP-HRMS' then 'Corporate'
when 'CORP-LeaseQuery' then 'Corporate'
when 'CORP-Network' then 'Corporate'
when 'CORP-Oracle' then 'Corporate'
when 'CORP-Oracle EBS' then 'Corporate'
when 'CORP-PBCS' then 'Corporate'
when 'CORP-Server' then 'Corporate'
when 'CORP-Splunk Dashboard' then 'Corporate'
when 'CORP-Website' then 'Corporate'
when 'CORP-Zscaler' then 'Corporate'
when 'METL-Network-WAN' then 'Infrastructure'
when 'METL-Network-LAN' then 'Infrastructure'
when 'METL-IS-Backend (Linux,Unix)' then 'Infrastructure'
when 'METL-Server-Windows' then 'Infrastructure'
when 'METL-All Technicians' then 'Infrastructure'
when 'METL-EAs' then 'Infrastructure'
when 'METL-Backup/DR' then 'METL-Backup/DR Team'
when 'METL-Division Infrastructure' then 'Infrastructure'
when 'METL-ServiceDesk' then 'SD'
when 'METL-SD-On-Call' then 'SD'
when 'METL-Site Support' then 'Site Support'
when 'SMC-SMWG-FieldServices' then 'Site Support'
when 'SMC-SCGE-FieldServices' then 'Site Support'
when 'SMC-HBEN-FieldServices' then 'Site Support'
when 'SMC-AUST-FieldServices' then 'Site Support'
when 'SMC-RVRT-FieldServices' then 'Site Support'
when 'SMC-NHDK-FieldServices' then 'Site Support'
when 'TIME-MORG-FieldServices' then 'Site Support'
when 'SMC-HACK-FieldServices' then 'Site Support'
when 'SMC-SCTM-FieldServices' then 'Site Support'
when 'SMC-RATH-FieldServices' then 'Site Support'
when 'TIME-WITT-FieldServices' then 'Site Support'
when 'TIME-HEND-FieldServices' then 'Site Support'
when 'TIME-WAUN-FieldServices' then 'Site Support'
when 'TIME-TORO-FieldServices' then 'Site Support'
when 'METL-Terminations' then 'Termination'
when 'Cherwell Platform Admin' then 'Corporate'
when 'METL-New Employee' then 'SD'
end Teams
,datediff(d,inc.[CreatedDateTime],isnull(case when inc.status <> 'reopened' then  inc.[ClosedDateTime] else null end,getdate())) DaysOld
,datediff(d,inc.[LastModifiedDateTime],getDate()) DaysSinceLstMod
,case when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 10 then '01-10 Days Old' when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 30 then '11-30 Days Old' when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 60 then '31-60 Days Old' Else '60+ Days Old' end AgedGroup
--,'cherwellclient://commands/goto?rectype=Incident&PublicID=' + cast(inc.ID as varchar(16)) as IncidentLink
,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(inc.ID as varchar(16)) as IncidentLink
,case when wi.TaskID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/work_item/' + cast(wi.TaskID as varchar(16)) else null end as WorkItemLink
	  ,TaskID
      ,Title
      ,wi.OwnedBy ItemOwner
      ,wi.Description ItemDescription
      ,wi.OwnedByTeam ItemTeam
      ,wi.ParentPublicID ItemParentPublicId
      ,wi.ParentTypeName ItemTypeName
      ,ConfigItemDisplayName
      ,wi.ClosedBy ItemClosedBy
      ,wi.ClosedDateTime ItemClosedDateTime
      ,wi.Status ItemStatus
      ,wi.CreatedBy ItemCreatedBy
      ,wi.Type ItemType
      ,IncidentSubcategory
      ,wi.IncidentCategory ItemIncidentCategory
      ,wi.LastModifiedDateTime ItemLastModifiedDateTime
      ,wi.CreatedDateTime ItemCreatedDateTime

	  ,case when ap.ApprovalID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	  ,ApprovalID
      ,ap.Status ApprovalStatus
      ,ApproverName
      ,CustomerApproverName
      ,ActualApproverName
      ,ObjectApprovalType
      ,ActualApprovedBy
      ,Details
      ,ApproverComment
      ,[ActualApproverEmail] ApproverEmail
      ,EmailApprover
      ,ap.[ActualParentType] ApprovalParentType
      ,ap.[ActualParentID] ApprovalParentID
      ,WhenApprovedDenied
  FROM [CW].[STAGE_INCIDENTS] inc left join (select * from [CW].[STAGE_WORK_ITEMS] where ParentTypeName in ('Service Request','Incident')) wi on inc.ID = wi.ParentPublicID 
  left join (SELECT [ApprovalID]
      ,[Status]
      ,[ApproverName]
      ,[CustomerApproverName]
      ,[ActualApproverName]
      ,[ObjectApprovalType]
      ,[ActualApprovedBy]
      ,[Details]
      ,[ApproverComment]
      ,[ActualApproverEmail]
      ,[EmailApprover]
      ,[WhenApprovedDenied]
	  ,[ActualParentType]
	  ,[ActualParentID] 
  FROM [CW].[vwApprovalsActualParents]
  where [ActualParentType] = 'work item') ap on wi.TaskID = ap.[ActualParentID] 

 union					--After getting work item approvals, get incident approvals

 SELECT inc.[Type]
      ,inc.[OwnedByTeam]
      ,inc.[OwnedBy]
      ,inc.[ID]
      ,inc.[CustomerName]
      ,inc.[FriendlyName]
      ,inc.[CreatedDateTime]
	  ,cast(inc.[CreatedDateTime] as date) [CreatedDate]
      ,inc.[Status]
      ,inc.[Description]
      ,inc.[Location]
      ,inc.[SLAResolveByDeadline]
      ,inc.[ConfigurationItem]
      ,inc.[Non-ValidatedResponse]
      ,inc.[CallSource]
      ,inc.[Cause]
      ,inc.[CloseDescription]
      ,inc.[ClosedBy]
      ,inc.[ClosedDateTime]
      ,inc.[CreatedBy]
      ,inc.[LastModifiedDateTime]
      ,inc.[RequesterDepartment]
      ,inc.[Withdraw]
      ,inc.[Category]
      ,inc.[Subcategory]
      ,inc.[OrderID]
      ,inc.[SmartClassifySearchString]
      ,inc.[Service]
      ,case when inc.Status <> 'Reopened' then  inc.[StatDateTimeResolved] else null end [StatDateTimeResolved]
	  ,case when inc.Status <> 'Reopened' then  cast(inc.[StatDateTimeResolved] as date) else null end [StatDateResolved]
      ,inc.[Division]
      ,inc.[Priority]
	  ,case inc.[OwnedByTeam]
when 'METL-Quality IS' then 'APPS'
when 'TIME-Apps-TIMET' then 'APPS'
when 'METL-Apps-SAP' then 'APPS'
when 'METL-BI (Web/SP/BI)' then 'APPS'
when 'SMC-Apps-NHD' then 'APPS'
when 'METL-Apps-SAP-Master Data' then 'APPS'
when 'SMC-Apps-SMW' then 'APPS'
when 'METL-BASIS/DBA/SAP_SEC' then 'APPS'
when 'WGFC-DVTX-Oracle' then 'APPS'
when 'METL-Apps-SAP-HR / HCM' then 'APPS'
when 'WGFC-DVTX-Database Team' then 'APPS'
when 'WGFC-EGY-Oracle' then 'APPS'
when 'SMC-EPM' then 'APPS'
when 'SMC-Apps-Revert' then 'APPS'
when 'SMC-Apps-HBEN' then 'APPS'
when 'METL-SAP-MII' then 'APPS'
when 'METL-SAP-Security' then 'APPS'
when 'METL-SAP-Vendor Master US' then 'APPS'
when 'SMC-Apps-Schulz' then 'APPS'
when 'TIME-Apps-STAR' then 'APPS'
when 'METL-Security/Compliance' then 'Compliance'
when 'Enterprise ITSM' then 'Corporate'
when 'Enterprise Network' then 'Corporate'
when 'Enterprise Admins' then 'Corporate'
when 'Enterprise Security' then 'Corporate'
when 'Enterprise eDiscovery' then 'Corporate'
when 'Enterprise SyteLine Cloud MDM' then 'Corporate'
when 'Enterprise SCCM' then 'Corporate'
when 'Enterprise SyteLine Cloud MDM' then 'Corporate'
when 'CORP-Service Desk' then 'Corporate'
when 'CORP-EPM Application ARC' then 'Corporate'
when 'CORP-Portal' then 'Corporate'
when 'CORP-Archer' then 'Corporate'
when 'CORP-Bitlocker' then 'Corporate'
when 'CORP-Bluecoat/SSLV' then 'Corporate'
when 'CORP-Corp-Data Team' then 'Corporate'
when 'CORP-EPM' then 'Corporate'
when 'CORP-Fixed Asset Report' then 'Corporate'
when 'CORP-FP&A' then 'Corporate'
when 'CORP-HRMS' then 'Corporate'
when 'CORP-LeaseQuery' then 'Corporate'
when 'CORP-Network' then 'Corporate'
when 'CORP-Oracle' then 'Corporate'
when 'CORP-Oracle EBS' then 'Corporate'
when 'CORP-PBCS' then 'Corporate'
when 'CORP-Server' then 'Corporate'
when 'CORP-Splunk Dashboard' then 'Corporate'
when 'CORP-Website' then 'Corporate'
when 'CORP-Zscaler' then 'Corporate'
when 'METL-Network-WAN' then 'Infrastructure'
when 'METL-Network-LAN' then 'Infrastructure'
when 'METL-IS-Backend (Linux,Unix)' then 'Infrastructure'
when 'METL-Server-Windows' then 'Infrastructure'
when 'METL-All Technicians' then 'Infrastructure'
when 'METL-EAs' then 'Infrastructure'
when 'METL-Backup/DR' then 'METL-Backup/DR Team'
when 'METL-Division Infrastructure' then 'Infrastructure'
when 'METL-ServiceDesk' then 'SD'
when 'METL-SD-On-Call' then 'SD'
when 'METL-Site Support' then 'Site Support'
when 'SMC-SMWG-FieldServices' then 'Site Support'
when 'SMC-SCGE-FieldServices' then 'Site Support'
when 'SMC-HBEN-FieldServices' then 'Site Support'
when 'SMC-AUST-FieldServices' then 'Site Support'
when 'SMC-RVRT-FieldServices' then 'Site Support'
when 'SMC-NHDK-FieldServices' then 'Site Support'
when 'TIME-MORG-FieldServices' then 'Site Support'
when 'SMC-HACK-FieldServices' then 'Site Support'
when 'SMC-SCTM-FieldServices' then 'Site Support'
when 'SMC-RATH-FieldServices' then 'Site Support'
when 'TIME-WITT-FieldServices' then 'Site Support'
when 'TIME-HEND-FieldServices' then 'Site Support'
when 'TIME-WAUN-FieldServices' then 'Site Support'
when 'TIME-TORO-FieldServices' then 'Site Support'
when 'METL-Terminations' then 'Termination'
when 'Cherwell Platform Admin' then 'Corporate'
end Teams
,datediff(d,inc.[CreatedDateTime],isnull(case when inc.status <> 'reopened' then  inc.[ClosedDateTime] else null end,getdate())) DaysOld
,datediff(d,inc.[LastModifiedDateTime],getDate()) DaysSinceLstMod
,case when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 10 then '01-10 Days Old' when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 30 then '11-30 Days Old' when datediff(d,inc.[CreatedDateTime],isnull(inc.[ClosedDateTime],getdate())) <= 60 then '31-60 Days Old' Else '60+ Days Old' end AgedGroup
--,'cherwellclient://commands/goto?rectype=Incident&PublicID=' + cast(inc.ID as varchar(16)) as IncidentLink
,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(inc.ID as varchar(16)) as IncidentLink
,case when wi.TaskID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/work_item/' + cast(wi.TaskID as varchar(16)) else null end as WorkItemLink
	  ,TaskID
      ,Title
      ,wi.OwnedBy ItemOwner
      ,wi.Description ItemDescription
      ,wi.OwnedByTeam ItemTeam
      ,wi.ParentPublicID ItemParentPublicId
      ,wi.ParentTypeName ItemTypeName
      ,ConfigItemDisplayName
      ,wi.ClosedBy ItemClosedBy
      ,wi.ClosedDateTime ItemClosedDateTime
      ,wi.Status ItemStatus
      ,wi.CreatedBy ItemCreatedBy
      ,wi.Type ItemType
      ,IncidentSubcategory
      ,wi.IncidentCategory ItemIncidentCategory
      ,wi.LastModifiedDateTime ItemLastModifiedDateTime
      ,wi.CreatedDateTime ItemCreatedDateTime

	  ,case when wi.TaskID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	  ,ApprovalID
      ,ap.Status ApprovalStatus
      ,ApproverName
      ,CustomerApproverName
      ,ActualApproverName
      ,ObjectApprovalType
      ,ActualApprovedBy
      ,Details
      ,ApproverComment
      ,[ActualApproverEmail]
      ,EmailApprover
      ,ap.[ActualParentType] ApprovalParentType
      ,ap.[ActualParentID] ApprovalParentID
      ,WhenApprovedDenied
  FROM [CW].[STAGE_INCIDENTS] inc left join (select * from [CW].[STAGE_WORK_ITEMS] where ParentTypeName in ('Service Request','Incident')) wi on inc.ID = wi.ParentPublicID 
  left join (SELECT [ApprovalID]
      ,[Status]
      ,[ApproverName]
      ,[CustomerApproverName]
      ,[ActualApproverName]
      ,[ObjectApprovalType]
      ,[ActualApprovedBy]
      ,[Details]
      ,[ApproverComment]
      ,[ActualApproverEmail]
      ,[EmailApprover]
      ,[WhenApprovedDenied]
	  ,[ActualParentType]
	  ,[ActualParentID] 
  FROM [CW].[vwApprovalsActualParents]
  where [ActualParentType] = 'incident') ap on inc.ID = ap.[ActualParentID] 
  where [ApprovalID] is not null
GO


