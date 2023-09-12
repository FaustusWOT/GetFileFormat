{$R GetFileDataFormat.rc}
{$define ERROR_STOP}
{$APPTYPE CONSOLE}
{OSV_05_01072020_30092020_1_END.csv SBERSplit.dll}
{ $define HOME}
{ $define DEBUG_BUILD}
{ $define ERR_FND}
{ $define HEAP_TRC}
{$CODEPAGE CP1251}
{$mode objfpc}{$H+}
Uses {$ifdef HEAP_TRC}HeapTrc,{$endif}MyUtils,SysUtils,CSVFieldUnit,BufTextStreamUnit,dos,{SQLTblUnit,}dosutils,SplitPlugin,CorBufStream,FieldIntUnit{,VC_Unit};//;
Const FILE_BUFFER_SIZE = 1000000;
	DIVISION_CHAR = ';';
	MAX_ERROR_COUNT = 100;
Var BufText : TCorBufTextStream;
    sTitle,S,sOld : String;
	D : Array[0..100] Of String;
	T : Array[0..100] Of TCSVField;

	I,iColCnt,iTotalColCnt : Integer;
	lTotalCnt : Longint;
	FT,FErr : Text;
	lErrorCount : Longint = 0;
	llTotalSize,llTotalReaded : Int64;
        R1,R2 : Double;
	FF : File;
	bWarnStr : Boolean;

Procedure DisplayMessage(sMsg : String);
Begin
	Writeln(Output,sMsg);
End;




Var sInputName,sSpliterName : String;
	bDoFast		: Boolean;

