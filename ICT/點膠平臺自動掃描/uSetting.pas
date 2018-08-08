unit uSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, GradPanel, RzCmboBx,IniFiles;

type
  TfSetting = class(TForm)
    grdpnl1: TGradPanel;
    cmbCom: TComboBox;
    btnOpenMa: TButton;
    btnBack: TButton;
    btnMove: TButton;
    edtBaud: TEdit;
    btnCloseMa: TButton;
    lbl1: TLabel;
    grdpnl2: TGradPanel;
    lbl8: TLabel;
    cmb1: TComboBox;
    btnOpenScan: TButton;
    edt4: TEdit;
    btnCloseScan: TButton;
    pnlAxis: TPanel;
    cmbModel: TComboBox;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    edtAllCount: TEdit;
    lbl9: TLabel;
    edtRowCount: TEdit;
    lbl10: TLabel;
    edtColCount: TEdit;
    edtColInterval: TEdit;
    lbl12: TLabel;
    btn1: TButton;
    btn2: TButton;
    lbl2: TLabel;
    edtX: TEdit;
    lbl3: TLabel;
    edtY: TEdit;
    lbl4: TLabel;
    edtZ: TEdit;
    lbl11: TLabel;
    cbbRowNo: TRzComboBox;
    lbl13: TLabel;
    lbl14: TLabel;
    lbl15: TLabel;
    edtSpeed: TEdit;
    procedure btnOpenMaClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnMoveClick(Sender: TObject);
    procedure btnCloseMaClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure edtAllCountChange(Sender: TObject);
    procedure cbbRowNoSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbModelSelect(Sender: TObject);
    procedure edtRowCountChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     editXY:array of TEdit;
     AllCount,RowCount:Integer;
     myIniFile:TInifile;
     sIniName:string;
  end;

var
  fSetting: TfSetting;

implementation

{$R *.dfm}

uses uMain;

procedure TfSetting.btnOpenMaClick(Sender: TObject);
begin
    fMain.commMa.CommName := cmbCom.Text;
    fMain.commMa.BaudRate := StrToInt(edtBaud.Text);
    fMain.commMa.StartComm;
end;

procedure TfSetting.btnBackClick(Sender: TObject);
begin
      fMain.SendHex('HM');
end;

procedure TfSetting.btnMoveClick(Sender: TObject);
begin
      fMain.SendHex('MAR '+edtx.Text+','+edtY.Text+','+edtZ.Text);
end;

procedure TfSetting.btnCloseMaClick(Sender: TObject);
begin
    fMain.commMa.StopComm;
end;

procedure TfSetting.btn1Click(Sender: TObject);
var i,j,k:Integer;
begin
   AllCount := StrToIntDef(edtAllCount.Text,0);
   setlength(editXY,AllCount);

   for i :=0 to StrToIntDef(edtAllCount.Text,0) -1 do
   begin

      j := Trunc(i div (StrToIntDef(edtColCount.Text,0)));
      k := Trunc(i mod (StrToIntDef(edtColCount.Text,0)));
      if FindComponent('editXY'+IntToStr(i+1))=  nil then
      begin
        editXY[i] := TEdit.Create(Self);
        editXY[i].Name :='editXY'+IntToStr(i+1);
      end;
      editXY[i].Height := 30 ;
      editXY[i].Top :=  Trunc(20 + j* (editXY[i].Height+20) );
      editXY[i].Width := Trunc((pnlAxis.Width-20 ) / StrToIntDef(edtColCount.Text,0))-10;
      editXY[i].Left :=  10+ k*(editXY[i].Width +10);
      editXY[i].Color := clGreen;
      editXY[i].Parent:=pnlAxis;
      editXY[i].Text :='';
      editXY[i].Show;

   end;
end;

procedure TfSetting.edtAllCountChange(Sender: TObject);
begin
    //editXY
   // SetLength(editXY,0);

end;

procedure TfSetting.cbbRowNoSelect(Sender: TObject);
begin
   //--------Load Settings-----------------
   myIniFile :=TIniFile.Create(sIniName);
   edtColCount.Text :=myIniFile.ReadString('ROW'+cbbRowNo.Text,'ColCount','');
   edtColInterval.Text :=myIniFile.ReadString('ROW'+cbbRowNo.Text,'Interval','');
   edtX.Text := myIniFile.ReadString('ROW'+cbbRowNo.Text,'X','');
   edtY.Text := myIniFile.ReadString('ROW'+cbbRowNo.Text,'Y','');
   edtZ.Text := myIniFile.ReadString('ROW'+cbbRowNo.Text,'Z','');
   myIniFile.Free;

end;

procedure TfSetting.FormShow(Sender: TObject);
var sr: TSearchRec;
sFilePath:string;
begin
  //
   sFilePath :=  ExtractFilePath(ParamStr(0)) + 'Settings\';

    if FindFirst( sFilePath+'\*.ini',faAnyFile,sr)=0 then
    begin
       repeat
           if (sr.Attr and faAnyFile) = sr.Attr then
           begin
               cmbModel.Items.Add(Copy(sr.Name,1,Length(sr.Name)-4));
           end;
       until FindNext(sr) <>0;
          FindClose(sr);
    end;

end;

procedure TfSetting.cmbModelSelect(Sender: TObject);
var i:Integer;
begin
    sIniName := ExtractFilePath(ParamStr(0)) + 'Settings\'+cmbModel.Text+'.ini';
    myIniFile :=TIniFile.Create(sIniName);
    cmbCom.Text :=myIniFile.ReadString('Settings','MACOMNAME','');
    edtBaud.Text :=myIniFile.ReadString('Settings','MABAUDRATE','');
    edtAllCount.Text :=myIniFile.ReadString('Settings','AllCount','');
    edtSpeed.Text :=myIniFile.ReadString('Settings','Speed','');
    edtRowCount.Text :=myIniFile.ReadString('Settings','Row','');
    cbbRowNo.Items.Clear;
    for i:=0 to StrtoIntDef( edtRowCount.Text,0)-1 do
    begin
        cbbRowNo.Items.Add(IntToStr(i+1));
    end;
    myIniFile.Free;
end;

procedure TfSetting.edtRowCountChange(Sender: TObject);
var i:Integer;
begin
   RowCount := StrToIntDef(edtRowCount.Text,0);
   cbbRowNo.Items.Clear;
   for i:=0 to RowCOunt-1 do
   begin
     cbbRowNo.Items.Add(IntToStr(i+1));
   end;

end;

end.
