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
    Procedure ShowHistory(ProcessID,modelID : String) ;
  end;

var
  fHistory: TfHistory;

implementation

{$R *.DFM}

Procedure TfHistory.ShowHistory(ProcessID,modelID : String) ;
begin
  With QryData1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'PROCESS_ID', ptInput);
    Params.CreateParam(ftString	,'model_ID', ptInput);
    CommandText := 'Select model_name "Model Name",Process_Name "Process",'+
                          'LOWER_LIMIT "Lower Limit",UPPER_LIMIT "Upper",'+
                          'EMP_NAME "Employee", A.UPDATE_TIME "Update Time",'+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_MODEL_PROCESS_RATE A, '+
                        'SAJET.SYS_EMP B, '+
                        'SAJET.SYS_PROCESS C, '+
                        'SAJET.SYS_model D '+
                   'Where A.PROCESS_ID = :PROCESS_ID and A.model_ID = :model_ID '+
                   'and   A.PROCESS_ID = C.PROCESS_ID '+
                   'and   A.UPDATE_USERID = B.EMP_ID(+) '+
                   'and   A.model_ID = D.model_ID '+
                   'Order By "Update Time"  ';
    Params.ParamByName('PROCESS_ID').AsString := ProcessID;
    Params.ParamByName('model_ID').AsString := modelID;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  //If Key = #13 Then
  //  ShowHistory(Trim(editCode.Text)) ;
end;

end.
