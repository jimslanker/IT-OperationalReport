-----------------------------------------------------------------
-- Filename: CW.spSendPendingApprovalEmails.sql
-- Author: Ryan Joaquim
-- Extracted from PROD SQL Server Database on 6/8/2022   
-----------------------------------------------------------------
USE [PROD]
GO

/****** Object:  StoredProcedure [CW].[spSendPendingApprovalEmails]    Script Date: 6/8/2022 11:22:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER procedure [CW].[spSendPendingApprovalEmails] as
declare @EmailsSent
TABLE( Email varchar(128), EmailBody varchar(max))
declare @count int
set @count = 0

	--Declare and set our default email settings
Declare @EmailSubject varchar(64)
Declare @EmailImportance varchar(8)
Declare @EmailProfile varchar(32)
Declare @EmailFormat varchar(4)

set @EmailSubject = 'Cherwell Tickets Pending Your Approval'
set @EmailImportance = 'Normal'
set @EmailProfile = 'OPREP Email Alerts'
set @EmailFormat = 'HTML'

	--Declare the variables that will store our cursor data
Declare @CursorApproverName varchar(128)
Declare @CursorEmail varchar(128)
Declare @CursorApprovalType varchar(16)
Declare @CursorLine varchar(1024)
Declare @CursorApproved varchar(1024)
Declare @CursorDenied varchar(1024)
Declare @CursorDescription varchar(300)
Declare @CursorCustomer	varchar(64)
Declare @CursorOwnedBy  varchar(64)

	--Declare and set comparison variables used to tell if we are onto the next person or approval type
Declare @CurrentEmail varchar(128)
Declare @CurrentApprovalType varchar(16)

set @CurrentEmail = ''
set @CurrentApprovalType = ''

	--Declare and set the message variable, this variable will store our entire body of our email
Declare @EmailBody varchar(max)

set @EmailBody = ''
	-- Declare and set suggestion link
Declare @SuggestionEmail varchar(1024)

set @SuggestionEmail = '<a href="mailto:svc_timeitops@precastcorp.com?Subject=Suggestion/Issues">Suggestions or Issues? Click Here</a>'

	--Cursor will go through each row of the table 1 by 1, the order by is important in order to keep all of the approver's approvals on the same email
Declare ApprovalEmail_Cursor cursor for 
SELECT 
	   case when CHARINDEX(',',ActualApproverName) = 0 then ActualApproverName else trim(SUBSTRING([ActualApproverName],CHARINDEX(',',ActualApproverName)+1,LEN([ActualApproverName]))) + ' ' + substring([ActualApproverName],0,CHARINDEX(',',ActualApproverName)) end ApproverName		--Names are stored last,first this rearanges it to be first last if there is a ,
      ,[ActualApproverEmail]
	  ,Description
	  ,case when CHARINDEX(',',CustomerName) = 0 then CustomerName else trim(SUBSTRING([CustomerName],CHARINDEX(',',CustomerName)+1,LEN([CustomerName]))) + ' ' + substring([CustomerName],0,CHARINDEX(',',CustomerName)) end CustomerName
      ,case when CHARINDEX(',',OwnedBy) = 0 then OwnedBy else trim(SUBSTRING([OwnedBy],CHARINDEX(',',OwnedBy)+1,LEN([OwnedBy]))) + ' ' + substring([OwnedBy],0,CHARINDEX(',',OwnedBy)) end OwnedBy
      ,[ApprovalFor]
	  ,ObjectApprovalType + ' for '
	   + ApprovalFor + ' ' + N'<a href="'+ IdLink + '">'+ +  cast(ID as varchar(16)) + '</a>' ApprovalLine
	,case when Approved ='' then 'Please open Cherwell to Approve or Reject this ticket' else N'<a href="'+ Approved + '">        Approve</a>' end
	,case when Denied ='' then '' else N'<a href="'+ Denied + '">Deny</a>' end
  FROM [CW].[vwPendingApprovals]
  where ActualApproverEmail = 'GMalec@specialmetals.com' or ActualApproverEmail = 'john.kocsis@timet.com' or ActualApproverEmail = 'sandra.idris@timet.com' or
  ActualApproverEmail = 'kipper.berry@specialmetals.com' or ActualApproverEmail = 'steve.phillips@timet.com' or ActualApproverEmail = 'warren.owens@tiemt.com' or
  ActualApproverEmail = 'martin.daeufel@timet.com' or ActualApproverEmail = 'michael.cheek@timet.com' or ActualApproverEmail = 'mbodinger@hackneyladish.com' or
  ActualApproverEmail = 'joe.hough@timet.com' or ActualApproverEmail = 'john.hendrickson@canmkg.com'
  order by ActualApproverEmail,ApprovalFor desc,ApprovalID

	--Start looping through the table results entering the first row's data into our previously declared variables
Open ApprovalEmail_Cursor 
Fetch next from ApprovalEmail_Cursor into @CursorApproverName, @CursorEmail, @CursorDescription, @CursorCustomer, @CursorOwnedBy, @CursorApprovalType, @CursorLine, @CursorApproved, @CursorDenied 
WHILE @@FETCH_STATUS = 0  
BEGIN 
	set @count = @count + 1
	--If the current email is blank then this is their first approval and we need to set our header
	IF(@CurrentEmail = '')
	BEGIN
		set @EmailBody = @CursorApproverName+ ',<br><br> The following Cherwell approvals have been assigned to you and are awaiting your approval.<br><br>'
	END
	--If this is their first incident apprvoval, label the incidents and start the list
	IF (@CursorApprovalType = 'Incident' and @CurrentApprovalType <> @CursorApprovalType)
	BEGIN
		set @EmailBody = @EmailBody + 'Incidents/Service Requests:' + '<ul>'
	END
	--If this is their first change apprvoval, label the change and start the list. A second if statement is needed to check if an incident list needs to be closed first
	IF (@CursorApprovalType = 'Change Request' and @CurrentApprovalType <> @CursorApprovalType)
	BEGIN
		IF (@CursorApprovalType <> '')
		BEGIN
			set @EmailBody = @EmailBody + '</ul>'
		END
		set @EmailBody = @EmailBody + 'Change Requests:' + '<ul>'
	END
	--Add the line for the approval to the list
	set @EmailBody = @EmailBody +'<li>' + @CursorLine + '</li>' 
	--Adding inner list for approval links
	set @EmailBody = @EmailBody + '<ul>' + '<li>' +'<b>'+'Owned by : ' +'</b>'+ @CursorOwnedBy + '</li>' + '<li>' +'<b>'+'Customer: ' +'</b>'+ @CursorCustomer + '</li>' ++'<li>' +'<b>'+'Descrption: ' +'</b>'+ @CursorDescription + '</li>' + '<li>' + @CursorApproved + '     or     ' + @CursorDenied + '</li>'+  + '</ul>' 
	--Set the current values equal to the current cursor values for the next loop if needed
	set @CurrentApprovalType = @CursorApprovalType
	set @CurrentEmail = @CursorEmail
	--Get the data from the next row
	Fetch next from ApprovalEmail_Cursor into @CursorApproverName, @CursorEmail, @CursorDescription,@CursorCustomer, @CursorOwnedBy,@CursorApprovalType, @CursorLine, @CursorApproved, @CursorDenied 

	--If the cursor email and the current email don't match then we have finished going through all of the previous approver's pending approvals, now we can send the email to the approver and reset the current email and the email body. Fetch status also needs to be checked for last row
	IF (@CursorEmail <> @CurrentEmail or @@FETCH_STATUS!=0)
	BEGIN
		set @EmailBody = @EmailBody + '</ul>' + '<br>'
		--Adding Suggestion Link
		set @EmailBody = @EmailBody + @SuggestionEmail
		exec msdb.dbo.sp_send_dbmail																													--Execute the built-in proc for sending an email based on the previosly setup DB profile
		@profile_name = @EmailProfile,
		@recipients = @CurrentEmail,
		@subject = @EmailSubject,
		@importance = @EmailImportance,
		@body = @EmailBody,
		@body_format = @EmailFormat 

		insert into @EmailsSent
		select @CurrentEmail,@EmailBody

		SET @CurrentEmail = ''
		SET @CurrentApprovalType = ''
		SET @EmailBody = ''
	END
End
	--Close and deallocate the cursor, we have processed the whole table
close ApprovalEmail_Cursor
deallocate ApprovalEmail_Cursor

select * from @EmailsSent
GO


