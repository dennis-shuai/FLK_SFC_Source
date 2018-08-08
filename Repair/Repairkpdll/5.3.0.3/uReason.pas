unit uReason;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, ComCtrls, StdCtrls, Buttons, Menus,
  ImgList;

type
  TfReason = class(TForm)
    QryTemp: TClientDataSet;
    TreeReason: TTreeView;
    ImageList1: TImageList;
    procedure TreeReasonDblClick(Sender: TObject);
    procedure TreeReasonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowSubReason;
    procedure ShowReasonList;
    { Public declarations }
  end;

var
  fReason: TfReason;

implementation

uses uRepair;

{$R *.dfm}

procedure TfReason.ShowReasonList;
var mNode: TTreeNode;
    sReason,sDesc:string;
begin
  TreeReason.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Reason_Level', ptInput);
    CommandText := 'Select * '
                 + 'from sajet.sys_reason '
                 + 'where Reason_Level= :Reason_Level '
                 + 'and enabled = ''Y'' '
                 + 'order by Reason_Code ';
    Params.ParamByName('Reason_Level').AsString := '0';
    Open;
    while not Eof do
    begin
      sReason:= FieldByName('Reason_Code').asstring;
      sDesc:= FieldByName('Reason_Desc').asstring;
      mNode := TreeReason.Items.AddChild(nil, sReason+'..('+sDesc+')');
      Next;
    end;
  end;
end;

procedure TfReason.ShowSubReason;
var mNode,msubNode:TTreeNode;
    sCode,sReason,sDesc:string; i,iLevel:integer;
begin
  iLevel:= TreeReason.Selected.Level+1;
  sCode:= Copy(TreeReason.Selected.Text,1,pos('..(',TreeReason.Selected.Text)-1)+'%';
  msubNode:= TreeReason.Selected;
  for i:= TreeReason.Selected.Count-1 downto 0 do
  begin
    TreeReason.Selected.Item[i].Delete;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Reason_Level', ptInput);
    Params.CreateParam(ftString, 'Reason_Code', ptInput);
    CommandText := 'Select * '
                 + 'from sajet.sys_reason '
                 + 'where Reason_Level=:Reason_Level '
                 + 'and Reason_Code like :Reason_Code '
                 + 'and Enabled = ''Y'' '
                 + 'order by Reason_Code ';
    Params.ParamByName('Reason_Level').AsString := IntToStr(iLevel);
    Params.ParamByName('Reason_Code').AsString := sCode;
    Open;
    while not Eof do
    begin
      sReason:= FieldByName('Reason_Code').asstring;
      sDesc:= FieldByName('Reason_Desc').asstring;
      mNode := TreeReason.Items.AddChild(msubNode, sReason+'..('+sDesc+')');
      Next;
    end;
  end;
  TreeReason.Selected.Expanded:=True;
end;

procedure TfReason.TreeReasonDblClick(Sender: TObject);
begin
    if TreeReason.Items.Count = 0 THEN
     Exit;
     IF NOT TreeReason.Selected.HasChildren Then
           ModalResult:= mrOK;
  //ShowSubReason;
end;

procedure TfReason.TreeReasonClick(Sender: TObject);
begin
  if TreeReason.Items.Count = 0 THEN
     Exit;
  if TreeReason.Selected.Count=0 then
    ShowSubReason;
end;

end.
