unit uCM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg, Db, DBClient, MConnect, SConnect;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ImageFunction: TImage;
    Panel3: TPanel;
    Panel4: TPanel;
    ImageTitle: TImage;
    ImageData: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    LoginUserID  : String;
  end;

var
  Form1: TForm1;
  Procedure FunctionInit(SenderOwner : TForm; SenderParent : TPanel; ShowParent : TPanel; ParentApplication : TApplication; UserID : String); stdcall; external 'FunctionList.dll';

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoginUserID  := ParamStr(1);
  FunctionInit(Self, Panel1, Panel4, Application, LoginUserID);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  If LoginUserID = '' Then
    Application.Terminate ;
end;
            
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
