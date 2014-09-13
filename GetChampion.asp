<% @LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="connect.asp" -->
<!--#include file="includes/aspJSON1.17.asp" -->
<% 
	'function that retrieves json from the open-source LoL API
	Function GetTextFromUrl(url)

		  Dim oXMLHTTP
		  Dim strStatusTest

		  Set oXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP.3.0")

		  oXMLHTTP.Open "GET", url, False
		  oXMLHTTP.setRequestHeader "X-Mashape-Key", "e8I0JpAdlpmshOA5XfxuaOkWZCGbp1nIzGsjsn0NzfhuuWX2S3"
		  oXMLHTTP.Send

		  If oXMLHTTP.Status = 200 Then

		    	GetTextFromUrl = oXMLHTTP.responseText

		  End If

	End Function

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

	Set oJSON = New aspJSON

	Do While Not rs.EOF

		summoner = rs("summoner")
		region = rs("region")

		If region = "kr" Then
			Exit Do
		End If

	    jsonstring = GetTextFromUrl("https://community-league-of-legends.p.mashape.com/api/v1.0/" + region + "/summoner/retrieveInProgressSpectatorGameInfo/" + summoner)

		'get data from LoL api based on summoner
		If Not IsNull(jsonstring) Then
			oJSON.loadJSON(jsonstring)
		End If

		'if summoner is in a game, exit loop, otherwise move on to next record
		If oJSON.data("success") <> "false" Then
			For Each player In oJSON.data("game").item("playerChampionSelections").item("array")
				Set this = oJSON.data("game").item("playerChampionSelections").item("array").item(player)
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

	'load champ img string from champion id
	jsonstring = GetTextFromUrl("https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion/" + champID + "?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643")

	If Not IsNull(jsonstring) Then
		oJSON.loadJSON(jsonstring)
	End If

	Response.Write Replace(Replace(Replace(oJSON.data("name"), " ", ""), ".", ""), "'", "")

	Response.End()
%> 