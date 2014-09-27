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
	<script>
		$(document).ready(function(){
			// pass data to datatable
			$.ajax({
	            url: 'http://jacob.nisnevich.com/lol-stream-data/GetTopStreams.asp',
	            dataType: 'json',
	            success: function(data) {
					$('#loadImg').hide();
					$('#content').attr("align", "left");
					$('#streamsTable').show();
				    $('#streamsTable').DataTable( {
				    	"order": [[ 0, "asc" ]],
					    "data": 			data.streams,
					    "info":     		false,
					    "iDisplayLength": 	25,
					    "columns": [
					    	{ data: 'views'},
					        { data: 'twitch' },
					        { data: 'summoner' },
					        { data: 'champion' },
					        { data: 'rank' },
					        { data: 'lp' },
					        { data: 'role' },
					        { data: 'region' },
					        { data: 'add'}
					    ],
						"aoColumnDefs": [
							{ "sType": "league-rank", "aTargets": [ 4 ] }
						]
					} );
	            }
	        });

			var ranks = [
				"",
				"BRONZE V",   "BRONZE IV",   "BRONZE III",   "BRONZE II",   "BRONZE I",
				"SILVER V",   "SILVER IV",   "SILVER III",   "SILVER II",   "SILVER I",
				"GOLD V",     "GOLD IV",     "GOLD III",     "GOLD II",     "GOLD I",
				"PLATINUM V", "PLATINUM IV", "PLATINUM III", "PLATINUM II", "PLATINUM I",
				"DIAMOND V",  "DIAMOND IV",  "DIAMOND III",  "DIAMOND II",  "DIAMOND I",
				"MASTER I",   "CHALLENGER I"
			]

			// sort functions for league rank

	        $.fn.dataTableExt.oSort['league-rank-asc']  = function(x,y) {
			    return ((ranks.indexOf(x) < ranks.indexOf(y)) ? -1 : ((ranks.indexOf(x) > ranks.indexOf(y)) ?  1 : 0));
			};
			 
			$.fn.dataTableExt.oSort['league-rank-desc'] = function(x,y) {
			    return ((ranks.indexOf(x) < ranks.indexOf(y)) ?  1 : ((ranks.indexOf(x) > ranks.indexOf(y)) ? -1 : 0));
			};
		});
	</script>
	<div id="topBar" align="center" valign="center">
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="allstreams.asp">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content" align="center" style="font-size:18px">
		<img id="loadImg" src="images/loading.gif" style="padding: 50px"/>
		<table id="streamsTable" style="display:none">
			<thead>
				<tr>
					<th></th>
					<th>Twitch Stream</th>
					<th>Summoner Name</th>
					<th>Current Champion</th>
					<th>League of Legends Rank</th>
					<th>League Points</th>
					<th>Role</th>
					<th>Region</th>
					<th>Add to DB</th>
				</tr>
			</thead>

			<tbody id="tableBody">
			</tbody>
		</table>
	</div>
</body>
</html>