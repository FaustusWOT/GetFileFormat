{$mode objfpc}{$H+}
Unit FieldStrUnit;
Interface
Uses RootFieldUnit;
Type TFieldStr = class (TRootFieldType)
				iLen : Integer;
				sMaxStr : String;
				Constructor Create;
				Function UpdateData(sData : String):Boolean;override;
				Function GetTypeString:String;override;
				Function CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;override;
				Function getTypeName:string;override;
				Function GetMaxString:String;override;
			end;
Implementation
Uses StrDataFormats,MyStrUtils,SysUtils;
Constructor TFieldStr.Create;
Begin
	inherited Create;
	iLen  := 0;
	sMaxStr := '';
End;

Function TFieldStr.UpdateData(sData : String):Boolean;
Begin
	sData := Trim(sData);
	if length(sData) > iLen Then Begin
		iLen := length(sData);
		sMaxStr := sData;
	end;
	UpdateData := True;
End;
Function TFieldStr.GetTypeString:String;
Begin
	Result := '';
	If iLen <= 1 then Result := 'char';
	If ((iLen > 1) And (iLen <= 50)) Then Result := 'char('+IntToStr(iLen)+')';
	If (iLen > 50) Then Result := 'varchar('+IntToStr(iLen)+')';
End;
Function TFieldStr.CanUpdate(sFieldType,sFieldSize,sFieldInfo: string):Boolean;
Var I : Integer;
Begin
	if ((sFieldType = 'char') Or (sFieldType = 'varchar')) Then Begin
		I := StrToInt(GetStringBracket(sFieldSize,'(',')'));
		If I >= iLen Then Exit(True);
		Writeln(Output,'WRN: Требуется увеличить размерность поля c ',I,' до как минимум ',iLen,' символов.');
	end else exit(false);
End;
Function TFieldStr.getTypeName:string;
Begin
	getTypeName := 'TFieldStr';
End;
Function TFieldStr.GetMaxString:String;
Begin
	GetMaxString := sMaxStr;
End;

End.