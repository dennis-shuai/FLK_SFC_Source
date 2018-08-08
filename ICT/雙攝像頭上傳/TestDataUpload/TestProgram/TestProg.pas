unit TestProg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ExtCtrls, DB, ADODB;

type
  TForm1 = class(TForm)
    btn4: TButton;
    btn5: TButton;
    lblMsg: TLabel;
    edtSN: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    sp1: TADOStoredProc;
    con1: TADOConnection;
    Label1: TLabel;
    mmoData: TMemo;
    btnUploadString: TButton;
    procedure FormShow(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btnUploadStringClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IsConnect:Boolean;
    iDateTime:TDateTime ;
  end;

   function SFISATUploadData(f_pData,f_pLen:Pointer): Boolean; stdcall;external 'TestDataUploaddll.dll';
   function SFISDoubleATUploadData(f_pData,f_pLen:Pointer): Boolean; stdcall;external 'TestDataUploaddll.dll';
   function SFISATUploadStringData(f_pData,f_pLen:Pointer): Boolean; stdcall;external 'TestDataUploaddll.dll';

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
 edtSN.SetFocus;
end;

procedure TForm1.btn4Click(Sender: TObject);
var  i,iLen:Integer;
 sData:string;

begin
   iLen:=Length(edtSN.Text);
   iDateTime := Now;
   if iLen<100 then SetLength(sData,1000)
   else SetLength(sData,iLen);

   for i:=1 to iLen do sData[i]:=edtSN.text[i];
   if SFISDoubleATUploadData(@sdata[1],@iLen) then
      lblmsg.Color :=clGreen
   else
      lblmsg.Color :=clRed;
   SetLength(sData,iLen);

   lblmsg.Caption:='Result : '+sData +',length:'+InttoStr(iLen)+' Time:'+FloatToStr((Now-iDateTime)*24*60*60)+'S';

end;

procedure TForm1.btn5Click(Sender: TObject);
var  i,iLen:Integer;
 sData:string;
begin
   iLen:=Length(edtSN.Text);
   iDateTime := Now;
   if iLen<100 then SetLength(sData,1000)
   else SetLength(sData,iLen);

   for i:=1 to iLen do sData[i]:=edtSN.text[i];
   if SFISATUploadData(@sdata[1],@iLen) then
      lblmsg.Color :=clGreen
   else
      lblmsg.Color :=clRed ;
   SetLength(sData,iLen);

   lblmsg.Caption:='Result : '+sData +',length:'+InttoStr(iLen)+' Time:'+FloatToStr((Now-iDateTime)*24*60*60)+'S';

end;

procedure TForm1.btnUploadStringClick(Sender: TObject);
var  i,iLen:Integer;
 sData:string;
begin

   iLen:=Length(mmoData.text);
   iDateTime := Now;
   if iLen<1000 then SetLength(sData,1000)
   else SetLength(sData,iLen);

   for i:=1 to iLen do sData[i]:=mmoData.text[i];
   if SFISATUploadStringData(@sdata[1],@iLen) then
      lblmsg.Color :=clGreen
   else
      lblmsg.Color :=clRed ;
   SetLength(sData,iLen);

   lblmsg.Caption:='Result : '+sData +',length:'+InttoStr(iLen)+' Time:'+FloatToStr((Now-iDateTime)*24*60*60)+'S';
   
end;

end.
