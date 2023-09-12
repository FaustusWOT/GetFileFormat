{$mode objfpc}{$H+}
Unit RootLogsUnit;
Interface

Uses Classes,StrUtils;
Type    TLog                = Class(TObject)
					sInfo : String;static;
					sMsg : String;
					Constructor Create;
					Function PutDataIntoLog:Boolean;Virtual;
					Function PostMessage:Boolean;Virtual;
					Function AddMessage(S : String):Boolean;Virtual;
					Procedure PutInfo(S : String);Virtual;
					Procedure PutInfo (S : String;Param : Array Of Const);Virtual;
					Function StoreLogIntoFile(sFileName : String):Boolean;Virtual;Abstract;


					Destructor Destroy;override;
				End;

	TFileLog            = Class(TLog)
				sMainLogName   : String;
				iMainLogMode  	: Integer;

				bFileCreated    : Boolean;

				bAddTimeToInfo : Boolean;

				Constructor Create(spLogName : ShortString;iLogMode : integer;bpAddTimeToInfo : Boolean);
				Function AddMessage(S : String):Boolean;override;
				Function PutDataIntoLog:Boolean;override;

				Destructor  Destroy;Override;
			End;


	TSimpleFunction = Function :Boolean; stdcall;
	TParamFunction = Function (sMsg : String):Boolean;stdcall;

	TWindowLog            = Class(TLog)
				DLLInstance : DWORD;

				fncShowInfoWnd	: TSimpleFunction;
				fncHideInfoWnd	: TSimpleFunction;
				fncClearLog	: TSimpleFunction;
				fncAddMessage	: TParamFunction;
				fncStoreLogIntoFile : TParamFunction;


				Constructor Create(sWinDllName : ShortString);
				Function AddMessage(S : String):Boolean;override;
				Function PutDataIntoLog:Boolean;override;
				Function StoreLogIntoFile(sFileName : String):Boolean;override;

				Destructor  Destroy;Override;
			End;

Var MainLog : TLog;
Implementation
Uses dos,Strings,Windows,MyStrUtils,SysUtils,dosUtils,MyUtils;
Constructor TLog.Create;
Begin
	inherited Create;
	sMsg := '';
	sInfo := 'init';
End;
Function TLog.AddMessage(S : String):Boolean;
Begin
	AddMessage := True;
	Try
		If sMsg <> '' Then sMsg := sMsg + #13#10;
		sMsg := sMsg + S;
	except 
		AddMessage := False;
	End;
End;

Function TLog.PutDataIntoLog:Boolean;
Begin
	PutDataIntoLog := True;
	try	
		if isConsole Then
			Writeln(sMsg)
//		Else
;						
	Except
		PutDataIntoLog := false;
	End;
End;

Function TLog.PostMessage:Boolean;
Begin
	PostMessage := PutDataIntoLog;
	sMsg := '';
End;

Procedure TLog.PutInfo(S : String);
Begin
//	Writeln('sMsg = ',S);
	AddMessage(S);
End;

Destructor TLog.Destroy;
Begin
	if sMsg <> '' Then
		PutDataIntoLog;
	inherited Destroy;
	sInfo := '';
End;

Procedure TLog.PutInfo(S : String;Param : Array Of Const);
Begin
//	Writeln('sMsg1 = ',S);
	PutInfo(Format(S,Param));
End;


Constructor TFileLog.Create(spLogName : ShortString;iLogMode : integer;bpAddTimeToInfo : Boolean);
Var 	sDir : DirStr;
	sName : NameStr;
	sExt : ExtStr;
	FT : Text;
Begin
	bAddTimeToInfo := bpAddTimeToInfo;

	FSplit(FExpand(spLogName),sDir,sName,sExt);
