<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Conn.asp"-->
<!--#include file="inc/md5.asp"-->
<!--#include file="inc/function.asp"-->
<%
Dim action,account,pass
action =Request.Form("action")
If action="1" Then
	account=Request.Form("account")
	pass=Request.Form("password")
	
	If account="" Or pass="" Then
		Call ShowErrorInfo("用户名称和密码必须输入，请确认！",0)
	End If
	If Not CheckNumCharOK(account) Then
		Call ShowErrorInfo("账号只能是纯英文字符或者英文字符加数字，请确认！",0)
	End If
	pass=md5(pass,32)
	Call OpenDataBase
	Set Rs=Conn.Execute("select id,userAccount,userLevel,userPass from CG_d_admin_info where userAccount='"&account&"'")
	If Not Rs.Eof Then
		If Rs("userPass")= pass Then
			Session(G_SessionPre&"_Mem_ID") 	=Rs("id")
			Session(G_SessionPre&"_Mem_Name")	=account
			Session(G_SessionPre&"_Mem_Level")	=Rs("userLevel")
			Rs.Close
			Set Rs = Nothing
			If Session(G_SessionPre&"_Mem_Level")="1" Then
				Response.Redirect("jutouscore.asp")
			ElseIf Session(G_SessionPre&"_Mem_Level")="2" Then
				Response.Redirect("adminscore.asp")
			ElseIf Session(G_SessionPre&"_Mem_Level")="3" Then
				Response.Redirect("userList.asp")
			Else
				Call ShowErrorInfo("非正常后台账号，无法进入任何管理页面!",0)
			End If
		Else
			Call ShowErrorInfo("用户名或密码错误，请重新输入!",G_Website_Dir&"/login.asp")
		End If
	Else
		Call ShowErrorInfo("您输入的账号没有注册，请重新输入!",G_Website_Dir&"/login.asp")
	End If
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>登录</title>
<link rel="stylesheet" type="text/css" href="css/base.css" />
<link rel="stylesheet" type="text/css" href="css/style.css" />
</head>

<body>
<div id="app" class="wrap">
	<div class="login-main">
    	<div class="login-tit"><a href="reg.asp">注册</a> | <a href="javascript:;" class="active">登录</a></div>
        <div class="login-con">
            <form action="" method="post">
            <input type="hidden" name="action" value="1">
            <table class="tab">
            	<tr>
                	<td width="70"><label for="account">账号：</label></td>
                    <td><input type="text" name="account" id="account" class="txt1" placeholder="请输入账号" /></td>
                </tr>
                <tr>
                	<td><label for="password">密码：</label></td>
                    <td><input type="password" name="password" id="password" class="txt1" placeholder="请输入密码" /></td>
                </tr>
                <tr>
                	<td></td>
                    <td>
                        <input type="submit" value="登录" class="btn" /> <a href="findpsd.asp" class="findpsd">找回密码</a>
                    </td>
                </tr>
            </table>
            </form>
        </div>
    </div>
</div>

</body>
</html>
