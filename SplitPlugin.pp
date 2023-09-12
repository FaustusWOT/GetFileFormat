{$define USE_DLL}
{$CODEPAGE CP1251}
{$mode objfpc}{$H+}
Unit SplitPlugin;
Interface
Type 	TStrSplitFunction 	= Function (Var D : Array of string;S : String):integer;
	TCountSplitFunction 	= Function (S : String):integer;
	TSetParamsFunction 	= Function (S : String):integer;

Var 	strsplit : TStrSplitFunction;
	countsplit : TCountSplitFunction;
	SetParams : TSetParamsFunction;

Procedure LoadPlugin(sDLLName : String);
Implementation
Uses Windows,Strings,SplitAll,SysUtils
{$ifndef USE_DLL},SBERSplit{$endif}
;
{$ifdef USE_DLL}
Var DLLInstance : THandle;
	chDiv : Char;
Function DefaultStrSplit(Var D : Array of string;S : String):integer;
Var I : Integer;
Begin
	DefaultStrSplit := AllSplit(S,D,chDiv);
{	Writeln ('----------------------------------------');
	Writeln(S);
	Writeln ('========================================');
	For I := Low(D) To (Low(D)+Result)-1 Do
		Writeln(I:5,' - |',D[I],'|');
	Writeln ('=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=');}
End;

Function DefaultCountSplit(S : String):integer;
Var D : Array[0..100] Of String;
Begin
	 DefaultCountSplit := AllSplit(S,D,chDiv);
End;


Procedure LoadPlugin(sDLLName : String);
Var	P : Array[0..255] of char;
	iPos : Integer;
	sParams : String;
Begin
	if Pos('?',sDLLName) > 0 Then Begin
		iPos := Pos('?',sDLLName);
		sParams := Copy(sDllName,iPos+1,255);
		Delete(sDLLName,iPos,255);
	End else sParams := '';
	if FileExists(sDLLName) Then Begin
		StrPCopy(P,sDLLName);
		DLLInstance := LoadLibrary(P);
		if DLLInstance = 0 then begin
			Writeln(Output,'Can not load ',sDLLName);
			Halt(1);
		End;
		strsplit := TStrSplitFunction(GetProcAddress(DLLInstance, 'strsplit'));
		if @strsplit  = nil then Begin
			FreeLibrary(DLLInstance);
			Writeln(Output,'can not find procedure strsplit');
			Halt(1);
		End;
		countsplit := TCountSplitFunction(GetProcAddress(DLLInstance, 'countsplit'));
		if @countsplit  = nil then Begin
			FreeLibrary(DLLInstance);
			Writeln(Output,'can not find procedure countsplit');
			Halt(1);
		End;
		SetParams := TCountSplitFunction(GetProcAddress(DLLInstance, 'SetParams'));
		Writeln(Output,'Загружен делитель ',sDLLName);
	end else Begin
		If Length(sDLLName) = 1 Then
			chDiv := copy(sDLLName,1,1)[1]
		else if copy(sDLLName,1,1) = '#' then begin
			chDiv := chr(StrToInt(Copy(sDLLName,2,255)));
		end else begin
			Writeln(Output,'Can not load ',sDLLName);
			Halt(1);
		End;
		Writeln('Определен символ разделитель : #',Ord(chDiv));
		strSplit := TStrSplitFunction(@DefaultStrSplit);
		countsplit := TCountSplitFunction(@DefaultCountSplit);
		setParams  := TSetParamsFunction(@DefaultSetParams);
	End;
	If ((@SetParams <> nil) and (sParams <> '')) Then
		SetParams(sParams);
End;
{$else}
Procedure LoadPlugin(sDLLName : String);
Begin
	Writeln(Output,'Загрузка делителя проигнорирована...');
End;

{$endif}
	
initialization
{$ifdef USE_DLL}
	strsplit := nil;
	countsplit := nil;
	DLLInstance := 0;
{$else}
	strsplit := TStrSplitFunction(@strsplitLL);
	countsplit := TCountSplitFunction(@countsplitLL);
{$endif}
finalization
{$ifdef USE_DLL}
	strsplit := Nil;
	countsplit := nil;
	if DLLInstance <> 0 Then
		FreeLibrary(DLLInstance);
{$endif}
End.