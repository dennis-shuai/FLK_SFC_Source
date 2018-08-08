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
    Procedure ShowHistory(PART_ID : String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(PART_ID : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PART_ID', ptInput);
    CommandText := 'Select part_no "part no",part_qty "part qty",point_qty "point qty",'+
                          'EMP_NAME "Employee", A.UPDATE_TIME "Update Time",'+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_part_point A, '+
                        'SAJET.SYS_EMP B, '+
                        'SAJET.SYS_part C '+
                   'Where A.PART_ID = :PART_ID '+
                   'and   A.PART_ID = C.PART_ID '+
                   'and   A.UPDATE_USERID = B.EMP_ID(+) '+
                   'Order By "Update Time"  ';
    Params.ParamByName('part_ID').AsString := PART_ID;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  //If Key = #13 Then
  //  ShowHistory(Trim(editCode.Text)) ;
end;

end.
