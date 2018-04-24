<%
Sub OpenDataBase
	Err.Clear
	'On Error Resume Next
	Set Conn = Server.CreateObject("ADODB.Connection")
	ConnStr="Provider=SQLOLEDB.1;Password=huancom12;Persist Security Info=True;User ID=qds214529287;Initial Catalog=qds214529287_db;Data Source=qds214529287.my3w.com"
	Conn.Open ConnStr
	If Err.Number<>0 Then
		Response.Write "<center>数据库连接错误</center>"
		Response.End
	End If
End Sub


'关闭数据库连接-
Sub connClose()
	If TypeName(Conn)="Connection" Then
		conn.close
		set conn = nothing
	end if 
End Sub
%>