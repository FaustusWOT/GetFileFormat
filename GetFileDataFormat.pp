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
	Writeln(Output,'������ ������ �� ᮮ⢥�⢨� ⨯�� � ࠧ��୮�� �����. V2.00');
	If Not((ParamCount = 2) Or (ParamCount = 3)) Then Begin
		Writeln(Output,'�ᯮ�짮�����: FileDataTypes.exe <input_file_name> [<����⥫�>] [/FAST]');
		Writeln(Output,#9'/FAST - ������ ०�� (⮫쪮 100000 ����� ��ப)');
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
		Writeln(Output,'��������! ��⨢�஢�� ������� �����! ������������� ⮫쪮 ���� 100000 ��ப 䠩��!');		

	LoadPlugin(sSpliterName);
	Writeln(Output,'������ 䠩� ��� �뢮�� �訡���� ��ப. ',GetFileNameWithExt(sInputName,'.err'));
	Assign(FErr,GetFileNameWithExt(sInputName,'.err'));
	Rewrite(FErr);	
	
	BufText := TCorBufTextStream.Create(sInputName,FILE_BUFFER_SIZE);
	If BufText = Nil Then Begin
		Writeln(Output,'�� ���� ������ 䠩� ',ParamStr(1));
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
	
// �������� ��譨� ⠡��権 � ���� ��ப�
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
		Write(FErr,'��ப� N ');
		Write(FErr,lTotalCnt);
		Writeln(FErr,'. ['+S+']');
		Write('��ப� N ');
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
					Writeln(Output,'��ப� N ',lTotalCnt,'. � ��������� 䠩�� 㪠���� ',iTotalColCnt,' �����, � ������ ��ப� ������� ',iColCnt,' �����. ��ப� ����������. ����� ��ப�:');
					Writeln(FErr,'|'+S+'|');
				end else If lErrorCount = MAX_ERROR_COUNT Then begin
					Writeln(Output,'��᫮ �訡�� � 䠩�� �ॢ�ᨫ� ���ᨬ��쭮 �����⨬�� ���祭��. �뢮� ᮮ�饭�� �� �訡��� ⨯� "� ��������� 䠩�� 㪠���� XXX �����, � � ������ ��ப� ������� YYY �����" �४�饭');
					Writeln(FErr,'��᫮ �訡�� � 䠩�� �ॢ�ᨫ� ���ᨬ��쭮 �����⨬�� ���祭��. �뢮� ᮮ�饭�� �� �訡��� ⨯� "� ��������� 䠩�� 㪠���� XXX �����, � � ������ ��ப� ������� YYY �����" �४�饭');
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
		Writeln(Output,'Error!!!�஠������஢��� ',(R1 / R2)*100:5:2,'% 䠩��. (������ 䠩�� : ',llTotalSize,', �業�� ���⠭��� ���� : ',llTotalReaded,')')
	Else
		Writeln(Output,'�஠������஢��� ',(R1 / R2)*100:5:2,'% 䠩��. (������ 䠩�� : ',llTotalSize,', �業�� ���⠭��� ���� : ',llTotalReaded,')');
		


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

	Writeln(FT,'����⨪� �� �� �� ��������:');
	For I := 0 To iColCnt Do begin
		Writeln(FT,'���� : '+T[I].sFieldName);
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
