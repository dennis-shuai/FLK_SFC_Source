unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function SajetTransData(f_iCommandNo : integer;f_pData,f_pLen : pointer) : byte; stdcall; external 'SajetConnect.dll';
  function SajetTransStart : boolean; stdcall;external 'SajetConnect.dll';
  function SajetTransClose : boolean; stdcall;external 'SajetConnect.dll';
var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SajetTransStart then MessageDlg('Start OK',mtInformation,[mbOK],0)
  else MessageDlg('Start Fail',mtInformation,[mbOK],0);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if SajetTransClose then MessageDlg('Close OK',mtInformation,[mbOK],0)
  else MessageDlg('Close Fail',mtInformation,[mbOK],0);
end;



procedure TForm1.Button3Click(Sender: TObject);
var sData : string;
    k,i,iLen : integer;
begin

  for k:=0 to strtoint(Edit2.Text) do
  begin
  iLen:=Length(Edit1.Text);

  if iLen<1000 then SetLength(sData,100)
  else SetLength(sData,iLen);

  for i:=1 to iLen do sData[i]:=Edit1.text[i];

  if SajetTransData(SpinEdit1.value,@sdata[1],@iLen)=1 then Label1.Font.Color:=clblue
  else Label1.Font.Color:=clred;

  SetLength(sData,iLen);

  Label1.Caption:='Result : '+sData ;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SajetTransClose;
end;

end.
