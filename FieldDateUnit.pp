{$mode objfpc}{$H+}
Unit FieldDateUnit;
Interface
Uses RootFieldUnit,Classes;
Type TFieldDate = class (TRootFieldType)
				lDateMasks : TStringList;			
				Constructor Create;
				Function UpdateData(sData : String):Boolean;override;
				Function GetTypeString:String;override;
				Function CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;override;
				Function getTypeName:string;override;
				Function isShablonPresent(sTestShablon : String):Boolean;
			end;
Implementation
Uses StrDataFormats,SysUtils,DateField;
Constructor TFieldDate.Create;
Begin
	inherited Create;
	lDateMasks := TStringList.Create;
	lDateMasks.Add('YYYYMMDD');
	lDateMasks.Add('YYYYDDMM');
	lDateMasks.Add('MMYYYYDD');
	lDateMasks.Add('DDYYYYMM');
	lDateMasks.Add('MMDDYYYY');
	lDateMasks.Add('DDMMYYYY');
	lDateMasks.Add('YYYY-MM-DD');
	lDateMasks.Add('YYYY-DD-MM');
	lDateMasks.Add('MM-YYYY-DD');
	lDateMasks.Add('DD-YYYY-MM');
	lDateMasks.Add('MM-DD-YYYY');
	lDateMasks.Add('DD-MM-YYYY');
	lDateMasks.Add('YYYY.MM.DD');
	lDateMasks.Add('YYYY.DD.MM');
	lDateMasks.Add('MM.YYYY.DD');
	lDateMasks.Add('DD.YYYY.MM');
	lDateMasks.Add('MM.DD.YYYY');
	lDateMasks.Add('DD.MM.YYYY');
	lDateMasks.Add('YYYY/MM/DD');
	lDateMasks.Add('YYYY/DD/MM');
	lDateMasks.Add('MM/YYYY/DD');
	lDateMasks.Add('DD/YYYY/MM');
	lDateMasks.Add('MM/DD/YYYY');
	lDateMasks.Add('DD/MM/YYYY');
	lDateMasks.Add('YYYY MM DD');
	lDateMasks.Add('YYYY DD MM');
	lDateMasks.Add('MM YYYY DD');
	lDateMasks.Add('DD YYYY MM');
	lDateMasks.Add('MM DD YYYY');
	lDateMasks.Add('DD MM YYYY');
	lDateMasks.Add('YYYYMMMDD');
	lDateMasks.Add('YYYYDDMMM');
	lDateMasks.Add('MMMYYYYDD');
	lDateMasks.Add('DDYYYYMMM');
	lDateMasks.Add('MMMDDYYYY');
	lDateMasks.Add('DDMMMYYYY');
	lDateMasks.Add('YYYY-MMM-DD');
	lDateMasks.Add('YYYY-DD-MMM');
	lDateMasks.Add('MMM-YYYY-DD');
	lDateMasks.Add('DD-YYYY-MMM');
	lDateMasks.Add('MMM-DD-YYYY');
	lDateMasks.Add('DD-MMM-YYYY');
	lDateMasks.Add('YYYY.MMM.DD');
	lDateMasks.Add('YYYY.DD.MMM');
	lDateMasks.Add('MMM.YYYY.DD');
	lDateMasks.Add('DD.YYYY.MMM');
	lDateMasks.Add('MMM.DD.YYYY');
	lDateMasks.Add('DD.MMM.YYYY');
	lDateMasks.Add('YYYY/MMM/DD');
	lDateMasks.Add('YYYY/DD/MMM');
	lDateMasks.Add('MMM/YYYY/DD');
	lDateMasks.Add('DD/YYYY/MMM');
	lDateMasks.Add('MMM/DD/YYYY');
	lDateMasks.Add('DD/MMM/YYYY');
	lDateMasks.Add('YYYY MMM DD');
	lDateMasks.Add('YYYY DD MMM');
	lDateMasks.Add('MMM YYYY DD');
	lDateMasks.Add('DD YYYY MMM');
	lDateMasks.Add('MMM DD YYYY');
	lDateMasks.Add('DD MMM YYYY');
	lDateMasks.Add('YYMMDD');
	lDateMasks.Add('YYDDMM');
	lDateMasks.Add('MMYYDD');
	lDateMasks.Add('DDYYMM');
	lDateMasks.Add('MMDDYY');
	lDateMasks.Add('DDMMYY');
	lDateMasks.Add('YY-MM-DD');
	lDateMasks.Add('YY-DD-MM');
	lDateMasks.Add('MM-YY-DD');
	lDateMasks.Add('DD-YY-MM');
	lDateMasks.Add('MM-DD-YY');
	lDateMasks.Add('DD-MM-YY');
	lDateMasks.Add('YY.MM.DD');
	lDateMasks.Add('YY.DD.MM');
	lDateMasks.Add('MM.YY.DD');
	lDateMasks.Add('DD.YY.MM');
	lDateMasks.Add('MM.DD.YY');
	lDateMasks.Add('DD.MM.YY');
	lDateMasks.Add('YY/MM/DD');
	lDateMasks.Add('YY/DD/MM');
	lDateMasks.Add('MM/YY/DD');
	lDateMasks.Add('DD/YY/MM');
	lDateMasks.Add('MM/DD/YY');
	lDateMasks.Add('DD/MM/YY');
	lDateMasks.Add('YY MM DD');
	lDateMasks.Add('YY DD MM');
	lDateMasks.Add('MM YY DD');
	lDateMasks.Add('DD YY MM');
	lDateMasks.Add('MM DD YY');
	lDateMasks.Add('DD MM YY');
	lDateMasks.Add('YYMMMDD');
	lDateMasks.Add('YYDDMMM');
	lDateMasks.Add('MMMYYDD');
	lDateMasks.Add('DDYYMMM');
	lDateMasks.Add('MMMDDYY');
	lDateMasks.Add('DDMMMYY');
	lDateMasks.Add('YY-MMM-DD');
	lDateMasks.Add('YY-DD-MMM');
	lDateMasks.Add('MMM-YY-DD');
	lDateMasks.Add('DD-YY-MMM');
	lDateMasks.Add('MMM-DD-YY');
	lDateMasks.Add('DD-MMM-YY');
	lDateMasks.Add('YY.MMM.DD');
	lDateMasks.Add('YY.DD.MMM');
	lDateMasks.Add('MMM.YY.DD');
	lDateMasks.Add('DD.YY.MMM');
	lDateMasks.Add('MMM.DD.YY');
	lDateMasks.Add('DD.MMM.YY');
	lDateMasks.Add('YY/MMM/DD');
	lDateMasks.Add('YY/DD/MMM');
	lDateMasks.Add('MMM/YY/DD');
	lDateMasks.Add('DD/YY/MMM');
	lDateMasks.Add('MMM/DD/YY');
	lDateMasks.Add('DD/MMM/YY');
	lDateMasks.Add('YY MMM DD');
	lDateMasks.Add('YY DD MMM');
	lDateMasks.Add('MMM YY DD');
	lDateMasks.Add('DD YY MMM');
	lDateMasks.Add('MMM DD YY');
	lDateMasks.Add('DD MMM YY');
