<%
dim fs
set fs=Server.CreateObject("Scripting.FileSystemObject")
sourceFile="inc\Conn.asp"
targetFile="inc\Conn1.asp"
fs.MoveFile server.MapPath(sourceFile),server.MapPath(targetFile)
set fs=nothing
%>