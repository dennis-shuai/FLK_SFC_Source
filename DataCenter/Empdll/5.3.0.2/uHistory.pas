unit uHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, uEmp, Db, DBClient;

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
    Params.CreateParam(ftString	,'CODE', ptInput);
    CommandText := 'Select A.EMP_ID "Employee ID",A.EMP_NO "Employee No",'+
                          'A.EMP_NAME "Employee Name",A.QUIT_DATE "Quit Date",'+
                          'B.EMP_NAME "Update Employee", '+
                          'C.DEPT_NAME "Department", D.SHIFT_CODE "Shift", '+
                          'A.UPDATE_TIME "Update Time",A.ENABLED "Status"  '+
                   'From SAJET.SYS_HT_EMP A, '+
                        'SAJET.SYS_EMP B, '+
                        'SAJET.SYS_DEPT C, '+
                        'SAJET.SYS_SHIFT D '+
                   'Where A.EMP_NO = :CODE and '+
                         'A.UPDATE_USERID = B.EMP_ID(+) and '+
                         'A.DEPT_ID = C.DEPT_ID(+) and '+
                         'A.SHIFT = D.SHIFT_ID(+) '+
                   'Order By "Update Time"  ';
    Params.ParamByName('CODE').AsString := RcCode;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    ShowHistory(Trim(editCode.Text)) ;
end;

end.
