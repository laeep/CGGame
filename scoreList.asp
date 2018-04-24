<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Session.asp"-->
<%
'If Not JudgePower("1") Then
	'Response.Write("dddddd")
	'Response.End()
	'Call Error1()
'End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>分数明细查询</title>
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
#apDiv1 {
	position: absolute;
	width: 400px;
	height: 120px;
	z-index: 1;
	border:1px solid #000;
	background:#fff;
	display:none;
	position: fixed;
	left: 50%;
	top: 50%;
	margin-left: -200px;
	margint-top: -60px;
}
#apDiv1 .tab4 { width:300px; margin:15px auto 0;}
.close { position:absolute; right:1px; top:1px; font-size:20px; cursor:pointer; width:25px; height:20px; color:#000;}
.omg { background:#36F;}
</style>
</head>

<body>
<div id="app" class="wrap">
	<div id="apDiv1">
    	<span class="close" @click="close">X</span>
        <table class="tab4">
            <tr>
                    <td>上分数: </td>
                    <td><input type="number" oninput="if(this.value.length>6)this.value=value.slice(0,6)" v-model="playCount" maxlength="6" />				</td>
                </tr>
                <tr>
                    <td colspan="2" align="center"><a class="addBtn" href="javascript:;" @click="addBtn">上分</a></td>
                </tr>
        </table>
    </div>
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
    <div class="userform"></div>
    <div style="text-align:center;" class="nav">
    <a href="jutouscore.asp">分数审核列表</a>&nbsp;&nbsp;
    <a href="jutou.asp">用户状态列表</a>&nbsp;&nbsp;
    <a href="javascript:;" class="active">分数明细查询</a>
    </div>
    <br><br>
    <center>
    上桌开始时间：<input type="text" class="some_class text3" placeholder="可以为空" value="" id="some_class_1"/>
    上桌结束时间：<input type="text" class="some_class text3" placeholder="可以为空" value="" id="some_class_2"/> 玩家ID：<input type="text" class="text3" placeholder="玩家ID" id="some_name" />
    <a class="addBtn" href="javascript:;" @click="chaxun">查询</a>
    </center>
    <br><br>
    <div class="aa">
    	<h3>分数明细查询<span class="icon2">这个颜色表示下分</span></h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
                <td>时间</td>
                <td>桌号</td>
                <td>玩家ID</td>
                <td>操作类型</td>
                <td>增减分数</td>
                <td>当前分数</td>
                <td>上分</td>
            </tr>
        	<tr v-for="(item,index) in userArr" :class="item.lx=='下分'?'red':''">
                <td>{{ item.ut }}</td>
                <td>{{ item.zh }}</td>
            	<td>{{ item.pi }}</td>
                <td>{{ item.lx }}</td>
                <td>{{ item.zj }}</td>
                <td>{{ item.dq }}</td>
              <td><a class="addBtn" @click="shangBtn(item.pi,item.zh)">上分</a></td>
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
                <li v-if="cur!=all"><a v-on:click="cur=all,pageClick()">末页</a></li>
                <li v-if="cur == all"><a class="banclick">末页</a></li>
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
		playId: '',
		playCount: '',
		playZh: '',
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
		close: function close() {
			$('#apDiv1').hide();
		},
		addBtn: function addBtn() {
			var _this = this;

			//添加数据
			axios.get(ajaxUrl, {
				params: {
					ot: 3,
					pi: this.playId,
					pt: this.playCount,
					zh: this.playZh
				}
			}).then(function (response) {
				//console.log(this.playId,this.playCount,this.playZh);
				//return;
				if (response.data.code == 0) {
					loginYZ(response.data.code);
					location.reload();
				} else if (response.data.code == 101) {
					alert('数据不能为空');
				} else if (response.data.code == 102) {
					alert('玩家账号非法');
				} else if (response.data.code == 103) {
					alert('积分非法');
				} else if (response.data.code == 104) {
					alert('账号已经在等待上桌，请勿重复添加');
				} else if (response.data.code == 105) {
					alert('此账号不是你添加的');
				}
				_this.playId = '';
				_this.playCount = '';
				_this.playZh = '';
			});
		},
		shangBtn: function shangBtn(pi, zh) {
			$('#apDiv1').show();
			this.playId = pi;
			this.playZh = zh;
			$('#apDiv1').find('input').focus();
		},
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
		soulp: function soulp() {
			if (this.soul >= 1 && this.soul <= this.all) {
				this.cur = parseInt(this.soul);
				this.jiazai();
			}
		},
		jiazai: function jiazai() {
			var _this2 = this;

			axios.get(ajaxUrl, { //取局头查询用户充值明细数据
				params: {
					ot: 12,
					page: this.cur,
					dateStart: this.dateStart,
					dateEnd: this.dateEnd,
					id: this.id
				}
			}).then(function (response) {
				loginYZ(response.data.code);
				_this2.allRec = response.data.allRec; //总条数
				_this2.all = response.data.allPage;
				_this2.userArr = response.data.datas;
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
	},
	created: function created() {}
});
</script>
