Unit FieldSizeUnit;
Interface
Uses Classes;
Type TFieldSize	= 	class(TObject)
				iParams : Array[1..2] Of Integer;
				iParamCount : Integer;
				Constructor Create(aiFirstParam,aiSecondParam : Integer);
				Constructor Create(aiFirstParam : Integer);
				Constructor Create(asParam : String);
				Function DoMax(T : TFieldSize;iOverLoad : Integer):Boolean;
				Function DoMax(sFieldSize : String;iOverLoad : Integer):Boolean;
				Function getFieldSize : String;
				Procedure setFieldSize(S : String);
				property sFieldSize : String read getFieldSize write SetFieldSize;
			End;
Implementation
Uses SysUtils,INTUtils;
Constructor TFieldSize.Create(aiFirstParam,aiSecondParam : Integer);
Begin
	inherited Create;
	iParams[1] := aiFirstParam;
	iParams[2] := aiSecondParam;
	iParamCount := 2;	
End;

Constructor TFieldSize.Create(aiFirstParam : Integer);
Begin
	inherited Create;
	iParams[1] := aiFirstParam;
	iParamCount := 1;	
End;

Function GetFirstParam(sFieldSize : String):Integer;
Var iM,iM1,iM2 : Integer;
Begin
	If sFieldSize = '' Then Exit(0);
	If Pos('(',sFieldSize) <= 0 Then Exit(-99);
	Delete(sFieldSize,1,Pos('(',sFieldSize));
	iM1 := Pos(',',sFieldSize);
	iM2 := Pos(')',sFieldSize);
	if iM1 <= 0 Then iM1 := iM2;
	If iM2 <= 0 Then Exit(-98);
	if iM1 < iM2 Then iM := iM1 else iM := iM2;
	Delete(sFieldSize,iM,255);
	Exit(StrToInt(sFieldSize));
End;                     

Function GetSecondParam(sFieldSize : String):Integer;
Var iM  : Integer;
Begin
	If sFieldSize = '' Then Exit(0);
	If Pos('(',sFieldSize) <= 0 Then Exit(-99);
	Delete(sFieldSize,1,Pos('(',sFieldSize));
	iM := Pos(',',sFieldSize);
	if iM <= 0 Then Exit(-97);
	Delete(sFieldSize,1,iM);
	iM := Pos(')',sFieldSize);
	Delete(sFieldSize,iM,255);
	Exit(StrToInt(sFieldSize));
End;


Constructor TFieldSize.Create(asParam : String);
Begin
	inherited Create;
	iParams[1] := GetFirstParam(asParam);
	iParams[2] := GetSecondParam(asParam);
	if iParams[2] > 0 Then 
		iParamCount := 2 
	else if iParams[1] > 0 Then 
		iParamCount := 1 
	else 
		iParamCount := 0;
End;

Function TFieldSize.DoMax(T : TFieldSize;iOverLoad : Integer):Boolean;
Begin
	DoMax := False;
	if iParams[1] < T.iParams[1] Then Begin
		DoMax := True;
		if iOverLoad > 0 Then
			iParams[1] := iDoOverload(T.iParams[1],iOverLoad)
		Else
			iParams[1] := T.iParams[1];
	End;
	if ((iParamCount = T.iParamCount) And (iParamCount = 2)) Then
		if iParams[2] < T.iParams[2] Then Begin
			DoMax := True;
			if iOverLoad > 0 Then
				iParams[2] := iDoOverload(T.iParams[2],iOverLoad)
			Else
				iParams[2] := T.iParams[2];
	End;
End;

Function TFieldSize.DoMax(sFieldSize : String;iOverLoad : Integer):Boolean;
Var T : TFieldSize;
Begin
	T := TFieldSize.Create(sFieldSize);
	DoMax := DoMax(T,iOverLoad);
	T.Destroy;
End;


Function TFieldSize.getFieldSize : String;
Begin
	case iParamCount Of
		2	:	getFieldSize := Format('(%d.%d)',[iParams[1],iParams[2]]);
		1	:	getFieldSize := Format('(%d)',[iParams[1]]);
	Else
		GetFieldSize := '';
	End;

End;

Procedure TFieldSize.setFieldSize(S : String);
Begin
	If S = '' Then Begin
		iParams[1] := 0;
		iParams[2] := 0;
		iParamCount := 0;
		Exit;
	End;
	iParams[1] := getFirstParam(S);
	iParams[2] := GetSecondParam(S);
	if iParams[2] >= 0 Then iParamCount := 2 else iParamCount := 1;
End;
End.