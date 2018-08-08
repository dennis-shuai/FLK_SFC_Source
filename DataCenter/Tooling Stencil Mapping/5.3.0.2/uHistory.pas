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
    Procedure ShowHistory(toolingsnID,partID: String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(toolingsnID,partID : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'tooling_sn_ID', ptInput);
    Params.CreateParam(ftString	,'part_ID', ptInput);
    CommandText := 'Select b.tooling_sn "tooling sn",d.part_no "part no",'+
                          'C.EMP_NAME "Update_user", A.UPDATE_TIME "Update Time",'+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_part_stencil A, '+
                        'SAJET.SYS_tooling_sn B, '+
                        'SAJET.SYS_EMP C, '+
                        'SAJET.SYS_part D '+
                   'Where A.tooling_sn_ID = :tooling_sn_ID and A.part_ID = :part_ID '+
                   'and   A.tooling_sn_ID = b.tooling_sn_id '+
                   'and   A.UPDATE_USERID = C.EMP_ID(+) '+
                   'and   A.part_ID = D.part_ID '+
                   'Order By "Update Time"  ';
    Params.ParamByName('tooling_sn_ID').AsString := toolingsnid;
    Params.ParamByName('part_ID').AsString := partID;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  //If Key = #13 Then
  //  ShowHistory(Trim(editCode.Text)) ;
end;

end.
