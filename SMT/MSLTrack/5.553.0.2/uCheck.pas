unit uCheck;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,DB,jpeg,BmpRgn, Buttons, DBClient;

type
  TfCheck = class(TForm)
    ListView1: TListView;
    ListView2: TListView;
    Timer1: TTimer;
    MSLNO: TLabel;
    PDLINE: TLabel;
    PARTNO: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    cmbLine: TComboBox;
    Label13: TLabel;
    Label35: TLabel;
    cmbMSL: TComboBox;
    sbtnStart: TSpeedButton;
    LabStart: TLabel;
    Image2: TImage;
    qryTemp: TClientDataSet;
    sbtnClose: TSpeedButton;
    Image5: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure cmbLineChange(Sender: TObject);
    procedure sbtnStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fCheck: TfCheck;

implementation

uses uManager,uDllform;

{$R *.dfm}

procedure TfCheck.Timer1Timer(Sender: TObject);
var ivv:integer;
begin
  Timer1.Enabled := False;
  with fManager.qryTemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString	,'MSL_NO', ptInput);
    commandtext:=' SELECT A.MSL_NO,C.PART_NO FROM SMT.G_MSL A,'+
                 ' SAJET.SYS_PART C WHERE MSL_NO=:MSL_NO '+
                 ' AND A.PART_ID =C.PART_ID AND ROWNUM=1 ';
    Params.ParamByName('MSL_NO').AsString :=trim(cmbMSL.Text);
    OPEN;
    MSLNO.Caption:=FieldByName('MSL_NO').AsString;
    PDLINE.Caption:=trim(cmbLine.Text);
    PARTNO.Caption:=FieldByName('PART_NO').AsString;

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'MSL_NO', ptInput);
    Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
    CommandText:=' select SLOT_NO FROM SMT.G_MSL WHERE MSL_NO=:MSL_NO '+
                 ' AND SLOT_NO NOT IN(SELECT A.SLOT_NO FROM SMT.G_SMT_STATUS A,'+
                 ' SAJET.SYS_PDLINE B WHERE A.MSL_NO=:MSL_NO AND B.PDLINE_NAME=:PDLINE_NAME '+
                 ' AND A.PDLINE_ID=B.PDLINE_ID ) GROUP BY SLOT_NO ORDER BY SLOT_NO ';
    Params.ParamByName('MSL_NO').AsString :=trim(cmbMSL.Text);
    Params.ParamByName('PDLINE_NAME').AsString :=trim(cmbLine.Text);
    Open;
    ListView1.Items.Clear;
    while not eof do
    begin
      with ListView1.Items.Add do
      begin
        Caption:=FieldByName('SLOT_NO').AsString;
      end;
      fManager.qryTemp.Next;
    end;
  end;
  with fManager.qryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'MSL_NO', ptInput);
    Params.CreateParam(ftString	,'PDLINE_NAME', ptInput);
    CommandText:=' SELECT C.SLOT_NO,C.REEL_NO,A.PART_NO,C.FEEDER_NO,C.IN_TIME,B.EMP_NAME FROM'+
                 ' SAJET.SYS_PART A,SAJET.SYS_EMP B,'+
                 '(SELECT A.SLOT_NO,A.REEL_NO,C.PART_ID,A.FEEDER_NO,A.IN_TIME,A.EMP_ID '+
                 ' FROM SMT.G_SMT_STATUS A,SAJET.SYS_PDLINE B,sajet.g_part_map C '+
                 ' WHERE A.MSL_NO=:MSL_NO AND B.PDLINE_NAME=:PDLINE_NAME '+
                 ' AND A.PDLINE_ID=B.PDLINE_ID AND A.reel_no=C.PART_SN '+
                 ' ORDER BY A.IN_TIME DESC) C WHERE C.PART_ID=A.PART_ID AND'+
                 ' C.EMP_ID=B.EMP_ID(+) ORDER BY IN_TIME DESC';
    Params.ParamByName('MSL_NO').AsString :=trim(cmbMSL.Text);
    Params.ParamByName('PDLINE_NAME').AsString :=trim(cmbLine.Text);
    Open;
    ivv:=1;
    ListView2.Items.Clear;
    while not eof do
    begin
      with ListView2.Items.Add do
      begin
        Caption:=inttostr(ivv);
        SubItems.Add(''+FieldByName('SLOT_NO').AsString+'');
        SubItems.Add(''+FieldByName('REEL_NO').AsString+'');
        SubItems.Add(''+FieldByName('PART_NO').AsString+'');
        SubItems.Add(''+FieldByName('FEEDER_NO').AsString+'');
        SubItems.Add(''+FieldByName('IN_TIME').AsString+'');
        SubItems.Add(''+FieldByName('EMP_NAME').AsString+'');
      end;
      fManager.qryTemp.Next;
      ivv:=ivv+1;
    end;
  end;
  Timer1.Enabled := True;
end;

procedure TfCheck.cmbLineChange(Sender: TObject);
begin
  cmbMSL.Items.Clear;
  with fManager.qrytemp do
  begin
    close;
    CommandText:='select distinct(a.msl_no) from smt.G_SMT_STATUS a,sajet.sys_pdline b' +
                ' where a.pdline_id=b.pdline_id and b.pdline_name='''+cmbLine.Text+''' order by a.msl_no ';
    open;
    while not eof do
    begin
      cmbMSL.Items.Add(Fieldbyname('msl_no').AsString);
      next;
    end;
  end;
  if cmbMSL.Items.Count=1 then
  begin
    cmbMSL.ItemIndex:=0;
    sbtnStartClick(self);
  end;
end;

procedure TfCheck.sbtnStartClick(Sender: TObject);
begin
  if LabStart.Caption='Start' then
  begin
    if (cmbLine.Text<>'') and (cmbMSL.Text<>'') then
    begin
      cmbLine.Enabled:=false;
      cmbMSL.Enabled:=false;
      LabStart.Caption:='Stop';
      Timer1Timer(SELF);
      timer1.Enabled:=true;
    end;
  end else if LabStart.Caption='Stop' then
  begin
    cmbLine.Enabled:=true;
    cmbMSL.Enabled:=true;
    LabStart.Caption:='Start';
    timer1.Enabled:=false;
  end;
end;

procedure TfCheck.FormClose(Sender: TObject; var Action: TCloseAction);
var H1: Hwnd;
begin
  LabStart.Caption:='Start';
  fManager.sbtnCloseClick(self);
  fDllMain.Close;
  H1 := FindWindow(nil, PChar('MSLTrack'));
  if H1 = 0 then exit;
    SendMessage(H1, WM_CLOSE, 0, 0);
end;

procedure TfCheck.FormResize(Sender: TObject);
begin
  //fManager.Hide;
  //fDllMain.Hide;
  
end;

procedure TfCheck.sbtnCloseClick(Sender: TObject);
begin
  Close;
  
end;

end.
