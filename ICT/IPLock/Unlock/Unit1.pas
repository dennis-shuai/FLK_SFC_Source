unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Registry, StdCtrls;

type
  TForm1 = class(TForm)
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
var reg :Tregistry;
stemp:string;
begin
    Reg:=TRegistry.Create;
    try
       Reg.RootKey:=HKEY_LOCAL_MACHINE; //HKEY_LOCAL_MACHINE

       if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',true) then
       begin
          reg.DeleteValue('IPLOCK');
          stemp := reg.ReadString('IPLOCK');
       end
       else begin
         reg.DeleteValue('IPLOCK');
       end;
       Reg.CloseKey;
    finally
       Reg.Free;
    end;
end;

end.
