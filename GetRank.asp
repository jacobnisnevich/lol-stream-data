<!--#include file="includes/aspJSON1.17.asp" -->
<!--#include file="includes/adovbs.inc" -->
<!--#include file="connect.asp" -->
<!--#include file="helpers.asp" -->
<%
    Function Convert(sIn)
        Dim oIn : Set oIn = CreateObject("ADODB.Stream")
        oIn.Open
        oIn.CharSet = "ISO-8859-1"
        oIn.WriteText sIn
        oIn.Position = 0
        oIn.CharSet = "UTF-8" 
        Convert = oIn.ReadText
        oIn.Close
    End Function

    'Get summoner name from twitch
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

	summoner = ""

	Set oJSON = New aspJSON

	'loop through record set
	Do While Not rs.EOF

		summoner = rs("summoner")
		region = rs("region")
		role = rs("role")

		If region = "kr" Then

			Exit Do

		End If

	    jsonstring = GetTextFromUrl("https://community-league-of-legends.p.mashape.com/api/v1.0/" + region + "/summoner/retrieveInProgressSpectatorGameInfo/" + summoner)

		'get data from LoL api based on summoner
		If Not IsNull(jsonstring) And Not IsEmpty(jsonstring) Then

			oJSON.loadJSON(jsonstring)

        Else 

            Exit Do

		End If

		'if summoner is in a game, exit loop, otherwise move on to next record
		If oJSON.data("success") <> "false" Then

			Exit Do
			
		Else

			rs.MoveNext

		End If

	Loop

	If summoner <> "" Then
		'Get summoner id from summoner name
		summonerID_data = GetTextFromUrl("https://" + region + ".api.pvp.net/api/lol/" + region + "/v1.4/summoner/by-name/" + summoner + "?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643")

		oJSON.loadJSON(summonerID_data)

		id = CStr(oJSON.data(Replace(LCase(summoner), " ", "")).item("id"))

		'Get league info from summoner id
		league_data = GetTextFromUrl("https://" + region + ".api.pvp.net/api/lol/" + region + "/v2.5/league/by-summoner/" + id + "/entry?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643")

		oJSON.loadJSON(league_data)

		tier = oJSON.data(id).item(0).item("tier")
		division = oJSON.data(id).item(0).item("entries").item(0).item("division")
		leaguepoints = oJSON.data(id).item(0).item("entries").item(0).item("leaguePoints")

		'Send data in JSON format

		Set writeJSON = New aspJSON

		With writeJSON.data

			.Add "success", "true"
			.Add "summoner", summoner
			.Add "id", id
			.Add "tier", tier
			.Add "division", division
			.Add "lp", leaguepoints

		End With
	Else 
		Set writeJSON = New aspJSON

		With writeJSON.data

			.Add "success", "false"

		End With
	End If

	Response.Write writeJSON.JSONoutput()

	Response.End()
%>