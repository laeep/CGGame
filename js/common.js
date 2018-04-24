// JavaScript Document
var ajaxUrl = 'server.asp';
var superUser ="无";
function loginYZ(code){
	if(code == 1000){
		alert('你需要登录再操作');
		location.href="login.asp";
	}
	if(code == 1001){
		alert('你没有权限操作');
		return false;
	}
	
}
var itime = 1000;

var itime2 = 5000;