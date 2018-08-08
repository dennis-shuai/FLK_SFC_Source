unit uMessage;

interface

uses
  Windows, ComCtrls, SysUtils, Graphics, StdCtrls, ActiveX  ;

type
  TLogType = (ltOK,ltNG,ltError,ltSys,ltPass);

//訊息顯示
function  uAddMemoMessage(var redtMsg: TRichEdit; strMsg: string; Color: TColor = clBlack): string;
procedure uAddSysMessage(redtSysMsg : TRichEdit; strMsg: string; Color: TColor = clBlack; savetolog: Boolean = True);
procedure uAddOKMessage(redtOKMsg : TRichEdit; strMsg: string; lblOKCnt :TLabel; Color: TColor = clBlack; savetolog: Boolean = True);
procedure uAddNGMessage(redtNGMsg : TRichEdit; strMsg: string; lblNGCnt :TLabel; Color: TColor = clBlack; savetolog: Boolean = True);
procedure uAddErrMessage(redtErrMsg : TRichEdit;strMsg: string; lblErrCnt :TLabel; Color: TColor = clBlack; savetolog: Boolean = True);
procedure uAddCurMessage(redtCurMsg,redtSysMsg : TRichEdit;strMsg: string;
          Color: TColor = clBlack; savetolog: Boolean = True);

procedure uRefreshMessage(redtCurMsg : TRichEdit; TCoordinate : Integer);
procedure FAILShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblErrCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True);
procedure OKShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblOKCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True);
procedure NGShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblNGCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True);

//文件操作
procedure InitLogFile(TFilePath : string);
function CreateLogFile(LogType: TLogType; LogFilePath, LogFileName : string): Integer;
procedure CloseAllFile;
function LogSaveToFile(pFile: Integer; Var sData: String): Boolean;

var
  LogFileName : string;
  Cavs: TCanvas;
  
implementation

var
  OkLogFile,NGLogFile,ErrorLogFile,SysLogFile,PassCountFile: Integer;
  LogFilePath : string;

procedure CreateObjQuery;
begin
  Cavs := TCanvas.Create;
  Cavs.Handle := GetDC(0);
end;

procedure FreeObjQuery;
begin
  FreeAndNil(Cavs);
end;

function CreateLogFile(LogType: TLogType; LogFilePath, LogFileName : string): Integer;
var
  FileName: string;
begin
  Result := 0;
  if not DirectoryExists(LogFilePath) then
  begin
    if not CreateDir(LogFilePath) then
    begin
      exit;
    end;
  end;

  case LogType of
    ltOK:
    begin
      FileName := LogFilePath + '\OKLog';
    end;
    ltNG:
    begin
      FileName := LogFilePath + '\NGLog';
    end;
    ltError:
    begin
      FileName := LogFilePath + '\ErrorLog';
    end;
    ltSys:
    begin
      FileName := LogFilePath + '\SysLog';
    end;
    ltPass:
    begin
      FileName := LogFilePath + '\PASSCOUNT';
    end;
  end;
  if Not DirectoryExists(FileName) then
  begin
    if not CreateDir(FileName) then
    begin
      exit;
    end;
  end;
  if LogType = ltPass then
     FileName := FileName + '\' + Trim(LogFileName)+'.TXT'
  else
     FileName := FileName + '\' + FormatDateTime('YYYYMMDD_HHNNSS',Now)+'.TXT';
  Result := FileCreate(FileName);
end;

procedure CloseAllFile;
begin
  if OkLogFile>0 then
  begin
    FileClose(OkLogFile);
    OkLogFile := -1;
  end;
  if NGLogFile>0 then
  begin
    FileClose(NGLogFile);
    NGLogFile := -1;
  end;
  if ErrorLogFile>0 then
  begin
    FileClose(ErrorLogFile);
    ErrorLogFile := -1;
  end;
  if SysLogFile>0 then
  begin
    FileClose(SysLogFile);
    SysLogFile :=-1;
  end;
  if PassCountFile>0 then
  begin
    FileClose(PassCountFile);
    PassCountFile :=-1;
  end;
end;

procedure InitLogFile(TFilePath : string);
var
  FilePath: string;
begin
  OkLogFile := -1;
  NGLogFile := -1;
  ErrorLogFile := -1;
  SysLogFile := -1;
  PassCountFile := -1;
  FilePath := TFilePath ;     //ExtractFilePath(Application.ExeName)
  FilePath := FilePath + 'LogFile';
  LogFilePath := FilePath;
end;

function LogSaveToFile(pFile: Integer; Var sData: String): Boolean;
var
  strData: string;
  chrData: array[0..499] of Char;
  iLen: integer;
begin
  Result := False;
  if pFile>0 then
  begin
    strData := sData+#13#10;
    iLen := Length(strData);
    ZeroMemory(@chrData,500);
    lstrcpy(chrData,PChar(strData));
    if FileWrite(pFile,chrData,iLen)>0 then
    begin
      Result := True;
    end;
  end;
end;

procedure uAddCurMessage(redtCurMsg,redtSysMsg : TRichEdit; strMsg: string;
          Color: TColor = clBlack; savetolog: Boolean = True);
begin
  redtCurMsg.Lines.Clear ;
  redtCurMsg.Lines.Append( strMsg);
  redtCurMsg.Refresh ;
  redtCurMsg.Font.Color := Color;
  redtCurMsg.SelectAll;
  redtCurMsg.SelAttributes.Color := Color;
  redtCurMsg.SelStart := 1;

  Cavs.Font.Color := Color;
  Cavs.Font.Size := 26;
  Cavs.Font.Style := [fsBold];
  Cavs.Pen.Color := clBlack ;
  Cavs.Brush.Style := bsSolid;
  Cavs.Brush.Color := clBlack;
  Cavs.Rectangle(0,0,1024,60);          //Screen.Width
  Cavs.Brush.Style := bsClear;
  Cavs.TextOut(10,10,strMsg);
  
  if savetolog then
    uAddSysMessage(redtSysMsg,strMsg,Color);
