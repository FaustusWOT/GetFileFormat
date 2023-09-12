{$CODEPAGE CP1251}
{$mode objfpc}{$H+}
Unit SplitAll;
Interface
Var iSplitMode : integer = 0;	// 0 - стандартный разбор
								// 1 - модификация для втб (не парные кавычки)
	iQuoteMode : integer = 1;	// 0 - кавычки - обычный символ
					// 1 - кавычки - ограничитель текстовых полей.
Function AllSplit(S : String;Var D : Array of String;ChDiv : Char):Integer;
Function DefaultSetParams(S : String):integer;
Implementation
Uses MyUtils,MyStrUtils;

Function MakeQuoteNorm(S : String):String;
Begin
	While Pos('""',S) > 0 Do Delete(S,Pos('""',S),1);
	S := LTrim(S);
	if (left(S,1) = #39) Then
		Delete (S,1,1);
	MakeQuoteNorm := S;
End;

function SearchInStr(S : String;subStr : String;iStartPos:integer):integer;
Var I : Integer;
begin
	I := iStartPos;
	While Not(Copy(S,I,length(subStr)) = subStr) Do Begin
		inc(I);
		if I > length(S) then break; 
	End;
	SearchInStr := I;
end;

function GetNextSplitPosition(S : String;sDiv : String;iStartPos : Integer):integer;
Var iInQuote : integer;
begin
	If Copy(S,iStartPos,1) = '"' then Begin
		GetNextSplitPosition := SearchInStr(S,'"'+sDiv,iStartPos)+1;
	end else begin
		GetNextSplitPosition := SearchInStr(S,sDiv,iStartPos);
	End;
	
end;

Function AllSplit(S : String;Var D : Array of String;ChDiv : Char):Integer;
Var	bInQuote : Boolean;
	I,iStart,iStop,iCurIDX : Integer;
	chCur,chNext : String;
	
Begin
	For I := Low(D) To High(D) Do D[I] := '';

	if iQuoteMode = 0 Then Begin
		I := 1; bInQuote := False;iStart := 0; iStop := -1;iCurIDX := Low(D);
		while (I <= Length(S)) Do Begin
			if copy(S,I,1) = chDiv Then 
				inc(iCurIDX)
			else
				D[iCurIDX] += copy(S,I,1);
			inc(I);
		end;		
		AllSplit := iCurIDX;
	end else begin
	if iSplitMode = 0 Then Begin
		I := 1; bInQuote := False;iStart := 0; iStop := -1;iCurIDX := Low(D);
		while I <= Length(S) Do Begin
			chCur := Copy(S,I,1);chNext := Copy(S,I+1,1);
			If  chCur = '"' Then Begin
				If chNext = '"' Then Begin
					I := I + 2;
					Continue;
				End else Begin
					bInQuote := Not(bInQuote);
					inc(I);
					Continue;
				End;
			End else if Not(bInQuote) Then begin
				If chCur = chDiv Then Begin
					iStop := I;
					if (iCurIDX <= High(D)) Then Begin
						D[iCurIDX] := MakeQuoteNorm(UnQuote(copy(S,iStart+1,(iStop - iStart) - 1)));
						inc(iCurIDX);
					End else Exit(-1);
//					Write(Space((iStop - iStart)-1),'^');
					iStart := iStop;
					iStop := -1;
				End;
			End;
			Inc(I);
		end;
		iStop := I;
		if (iCurIDX <= High(D)) Then Begin
			D[iCurIDX] := MakeQuoteNorm(UnQuote(copy(S,iStart+1,Length(S) - iStart)));
			inc(iCurIDX);
		End else Exit(-1);
		AllSplit := iCurIDX-1;
	End;
	if iSplitMode = 1 Then Begin
		I := 1; bInQuote := False;iStart := 0; iStop := -1;iCurIDX := Low(D);
		while I <= Length(S) Do Begin
			iStop := GetNextSplitPosition(S,chDiv,I);
			iStart := I;
			if iCurIDX <= High(D) Then Begin
				D[iCurIDX] := MakeQuoteNorm(UnQuote(copy(S,iStart,(iStop - iStart))));
				inc(iCurIDX);
			end
			else
				break;
			I := iStop + 1;
		end;
		AllSplit := iCurIDX-1;
	End;
end;
End;

Function DefaultSetParams(S : String):integer;
Var D : Array[0..110] Of String;
	bError : Boolean;
	iMode1,iMode2,iCode : Integer;
Begin
	bError := false;
	AllSplit(S,D,'*');
	if D[0] <> '' Then Begin
		Val(D[0],iMode1,iCode);
		if iCode <> 0 Then Begin
			Writeln('Parameter ',D[0],' is not digit! Parameters is not set!');
			bError := True;
		End;
	End;
	if D[1] <> '' Then Begin
		Val(D[1],iMode2,iCode);
		if iCode <> 0 Then Begin
			Writeln('Parameter ',D[1],' is not digit! Parameters is not set!');
			bError := True;
		End;
	End;

	If Not(bError) Then Begin
		Writeln(Output,'AllSpliter parameters set:');
		If D[0] <> '' Then Begin
			iSplitMode := iMode1;
			Writeln(Output,'iSplitMode := ',iMode1,';');
		End;
		If D[1] <> '' Then Begin
			iQuoteMode := iMode2;
			Writeln(Output,'iQuoteMode := ',iMode2,';');
		End;
	End;			
End;

End.