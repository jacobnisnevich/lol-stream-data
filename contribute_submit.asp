<%@ Language=VBScript %>
<!--#include file="includes/adovbs.inc" -->
<!--#include file="connect.asp" -->
<% 
	function EncodeUTF8(s)
		dim i
		dim c

		i = 1
		do while i <= len(s)
			c = asc(mid(s,i,1))
			if c >= &H80 then
				s = left(s,i-1) + chr(&HC2 + ((c and &H40) / &H40)) + chr(c and &HBF) + mid(s,i+1)
				i = i + 1
			end if
			i = i + 1
		loop
		EncodeUTF8 = s 
	end function

	summoner = Request.Form("summoner")
	twitch = Request.Form("twitch")
	role = Request.Form("role")
	region = Request.Form("region")

	summonerUTF = EncodeUTF8(Request.Form("summoner"))
	twitchUTF = EncodeUTF8(Request.Form("twitch"))
	roleUTF = EncodeUTF8(Request.Form("role"))
	regionUTF = EncodeUTF8(Request.Form("region"))

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