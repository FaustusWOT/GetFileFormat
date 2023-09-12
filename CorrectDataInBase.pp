{ $define HOME}
{ $define DEBUG_BUILD}
{ $define DEBUG}
{$CODEPAGE CP1251}
{$mode objfpc}{$H+}
Uses ShareMem,MyUtils,SysUtils,SQLdb,mssqlconn,odbcconn,db,CSVFieldUnit,BufTextStreamUnit,dos,SQLTblUnit,SplitPlugin,CorBufStream,MyStrUtils;
Const FILE_BUFFER_SIZE = 1000000;

Var BufText : TCorBufTextStream;
    sTitle,S,sOld : String;
	D : Array[0..100] Of String;
	T : Array[0..100] Of TCSVField;

	I,iColCnt,iTotalColCnt : Integer;
	lTotalCnt,lCurrentLine : Longint;
	FT : Text;
	BT : TBaseTable;
	iBankID : Integer;
	iTM : Integer;
	iFileType : Integer;
	iFileID : Integer;
	FE : Text; // Копия входящего файла со строками только содержащими ошибки
	lCountError : Longint;

FConn : TSQLConnector;
//	BaseData,FileData : TList;

Procedure DisplayMessage(sMsg : String);
Begin
	Writeln(Output,sMsg);
End;


Function isEmptyString(S:String):Boolean;
Var D : Array[0..100] Of String;
	I,iCnt : Integer;
Begin
	iCnt := strsplit(D,S);
	For I := 0 To iCnt Do
		If Trim(D[I]) <> '' Then Exit(False);
	isEmptyString := True;
End;





Begin
	lCountError := 0;
	Writeln(Output,'Импорт данных из CSV файла в таблицу БД. V2.00');
	If ParamCount <> 6 Then Begin
		Writeln(Output,'Использование: '+ParamStr(0)+' <file_name> <table_name> <iBankID> <iTM> <iFileType> <делитель>');
		Writeln(Output,'Если <iTM> и <iFileType> меньше 0, то запись в список принятых файлов не делается. Это позволяет принимать одновременно несколько файлов в разные таблицы, а затем скопировать их в общую командами в SQL');
		Halt;
	End;

	try 
		iBankID := StrToInt(ParamStr(3));
	except
		Writeln(Output,'ERROR! iBankID (ParamStr(3)='#39+ParamStr(3)+#39') is not integer!');
		Halt;
	End;

	try 
		iTM := StrToInt(ParamStr(4));
	except
		Writeln(Output,'ERROR! iTM (ParamStr(4)='#39+ParamStr(4)+#39') is not integer!');
		Halt;
	End;

	try 
		iFileType := StrToInt(ParamStr(5));
	except
		Writeln(Output,'ERROR! iFileType (ParamStr(5)='#39+ParamStr(5)+#39') is not integer!');
		Halt;
	End;

	try 
		LoadPlugin(ParamStr(6));
	except
		Writeln(Output,'ERROR! Can not load plugin (ParamStr(6)='#39+ParamStr(6)+#39')!');
		Halt;
	End;


	FConn:=TSQLConnector.Create(nil);
	FConn.CharSet := 'CP1251';
{$ifdef HOME}
//	FConn.HostName:='DESKTOP-PS9BJID\SQLEXPRESS';
//	FConn.HostName:='DESKTOP-PS9BJID\SQLEXPRESS';
	FConn.ConnectorType:='odbc';
{$else}
	FConn.ConnectorType:='mssqlserver';
	FConn.HostName:='r9979-app052';
{$endif}
	FConn.DatabaseName:='Tax_Mon01';

//	FConn.DatabaseName:='Taxes';
	FConn.UserName:='';
	FConn.Password:='';
	FConn.Transaction:=TSQLTransaction.Create(nil);
	FConn.Connected:=True;
	FConn.Transaction.Action:= caCommit;
//	ProgressBarCreate;
	BT := TBaseTable.Create(FConn,ParamStr(2));
	If BT = Nil Then Begin
		Writeln(Output,'ERROR! Can not read base description!');
		Halt(1);
	End;
	If (BT.Count > 0) Then Begin
		Writeln(Output,'Found ',BT.Count,' fields.');
		If ((iTM > 0) And (iFileType > 0)) Then
			iFileID := BT.AddFileData(ParamStr(1),iBankID,iTM,iFileType)
		Else
			iFileID := -1;
		Assign(FE,ChangeFileExt(ParamStr(1),'.err'));
		Rewrite(FE);
		BufText := TCorBufTextStream.Create(ParamStr(1),FILE_BUFFER_SIZE);
		If BufText = Nil Then Begin
			Writeln(Output,'ERROR! Can not open file ',ParamStr(1));
			Close(FE);
			Erase(FE);
			Halt (1);
		End;
		S := Trim(BufText.ReadStr);
		S := Replace(S,' '#9,#9);
		S := Replace(S,#9' ',#9);

		if Not(BT.TestTitle(S)) Then Begin
			BufText.Destroy;
			Close(FE);
			Erase(FE);
			Writeln(Output,'Header of file is not equal base descrition!');
			Writeln(Output,S);
			Writeln(Output,BT.sTitleLine);
			Halt(2);
		End;
		Writeln(FE,'lLine,',S); // Сохраняем заголовок файла (если в дальнейшем будут ошибки, то err файл позволит легко отладить прием)
		lCurrentLine := 2;
		While Not(BufText.EOF) Do Begin
			S := BufText.ReadCols(BT.iColCount);
//			Writeln('|'+S+'|');
				inc(lCurrentLine);
				If ((lCurrentLine Mod 10000) = 0) Then Begin
					Writeln(Output,lCurrentLine,' lines processed...');
{$ifdef DEBUG}
					Break;
{$endif}
				End;
		End;

		S := BufText.ReadCols(BT.iColCount);
//			Writeln('|'+S+'|');
		If Not(IsEmptyString(S)) Then Begin
			If Not(BT.GetDataFromString(S)) Then Begin
				Writeln(Output,'ERROR! Can not get data at line N',lCurrentLine);
				Writeln(FE,lCurrentLine,',',S);
				inc(lCountError);
			End;
//			Writeln(BT.GetInsertSQL(lCurrentLine));
			If Not(BT.InsertBaseRecord(iFileID,lCurrentLine)) Then Begin
				Writeln(Output,'Error on line #',lCurrentLine);
				Writeln(FE,lCurrentLine,',',S);
				inc(lCountError);
			End;
		End;


		Writeln(Output,lCurrentLine,' lines processed...');
		BufText.Destroy;
		Close(FE);
		if lCountError = 0 Then
			Erase(FE)
		else
			Writeln(Output,lCountError, ' lines with error found!');
	End;
BT.Destroy;	
{$ifdef DEBUG}
Writeln(Output,'Before');
{$endif}
	FreeAndNil(FConn);
{$ifdef DEBUG}
Writeln(Output,'After');
{$Endif}
	Writeln(Output,'All done!');
End.