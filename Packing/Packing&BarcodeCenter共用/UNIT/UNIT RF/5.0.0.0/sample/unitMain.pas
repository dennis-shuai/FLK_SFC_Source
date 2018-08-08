unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,unitRF, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    m_RF : TRF;
    function onRsvData(f_iSubID:integer;var f_sData : string) : boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


function TForm1.onRsvData(f_iSubID:integer;var f_sData : string) : boolean;
begin
  f_sData:='Receive : '+f_sData;
  result:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  m_RF:=TRF.Create(self);
  m_RF.OnReceiveData:=onRsvData;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  m_RF.free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var sMessage : string;
begin
  if not m_RF.Setup(sMessage) then showmessage(sMessage);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  m_RF.Started:=not m_RF.Started;
  if m_RF.Started then Button2.Caption:='Driver Start'
  else Button2.Caption:='Driver Stop';
end;

end.
