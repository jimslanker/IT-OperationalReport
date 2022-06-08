-----------------------------------------------------------------
-- Filename: cw.vwPendingApprovals.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  View [CW].[vwPendingApprovals]    Script Date: 6/8/2022 11:20:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











CREATE OR ALTER view [CW].[vwPendingApprovals] as

--Get Incident Approvals based on Work Items
SELECT inc.ID
	,inc.CustomerName as CustomerName
	,inc.OwnedBy as OwnedBy
	,inc.OwnedByEmail
	,cast(replace(inc.Description,'Â','') as varchar(300)) Description
	,wi.[TaskID]
	,wi.[ParentPublicID]
	,ap.[ApprovalID]
	,ap.[ActualApproverName]
	,ap.[ObjectApprovalType]
	,ap.[ActualApproverEmail]
	,ap.[ActualParentType]
	,ap.[ActualParentID]
	,'Incident' ApprovalFor
	,'Incident Approvals' EmailCategory
	,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(inc.ID as varchar(16)) as IdLink
	,case when wi.TaskID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/work_item/' + cast(wi.TaskID as varchar(16)) else null end as WorkItemLink
	,case when ap.ApprovalID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + case when inc.Type = 'Incident' then  'Incident%20' else 'Service%20Request%20' end + 'Approved%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line%20or%20delete%20this%20message.%20Add%20any%20notes%20about%20your%20approval%20of%20work%20item%20' + cast(wi.taskid as varchar(16)) + '%20on%20ticket%20' + cast(inc.id as varchar(16))+'%20in%20the%20comments%20section%20below.%0D%0A%0D%0AComments:' as Approved
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + case when inc.Type = 'Incident' then  'Incident%20' else 'Service%20Request%20' end + 'Denied%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line%20or%20delete%20this%20message.%20Add%20any%20notes%20about%20your%20rejection%20of%20work%20item%20' + cast(wi.taskid as varchar(16)) + '%20on%20ticket%20' + cast(inc.id as varchar(16))+'%20in%20the%20comments%20section%20below.%0D%0A%0D%0AComments:' as Denied
FROM  [CW].[STAGE_INCIDENTS] Inc
LEFT JOIN [CW].[STAGE_WORK_ITEMS] wi ON inc.ID = wi.ParentPublicID
INNER JOIN [CW].[vwApprovalsActualParents] ap ON ap.ActualParentID = wi.TaskID
WHERE inc.STATUS IN ('Assigned','Reopened','In Progress','New')
	and wi.STATUS IN ('Pending Approval','Acknowledged','In Progress','New')
	and ap.STATUS = 'waiting' AND ap.ActualApproverEmail <> '' AND ap.ActualParentType = 'Work Item'
Union
--Get Incident Approvals based on Incident ID
SELECT inc.ID
	,inc.CustomerName as CustomerName
	,inc.OwnedBy as OwnedBy
	,inc.OwnedByEmail
	,cast(replace(inc.Description,'Â','') as varchar(300)) [Description]
	,''
	,''
	,ap.[ApprovalID]
	,ap.[ActualApproverName]
	,ap.[ObjectApprovalType]
	,ap.[ActualApproverEmail]
	,ap.[ActualParentType]
	,ap.[ActualParentID]
	,'Incident' ApprovalFor
	,'Incident Approvals' EmailCategory
	,'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/incident/' + cast(inc.ID as varchar(16)) as IdLink
	,null as WorkItemLink
	,case when ap.ApprovalID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	,'' 
	,''
FROM  [CW].[STAGE_INCIDENTS] Inc
INNER JOIN [CW].[vwApprovalsActualParents] ap ON ap.ActualParentID = inc.ID
WHERE inc.STATUS IN ('Assigned','Reopened','In Progress','New')
	and ap.STATUS = 'waiting' AND ap.ActualApproverEmail <> '' AND ap.ActualParentType = 'Incident'
Union
	--Get Change Approvals based on Work Items
