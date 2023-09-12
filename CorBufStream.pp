{$CODEPAGE CP1251}
{$mode objfpc}{$H+}
{ $define DEBUG_CORBUF}
Unit CorBufStream;
interface
Uses BufTextStreamUnit;
Const MAX_CORRECT_LINES = 10;
Type TCorBufTextStream = 	class(TBufTextStream)
				sOld : String;
				Function ReadCols(iNeedCols : Integer):String;
				Constructor Create(csFileName : String;clBufSize : Longint);
				Function EOF:Boolean; override;
			End;
implementation
Uses SplitPlugin,SysUtils,SettingsUnit,MyStrUtils;
Constructor TCorBufTextStream.Create(csFileName : String;clBufSize : Longint);
Begin
	inherited Create(csFileName,clBufSize);
	sOld := '';
End;

Function LocalTrim(S : String):String;
Begin
	while left(S,1) = ' ' Do Delete(S,1,1);
	while right(S,1) = ' ' Do Delete(S,length(S),1);
	LocalTrim := S;
End;

Function TCorBufTextStream.ReadCols(iNeedCols : Integer):String;
Var sNew : String;
	D : Array[0..110] Of string;
	iNew,iOld : Integer;
	iCnt : Integer;
	I : Integer;
Begin
	if (bErrCRLNCorrect) Then begin
//	Writeln('iNeedCols = ',iNeedCols);
//	Writeln('On start sOld = ',sOld);
	iCnt := 0;
	sNew := '';

	iOld := strsplit(D,sOld);

	While Not(inherited EOF) Do Begin
		inc(iCnt);
		repeat
			sNew := LocalTrim(ReadStr);
			if (inherited EOF) then break;
		until sNew <> '';
//		Writeln('iOld = ',iOld);
//		Writeln('sOld = ',sOld);
//		Writeln('sNew = ',sNew);
		iNew := strsplit(D,sOld+' '+sNew);
//		Writeln('InStr : |',sOld+' '+sNew,'| iNew = ',iNew);
//		For I := 0 to iNew Do
//			Writeln(i:4,' - |'+D[I]+'|');
//		Writeln('iNew = ',iNew);
//		Writeln('sNew = ',sOld+' '+sNew);
		
		If (iOld <= iNeedCols) Then Begin
			If (iNew <= iNeedCols) Then Begin
				if sOld <> '' Then sOld := sOld + ' ';
				sOld := sOld + sNew;
				sNew := '';
				iOld := iNew;
				if iCnt > MAX_CORRECT_LINES Then Begin
					Writeln(Output,'Max correct line!'+sOld+'|');
					Break;
				end;
			End Else Break;
		End Else Break;

	End;

	Result := sOld;
	sOld := sNew;
	end else 
		ReadCols := ReadStr;
End;
Function TCorBufTextStream.EOF:Boolean;
Begin
	if sOld <> '' Then 
		EOF := False
	else 
		EOF := inherited EOF;
End;

End.


