<%
Function ReplaceStar(f_str)
	If Len(f_str)<3 Then
		ReplaceStar = f_str
	Else
		ReplaceStar=Left(f_str,3)&"**"&right(f_str,2)
	End If
End Function

Function JInt(BigNum,SmallNum)
	Dim f_int
	f_int =BigNum\SmallNum
	If BigNum mod SmallNum >0 Then
		f_int=f_int +1
	End If
	JInt = f_int
End Function

Function CheckAccountOk(f_account)
	Dim OkStr,i
	f_account=LCase(f_account)
	CheckAccountOk=True
	OkStr="1234567890abcdefghijklmnopqrstuvwxyz"
	For i=1 to Len(f_account)
		If InStr(1,OkStr,LCase(Mid(f_account,i,1)))=0 Then
			CheckAccountOk=False
			Exit Function
		End If
	Next
	If InStr(1,"1234567890",left(f_account,1))>0 Then
		CheckAccountOk=False
		Exit Function
	End IF
End Function

Function CheckNumCharOK(f_str)
	Dim OkStr,i
	f_str=LCase(f_str)
	CheckNumCharOK=True
	OkStr="1234567890abcdefghijklmnopqrstuvwxyz"
	For i=1 to Len(f_str)
		If InStr(1,OkStr,LCase(Mid(f_str,i,1)))=0 Then
			CheckNumCharOK=False
			Exit Function
		End If
	Next
End Function


Function GetTitle(str,length)
	on error resume next         
    dim l,c,i,hz,en  
    l=len(str)  
    if l<length then  
        getSubString=str  
    else  
        hz=0  
        en=0  
        for i=1 to l  
            c=asc(mid(str,i,1))  
            if c>=128 or c<0 then   
                hz=hz+1  
            else  
                en=en+1  
            end if  
      
            if en/2+hz>=length then  
                exit for  
            end if  
        next          
        getSubString=left(str,i) & ".."  
    end if  
    if err.number<>0 then err.clear  
End function

Function GetStrLen(f_Str)
	Dim StrLen,t,i,c
	StrLen=len(f_Str)
	t=0
	StrLen=Clng(StrLen)
	for i=1 to StrLen
		c=Abs(Asc(Mid(f_Str,i,1)))
		if c>255 then
			t=t+2
		else
			t=t+1
		end if
	next
	GetStrLen = t
End Function

Function GetCustIp
	Dim f_CustIP
	f_CustIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
	If f_CustIP="" Then
		f_CustIP = Request.ServerVariables("REMOTE_ADDR")
	End If
	GetCustIp = f_CustIP
End Function

Function GetRandomID18()
	Dim TempStr,NowTime
	NowTime = Now()
	TempStr = Right(CStr(Year(NowTime)),2)
	TempStr = TempStr &  Right("0"&CStr(Month(NowTime)),2)
	TempStr = TempStr &  Right("0"&CStr(Day(NowTime)),2)
	TempStr = TempStr &  Timer*100
	GetRandomID18 = TempStr
End Function

Function createRandomString(f_Num)
	Dim allowString,tmpString,rndNum
	'allowString="1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM~!@#$%^*()_+[]{}"
	allowString="23456789qwertyuipasdfghjkzxcvbnm"
	RANDOMIZE Timer
	For i = 1 to f_Num
		rndNum = int(Len(allowString)*rnd+1)
		tmpString =tmpString & mid(allowString,rndNum,1)
	Next
	createRandomString = tmpString
End Function

Function IsNum(f_num)
	IsNum=True
	If f_num="" Then
		IsNum=False
		Exit Function
	End If
	For i_l=1 to Len(f_num)
		If Asc(Mid(f_num,i_l,1))<48 Or Asc(Mid(f_num,i_l,1))>57 Then
			IsNum=False
			Exit Function
		End If
	Next
End Function

Sub ShowErrorInfo(f_Info,f_Url)
	Call connClose
	If f_Url ="0" Then
		Response.Write "<script language=javascript>alert('"&f_Info&"');history.back();</script>"
		Response.end
	ElseIf f_Url="1" Then
		Response.Write "<script language=javascript>alert('"&f_Info&"');window.opener=null;window.close();</script>"
		Response.end
	Else
		Response.Write "<script language=javascript>alert('"&f_Info&"');location.href='"&f_Url&"';</script>"
		Response.end
	End If
End Sub

