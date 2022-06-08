-----------------------------------------------------------------
-- Filename: cw.UserTicketsByMonth_Resolved.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  View [CW].[UserTicketsByMonth_Resolved]    Script Date: 6/8/2022 11:17:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER view [CW].[UserTicketsByMonth_Resolved] as
SELECT  OwnedBy
		,OwnedByTeam
		,Teams
		,isnull(Aug,0) Aug
,isnull(Sep,0) Sep
,isnull(Oct,0) Oct
,isnull(Nov,0) Nov
,isnull(DEC,0) DEC
,isnull(Jan,0) Jan
,isnull(Feb,0) Feb
/*,isnull(Mar,0) Mar
,isnull(May,0) May
,isnull(Apr,0) Apr
,isnull(Jun,0) Jun
,isnull(Jul,0) Jul*/
,isnull(Total,0) Total
,isnull(total / 7 ,0) Average

FROM (
	SELECT inc.OwnedBy
		,inc.OwnedByTeam
		,FORMAT(StatDateTimeResolved, 'MMM', 'en-US') Mon
		,count(*) coun
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
		,Total
	FROM [CW].[STAGE_INCIDENTS] inc left join (select OwnedBy,OwnedByTeam,count(*) total from [CW].[STAGE_INCIDENTS] WHERE StatDateTimeResolved >= '8/1/21' group by OwnedBy,OwnedByTeam ) inc2 on inc.OwnedBy = inc2.OwnedBy and inc.OwnedByTeam = inc2.OwnedByTeam
	WHERE StatDateTimeResolved >= '8/1/21' and Status <> 'Reopened'
	GROUP BY inc.OwnedByTeam
		,inc.ownedby
		,FORMAT(StatDateTimeResolved, 'MMM', 'en-US')
		,total
	) t
pivot(sum(coun) FOR mon IN (
			Aug
			,Sep
			,Oct
			,Nov
			,DEC
			,Jan
			,Feb
			,Mar
			,May
			,Apr
			,Jun
			,Jul
			)
) AS piv
GO


