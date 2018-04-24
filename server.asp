<!--#include file="inc/Const.asp"-->
<!--#include file="inc/Conn.asp"-->
<!--#include file="inc/function.asp"-->
<%

Dim operType
Dim retValue
Dim f_id
Dim deskNo,currentTime
Dim orderIdList
Dim DeskList,deskNoList
Dim OneDeskMaxNum,OneDeskMinNum
Dim startTime,endTime,playerId
Dim fPageIndex,allRecNum,allPageNum,fWhere,fPageSize

Dim deskNoListArr,idListArr,fsListArr
OneDeskMaxNum 	= 999
OneDeskMinNum 	= 1
operType		=request.QueryString("ot")
'1	返回当前登录账号
'2	返回系统时间
'3	添加数据（上分）
'4	返回指定局头录入的玩家列表
'5	返回已经进入上桌排队的玩家列表
'6	删除局头添加的数据
'7	局头提交添加的数据到管理员处
'8	否定上桌
'9	确认上桌
'10	下桌
'11	已上桌列表
'12	分数变动记录
'13	返回上分明细列表----------
'14 历史数据查询
'15	返回系统日志--------------
'16 导出excel（XML）
'18 管理员确认或者拒绝上分操作-------
'100用户列表
'101设置权限
If operType="1" Then
	Response.Write(Session(G_SessionPre&"_Mem_Name"))
	
ElseIf operType="2" Then
	Response.Write(Now())
	
ElseIf operType="3" Then'上分
	Call LoginPowerJudge(1)
	Dim playerInitPoint
	Dim userBalances
	playerID		=request.QueryString("pi")
	playerInitPoint	=request.QueryString("pt")
	deskNo			=request.QueryString("zh")
	If playerID ="" or playerInitPoint="" or deskNo="" Then
		Response.Write("{""code"":101}")'输入数据不全
		Response.end
	End If
	If Not IsNum(playerInitPoint) Then
		Response.Write("{""code"":103}")'积分非法
		Response.end
	End If
	Call OpenDataBase
	'判断桌号输入是否和上次一样
	Set deskNoRs=Conn.Execute("select top 1 userDeskNo from CG_d_user_desk where userAccount='"&playerID&"' and userDownDeskTime is null order by id desc")
	If Not deskNoRs.Eof Then
		If deskNoRs("userDeskNo")<>deskNo Then
			deskNoRs.Close
			Set deskNoRs = Nothing
			Call connClose
			Response.Write("{""code"":110}")'桌号输入与上次不一样
			Response.end
		End If
	End If
	deskNoRs.Close
	Set deskNoRs = Nothing
	
	'上分
	If CLng(playerInitPoint)>0 Then '如果输入分数大于零 则进行上分操作
		Set dataRs=Conn.Execute("select userHeader from CG_d_user_info where userAccount='"&playerID&"'")
		If Not dataRs.Eof Then'已有此账号的情况
			If dataRs("userHeader")=Session(G_SessionPre&"_Mem_Name") Then
				Conn.Execute("insert into CG_d_addPoint_info(userAccount,userHeader,userAddPoint,userDeskNo) values('"&playerID&"','"&Session(G_SessionPre&"_Mem_Name")&"',"&playerInitPoint&",'"&deskNo&"')")
			Else
				dataRs.Close
				Set dataRs = Nothing
				Call connClose
				Response.Write("{""code"":105}")'您不能给此账号上分，只能给自己录入的账号上分
				Response.end
			End If
		Else
			'无此账号，直接写上分请求
			Conn.Execute("insert into CG_d_addPoint_info(userAccount,userHeader,userAddPoint,userDeskNo) values('"&playerID&"','"&Session(G_SessionPre&"_Mem_Name")&"',"&playerInitPoint&",'"&deskNo&"')")
			'用户表中插入余额为0的记录
			Conn.Execute("insert into CG_d_user_info(userAccount,userHeader,userBalances) values('"&playerID&"','"&Session(G_SessionPre&"_Mem_Name")&"',0)")
		End If
		dataRs.Close
		'写系统日志
		Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&playerID&"','局头【"&Session(G_SessionPre&"_Mem_Name")&"】请求给账号【"&playerID&"】上【"&playerInitPoint&"】分，请请尽快处理','#333','"&G_AdminFlag&"')")
	End If
	
	Set dataRs=Conn.Execute("select userHeader from CG_d_user_info where userAccount='"&playerID&"' and userHeader='"&Session(G_SessionPre&"_Mem_Name")&"'")
	If Not dataRs.Eof Then
		'读取用户当前分数
		userBalances =Conn.Execute("select userBalances from CG_d_user_info where userAccount='"&playerID&"'")(0)
		Set dataRs1=Conn.Execute("select id from CG_d_user_desk where userAccount='"&playerID&"' and userDownDeskTime is null")
		If Not dataRs1.Eof Then
			If Clng(playerInitPoint)=0 Then
				dataRs1.Close
				Set dataRs1 = Nothing
				dataRs.Close
				Set dataRs = Nothing
				Call connClose
				Response.Write("{""code"":104}")'账号已经在等待上桌或已上桌，请勿重复添加
				Response.end
			End If
		Else
			Conn.Execute("insert into CG_d_user_desk(userAccount,userInitPoint,userHeader,userDeskNo) values('"&playerID&"',"&userBalances&",'"&Session(G_SessionPre&"_Mem_Name")&"','"&deskNo&"')")
		End If
		dataRs1.Close
		Response.Write("{""code"":0}")'成功
		dataRs.Close
		Set dataRs = Nothing
		Call connClose
		Response.End()
	Else
		dataRs.Close
		Set dataRs = Nothing
		Call connClose
		Response.Write("{""code"":105}")'您不能操作此账号
		Response.end
	End If

