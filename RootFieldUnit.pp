{$mode objfpc}{$H+}
Unit RootFieldUnit;
interface
Uses Classes;
Type TRootFieldType = class(TObject)
			bIsNullable : Boolean;
			Function UpdateData(sData : String):Boolean;virtual;abstract;
			Function GetTypeString:String;virtual;abstract;
			Function CanUpdate(sFieldType,sFieldSize,sFieldInfo: String):Boolean;Virtual;Abstract;
			Function getTypeName:string;virtual;abstract;
			Function getMaxString:string;virtual;
		end;
implementation
Function TRootFieldType.getMaxString:string;
Begin
	GetMaxString := '';
End;

end.