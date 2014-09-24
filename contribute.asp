<html>
<title>Contribute</title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link rel="shortcut icon" href="logo_test-ico.ico">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400' rel='stylesheet' type='text/css'>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
</head>
<body>
	<div id="topBar" align="center" valign="center">
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="allstreams.asp">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content" align="center">
		<div id="contributeFormDiv">
			<form action="contribute_submit.asp" method="post">
				<div style="width:400px">
					<div class="contributeForm">
						<span>Twitch Username</span>
						<input type="text" name="twitch" value="<%= Request.QueryString("stream") %>"/>
					</div>
					<div class="contributeForm">
						<span>Summoner Name</span>
						<input type="text" name="summoner"/>
					</div>
					<div class="contributeForm">
						<span>Role</span>
						<select name="role" >
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
						<select name="region" >
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
						<button type="submit" name="submit" class="button">Submit to Database</button>
					</div>
				</div>
			</form>
		</div>
	</div>
</body>