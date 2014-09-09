<html>
<title><%=Request.QueryString("stream")%></title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400' rel='stylesheet' type='text/css'>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
</head>
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
	myConn.open("Driver={MySQL ODBC 3.51 Driver};SERVER=MySQLC6.webcontrolcenter.com;DATABASE=alex;UID=alex;PWD=dbREh1FKeO0Iea;Port=3306")
	set rs = Server.CreateObject("ADODB.recordset")

    set command = Server.CreateObject("ADODB.Command")
	command.CommandText = "SELECT * FROM lsd_streams WHERE twitch = ?"
    command.CommandType = 1 'adCmdText
    command.ActiveConnection = myConn

    set invoiceNumParam = command.CreateParameter("@twitch", 200, &H0001, 255, twitch)
    command.Parameters.Append invoiceNumParam

    'set recordset rs to SQL command output
	Set rs = command.Execute()

	Set oJSON = New aspJSON

	'loop through record set
	Do While Not rs.EOF

		summoner = rs("summoner")
		region = rs("region")
		role = rs("role")

        jsonstring = GetTextFromUrl("https://community-league-of-legends.p.mashape.com/api/v1.0/" + region + "/summoner/retrieveInProgressSpectatorGameInfo/" + summoner)

		'get data from LoL api based on summoner
		oJSON.loadJSON(jsonstring)

		'if summoner is in a game, exit loop, otherwise move on to next record
		If oJSON.data("success") <> "false" Then

			Exit Do
			
		Else

			rs.MoveNext

		End If

	Loop

%>

