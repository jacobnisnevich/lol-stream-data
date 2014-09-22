<html>
<title><%=Request.QueryString("stream")%></title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300,600' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400' rel='stylesheet' type='text/css'>
	<link rel="shortcut icon" href="logo_test-ico.ico">
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<script src="http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/2.0.0-alpha.4/handlebars.min.js"></script>
</head>
<!--#include file="includes/aspJSON1.17.asp" -->
<!--#include file="connect.asp" -->
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

%>

<script id="streamSuggestion" type="text/x-handlebars-template">
	<div class="suggestion">
		<span><img src="{{ img }}" style="{{ imgStyle }}"/></span>
		<span style="{{ textStyle }}"><a href="/lol-stream-data/player.asp?stream={{ stream }}">{{ stream }}</a></span>
		<span style="float:right">{{ viewers }} viewers</span>
	</div>
</script>

<script>
	$(document).ready(function(){
		var templateScript = $("#streamSuggestion").html();
		var template = Handlebars.compile (templateScript);

		$("#rank").hide();
		$("#contributeFormDiv").hide();

		var summoner = '<%=summoner%>';
		var role = '<%=role%>';
		var region = '<%=region%>'
		$("#currentRegion").html(region);
        var id = getSummonerID(summoner, region);

        var name = "#topBar";
		var menuYloc = null;

		var roleCount = 0;
		var regionCount = 0;

		$.ajax({
            url: 'https://api.twitch.tv/kraken/streams?game=League+of+Legends',
            dataType: 'jsonp',
            success: function(dataWeGotViaJsonp) {
                for (var i = 0; i < 50; i++) {
                	(function (i) {
	                    $.ajax({
				            url: 'GetStreamData.asp?stream=' + dataWeGotViaJsonp.streams[i].channel.name,
				            dataType: 'json',
				            success: function(streamData) {
				            	if (roleCount == 5) {
				            		return;
				            	}
				            	else {
					            	topStream = dataWeGotViaJsonp.streams[i];
					            	if (streamData.role == role) {
					            		if (streamData.champion != "") {
						            		data = {
						            			stream: topStream.channel.name,
						            			img: 'images/champions/' + streamData.champion + 'Square.png',
						            			imgStyle: 'width:24px; height:24px; float: left; padding: 0px 5px',
						            			textStyle: '',
						            			viewers: topStream.viewers
						            		};
						            	} else {
						            		data = {
						            			stream: topStream.channel.name,
						            			img: '',
						            			imgStyle: '',
						            			textStyle: 'padding-left: 30px',
						            			viewers: topStream.viewers
						            		};
						            	}
					            		roleCount++;
					            		$("#suggestRole").append(template(data));
						            }
						        }
		                    }
				        });
					}) (i);
                }
            }
        });

		$.ajax({
            url: 'https://api.twitch.tv/kraken/streams?game=League+of+Legends',
            dataType: 'jsonp',
            success: function(dataWeGotViaJsonp) {
                for (var i = 0; i < 50; i++) {
                	(function (i) {
	                    $.ajax({
				            url: 'GetStreamData.asp?stream=' + dataWeGotViaJsonp.streams[i].channel.name,
				            dataType: 'json',
				            success: function(streamData) {			 
				            	if (regionCount == 5) {
				            		return;
				            	}
				            	else {          
					            	topStream = dataWeGotViaJsonp.streams[i];
					            	if (streamData.region == region) {
					            		if (streamData.champion != "") {
						            		data = {
						            			stream: topStream.channel.name,
						            			img: 'images/champions/' + streamData.champion + 'Square.png',
						            			imgStyle: 'width:24px; height:24px; float: left; padding: 0px 5px',
						            			textStyle: '',
						            			viewers: topStream.viewers
						            		};
						            	} else {
						            		data = {
						            			stream: topStream.channel.name,
						            			img: '',
						            			imgStyle: '',
						            			textStyle: 'padding-left: 30px',
						            			viewers: topStream.viewers
						            		};
						            	}
					            		regionCount++;
					            		$("#suggestRegion").append(template(data));
						            }
						        }
		                    }
				        });
					}) (i);
                }
            }
        });

		window.setInterval(function() {
	        if (summoner == "") {
				$("#contributeFormDiv").show();
			}
			else {
		        $.ajax({
		            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.4/summoner/by-name/' + summoner + '?api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
		            dataType: 'json',
		            success: function(dataWeGotViaJsonp) {
		            	summoner = summoner.replace(/\s/g, '').toLowerCase();
		            	id = dataWeGotViaJsonp[summoner].id;
		            	$("#rank").show();
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
				            },
				            error: function(xhr, textStatus, errorThrown) {
				            	$('#rankLeague').html('Summoner service unavailable');
				            }
				        });
					}
		        });
			}
		}, 5000);

		getGameStats(region, summoner)
		window.setInterval(function() {
			getGameStats(region, summoner)
		}, 150000);

        $.ajax({
			url: 'Notice.asp',
			dataType: 'json',
			success: function(notice) {
				$('#noticeText').empty();
                if (notice.status == "active") {
                	$('#notice').toggle("slide");
                	$('#noticeText').html(notice.message);
                	$('#noticeClose').show();
                }
			}
		});

		$('#noticeClose').click(function() {
			$('#notice').toggle("slide");
			$('#noticeClose').hide();
		});

		updateChampStats();
		window.setInterval(function() {
			updateChampStats();
		}, 5000);

		update();
    })

	function getGameStats(region, summoner) {
		if (region != "kr") {
			$.ajax({
				url: 'https://community-league-of-legends.p.mashape.com/api/v1.0/' + region + '/summoner/retrieveInProgressSpectatorGameInfo/' + summoner,
				dataType: 'json',
				headers: {"X-Mashape-Authorization" : "ZtLlNdZge6mshmy7fLdhxNt8YfP2p1FRaJ4jsn2YXW1NJdCqnc"},
				success: function(dataWeGotViaJsonp) {
	            	console.log(dataWeGotViaJsonp);
	            	if (dataWeGotViaJsonp.success == "false") {
	            		$('#currentGameTitle').html('No games in progress found');
		            	$('#currentGameTitle').css("font-weight", "bold");
		            	$('#currentGameTitle').css("padding", "25px");
		            	$('#currentGame').hide();
		            	return;
	            	}
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
					            url: 'https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion/' + champID + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
					            dataType: 'json',
					            success: function(data) {
					            	champName = data.name.replace(/\s/g, '').replace(/'/g, '').replace(/\./g, '');
				            		for (var team1 = 0; team1 < 5; team1++) {
				            			(function (team1) {
				            				if ($('#one' + (team1 + 1)).html().replace(/\s/g, '').toLowerCase() == champSelect[pick].summonerInternalName) {
						            			$("#one" + (team1 + 1) + "Img").attr("src","images/champions/" + champName + "Square.png");

						            			if (summoner.replace(/\s/g, '').toLowerCase() == $('#one' + (team1 + 1)).html().replace(/\s/g, '').toLowerCase()) {
						            				$("#currentChampId").html(champSelect[pick].championId);
						            				$('#one' + (team1 + 1)).html('<b style="line-height: 0px;">' + $('#one' + (team1 + 1)).html() + '</b>')
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
						            				$('#two' + (team2 + 1)).html('<b style="line-height: 0px;">' + $('#two' + (team2 + 1)).html() + '</b>')
						            			}
						            		}
				            			})(team2);
				            		}
				            	}
		        			});	
						})(pick);
	            	}
				},
	            error: function(xhr, textStatus, errorThrown) {
	            	$('#currentGameTitle').html('No games in progress found');
	            	$('#currentGame').hide();
	            	$('#currentGameTitle').css("font-weight", "bold");
	            	$('#currentGameTitle').css("padding", "25px");
	            }
			});
		} else {
			$('#currentGameTitle').html('The Korean region is currently unsupported');
        	$('#currentGameTitle').css("font-weight", "bold");
        	$('#currentGameTitle').css("padding", "25px");
        	$('#currentGame').hide();
		}
	}

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

	function updateChampStats() {
		var summId = $("#currentSummId").html();
		var champId = $("#currentChampId").html();
		var region = $("#currentRegion").html();

		if (summId != undefined && champId != undefined && region != undefined && champId != "" && champId != "") {
			$.ajax({
	            url: 'https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion/' + champId + '?champData=blurb&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
	            dataType: 'json',
	            success: function(data) {
	            	var champName = data.name.replace(/\s/g, '').replace(/'/g, '');
	            	$("#currentChampName").html(champName);

	            	$.ajax({
			            url: 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v1.3/stats/by-summoner/' + summId + '/ranked?season=SEASON4&api_key=5b1c5bb8-e188-4c00-b733-b49c18d56643',
			            dataType: 'json',
			            success: function(data) {
			                champs = data.champions;
			                $('#championError').hide();
			                $('#currentChampDataComplete').show();

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
			            },
			            error: function(xhr, textStatus, errorThrown) {
			            	$('#currentChampDataComplete').hide();
			            	$('#championError').show();
			            	$('#championError').html('No champion data found for this summoner');
			            	$('#championError').css("font-weight", "bold");
			            	$('#championError').css("padding", "25px");
			            }
			        });
	            }
			});
		} else {
			$('#currentChampDataComplete').hide();
			$('#championError').show();
        	$('#championError').html('No champion data found for this summoner');
        	$('#championError').css("font-weight", "bold");
        	$('#championError').css("padding", "25px");
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
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="/lol-stream-data">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="suggested">
		<div class="suggestedCategory" id="suggestRole">
			<div class="suggestedTitle">Top streamers with the same role:</div>
		</div>
		<div class="suggestedCategory" id="suggestRegion">
			<div class="suggestedTitle">Top streamers in the same region:</div>
		</div>
	</div>
	<div id="chat">
		<iframe frameborder="0" scrolling="no" id="chat_embed" src="http://twitch.tv/chat/embed?channel=<%=Request.QueryString("stream")%>&amp;popout_chat=true" height="910px" width="473px"></iframe>
	</div>
	<div id="content">
		<div id="notice">
			<span id="noticeClose">x</span>
			<span id="noticeText">Current game statistics are currently unavailable due to issues with the League of Legends spectator mode.</span>
		</div>
		<div id="streamDescription">
			<span id="streamTitle"><%=Request.QueryString("stream")%></span>
			<span id="divisionRank"></span>
		</div>
		<div id="stream">
			<object type="application/x-shockwave-flash" height="540" width="900" id="live_embed_player_flash" data="http://www.twitch.tv/widgets/live_embed_player.swf?channel=<%=Request.QueryString("stream")%>"  bgcolor="#000000">
				<param  name="allowFullScreen" value="true" />
				<param  name="allowScriptAccess" value="always" />
				<param  name="allowNetworking" value="all" />
				<param  name="movie" value="http://www.twitch.tv/widgets/live_embed_player.swf" />
				<param  name="flashvars" value="hostname=www.twitch.tv&channel=<%=Request.QueryString("stream")%>&auto_play=true" />
			</object>
		</div>
		<div id="stats">
			<div class="statsPanel">
				<div id="rank">
					<div align="center"><img id="rankImg" src=""></div>
					<div id="rankLeague"></div>
					<div id="rankInfo"></div>
					<div id="rankLP"></div>
				</div>
				<div id="contributeFormDiv">
					<form action="contribute_submit.asp" method="post">
						<div style="width:285px">
							<div class="contributeForm">
								<span>Twitch Username</span>
								<input type="text" name="twitch" value="<%= Request.QueryString("stream") %>" style="width: 135px;"/>
							</div>
							<div class="contributeForm">
								<span>Summoner Name</span>
								<input type="text" name="summoner" style="width: 135px;"/>
							</div>
							<div class="contributeForm">
								<span>Role</span>
								<select name="role" style="width: 135px;">
									<option value="TOP">Top Lane</option>
									<option value="JUNGLER">Jungle</option>
									<option value="MID">Mid Lane</option>
									<option value="ADC">ADC</option>
									<option value="SUPPORT">Support</option>
									<option value="FILL">Fill</option>
								</select>
							</div>
							<div class="contributeForm">
								<span>Region</span>
								<select name="region" style="width: 135px;">
									<option value="br">BR</option>
									<option value="eune">EUNE</option>
									<option value="euw">EUW</option>
									<option value="kr">KR</option>
									<option value="lan">LAN</option>
									<option value="las">LAS</option>
									<option value="na">NA</option>
									<option value="oce">OCE</option>
									<option value="ru">RU</option>
									<option value="tr">TR</option>
								</select>
							</div>
							<div class="contributeForm">
								<button type="submit" name="submit" class="button" style="margin-left: 50px;">Submit to Database</button>
							</div>
						</div>
					</form>
				</div>
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
				<div id="championError" style="display:none" align="center"></div>
				<div id="currentChampDataComplete">
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