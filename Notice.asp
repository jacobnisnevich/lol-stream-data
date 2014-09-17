<!--#include file="includes/aspJSON1.17.asp" -->
<%
	Set oJSON = New aspJSON

	With oJSON.data

		.Add "status", "inactive"
		.Add "message", "Current game statistics are temporarily unavailable due to issues with the in-game API"

	End With

	Response.Write oJSON.JSONoutput()
%>