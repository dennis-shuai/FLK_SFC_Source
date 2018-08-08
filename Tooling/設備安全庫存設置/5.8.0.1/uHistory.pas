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
    Procedure ShowHistory(PARTID,FACTORYID : String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(PARTID,FACTORYID : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PART_ID', ptInput);
    Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
    CommandText := 'Select part_no "part no",factory_code "factory code",'+
                          'warehouse_name "warehouse name",locate_name "locate name" ,'+
                          'EMP_NAME "Employee", A.UPDATE_TIME "Update Time",'+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_part_factory A, '+
                        'SAJET.SYS_EMP B, '+
                        'SAJET.SYS_part C, '+
                        'SAJET.SYS_factory D, '+
                        'SAJET.SYS_WAREHOUSE E,'+
                        'SAJET.SYS_LOCATE F '+
                   'Where A.PART_ID = :PART_ID and A.FACTORY_ID = :FACTORY_ID '+
                   'and   A.PART_ID = C.PART_ID '+
                   'and   A.UPDATE_USERID = B.EMP_ID(+) '+
                   'and   A.FACTORY_ID = D.FACTORY_ID '+
                   'and   A.LOCATE_ID = F.LOCATE_ID(+) '+
                   'and   E.WAREHOUSE_ID(+) = F.WAREHOUSE_ID '+
                   'Order By "Update Time"  ';
    Params.ParamByName('PART_ID').AsString := PARTID;
    Params.ParamByName('FACTORY_ID').AsString := FACTORYID;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  //If Key = #13 Then
  //  ShowHistory(Trim(editCode.Text)) ;
end;

end.
