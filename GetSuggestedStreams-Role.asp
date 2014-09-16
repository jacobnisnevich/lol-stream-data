<!--#include file="includes/aspJSON1.17.asp" -->
<!--#include file="connect.asp" -->
<%
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

	Set oJSON = New aspJSON

	With oJSON.data
		.Add "streams", oJSON.Collection()

		With oJSON.data("streams") {
			.Add 0, oJSON.Collection() 
			With .item(0)
				.Add "twitch", stream0
			End With

			.Add 1, oJSON.Collection() 
			With .item(1)
				.Add "twitch", stream1
			End With

			.Add 2, oJSON.Collection() 
			With .item(2)
				.Add "twitch", stream2
			End With

			.Add 3, oJSON.Collection() 
			With .item(3)
				.Add "twitch", stream3
			End With

			.Add 4, oJSON.Collection() 
			With .item(4)
				.Add "twitch", stream4
			End With
		}
	End With

	Response.Write oJSON.JSONoutput()
%>