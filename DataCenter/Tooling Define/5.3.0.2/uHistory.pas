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
    Params.CreateParam(ftString	,'TOOLING_TYPE_ID', ptInput);
    commandText :=' Select B.TOOLING_NO "Tooling No",B.TOOLING_NAME "Tooling Name",B.TOOLING_DESC "Tooling Desc" '
                  +'      ,B.MAX_USED_COUNT "Max Used Count",B.LIMIT_USED_COUNT "Limit Used Count",B.USED_TIME "Used Time" '
                  +'      ,NVL(C.EMP_NAME,B.UPDATE_USERID) "Employee" '
                  +'      ,B.UPDATE_TIME "Update Time" '
                  +' from '
                  +' SAJET.SYS_HT_TOOLING B '
                  +',SAJET.SYS_EMP C '
                  +' WHERE B.TOOLING_ID =:TOOLING_ID '
                  +'   AND B.UPDATE_USERID = C.EMP_ID(+) '
                  +' Order By "Update Time"   ';
    Params.ParamByName('TOOLING_ID').AsString := RcCode;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    ShowHistory(Trim(editCode.Text)) ;
end;

end.
