<!--#include file="includes/aspJSON1.17.asp" -->
<%
	Set oJSON = New aspJSON

	With oJSON.data

		.Add "status", "active"
		.Add "message", "Current game statistics are temporarily unavailable due to issues with the League of Legends spectator mode."

	End With

	Response.Write oJSON.JSONoutput()
%>