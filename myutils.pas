unit MyUtils;

{$mode objfpc}{$H+}
{$define CONSOLE}

interface

uses
  Classes, SysUtils;


Type TDecimalOptions = Record
				chRDec : Char;
				chRFrac : Char;
			End;

Function linesplit(Var D : Array Of String;S : String;sDiv : Char):Integer;
Function Split(Var D : Array Of String;S : String;sDiv : String):Integer;
Function L0(w : Integer):String;
Function GetDateTime:String;
Function UnQuote(S : String):String;
Function UnHTMLQuote(S : String):String;
Function UnExcelQuote(S : String):String;
Procedure AddWithComma(Var S : String;sNewStr : String);
Function UTF8Length(S : String):Integer;
Function DecodeDate(sShablon,sDate : ShortString):ShortString;
Function getIntFromStr(S : ShortString):Integer;
Function TestFileName(sFileName : ShortString;sTest : ShortString;Var sShablon,SInner : ShortString):Boolean;
Function AppendStrIntoFile(sFileName,sMsg : String):Boolean;
Function sCurrentDateTime:String;
Function CountSplit(S : String;sDiv : Char):Integer;
Function MassReplace(S : String;sFrom,sTo : String):String;
Function GetDecimalOptions(S : String) : TDecimalOptions;
Function GetFieldOptions(S : String) : String;

implementation

uses dos
{$ifndef CONSOLE}
, LazUTF8
{$endif}
;

Function UTF8Length(S : String):Integer;
Begin
  {$ifdef CONSOLE}
	UTF8Length := Length(S);
  {$else}
	UTF8Length := LazUTF8.UTF8Length(S);
  {$endif}
End;


Function linesplit(Var D : Array Of String;S : String;sDiv : Char):Integer;
Var I,L,H,J : Integer;
    bInQuote : Boolean;
Begin
     if S = '' Then Exit(-1);
	L := Low(D); H := High(D);
	I := L;J := 1;D[I] := '';
	bInQuote := False;
	While True Do Begin
		if S[J] = '"' then begin
			if bInQuote Then Begin
				if S[J+1] = '"' Then Begin
					D[I] += '"';
					inc(J);
				end else bInQuote := False;
			end else bInQuote := True;
		end else
			if S[J] = sDiv Then begin
				If bInQuote Then
					D[I] += s[J]
				else begin
					Inc(I);
					D[I] := '';
				end;
			End else D[I] += S[J];
		inc(J);
		if I > H Then Break;
		if J > Length(S) Then Break;
	End;
	lineSplit := I;
End;

Function CountSplit(S : String;sDiv : Char):Integer;
Var I : Integer;
    bInQuote : Boolean;
Begin
	bInQuote := False;
	Result := 0;
	For I := 1 To Length(S) Do Begin
		if S[I] = '"' Then
			bInQuote := Not(bInQuote)
		Else
			if ((S[I] = sDiv) And Not(bInQuote)) Then
				Inc(Result);
	End;
End;


Function Split(Var D : Array Of String;S : String;sDiv : String):Integer;
Var L,H,iPos : Integer;

Procedure AddLine (S1 : String);
Begin
	if L <= H Then D[L] := UnQuote(S1);
	Inc(L);
	System.Delete(S,1,length(S1));
	if System.Copy(S,1,Length(sDiv)) = sDiv Then
		System.Delete(S,1,length(sDiv));
End;
Begin
	L := Low(D);H := High(D);
	While True Do begin
		iPos := Pos(sDiv,S);
		if iPos > 0 Then Begin
			AddLine(System.Copy(S,1,iPos-1));
		end else begin
			AddLine(S);
			Break;
		end;
	end;
	Split := L-1;
End;

Function L0(w : Integer):String;
Var S : String;
    L : Integer;
Begin
  If ((w >= 0) and (w < 100)) Then L := 2;
  If (w >= 100) Then L := 4;
  Str(W,S);
  while Length(S) < L Do S := '0' + S;
  L0 := S;
end;

Function GetDateTime:String;
Var wYear,wMonth,wDay,wTmp,wHour,wMinute,wSecond : Word;
Begin
  GetDate(wYear,wMonth,wDay,wTmp);
  GetTime(wHour,wMinute,wSecond,wTmp);

  GetDateTime := L0(wDay)+'.'+L0(wMonth)+'.'+L0(wYear)+ ' ' + l0(wHour) + ':'+L0(wMinute)+'.'+L0(wSecond);

