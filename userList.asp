<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Session.asp"-->
<%
If Not JudgePower("3") Then
	'Response.Write("dddddd")
	'Response.End()
	Call Error1()
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>用户管理</title>
<link type="text/css" href="css/index.css" rel="stylesheet" />
</head>

<body>
<div id="app" class="wrap">
	<div class="pagehead">
    	<div class="superuser">
        	账号：{{superUser}}
        </div>
        <div class="date">系统时间: <span id="date">{{ today }}</span></div>
        <div class="logout">
        	<a href="newpsd.asp">修改密码</a>&nbsp;&nbsp;
        	<a href="loginout.asp">退出</a>
        </div>
    </div>
    <br>
    <br><br>
    <div class="aa">
    	<h3>管理信息列表</h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
            	<td>序号</td>
                <td>账号</td>
                <td>权限等级</td>
            </tr>
        	<tr v-for="(item,index) in userArr">
            	<td>{{ item.id }}</td>
                <td>{{ item.ua }}</td>
                <td>
                	<select v-model="item.ul" @change="save(item.id,item.ul)">  
                      <option v-for="opt in levelArr" v-bind:value="opt.lev">  
                        {{ opt.name }}  
                      </option>  
                    </select>
                </td>
            </tr>
        </table>
    </div>
    
</div>
</body>
</html>
<script src="js/vue.min.js"></script>
<script src="js/axios.min.js"></script>
<script src="js/jquery-3.2.1.js"></script>
<script src="js/polyfill.min.js"></script>
<script src="js/common.js"></script>
<script>
"use strict";

var app = new Vue({
	el: '#app',
	data: {
		superUser: superUser,
		today: this.formatDateTime,
		now: null,
		userArr: [],
		newArr: [],
		idArr: [],
		levelArr: [{ "lev": 0, "name": '注册用户' }, { "lev": 1, "name": '局头' }, { "lev": 2, "name": '管理员' }]
	},
	methods: {
		time: function time() {
			var date = new Date();
			var y = date.getFullYear();
			var m = date.getMonth() + 1;
			m = m < 10 ? '0' + m : m;
			var d = date.getDate();
			d = d < 10 ? '0' + d : d;
			var h = date.getHours();
			h = h < 10 ? '0' + h : h;
			var minute = date.getMinutes();
			minute = minute < 10 ? '0' + minute : minute;
			var second = date.getSeconds();
			second = second < 10 ? '0' + second : second;
			this.today = y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second;
		},
		formatDateTime: function formatDateTime() {
			this.time();
			var This = this;
			setInterval(function () {
				This.time();
			}, 1000);
		},
		save: function save(x, y) {
			axios.get(ajaxUrl, {
				params: {
					ot: 101,
					id: x,
					ul: y
				}
			}).then(function (response) {
				console.log(response.data);
			});
		},
		jiazai: function jiazai() {
			var _this = this;

			this.idArr.length = 0;
			for (var i = 0; i < this.userArr.length; i++) {
				this.idArr.push(this.userArr[i].id);
			}
			axios.get(ajaxUrl, { //取排队数据
				params: {
					ot: 100
				}
			}).then(function (response) {
				//console.log(1);
				//console.log(response.data);
				for (var i = 0; i < response.data.length; i++) {
					_this.userArr.unshift(response.data[i]);
				}
				$(function () {
					//鼠标移入该行和鼠标移除该行的事件
					jQuery(".tab5 tr:gt(0)").mouseover(function () {
						jQuery(this).addClass("trover");
					}).mouseout(function () {
						jQuery(this).removeClass("trover");
					});
				});
			});
		}
	},
	mounted: function mounted() {
		var This = this;
		axios.get(ajaxUrl, {
			params: {
				ot: 1
			}
		}).then(function (response) {
			This.superUser = response.data;
		});

		axios.get(ajaxUrl, {
			params: {
				ot: 2
			}
		}).then(function (response) {
			This.now = new Date(response.data);
			This.formatDateTime();
		});

		this.jiazai();
		/*
  setInterval(()=>{
  	this.jiazai();
  },itime);
  */
	}
});
</script>
