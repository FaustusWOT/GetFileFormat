Unit SettingsUnit;
{$mode objfpc}{$H+}
Interface
Var
	sBaseType,
	sBaseURL,
	sBaseName,
	sBaseUser,
	sBasePassword	: String;
	iMainLogMode : Integer;
	bErrCRLNCorrect : boolean;
Procedure DisplaySettings;
Implementation
Uses Dos,INIFiles,DosUtils,RootLogsUnit;

Function sBoolean(B : Boolean):String;
Begin
	if B Then Exit('��') else exit('���');
End;
Procedure DisplaySettings;
Begin
	MainLog.PutInfo('������ �� : %s:%s',[sBaseType,sBaseURL]);
	MainLog.PutInfo('���� ������ : %s',[sBaseName]);
	MainLog.PutInfo('�������������� ������ ������ ��������� ������ ������ ������ : %s',[sBoolean(bErrCRLNCorrect)]);
End;


Var	sFolder : DirStr;
	sName : NameStr;
	sExt : ExtStr;
	sIniFileName : String;
	GlobalConfig : TIniFile;
Begin
	FSplit(FExpand(ParamStr(0)),sFolder,sName,sExt);
	sIniFileName := FSearch(sName+'.ini','.;'+sFolder+';'+GetEnv('PATH'));
	GlobalConfig := TIniFile.Create(sINIFileName,[ifoStripComments,ifoStripInvalid,ifoStripQuotes]);
	If GlobalConfig <> Nil Then Begin
		sBaseType	:= GlobalConfig.ReadString('DATABASE','type','odbc');
		sBaseURL	:= GlobalConfig.ReadString('DATABASE','URL','CBRBaseDev');
		sBaseName	:= GlobalConfig.ReadString('DATABASE','Name','');
		sBaseUser	:= GlobalConfig.ReadString('DATABASE','User','');
		sBasePassword	:= GlobalConfig.ReadString('DATABASE','Password','');
		iMainLogMode	:= GlobalConfig.ReadInteger('OPTIONS','MainLOGMode',2);	// ������ ��� - ������������ ���� 0 - � ����� ������������ EXE �����, 1- � ������� ��������
											// ������ ��� - ��� ���� 0 - ��� ���������� �������, 1 - � ����������� �������

		If Not(GlobalConfig.ValueExists('ERRORS','bErrCRLNCorrect')) Then Begin
			GlobalConfig.WriteBool('ERRORS','bErrCRLNCorrect',False);
		End;
		bErrCRLNCorrect	:= GlobalConfig.ReadBool('ERRORS','bErrCRLNCorrect',False);

		GlobalConfig.Destroy;
	end else begin
		Writeln('�� ������ ���� ������������! ������������ ��������� �� ��������� (����������)');
		sBaseType	:= 'odbc';
		sBaseURL	:= 'TestBase';
		sBaseName	:= '';
		sBaseUser	:= '';
		sBasePassword	:= '';
		iMainLogMode    := 2;
		bErrCRLNCorrect	:= False;
	end;
End.
