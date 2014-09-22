<% @LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="connect.asp" -->
<!--#include file="includes/aspJSON1.17.asp" -->
<!--#include file="helpers.asp" -->
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

	Set readJSON = New aspJSON

	champID = ""

	Do While Not rs.EOF

		summoner = Replace(LCase(rs("summoner")), " ", "")
		region = rs("region")
		role = rs("role")

		If region = "kr" Then
			Exit Do
		End If

	    jsonstring = GetTextFromUrl("https://community-league-of-legends.p.mashape.com/api/v1.0/" + region + "/summoner/retrieveInProgressSpectatorGameInfo/" + summoner)

		'get data from LoL api based on summoner
		If Not IsNull(jsonstring) And Not IsEmpty(jsonstring) Then
			readJSON.loadJSON(jsonstring)
        Else 
            Exit Do
		End If

		'if summoner is in a game, exit loop, otherwise move on to next record
		If Not IsNull(readJSON.data("game")) And Not IsEmpty(readJSON.data("game")) Then
			For Each player In readJSON.data("game").item("playerChampionSelections").item("array")
				Set this = readJSON.data("game").item("playerChampionSelections").item("array").item(player)
				If this.item("summonerInternalName") = summoner Then
					champID = CStr(this.item("championId"))
					Exit For
				End If
			Next

			Exit Do
		Else
			rs.MoveNext
		End If

	Loop

	rs.Close : Set rs = Nothing : Set command = Nothing : myConn.Close : Set myConn = Nothing

    champName = ""

    If champID <> "" Then
	    'open ADODB connection to database
	    Set myConn = Server.CreateObject("ADODB.Connection")
	    myConn.open(GetConnectionString())
	    set rs = Server.CreateObject("ADODB.recordset")

	    set command = Server.CreateObject("ADODB.Command")
	    command.CommandText = "SELECT * FROM lsd_champions WHERE id = ?"
	    command.CommandType = 1 'adCmdText
	    command.ActiveConnection = myConn

	    set twitchParam = command.CreateParameter("@id", 3, &H0001, 255, champID)
	    command.Parameters.Append twitchParam

	    'set recordset rs to SQL command output
	    Set rs = command.Execute()

	    champName = rs("name")
        
        rs.Close : Set rs = Nothing : Set command = Nothing : myConn.Close : Set myConn = Nothing
    End If

	Set writeJSON = New aspJSON

	With writeJSON.data

		.Add "champion", champName
		.Add "region", region
		.Add "role", role

	End With

	Response.Write writeJSON.JSONoutput()

	Response.End()
%> 