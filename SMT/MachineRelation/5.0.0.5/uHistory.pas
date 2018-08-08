unit uHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, uformMain, Db, DBClient;

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
    Params.CreateParam(ftString	,'ITEM_TYPE_ID', ptInput);
    CommandText := 'Select A.ITEM_TYPE_ID "ITEM Type ID",A.ITEM_TYPE_CODE "Item Type Code" ,A.ITEM_TYPE_NAME "Item Type Name", '+
                          'A.ITEM_TYPE_DESC "Desc.", C.SAMPLING_TYPE "Sampling Plan", '+
                          'B.EMP_NAME "Employee", A.UPDATE_TIME "Update Time", '+
                          'A.ENABLED "Status" '+
                   'From SAJET.SYS_HT_TEST_ITEM_TYPE A '+
                   'LEFT JOIN  SAJET.SYS_QC_SAMPLING_PLAN C ON A.SAMPLING_ID = C.SAMPLING_ID '+
                   'LEFT JOIN  SAJET.SYS_EMP B  ON A.UPDATE_USERID = B.EMP_ID '+
                   'Where A.ITEM_TYPE_ID = :ITEM_TYPE_ID  '+
                   'Order By "Update Time"  ';
    Params.ParamByName('ITEM_TYPE_ID').AsString := RcCode;
    Open;
  end;
end;

procedure TfHistory.editCodeKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    ShowHistory(Trim(editCode.Text)) ;
end;

end.
