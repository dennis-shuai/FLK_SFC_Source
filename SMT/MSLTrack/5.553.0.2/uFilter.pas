unit uFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient, AppEvnts;

type
  TfFilter = class(TForm)
    DBGrid2TTT: TDBGrid;
    QryData: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid2: TDBGrid;
    ApplicationEvents1: TApplicationEvents;
    procedure DBGrid2DblClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFilter: TfFilter;

implementation

{$R *.DFM}
uses uManager;

procedure TfFilter.DBGrid2DblClick(Sender: TObject);
begin           //qryData.Eof AND
  If  qryData.RecordCount<=0 then
     Exit;
  ModalResult := mrOK;
end;

procedure TfFilter.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if (DBGrid2.Focused) And (Msg.message = WM_MOUSEWHEEL) then
  begin
  if Msg.wParam > 0 then
    SendMessage(DBGrid2.Handle, WM_KEYDOWN, VK_UP, 0)
  else
    SendMessage(DBGrid2.Handle, WM_KEYDOWN, VK_DOWN, 0);
    Handled := True;
  end;
end;

end.
