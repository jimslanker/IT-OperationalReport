-----------------------------------------------------------------
-- Filename: CW.spSEND_TICKET_EMAILS.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------

USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spSEND_TICKET_EMAILS]    Script Date: 6/8/2022 11:21:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER procedure [CW].[spSEND_TICKET_EMAILS] (@SendTo varchar(128)) as		--SendTo parameter is used for allowing individual users to recieve the email, pass % as the parameter to send all
declare @EmailsSent
TABLE( Email varchar(128), EmailBody varchar(max))
declare @count int
set @count = 0

	--Declare and set our default email settings
Declare @EmailSubject varchar(64)
Declare @EmailImportance varchar(8)
Declare @EmailProfile varchar(32)
Declare @EmailFormat varchar(4)

set @EmailSubject = 'Cherwell Ticket Summary'
set @EmailImportance = 'Normal'
set @EmailProfile = 'OPREP Email Alerts'
set @EmailFormat = 'HTML'

	--Declare the variables that will store our cursor data
Declare @CursorUserName varchar(128)
Declare @CursorUserNameFirstLast varchar(128)
Declare @CursorEmail varchar(128)
Declare @CursorDescription varchar(300)
Declare @CursorCustomer	varchar(64)
Declare @CursorOwnedBy  varchar(64)
Declare @CursorOwnedByEmail varchar(128)
Declare @CursorEmailCategory varchar(32)
Declare @CursorLine varchar(1024)
Declare @CursorApproved varchar(1024)
Declare @CursorDenied varchar(1024)

	--Declare and set comparison variables used to tell if we are onto the next person or email category
Declare @CurrentEmail varchar(128)
Declare @CurrentEmailCategory varchar(32)
Declare @GROUP_ID int

set @CurrentEmail = ''
set @CurrentEmailCategory = ''

select @GROUP_ID = isnull(max(GROUP_ID),0) + 1 from [CW].[SENT_TICKET_EMAILS_LOG]


	--Declare and set the message variable, this variable will store our entire body of our email
Declare @EmailBody varchar(max)

set @EmailBody = ''
	-- Declare and set suggestion link
Declare @SuggestionEmail varchar(1024)
Declare @ResendEmail varchar(1024)

set @SuggestionEmail = '<a href="mailto:svc_timeitops@precastcorp.com?Subject=Suggestion/Issues">Suggestions or Issues? Click Here</a>'

	--Cursor will go through each row of the table 1 by 1, the order by is important in order to keep all of the User's items on the same email
Declare CherwellEmail_Cursor cursor for 
	--The data we use for our cursor is coming from two view; 1 that determines the user's pending approvals and another that determines active tickets the user is either the owner of or the creator for. After unioning them into a table we need to join them with the emial category table to determine order
SELECT t.UserName
	,t.UserNameFirstLast
	,t.Email
	,t.Description
	,t.CustomerName
	,t.OwnedBy
	,t.OwnedByEmail
	,t.EmailCategory
	,t.ItemLine
	,t.ApproveLink
	,t.DenyLink
