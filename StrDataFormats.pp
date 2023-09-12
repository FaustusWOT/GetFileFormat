{ $define DEBUG_INT}
{$mode objfpc}{$H+}
Unit StrDataFormats;
Interface
Const INT_DIV = ['.',',',' ',#160];

Function GetFormatDigital(sData : String; Var iDecLen,iFracLen : Integer;Var ChDiv,ChFrac : Char):Boolean;
Implementation
Uses MyStrUtils;
Function GetFormatDigital(sData : String; Var iDecLen,iFracLen : Integer;Var ChDiv,ChFrac : Char):Boolean;
Type TDivChar = Record
			ChDiv : Char;
			iPosDiv : Integer;
			iNextStep : Integer;
		End;
Var DataDiv : Array[0..100] Of TDivChar;
	I,iDataDivCnt,iDigCount : Integer;
	Ch : Char;
Begin
	GetFormatDigital := True;

	iDecLen := 0;
	iFracLen := 0;
	ChDiv  := #0;
	ChFrac := #0;

	iDataDivCnt := -1;
	sData := Trim(sData);
//	Writeln('|'+sData+'|');
	iDigCount := 0;
	If Length(sData) = 0 Then begin
		iDecLen := 1;
		Exit(True);
	End;

	for I := 1 to Length(sData) Do Begin
		Ch := copy(sData,I,1)[1];
		If Ch In INT_DIV Then Begin
			Inc(iDataDivCnt);
			With DataDiv[iDataDivCnt] Do Begin
				ChDiv := Ch;
				iPosDiv := I;
			End;
		End Else
			case Ch Of
				'-','+' : if I <> 1 then Exit(False);
				'0'..'9' : begin
						Inc(iDigCount);
					End;
				Else
					Begin
					{$ifdef DEBUG_INT}Writeln(Output,'Not digits and +-');{$endif}
						Exit(False);
					End;
			End;
	end;

	if iDataDivCnt >= 0 Then Begin 
		if iDataDivCnt > 0 Then Begin
			For I := 0 To iDataDivCnt-1 Do 
				DataDiv[I].iNextStep := DataDiv[I+1].iPosDiv - DataDiv[I].iPosDiv;
		End;
		DataDiv[iDataDivCnt].iNextStep := (Length(sData) - DataDiv[iDataDivCnt].iPosDiv)+1;
		if iDataDivCnt = 0 then begin
			if ((DataDiv[0].ChDiv = ' ') and (DataDiv[0].iNextStep = 4)) Then Begin
				ChDiv  := DataDiv[0].ChDiv;
				ChFrac := #0;
				iDecLen := iDigCount;
				iFracLen := 0;
			End else If DataDiv[0].ChDiv <> ' ' Then Begin
				ChFrac  := DataDiv[0].ChDiv;
				ChDiv   := #0;
				iDecLen := iDigCount;
				iFracLen := DataDiv[0].iNextStep-1;
			End else Begin
					{$ifdef DEBUG_INT}Writeln('Exit 001');{$endif}
				Exit(False);
			End
		end else begin
			// Проверяю что все, кроме последней, разделители одинаковые и у всех число символов равно 4
			ChFrac := DataDiv[iDataDivCnt].ChDiv;
			ChDiv  := DataDiv[0].ChDiv;
			if ChFrac = ChDiv Then ChFrac := #0;
			For I := 0 To iDataDivCnt Do Begin
				If ((DataDiv[I].ChDiv = ChDiv) and (DataDiv[I].iNextStep <> 4)) Then Begin
					{$ifdef DEBUG_INT}Writeln('Exit 002');{$endif}
					Exit(False);
				End;
				If ((DataDiv[I].ChDiv = ChFrac) and (I<>iDataDivCnt)) Then Begin
					{$ifdef DEBUG_INT}Writeln('Exit 003');{$endif}
					Exit(False);
				End;
			End;
			if DataDiv[iDataDivCnt].ChDiv = ChFrac Then
				iFracLen := DataDiv[iDataDivCnt].iNextStep-1
			Else
				iFracLen := 0;
			iDecLen := iDigCount;
			Exit(True);

		end;
	end else Begin
		ChDiv := #0;
		ChFrac := #0;
		iDecLen := iDigCount;
		iFracLen := 0;
		Exit(True);
	End;
	{$ifdef DEBUG_INT}Writeln('Default Exit:(',iDecLen,'=,=',iFracLen,'=,=',Ord(ChDiv),'=,=',Ord(ChFrac) );{$endif}
	
End;


End.