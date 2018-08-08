unit uFormLabelData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, DB, clsDataSet ;

type
  TFormLabelData = class(TForm)
    pnl1: TPanel;
    lbl1: TLabel;
    LabType2: TLabel;
    edtComm: TEdit;
    dbgrd1: TDBGrid;
    pnl2: TPanel;
    LabType1: TLabel;
    DataSource1: TDataSource;
    Button1: TButton;
    Button2: TButton;
    procedure edtCommChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgrd1DblClick(Sender: TObject);
    procedure dbgrd1CellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormLabelData: TFormLabelData;

implementation

{$R *.dfm}

procedure TFormLabelData.edtCommChange(Sender: TObject);
begin
  if not ObjDataSet.ObjQryTemp.Active then
     Exit;
  if not ObjDataSet.ObjQryTemp.IsEmpty then
      ObjDataSet.ObjQryTemp.Locate(ObjDataSet.ObjQryTemp.Fields.Fields[0].FieldName, Trim(edtComm.Text), [loCaseInsensitive, loPartialKey])
end;

procedure TFormLabelData.Button1Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFormLabelData.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TFormLabelData.FormShow(Sender: TObject);
begin
  Self.Left :=Round((Screen.Width -Self.Width)/2);
  Self.Top :=Round((Screen.Height-Self.Height)/2);
end;

procedure TFormLabelData.dbgrd1DblClick(Sender: TObject);
begin
  Button1Click(Self);
end;

procedure TFormLabelData.dbgrd1CellClick(Column: TColumn);
begin
  edtComm.Text := ObjDataSet.ObjQryTemp.Fields.Fields[0].AsString ;
end;

end.
