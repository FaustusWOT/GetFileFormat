Unit INTUtils;
interface
CONST MAX_LONGINT : Longint = 2147483647;
	MAX_INT : integer = 32767;
Function lDoOverload(Value : longint;iOverLoad : integer):longint;
Function iDoOverload(Value : integer;iOverLoad : integer):integer;
implementation

Function lDoOverload(Value : longint;iOverLoad : integer):longint;
Var R1,R2,R : Double;
Begin
	try
		R1 := Value;
		R2 := iOverload;
		R2 := (R2+100) / 100;
		R := (R1 * R2) + 0.5;
		if R > MAX_LONGINT Then
			R := MAX_LONGINT;
		Result := Trunc(R);
	except
		Result := -Value;
	end;
End;
Function iDoOverload(Value : integer;iOverLoad : integer):integer;
Var R1,R2,R : Double;
Begin
	try
		R1 := Value;
		R2 := iOverload;
		R2 := (R2+100) / 100;
		R := (R1 * R2) + 0.5;
		if R > MAX_INT Then
			R := MAX_INT;
		Result := Trunc(R);
	except
		Result := -Value;
	end;
End;
end.