// Первый бит - Расположение лога 0 - В месте расположения EXE файла, 1- В текущем каталоге
// Второй бит - имя лога 0 - Без добавления времени, 1 - С добавлением времени
	Case iLogMode Of
		0 : 	Begin
				sMainLogName := NormalizeFolder(sDir)+sName+'.log';
			End;
		1 : 	Begin
				GetDir(0,sDir);
				sMainLogName := NormalizeFolder(sDir)+sName+'.log';
			End;
		2 : 	Begin
				sMainLogName := NormalizeFolder(sDir)+sName+sCurrentDateTime+'.log';
			End;
		3 : 	Begin
				GetDir(0,sDir);
				sMainLogName := NormalizeFolder(sDir)+sName+sCurrentDateTime+'.log';
			End;
	End;


	bFileCreated	:= False;

	AssignFile(FT,sMainLogName);
	Rewrite(FT);
	if bAddTimeToInfo Then Write(FT,'['+sCurrentTime()+'] ');
	writeln(FT,'Начало работы.');//+spArcFileName);
	CloseFile(FT);

End;

Function TFileLog.AddMessage(S : String):Boolean;
Var sTmp : String;
Begin
	AddMessage := True;
//	Writeln ('AddMessage ^ ',S);
	Try
		if bAddTimeToInfo Then sTmp := '['+sCurrentTime()+'] ' + S else sTmp := S;
//		Writeln ('sTmp ^ ',sTmp);
		AddMessage := inherited AddMessage(sTmp);
		PostMessage;
	except 
		AddMessage := False;
	End;
End;

Function TFileLog.PutDataIntoLog:Boolean;
Begin
	PutDataIntoLog := True;
//	Writeln('PutDataIntoLog ^ ',sMsg);
	try	
		If Not(AppendStrIntoFile(sMainLogName,sMsg)) Then Begin
			if isConsole Then
				Writeln ('Can not add line into file ',sMainLogName)
			else
				MessageBox (0,'Can not add line into file ','Error',0);
			Halt
		End;
		PutDataIntoLog := inherited PutDataIntoLog;
	Except
		PutDataIntoLog := false;
	End;
End;


Destructor  TFileLog.Destroy;
Begin
	PutInfo('Обработка завершена.');
	Inherited Destroy;
End;



Constructor TWindowLog.Create(sWinDllName : ShortString);
Var P : Array[0..255] Of char;
Begin
	inherited Create;

	StrPCopy(P,sWinDLLName);
	DLLInstance := LoadLibrary(P);
	if DLLInstance = 0 then Fail;

	fncShowInfoWnd	:= TSimpleFunction(GetProcAddress(DLLInstance, 'ShowInfoWnd'));
	if @fncShowInfoWnd = nil Then Fail;

	fncHideInfoWnd	:= TSimpleFunction(GetProcAddress(DLLInstance, 'HideInfoWnd'));
	if @fncHideInfoWnd = nil Then Fail;

	fncClearLog	:= TSimpleFunction(GetProcAddress(DLLInstance, 'ClearLog'));
	if @fncClearLog = nil Then Fail;

	fncAddMessage	:= TParamFunction(GetProcAddress(DLLInstance, 'AddMessage'));
	if @fncAddMessage = nil Then Fail;

	fncStoreLogIntoFile	:= TParamFunction(GetProcAddress(DLLInstance, 'StoreLogIntoFile'));
	if @fncStoreLogIntoFile = nil Then Fail;

	If Not(fncShowInfoWnd()) Then Fail;
	If Not(fncClearLog()) Then Fail;
	
End;

Function TWindowLog.AddMessage(S : String):Boolean;
Begin
	AddMessage := fncAddMessage(S);
End;

Function TWindowLog.StoreLogIntoFile(sFileName : String):Boolean;
Begin
	StoreLogIntoFile := fncStoreLogIntoFile(sFileName);
End;

Function TWindowLog.PutDataIntoLog:Boolean;
Begin
	Result := True;
End;

Destructor  TWindowLog.Destroy;
Begin
	fncHideInfoWnd;
	if DLLInstance <> 0 Then
		FreeLibrary(DLLInstance);
	inherited destroy;
End;



initialization
	MainLog := Nil;
Finalization
	If MainLog <> Nil Then  
		if MainLog.sInfo <> '' Then Begin
			MainLog.Destroy;
			MainLog := Nil;
		End;
End.