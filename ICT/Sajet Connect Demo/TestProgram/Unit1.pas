unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    BitBtn5: TBitBtn;
    Edit3: TEdit;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit4: TEdit;
    Label1: TLabel;
    BitBtn6: TBitBtn;
    lbl1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    startDate,enddate:TDateTime;
  end;
  function SajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : byte; stdcall; external 'SajetConnect.dll';
  function SajetTransStart : boolean; stdcall;external 'SajetConnect.dll';
  function SajetTransClose : boolean; stdcall;external 'SajetConnect.dll';
var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
var sData : string;
    k,i,iLen : integer;
begin
  startDate :=Now;

  iLen:=Length(Edit1.Text);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=Edit1.text[i];

  if SajetTransData(1,@sdata[1],@iLen)=1 then Label1.Font.Color:=clblue
  else Label1.Font.Color:=clred;

  SetLength(sData,iLen);

  Label1.Caption:='Result : '+sData +',length:'+InttoStr(iLen);

  lbl1.Caption := IntToStr(Round((now-StartDate)*24*60*60)) +'S';

end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  startDate :=Now;
    SajetTransStart ;//then MessageDlg('Start OK',mtInformation,[mbOK],0)
 // else MessageDlg('Start Fail',mtInformation,[mbOK],0);
   lbl1.Caption := IntToStr(Round((now-StartDate)*24*60*60)) +'S';

end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
     if SajetTransClose then MessageDlg('Close OK',mtInformation,[mbOK],0)
  else MessageDlg('Close Fail',mtInformation,[mbOK],0);
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var sData : string;
    k,i,iLen : integer;
begin

  startDate :=Now;
  iLen:=Length(Edit3.Text);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=Edit3.text[i];

  if SajetTransData(StrToInt(Edit4.Text),@sdata[1],@iLen)=1 then Label1.Font.Color:=clblue
  else Label1.Font.Color:=clred;

  SetLength(sData,iLen);

  Label1.Caption:='Result : '+sData ;
  
  lbl1.Caption := IntToStr(Round((now-StartDate)*24*60*60)) +'S';


end;

procedure TForm1.BitBtn4Click(Sender: TObject);
var sData : string;
    k,i,iLen : integer;
begin
   startDate :=Now;
  iLen:=Length(Edit2.Text);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=Edit2.text[i];

  if SajetTransData(2,@sdata[1],@iLen)=1 then Label1.Font.Color:=clblue
  else Label1.Font.Color:=clred;
                      // SajetTransData(int,char * , int *  )
  SetLength(sData,iLen);

  Label1.Caption:='Result : '+sData ;
  
  lbl1.Caption := IntToStr(Round((now-StartDate)*24*60*60)) +'S';

end;

procedure TForm1.BitBtn6Click(Sender: TObject);
var sData : string;
    k,i,iLen : integer;
begin

  iLen:=Length(Edit2.Text);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=Edit2.text[i];

  if SajetTransData(9,@sdata[1],@iLen)=1 then Label1.Font.Color:=clblue
  else Label1.Font.Color:=clred;

  SetLength(sData,iLen);

  Label1.Caption:='Result : '+sData ;

end;

end.