Sub ExportDataToExcel(f_rs,f_fileName)
	Dim tempStr
	If Not f_rs.Eof Then
		set fs=server.CreateObject("Scripting.FileSystemObject")
		set fs_file=fs.OpenTextFile(server.MapPath(f_fileName),2,True,True)
		FieldsCount=f_rs.Fields.Count
		For i = 0 to FieldsCount-1
			tempStr=tempStr & f_rs.Fields(i).Name & ","
		Next
		fs_file.writeline Left(tempStr,len(tempStr)-1)
		tempStr = ""
		Do While Not f_rs.Eof
			For i = 0 to FieldsCount-1
				tempStr=tempStr & f_rs.Fields(i).Value & ","
			Next
			fs_file.writeline Left(tempStr,len(tempStr)-1)
			tempStr = ""
			f_rs.MoveNext
		Loop
		fs_file.close
		set fs_file=nothing
		set fs=nothing
		ExportDataToExcel=f_fileName
	Else
		ExportDataToExcel=""
	End IF
End Sub

sub WriteFile(f_FileName,f_Content)
	set fs=server.CreateObject("Scripting.FileSystemObject")
	set fs_file=fs.OpenTextFile(server.MapPath(f_FileName),8,True,True)
	fs_file.writeline "访问者IP："&GetCustIp&"-访问时间"& now()&"-" & f_Content 
	fs_file.close
	set fs_file=nothing
	set fs=nothing
End sub

Function formatTimeOut
	dim y,m,d,h,mi,s,n
	n=Now()
	y = CStr(Year(n))
	m = Right("0"&CStr(month(n)),2)
	d = Right("0"&CStr(day(n)),2)
	h = Right("0"&CStr(hour(n)),2)
	mi= Right("0"&CStr(minute(n)),2)
	s = Right("0"&CStr(second(n)),2)
	formatTimeOut = y&"-"&m&"-"&d&" "&h&":"&mi&":"&s
End Function 

Function myReplace(myString)
   myString = Replace(myString,"&","&amp;")
   myString = Replace(myString,"<","&lt;")
   myString = Replace(myString,">","&gt;")
   myString = Replace(myString,"chr(","")
   myString = Replace(myString,"'","&apos;")
   'myString = Replace(myString,";","")
   myReplace = myString
End Function

Function lostDangerChar(myString)
	If myString="" Then 
		lostDangerChar=""
		Exit Function
	End If
	myString = Replace(myString,"&","")
	myString = Replace(myString,"<","")
	myString = Replace(myString,">","")
	myString = Replace(myString,"chr(","")
	myString = Replace(myString,"'","")
	myString = Replace(myString,";","")
	lostDangerChar = myString
End Function

Function CutString(byval A_strString,byval A_intLen,byval A_strAddString) 
	Dim trueLen,retString
	For i = 1 to len(A_strString)
		If AscW(Mid(A_strString,i,1))<256 And AscW(Mid(A_strString,i,1))>0 Then 
			trueLen =trueLen+1
		Else
			trueLen =trueLen+2
		End If
		If trueLen<=A_intLen Then
			retString =retString & Mid(A_strString,i,1)
		Else
			CutString = retString & A_strAddString
			Exit Function
		End IF
	Next
	CutString = retString

End function 

Sub LoginPowerJudge(f_power)
	If Session(G_SessionPre&"_Mem_Name")="" Then
		Response.Write("{""code"":1000}")
		Response.End()
	End If
	If f_power<>"" Then
		If CInt(Session(G_SessionPre&"_Mem_Level"))<>CInt(f_power) Then
			Response.Write("{""code"":1001}")
			Response.End()
		End If
	End If
End Sub

