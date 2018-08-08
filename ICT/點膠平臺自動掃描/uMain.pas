unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, SPComm, ExtCtrls, GradPanel,
  StringGrid1, GradBtn, RzCmboBx, RzShellCtrls, RzButton;

type
  TfMain = class(TForm)
    mmo1: TMemo;
    commMa: TComm;
    strngrd: TStringGrid1;
    grdpnl1: TGradPanel;
    grdpnl2: TGradPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    cmb1: TComboBox;
    edt3: TEdit;
    edt4: TEdit;
    edt5: TEdit;
    lbl7: TLabel;
    btn1: TRzButton;
    commScan: TComm;
    procedure commMaReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    cmd:string ;
    procedure SendHex(S: String);
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
uses uSetting;

procedure TfMain.commMaReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
begin
//
end;

procedure TfMain.btn3Click(Sender: TObject);
begin
   commMa.StartComm;
end;

procedure TfMain.btn4Click(Sender: TObject);
var cmd:string;
begin
    cmd :='HM';
    SendHex(cmd);
end;

procedure TfMain.SendHex(S: String);
var
  s2:string;
  buf1:array[0..50000] of char;
  i:integer;
begin
  s2:='';
  for i:=1 to  length(s) do
  begin
    if ((copy(s,i,1)>='0') and (copy(s,i,1)<='9'))or((copy(s,i,1)>='a') and (copy(s,i,1)<='f'))
        or((copy(s,i,1)>='A') and (copy(s,i,1)<='F')) then
    begin
        s2:=s2+copy(s,i,1);
    end;
  end;
  for i:=0 to (length(s2) div 2-1) do
    buf1[i]:=char(strtoint('$'+copy(s2,i*2+1,2)));
  commMa.WriteCommData(buf1,(length(s2) div 2));
end;

procedure TfMain.btn5Click(Sender: TObject);
begin
   // cmd :='MAR '+edtX.Text+','+edtY.Text+','+edtZ.Text;
    SendHex(cmd);

end;

procedure TfMain.FormShow(Sender: TObject);
begin
    strngrd.ColWidths[0] :=45;
end;



procedure TfMain.btn1Click(Sender: TObject);
var fSetting:TfSetting;
begin
   fSetting :=TfSetting.Create(Self);
   fSetting.Show;
end;

end.
