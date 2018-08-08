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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    g_type: string;
    g_tsItemData: TStrings;
    procedure ShowSubReason;
    procedure ShowReasonList(SREASONCODE:STRING);
    procedure ShowItemList(sLocation, sItemNo: string);
    procedure ShowSubItem;
    { Public declarations }
  end;

var
  fReason: TfReason;

implementation

uses uRepair;

{$R *.dfm}

procedure TfReason.ShowItemList(sLocation, sItemNo: string);
var sItem, sDesc, sLoc: string;
begin
  TreeReason.Items.Clear;
  g_tsItemData := TStringList.Create;
  // limit by key 2008/06/11
 { with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Work_Order', ptInput);
    CommandText := 'select a.location,nvl(a.version,''N/A'') version,a.ITEM_PART_ID '
      + '      ,b.part_no item_part_no,b.SPEC1 item_part_spec,c.part_no,c.SPEC1 '
      + 'from sajet.g_wo_bom a '
      + '    ,sajet.sys_part b '
      + '    ,sajet.sys_part c '
      + 'where work_order = :Work_Order '
      + 'and a.item_part_id = b.Part_id '
      + 'and a.part_id = c.part_id ';

    if trim(sLocation) <> '' then
      CommandText := CommandText + 'and a.Location like ' + '''' + sLocation + '%' + '''';
    if trim(sItemNo) <> '' then
      CommandText := CommandText + 'and b.Part_no like ' + '''' + sItemNo + '%' + '''';

    CommandText := CommandText + 'order by item_part_no';
    Params.ParamByName('Work_Order').AsString := fRepair.LabWO.Caption;
    Open;
    g_tsItemData.clear;
    while not Eof do
    begin
      sItem := FieldByName('item_part_no').asstring;
      sDesc := FieldByName('item_part_spec').asstring;
      sLoc := FieldByName('LOCATION').asstring;
      TreeReason.Items.AddChild(nil, sItem + '..(' + sDesc + ')' + '..[' + sLoc + ']');

      g_tsItemData.Add(FieldByName('item_part_no').AsString);
      g_tsItemData.Add(FieldByName('ITEM_PART_ID').AsString);
      g_tsItemData.Add(FieldByName('VERSION').AsString);

      Next;
    end;
  end;
  }

  //add by key 2008/06/11
   with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Work_Order', ptInput);
    CommandText := ' select b.part_no,b.part_id,b.spec1,b.version from sajet.g_wo_pick_list a, sajet.sys_part b '
                   +' where a.work_order=:work_order and a.part_id=b.part_id '
                   +' order by b.part_no ';
    Params.ParamByName('Work_Order').AsString := fRepair.LabWO.Caption;
    Open;
    g_tsItemData.clear;
    while not Eof do
    begin
      sItem := FieldByName('part_no').asstring;
      sDesc := FieldByName('spec1').asstring;
      TreeReason.Items.AddChild(nil, sItem + '..(' + sDesc + ')' );

      g_tsItemData.Add(FieldByName('part_no').AsString);
      g_tsItemData.Add(FieldByName('PART_ID').AsString);
      g_tsItemData.Add(FieldByName('VERSION').AsString);

      Next;
    end;
  end;

end;

procedure TfReason.ShowSubItem;
var msubNode: TTreeNode;
  sCode, sItem, sDesc, sLoc: string;
  i, iIndex: integer;
  sPartID, sVer: string;
