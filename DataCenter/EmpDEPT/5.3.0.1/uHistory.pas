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
    Procedure ShowHistory(empID,deptID : String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(empID,deptID : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'emp_ID', ptInput);
    Params.CreateParam(ftString	,'dept_ID', ptInput);
    CommandText := 'Select dept_name "Dept Name",B.Emp_Name "Emp_Name",'+
                          'C.EMP_NAME "Update_user", A.UPDATE_TIME "Update Time",'+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_EMP_DEPT A, '+
                        'SAJET.SYS_EMP B, '+
                        'SAJET.SYS_EMP C, '+
                        'SAJET.SYS_DEPT D '+
                   'Where A.EMP_ID = :EMP_ID and A.DEPT_ID = :DEPT_ID '+
                   'and   A.EMP_ID = B.EMP_ID '+
                   'and   A.UPDATE_USERID = C.EMP_ID(+) '+
                   'and   A.DEPT_ID = D.DEPT_ID '+
                   'Order By "Update Time"  ';
    Params.ParamByName('EMP_ID').AsString := EmpID;
    Params.ParamByName('DEPT_ID').AsString := DeptID;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  //If Key = #13 Then
  //  ShowHistory(Trim(editCode.Text)) ;
end;

end.
