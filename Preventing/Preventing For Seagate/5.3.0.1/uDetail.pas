unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus,IniFiles;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    label1: TLabel;
    Label2: TLabel;
    Editwo: TEdit;
    Editpallet: TEdit;
    panlMessage: TLabel;
    PanelLine: TPanel;
    PanelShift: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    PanelProcessName: TPanel;
    PanelTerminal: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure label1Click(Sender: TObject);
  private
    { Private declarations }
    Function  GetTerminalID : Boolean;
    Function  Getsystime: TdateTime;
  public
    { Public declarations }
    UpdateUserID,UserNo : String;
    G_sTerminalID,G_sProcessID,G_sPDLineID : String;
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uDllForm;
{$R *.DFM}

Function TfDetail.Getsystime: TdateTime;
begin
  with QryTemp do
  begin
    close;
    Params.Clear;
    CommandText :=' SELECT SYSDATE FROM DUAL  ';
    open;
    Result := FieldByName('SYSDATE').asDateTime ;
  end;
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;


procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
  if G_sTerminalID='' then exit;
  if (trim(editwo.Text)='') or (trim(editpallet.Text)='') then exit;
  with Sproc do
  begin
    try
      Close;
      DataRequest('SAJET.KEY_Preventing_Seagate');
      FetchParams;
      Params.ParamByName('tterminalid').AsString :=G_sTerminalID;
      Params.ParamByName('tnow').AsDateTime :=Getsystime;
      Params.ParamByName('TWO').AsString := editWO.Text;
      Params.ParamByName('TPALLET').AsString :=Editpallet.text;
      Params.ParamByName('TEMPID').AsString :=fDllForm.UpdateUserID;
      Execute;
      panlMessage.Caption := Params.ParamByName('TRES').AsString;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        panlMessage.Caption := Editpallet.Text +' OK ';
        panlMessage.Font.Color := clBlue;
        editpallet.SelectAll ;
        editpallet.SetFocus ;
      end else
      begin
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editpallet.SelectAll ;
        editpallet.SetFocus ;
      end;
    finally
      Close;
    end;
  end;
end;


Function TfDetail.GetTerminalID : Boolean;
begin
  Result := False;
  With TIniFile.Create('SAJET.ini') do
  begin
     G_sTerminalID := ReadString('Preventing','Terminal','');
     Free;
  end;
  If G_sTerminalID = '' Then
  begin
     MessageDlg('Terminal not be assign !!',mtError, [mbCancel],0);
     Exit;
  end;
  With QryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'TERMINALID', ptInput);
      CommandText := 'Select A.PROCESS_ID,A.TERMINAL_NAME,B.PROCESS_NAME,C.PDLINE_NAME '+
                     '      ,A.PDLINE_ID '+
                     'From  SAJET.SYS_TERMINAL A,'+
                          ' SAJET.SYS_PROCESS B, '+
                          ' SAJET.SYS_PDLINE C '+
                      'Where   A.TERMINAL_ID = :TERMINALID '
                        +  ' AND A.PROCESS_ID = B.PROCESS_ID '
                        +  ' AND A.PDLINE_ID = C.PDLINE_ID ';
      Params.ParamByName('TERMINALID').AsString := G_sTerminalID ;
      Open;
      If RecordCount <= 0 Then
      begin
        Close;
        MessageDlg('Terminal data error !!',mtError, [mbCancel],0);
        Exit;
      end;
      G_sProcessID := FieldByName('PROCESS_ID').AsString;
      G_sPDLineID := FieldByName('PDLINE_ID').AsString;
      PanelProcessName.Caption := FieldbyName('Process_Name').AsString;
      PanelTerminal.Caption := FieldByName('Terminal_Name').AsString;
      PanelLine.Caption := FieldByName('PDLINE_NAME').AsString;
    finally
      Close;
    end;
  end;
  Result := True;
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
   editwo.Clear ;
   editwo.SetFocus ;
   editpallet.Clear ;
 if not GetTerminalID then exit;
  with Qrytemp do
  begin
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'USERID', ptInput);
    CommandText :=' SELECT EMP_NO FROM SAJET.SYS_EMP '
                 +' WHERE EMP_ID = :USERID AND ROWNUM=1 ';
    Params.ParamByName('USERID').AsString :=UpdateUserID;
    open;
    UserNo := FieldByName('EMP_NO').asString;
    //Get Shift Name
    close;
    Params.Clear;
    Params.CreateParam(ftString	,'PdlineID', ptInput);
    commandText:=' select a.shift_name '+
                 ' from sajet.sys_shift a,sajet.sys_pdline_shift_base b '+
                 ' where b.shift_id=a.shift_id and b.pdline_id=:PdlineID '+
                 '   and b.ACTIVE_FLAG=''Y'' and rownum=1 ';
    Params.ParamByName('PdlineID').AsString:=G_sPDLineID;
    open;
    if RecordCount=1 then
      PanelShift.Caption:=FieldByName('shift_name').AsString
    else
    begin
      MessageDlg('The Line'+'''s Shift not Define !!',mtError, [mbCancel],0);
      exit;
    end;
    close;
  end;
end;

procedure TfDetail.label1Click(Sender: TObject);
begin
   editwo.Text := UpdateUserID;
end;

end.
