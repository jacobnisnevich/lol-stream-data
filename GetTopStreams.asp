<!--#include file="includes/aspJSON1.17.asp" -->
<!--#include file="helpers.asp" -->
<%
	Server.ScriptTimeout = 200

	Set inJSON = new aspJSON
	Set outJSON = new aspJSON

	jsonstring = GetTextFromUrl("https://api.twitch.tv/kraken/streams?game=League+of+Legends&limit=50")
	inJSON.loadJSON(jsonstring)

	With outJSON.data
		.Add "streams", outJSON.Collection()

		With outJSON.data("streams")
			For i = 0 To 49

				twitch = inJSON.data("streams").item(i).item("channel").item("name")
				
				'Rank data

				jsonstring = GetTextFromUrl("http://jacob.nisnevich.com/lol-stream-data/GetRank.asp?stream=" + twitch)
                
                If IsEmpty(jsonstring) Then
                    .Add i, outJSON.Collection()
					With .item(i)
						.Add "views", CStr(i + 1)
						.Add "twitch", "<b style=""line-height:normal""><a href=""player.asp?stream=" + twitch + """>" + twitch + "</a></b>"
						.Add "summoner", ""
						.Add "champion", ""
						.Add "rank", ""
						.Add "lp", ""
						.Add "role", ""
						.Add "region", ""
						.Add "add", "<b style=""line-height:normal""><a href=""contribute.asp?stream=" + twitch + """>Contribute</a></b>"
					End With
                Else
				    inJSON.loadJSON(jsonstring)

				    If inJSON.data("success") = "true" Then
					    summoner = inJSON.data("summoner")
					    rank = inJSON.data("tier") + " " + inJSON.data("division")
					    lp = inJSON.data("lp")

					    'Stream data

					    jsonstring = GetTextFromUrl("http://jacob.nisnevich.com/lol-stream-data/GetStreamData.asp?stream=" + twitch)

					    inJSON.loadJSON(jsonstring)

					    champion = inJSON.data("champion")
					    role = inJSON.data("role")
					    region = inJSON.data("region")

					    .Add i, outJSON.Collection()
					    With .item(i)
					    	.Add "views", CStr(i + 1)
						    .Add "twitch", "<b style=""line-height:normal""><a href=""player.asp?stream=" + twitch + """>" + twitch + "</a></b>"
						    .Add "summoner", summoner
						    .Add "champion", champion
						    .Add "rank", rank
						    .Add "lp", lp
						    .Add "role", role
						    .Add "region", region
						    .Add "add", "<b style=""line-height:normal""><a href=""contribute.asp?stream=" + twitch + """>Contribute</a></b>"
					    End With
				    Else 
					    .Add i, outJSON.Collection()
					    With .item(i)
					    	.Add "views", CStr(i + 1)
						    .Add "twitch", "<b style=""line-height:normal""><a href=""player.asp?stream=" + twitch + """>" + twitch + "</a></b>"
						    .Add "summoner", ""
						    .Add "champion", ""
						    .Add "rank", ""
						    .Add "lp", ""
						    .Add "role", ""
						    .Add "region", ""
						    .Add "add", "<b style=""line-height:normal""><a href=""contribute.asp?stream=" + twitch + """>Contribute</a></b>"
					    End With
				    End If
                End If
			Next
		End With
	End With

	Response.Write outJSON.JSONoutput()
%>