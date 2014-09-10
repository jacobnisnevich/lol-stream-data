<html>
<title>Submission Confirmation</title>
<head>
	<link rel="stylesheet" type="text/css" href="styles.css">
	<link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300' rel='stylesheet' type='text/css'>
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
</head>
<body>
	<div id="topBar" align="center" valign="center">
		<span id="logo"><a href="/lol-stream-data">LOL STREAM DATA</a></span>
		<span><a href="/lol-stream-data">All Streams</a></span>
		<span>Categories</span>
		<span><a href="contribute.asp">Contribute</a></span>
		<span>About</span>
	</div>
	<div id="content" align="center">
		<div>Your submission has been entered in the database</div>
		<div id="submission">
			<table cellspacing="10px" style="border: 1px solid;">
				<tr>
					<th>twitch</th>
					<th>summoner</th>
					<th>role</th>
					<th>region</th>
				</tr>
				<tr>
					<td><%=Request.QueryString("twitch")%></td>
					<td><%=Request.QueryString("summoner")%></td>
					<td><%=Request.QueryString("role")%></td>
					<td><%=Request.QueryString("region")%></td>
				</tr>
			</table>
		</div>
	</div>
</body>