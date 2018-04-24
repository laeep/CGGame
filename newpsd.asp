<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Conn.asp"-->
<!--#include file="inc/md5.asp"-->
<!--#include file="inc/function.asp"-->
<!--#include file="inc/Session.asp"-->
<%

Dim Action,newPass1,newPass2,oldPass,account
Action=Request.Form("action")
If Action="1" Then
	account = Request.Form("account")
	oldPass = Request.Form("oldPass")
	newPass1= Request.Form("newPass1")
	newPass2= Request.Form("newPass2")
	If oldPass="" Or newPass1="" Or newPass2="" Then
		Call ShowErrorInfo("请输入所有密码后再提交！",0)
	End If
	If Not CheckNumCharOK(account) Then
		Call ShowErrorInfo("账号只能是纯英文字符或者英文字符加数字，请确认！",0)
	End If
	oldPass  =md5(oldPass,32)
	newPass1 =md5(newPass1,32)
	newPass2 =md5(newPass2,32)
	If account="" Then
		Call ShowErrorInfo("请输入账号再提交！",0)
	End If
	If newPass1 <> newPass2 Then
		Call ShowErrorInfo("您两次输入的新密码不一样，请确认！",0)
	End If
	Call OpenDataBase
	Set Rs=Conn.Execute("select id,userPass from CG_d_admin_info where userAccount='"&account&"'")
	If Not Rs.Eof Then
		If oldPass=Rs("userPass") Then
			Conn.Execute("update CG_d_admin_info set userPass='"&newPass1&"' where userAccount='"&account&"'")
		Else
			Rs.Close
			Set Rs = Nothing
			Call ShowErrorInfo("原密码输入错误，请确认！",0)
		End If
	Else
		Rs.Close
		Set Rs = Nothing
		Call ShowErrorInfo("登录超时，请重新登陆后再修改！",0)
	End If
	Call ShowErrorInfo("修改成功！",G_Website_Dir&"/login.asp")
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>修改密码</title>
<link rel="stylesheet" type="text/css" href="css/base.css" />
<link rel="stylesheet" type="text/css" href="css/style.css" />
</head>

<body>
<div id="app" class="wrap">
	<div class="login-main">
    	<div class="login-tit"><a href="javascript:;" class="active">修改密码</a></div>
        <div class="login-con">
        	<form action=""  method="post"><input type="hidden" name="action" value="1">
        	<table class="tab">
                <tr>
                	<td><label for="account">账号：</label></td>
                    <td><input type="text" id="account" name="account" class="txt1" readonly value="<%=Session(G_SessionPre&"_Mem_Name")%>" /></td>
                </tr>
                <tr>
                	<td><label for="oldPass">原密码：</label></td>
                    <td><input type="password" id="oldPass" name="oldPass" class="txt1" placeholder="请输入原密码" /></td>
                </tr>
                <tr>
                	<td><label for="newPass1">新密码：</label></td>
                    <td><input type="password" id="newPass1" name="newPass1" class="txt1" placeholder="请输入新密码" /></td>
                </tr>
                <tr>
                	<td><label for="newPass2">确认新密码：</label></td>
                    <td><input type="password" id="newPass2" name="newPass2" class="txt1" placeholder="请再次输入密码" /></td>
                </tr>
                <tr>
                	<td></td>
                    <td>
                    	<input type="submit" value="确认修改" class="btn" />
                    </td>
                </tr>
            </table>
            </form>
        </div>
    </div>
</div>

</body>
</html>
