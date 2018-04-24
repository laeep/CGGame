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
<title>等待下桌列表</title>
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
    <br>
    <div style="text-align:center;" class="nav">
    <a href="adminscore.asp">分数审核列表</a>&nbsp;&nbsp;
    <!--<a href="admin.asp">等待上桌列表</a>&nbsp;&nbsp;-->
    <a href="javascript:;" class="active">等待下桌列表</a>&nbsp;&nbsp;
    <a href="dataList.asp">历史数据查询</a>&nbsp;&nbsp;
    <a href="scoreListAdmin.asp">分数明细查询</a>
    </div>
    <br><br>
    <div class="aa">
    	<h3>等待下桌列表</h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
            	<td>桌号</td>
                <td>时间</td>
                <td>执行者</td>
                <td>玩家ID</td>
                <td>初始分数</td>
                <td>增减分数(加5分输入5,减5分请输入-5)</td>
                <td>编辑</td>
            </tr>
            <tr v-for="(item,index) in userArr">
            	<td>{{ item.zh }}</td>
                <td>{{ item.ut }}</td>
                <td>{{ item.uh }}</td>
            	<td>{{ item.pi }}</td>
                <td>{{ item.pt }}</td>
                <td><input type="text" v-model="item.pe" /></td>
                <td><button @click="xiazhuoOne(item.id,item.pe,index)" class="button2" :disabled="item.pe==''">下桌</button></td>
            </tr>
            </tbody>
        </table>
        <div style="display:none;"><center><button @click="xiazhuo">下桌</button></center></div>
    </div>
    <audio src="music.mp3" data-src="music.mp3" id="music"></audio>
</div>
</body>
</html>
<script src="js/vue.min.js"></script>
<script src="js/axios.min.js"></script>
<script src="js/jquery-3.2.1.js"></script>
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
		now2: null,
		playId: '',
		playCount: '',
		zhuohao: [],
		userArr: [],
		newArr: [],
		fsArr: [],
		idArr: [],
		idArr2: [],
		idArr3: []
	},
	methods: {
		typeA: function typeA(fs) {
			if (fs != "") {
				return false;
			} else {
				return true;
			}
		},
		xiazhuoOne: function xiazhuoOne(id, fs, p) {
			var _this = this;

			axios.get(ajaxUrl, {
				params: {
					ot: 10,
					id: id,
					fs: fs
				}
			}).then(function (response) {
				loginYZ(response.data.code);
				if (response.data.code == 0) {
					_this.userArr.splice(p, 1);
				} else if (response.data.code == 203) {
					_this.userArr[p].pe = '';
					alert("数字非法");
				}
			});
		},
		xiazhuo: function xiazhuo() {
			var _this2 = this;

			this.idArr2 = []; //下桌传输的id
			//this.idArr = [];	//每一秒请求的id
			this.idArr3 = []; //每一秒请求的id
			this.fsArr = [];
			this.zhArr = [];
			this.newArr = [];
			var reg = /^(-)?[0-9]+$/;
			for (var i = 0; i < this.userArr.length; i++) {
				if (this.userArr[i].pe != "") {
					if (!reg.test(this.userArr[i].pe)) {
						alert("数字非法");
						this.userArr[i].pe = "";
						return;
					} else {
						this.idArr2.push(this.userArr[i].id);
						this.fsArr.push(this.userArr[i].pe);
					}
				} else {
					this.newArr.push(this.userArr[i]);
					this.idArr3.push(this.userArr[i].id);
				}
			}
			//console.log(this.idArr2);
			//console.log(this.fsArr);
			//return;
			axios.get(ajaxUrl, {
				params: {
					ot: 10,
					id: this.idArr2.toString(),
					fs: this.fsArr.toString()
				}
			}).then(function (response) {
				//console.log(response.data.code);
				loginYZ(response.data.code);
				if (response.data.code == 0) {
					_this2.userArr = _this2.newArr;
					_this2.idArr = _this2.idArr3;
					/*
     for(var k=0;k<this.idArr2.length;k++){
     	var ret = this.userArr.findIndex((value, index, arr) =>{
     		return value.id==this.idArr2[k];
     	});
     	if(ret!=-1){
     		this.userArr.splice(ret,1);
     	}
     }
     */
				} else if (response.data.code == 203) {
					_this2.idArr = [];
					for (var i = 0; i < _this2.userArr.length; i++) {
						_this2.idArr.push(_this2.userArr[i].id);
						_this2.userArr[i].pe = '';
					}
					alert("数字非法");
				}
			});
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
		jiazai: function jiazai() {
			var _this3 = this;

			//console.log(this.idArr);
			//console.log(this.userArr);
			axios.get(ajaxUrl, { //取排队数据
				params: {
					ot: 11,
					id: this.idArr.toString()
				}
			}).then(function (response) {
				//console.log(response.data.length);
				if (response.data.length > 0) {
					for (var i = 0; i < response.data.length; i++) {
						_this3.idArr.push(response.data[i].id);
						_this3.userArr.unshift(response.data[i]);
					}
					$(function () {
						//鼠标移入该行和鼠标移除该行的事件
						jQuery(".tab5 tr:gt(0)").mouseover(function () {
							jQuery(this).addClass("trover");
						}).mouseout(function () {
							jQuery(this).removeClass("trover");
						});
					});
				}
			});
		}

	},
	mounted: function mounted() {
		var _this4 = this;

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
		setInterval(function () {
			_this4.jiazai();
		}, itime);

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
		}
	}
});
</script>
