{$define BUFFERED_READ}
{$define SIZE_TEST}
{$define DEBUG_OPEN}
{$mode objfpc}{$H+}
Unit BufTextStreamUnit;
Interface
Uses Classes;
{$ifdef SIZE_TEST}
Const SIZE_CRLF = 2;
{$endif}
Type TBufTextStream = 	class(TObject)
				private
					FF : Text;
{$ifdef BUFFERED_READ}
					Buf : Pointer;
					lBufSize : LongInt;
{$endif}

				public 
{$ifdef SIZE_TEST}
					llTotalReaded  : int64;
{$endif}
					lCurrentLine : int64;
					Constructor Create(csFileName : String;clBufSize : Longint);
					Destructor Destroy;override;
					Function EOF:Boolean; Virtual;
					Function ReadStr:String; Virtual;
					Procedure NextLineCount; Virtual;
			End;
Implementation
Uses SysUtils;

Constructor TBufTextStream.Create(csFileName : String;clBufSize : Longint);
Begin
	inherited Create;
	Try
{$ifdef BUFFERED_READ}
		lBufSize := clBufSize;
		GetMem(Buf,lBufSize+100);
		If Buf = Nil Then Begin
{$ifdef DEBUG_OPEN}
			Writeln('Not allocated ',lBufSize);
{$endif}
			Fail;
		End;
{$endif}
		Assign(FF,csFileName);
		Reset(FF);
		lCurrentLine := 0;
{$ifdef BUFFERED_READ}
		System.SetTextBuf(FF,Buf^,lBufSize);
{$endif}
{$ifdef SIZE_TEST}
		llTotalReaded := 0;
{$endif}
	except     
{$ifdef DEBUG_OPEN}
			On Err:Exception do Begin
				Writeln(Err.ToString);
				Fail;
			end;
{$else}
		Fail;
{$endif}
	End;
End;

Destructor TBufTextStream.Destroy;
Begin
	Close(FF);
{$ifdef BUFFERED_READ}
	FreeMem(Buf,lBufSize+100);
{$endif}
	inherited Destroy;
End;

Function TBufTextStream.EOF:Boolean;
Begin
	EOF := System.EOF(FF);
End;
Function TBufTextStream.ReadStr:String;
Var S : String;
Begin
	ReadLn(FF,S);
	inc(lCurrentLine);
	NextLineCount;
{$ifdef SIZE_TEST}
	llTotalReaded += Length(S)+SIZE_CRLF;
{$endif}
	ReadStr := S;
End;

Procedure TBufTextStream.NextLineCount; 
Begin
End;
Begin
	CtrlZMarksEOF := False;
End.

