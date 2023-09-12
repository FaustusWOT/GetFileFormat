Unit DateField;
Interface
Type TDateError = (DATE_OK,DATE_EMPTY,DATE_MASKEMPTY,DATE_LENGTHERROR,DATE_MASKERROR,DATE_NOYEAR,DATE_NOMONTH,DATE_NODAY,DATE_NOHOUR,DATE_NOMIN,DATE_NOSEC,DATE_WRONG);
Function ParseDateStr(S : String;sFieldMask : String;Var iYear,iMonth,iDay,iHour,iMin,iSec : Integer):TDateError;
Function ParseDateStr(S : String;sFieldMask : String):TDateError;
Implementation
Uses SysUtils;
Function ParseDateStr(S : String;sFieldMask : String;Var iYear,iMonth,iDay,iHour,iMin,iSec : Integer):TDateError;
Var sYear,sMonth,sDay,sHour,sMin,sSec : ShortString;
    I : Integer;
Begin
	S := Trim(S);
	if ((S = '') Or (S = '-')) Then Exit(DATE_EMPTY);
	if sFieldMask = '' Then Exit(DATE_MASKEMPTY);

	if Length(S) <> Length(sFieldMask) Then Exit(DATE_LENGTHERROR);

	sYear  := '';
	sMonth := '';
	sDay   := '';
	sHour  := '';
	sMin   := '';
	sSec   := '';
	For I := 1 to Length(sFieldMask) Do
//		if ((S[I] <> sFieldMask[I]) And (sFieldMask[I] <> '?')) then begin
			Case UpCase(sFieldMask[I]) Of
				'Y' : sYear := sYear + S[I];
				'M' : sMonth := sMonth + S[I];
				'D' : sDay := sDay + S[I];
				'H' : sHour := sHour + S[I];
				'N' : sMin := sMin + S[I];
				'S' : sSec := sSec + S[I];
				'?' :;
			else
				If sFieldMask[I] <> S[I] Then Exit(DATE_MASKERROR);
			end;
//		end;
	try
		iYear := StrToInt(sYear);
	except
		Exit(DATE_NOYEAR);
	end;
//	Writeln('sMonth = ',sMonth);
	case sMonth of
		'JAN' : iMonth := 1;
		'FEB' : iMonth := 2;
		'MAR' : iMonth := 3;
		'APR' : iMonth := 4;
		'MAY' : iMonth := 5;
		'JUN' : iMonth := 6;
		'JUL' : iMonth := 7;
		'AUG' : iMonth := 8;
		'SEP' : iMonth := 9;
		'OCT' : iMonth := 10;
		'NOV' : iMonth := 11;
		'DEC' : iMonth := 12;
	else
		try
			iMonth := StrToInt(sMonth);
		except
			Exit(DATE_NOMONTH);
		end;
	end;

	if sDay = '' then
		iDay := 1
	else Begin
		try
			iDay   := StrToInt(sDay);
		except
				Exit(DATE_NODAY);
		end;
	end;

	if ((sHour <> '') Or (sMin <> '')) Then Begin
		try
			iHour   := StrToInt(sHour);
		except
			Exit(DATE_NOHOUR);
		end;
		try
			iMin   := StrToInt(sMin);
		except
			Exit(DATE_NOMIN);
		end;
		if sSec <> '' Then Begin
			try
				iSec   := StrToInt(sSec);
			except
				Exit(DATE_NOSEC);
			end;
		end;
	end else Begin
		iHour	:= -99;
		iMin	:= -99;
		iSec	:= -99;
	end;

	if ((iYear >= 0) And (iYear <= 50)) Then iYear := iYear + 2000;
	if ((iYear >= 51) And (iYear <= 99)) Then iYear := iYear + 1900;
	if Not((iYear >= 1900) and (iYear <= 9999)) Then Exit(DATE_WRONG);
	if Not((iMonth >= 1) and (iMonth <= 12)) Then Exit(DATE_WRONG);
	if ((iMonth in [1,3,5,7,8,10,12]) and Not((iDay >= 1) and (iDay <= 31))) Then Exit(DATE_WRONG);
	if ((iMonth in [4,6,9,11]) and Not((iDay >= 1) and (iDay <= 30))) Then Exit(DATE_WRONG);
	if ((iMonth = 2) and Not((iDay >= 1) and (iDay <= 29))) Then Exit(DATE_WRONG);
{
        If ((sHour <> '') and (sMin <> '')) Then //Begin
		S := Format ('%.4d-%.2d-%.2d %.2d:%.2d:%.2d', [iYear,iMonth,iDay,iHour,iMin,iSec])
	else
		S := Format ('%.4d-%.2d-%.2d', [iYear,iMonth,iDay]);
}
	Exit(DATE_OK);
end;

Function ParseDateStr(S : String;sFieldMask : String):TDateError;
Var iYear,iMonth,iDay,iHour,iMin,iSec : Integer;
Begin
	ParseDateStr := ParseDateStr(S,sFieldMask,iYear,iMonth,iDay,iHour,iMin,iSec);
End;
End.