<%
Sub IsLogin
	If IsNull(Session(G_SessionPre&"_Mem_ID")) Or Session(G_SessionPre&"_Mem_ID")="" Then
		Response.Write("<script>alert('你尚未登录，无法进行此操作，请先登录！');top.location="""&G_Website_Dir&"/login.asp"";</script>")
		Response.End()
	End If
End Sub 

Function JudgePower(m_PagePop)
	JudgePower=False
	'0默认值，无权限
	'1局头权限
	'2管理员权限
	'3超级权限
	Call IsLogin
	'If Session(G_SessionPre&"_Mem_ID")<>"" Then
		If CInt(Session(G_SessionPre&"_Mem_Level"))= CInt(m_PagePop) Then
			JudgePower = True
		End If
	'End If
End Function

Function Error1()
	Response.Write("<script>alert('您没有此权限，不能操作！');top.location="""&G_Website_Dir&"/login.asp""</script>")
	Response.End
End function
%>