end;


Function UnQuote(S : String):String;
Begin
  S := Trim(S);
  if Length(s) >= 2 Then begin
    if ((S[1] in ['"',#39]) and (S[Length(S)] in ['"',#39])) Then
          S := System.Copy(S,2,Length(S) - 2);
  end;
  UnQuote := Trim(S);
end;

Function MassReplace(S : String;sFrom,sTo : String):String;
Var iPos : Integer;
Begin
	repeat
		iPos := Pos (sFrom,S);
		if iPos > 0 Then Begin
			System.Delete(S,iPos,Length(sFrom));
			System.Insert(sTo,S,iPos);
		End;
	until iPos <= 0;
	MassReplace := S;
End;


Function UnHTMLQuote(S : String):String;
Begin
	UnHTMLQuote := MassReplace(MassReplace(S,'&quot;','"'),'&amp;','&');
end;

Function UnExcelQuote(S : String):String;
Begin
	S := UnQuote(S);
	If Length(S) > 0 Then
		While S[1] = chr(39) do Begin
			S := Copy(S,2,length(S));
			If Length(S) = 0 Then Break;
		End;
	UnExcelQuote := S;
	
			
End;


Procedure AddWithComma(Var S : String;sNewStr : String);
Begin
  If S <> '' Then S := S + ', ';
  S := S + sNewStr;
end;

Function DecodeDate(sShablon,sDate : ShortString):ShortString;
Var sYear,sMonth,sDay,sHour,sMin,sSec : ShortString;
    iYear,iMonth,iDay,iHour,iMin,iSec : Integer;
    {iCode,}I : Integer;
Begin
  sYear  := '';
  sMonth := '';
  sDay   := '';
  sHour  := '';
  sMin   := '';
  sSec   := '';
  For I := 1 To Length(sShablon) Do
    Case UpCase(sShablon[I]) Of
    'Y' : sYear  := sYear + sDate[I];
    'M' : sMonth := sMonth + sDate[I];
    'D' : sDay   := sDay + sDate[I];
    'H' : sHour  := sHour + sDate[I];
    'N' : sMin   := sMin + sDate[I];
    'S' : sSec   := sSec + sDate[I];
    end;

  iYear := getIntFromStr(sYear);
  iMonth := getIntFromStr(sMonth);
  iDay := getIntFromStr(sDay);
  iHour := getIntFromStr(sHour);
  iMin := getIntFromStr(sMin);
  iSec := getIntFromStr(sSec);

 if iYear = 0 Then iYear := 1900;
 if iMonth = 0 Then iMonth := 1;
 if iDay = 0 Then iDay := 1;
 if iYear < 50 Then
    iYear := iYear + 2000
 else
   if iYear < 100 Then
      iYear := iYear + 1900;
 DecodeDate := L0(iYear)+'-'+L0(iMonth)+'-'+L0(iDay)+' '+L0(iHour)+':'+L0(iMin)+':'+L0(iSec);
end;

Function getIntFromStr(S : ShortString):Integer;
Var iRes,iCode : Integer;
Begin
 try
   Val(S,iRes,iCode);
 except
   iCode := -1;
 end;
 if iCode <> 0 Then
    iRes := 0;
 GetIntFromStr := iRes;
end;

Function TestFileName(sFileName : ShortString;sTest : ShortString;Var sShablon,SInner : ShortString):Boolean;
Var I,J : integer;
  bMode : Boolean;
Begin
  sInner := '';
  sShablon := '';
  J := 1;I := 1;
  bMode := False;
  While true do Begin
      if sTest[J] = '[' then begin
           bMode := true;
           inc(J);
           continue;
         end;
      if sTest[J] = ']' then begin
           bMode := false;
           inc(J);
           continue;
         end;
    if bMode then begin
       if sTest[J] <>'?' then Begin
              sInner := sInner + sFileName[I];
              sShablon := sShablon + sTest[J];
       end
    end else begin
      if upCase(sFileName[I]) <> upCase(sTest[J]) then exit(False);
    end;
    inc(I);
    inc(J);
    if ((i > Length(sFileName)) Or (j > Length(sTest))) then
       break;
  end;
  exit((i > Length(sFileName)) And (j > Length(sTest)));

end;

Function sCurrentDateTime:String;
Var  Year,Month,Day,WDay,H,M,S,D : word;
begin
  GetDate(Year,Month,Day,WDay);
  GetTime(H,M,S,D);
  sCurrentDateTime := Format('%.4d%.2d%.2d%.2d%.2d%.2d',[Year,Month,Day,H,M,S,D]);
End;


Function AppendStrIntoFile(sFileName,sMsg : String):Boolean;
Var FT : Text;
Begin
	AppendStrIntoFile := True;
{$IFOPT I+} 
{$define GIC}
{$else}
{$UNDEF GIC}
{$ENDIF}

{$ifdef GIC}{$I-}{$endif}
	AssignFile(FT,sFileName);
{$ifdef GIC}{$I+}{$endif}
	if IOResult <> 0 Then Exit(False);
{$ifdef GIC}{$I-}{$endif}
	Append(FT);
{$ifdef GIC}{$I+}{$endif}
	if IOResult <> 0 Then Exit(False);
{$ifdef GIC}{$I-}{$endif}
{	While Length(sMsg) > 250 Do Begin
		Writeln(FT,System.Copy(sMsg,1,250)+'...');
		System.Delete(sMsg,1,250);
	end;}
	Writeln(FT,sMsg);
{$ifdef GIC}{$I+}{$endif}
	if IOResult <> 0 Then Exit(False);
{$ifdef GIC}{$I-}{$endif}
	CloseFile(FT);			
{$ifdef GIC}{$I+}{$endif}
	if IOResult <> 0 Then Exit(False);
End;

Var S : String = 'DESCRIPTION (#38,'+#39+'.'+#39+') other data...';
	iStart : Integer;

Function GetStrChar(S : String):Char;
Var Code,iCode : Integer;
Begin
	If Length(S) = 1 Then Exit(S[1]);
	If S[1] = '#' Then Begin
		Val(Copy(S,2,255),Code,iCode);
		if iCode <> 0 Then Exit(#0)
		Else Exit(Chr(Code));
	End Else Exit(S[1]);
End;

{Function GetDecimalOptions(S : String) : TDecimalOptions;
Var sTmp : String;
	sD : Array[0..2] Of String;
	i,iStart : Integer;
Begin
	Result.chRDec := #0;
	Result.chRFrac := #0;

	if linesplit(sD,getFieldOptions(S),',') <> 1 Then Exit;
	sD[0] := UnQuote(sD[0]);
	sD[1] := UnQuote(sD[1]);
	Result.chRDec := GetStrChar(sD[0]);
	Result.chRFrac := GetStrChar(sD[1]);
End;
}
Function GetFieldOptions(S : String) : String;
Var sTmp : String;
	i,iStart : Integer;
Begin
	Result := '';
	iStart := Pos('(',S);
	If iStart <= 0 Then Exit;
	sTmp := Copy(S,iStart+1,(Length(S) - iStart));
	iStart := Pos(')',sTmp);
	If iStart <= 0 Then Exit;
	Delete(sTmp,iStart,(length(sTmp) - iStart)+1);
	GetFieldOptions := sTmp;
End;
{
Function GetStrChar(S : String):Char;
Var Code,iCode : Integer;
Begin
	If Length(S) = 1 Then Exit(S[1]);
	If S[1] = '#' Then Begin
		Val(Copy(S,2,255),Code,iCode);
		if iCode <> 0 Then Exit(#0)
		Else Exit(Chr(Code));
	End Else Exit(S[1]);
End;
}
Function GetDecimalOptions(S : String) : TDecimalOptions;
Var sTmp : String;
	sD : Array[0..2] Of String;
	i,iStart : Integer;
Begin
	Result.chRDec := #0;
	Result.chRFrac := #0;
	sTMP := S;
	While true Do Begin
		iStart := Pos('(',sTmp);
		If iStart <= 0 Then Break;
		sTmp := Copy(sTmp,iStart+1,(Length(sTmp) - iStart));
	End;
	iStart := Pos(')',sTmp);
	If iStart <= 0 Then Exit;
	Delete(sTmp,iStart,(length(sTmp) - iStart)+1);
	if linesplit(sD,sTmp,',') <> 1 Then Exit;
	sD[0] := UnQuote(sD[0]);
	sD[1] := UnQuote(sD[1]);
	Result.chRDec := GetStrChar(sD[0]);
	Result.chRFrac := GetStrChar(sD[1]);
End;


end.

