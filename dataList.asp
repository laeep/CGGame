<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Session.asp"-->
<%
If Not JudgePower("2") Then
	'Response.Write("dddddd")
	'Response.End()
	Call Error1()
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>历史数据查询</title>
<link type="text/css" href="css/index.css" rel="stylesheet" />
<link type="text/css" href="css/jquery.datetimepicker.css" rel="stylesheet" />
<style>
.page-bar { width:600px; margin:25px auto;}
.page-bar a{
    border: 1px solid #ddd;
    text-decoration: none;
    position: relative;
    float: left;
    padding: 6px 12px;
    margin-left: -1px;
    line-height: 1.42857143;
    color: #337ab7;
    cursor: pointer
}
.page-bar a:hover{
    background-color: #eee;
}
.page-bar a.banclick{
    cursor:not-allowed;
}
.page-bar .active a{
    color: #fff;
    cursor: default;
    background-color: #337ab7;
    border-color: #337ab7;
}
.page-bar i{
    font-style:normal;
    color: #d44950;
    margin: 0px 4px;
    font-size: 12px;
}
</style>
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
    <br>
    <div style="text-align:center;" class="nav">
    <a href="adminscore.asp">分数审核列表</a>&nbsp;&nbsp;
    <!--<a href="admin.asp">等待上桌列表</a>&nbsp;&nbsp;-->
    <a href="upList.asp">等待下桌列表</a>&nbsp;&nbsp;
    <a href="javascript:;" class="active">历史数据查询</a>&nbsp;&nbsp;
    <a href="scoreListAdmin.asp">分数明细查询</a>
    </div>
    <br><br>
    <center>
    上桌开始时间：<input type="text" class="some_class text3" placeholder="可以为空" value="" id="some_class_1"/>
    结束时间：<input type="text" class="some_class text3" placeholder="可以为空" value="" id="some_class_2"/> 玩家ID：<input type="text" class="text3" placeholder="玩家ID" id="some_name" />
    <a class="addBtn" href="javascript:;" @click="chaxun">查询</a>
    <a class="addBtn" href="javascript:;" @click="daochu">导出</a>
    </center>
    <br><br>
    <div class="aa">
    	<h3>历史数据查询</h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
                <td>桌号</td>
                <td>上桌时间</td>
                <td>来源局头</td>
                <td>玩家ID</td>
                <td>初始分数</td>
                <td>局末分数</td>
            </tr>
        	<tr v-for="(item,index) in userArr">
                <td>{{ item.zh }}</td>
                <td>{{ item.ut }}</td>
                <td>{{ item.uh }}</td>
            	<td>{{ item.pi }}</td>
                <td>{{ item.pt }}</td>
                <td>{{ item.pe }}</td>
            </tr>
        </table>
        <div class="page-bar">
            <ul>
            	<li v-if="cur>1"><a v-on:click="cur=1,pageClick()">首页</a></li>
                <li v-if="cur==1"><a class="banclick">首页</a></li>
                <li v-if="cur>1"><a v-on:click="cur--,pageClick()">上一页</a></li>
                <li v-if="cur==1"><a class="banclick">上一页</a></li>
                <li v-for="index in indexs"  v-bind:class="{ 'active': cur == index}">
                    <a v-on:click="btnClick(index)">{{ index }}</a>
                </li>
                <li v-if="cur!=all"><a v-on:click="cur++,pageClick()">下一页</a></li>
                <li v-if="cur == all"><a class="banclick">下一页</a></li>
                <li v-if="cur == all"><a v-on:click="cur=all,pageClick()">末页</a></li>
                <li v-if="cur!=all"><a class="banclick">末页</a></li>
                <li><a class="banclick">共<i>{{allRec}}</i> 条 / <i>{{all}}</i> 页</a></li>
            </ul>
            <!--<input type="text" v-model="soul" />
            <input type="button" value="跳转" @click="soulp" />-->
        </div>
    </div>
    <audio src="music.mp3" data-src="music.mp3" id="music"></audio>