<script>
	$(document).ready(function(){
		var summoner = '<%=summoner%>';
		var role = '<%=role%>';
		var region = '<%=region%>'
		$("#currentRegion").html(region);
        var id = getSummonerID(summoner, region);
        
        $.ajax({
            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.4/summoner/by-name/' + summoner + '?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
            dataType: 'json',
            success: function(dataWeGotViaJsonp) {
            	summoner = summoner.replace(/\s/g, '').toLowerCase();
            	id = dataWeGotViaJsonp[summoner].id;
		        $.ajax({
		            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.5/league/by-summoner/' + id + '/entry?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
		            dataType: 'json',
		            success: function(newData) {
		                var division = newData[id][0].entries[0].division;
		                var tier = newData[id][0].tier;
		                var leaguename = newData[id][0].name;
		                var rank = tier + ' ' + division;
		                var text = role + ' | <b>' + rank + '</b>';
		                var leaguepoints = newData[id][0].entries[0].leaguePoints + ' LP';
		                $('#divisionRank').html(text);
		                $('#rankInfo').html(rank);
		                $('#rankLP').html(leaguepoints);
		                $('#rankLeague').html(leaguename);
		                $("#rankImg").attr("src","images/divisions/" + tier + "_" + numeralToNum(division) + ".png");
		            }
		        });
			}
        });

		$.ajax({
			url: 'https://community-league-of-legends.p.mashape.com/api/v1.0/' + region + '/summoner/retrieveInProgressSpectatorGameInfo/' + summoner,
			dataType: 'json',
			headers: {"X-Mashape-Authorization" : "ZtLlNdZge6mshmy7fLdhxNt8YfP2p1FRaJ4jsn2YXW1NJdCqnc"},
			success: function(dataWeGotViaJsonp) {
            	console.log(dataWeGotViaJsonp);          	
            	firstTeam = dataWeGotViaJsonp.game.teamOne.array;
            	secondTeam = dataWeGotViaJsonp.game.teamTwo.array;
            	for (var i = 0; i < 5; i++) {
            		$('#one' + (i + 1)).html(firstTeam[i].summonerName);
            		$('#two' + (i + 1)).html(secondTeam[i].summonerName);
            	}
            	champSelect = dataWeGotViaJsonp.game.playerChampionSelections.array;
            	for (var pick = 0; pick < 10; pick++) {
            		(function (pick) {
	            		champID = champSelect[pick].championId;
	            		$.ajax({
				            url: 'https://' + region + '.api.pvp.net/api/lol/static-data/' + region + '/v1.2/champion/' + champID + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
				            dataType: 'json',
				            success: function(data) {
				            	champName = data.name.replace(/\s/g, '').replace(/'/g, '');
			            		for (var team1 = 0; team1 < 5; team1++) {
			            			(function (team1) {
			            				if ($('#one' + (team1 + 1)).html().replace(/\s/g, '').toLowerCase() == champSelect[pick].summonerInternalName) {
					            			$("#one" + (team1 + 1) + "Img").attr("src","images/champions/" + champName + "Square.png");

					            			if (summoner.replace(/\s/g, '').toLowerCase() == $('#one' + (team1 + 1)).html().replace(/\s/g, '').toLowerCase()) {
					            				$("#currentChampId").html(champSelect[pick].championId);
					            				$('#one' + (team1 + 1)).html('<b>' + $('#one' + (team1 + 1)).html() + '</b>')
					            			}
					            		}
					            	})(team1);
			            		}
			            		for (var team2 = 0; team2 < 5; team2++) {
			            			(function (team2) {
				            			if ($('#two' + (team2 + 1)).html().replace(/\s/g, '').toLowerCase() == champSelect[pick].summonerInternalName) {
				            				$("#two" + (team2 + 1) + "Img").attr("src","images/champions/" + champName + "Square.png");

				            				if (summoner.replace(/\s/g, '').toLowerCase() == $('#two' + (team2 + 1)).html().replace(/\s/g, '').toLowerCase()) {
					            				$("#currentChampId").html(champSelect[pick].championId);
					            				$('#two' + (team2 + 1)).html('<b>' + $('#two' + (team2 + 1)).html() + '</b>')
					            			}
					            		}
			            			})(team2);
			            		}
			            	}
	        			});	
					})(pick);
            	}
			}
		});

		updateChampStats();

		update();
    })

	function getChampion(region, id) {
		$.ajax({
            url: 'https://' + region + '.api.pvp.net/api/lol/static-data/' + region + '/v1.2/champion/' + id + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
            dataType: 'json',
            success: function(data) {
                return data.name.toString();
            }
        });
	}

	function getSummonerID(summoner, region) {
		$.ajax({
            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.4/summoner/by-name/' + summoner + '?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
            dataType: 'json',
            success: function(dataWeGotViaJsonp) {
            	summoner = summoner.replace(/\s/g, '').toLowerCase();
		        $('#currentSummId').html(dataWeGotViaJsonp[summoner].id);
                return dataWeGotViaJsonp[summoner].id;
            }
        });
	}

	function updateRank(summoner, region, id) {
		$.ajax({
            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.4/summoner/by-name/' + summoner + '?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
            dataType: 'json',
            success: function(dataWeGotViaJsonp) {
            	summoner = summoner.replace(/\s/g, '').toLowerCase();
            	id = dataWeGotViaJsonp[summoner].id;

		        $.ajax({
		            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.5/league/by-summoner/' + id + '/entry?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
		            dataType: 'json',
		            success: function(newData) {
		                var division = newData[id][0].entries[0].division;
		                var tier = newData[id][0].tier;
		                var leaguename = newData[id][0].name;
		                var rank = tier + ' ' + division;
		                var text = role + ' | <b>' + rank + '</b>';
		                var leaguepoints = newData[id][0].entries[0].leaguePoints + ' LP';

		                $('#divisionRank').html(text);
		                $('#rankInfo').html(rank);
		                $('#rankLP').html(leaguepoints);
		                $('#rankLeague').html(leaguename);
		                $("#rankImg").attr("src","images/divisions/" + tier + "_" + numeralToNum(division) + ".png");

		                window.setTimeout(updateRank(region, id), 3000);
		            }
		        });
			}
        });
	}

	function updateChampStats() {
		var summId = $("#currentSummId").html();
		var champId = $("#currentChampId").html();
		var region = $("#currentRegion").html();

		if (summId != undefined && champId != undefined && region != undefined && champId != "" && champId != "") {
			$.ajax({
	            url: 'https://' + region + '.api.pvp.net/api/lol/static-data/' + region + '/v1.2/champion/' + champId + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
	            dataType: 'json',
	            success: function(data) {
	            	var champName = data.name.replace(/\s/g, '').replace(/'/g, '');
	            	$("#currentChampName").html(champName);

	            	$.ajax({
			            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.3/stats/by-summoner/' + summId + '/ranked?season=SEASON4&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
			            dataType: 'json',
			            success: function(data) {
			                champs = data.champions;

			                for (var i = 0; i < champs.length; i++) {
			                	(function (i) {
			                	if (champs[i].id == champId) {
			                		$("#currentChampImg").attr("src","images/champions/" + champName + "Square.png");

			                		$("#champGames").html("Games played: " + champs[i].stats.totalSessionsPlayed);
									$("#champWins").html("Games won: " + champs[i].stats.totalSessionsWon);
									$("#champLosses").html("Games lost: " + champs[i].stats.totalSessionsLost);

									$("#champAverageKDA").html("Average KDA: " + (champs[i].stats.totalChampionKills/champs[i].stats.totalSessionsPlayed).toFixed(1) + "/" + (champs[i].stats.totalDeathsPerSession/champs[i].stats.totalSessionsPlayed).toFixed(1) + "/" + (champs[i].stats.totalAssists/champs[i].stats.totalSessionsPlayed).toFixed(1));
									$("#champAverageGold").html("Average Gold: " + Math.round((champs[i].stats.totalGoldEarned/champs[i].stats.totalSessionsPlayed)));
									$("#champAverageCS").html("Average Minion Kills: " + Math.round((champs[i].stats.totalMinionKills/champs[i].stats.totalSessionsPlayed)));

									$("#champTriples").html("Triple kills: " + champs[i].stats.totalTripleKills);
									$("#champQuadras").html("Quadra kills: " + champs[i].stats.totalQuadraKills);
									$("#champPentas").html("Penta kills: " + champs[i].stats.totalPentaKills);
			                	}
			                	})(i);
			                }

			                window.setTimeout(updateChampStats, 3000);
			            }
			        });
	            }
			});
		} else {
			window.setTimeout(updateChampStats, 1000);
		}
	}

	function update() {
		$.ajax({
            url: 'https://api.twitch.tv/kraken/streams/<%=Request.QueryString("stream")%>',
            dataType: 'jsonp',
            success: function(dataWeGotViaJsonp) {
                var text = '';
                text = '<%=Request.QueryString("stream")%>' + ' | ' + dataWeGotViaJsonp.stream.viewers + ' viewers';
                $('#streamTitle').html(text);
                window.setTimeout(update, 3000);
            }
        });
	}

	function numeralToNum (roman) {
		switch (roman) {
			case "I":
				return 1;
				break;
			case "II":
				return 2;
				break;
			case "III":
				return 3;
				break;
			case "IV":
				return 4;
				break;
			case "V":
				return 5;
				break;	
		}
	}
</script>
<body>
	<div id="topBar" align="center" valign="center">
		<span id="logo">LOL STREAM DATA</span>
		<span>All Streams</span>
		<span>Categories</span>
		<span><a href="contribute.html">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content">
		<div id="streamDescription">
			<span id="streamTitle"><%=Request.QueryString("stream")%></span>
			<span id="divisionRank"></span>
		</div>
		<div id="stream">
			<object type="application/x-shockwave-flash" height="540" width="900" id="live_embed_player_flash" data="http://www.twitch.tv/widgets/live_embed_player.swf?channel={CHANNEL}"  bgcolor="#000000">
				<param  name="allowFullScreen" value="true" />
				<param  name="allowScriptAccess" value="always" />
				<param  name="allowNetworking" value="all" />
				<param  name="movie" value="http://www.twitch.tv/widgets/live_embed_player.swf" />
				<param  name="flashvars" value="hostname=www.twitch.tv&channel=<%=Request.QueryString("stream")%>&auto_play=true" />
			</object>
		</div>
		<div id="stats">
			<div class="statsPanel">
				<div align="center"><img id="rankImg" src=""></div>
				<div id="rankLeague"></div>
				<div id="rankInfo"></div>
				<div id="rankLP"></div>
			</div> 
			<div class="statsPanel" style="width:580px">
				<div id="currentGameTitle" align="center">Game in Progress</div>
				<div id="currentGame">
					<div id="teamOne" align="left">
						<div class="player"><img id="one1Img"><span id="one1"></span></div>
						<div class="player"><img id="one2Img"><span id="one2"></span></div>
						<div class="player"><img id="one3Img"><span id="one3"></span></div>
						<div class="player"><img id="one4Img"><span id="one4"></span></div>
						<div class="player"><img id="one5Img"><span id="one5"></span></div>
					</div>
					<div id="teamTwo" align="right">
						<div class="player"><span id="two1"></span><img id="two1Img"></div>
						<div class="player"><span id="two2"></span><img id="two2Img"></div>
						<div class="player"><span id="two3"></span><img id="two3Img"></div>
						<div class="player"><span id="two4"></span><img id="two4Img"></div>
						<div class="player"><span id="two5"></span><img id="two5Img"></div>
					</div>
				</div>
			</div>
			<div class="statsPanel" style="width: 880px; height: 155px; margin-top: 0px;">
				<div id="currentRegion" style="display:none"></div>
				<div id="currentSummId" style="display:none"></div>
				<div id="currentChampId" style="display:none"></div>
				<div>
					<div id="currentChamp">
						<img id="currentChampImg"></img>
					</div>
					<div class="currentChampStatsPanels" align="center" style="padding:19px 6px">
						<div style="font-size: 19px; padding: 0px;">2014 Season Stats</div>
						<div style="font-weight:normal; padding: 2px;"><b><%=summoner%></b> as</div>
						<div id="currentChampName" style="padding: 0px;"></div>
					</div>
					<div class="currentChampStatsPanels">
						<div id="champGames"></div>
						<div id="champLosses"></div>
						<div id="champWins"></div>
					</div>
					<div class="currentChampStatsPanels">
						<div id="champAverageKDA"></div>
						<div id="champAverageGold"></div>
						<div id="champAverageCS"></div>
					</div>	
					<div class="currentChampStatsPanels">
						<div id="champTriples"></div>
						<div id="champQuadras"></div>
						<div id="champPentas"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>