{$mode objfpc}{$H+}
Unit FieldTypesListUnit;
Interface
Uses Classes,FieldIntUnit,FieldStrUnit,RootFieldUnit,FieldDateUnit;
Type TFieldTypesList = class(TList)
				Constructor Create;
				Procedure UpdateData(sData : String;Var sDebugMessages : TStringList;lCurrentLine : Longint);
				Function GetTypeString:String;
				Function GetMaxString:String;
				Function getTypedField(sFieldTypeName : String):TRootFieldType;
				Function getStrField:TFieldStr;
				Function getIntField:TFieldInt;
				Function getDateField:TFieldDate;



			End;
Implementation
Constructor TFieldTypesList.Create;
Begin
	inherited Create;
	Add(TFieldStr.Create);
	Add(TFieldInt.Create);
	Add(TFieldDate.Create);
End;

Procedure TFieldTypesList.UpdateData(sData : String;Var sDebugMessages : TStringList;lCurrentLine : Longint);
Var I : Integer;
Begin
	If Count > 0 Then Begin
		I := 0;
		While I < Count Do Begin
			If Not(TRootFieldType(Items[I]).UpdateData(sData)) Then Begin
//				Writeln('Delete from int for |'+sData+'|');
				sDebugMessages.Add('Исключен тип %s в строке %d (%s)',[TRootFieldType(Items[I]).getTypeName,lCurrentLine,sData]);
				TRootFieldType(Items[I]).Destroy;
				Delete(I);
			End else inc(I);
				 
		End;

	End;
End;

Function TFieldTypesList.GetTypeString : String;
Var I : Integer;
Begin
	Result := '';
	If Count > 0 Then Begin
		I := 0;
		While I < Count Do Begin
			If (Result <> '') Then Result := Result + ', ';
			Result := Result + TRootFieldType(Items[I]).GetTypeString;
			inc(I);
		End;

	End;
End;

Function TFieldTypesList.GetMaxString : String;
Var I : Integer;
Begin
	Result := '';
	If Count > 0 Then Begin
		I := 0;
		While I < Count Do Begin
			Result := TRootFieldType(Items[I]).GetMaxString;
			If (Result <> '') Then exit;
			inc(I);
		End;

	End;
End;

Function TFieldTypesList.GetTypedField(sFieldTypeName : String):TRootFieldType;
Var I : Integer;
Begin
	If Count > 0 Then
		For I := 0 To Count - 1 Do
			If TRootFieldType(Items[I]).getTypeName = sFieldTypeName Then
				Exit(TRootFieldType(Items[I]));
	Exit(Nil);
End;

Function TFieldTypesList.getStrField:TFieldStr;
Begin
	getStrField := TFieldStr(GetTypedField('TFieldStr'));
End;
Function TFieldTypesList.getIntField:TFieldInt;
Begin
	getIntField := TFieldInt(GetTypedField('TFieldInt'));
End;
Function TFieldTypesList.getDateField:TFieldDate;
Begin
	getDateField := TFieldDate(GetTypedField('TFieldDate'));
End;


End.