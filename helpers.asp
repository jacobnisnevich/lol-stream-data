<% 
	'function that retrieves json from the open-source LoL API
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
%>