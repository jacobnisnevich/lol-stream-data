<%@ Language=VBScript %>
<!--#include file="includes/adovbs.inc" -->
<!--#include file="connect.asp" -->
<% 
	Response.CharSet = "UTF-8"

	summoner = Request.Form("summoner")
	twitch = Request.Form("twitch")
	role = Request.Form("role")
	region = Request.Form("region")

	Set myConn = Server.CreateObject("ADODB.Connection")
	myConn.open(GetConnectionString())

	set command = Server.CreateObject("ADODB.Command")
	command.CommandText = "INSERT INTO lsd_streams (twitch, summoner, role, region)" _ 
		& "VALUES ('" & twitch & "','" & summoner & "','" & role & "','" & region & "')"
	command.CommandType = adCmdText
	command.ActiveConnection = myConn

	Set rs = command.Execute()

	myConn.Close

	Response.Redirect "/lol-stream-data/contribute_confirm.asp?summoner=" & summoner & "&twitch=" & twitch & "&role=" & role & "&region=" & region
%>