FROM (
	SELECT UserName
		,CASE 
			WHEN CHARINDEX(',', UserName) = 0
				THEN UserName
			ELSE trim(SUBSTRING(UserName, CHARINDEX(',', UserName) + 1, LEN(UserName))) + ' ' + substring(UserName, 0, CHARINDEX(',', UserName))
			END UserNameFirstLast --Names are stored last,first this rearanges it to be first last if there is a ,
		,[Description]
		,[Email]
		,[EmailCategory]
		,Ticket ItemNumber
		,CASE 
			WHEN EmailCategory LIKE '%incident%'
				THEN 'Incident '
			ELSE 'Change Request '
			END + N'<a href="' + Link + '">' + + cast(Ticket AS VARCHAR(16)) + '</a>' ItemLine
		,CASE 
			WHEN CHARINDEX(',', CustomerName) = 0
				THEN CustomerName
			ELSE trim(SUBSTRING([CustomerName], CHARINDEX(',', CustomerName) + 1, LEN([CustomerName]))) + ' ' + substring([CustomerName], 0, CHARINDEX(',', CustomerName))
			END CustomerName
		,CASE 
			WHEN CHARINDEX(',', OwnedBy) = 0
				THEN OwnedBy
			ELSE trim(SUBSTRING([OwnedBy], CHARINDEX(',', OwnedBy) + 1, LEN([OwnedBy]))) + ' ' + substring([OwnedBy], 0, CHARINDEX(',', OwnedBy))
			END OwnedBy
		,OwnedByEmail
		,'' ApproveLink
		,'' DenyLink
	FROM [CW].[vwOPEN_TICKETS_EMAIL]
	
	UNION
	
	SELECT ActualApproverName
		,CASE 
			WHEN CHARINDEX(',', ActualApproverName) = 0
				THEN ActualApproverName
			ELSE trim(SUBSTRING([ActualApproverName], CHARINDEX(',', ActualApproverName) + 1, LEN([ActualApproverName]))) + ' ' + substring([ActualApproverName], 0, CHARINDEX(',', ActualApproverName))
			END ApproverName --Names are stored last,first this rearanges it to be first last if there is a ,
		,Description
		,[ActualApproverEmail]
		,EmailCategory
		,ApprovalID
		,ObjectApprovalType + ' approval ' + cast(ApprovalID as varchar(16)) + ' for ' + ApprovalFor + ' ' + N'<a href="' + IdLink + '">' + + cast(ID AS VARCHAR(16)) + '</a>' ApprovalLine
		,CASE 
			WHEN CHARINDEX(',', CustomerName) = 0
				THEN CustomerName
			ELSE trim(SUBSTRING([CustomerName], CHARINDEX(',', CustomerName) + 1, LEN([CustomerName]))) + ' ' + substring([CustomerName], 0, CHARINDEX(',', CustomerName))
			END CustomerName
		,CASE 
			WHEN CHARINDEX(',', OwnedBy) = 0
				THEN OwnedBy
			ELSE trim(SUBSTRING([OwnedBy], CHARINDEX(',', OwnedBy) + 1, LEN([OwnedBy]))) + ' ' + substring([OwnedBy], 0, CHARINDEX(',', OwnedBy))
			END OwnedBy
		,OwnedByEmail
		,CASE 
			WHEN Approved = ''
				THEN 'Please open Cherwell to Approve or Reject this ticket'
			ELSE N'<a href="' + Approved + '">        Approve</a>'
			END
		,CASE 
			WHEN Denied = ''
				THEN ''
			ELSE N'<a href="' + Denied + '">Deny</a>'
			END
	FROM [CW].[vwPendingApprovals]
	) t
INNER JOIN [CW].[EMAIL_CATEGORY] ec ON t.EmailCategory = ec.Description
where (Email in ('James.Owens@Timet.com','GMalec@specialmetals.com', 'john.kocsis@timet.com', 'sandra.idris@timet.com', 'kipper.berry@specialmetals.com', 'steve.phillips@timet.com', 
'warren.owens@timet.com', 'martin.daeufel@timet.com', 'michael.cheek@timet.com', 'mbodinger@hackneyladish.com', 'joe.hough@timet.com', 'john.hendrickson@canmkg.com','NNebelski@specialmetals.com',
'Joseph.Winnicki@Timet.com','mlobrien@wyman.com','THall@specialmetals.com','Joseph.McCallister@Timet.com','ryan.joaquim@rathgibson.com','william.lane@timet.com')) and Email like @SendTo
ORDER BY t.Email,ec.Category,t.ItemNumber

	--Start looping through the table results entering the first row's data into our previously declared variables
