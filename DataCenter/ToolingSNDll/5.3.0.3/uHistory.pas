unit uHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, Db, DBClient;

type
  TfHistory = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    editCode: TEdit;
    QryData1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure editCodeKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure ShowHistory(RcCode : String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(RcCode : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'TOOLING_SN', ptInput);
    commandText :=' Select B.TOOLING_SN "Tooling SN" '
                  +'      ,NVL(C.EMP_NAME,B.UPDATE_USERID) "Employee" '
                  +'      ,B.UPDATE_TIME "Update Time",B.ENABLED "Status" '
                  +' from '
                  +' SAJET.SYS_HT_TOOLING_SN B '
                  +',SAJET.SYS_EMP C '
                  +' WHERE B.TOOLING_SN =:TOOLING_SN '
                  +'   AND B.UPDATE_USERID = C.EMP_ID(+) '
                  +' Order By "Update Time"   ';
    Params.ParamByName('TOOLING_SN').AsString := RcCode;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    ShowHistory(Trim(editCode.Text)) ;
end;

end.