begin
  sCode := Copy(TreeReason.Selected.Text, 1, pos('..(', TreeReason.Selected.Text) - 1);
  iIndex := g_tsItemData.Indexof(sCode);
  sPartID := g_tsItemData.strings[iIndex + 1];
  sVer := g_tsItemData.strings[iIndex + 2];

  msubNode := TreeReason.Selected;
  for i := TreeReason.Selected.Count - 1 downto 0 do
  begin
    TreeReason.Selected.Item[i].Delete;
  end;

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PARTID', ptInput);
    Params.CreateParam(ftString, 'VER', ptInput);
    CommandText := 'Select B.ITEM_PART_ID,nvl(B.VERSION,''N/A'') VERSION,D.PART_NO,D.SPEC1,B.LOCATION '
      + 'From SAJET.SYS_BOM_INFO A '
      + '    ,SAJET.SYS_BOM B ' // Part No
      + '    ,SAJET.SYS_PART D ' // sub sub Part
      + 'Where A.PART_ID = :PARTID and NVL(A.VERSION,''N/A'') = :VER '
      + 'and A.BOM_ID = B.BOM_ID '
      + 'and B.ITEM_PART_ID = D.PART_ID '
      + 'Group By B.ITEM_PART_ID,D.PART_NO,B.VERSION,D.SPEC1,B.LOCATION ';
    Params.ParamByName('PARTID').AsString := sPartID;
    Params.ParamByName('VER').AsString := sVer;
    Open;
    while not Eof do
    begin
      sItem := FieldByName('PART_NO').asstring;
      sDesc := FieldByName('SPEC1').asstring;
      sLoc := FieldByName('LOCATION').AsString;
      TreeReason.Items.AddChild(msubNode, sItem + '..(' + sDesc + ')' + '..[' + sLoc + ']');

      g_tsItemData.Add(FieldByName('PART_NO').AsString);
      g_tsItemData.Add(FieldByName('ITEM_PART_ID').AsString);
      g_tsItemData.Add(FieldByName('VERSION').AsString);
      Next;
    end;
  end;
  TreeReason.Selected.Expanded := True;
end;

procedure TfReason.ShowReasonList(SREASONCODE:STRING);
var sReason, sDesc: string;
begin
  TreeReason.Items.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'Reason_Level', ptInput);
    Params.CreateParam(ftString, 'Reason_Code', ptInput);
    CommandText := 'Select * '
      + 'from sajet.sys_reason '
      + 'where Reason_Level= :Reason_Level '
      + ' and reason_code like :reason_code '
      + ' AND ENABLED=''Y'' '
      + 'order by Reason_Code ';
    Params.ParamByName('Reason_Level').AsString := '0';
    Params.ParamByName('Reason_Code').AsString := SREASONCODE + '%';;
    Open;
    while not Eof do
    begin
      sReason := FieldByName('Reason_Code').asstring;
      sDesc := FieldByName('Reason_Desc').asstring;
      TreeReason.Items.AddChild(nil, sReason + '..(' + sDesc + ')');
      Next;
    end;
  end;
end;

procedure TfReason.ShowSubReason;
var msubNode: TTreeNode;
  sCode, sReason, sDesc: string; i, iLevel: integer;
begin
  iLevel := TreeReason.Selected.Level + 1;
  sCode := Copy(TreeReason.Selected.Text, 1, pos('..(', TreeReason.Selected.Text) - 1) + '%';
  msubNode := TreeReason.Selected;
  for i := TreeReason.Selected.Count - 1 downto 0 do
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
      + ' AND ENABLED=''Y'' '
      + 'order by Reason_Code ';
    Params.ParamByName('Reason_Level').AsString := IntToStr(iLevel);
    Params.ParamByName('Reason_Code').AsString := sCode;
    Open;
    while not Eof do
    begin
      sReason := FieldByName('Reason_Code').asstring;
      sDesc := FieldByName('Reason_Desc').asstring;
      TreeReason.Items.AddChild(msubNode, sReason + '..(' + sDesc + ')');
      Next;
    end;
  end;
  TreeReason.Selected.Expanded := True;
end;

procedure TfReason.TreeReasonDblClick(Sender: TObject);
begin
  if TreeReason.Items.Count <> 0 then
    ModalResult := mrOK;
end;

procedure TfReason.TreeReasonClick(Sender: TObject);
begin
  if TreeReason.Items.Count = 0 then
    Exit;
  if TreeReason.Selected.Count = 0 then
  begin
    if g_type = 'R' then
      ShowSubReason
    else
      ShowSubItem;
  end;
end;

procedure TfReason.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  g_tsItemData.Free;
end;

end.

