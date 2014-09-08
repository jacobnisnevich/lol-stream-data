<html>
<title><%=Request.QueryString("stream")%></title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400' rel='stylesheet' type='text/css'>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
</head>
<script>
	$(document).ready(function(){
		var summoner = 'TheOddOne';
		var role = 'JUNGLER';
		var region = 'na'
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
            		champID = champSelect[pick].championId;
            		(function (pick) {
	            		$.ajax({
				            url: 'https://' + region + '.api.pvp.net/api/lol/static-data/' + region + '/v1.2/champion/' + champID + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
				            dataType: 'json',
				            success: function(data) {
				            	champName = data.name.replace(/\s/g, '').replace(/'/g, '');
			            		for (var team1 = 0; team1 < 5; team1++) {
			            			if ($('#one' + (team1 + 1)).html().replace(/\s/g, '').toLowerCase() == champSelect[pick].summonerInternalName) {
				            			$("#one" + (team1 + 1) + "Img").attr("src","images/champions/" + champName + "Square.png");
				            			return;
				            		}
			            		}
			            		for (var team2 = 0; team2 < 5; team2++) {
			            			if ($('#two' + (team2 + 1)).html().replace(/\s/g, '').toLowerCase() == champSelect[pick].summonerInternalName) {
			            				$("#two" + (team2 + 1) + "Img").attr("src","images/champions/" + champName + "Square.png");
			            				return;
			            			}
			            		}
			            	}
	        			});	
					})(pick);
            	}
			}
		});

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
			<div class="statsPanel" style="width: 880px; height: 150px; margin-top: 0px;"></div>
		</div>
	</div>
</body>
</html>