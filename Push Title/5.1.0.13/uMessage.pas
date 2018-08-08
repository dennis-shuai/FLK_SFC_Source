unit uMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TfMessage = class(TForm)
    BnOK: TButton;
    Timer1: TTimer;
    Panel1: TPanel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    G_sBox_time: Integer;
  public

    { Public declarations }
  end;

var
  fMessage: TfMessage;

implementation

{$R *.dfm}

procedure TfMessage.Timer1Timer(Sender: TObject);
begin
  if G_sBox_time>=0 then
  begin
    BnOK.Caption:='OK('+inttostr(G_sBox_time)+')';
    G_sBox_time:=G_sBox_time-1;
  end else
  begin
    Timer1.Enabled:=false;
    close;
  end;
end;

procedure TfMessage.FormShow(Sender: TObject);
begin
  bnOk.Caption:='OK';
  G_sBox_time:=5;
  Timer1.Enabled:=true;
end;

procedure TfMessage.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
  begin
    Modalresult := mrOK;
    close;
  end;
end;

procedure TfMessage.BnOKClick(Sender: TObject);
begin
  Modalresult := mrOK;
  close;
end;

procedure TfMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
