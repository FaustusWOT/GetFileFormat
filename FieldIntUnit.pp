{$define DEBUG_INT}
{$mode objfpc}{$H+}
Unit FieldIntUnit;
Interface
Uses RootFieldUnit;
Type TFieldInt = class (TRootFieldType)
				ChDec,ChFrac : Char;
				iDec,iFrac : Integer;
				bScientific : Boolean;
				Constructor Create;
				Function UpdateData(sData : String):Boolean;override;
				Function GetTypeString:String;override;
				Function CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;override;
				Function getTypeName:string;override;
				class Function isScientific(S : String):Boolean;
			end;
Implementation
Uses StrDataFormats,SysUtils,MyStrUtils;
Constructor TFieldInt.Create;
Begin
	inherited Create;
	iDec  := 0;
	iFrac := 0;
	chDec := #0;
	chFrac := #0;
	bScientific := False;
End;


class Function TFieldInt.IsScientific(S : String):Boolean;
Var I,iStep : Integer;
	Ch : Char;
Begin
	IsScientific := False;
	try
		If S = '' Then Exit;
		iStep := 1;
		I := 1;
		While I <= Length(S) Do Begin
			Ch := UpCase(S[I]);
//			Writeln('Cur step. Ch = ',Ch,' iStep = ',iStep,' I = ',I);
			Case iStep Of
				1 : 	Begin						// Первый символ числа (возможно + или -) В случае других символов - тут же перехожу к второму шагу
						if Ch In ['+','-'] Then Begin
							Inc(iStep);
							Inc(I);
						End else Inc(iStep);
					End;
				2 :	Begin
						If (Ch In ['0'..'9']) Then Begin
							inc(iStep);
							Inc(I);
						End Else Exit;
					End;
				3 :	Begin
						If (Ch In ['.',',']) Then Begin
							inc(iStep);
							Inc(I);
						End Else	If (Ch = 'E') Then Begin
									inc(iStep,2);				// Нет дробной части! сразу перехожитм к Е!!!
								End else Exit;
					End;
				4 :	Begin
						If (Ch In ['0'..'9']) Then Begin
							Inc(I);
						End Else Inc(iStep);
					End;
				5 :	Begin
						If (Ch = 'E') Then Begin
							Inc(I);
							inc(iStep);
						End Else Exit;
					End;
				6 :	Begin
						If (Ch in ['+','-']) Then Begin
							Inc(I);
							inc(iStep);
						End Else inc(iStep);
					End;
				7 :	Begin
						If (Ch in ['0'..'9']) Then Begin
							Inc(I);
						End Else Exit;
					End;
			End;
		End;
	        isScientific := (iStep = 7);

{	I := 1;

	If (copy(S,I,1)[1] In ['+','-']) Then inc(I);
	If I > Length(S) Then Exit;

	If Not(copy(S,I,1)[1] In ['0'..'9']) Then Exit;
	Inc(I);
	If I > Length(S) Then Exit;

	If Not(UpCase(copy(S,I,1))[1] In [',','.','E']) Then Exit;
	if Not(UpCase(copy(S,I,1))[1] = 'E') Then begin
		Inc(I);
		If I > Length(S) Then Exit;
		If I <= Length(S) Then
			While copy(S,I,1)[1] In ['0'..'9'] Do Begin
				Inc(I);
				If I > Length(S) Then exit;
			End
		Else
			Exit;
		If Not(Upcase(copy(S,I,1))[1] = 'E') Then Exit;
		Inc(i);
	End; 
	If (copy(S,I,1)[1] In ['+','-']) Then inc(I);
	If I <= Length(S) Then Begin
		While copy(S,I,1)[1] In ['0'..'9'] Do Begin
			Inc(I);
			If I > Length(S) Then Break;
		End;
		If I <= Length(S) Then Exit;
	end Else
		Exit;}
	except
		On Err:Exception do Begin
			Writeln(Output,'IsScientific error');
			Writeln(Output,'ERR:'+Err.ToString);
			Writeln(Output,'Test str: '+S);
			Writeln(Output,'Current I: '+IntToStr(I));
			Writeln(Output,'Current iStep: '+IntToStr(iStep));
		End;
		
	end;
End;



Function TFieldInt.UpdateData(sData : String):Boolean;
Var chNewDec,chNewFrac : Char;
	iNewDec,iNewFrac : Integer;
Begin
	
	If Not(GetFormatDigital(sData,iNewDec,iNewFrac,chNewDec,chNewFrac)) Then Begin
		If Not(isScientific(sData)) Then Begin
{$ifdef DEBUG_INT}
			Writeln(Output,'Wrong int in ['+sData+']');
{$endif}
			Exit(False);
		End Else Begin
{$ifdef DEBUG_INT}
			Writeln(Output,'Warrinig int in ['+sData+'] is SCIENTIFIC!');
{$endif}
			bScientific := True;
			Exit(True);

		End;
	End;
	If chDec <> chNewDec Then Begin
		If chDec = #0 Then 
			chDec := chNewDec
		else
			if chNewDec <> #0 then begin
				Writeln(Output,'Разные символы разделители тысяч. Было '+ChDec+'('+IntToStr(Ord(ChDec))+') стало '+ChNewDec+'('+IntToStr(Ord(ChNewDec))+')' );
				Exit(False);
			End;
	End;
	If chFrac <> chNewFrac Then Begin
		If chFrac = #0 Then 
			chFrac := chNewFrac
		else
			if chNewFrac <> #0 then Begin
				Writeln(Output,'Разные символы десятичной точки. Было '+ChFrac+'('+IntToStr(Ord(ChFrac))+') стало '+ChNewFrac+'('+IntToStr(Ord(ChNewFrac))+')' );
				Exit(False);
			End;
	End;
	if iNewDec > iDec Then iDec := iNewDec;
	if iNewFrac > iFrac Then iFrac := iNewFrac;
	UpdateData := True;
End;

Function TFieldInt.GetTypeString:String;
Begin
	If Not(bScientific) Then 
		Result := 'decimal('+IntToStr(iDec)+','+IntToStr(iFrac)+')(#'+IntToStr(Ord(ChDec))+',#'+IntToStr(Ord(ChFrac))+')'
	Else
		Result := 'decimal('+IntToStr(iDec)+','+IntToStr(iFrac)+')(#'+IntToStr(Ord(ChDec))+',#'+IntToStr(Ord(ChFrac))+') *E*';
End;

Function TFieldInt.CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;
Begin
	if (sFieldType = 'money') Then Begin
		If ((iDec <= 19) And (iFrac <= 4)) Then Exit(true);
		Writeln(Output,'WRN: Требуется увеличить размерность поля с типа money (19,4) до как минимум (',iDec,',',iFrac,')');
		Exit(true);
	End;
	if (sFieldType = 'decimal') Then Begin
		If ((iDec <= StrToInt(GetStringBracket(sFieldSize,'(',','))) And (iFrac <= StrToInt(GetStringBracket(sFieldSize,',',')')))) Then Exit(true);
		Writeln(Output,'WRN: Требуется увеличить размерность поля с типа decimal ',sFieldSize,' до как минимум (',iDec,',',iFrac,')');
		Exit(true);
	End;
	Exit(False);	
End;
Function TFieldInt.getTypeName:string;
Begin
	getTypeName := 'TFieldInt';
End;

End.