End;

Function TFieldDate.UpdateData(sData : String):Boolean;
Var i : Integer;
	sMask : String;
Begin
//	Writeln('TestingData ',sData);
	I := 0;
	if lDateMasks.Count = 0 Then Exit(False);
	While I < lDateMasks.Count Do Begin
		sMask := lDateMasks[I];
		if Not(ParseDateStr(sData,sMask) in [DATE_OK,DATE_EMPTY]) Then Begin
//			Writeln('Delete mask '+sMask);
			lDateMasks.Delete(I)
		End else Inc(I);
	End;
	if lDateMasks.Count = 0 Then Exit(False);
	UpdateData := True;
End;

Function TFieldDate.GetTypeString:String;
Var I : Integer;
Begin
	Result := 'datetime (';
	If lDateMasks.Count > 0 Then
		For I := 0 To lDateMasks.Count-1 Do Begin
			If I <> 0 Then Result := Result + ',';
			Result += #39+lDateMasks[I]+#39;
		End;
	Result += ')';
End;

Function TFieldDate.CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;
Var I : Integer;
Begin
	If ((sFieldType = 'datetime') or (sFieldType = 'smalldatetime')) Then Begin
		I := 0;
		While I < lDateMasks.Count Do Begin
			if lDateMasks[I] <> sFieldInfo Then Begin
				Writeln(Output,lDateMasks[I],' <> ',sFieldInfo);
				lDateMasks.Delete(I)
			End Else
				Inc(I);
		End;
		Exit(lDateMasks.Count > 0);
	End;
	Exit(False);
End;

Function TFieldDate.getTypeName:string;
Begin
	GetTypeName := 'TFieldDate';
End;

Function TFieldDate.isShablonPresent(sTestShablon : String):Boolean;
Var I : Integer;
Begin
	if lDateMasks.Count > 0 Then
		For I := 0 To lDateMasks.Count - 1 Do Begin
			If lDateMasks[I] = sTestShablon Then Exit(true);
		End;
	isShablonPresent := False;
End;


End.