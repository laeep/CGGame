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
<title>等待上桌列表</title>
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
    <a href="javascript:;" class="active">等待上桌列表</a>&nbsp;&nbsp;
    <a href="upList.asp">等待下桌列表</a>&nbsp;&nbsp;
    <a href="dataList.asp">历史数据查询</a>&nbsp;&nbsp;
    <a href="scoreListAdmin.asp">分数明细查询</a>
    </div>
    <br><br>
    <div class="aa">
    	<h3>等待上桌列表</h3>
        <table class="tab2 tab5" width="100%">
        	<tr>
            	<td>序号</td>
                <td>桌号</td>
                <td>时间</td>
                <td>执行者</td>
                <td>玩家ID</td>
                <td>分数</td>
                <td>否定上桌</td>
                <td>编辑</td>
            </tr>
        	<tr v-for="(item,index) in userArr">
            	<td>{{ item.id }}</td>
                <td><input type="text" v-model="item.zh" /></td>
                <td>{{ item.ut }}</td>
                <td>{{ item.uh }}</td>
            	<td>{{ item.pi }}</td>
                <td>{{ item.pt }}</td>
                <td><span @click="fouding(item.id,index)">退回</span></td>
                <!--<td><input type="checkbox" name="whom" v-model="item.check" disabled="{{check(item.zh)}}" /></td>-->
                <td><button @click="shangzhuoOne(item.id,item.zh,index)" class="button2" :disabled="item.zh==''">上桌</button></td>
            </tr>
        </table>
        <div style="display:none"><center><button @click="shangzhuo">上桌</button></center></div>
    </div>
    <audio src="music.mp3" data-src="music.mp3" id="music"></audio>
</div>
</body>
</html>
<script src="js/vue.min.js"></script>
<script src="js/axios.min.js"></script>
<script src="js/jquery-3.2.1.js"></script>
<script src="js/common.js"></script>
<script>
var app = new Vue({
	el: '#app',
	data: {
		superUser: superUser,
		today: this.formatDateTime,
		now: null,
		now2: null,
		playId: '',
		playCount: '',
		userArr: [],
		newArr: [],
		idArr: [],
		zhArr: []
	},
	methods: {
		/*check: function(i){
			this.userArr[i].check = !this.userArr[i].check;
		},*/
		fouding: function(i,y){	//否定
			axios.get(ajaxUrl, {
				params: {
				  ot: 8,
				  id: i,
				}
			})
			.then( response => {
				this.userArr.splice(y,1);
			})
		},
		shangzhuoOne: function(id,zh,p){
			axios.get(ajaxUrl, {
				params: {
				  ot: 9,
				  id: id,
				  zh: zh,
				}
			})
			.then( response => {
				loginYZ(response.data.code);
				if( response.data.code == 0 ){
					this.userArr.splice(p,1);
				}else if( response.data.code == 203 ){
					this.userArr[p].pe = '';
					alert("数字非法");
				}
			})
		},
		shangzhuo: function(){
			this.idArr2 = [];
			this.zhArr = [];
			this.newArr = [];
			for(var i=0;i<this.userArr.length;i++){
				if(this.userArr[i].zh!=""){
					//this.idArr =  this.idArr + this.userArr[i].id + ",";
					this.idArr2.push(this.userArr[i].id);
					this.zhArr.push(this.userArr[i].zh);
				}else{
					this.newArr.push(this.userArr[i]);
				}
			}
			axios.get(ajaxUrl, {
				params: {
				  ot: 9,
				  id: this.idArr2.toString(),
				  zh: this.zhArr.toString()
				}
			})
			.then( response => {
				loginYZ(response.data.code);
				this.userArr = this.newArr;
				/*
				for(var k=0;k<this.idArr.length;k++){
					var ret = this.userArr.findIndex((value, index, arr) =>{
						return value.id==this.idArr[k];
					});
					if(ret!=-1){
						this.userArr.splice(ret,1);
					}
				}
				*/
			})
		},
		time: function(){
			var date = new Date();
			var y = date.getFullYear();  
			var m = date.getMonth() + 1;  
			m = m < 10 ? ('0' + m) : m;  
			var d = date.getDate();  
			d = d < 10 ? ('0' + d) : d;  
			var h = date.getHours();  
			h=h < 10 ? ('0' + h) : h;  
			var minute = date.getMinutes();  
			minute = minute < 10 ? ('0' + minute) : minute;  
			var second=date.getSeconds();  
			second=second < 10 ? ('0' + second) : second; 
			this.today = y + '-' + m + '-' + d+' '+h+':'+minute+':'+second;
		},
		formatDateTime: function(){
			this.time();
			var This = this;
			setInterval(function(){
				This.time();
			},1000);
		},
		isOk: function(i){
			return i!=0?false:true;
		},
		jiazai: function(){
			this.idArr.length = 0;
			for(var i=0;i<this.userArr.length;i++){
				this.idArr.push(this.userArr[i].id);
			}
			axios.get(ajaxUrl, {	//取排队数据
				params: {
				  ot: 5,
				  id: this.idArr.toString(),
				}
			})
			.then( response => {
				//console.log(response.data);nse => {
				for(var i=0;i<response.data.length;i++){
					this.userArr.unshift(response.data[i]);	
				}
				$(function () {
					//鼠标移入该行和鼠标移除该行的事件
					jQuery(".tab5 tr:gt(0)").mouseover(function () {
						jQuery(this).addClass("trover");
					}).mouseout(function () {
						jQuery(this).removeClass("trover");
				  	});
			   	});
			})
		}
		
	},
	mounted: function(){
		var This = this;
		axios.get(ajaxUrl, {
			params: {
			  ot: 1,
			}
		})
		.then(function (response) {
			This.superUser = response.data;
		});
		
		axios.get(ajaxUrl, {
			params: {
			  ot: 2,
			}
		})
		.then(function (response) {
			This.now = new Date(response.data);
			This.formatDateTime();
		});
		
		this.jiazai();
		setInterval(()=>{
			this.jiazai();
		},itime);
		
		setInterval(function(){
			axios.get(ajaxUrl, {	//获取日志记录
				params: {
				  ot: 15,
				}
			})
			.then(function (response) {
				loginYZ(response.data.code);
				if(response.data.length>0){
					document.getElementById('music').play();
				}
			});
		},itime2);
		
	},
	computed:{
        all2:function () {
            return this.userArr.length;
        },
		check:function(a){
			if(a!=''){
				return false;
			}else{
				return true;
			}
		}
    },
	created: function(){
		
	}
});
</script>
