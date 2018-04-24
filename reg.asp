<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Conn.asp"-->
<!--#include file="inc/md5.asp"-->
<!--#include file="inc/function.asp"-->
<%
Dim action,account,password,password1,question,answer,userPass
action = Request.Form("action")
If action="1" Then
	account =Request.Form("account")
	password =Request.Form("password")
	password1 =Request.Form("password1")
	question =Request.Form("question")
	answer =Request.Form("answer")
	If account="" or password=""  Then
		Call ShowErrorInfo("账号和密码均必须输入，请确认！",0)
	End If
	If question="" Then
		Call ShowErrorInfo("请选择一个密保问题！",0)
	End If
	If answer=""  Then
		Call ShowErrorInfo("请输入您的密保答案！",0)
	End If
	If Not CheckNumCharOK(account) Then
		Call ShowErrorInfo("账号只能是纯英文字符或者英文字符加数字，请确认！",0)
	End If
	If password1 <> password Then
		Call ShowErrorInfo("您两次输入的密码不一样，请确认！",0)
	End If
	
	question=myReplace(question)
	answer=myReplace(answer)
	userPass = md5(password,32)
	
	Call OpenDataBase
	Set Rs=Conn.Execute("select id from CG_d_admin_info where userAccount='"&account&"'")
	If Not Rs.Eof Then
		Call ShowErrorInfo("此账号已经存在，请更换账号注册！",0)
	End If
	Rs.Close
	Set Rs = Nothing
	Conn.Execute("insert into CG_d_admin_info(userAccount,userPass,userQuestion,userAnswer) values('"&account&"','"&userPass&"','"&question&"','"&answer&"')")
	Call connClose
	Call ShowErrorInfo("注册成功，请登录！","login.asp")
	
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>注册</title>
<link rel="stylesheet" type="text/css" href="css/base.css" />
<link rel="stylesheet" type="text/css" href="css/style.css" />
</head>

<body>
<div id="app" class="wrap">
	<div class="login-main">
    	<div class="login-tit"><a href="javascript:;" class="active">注册</a> | <a href="login.asp">登录</a></div>
        <div class="login-con">
        	<form action="" method="post">
            <input type="hidden" name="action" value="1">
        	<table class="tab">
            	<tr>
                	<td width="70"><label for="account">账号：</label></td>
                    <td><input type="text" name="account" id="account" class="txt1" placeholder="账号只能是英文和数字" /></td>
                </tr>
                <tr>
                	<td><label for="password">密码：</label></td>
                    <td><input type="password" name="password" id="password" class="txt1" placeholder="请输入密码" /></td>
                </tr>
                <tr>
                	<td><label for="password1">确认密码：</label></td>
                    <td><input type="password" name="password1" id="password1" class="txt1" placeholder="请再次输入密码" /></td>
                </tr>
                <tr>
                	<td><label for="question">密保问题：</label></td>
                    <td>
                    	<select name="question" id="question" class="txt2" >
                          <option value="">请选择你的密保问题</option>
                          <option value="您的出生地是哪里？">您的出生地是哪里？</option>
                          <option value="您母亲的姓名是？">您母亲的姓名是？</option>
                          <option value="您父亲的姓名是？">您父亲的姓名是？</option>
                          <option value="您配偶的姓名是？">您配偶的姓名是？</option>
                          <option value="自定义神秘答案？">自定义神秘答案？</option>
                        </select>
                    </td>
                </tr>
                <tr>
                	<td><label for="answer">密保答案：</label></td>
                    <td><input type="text" name="answer" id="answer" class="txt1" placeholder="请输入答案" /></td>
                </tr>
                <tr>
                	<td></td>
                    <td>
                    	<input type="submit" value="注册" class="btn" />
                    </td>
                </tr>
            </table>
            </form>
        </div>
    </div>
</div>

</body>
</html>
