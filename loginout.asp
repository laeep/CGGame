<!--#include file="inc/Const.asp"-->
<%
Session(G_SessionPre&"_Mem_ID") 	=""
Session(G_SessionPre&"_Mem_Name")	=""
Session(G_SessionPre&"_Mem_Level")	=""
Response.Redirect(G_Website_Dir&"/login.asp")
%>