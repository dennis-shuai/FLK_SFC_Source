unit uDir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls, ShellCtrls;

type
  TformDir = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ShellTreeView1: TShellTreeView;
    procedure ShellTreeView1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formDir: TformDir;

implementation

{$R *.dfm}

procedure TformDir.ShellTreeView1KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

end.
