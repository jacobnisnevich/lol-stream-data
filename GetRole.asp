<% @LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="connect.asp" -->
<% 
	'retrieve url parameter and store it
	twitch = Request.QueryString("stream")

	'open ADODB connection to database
	Set myConn = Server.CreateObject("ADODB.Connection")
	myConn.open(GetConnectionString())
	set rs = Server.CreateObject("ADODB.recordset")

	set command = Server.CreateObject("ADODB.Command")
	command.CommandText = "SELECT * FROM lsd_streams WHERE twitch = ?"
	command.CommandType = 1 'adCmdText
	command.ActiveConnection = myConn

	set twitchParam = command.CreateParameter("@twitch", 200, &H0001, 255, twitch)
	command.Parameters.Append twitchParam

	'set recordset rs to SQL command output
	Set rs = command.Execute()
	If Not rs.EOF Then
		Response.Write rs("role")
	End If
	rs.Close : Set rs = Nothing : Set command = Nothing : myConn.Close : Set myConn = Nothing
	
	Response.End()
%> 