<%
dim fs
set fs=Server.CreateObject("Scripting.FileSystemObject")
sourceFile="inc\Conn1.asp"
targetFile="inc\Conn.asp"
fs.MoveFile server.MapPath(sourceFile),server.MapPath(targetFile)
set fs=nothing
%>