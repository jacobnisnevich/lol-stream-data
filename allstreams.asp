<html>
<title>LoL Stream Data</title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.2/css/jquery.dataTables.min.css">
	<link rel="shortcut icon" href="logo_test-ico.ico">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300,600' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400' rel='stylesheet' type='text/css'>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<script src="http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/2.0.0-alpha.4/handlebars.min.js"></script>
	<script src="http://cdn.datatables.net/1.10.2/js/jquery.dataTables.min.js"></script>
</head>
<body>
	<script id="rowInstance" type="text/x-handlebars-template">
		<tr>
			<td><a href="player.asp?stream={{ twitch }}"> {{ twitch }}</td>
			<td>{{ summoner }}</td>
			<td>{{ champion }}</td>
			<td>{{ rank }}</td>
			<td>{{ lp }}</td>
			<td>{{ role }}</td>
			<td>{{ region }}</td>
		</tr>
	</script>
	<script>
		$(document).ready(function(){
			// initialize handlebars
		    var templateScript = $("#rowInstance").html();
			var template = Handlebars.compile (templateScript);

			// pass data to datatable
			$.ajax({
	            url: 'https://api.twitch.tv/kraken/streams?game=League+of+Legends',
	            dataType: 'jsonp',
	            success: function(dataWeGotViaJsonp) {
	                for (var i = 0; i < 25; i++) {
	                	(function (i) {
		                    $.ajax({
					            url: 'GetStreamData.asp?stream=' + dataWeGotViaJsonp.streams[i].channel.name,
					            dataType: 'json',
					            success: function(streamData) {			           
					            	if (streamData.champion != "") {
				                    	$.ajax({ 
				                    		url: 'GetRank.asp?stream=' + dataWeGotViaJsonp.streams[i].channel.name,
								            dataType: 'json',
								            success: function(rankData) {
								            	topStream = dataWeGotViaJsonp.streams[i];
												data = {
													twitch: topStream.channel.name,
													summoner: rankData.summoner,
													champion: streamData.champion,
													rank: rankData.tier + rankData.division,
													lp: rankData.lp,
													role: streamData.role,
													region: streamData.region
												}
												$("#tableBody").append(template(data));
								            }
								        });
				                    } else {
				                    	$.ajax({ 
				                    		url: 'GetRank.asp?stream=' + dataWeGotViaJsonp.streams[i].channel.name,
								            dataType: 'json',
								            success: function(rankData) {
								            	topStream = dataWeGotViaJsonp.streams[i];
												data = {
													twitch: topStream.channel.name,
													summoner: rankData.summoner,
													champion: '',
													rank: rankData.tier + rankData.division,
													lp: rankData.lp,
													role: streamData.role,
													region: streamData.region
												}
												$("#tableBody").append(template(data));
								            }
								        });
				                    }
			                    }
					        });
						}) (i);
	                }
	            }
	        });

			// initialize datatable
		    $('#streamsTable').DataTable();
		});
	</script>
	<div id="topBar" align="center" valign="center">
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="allstreams.asp">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content">
		<table id="streamsTable">
			<thead>
				<tr>
					<th>Twitch Stream</th>
					<th>Summoner Name</th>
					<th>Current Champion</th>
					<th>League of Legends Rank</th>
					<th>League Points</th>
					<th>Role</th>
					<th>Region</th>
				</tr>
			</thead>

			<tbody id="tableBody">
			</tbody>
		</table>
	</div>
</body>
</html>