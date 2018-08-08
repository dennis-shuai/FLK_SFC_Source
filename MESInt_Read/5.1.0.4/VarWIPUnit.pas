unit VarWIPUnit;

interface

uses Classes,Stdctrls,Graphics,Extctrls,Inifiles;

Function PADR(mString:String; mLength:WORD; mChar:String):String;
Function PADL(mString:String; mLength:WORD; mChar:String):String;
Procedure ReadINI;
Procedure WriteINI;

Var ServerString,DownLoadPath,BackupPath:String;
    FactoryID : String;
    FactoryName : String;
    TimeSection : Integer;

    FTP_Proxy : Boolean;
    FTP_Proxy_Port,FTP_Port : Integer;
    FTP_Proxy_Host,FTP_HOST,
    FTP_TimeOut,FTP_UserID,FTP_Pwd,FTP_Dir : ShortString;
    FTP_Errormessage,FTP_Message : String;
    FTP_Error : Boolean;
    FTP_FileCount : Integer;
    FTP_Login_Dir : String;
    FTP_Connect : Boolean;

Const sDot = #1;

implementation

Procedure ReadINI;
Var INIname : String; vIniFile : TIniFile;
begin
  INIname := '.\SAJET.INI';
  vInifile := Tinifile.Create(INIname);
  ServerString := vIniFile.ReadString('CONNECT','SERVER','N/A');
  DownLoadPath := vIniFile.ReadString('PATH','DOWN LOAD','N/A');
  BackupPath := vIniFile.ReadString('PATH','BACKUP','N/A');
  TimeSection := vIniFile.ReadInteger('TIMER','TIME SECTION',30);
  FTP_Proxy := vIniFile.ReadBool('FTP','FTP_Proxy',False);
  FTP_Proxy_Host := vIniFile.ReadString('FTP','FTP_Proxy_Host','');
  FTP_Proxy_Port := vIniFile.ReadInteger('FTP','FTP_Proxy_Port',21);
  FTP_HOST := vIniFile.ReadString('FTP','FTP_HOST','');
  FTP_Port := vIniFile.ReadInteger('FTP','FTP_Port',21);
  FTP_TimeOut := vIniFile.ReadString('FTP','FTP_TimeOut','');
  FTP_UserID := vIniFile.ReadString('FTP','FTP_UserID','');
  FTP_Pwd := vIniFile.ReadString('FTP','FTP_Pwd','');
  FTP_Dir := vIniFile.ReadString('FTP','FTP_Dir','');

  vInifile.Free;
end;

Procedure WriteINI;
Var INIname : String; vIniFile : TIniFile;
begin
  INIname := '.\SAJET.INI';
  vInifile := Tinifile.Create(INIname);
  ServerString := vIniFile.ReadString('CONNECT','SERVER','N/A');
  vIniFile.WriteString('PATH','DOWN LOAD',DownLoadPath);
  vIniFile.WriteString('PATH','BACKUP',BackUpPath);
  vInifile.Free;
end;

Function PADR(mString:String; mLength:WORD; mChar:String):String;
Var mI : Byte;
begin
   For mI:=Length(mString) to mLength-1 do mString := mString + mChar[1];
   Result := mString;
end;

Function PADL(mString:String; mLength:WORD; mChar:String):String;
Var mI : Byte;
begin
   For mI:=Length(mString) to mLength-1 do mString := mChar[1]+mString;
   Result := mString;
end;

end.