</div>
</body>
</html>
<script src="js/vue.min.js"></script>
<script src="js/axios.min.js"></script>
<script src="js/jquery-3.2.1.js"></script>
<script src="js/jquery.datetimepicker.full.js"></script>
<script src="js/polyfill.min.js"></script>
<script src="js/common.js"></script>
<script>
'use strict';

var app = new Vue({
	el: '#app',
	data: {
		superUser: superUser,
		today: this.formatDateTime,
		now: null,
		userArr: [],
		newArr: [],
		idArr: [],
		dateStart: '',
		dateEnd: '',
		id: '',
		allRec: 0, //总条数
		all: 20, //总页数
		cur: 1, //当前页码
		soul: 1
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
		btnClick: function btnClick(data) {
			//页码点击事件
			if (data != this.cur) {
				this.cur = data;
			}
			this.jiazai();
		},
		pageClick: function pageClick() {
			//console.log('现在在'+this.cur+'页');
			this.jiazai();
		},
		chaxun: function chaxun() {
			this.dateStart = $('#some_class_1').val();
			this.dateEnd = $('#some_class_2').val();
			this.id = $('#some_name').val();
			this.cur = 1;
			this.jiazai();
		},
		daochu: function daochu() {
			this.dateStart = $('#some_class_1').val();
			this.dateEnd = $('#some_class_2').val();
			this.id = $('#some_name').val();
			this.cur = 1;
			axios.get(ajaxUrl, { //取排队数据
				params: {
					ot: 16,
					page: this.cur,
					dateStart: this.dateStart,
					dateEnd: this.dateEnd,
					id: this.id
				}
			}).then(function (response) {
				//this.all = response.data.allPage;
				//this.userArr = response.data.datas;
				//console.log(response.data);
				console.log(response.data.code);
				location.href = response.data.code;
			});
		},
		soulp: function soulp() {
			if (this.soul >= 1 && this.soul <= this.all) {
				this.cur = parseInt(this.soul);
				this.jiazai();
			}
		},
		jiazai: function jiazai() {
			var _this = this;

			/*
   this.idArr.length = 0;
   for(var i=0;i<this.userArr.length;i++){
   	this.idArr.push(this.userArr[i].id);
   }
   */
			axios.get(ajaxUrl, { //取排队数据
				params: {
					ot: 14,
					page: this.cur,
					dateStart: this.dateStart,
					dateEnd: this.dateEnd,
					id: this.id
				}
			}).then(function (response) {
				//console.log(response.data);
				loginYZ(response.data.code);
				_this.allRec = response.data.allRec; //总条数
				_this.all = response.data.allPage; //总页数
				_this.userArr = response.data.datas;
				$(function () {
					//鼠标移入该行和鼠标移除该行的事件
					jQuery(".tab5 tr:gt(0)").mouseover(function () {
						jQuery(this).addClass("trover");
					}).mouseout(function () {
						jQuery(this).removeClass("trover");
					});
				});
				//console.log(response.data.datas);
			});
		}

	},
	mounted: function mounted() {
		$('.some_class').datetimepicker();
		var This = this;
		this.jiazai();
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

		setInterval(function () {
			axios.get(ajaxUrl, { //获取日志记录
				params: {
					ot: 15
				}
			}).then(function (response) {
				loginYZ(response.data.code);
				if (response.data.length > 0) {
					document.getElementById('music').play();
				}
			});
		}, itime2);
	},
	computed: {
		indexs: function indexs() {
			var left = 1;
			var right = this.all;
			var ar = [];
			if (this.all >= 5) {
				if (this.cur > 3 && this.cur < this.all - 2) {
					left = this.cur - 2;
					right = this.cur + 2;
				} else {
					if (this.cur <= 3) {
						left = 1;
						right = 5;
					} else {
						right = this.all;
						left = this.all - 4;
					}
				}
			}

			while (left <= right) {
				ar.push(left);
				left++;
			}
			return ar;
		}
	}
});
</script>
