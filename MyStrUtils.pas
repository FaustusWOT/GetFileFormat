{$mode objfpc}{$H+}
Unit MyStrUtils;
Interface
Var MAX_STRING_SIZE : Longint = 2048;

Function WinToDOS(S : String):String;
Function DOStoWin(S : String):String;
Function sCurrentTime: String;
Function isCP1251(S : String):Integer;
Function DblChar(Ch : Char;iCnt : Integer):String;
function DeleteCR(S : String):String;
Function UpperCase(S : String):String;
Function LTrim(S : String):String;
Function RTrim(S : String):String;
Function Trim(S : String):String;
Function GetStringBracket(S : String;sLeft : String;sRight : String):String;
Function Left(S : String; iCnt : Integer):String;
Function Right(S : String;iCnt : Integer):String;
Function Replace(S : String;sFrom,sTo : String):String;
Procedure DeleteRight(Var S : String;iCount : Integer);
Procedure DeleteLeft(Var S : String;iCount : Integer);
//Function Replace(S : String;sFrom,sTo : String):String;
Implementation
Uses Strings,Windows,SysUtils,Dos;

Var P : Pointer;
Function WinToDOS(S : String):String;
Begin
	If P = Nil Then GetMem(P,MAX_STRING_SIZE);
	StrPCopy(P,S);
	ANSIToOEM(P,P);
	Exit(StrPas(P));
End;

Function DOStoWin(S : String):String;
Begin
	If P = Nil Then GetMem(P,MAX_STRING_SIZE);
	StrPCopy(P,S);
	OEMToANSI(P,P);
	Exit (StrPas(P));
End;

Function sCurrentTime: String;
var wYear ,wMonth ,wDay ,wWorkDay : word;
    wHour ,wMin , wSec ,wHSec : word;
	S : String;
begin
	GetDate (wYear,wMonth,wDay ,wWorkDay);
	GetTime (wHour ,wMin , wSec ,wHSec );
	S := Format ('%.2d.%.2d.%.4d %.2d:%.2d.%.2d', [wDay,wMonth,wYear,wHour,wMin,wSec]);
	sCurrentTime := S;
end;

Function isCP1251(S : String):Integer;
Var I,iFirstChar,iWrongCharCount : Integer;
//    sT : ShortString;
    Ch : Char;
Begin
	isCP1251 := 0;
//	sT := UTF8ToCP1251(S);
	iFirstChar := -1;
	iWrongCharCount := 0;
	For I := 1 to Length(S) Do Begin
		Ch := Copy(S,I,1)[1];
		If Ord(Ch) > 127 Then Begin
			If Not(Ch in [#191,#178,#132,#151,#182,#146,#160,#147,#148,#150,#171,#187,#185, #184,#233,#246,#243,#234,#229,#237,#227,#248,#249,#231,#245,#250,#244,#251,#226,#224,#239,#240,#238,#235,#228,#230,#253,#255,#247,#241,#236,#232,#242,#252,#225,#254,#168,#201,#214,#211,#202,#197,#205,#195,#216,#217,#199,#213,#218,#212,#219,#194,#192,#207,#208,#206,#203,#196,#198,#221,#223,#215,#209,#204,#200,#210,#220,#193,#222]) Then Begin
				if iFirstChar < 0 Then iFirstChar := I;
				inc(iWrongCharCount);
			end;
        // #178 óêðàèíñêîå I?
        // #191 - óêðàèíñêîå i ñ äâóìÿ êðàïêàìè...
		end;
	end;
	if iWrongCharCount > 10 Then
		isCP1251 := -iFirstChar
	else
		isCP1251 := 0;
End;

Function DblChar(Ch : Char;iCnt : Integer):String;
Var I : Integer;
    S : String;
Begin
	S := '';
	For I := 1 to iCnt Do S := S + Ch;
	DblChar := S;
End;

Function Replace(S : String;sFrom,sTo : String):String;
Var iPos : Integer;
Begin
	repeat
		iPos := Pos(sFrom,S);
		if iPos > 0 Then begin
			Delete(S,iPos,length(sFrom));
			if sTo <> '' Then
				Insert(sTo,S,iPos);
		End;
	until iPos <= 0;
	Replace := S;
End;


function DeleteCR(S : String):String;
Var iPos : Integer;
Begin
	S := Replace(S,#10,' ');
	S := Replace(S,#13,' ');
	S := Replace(S,#9,' ');
	S := Replace(S,'  ',' ');

	DeleteCR := S;
end;

Function UpperCase(S : String):String;
Var	sSmallChars : String =	'éöóêåíãøùçõúôûâàïðîëäæýÿ÷ñìèòüáþ¸';
	sCapsChars : String =	'ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏÐÎËÄÆÝß×ÑÌÈÒÜÁÞ¨';
	I,iPos : Integer;
Begin
	Result := '';
	For I := 1 to length(S) Do Begin
		iPos := Pos(S[I],sSmallChars);
		if iPos < 1 Then 
			Result := Result + System.UpCase(S[I])
		Else
			Result := Result + sCapsChars[iPos];
	End;
End;

Const EMPTY_CHARS : Set of Char = [' ',#9];

Function LTrim(S : String):String;
Begin
	if Length(S) > 0 then
		while S[1] in EMPTY_CHARS do begin
			Delete (S,1,1);
			if Length(S) = 0 Then break;
		end;
	LTrim := S;
End;

Function RTrim(S : String):String;
Begin
	if Length(S) > 0 then
		while S[Length(S)] in EMPTY_CHARS do begin
			Delete (S,Length(S),1);
			if Length(S) = 0 Then break;
		end;
	RTrim := S;
End;

Function Trim(S : String):String;
Begin
	Trim := LTrim(RTrim(S));
End;

Function GetStringBracket(S : String;sLeft : String;sRight : String):String;
Var I : Integer;
Begin
	i := Pos(sLeft,S);
	If i > 0 Then Delete(S,1,I);
	i := Pos(sRight,S);
	If i > 0 Then Delete(S,I,(Length(S)-I) + 1);
	GetStringBracket := S;
End;

Function Left(S : String; iCnt : Integer):String;
Begin
	Left := Copy(S,1,iCnt);
End;

Function Right(S : String;iCnt : Integer):String;
Begin
	If Length(S) <= iCnt Then
		Right := S
	Else
		Right := Copy(S,(Length(S)+1) - iCnt,iCnt);
End;

{Function Replace(S : String;sFrom,sTo : String):String;
Var iPos : Integer;
Begin
	Result := S;
	While True Do Begin
		iPos := Pos(sFrom,Result);
		if iPos > 0 Then Begin
			Delete(Result,iPos,length(sFrom));
			Insert(sTo,Result,iPos);
		End else break;
	End;
End;
}

Procedure DeleteRight(Var S : String;iCount : Integer);
Begin
	Delete(S,(length(S)-iCount)+1,iCount);
End;
Procedure DeleteLeft(Var S : String;iCount : Integer);
Begin
	Delete(S,1,iCount);
End;


Initialization
	P := Nil;

Finalization
	if P <> Nil Then FreeMem(P);
End.