Open CherwellEmail_Cursor 
Fetch next from CherwellEmail_Cursor into @CursorUserName, @CursorUserNameFirstLast, @CursorEmail, @CursorDescription, @CursorCustomer, @CursorOwnedBy,@CursorOwnedByEmail, @CursorEmailCategory, @CursorLine, @CursorApproved, @CursorDenied 
WHILE @@FETCH_STATUS = 0  
BEGIN 
	set @count = @count + 1
	--If the current email is blank then this is their first item and we need to set our header
	IF(@CurrentEmail = '')
	BEGIN
		set @EmailBody = @CursorUserNameFirstLast+ ',<br><br> The following list is a summary of your current Cherwell tickets.<br><br>'
	END
	--If this is their first incident apprvoval, label the incidents and start the list
	IF (@CursorEmailCategory = 'Incident Approvals' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Pending Incidents/Service Request Approvals:' + '<ul>'
	END
	--If this is their first change apprvoval, label the change and start the list. A second if statement is needed to check if an incident list needs to be closed first
	IF (@CursorEmailCategory = 'Change Approvals' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Pending Change Request Approvals:' + '<ul>'
	END
	--If this is their first assigned incident, label the incident and start the list. A second if statement is needed to check if a list needs to be closed first
	IF (@CursorEmailCategory = 'Assigned Incidents' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Assigned Incident Requests:' + '<ul>'
	END
	--If this is their first assigned Change request, label the change request and start the list. A second if statement is needed to check if a list needs to be closed first
	IF (@CursorEmailCategory = 'Assigned Changes' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Assigned Changes Requests:' + '<ul>'
	END
	--If this is their first created incident request, label the incident request and start the list. A second if statement is needed to check if a list needs to be closed first
	IF (@CursorEmailCategory = 'Created Incidents' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Created Incident Requests:' + '<ul>'
	END
	--If this is their first assigned Change request, label the change request and start the list. A second if statement is needed to check if a list needs to be closed first
	IF (@CursorEmailCategory = 'Requested Changes' and @CurrentEmailCategory <> @CursorEmailCategory)
	BEGIN
		IF (@CursorEmailCategory <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Requested Change Requests:' + '<ul>'
	END
	--Add the line for the approval to the list
	set @EmailBody = @EmailBody +'<li>' + @CursorLine + '</li>' 
	--Adding inner list for approval links
	set @EmailBody = @EmailBody + '<ul>' + '<li>' +'<b>'+'Owned by : ' +'</b>'+ @CursorOwnedBy + ' ' + case when @CursorOwnedByEmail is not null then '<a href="MSTeams:/l/chat/0/0?users=' + @CursorOwnedByEmail + '">Chat in Teams</a>' else '' end+ '</li>' 
		+ '<li>' +'<b>'+'Customer: ' +'</b>'+ @CursorCustomer + '</li>' 
		+'<li>' +'<b>'+'Descrption: ' +'</b>'+ @CursorDescription + '</li>' 
	IF(@CursorEmailCategory = 'Incident Approvals' or @CursorEmailCategory = 'Change Approvals')
	BEGIN
		set @EmailBody = @EmailBody + '<li>' + @CursorApproved + '     or     ' + @CursorDenied + '</li>'
	END
	set @EmailBody = @EmailBody   + '</ul>' 
	--Set the current values equal to the current cursor values for the next loop if needed
	set @CurrentEmailCategory = @CursorEmailCategory
	set @CurrentEmail = @CursorEmail
	--Get the data from the next row
	Fetch next from CherwellEmail_Cursor into @CursorUserName, @CursorUserNameFirstLast, @CursorEmail, @CursorDescription, @CursorCustomer, @CursorOwnedBy,@CursorOwnedByEmail, @CursorEmailCategory, @CursorLine, @CursorApproved, @CursorDenied 

	--If the cursor email and the current email don't match then we have finished going through all of the previous user's items, now we can send the email to the user and reset the current email and the email body. Fetch status also needs to be checked for last row
	IF (@CursorEmail <> @CurrentEmail or @@FETCH_STATUS!=0)
	BEGIN
		set @EmailBody = @EmailBody + '</ul>'
		--Add a link to request an updated summary. This will forward an email to the service account which has a power automate flow that will look for this email subject then rerun the procudeure passing the user's email as a parameter.
		set @EmailBody = @EmailBody + '<a href="mailto:svc_timeitops@precastcorp.com?Subject=Resend Cherwell Ticket Summary&body=IMPORTANT: Please do not edit this email %0d%0a%0d%0a{'+ @CurrentEmail +'}%0d%0a%0d%0a*Note this data syncs with Cherwell every 15 minutes on the hour so recent updates may not show.">Resend Updated Email</a>'+ '<br>' + '<br>' --%0d%0a is the new line character for emails
		--Adding Suggestion Link
		set @EmailBody = @EmailBody + @SuggestionEmail + '<br>'
		exec msdb.dbo.sp_send_dbmail																													--Execute the built-in proc for sending an email based on the previosly setup DB profile
		@profile_name = @EmailProfile,
		@recipients = @CurrentEmail,--'ryan.joaquim@precastcorp.com;wlane@precastcorp.com',--
		@subject = @EmailSubject,
		@importance = @EmailImportance,
		@body = @EmailBody,
		@body_format = @EmailFormat 

		insert into [CW].[SENT_TICKET_EMAILS_LOG]
		select @GROUP_ID,getdate(), @CurrentEmail,@EmailBody

		SET @CurrentEmail = ''
		SET @CurrentEmailCategory = ''
		SET @EmailBody = ''
	END
End
	--Close and deallocate the cursor, we have processed the whole table
close CherwellEmail_Cursor
deallocate CherwellEmail_Cursor

--select * from @EmailsSent
--order by Email
GO


