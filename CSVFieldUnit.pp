{$mode objfpc}{$H+}
Unit CSVFieldUnit;
interface
Uses Classes,FieldTypesListUnit,FieldStrUnit,FieldIntUnit,FieldDateUnit,FieldSizeUnit;
Type TCSVField    = class(TObject)
			sFieldName : String;
			TypesList : TFieldTypesList;
			bIsFound : Boolean;
			sBaseFieldType : String;
			sBaseFieldSize : TFieldSize;
			sBaseFieldIdentity : String;
			sBaseFieldInfo : String;
			bIsEmpty : Boolean;
			sDebugMessages : TStringList;
			Constructor Create(csFieldName : String);
			Destructor Destroy;override;
			Procedure UpdateData(sData : String;lCurrentLine : Longint);
			Function  GetTypeString:String;
			Function  GetMaxString:String;
			Function CanUpdate(asFieldType,asFieldSize,asFieldInfo: string):Boolean;
			Procedure FoundInBase(asFieldType,asFieldSize,asFieldInfo: string);
			Function getStrField:TFieldStr;
			Function getIntField:TFieldInt;
			Function getDateField:TFieldDate;
			Procedure WriteDebug(Var FT : Text);
		end;
implementation
Uses RootFieldUnit;
Constructor TCSVField.Create(csFieldName : String);
Begin
	inherited Create;
	sFieldName := csFieldName;
	TypesList := TFieldTypesList.Create;
	bisFound := False;
	bIsEmpty := True;
	sDebugMessages := TStringList.Create();
end;

Destructor TCSVField.Destroy;
Begin
	sDebugMessages.Destroy;
	TypesList.Destroy;
	inherited Destroy;
End;

Procedure TCSVField.UpdateData(sData : String;lCurrentLine : Longint);
Begin
	If bIsEmpty Then
		If sData<>'' Then
			bIsEmpty := False;
	TypesList.UpdateData(sData,sDebugMessages,lCurrentLine);
End;

Function  TCSVField.GetTypeString:String;
Begin
	If bIsEmpty Then
		GetTypeString := '[NULL]'
	Else
		GetTypeString := TypesList.GetTypeString;
End;

Function  TCSVField.GetMaxString:String;
Begin
	If bIsEmpty Then
		GetMaxString := '[NULL]'
	Else
		GetMaxString := TypesList.GetMaxString;
End;

Function TCSVField.CanUpdate(asFieldType,asFieldSize,asFieldInfo: string):Boolean;
Var I : Integer;
Begin
	I := 0;
	While I < TypesList.Count Do Begin
		If Not(TRootFieldType(TypesList[I]).CanUpdate(asFieldType,asFieldSize,asFieldInfo)) Then
			TypesList.Delete(I)
		Else
			Inc(I);
	End;
	Exit(TypesList.Count > 0);
End;

Procedure TCSVField.FoundInBase(asFieldType,asFieldSize,asFieldInfo: string);
Begin
	sBaseFieldType	:= asFieldType;
	sBaseFieldSize	:= TFieldSize.Create(asFieldSize);
	sBaseFieldInfo	:= asFieldInfo;
	bisFound 	:= True;
End;
Function TCSVField.getStrField:TFieldStr;
Begin
	getStrField := TypesList.getStrField; 
End;
Function TCSVField.getIntField:TFieldInt;
Begin
	getIntField := TypesList.getIntField; 
End;
Function TCSVField.getDateField:TFieldDate;
Begin
	getDateField := TypesList.getDateField; 
End;

Procedure TCSVField.WriteDebug(Var FT : Text);
vAR i : Integer;
Begin
	If sDebugMessages.Count <= 0 Then
		Writeln(FT,#9'[NULL]')
	else Begin
		For I := 0 To sDebugMessages.Count - 1 Do
			Writeln(FT,#9+sDebugMessages[i]);

	end;

End;

end.