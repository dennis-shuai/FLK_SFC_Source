unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,COmobj;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 function InitPrint(PrintFile:pointer) : boolean; stdcall; external 'PrintModuleDll.dll';
 function PrintLabel(ModuleNo:pointer) : boolean; stdcall;external 'PrintModuleDll.dll';
 function ClosePrint : boolean; stdcall;external 'PrintModuleDll.dll';


var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var str:string;
begin
    str :=edit1.Text;
   // CoInitialize(nil);
    InitPrint( @Str[1]);
end;

procedure TForm1.Button2Click(Sender: TObject);
var str:string;
begin
   str :=edit2.Text;
   PrintLabel(@Str[1]);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   ClosePrint;
end;

end.