SELECT cr.ChangeID
	,cr.RequestedBy as CustomerName
	,cr.ChangeOwner as OwnedBy
	,cr.OwnedByEmail
	,cast(replace(cr.Description,'Â','') as varchar(300)) Description
	,wi.TaskID
	,wi.ParentPublicID
	,ap.[ApprovalID]
	,ap.[ActualApproverName]
	,ap.[ObjectApprovalType]
	,ap.[ActualApproverEmail]
	,ap.[ActualParentType]
	,ap.[ActualParentID]
	,'Change Request' ApprovalFor
	,'Change Approvals' EmailCategory
	,case when cr.ChangeID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/changerequest/' + cast(cr.ChangeID as varchar(16)) else null end as IdLink
	,case when wi.TaskID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/work_item/' + cast(wi.TaskID as varchar(16)) else null end as WorkItemLink
	,case when ap.ApprovalID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + 'Change%20Request%20' + 'Approved%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line%20or%20delete%20this%20message.%20Add%20any%20notes%20about%20your%20approval%20of%20work%20item%20' + cast(wi.taskid as varchar(16)) + '%20on%20ticket%20' + cast(cr.ChangeID as varchar(16))+'%20in%20the%20comments%20section%20below.%0D%0A%0D%0AComments:' as Approved -- creates link for approval button in email
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + 'Change%20Request%20' + 'Denied%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line%20or%20delete%20this%20message.%20Add%20any%20notes%20about%20your%20rejection%20of%20work%20item%20' + cast(wi.taskid as varchar(16)) + '%20on%20ticket%20' + cast(cr.ChangeID as varchar(16)) + '%20in%20the%20comments%20section%20below.%0D%0A%0D%0AComments:' as Denied -- creates link for deny button in email
FROM [CW].[STAGE_CHANGE_REQUESTS] cr
LEFT JOIN [CW].[STAGE_WORK_ITEMS] wi ON cr.ChangeID = wi.ParentPublicID
INNER JOIN [CW].[vwApprovalsActualParents] ap ON ap.ActualParentID = wi.TaskID
where cr.status not in ('Closed','','Review','Deploy')
	and wi.STATUS IN ('Pending Approval','Acknowledged','In Progress','New') AND wi.ParentTypeName = 'Change'
	and ap.STATUS = 'waiting'AND ap.ActualApproverEmail <> '' AND ap.ActualParentType = 'Work Item'
Union
--Get Change Approvals based on Change ID
SELECT cr.[ChangeID]
	,cr.RequestedBy as CustomerName
	,cr.ChangeOwner as OwnedBy
	,cr.OwnedByEmail
	,cast(replace(Description,'Â','') as varchar(300)) [Description]
	,''
	,''
	,ap.[ApprovalID]
	,ap.[ActualApproverName]
	,ap.[ObjectApprovalType]
	,ap.[ActualApproverEmail]
	,ap.[ActualParentType]
	,ap.[ActualParentID]
	, 'Change Request' ApprovalFor
	,'Change Approvals' EmailCategory
	,case when cr.ChangeID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/changerequest/' + cast(cr.ChangeID as varchar(16)) else null end as IdLink
	,null as WorkItemLink
	,case when ap.ApprovalID is not null  then 'https://corp-hdeskprod.cherwellondemand.com/CherwellClient/Access/approval/' + cast(ap.ApprovalID as varchar(16)) else null end as ApprovalLink
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + 'Change%20Request%20' + 'Approved%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line,%20add%20any%20notes%20about%20your%20approval%20for%20Change%20'  + cast(cr.ChangeID as varchar(16))+'%20below.%0D%0A%0D%0AComments:' as Approved
	,'mailto:pcchelpdesk@precastcorp.com?Subject=' + 'Change%20Request%20' + 'Denied%20' + cast(ap.ApprovalID as varchar(16)) + '&body=IMPORTANT:%20Please%20do%20not%20edit%20the%20subject%20line,%20add%20any%20notes%20about%20your%20rejection%20for%20Change%20' + cast(cr.ChangeID as varchar(16)) + '%20below.%0D%0A%0D%0AComments:' as Denied	  
FROM [CW].[STAGE_CHANGE_REQUESTS] cr
INNER JOIN [CW].[vwApprovalsActualParents] ap ON ap.ActualParentID = cr.ChangeID
where cr.status not in ('Closed','','Review','Deploy')
	and ap.STATUS = 'waiting' AND ActualApproverEmail <> '' AND ActualParentType = 'Change Request'
GO