end;

function uAddMemoMessage(var redtMsg: TRichEdit; strMsg: string;
  Color: TColor): string;
var
  iStart,iLen : integer;
  Rstr: string;
begin
  Rstr := '['+FormatDateTime('YYYY/MM/DD HH:NN:SS.ZZZ',Now)+']:'+strMsg;
  iStart := redtMsg.GetTextLen;
  redtMsg.Lines.Add(Rstr);
  redtMsg.SelStart := iStart;
  iLen := 26;
  redtMsg.SelLength := iLen;
  redtMsg.SelAttributes.Color := clBlue;
  redtMsg.SelAttributes.Size := redtMsg.Font.Size;

  redtMsg.SelStart := iStart + iLen;
  iLen := Length(strMsg);
  redtMsg.SelLength := iLen;
  redtMsg.SelAttributes.Color := Color;
  redtMsg.SelAttributes.Size := redtMsg.Font.Size;
  redtMsg.SelStart := redtMsg.GetTextLen;
  redtMsg.Refresh;
  Result := Rstr;
end;

procedure uAddSysMessage(redtSysMsg : TRichEdit; strMsg : string; Color: TColor; savetolog: Boolean );
var
  str01: string;
begin
  str01 := uAddMemoMessage(redtSysMsg,strMsg,Color);
  if savetolog then
  begin
    if SysLogFile<=0 then   //保存到文件中
      SysLogFile := CreateLogFile(ltSys,LogFilePath,LogFileName);
    LogSaveToFile(SysLogFile,str01);
  end;
end;

procedure uAddOKMessage(redtOKMsg : TRichEdit; strMsg: string; lblOKCnt :TLabel; Color: TColor = clBlack; savetolog: Boolean = True);
var
  str01: string;
begin
  str01 := uAddMemoMessage(redtOKMsg,strMsg,Color);
  lblOKCnt.Caption := Trim(IntToStr(StrToInt(Trim(lblOKCnt.Caption))+1));
  if savetolog then
  begin
    if OkLogFile<=0 then    //保存到文件中
      OkLogFile := CreateLogFile(ltOK,LogFilePath,LogFileName);
    LogSaveToFile(OkLogFile,str01);
  end;
end;

procedure uAddNGMessage(redtNGMsg : TRichEdit; strMsg: string; lblNGCnt :TLabel; Color: TColor; savetolog: Boolean);
var
  str01: string;
begin
  str01 := uAddMemoMessage(redtNGMsg,strMsg,Color);
  lblNGCnt.Caption := Trim(IntToStr(StrToInt(Trim(lblNGCnt.Caption))+1));
  if  savetolog  then
  begin
    if NGLogFile<=0 then   //保存到文件中
      NGLogFile := CreateLogFile(ltNG,LogFilePath,LogFileName);
    LogSaveToFile(NGLogFile,str01);
  end;
end;

procedure uAddErrMessage(redtErrMsg : TRichEdit; strMsg: string; lblErrCnt :TLabel; Color: TColor; savetolog: Boolean);
var
  str01: string;
begin
  str01 := uAddMemoMessage(redtErrMsg,strMsg,Color);
  lblErrCnt.Caption := Trim(IntToStr(StrToInt(Trim(lblErrCnt.Caption))+1));
  if savetolog then
  begin
    if ErrorLogFile<=0 then    //保存到文件中
      ErrorLogFile := CreateLogFile(ltError,LogFilePath,LogFileName);
    LogSaveToFile(ErrorLogFile,str01);
  end;
end;

procedure FAILShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblErrCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True );
begin
  uAddCurMessage(redtCurMsg,redtSysMsg,'FAIL,'+strMsg,Color, savetolog);
  uAddErrMessage(redtErrMsg,'FAIL,'+strMsg,lblErrCnt,Color, savetolog);
end;

procedure OKShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblOKCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True );
begin
  uAddCurMessage(redtCurMsg,redtSysMsg,'OK,'+strMsg,Color, savetolog);
  uAddOKMessage(redtErrMsg,'OK,'+strMsg,lblOKCnt,Color, savetolog);
end;

procedure NGShowMessage(redtCurMsg,redtSysMsg,redtErrMsg : TRichEdit; strMsg: string; lblNGCnt : TLabel ; Color: TColor = clBlack; savetolog: Boolean = True );
begin
  uAddCurMessage(redtCurMsg,redtSysMsg,'NG,'+strMsg,Color, savetolog);
  uAddNGMessage(redtErrMsg,'NG,'+strMsg,lblNGCnt,Color, savetolog);
end;

procedure uRefreshMessage(redtCurMsg : TRichEdit; TCoordinate : Integer );
var
s1: string;
begin
  s1 := redtCurMsg.Text;
  redtCurMsg.SelectAll;
  Cavs.Font.Color :=  redtCurMsg.SelAttributes.Color;
  redtCurMsg.SelStart := 1;
  Cavs.Font.Size := 26;
  Cavs.Font.Style := [fsBold];
  Cavs.Brush.Style := bsSolid;
  Cavs.Brush.Color := clBlack;
  Cavs.Rectangle(0,0,TCoordinate,60);         //Screen.Width
  Cavs.Brush.Style := bsClear;
  Cavs.TextOut(10,10,redtCurMsg.Text);
end;

initialization
  //CoInitialize(nil);
  OleInitialize(nil);
  CreateObjQuery ;

finalization
  OleUnInitialize;
  FreeObjQuery ;
  
end.