Function WriteExcelFile(f_recCount,f_columnNum,f_workTableName,f_oneRowName,f_titleList)
	WriteExcelFile = "<?xml version=""1.0""  encoding=""gb2312""?>" & vbcrlf &  _
		  "<?mso-application progid=""Excel.Sheet""?>" & vbcrlf &  _
		  "<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""" & vbcrlf &  _
		  "xmlns:o=""urn:schemas-microsoft-com:office:office""" & vbcrlf &  _
		  "xmlns:x=""urn:schemas-microsoft-com:office:excel""" & vbcrlf &  _
		  "xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""" & vbcrlf &  _
		  "xmlns:html=""http://www.w3.org/TR/REC-html40"">" & vbcrlf &  _
		  "<DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">" & vbcrlf &  _
		  "</DocumentProperties>" & vbcrlf &  _
		  "<ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">" & vbcrlf &  _
		  "<ProtectStructure>False</ProtectStructure>" & vbcrlf &  _
		  "<ProtectWindows>False</ProtectWindows>" & vbcrlf &  _
		  "</ExcelWorkbook>" & vbcrlf &  _
		  "<Styles>" & vbcrlf &  _
		  "<Style ss:ID=""Default"" ss:Name=""Normal"">" & vbcrlf &  _
				 "<Alignment ss:Vertical=""Center""/>" & vbcrlf &  _
				 "<Borders/>" & vbcrlf &  _
				 "<Font ss:FontName=""宋体"" x:CharSet=""134"" ss:Size=""12""/>" & vbcrlf &  _
				 "<Interior/>" & vbcrlf &  _
				 "<NumberFormat ss:Format=""@""/>" & vbcrlf &  _
				 "<Protection/>" & vbcrlf &  _
		  "</Style>" & vbcrlf &  _
		  "<Style ss:ID=""sdate"">"& vbcrlf &  _
   		  "<NumberFormat ss:Format=""0_ ""/>"& vbcrlf &  _
  		  "</Style>"& vbcrlf &  _
		  "</Styles>" & vbcrlf &  _
		  "<Worksheet ss:Name="""&f_workTableName&""">" & vbcrlf & _
		  "<Table ss:ExpandedColumnCount="""&f_columnNum&""" ss:ExpandedRowCount="""&(f_recCount+2)&""" x:FullColumns=""1""" & vbcrlf & _
		  "x:FullRows=""1"" ss:DefaultColumnWidth=""54"" ss:DefaultRowHeight=""14.25"">" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""40""/>" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""120""/>" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""100""/>" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""100""/>" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""80""/>" & vbcrlf & _
		  "<Column ss:AutoFitWidth=""1"" ss:Width=""80""/>" & vbcrlf
	If f_oneRowName<>"" Then
		WriteExcelFile= WriteExcelFile&"<Row>" & vbcrlf &"<Cell ss:MergeAcross="""&f_columnNum&"""><Data ss:Type=""String"">"&f_oneRowName&"</Data></Cell></Row>"
	End If 
	If f_titleList<>"" Then
		WriteExcelFile= WriteExcelFile &"<Row>" & vbcrlf
		For m=0 to UBound(split(f_titleList,","))
			WriteExcelFile= WriteExcelFile &"<Cell><Data ss:Type=""String"">"&split(f_titleList,",")(m)&"</Data></Cell>" & vbcrlf 
		Next
		WriteExcelFile= WriteExcelFile &"</Row>" & vbcrlf
	End If
	
	WriteExcelFile= WriteExcelFile &"{trueDataString}" & vbcrlf
	 
	WriteExcelFile= WriteExcelFile & "</Table>" & vbcrlf & _
		  "<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">" & vbcrlf & _
				 "<ProtectObjects>False</ProtectObjects>" & vbcrlf & _
				 "<ProtectScenarios>False</ProtectScenarios>" & vbcrlf & _
		  "</WorksheetOptions>" & vbcrlf & _
		  "</Worksheet>" & vbcrlf & _
		  "</Workbook>" & vbcrlf
End Function

Function ProcessColXMlData(f_data,dataType)
	If Len(f_data)=0 or isnull(f_data) or f_data="" then ProcessColXMlData=""
	Select Case dataType
		case 1 '整型
			 ProcessColXMlData="<Cell><Data ss:Type=""Number"">"&f_data&"</Data></Cell>"& vbcrlf
		case 2 '货币
			 ProcessColXMlData="<Cell><Data ss:Type=""Number"">"&f_data&"</Data></Cell>"& vbcrlf
		case 3 '字符串
			 ProcessColXMlData="<Cell><Data ss:Type=""String"">"&f_data&"</Data></Cell>" & vbcrlf  
		case 4 '日期
			 ProcessColXMlData="<Cell ss:StyleID=""sdate""><Data ss:Type=""String"">"&f_data&"</Data></Cell>"& vbcrlf
	End Select
End Function


'创建目录
Function CreateFolder(strFolderName)
    SET FSO=Server.CreateObject("Scripting.FileSystemObject")
	strFolderName = Server.MapPath(strFolderName)
    IF(FSO.FolderExists(strFolderName) = False) THEN
        FSO.CreateFolder(strFolderName)
    END IF
    SET FSO=NOTHING
END Function
  
'删除目录（文件夹）
Function DeleteFolder(strFolderName)
    SET FSO=Server.CreateObject("Scripting.FileSystemObject")
    strFolderName = Server.MapPath(strFolderName)
	'Response.Write(strFolderName)
	'Response.End()
	IF(FSO.FolderExists(strFolderName)) THEN
        FSO.DeleteFolder(strFolderName)
    END IF
    SET FSO=NOTHING
END Function
  
'删除文件
Function DeleteFile(strFileName)
	strFolderName = Server.MapPath(strFileName)
    SET FSO=Server.CreateObject("Scripting.FileSystemObject")
    IF(FSO.FileExists(strFileName)) THEN
        FSO.DeleteFile(strFileName)
    END IF
    SET FSO=NOTHING
END Function
%>