<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Session.asp"-->
<%
If Not JudgePower("1") Then
	'Response.Write("dddddd")
	'Response.End()
	Call Error1()
End If
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>用户状态列表</title>
<link type="text/css" href="css/index.css" rel="stylesheet" />
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

<body onkeydown="keyLogin();">
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
    <a href="javascript:;" class="active">用户状态列表</a>&nbsp;&nbsp;
    <a href="scoreList.asp">分数明细查询</a>
    <div class="reload"><a class="addBtn" href="javascript:location.reload();">刷新</a></div>
    </div>
    <br>
    <div class="aa">
    	<h3>局头数据列表<span class="icon1">这个颜色表示否定</span></h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
            	<!--<td>序号</td>-->
                <td>时间</td>
                <td>执行者</td>
                <td>玩家ID</td>
                <td>初始分数</td>
                <td>局末分数</td>
                <td>桌号</td>
                <td>状态</td>
                <td>编辑</td>
            </tr>
        	<tr v-for="(item,index) in userArr" :class="setColors(item.zt)">
            	<!--<td>{{ item.id }}</td>-->
                <td>{{ item.ut }}</td>
                <td>{{ item.uh }}</td>
            	<td>{{ item.pi }}</td>
                <td>{{ item.pt }}</td>
                <td>{{ item.pe }}</td>
                <td>{{ item.zh }}</td>
                <td>{{ item.zt }}</td>
                <td width="150" class="btnsa">
                <!--<label v-show="item.zt=='等待提交' || item.zt=='退回'"><span @click="del(item.id,index)">删除</span><span @click="sub(item.id,index)">提交</span></label>-->
                <a v-show="item.zt!='已下桌'" class="addBtn" href="javascript:;" @click="shangBtn(item.pi,item.zh)">增加</a>
                </td>
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
<script src="js/jquery-3.2.1.js"></script>
<script src="js/axios.min.js"></script>
<script src="js/polyfill.min.js"></script>
<script src="js/common.js"></script>
<script>
'use strict';

function keyLogin() {
	var event = window.event || arguments.callee.caller.arguments[0];
	var keycode = event.keyCode || event.which;
	if (keycode == 13) {
		app.addBtn();
		document.getElementById("playId").focus();
	}
}
var app = new Vue({
	el: '#app',
	data: {
		setColor: '',
		superUser: superUser,
		today: this.formatDateTime,
		now: null,
		now2: null,
		playId: '',
		playCount: '',
		playZh: '',
		idArr: [],
		userArr: [],
		allRec: 0, //总条数
		all: 20, //总页数
		cur: 1, //当前页码
		soul: 1
		/*userArr: [
  	{id:9,pi:"bb",pt:55,uc:0,uh:"shanfox",ut:"2018/2/24 14:15:49"}
  ],*/
	},
	methods: {
		/*
  movedown: function(i){
  	if(i<this.userArr.length-1){
  		var tmp = this.userArr[i];
  		this.userArr.splice(i,1);
  		this.userArr.splice((i+1),0,tmp);	
  	}
  },
  moveup: function(i){
  	if(i>0){
  		var tmp = this.userArr[i];
  		this.userArr.splice(i,1);
  		this.userArr.splice((i-1),0,tmp);	
  	}
  },
  */
		close: function close() {
			$('#apDiv1').hide();
		},
		del: function del(i, y) {
			var _this = this;

			//删除
			console.log(y);
			axios.get(ajaxUrl, {
				params: {
					ot: 6,
					id: i
				}
			}).then(function (response) {
				loginYZ(response.data.code);
				_this.userArr.splice(y, 1);
			});
		},
		sub: function sub(i, y) {
			var _this2 = this;

			//提交
			axios.get(ajaxUrl, {
				params: {
					ot: 7,
					id: i
				}
			}).then(function (response) {
				loginYZ(response.data.code);
				_this2.userArr.splice(y, 1);
				//this.userArr[y].zt = 1;
			});
		},
		addBtn: function addBtn() {
			var _this3 = this;

			//添加数据

			axios.get(ajaxUrl, {
				params: {
					ot: 3,
					pi: this.playId,
					pt: this.playCount,
					zh: this.playZh
				}
			}).then(function (response) {
				_this3.playId = '';
				_this3.playCount = '';
				_this3.playZh = '';
				if (response.data.code == 0) {
					loginYZ(response.data.code);
					location.reload();
					/*
     var ret = this.userArr.findIndex((value, index, arr) =>{
     	return value.pi==response.data.pi
     });
     //console.log(ret);
     if(ret!=-1){
     	this.userArr.splice(ret,1);
     }
     */
					//alert('操作成功');
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
			});

			//this.userArr.push({'user':this.playId,'account':this.playCount,'date':$('#date').text(),check: false});
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
		isOk: function isOk(i) {
			return i != 0 ? false : true;
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
		setColors: function setColors(n) {
			if (n == "等待上桌") {
				return 'red';
			} else if (n == "已上桌") {
				return 'green';
			} else if (n == "已下桌") {
				return 'blue';
			} else if (n == "退回") {
				return 'gray';
			}
		},
		jiazai: function jiazai() {
			var _this4 = this;

			this.idArr.length = 0;
			for (var i = 0; i < this.userArr.length; i++) {
				this.idArr.push(this.userArr[i].id);
			}

			axios.get(ajaxUrl, { //取排队数据
				params: {
					ot: 4,
					//id: this.idArr.toString(),
					page: this.cur
				}
			}).then(function (response) {
				//console.log(response.data);
				loginYZ(response.data.code);
				_this4.allRec = response.data.allRec; //总条数
				_this4.all = response.data.allPage;
				_this4.userArr = response.data.datas;
				$(function () {
					//鼠标移入该行和鼠标移除该行的事件
					jQuery(".tab5 tr:gt(0)").mouseover(function () {
						jQuery(this).addClass("trover");
					}).mouseout(function () {
						jQuery(this).removeClass("trover");
					});
				});
				for (var i = 0; i < _this4.userArr.length; i++) {
					if (_this4.userArr[i].zt == 0) {
						_this4.userArr[i].zt = "等待上桌";
					} else if (_this4.userArr[i].zt == 2) {
						_this4.userArr[i].zt = "已上桌";
					} else if (_this4.userArr[i].zt == 3) {
						_this4.userArr[i].zt = "已下桌";
					} else if (_this4.userArr[i].zt == 10) {
						_this4.userArr[i].zt = "退回";
					}
				}
			});
		}

	},
	mounted: function mounted() {
		var This = this;
		axios.get(ajaxUrl, { //获取登录账号
			params: {
				ot: 1
			}
		}).then(function (response) {
			loginYZ(response.data.code);
			This.superUser = response.data;
		});

		axios.get(ajaxUrl, { //获取服务器时间
			params: {
				ot: 2
			}
		}).then(function (response) {
			This.now = new Date(response.data);
			This.formatDateTime();
		});
		this.jiazai();

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
		all2: function all2() {
			return this.userArr.length;
		},
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