Begin
{$ifdef HEAP_TRC}
	SetHeapTraceOutput(GetFileNameWithExt(ParamStr(1),'.heap'));
	try
{$endif}
	Writeln(Output,'Анализ данных на соотвествие типам и размерности полей. V2.00');
	If Not((ParamCount = 2) Or (ParamCount = 3)) Then Begin
		Writeln(Output,'Использование: FileDataTypes.exe <input_file_name> [<делитель>] [/FAST]');
		Writeln(Output,#9'/FAST - Быстрый режим (только 100000 первых строк)');
{$ifdef ERROR_STOP}
ReadLn;
{$endif}
		Halt;
	End;

	sInputName := '';
	sSpliterName := '';

{$ifdef DEBUG_BUILD}
	bDoFast := True;
{$else}
	bDoFast := False;
{$endif}

	For I := 1 To ParamCount Do Begin
		If Upcase(ParamStr(I)) = '/FAST' Then 
			bDoFast := True
		Else
			If sInputName = '' Then
				sInputName := ParamStr(I)
			Else
				sSpliterName := ParamStr(I);
	End;

	if bDoFast Then
		Writeln(Output,'ВНИМАНИЕ! Активирован БЫСТРЫЙ РЕЖИМ! Анализируются только первые 100000 строк файла!');		

	LoadPlugin(sSpliterName);
	Writeln(Output,'Создаю файл для вывода ошибочных строк. ',GetFileNameWithExt(sInputName,'.err'));
	Assign(FErr,GetFileNameWithExt(sInputName,'.err'));
	Rewrite(FErr);	
	
	BufText := TCorBufTextStream.Create(sInputName,FILE_BUFFER_SIZE);
	If BufText = Nil Then Begin
		Writeln(Output,'Не могу открыть файл ',ParamStr(1));
{$ifdef ERROR_STOP}
ReadLn;
{$endif}
		Halt(1);
	End;

	sTitle := BufText.ReadStr;
	Writeln(FErr,sTitle);
	iTotalColCnt := strsplit(D,sTitle);
{	Writeln('iTotalCount = ',iTotalColCnt);

	For I := Low(D) To (Low(D)+iTotalColCnt)-1 Do
		Writeln(I:5,' - |',D[I],'|');}
	
// Удаление лишних табуляций в конце строки
//	While D[iTotalColCnt] = '' Do Begin
//		Dec(iTotalColCnt);
//		if (iTotalColCnt <= 0) Then Break;
//	End;
//	Writeln('new iTotalCount = ',iTotalColCnt);

	For I := 0 to iTotalColCnt Do T[I] := TCSVField.Create(D[I]);	
	lTotalCnt := 0;
	sOld := '';
	While Not(BufText.EOF) Do Begin
		inc(lTotalCnt);
//		writeln('Line : ',lTotalCnt);
		S := BufText.ReadCols(iTotalColCnt);
//		if ((lTotalCnt >= 5700000) and (lTotalCnt <= 5800000)) Then
//			Writeln(S);
//		write(#10,lTotalCnt:9);
{$ifdef ERR_FND}
		Write(FErr,'Строка N ');
		Write(FErr,lTotalCnt);
		Writeln(FErr,'. ['+S+']');
		Write('Строка N ');
		Write('lTotalCnt = ',lTotalCnt);
		Writeln('. ['+S+']');
{$endif}
		Try
			iColCnt := strsplit(D,S);
//			WriteLn('iColCnt = ',iColCnt);
//			WriteLn('iTotalColCnt = ',iTotalColCnt);
			If iColCnt > iTotalColCnt Then Begin
				While iColCnt > iTotalColCnt Do Begin
					if D[iColCnt] = '' Then Begin
						Dec(iColCnt);
					End Else Break;
					if iColCnt <= 0 Then Break;
				End;
			End else Begin
				While iColCnt < iTotalColCnt Do Begin
					inc(iColCnt);
					D[iColCnt] := '';
				End;
			
			End;
//		Writeln('divide by ',iColCnt);
			If iColCnt <> iTotalColCnt Then Begin
				if lErrorCount < MAX_ERROR_COUNT Then begin
					Writeln(Output,'Строка N ',lTotalCnt,'. В заголовке файла указано ',iTotalColCnt,' полей, в данной строке найдено ',iColCnt,' полей. Строка игнорируется. Текст строки:');
					Writeln(FErr,'|'+S+'|');
				end else If lErrorCount = MAX_ERROR_COUNT Then begin
					Writeln(Output,'Число ошибок в файле превысило максимально допустимое значение. Вывод сообщений об ошибках типа "в заголовке файла указано XXX полей, а в данной строке найдено YYY полей" прекращен');
					Writeln(FErr,'Число ошибок в файле превысило максимально допустимое значение. Вывод сообщений об ошибках типа "в заголовке файла указано XXX полей, а в данной строке найдено YYY полей" прекращен');
					bDoFast := true;
				end;
				inc(lErrorCount);
			End else Begin
				bWarnStr := False;
				For I := 0 To iColCnt Do Begin
					T[I].UpdateData(D[I],BufText.lCurrentLine);
					If Not(bWarnStr) Then
						If TFieldInt.isScientific(D[I]) Then bWarnStr := true;
				End;
				If bWarnStr Then Begin
					Writeln(FErr,S);
					inc(lErrorCount);
				End;
			End;
		Except
			On Err:Exception do Begin
				Writeln(Output,'Inner error on line #',lTotalCnt);
				Writeln(Output,'ERR:'+Err.ToString);
				Break;
			End;
		End;
		If (lTotalCnt Mod 100000) = 0 Then Begin
			Writeln(Output,lTotalCnt ,' lines procesed');
			If bDoFast Then Break;
	
		End;
	End;
	llTotalReaded := BufText.llTotalReaded;
	BufText.Destroy;
	Writeln(Output,'Total lines ',lTotalCnt,' processed.');
	Assign(FF,sInputName);
	Reset(FF,1);
	llTotalSize := System.FileSize(FF);
	Close(FF);
	R1 := llTotalReaded;
	R2 := llTotalSize;
	If (llTotalReaded <> llTotalSize) Then
		Writeln(Output,'Error!!!Проанализировано ',(R1 / R2)*100:5:2,'% файла. (Размер файла : ',llTotalSize,', Оценка прочитанных байт : ',llTotalReaded,')')
	Else
		Writeln(Output,'Проанализировано ',(R1 / R2)*100:5:2,'% файла. (Размер файла : ',llTotalSize,', Оценка прочитанных байт : ',llTotalReaded,')');
		


	Assign(FT,GetFileNameWithExt(sInputName,'.ftype'));
	Rewrite(FT);	
	Writeln(FT,sTitle);
	Writeln(FT,lTotalCnt);
	Writeln(FT,sSpliterName);
	Writeln(FT,iColCnt);
	Writeln(FT,lErrorCount);
	For I := 0 To iColCnt Do
		Writeln(FT,T[I].sFieldName+#9+ T[I].GetTypeString+#9+'|'+T[I].GetMaxString+'|');

	Writeln(FT,sInputName);
	Writeln(FT,llTotalReaded);
	Writeln(FT,llTotalSize);

	Writeln(FT,'Статистика по ИИ по колонкам:');
	For I := 0 To iColCnt Do begin
		Writeln(FT,'Поле : '+T[I].sFieldName);
		T[I].WriteDebug(FT);
	end;


	Close(FT);
	Close(FErr);
	If lErrorCount = 0 Then
		Erase(FErr)
	Else
		Writeln(Output,lErrorCount,' errors found!');
{$ifdef HEAP_TRC}
	finally
		DumpHeap;
	end;
{$endif}
End.