ElseIf operType="4" Then'返回指定局头录入的所有玩家列表
	Call LoginPowerJudge(1)
	
	fPageIndex=Request.QueryString("page")

	'startTime =Request.QueryString("dateStart")
	'endTime =Request.QueryString("dateEnd")
	'playerId =Request.QueryString("id")
	
	If fPageIndex="" Then fPageIndex=1 else fPageIndex=CInt(fPageIndex)
	fPageSize =15
	
	fWhere=" where userHeader='"&Session(G_SessionPre&"_Mem_Name")&"'"
	Call OpenDataBase
	allRecNum=Conn.Execute("select Count(0) from CG_d_user_desk" & fWhere)(0)
	allPageNum = JInt(allRecNum,15)
	
	Set dataRs =Conn.Execute("select * from (Select id,[userAccount],[userInitPoint],[userEndPoint],[userHeader],userDeskNo,userCurrentState,userAddTime,row_number() OVER (ORDER BY lastChangeTime desc) n from CG_d_user_desk"&fWhere&") t where n between " & Cstr(fPageSize*(fPageIndex-1)+1) & " and " & Cstr(fPageSize*(fPageIndex-1)+fPageSize))
	Do While Not dataRs.Eof
		retValue =retValue & ",{""id"":"&dataRs("id")&",""ut"":"""&dataRs("userAddTime")&""",""uh"":"""&dataRs("userHeader")&""",""pi"":"""&dataRs("userAccount")&""",""zh"":"""&dataRs("userDeskNo")&""",""pt"":"&dataRs("userInitPoint")&",""pe"":"""&dataRs("userEndPoint")&""",""zt"":"&dataRs("userCurrentState")&"}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="{""allPage"":" & allPageNum & ",""allRec"":"&allRecNum&",""datas"":[" & retValue &"]}" 
	'retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose

'ElseIf operType="5" Then'返回已经进入上桌排队的玩家列表
'	Call LoginPowerJudge(2)
'	orderIdList =Request.QueryString("id")
'	If orderIdList="" Then orderIdList=0
'	Call OpenDataBase
'	Set dataRs=Conn.Execute("select id,userSubmitTime,userHeader,userAccount,userInitPoint,userCurrentState,userDeskNo from CG_d_user_desk where userCurrentState=1 and id not in("&orderIdList&") order by id desc")
'	Do While Not dataRs.Eof
'		retValue =retValue & ",{""id"":"&dataRs("id")&",""ut"":"""&dataRs("userSubmitTime")&""",""uh"":"""&dataRs("userHeader")&""",""pi"":"""&dataRs("userAccount")&""",""pt"":"&dataRs("userInitPoint")&",""uc"":0,""check"":0,""zh"":"""&dataRs("userDeskNo")&"""}"
'		dataRs.MoveNext
'	Loop
'	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
'	retValue ="[" & retValue &"]"
'	Response.Write(retValue)
'	dataRs.Close
'	Set dataRs = Nothing
'	Call connClose
'	
'ElseIf operType="6" Then '删除局头添加的数据
'	Call LoginPowerJudge(1)
'	f_id=CLng(request.QueryString("id"))
'	Call OpenDataBase
'	Conn.Execute("delete from CG_d_user_desk where id="&f_id)
'	Call connClose
'	Response.Write("{""code"":0}")
	
'ElseIf operType="7" Then '局头提交添加的数据到管理员处
'	Call LoginPowerJudge(1)
'	f_id=CLng(request.QueryString("id"))
'	Call OpenDataBase
'	userAccount=Conn.Execute("select userAccount from CG_d_user_desk where id="&f_id)(0)
'	'写系统日志
'	Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&userAccount&"','局头【"&Session(G_SessionPre&"_Mem_Name")&"】提交了账号【"&userAccount&"】，请求上桌','#333','"&G_AdminFlag&"')")
'
'	Conn.Execute("update CG_d_user_desk set userCurrentState=1,userSubmitTime=getdate(),lastChangeTime=getdate() where id="&f_id)
'	Call connClose
'	Response.Write("{""code"":0}")
	
'ElseIf operType="8" Then '否定上桌
'	Call LoginPowerJudge(2)
'	f_id=CLng(request.QueryString("id"))
'	Call OpenDataBase
'	Set dataRs=Conn.Execute("select userAccount,userHeader from CG_d_user_desk where id="&f_id)
'	'写系统日志
'	Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&dataRs("userAccount")&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】否定了账号【"&dataRs("userAccount")&"】的上桌请求','#333','"&dataRs("userHeader")&"')")
'	dataRs.Close
'	Set dataRs = Nothing
'	Conn.Execute("update CG_d_user_desk set userCurrentState=10,lastChangeTime=getdate() where id="&f_id)
'	Call connClose
'	Response.Write("{""code"":0}")

'ElseIf operType="9" Then '确认上桌
'	Call LoginPowerJudge(2)
'	'Call WriteFile("0000000000.txt",request.QueryString)
'
'	deskNoList	=request.QueryString("zh")
'	idList		=request.QueryString("id")
'	currentTime =Now()
'	If idList="" or deskNoList="" Then
'		Response.Write("{""code"":201}")
'		Response.End()
'	End If
'
'	Dim tempList
'	tempList = replace(idList,",","")
'	If Not IsNum(tempList) Then
'		Response.Write("{""code"":203}")
'		Response.End()
'	End If
'	Call OpenDataBase
'	
'	'写系统日志
'	Set dataRs=Conn.Execute("select userAccount,userHeader from CG_d_user_desk where id="&idList)
'	Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&dataRs("userAccount")&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】确认了账号【"&dataRs("userAccount")&"】的上桌请求','#333','"&dataRs("userHeader")&"')")
'	dataRs.Close
'	Set dataRs = Nothing
'	
'	
'	deskNoListArr	=Split(deskNoList,",")
'	idListArr		=Split(idList,",")
'	For iNum=0 to Ubound(deskNoListArr)
'
'		Conn.Execute("update CG_d_user_desk set userDeskNo='"&deskNoListArr(iNum)&"',userUpDeskTime='"&currentTime&"',userCurrentState=2,lastChangeTime='"&currentTime&"' where id ="&idListArr(iNum))
'	Next 
'	Call connClose
'	Response.Write("{""code"":0,""time"":"""&currentTime&"""}")
	
ElseIf operType="10" Then '下桌
	Call LoginPowerJudge(2)
	'Call WriteFile("0000000000.txt",request.QueryString)

	fsList	=request.QueryString("fs")
	idList	=request.QueryString("id")
	If idList="" or fsList="" Then
		Response.Write("{""code"":201}")
		Response.End()
	End If

	tempList = replace(replace(fsList,",",""),"-","")
	If Not IsNum(tempList) Then
		Response.Write("{""code"":203}")
		Response.End()
	End If
	currentTime =Now()
	Call OpenDataBase	

	
	fsListArr	=Split(fsList,",")
	idListArr	=Split(idList,",")

	For iNum=0 to Ubound(idListArr)
		userAccount=Conn.Execute("select userAccount from CG_d_user_desk where id="&idListArr(iNum))(0)
		userDeskNo=Conn.Execute("select userDeskNo from CG_d_user_desk where id="&idListArr(iNum))(0)
		
		Conn.Execute("update CG_d_user_desk set userDownDeskTime='"&currentTime&"',userEndPoint=userInitPoint+"&CLng(fsListArr(iNum))&",lastChangeTime=getdate(),userCurrentState=3 where id="&idListArr(iNum))
		Conn.Execute("update CG_d_user_info set userBalances=userBalances+"&CLng(fsListArr(iNum)) & " where userAccount='"&userAccount&"'")
		userBalances=Conn.Execute("select userBalances from CG_d_user_info where userAccount='"&userAccount&"'")(0)
		'根据ID获取账号，写日志用
		Set dataRs=Conn.Execute("select userAccount,userHeader from CG_d_user_desk where id="&idList)

		If CLng(fsListArr(iNum))>0 Then
			Conn.Execute("insert into CG_d_point_rec(userDeskNo,userAccount,operType,changePoint,userBalances,operAccount) values('"&userDeskNo&"','"&userAccount&"','上分',"&fsListArr(iNum)&","&userBalances&",'"&Session(G_SessionPre&"_Mem_Name")&"')")
			Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&dataRs("userAccount")&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】已操作账号【"&dataRs("userAccount")&"】下桌，本次分数变动【+"&fsListArr(iNum)&"】分','#333','"&dataRs("userHeader")&"')")

		Else
			Conn.Execute("insert into CG_d_point_rec(userDeskNo,userAccount,operType,changePoint,userBalances,operAccount) values('"&userDeskNo&"','"&userAccount&"','下分',"&replace(fsListArr(iNum),"-","")&","&userBalances&",'"&Session(G_SessionPre&"_Mem_Name")&"')")
			Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&dataRs("userAccount")&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】已操作账号【"&dataRs("userAccount")&"】下桌，本次分数变动【"&fsListArr(iNum)&"】分','#333','"&dataRs("userHeader")&"')")

		End If
		dataRs.Close
		Set dataRs = Nothing
	Next 
	
	Call connClose
	Response.Write("{""code"":0}")
	
ElseIf operType="11" Then '已上桌列表
	f_where="userCurrentState=2"
	Call LoginPowerJudge(2)
	idList =Request.QueryString("id")
	'Call WriteFile("1111.txt",idList)
	If idList="" Then idList=0
	Call OpenDataBase
	Set dataRs=Conn.Execute("select id,userUpDeskTime,userHeader,userAccount,userInitPoint,userDeskNo from CG_d_user_desk where "&f_where&" and id not in("&idList&") order by userDeskNo desc,userUpDeskTime desc")
	Do While Not dataRs.Eof
		retValue = retValue &",{""id"":"&dataRs("id")&",""ut"":"""&dataRs("userUpDeskTime")&""",""uh"":"""&dataRs("userHeader")&""",""pi"":"""&dataRs("userAccount")&""",""pt"":"&dataRs("userInitPoint")&",""pe"":"""",""zh"":"""&dataRs("userDeskNo")&"""}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close
	'Call WriteFile("0000000000.txt",retValue)
	Set dataRs = Nothing
	Call connClose
	
ElseIf operType="12" Then '分数变动记录
	If Session(G_SessionPre&"_Mem_Level")="" Then
		Response.Write("{""code"":1000}")
		Response.End()
	End If
	
	fPageIndex	=Request.QueryString("page")
	startTime 	=Request.QueryString("dateStart")
	endTime 	=Request.QueryString("dateEnd")
	playerId 	=Request.QueryString("id")
	
	If fPageIndex="" Then fPageIndex=1 else fPageIndex=CInt(fPageIndex)
	fPageSize =15
	
	If CInt(Session(G_SessionPre&"_Mem_Level"))=1 Then
		fWhere = " where a.userAccount=b.userAccount and b.userHeader='"&Session(G_SessionPre&"_Mem_Name")&"'"
	ElseIf CInt(Session(G_SessionPre&"_Mem_Level"))=2 Then
		fWhere = " where a.userAccount=b.userAccount"
	Else
		fWhere = " where a.userAccount=b.userAccount and 1=2"
	End If
	If playerId<>"" Then
		'If Not CheckNumCharOK(playerId) Then
		'	Response.Write("{""code"":301}")
		'	Response.End()
		'End If
		fWhere =fWhere &" and a.userAccount like '%"&playerId&"%'"
	End If
	If startTime<>"" Then
		If Not isDate(startTime) Then
			Response.Write("{""code"":302}")
			Response.End()
		End If
		fWhere =fWhere &" and a.operTime>='"&startTime&"'"
	End If
	If endTime<>"" Then
		If Not isDate(endTime) Then
			Response.Write("{""code"":303}")
			Response.End()
		End If
		fWhere =fWhere &" and a.operTime<='"&endTime&"'"
	End If
	
	Call OpenDataBase
	allRecNum=Conn.Execute("select Count(0) from CG_d_point_rec a,CG_d_user_info b" & fWhere)(0)
	allPageNum = JInt(allRecNum,15)
	aaaa="select * from (Select a.id,a.userAccount,a.operType,a.changePoint,a.userBalances,a.operTime,a.userDeskNo,row_number() OVER (ORDER BY a.operTime desc) n from CG_d_point_rec a,CG_d_user_info b"& fWhere &") t where n between " & Cstr(fPageSize*(fPageIndex-1)+1) & " and " & Cstr(fPageSize*(fPageIndex-1)+fPageSize)
	'Response.Write(aaaa)
	'Response.End()
	Set dataRs =Conn.Execute(aaaa)
	Do While Not dataRs.Eof
		retValue =retValue & ",{""pi"":"""&dataRs("userAccount")&""",""ut"":"""&dataRs("operTime")&""",""lx"":"""&dataRs("operType")&""",""zh"":"""&dataRs("userDeskNo")&""",""zj"":"&dataRs("changePoint")&",""dq"":"&dataRs("userBalances")&"}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="{""allPage"":" & allPageNum & ",""allRec"":"&allRecNum&",""datas"":[" & retValue &"]}" 
	'retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose
	
ElseIf operType="13" Then '返回上分明细列表
	If Session(G_SessionPre&"_Mem_Level")="" Then
		Response.Write("{""code"":1000}")
		Response.End()
	End If
	
	fPageIndex	=Request.QueryString("page")
	startTime 	=Request.QueryString("dateStart")
	endTime 	=Request.QueryString("dateEnd")
	'playerId 	=Request.QueryString("id")
	
	If fPageIndex="" Then fPageIndex=1 else fPageIndex=CInt(fPageIndex)
	fPageSize =15
	
	If CInt(Session(G_SessionPre&"_Mem_Level"))=1 Then
		fWhere = " where userHeader='"&Session(G_SessionPre&"_Mem_Name")&"'"
	ElseIf CInt(Session(G_SessionPre&"_Mem_Level"))=2 Then
		fWhere = " where 1=1"
	Else
		fWhere = " where 1=2"
	End If
	If startTime<>"" Then
		If Not IsDate(startTime) Then
			Response.Write("{""code"":302}")
			Response.End()
		End If
		fWhere =fWhere &" and addTime>='"&startTime&"'"
	End If
	If endTime<>"" Then
		If Not IsDate(endTime) Then
			Response.Write("{""code"":303}")
			Response.End()
		End If
		fWhere =fWhere &" and addTime<='"&endTime&"'"
	End If
	
	Call OpenDataBase
	allRecNum=Conn.Execute("select Count(0) from CG_d_addPoint_info" & fWhere)(0)
	allPageNum = JInt(allRecNum,15)
	aaaa="select * from (Select *,row_number() OVER (ORDER BY addTime desc) n from CG_d_addPoint_info"& fWhere &") t where n between " & Cstr(fPageSize*(fPageIndex-1)+1) & " and " & Cstr(fPageSize*(fPageIndex-1)+fPageSize)
	'Response.Write(aaaa)
	'Response.End()
	Set dataRs =Conn.Execute(aaaa)
	Do While Not dataRs.Eof
		retValue =retValue & ",{""desk"":"""&dataRs("userDeskNo")&""",""id"":"""&dataRs("id")&""",""zh"":"""&dataRs("userAccount")&""",""sj"":"""&dataRs("addTime")&""",""jt"":"""&dataRs("userHeader")&""",""fs"":"""&dataRs("userAddPoint")&""",""zt"":"&dataRs("auditState")&"}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="{""allPage"":" & allPageNum & ",""allRec"":"&allRecNum&",""datas"":[" & retValue &"]}" 
	'retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose

ElseIf operType="14" Then '历史数据查询
	Call LoginPowerJudge(2)
	
	fPageIndex=Request.QueryString("page")

	startTime =Request.QueryString("dateStart")
	endTime =Request.QueryString("dateEnd")
	playerId =Request.QueryString("id")
	
	If fPageIndex="" Then fPageIndex=1 else fPageIndex=CInt(fPageIndex)
	fPageSize =15
	fWhere = " where userCurrentState=3"
	If playerId<>"" Then
		'If Not CheckNumCharOK(playerId) Then
		'	Response.Write("{""code"":301}")
		'	Response.End()
		'End If
		fWhere =fWhere &" and userAccount like '%"&playerId&"%'"
	End If
	If startTime<>"" Then
		If Not isDate(startTime) Then
			Response.Write("{""code"":302}")
			Response.End()
		End If
		fWhere =fWhere &" and userUpDeskTime>='"&startTime&"'"
	End If
	If endTime<>"" Then
		If Not isDate(endTime) Then
			Response.Write("{""code"":303}")
			Response.End()
		End If
		fWhere =fWhere &" and userUpDeskTime<='"&endTime&"'"
	End If
	
	Call OpenDataBase
	allRecNum=Conn.Execute("select Count(0) from CG_d_user_desk" & fWhere)(0)
	allPageNum = JInt(allRecNum,15)
	
	Set dataRs =Conn.Execute("select * from (Select id,[userAccount],[userInitPoint],[userHeader],userDeskNo,userUpDeskTime,userendPoint,row_number() OVER (ORDER BY userUpDeskTime desc) n from CG_d_user_desk"& fWhere &") t where n between " & Cstr(fPageSize*(fPageIndex-1)+1) & " and " & Cstr(fPageSize*(fPageIndex-1)+fPageSize))
	Do While Not dataRs.Eof
		retValue =retValue & ",{""id"":"&dataRs("id")&",""ut"":"""&dataRs("userUpDeskTime")&""",""uh"":"""&dataRs("userHeader")&""",""pi"":"""&dataRs("userAccount")&""",""zh"":"""&dataRs("userDeskNo")&""",""pt"":"&dataRs("userInitPoint")&",""pe"":"&dataRs("userendPoint")&"}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="{""allPage"":" & allPageNum & ",""allRec"":"&allRecNum&",""datas"":[" & retValue &"]}" 
	'retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose
	
ElseIf operType="15" Then '返回系统日志
	If Session(G_SessionPre&"_Mem_Level")="" Then
		Response.Write("{""code"":1000}")
		Response.End()
	End If
	
	If CInt(Session(G_SessionPre&"_Mem_Level"))=1 Then
		fWhere = " where readState=0 and toWho='"&Session(G_SessionPre&"_Mem_Name")&"'"
	ElseIf CInt(Session(G_SessionPre&"_Mem_Level"))=2 Then
		fWhere = " where readState=0 and toWho='"&G_AdminFlag&"'"
	Else
		fWhere = " where 1=2"
	End If
	
	Call OpenDataBase
	aaaa="select * from  CG_d_log_info"& fWhere
	'Call WriteFile("b.txt",aaaa)
	Set dataRs =Conn.Execute(aaaa)
	Do While Not dataRs.Eof
		retValue =retValue & ",{""sj"":"""&dataRs("logTime")&""",""nr"":"""&dataRs("logContent")&""",""ys"":"""&dataRs("showColor")&"""}"
		'Call WriteFile("b.txt",retValue)
		Conn.Execute("update CG_d_log_info set readState=1 where id=" & dataRs("id"))
		dataRs.MoveNext
	Loop
	
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	'retValue ="{""allPage"":" & allPageNum & ",""allRec"":"&allRecNum&",""datas"":[" & retValue &"]}" 
	retValue ="[" & retValue &"]"
	'Call WriteFile("b.txt",retValue)
	Response.Write(retValue)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose
	
ElseIf operType="16" Then '历史数据导出XML
	Call LoginPowerJudge(2)
	startTime =Request.QueryString("dateStart")
	endTime =Request.QueryString("dateEnd")
	playerId =Request.QueryString("id")
	'Call WriteFile("fs.txt",playerId)
	fWhere = " where userCurrentState=3"
	If playerId<>"" Then
		'If Not CheckNumCharOK(playerId) Then
		'	Response.Write("{""code"":301}")
		'	Response.End()
		'End If
		fWhere =fWhere &" and userAccount='"&playerId&"'"
	End If
	If startTime<>"" Then
		If Not isDate(startTime) Then
			Response.Write("{""code"":302}")
			Response.End()
		End If
		fWhere =fWhere &" and userUpDeskTime>='"&startTime&"'"
	End If
	If endTime<>"" Then
		If Not isDate(endTime) Then
			Response.Write("{""code"":303}")
			Response.End()
		End If
		fWhere =fWhere &" and userUpDeskTime<='"&endTime&"'"
	End If
	
	Call OpenDataBase
	Dim projectName,dataRsString,allDataRsString
	projectName="序号,桌号,上桌时间,来源局头,玩家ID,初始分数,局末分数"
	
	RecCount=Conn.Execute("select count(0) from CG_d_user_desk"& fWhere)(0)
	iii =1
	FileName = "xlsx/DataList"&GetRandomID18&".xls"
	
	dataRsString=""
	Set dataRs =Conn.Execute("Select id,userUpDeskTime,[userHeader],[userAccount],[userInitPoint],userendPoint,userDeskNo from CG_d_user_desk"& fWhere)
	Do While Not dataRs.Eof
		dataRsString=dataRsString & "<Row>"&vbcrlf
		dataRsString=dataRsString &ProcessColXMlData(dataRs(0),1)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(6),3)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(1),4)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(2),3)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(3),3)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(4),1)
		dataRsString=dataRsString &ProcessColXMlData(dataRs(5),1)
		dataRsString=dataRsString &"</Row>" &vbcrlf
		
		dataRs.MoveNext
	Loop
	allDataRsString =WriteExcelFile(RecCount,7,"统计表","",projectName)
	allDataRsString =Replace(allDataRsString,"{trueDataString}",dataRsString)
	'清理目录
	'DeleteFolder("./xlsx")
	'CreateFolder("./xlsx")
	Set fso = CreateObject("Scripting.FileSystemObject")
	set f=fso.CreateTextFile(server.mappath(FileName),True,True) '常见一个要输出的文本文件
	f.write allDataRsString
	f.close
    set fso=Nothing
	'downloadFile(FileName)

	Response.Write("{""code"":"""&FileName&"""}")
	'Response.Write(FileName)
	dataRs.Close

	Set dataRs = Nothing
	Call connClose	
	
ElseIf operType="18" Then '管理员确认或者拒绝上分操作
	'1确认 2拒绝
	Call LoginPowerJudge(2)
	id			=request.QueryString("id")
	operResult	=request.QueryString("t")
	deskNo		=request.QueryString("zh")
	If operResult="1" and deskNo="" Then
		Response.Write("{""code"":110}")'桌号为空
		Response.end
	End If
	Call OpenDataBase
	'获取上分详情
	Dim userAccount,userHeader,userPoint
	Set dataRsPoint=Conn.Execute("select * from CG_d_addPoint_info where id=" & id & " and auditState=0")
	If Not dataRsPoint.Eof Then'如果确实有此上分记录
		userAccount = dataRsPoint("userAccount")
		userHeader 	= dataRsPoint("userHeader")
		userPoint 	= dataRsPoint("userAddPoint")
		
		If operResult="1" Then '同意上分
			'Set dataRsAccount=Conn.Execute("select ID from CG_d_user_info where userAccount='"&userAccount&"'")
			'If Not dataRsAccount.Eof Then
				Conn.Execute("update CG_d_user_info set userBalances=userBalances+"&userPoint&",lastUpTime=getdate() where userAccount='"&userAccount&"'")
			'Else
			'	Conn.Execute("insert into CG_d_user_info(userAccount,userHeader,userBalances) values('"&userAccount&"','"&userHeader&"',"&userPoint&")")
			'End If
			'获取用户余额
			userBalances =Conn.Execute("select userBalances from CG_d_user_info where userAccount='"&userAccount&"'")(0)
			'写上分记录
			Conn.Execute("insert into CG_d_point_rec(userAccount,operType,changePoint,userBalances,operAccount,userDeskNo) values('"&userAccount&"','上分',"&userPoint&","&userBalances&",'"&userHeader&"','"&deskNo&"')")
			'写系统日志
			Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&userAccount&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】同意了账号【"&userAccount&"】的上【"&userPoint&"】分请求','#5DE85D','"&userHeader&"')")
			'更新未下桌记录的初始分数
			Conn.Execute("update CG_d_user_desk set userInitPoint="&userBalances&" where userAccount='"&userAccount&"' and userDownDeskTime is null")
			
			'以管理员最终输入的桌号为准，修改桌号
			Conn.Execute("update CG_d_user_desk set userDeskNo='"&deskNo&"' where userAccount='"&userAccount&"' and userCurrentState=0 and userHeader='"&userHeader&"'")
			'判断账号是否已经上桌
			isNotOnDesk=Conn.Execute("select Count(0) from CG_d_user_desk where userAccount='"&userAccount&"' and userCurrentState=0")(0)
			If isNotOnDesk>0 Then
				'写上桌日志
				Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&userAccount&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】已同意账号【"&userAccount&"】上桌','#5DE85D','"&userHeader&"')")
			End If
			'管理员同意上分后自动上桌
			Conn.Execute("update CG_d_user_desk set userCurrentState=2,userUpDeskTime=getdate(),userSubmitTime=getdate(),lastChangeTime=getdate() where userAccount='"&userAccount&"' and userCurrentState=0")
			'dataRsAccount.Close
			'Set dataRsAccount = Nothing
		Else'拒绝上分
			Conn.Execute("insert into CG_d_log_info(userAccount,logContent,showColor,toWho) values('"&userAccount&"','管理员【"&Session(G_SessionPre&"_Mem_Name")&"】拒绝了账号【"&userAccount&"】的上【"&userPoint&"】分请求','#f00','"&userHeader&"')")
			'删除上桌数据记录
			'Conn.Execute("delete from CG_d_user_desk where userAccount='"&userAccount&"' and userCurrentState=0")
		End If
		'更新上分记录状态
		Conn.Execute("update CG_d_addPoint_info set auditState="&operResult &",userDeskNo='"&deskNo&"' where id=" & id & " and auditState=0")
	Else
		dataRsPoint.Close
		Set dataRsPoint = Nothing
		Call connClose
		Response.Write("{""code"":104}")'参数ID不存在
		Response.end
	End If
	
	Response.Write("{""code"":0}")'成功
	
	dataRsPoint.Close
	Set dataRsPoint = Nothing
	Call connClose
	Response.End()
	
ElseIf operType="100" Then'返回注册账号列表
	Call LoginPowerJudge(3)

	Call OpenDataBase
	Set dataRs=Conn.Execute("select id,userAccount,userLevel from CG_d_admin_info where userLevel<3 order by id desc")
	Do While Not dataRs.Eof
		retValue =retValue & ",{""id"":"&dataRs("id")&",""ua"":"""&dataRs("userAccount")&""",""ul"":"&dataRs("userLevel")&"}"
		dataRs.MoveNext
	Loop
	If Len(retValue)>1 Then retValue=right(retValue,len(retValue)-1)
	retValue ="[" & retValue &"]"
	Response.Write(retValue)
	dataRs.Close
	Set dataRs = Nothing
	Call connClose

ElseIf operType="101" Then'设置账号权限
	Call LoginPowerJudge(3)
	Dim userId,userLevel
	userId = Request.QueryString("id")
	userLevel=Request.QueryString("ul")
	If userId="" Or userLevel="" Then
		Response.Write("{""code"":501}")'参数错误
		Response.End()
	End If
	userId =Cint(userId)
	userLevel = Cint(userLevel)
	If userLevel>2 Then
		Response.Write("{""code"":502}")'非法设置权限
		Response.End()
	End If
	Call OpenDataBase
	Conn.Execute("update CG_d_admin_info set userLevel="&userLevel&" where id="&userId)
	Call connClose
	Response.Write("{""code"":0}")
End If

%>