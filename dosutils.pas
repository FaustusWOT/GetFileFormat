unit dosutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


Function DeleteFile(sFolder,sFileName : String):Boolean;
Function FolderExists(SFolderName : String):Boolean;
Function GetFileNameWithExt(sFileName,sFileExt : String):String;
//Function MoveToBackup(sFileName,sInputFolder,sOutputFolder : String):Boolean;
Function NormalizeFolder(sFolderName : String):String;
Function getTempFolder:String;
Function GetFileName(sFullFileName : String):String;
Function FileSize(sFileName : String):Longint;
Function GetObjectAttr(SObjectName : String):Integer;
implementation

uses Windows,dos,MyStrUtils;

Function GetObjectAttr(SObjectName : String):Integer;
Var Sr : SearchRec;
Begin
//	Writeln(sObjectName);
	if Right(sObjectName,1) = '\' Then DeleteRight(sObjectName,1);
//	Writeln(sObjectName);
	FindFirst(sObjectName,AnyFile,Sr);
	if DosError <> 0 then GetObjectAttr := -1
	Else GetObjectAttr := Sr.Attr;
End;


Function GetFileName(sFullFileName : String):String;
Var
    sFolder : DirStr;
    sName : NameStr;
    sExt : ExtStr;
Begin
	FSplit(sFullFileName,sFolder,sName,sExt);
	GetFileName := sName+sExt;
End;


Function DeleteFile(sFolder,sFileName : String):Boolean;
Begin
  DeleteFile := SysUtils.DeleteFile(NormalizeFolder(sFolder)+sFileName);
end;

Function FolderExists(SFolderName : String):Boolean;
Var Dir : SearchRec;
Begin
	If sFolderName [Length(sFolderName)] = '\' Then begin
		sFolderName := System.Copy(sFolderName,1,Length(sFolderName) - 1);
		if sFolderName[Length(sFolderName)] in ['.','\'] Then Exit(true);
	end;

	FindFirst(sFolderName,Directory,Dir);
	FolderExists := (DosError=0);
	FindClose(Dir);
end;

Function GetFileNameWithExt(sFileName,sFileExt : String):String;
Var	sFolder : DirStr;
	sName : NameStr;
	sExt : ExtStr;
	i : Integer;
Begin
// Сбоит при использовании в программе LConvEncoding.
{	fSplit(sFileName,sFolder,sName,sExt);
	if Length(sFileExt) > 0 Then
		If system.copy(sFileExt,1,1) <> '.' Then sFileExt := '.'+sFileExt;
	
	GetFileNameWithExt := NormalizeFolder(sFolder)+sName + sFileExt;
}
// Более тупой, но более надежный алгоритм.
	If ((length(sFileExt) > 0) And (sFileExt[1] <> '.')) Then sFileExt := '.'+sFileExt;
	I := Length(sFileName);
// Ищем с конца первый символ, который не может быть в имени файла
	While I > 0 Do Begin
		If sFileName[I] in ['.','/','\',':'] Then break;
		Dec(I);
	End;	
// По результату в I либо индекс найденного символа, либо 0 - если таковых не найдено.
	If ((I <> 0) and (sFileName[I] = '.')) Then
// Если найдена точка то удаляем из имени файла расшиерение по точку включчительно.
		Delete(sFileName,I,(Length(sFileName) - I) + 2);
	Result := sFileName+sFileExt;
end;
{
Function MoveToBackup(sFileName,sInputFolder,sOutputFolder : String):Boolean;
Var	sInFile,sOutFile : String;
	p1,P2 : Array[0..1024] Of Char;
	dErrorCode : DWORD;
Begin
	MoveToBackup := True;
	sInFile := sInputFolder+sFileName;
	sOutFile := sOutputFolder+sFileName;
	StrPCopy(P1,sInFile);
	StrPCopy(P2,sOutFile);
	If Not(MoveFile(P1,P2)) Then Begin
		dErrorCode := GetLastError();
		MainLog.PutInfo('Ошибка при копировании принятого архива. Код: '+ Format('%xd',[dErrorCode]));	
		MoveToBackup := False;
	end;
end;
}
Function NormalizeFolder(sFolderName : String):String;
Begin
  If sFolderName = '' Then Exit('');
  If sFolderName[Length(sFolderName)] <> '\' Then sFolderName := sFolderName + '\';
  NormalizeFolder := sFolderName;
end;

Function getTempFolder:String;
Var sTempFolder : String;
Begin
  sTempFolder := GetEnv('TEMP');
  if sTempFolder = '' Then
    sTempFolder := GetEnv('TMP');
  getTempFolder := NormalizeFolder(sTempFolder);
end;

Function FileSize(sFileName : String):Longint;
Var FF : File;

Begin
	Assign(FF,sFileName);
	Reset(FF,1);
	FileSize := system.FileSize(FF);
	Close(FF);
End;

end.

