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
	            url: 'http://jacob.nisnevich.com/lol-stream-data/GetTopStreams.asp',
	            dataType: 'json',
	            success: function(JSONdata) {
	                for (var i = 0; i < 25; i++) {
	                	(function (i) {
		                    var stream = JSONdata.streams[i];

		                    data = {
								twitch: stream.twitch,
								summoner: stream.summoner,
								champion: stream.champion,
								rank: stream.rank,
								lp: stream.lp,
								role: stream.role,
								region: stream.region
							}

							$("#tableBody").append(template(data));

							if (i == 24) {	
								// initialize datatable
								$('#loadImg').hide();
								$('#content').attr("align", "left");
								$('#streamsTable').show();
							    $('#streamsTable').DataTable( {
								    data: data
								} );
							}
						}) (i);
	                }
	            }
	        });
		});
	</script>
	<div id="topBar" align="center" valign="center">
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="allstreams.asp">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content" align="center">
		<img id="loadImg" src="images/loading.gif" style="padding: 50px"/>
		<table id="streamsTable" style="display:none">
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