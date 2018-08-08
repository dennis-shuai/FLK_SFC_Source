unit uBom;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ImgList, BmpRgn,
  ComCtrls, Db, DBClient, MConnect, SConnect, Menus, ObjBrkr;

type
  TfBom = class(TForm)
    ImageList2: TImageList;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    PopupMenu1: TPopupMenu;
    Collapse1: TMenuItem;
    Expanded1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Collapse2: TMenuItem;
    Expand1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Label5: TLabel;
    Label2: TLabel;
    lablWorkOrder: TLabel;
    Label6: TLabel;
    editPNFilter: TEdit;
    lvPartNo: TListView;
    TreePC: TTreeView;
    lablReadOnly: TLabel;
    sbtnClose: TSpeedButton;
    ImageAll: TImage;
    labVersion: TLabel;
    LabDesc: TLabel;
    cmbFactory: TComboBox;
    cmbBOM: TComboBox;
    Image2: TImage;
    Label9: TLabel;
    Label3: TLabel;
    AddProcess1: TMenuItem;
    procedure cmbFactoryChange(Sender: TObject);
    procedure TreePCDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreePCDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure sbtnCloseClick(Sender: TObject);
    procedure TreeProcessGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure Collapse1Click(Sender: TObject);
    procedure Expanded1Click(Sender: TObject);
    procedure Collapse2Click(Sender: TObject);
    procedure Expand1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editPNFilterKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddProcess1Click(Sender: TObject);
  private
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    FcID, UpdateUserID, gsPartID: string;
    SelectLevel: string;
    Authoritys, AuthorityRole: string;
    g_sChangeGroup: Boolean;
    slProcess, slMaxRelation: TStringList;
    procedure SetTheRegion;
    procedure ShowProcess;
    function GetMaxRouteID: string;
    function GetRouteID(RouteName: string): string;
    procedure UpdateWOBom;
    procedure CopyToHistory(RecordID: string); overload;
    function PrepareProcessData: Boolean;
    procedure ShowBom;
    procedure SetStatusbyAuthority;
    function appendBomData(psBom, psItemPart: string; nodeTemp: TTreeNode): Boolean;
    function GetPartNoID(PartNo: string; bEnabled: Boolean; var PartId: string): Boolean;
    function GetRelationNo(WO, ProcessID, Relation: string; var RelationNo: string): Boolean;
    function GetProcessID(Process: string; var ProcessId: string): Boolean;
    procedure insertWOBom(psBomID, psPartID, psProcessID, psRelation: string; nodeTemp: TTreeNode);
    function CheckDup(sProcess, sItemPart, sVersion: string; iCount: Integer): Boolean;
  end;

var
  fBom: TfBom;

implementation

uses uData, uWOManager, uBomData;

{$R *.DFM}

procedure TfBom.insertWOBom(psBomID, psPartID, psProcessID, psRelation: string; nodeTemp: TTreeNode);
var sItemPartNo, sItemPartID: string;
  sItemCount, sVersion, sLocation: string;
begin
  sItemPartNo := Trim(Copy(nodeTemp.Text, 1, Pos('(', nodeTemp.Text) - 1));
  getPartNoID(sItemPartNo, True, sItemPartID);

  if Pos(' [', nodeTemp.Text) = 0 then
    sItemCount := Copy(nodeTemp.Text, Pos(' * ', nodeTemp.Text) + 3, Pos(' {', nodeTemp.Text) - Pos(' * ', nodeTemp.Text) - 3)
      //sItemCount := Copy(nodeTemp.Text, Pos(' * ',nodeTemp.Text)+3, Length(nodeTemp.Text)-Pos(' * ',nodeTemp.Text)-2)
  else
    sItemCount := Copy(nodeTemp.Text, Pos(' * ', nodeTemp.Text) + 3, Pos(' [', nodeTemp.Text) - Pos(' * ', nodeTemp.Text) - 3);
  sVersion := Copy(nodeTemp.Text, Pos('(', nodeTemp.Text) + 1, Pos(')', nodeTemp.Text) - Pos('(', nodeTemp.Text) - 1);
  sLocation := Copy(nodeTemp.Text, Pos('{', nodeTemp.Text) + 1, Pos('}', nodeTemp.Text) - Pos('{', nodeTemp.Text) - 1);

  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORKORDER', ptInput);
    Params.CreateParam(ftString, 'PARTID', ptInput);
    Params.CreateParam(ftString, 'ITEMPARTID', ptInput);
    Params.CreateParam(ftString, 'ITEMGROUP', ptInput);
    Params.CreateParam(ftString, 'ITECOUNT', ptInput);
    Params.CreateParam(ftString, 'PROCESSID', ptInput);
    Params.CreateParam(ftString, 'VERSION', ptInput);
    Params.CreateParam(ftString, 'UPDATEUSER', ptInput);
    Params.CreateParam(ftString, 'LOCATION', ptInput);
    CommandText := 'INSERT INTO SAJET.G_WO_BOM '
      + ' (WORK_ORDER, PART_ID, ITEM_PART_ID, ITEM_GROUP, ITEM_COUNT, PROCESS_ID, VERSION, UPDATE_USERID, LOCATION) '
      + ' VALUES(:WORKORDER, :PARTID, :ITEMPARTID, :ITEMGROUP, :ITECOUNT, :PROCESSID, :VERSION, :UPDATEUSER, :LOCATION) ';
    Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
    Params.ParamByName('PARTID').AsString := psBomID;
    Params.ParamByName('ITEMPARTID').AsString := sItemPartID;
    Params.ParamByName('ITEMGROUP').AsString := psRelation;
    Params.ParamByName('ITECOUNT').AsString := sItemCount;
    Params.ParamByName('PROCESSID').AsString := psProcessID;
    Params.ParamByName('VERSION').AsString := sVersion;
    Params.ParamByName('UPDATEUSER').AsString := fWOManager.UpdateUserID;
    Params.ParamByName('LOCATION').AsString := sLocation;
    Execute;
  end;
end;

function TfBom.GetProcessID(Process: string; var ProcessId: string): Boolean;
begin
  Result := False;
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PROCESS', ptInput);
    CommandText := 'Select PROCESS_ID ' +
      'From SAJET.SYS_PROCESS ' +
      'Where PROCESS_NAME = :PROCESS ';
    Params.ParamByName('PROCESS').AsString := Process;
    Open;
    if not IsEmpty then
      ProcessId := Fieldbyname('PROCESS_ID').AsString
    else
    begin
      ProcessID := '0';
      Exit;
    end;
    Close;
  end;
  Result := True;
end;

function TfBOM.GetPartNoID(PartNo: string; bEnabled: Boolean; var PartId: string): Boolean;
begin
  with fWOManager.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PARTNO', ptInput);
    CommandText := 'Select PART_ID,ENABLED ' +
      'From SAJET.SYS_PART ' +
      'Where PART_NO = :PARTNO ';
    Params.ParamByName('PARTNO').AsString := PartNo;
    Open;
    if not IsEmpty then
    begin
      if (Fieldbyname('ENABLED').AsString = 'Y') or (not bEnabled) then
      begin
        PartId := Fieldbyname('PART_ID').AsString;
        Result := True;
      end
      else if bEnabled then
      begin
        MessageDlg('Part No Invalid !!', mtError, [mbCancel], 0);
        Result := False;
      end;
    end
    else
    begin
      MessageDlg('Part No Error !!', mtError, [mbCancel], 0);
      Result := False;
    end;
    Close;
  end;
end;

function TfBOM.GetRelationNo(WO, ProcessID, Relation: string; var RelationNo: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Trim(Relation) <> '' then
  begin
    RelationNo := Relation;
    Result := True;
    Exit;
  end;
  i := 1;
  while True do
  begin
    with fWOManager.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO', ptInput);
      //Params.CreateParam(ftString	,'PROCESSID', ptInput);
      Params.CreateParam(ftString, 'ITEMGROUP', ptInput);
      CommandText := 'Select ITEM_GROUP ' +
        'From SAJET.G_WO_BOM ' +
        'Where Work_Order = :WO ' +
                   //'and Process_ID = :PROCESSID ' +
      'and Item_Group = :ITEMGROUP ';
      Params.ParamByName('WO').AsString := WO;
      //Params.ParamByName('PROCESSID').AsString := ProcessID;
      Params.ParamByName('ITEMGROUP').AsString := IntToStr(i);
      Open;
      if IsEmpty then
      begin
        RelationNo := IntToStr(i);
        Result := True;
        Break;
      end;
      Close;
    end;
    Inc(i);
  end;
end;

function TfBom.CheckDup(sProcess, sItemPart, sVersion: string; iCount: Integer): Boolean;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WO', ptInput);
    Params.CreateParam(ftString, 'sProcessID', ptInput);
    if sVersion <> '' then
      Params.CreateParam(ftString, 'VER', ptInput);
    Params.CreateParam(ftString, 'sPartNo', ptInput);
    CommandText := 'Select count(*) ' +
      'From SAJET.G_WO_BOM a, sajet.sys_part b ' +
      'Where Work_Order = :WO ' +
      'and a.Process_ID = :sProcessID ' +
      'and a.item_part_id = b.part_id ';
    if sVersion <> '' then
      CommandText := CommandText + 'and a.VERSION = :VER ';
    CommandText := CommandText + 'and b.part_no = :sPartNo ';
    Params.ParamByName('WO').AsString := lablWorkOrder.Caption;
    Params.ParamByName('sProcessID').AsString := sProcess;
    if sVersion <> '' then
      Params.ParamByName('VER').AsString := sVersion;
    Params.ParamByName('sPartNo').AsString := sItemPart;
    Open;
    Result := (FieldByName('count(*)').AsInteger = iCount);
  end;
end;

function TfBom.appendBomData(psBom, psItemPart: string; nodeTemp: TTreeNode): Boolean;
var sProcess, sProcessID, sCount, sRelation, sVersion, sWorkOrder, sLocation, ProcessId: string;
  iNodeLevel: integer;
begin
  Result := False;
  g_sChangeGroup := False;
  if nodeTemp <> nil then
  begin
    iNodeLevel := nodeTemp.Level;
    if nodeTemp.Level = 0 then //在增加一不同Process的主料
    begin
      sProcess := '';
      sCount := '1';
      sRelation := '0';
      sVersion := '';
      sLocation := '';
    end
    else if nodeTemp.Level = 1 then //在此Process中增加一主料
    begin
      sProcess := nodeTemp.Text;
      if sProcess = 'ALL' then
      begin
        MessageDlg('Cann''t Add to this Process.', mtError, [mbOK], 0);
        Exit;
      end;
      sCount := '1';
      sRelation := '0';
      sVersion := '';
      sLocation := '';
      GetProcessID(sProcess, ProcessId);
      if not CheckDup(ProcessId, psItemPart, '', 0) then
      begin
        MessageDlg('Sub Part No Duplicate.', mtError, [mbOK], 0);
        Exit;
      end;
    end
    else if nodeTemp.Level = 2 then //在Part中增加一替代料
    begin
      sProcess := nodeTemp.Parent.Text;
      if sProcess = 'ALL' then
      begin
        MessageDlg('Cann''t Add to this Process.', mtError, [mbOK], 0);
        Exit;
      end;
      sCount := Copy(nodeTemp.Text, Pos('*', nodeTemp.Text) + 2, Pos(' [', nodeTemp.Text) - Pos('*', nodeTemp.Text) - 2);
      sRelation := Copy(nodeTemp.Text, Pos(' [', nodeTemp.Text) + 2, Pos('] ', nodeTemp.Text) - Pos(' [', nodeTemp.Text) - 2);
         //若原本無替代料,需將group改為非0的值 2005/12/19
      if sRelation = '0' then
      begin
        sRelation := '';
        g_sChangeGroup := True;
      end;
      if psItemPart = Copy(nodeTemp.Text, 1, Pos('(', nodeTemp.Text) - 1) then
        if not CheckDup(ProcessId, psItemPart, '', 0) then
        begin
          MessageDlg('Sub Part No Duplicate.', mtError, [mbOK], 0);
          Exit;
        end;
      sVersion := Copy(nodeTemp.Text, Pos('(', nodeTemp.Text) + 1, Pos(')', nodeTemp.Text) - Pos('(', nodeTemp.Text) - 1);
      sLocation := Copy(nodeTemp.Text, Pos('{', nodeTemp.Text) + 1, Pos('}', nodeTemp.Text) - Pos('{', nodeTemp.Text) - 1);
    end
    else if nodeTemp.Level = 3 then
    begin
      sProcess := nodeTemp.Parent.Parent.Text;
      sCount := Copy(nodeTemp.Text, Pos('*', nodeTemp.Text) + 2, Pos(' {', nodeTemp.Text) - Pos('*', nodeTemp.Text) - 2);
      sRelation := Copy(nodeTemp.Parent.Text, Pos(' [', nodeTemp.Parent.Text) + 2, Pos('] ', nodeTemp.Parent.Text) - Pos(' [', nodeTemp.Parent.Text) - 2);
      sVersion := Copy(nodeTemp.Text, Pos('(', nodeTemp.Text) + 1, Pos(')', nodeTemp.Text) - Pos('(', nodeTemp.Text) - 1);
      sLocation := Copy(nodeTemp.Text, Pos('{', nodeTemp.Text) + 1, Pos('}', nodeTemp.Text) - Pos('{', nodeTemp.Text) - 1);
      nodeTemp := nodeTemp.Parent;
    end
    else
    begin
      Exit;
    end;
  end
  else
  begin
    sProcess := '';
    sCount := '1';
    sRelation := '0';
    sVersion := '';
    sLocation := '';
  end;
  sWorkOrder := lablWorkOrder.Caption;
  fBomData := TfBomData.Create(Self);
  with fBomData do
  begin
    giNodeLevel := iNodeLevel;
    lablWorkOrder.Caption := fData.editWO.Text; //sWorkOrder;
    LabPartNo.Caption := psBom;
    editSubPartNo.Text := psItemPart;
    cmbProcess.ItemIndex := cmbProcess.Items.IndexOf(sProcess);
    editQty.Text := sCount;
    editGroup.Text := sRelation;
    editVersion.Text := '';
    editLocation.Text := sLocation;
    if iNodeLevel >= 2 then
    begin
      editSubPartNo.Enabled := False;
      cmbProcess.Enabled := False;
      editQty.Enabled := False;
      editGroup.Enabled := g_sChangeGroup;
    end
    else if iNodeLevel = 1 then
    begin
      editSubPartNo.Enabled := False;
      cmbProcess.Enabled := False;
      editGroup.Enabled := False;
    end;
    if ShowModal = mrOK then
    begin
      if Trim(editVersion.Text) = '' then
        editVersion.Text := 'N/A';
      if cmbProcess.ItemIndex = -1 then
        sProcess := 'ALL'
      else
        sProcess := cmbProcess.Text;

         //2005/12/19
      if (nodeTemp <> nil) and (nodeTemp.Level = 2) and (g_sChangeGroup) then
      begin
        nodeTemp.Text := Copy(nodeTemp.Text, 1, pos('(', nodeTemp.Text) - 2) +
          ' (' + sVersion + ') ' +
          ' * ' + sCount +
          ' [' + editGroup.Text + '] ' +
          ' {' + sLocation + '} ';
      end;
         //
      if (nodeTemp <> nil) and (nodeTemp.Level > 0) then
        nodeTemp := fBom.TreePC.Items.AddChild(nodeTemp, fBom.lvPartNo.Selected.Caption
          + ' (' + editVersion.Text + ')' + ' * ' + editQty.Text
          + ' [' + editGroup.Text + ']'
          + ' {' + editLocation.Text + '}')
      else
      begin
        nodeTemp := fBom.TreePC.Items.AddChild(fBom.TreePC.Items.Item[0], sProcess);
        nodeTemp := fBom.TreePC.Items.AddChild(nodeTemp, fBom.lvPartNo.Selected.Caption
          + ' (' + editVersion.Text + ')' + ' * ' + editQty.Text
          + ' [' + editGroup.Text + ']'
          + ' {' + editLocation.Text + '}');
      end;
      nodeTemp.ImageIndex := fBom.lvPartNo.Selected.ImageIndex;
      Result := True;
    end;
    Free;
  end;
end;

procedure TfBom.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, ImageAll.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfBom.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with ImageAll.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfBom.WMNCHitTest(var msg: TWMNCHitTest);
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then
  begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient(p);
    MouseOnControl := false;
    for i := 0 to ControlCount - 1 do
    begin
      if not MouseOnControl
        then
      begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
          then MouseOnControl := PtInRect(AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

procedure TfBom.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  Authoritys := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    Params.CreateParam(ftString, 'PRG', ptInput);
    Params.CreateParam(ftString, 'FUN', ptInput);
    CommandText := 'Select AUTHORITYS ' +
      'From SAJET.SYS_EMP_PRIVILEGE ' +
      'Where EMP_ID = :EMP_ID and ' +
      'PROGRAM = :PRG and ' +
      'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'Data Center';
    Params.ParamByName('FUN').AsString := 'Route Define';
    Open;
    if not IsEmpty then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  Delete1.Enabled := ((Authoritys = 'Allow To Change') or (Authoritys = 'Full Control'));

  AuthorityRole := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EMP_ID', ptInput);
    Params.CreateParam(ftString, 'PRG', ptInput);
    Params.CreateParam(ftString, 'FUN', ptInput);
    CommandText := 'Select AUTHORITYS ' +
      'From SAJET.SYS_ROLE_PRIVILEGE A, ' +
      'SAJET.SYS_ROLE_EMP B ' +
      'Where A.ROLE_ID = B.ROLE_ID and ' +
      'EMP_ID = :EMP_ID and ' +
      'PROGRAM = :PRG and ' +
      'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'Data Center';
    Params.ParamByName('FUN').AsString := 'Route Define';
    Open;
    if not IsEmpty then
      AuthorityRole := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;

  if not Delete1.Enabled then
  begin
    Delete1.Enabled := ((Authoritys = 'Allow To Change') or (Authoritys = 'Full Control'));
  end;
end;

function TfBom.PrepareProcessData: Boolean;
begin
  with QryData do
  begin
    Close;
    Params.Clear;
    //Params.CreateParam(ftString	,'FCID', ptInput);
    CommandText := 'Select PROCESS_ID,PROCESS_NAME,TYPE_NAME ' +
      'From SAJET.SYS_PROCESS A, ' +
      'SAJET.SYS_OPERATE_TYPE C ' +
                   //'Where A.FACTORY_ID = :FCID and '+
    'WHERE A.OPERATE_ID = C.OPERATE_ID(+) and ' +
      'A.ENABLED = ''Y'' ' +
      'Order By PROCESS_NAME ';
    //Params.ParamByName('FCID').AsString := FcID;
    Open;
    Result := (not IsEmpty);
  end;
end;

function TfBom.GetMaxRouteID: string;
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select NVL(Max(ROUTE_ID),0) + 1 ROUTEID ' +
      'From SAJET.SYS_ROUTE';
    Open;
    if Fieldbyname('ROUTEID').AsString = '1' then
    begin
      Close;
      CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' ROUTEID ' +
        'From SAJET.SYS_BASE ' +
        'Where PARAM_NAME = ''DBID'' ';
      Open;
    end;
    Result := Fieldbyname('ROUTEID').AsString;
    Close;
  end;
end;

function TfBom.GetRouteID(RouteName: string): string;
begin
  Result := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'ROUTENAME', ptInput);
    CommandText := 'Select ROUTE_ID ' +
      'From SAJET.SYS_ROUTE ' +
      'Where ROUTE_NAME = :ROUTENAME ';
    Params.ParamByName('ROUTENAME').AsString := RouteName;
    Open;
    if not IsEmpty then
      Result := Fieldbyname('ROUTE_ID').AsString;
    Close;
  end;
end;

procedure TfBom.UpdateWOBom;
var sProcessID, sBomID, sPartID, sRelation: string;
  I, J, K, iRelation: Integer;
begin

  if TreePC.Items.Item[0].Count <> 0 then
  begin
      //刪除工單原來的BOM表資料
    with QryData do
    begin
      Close;
      Params.Clear;
      CommandText := 'DELETE SAJET.G_WO_BOM '
        + ' WHERE WORK_ORDER = ''' + lablWorkOrder.Caption + ''' ';
      Execute;
    end;
    //將TreeView資料填入資料庫
    iRelation := 0;
    sRelation := '';
    getPartNOID(Copy(TreePC.Items.Item[0].Text, 1, Pos('(', TreePC.Items.Item[0].Text) - 2), True, sBomID);
    for i := 0 to TreePC.Items.Item[0].Count - 1 do
    begin
      getProcessID(TreePC.Items.Item[0].Item[i].Text, sProcessID);
      for j := 0 to TreePC.Items.Item[0].Item[i].Count - 1 do
      begin
        if not getPartNoID(Trim(Copy(TreePC.Items.Item[0].Item[i].Item[j].Text, 1, Pos('(', TreePC.Items.Item[0].Item[i].Item[j].Text) - 1)), True, sPartID) then
          Exit;
        if TreePC.Items.Item[0].Item[i].Item[j].Count = 0 then
          insertWOBom(sBomID, sPartID, sProcessID, '0', TreePC.Items.Item[0].Item[i].item[j])
        else
        begin
          Inc(iRelation);
          sRelation := Copy(TreePC.Items.Item[0].Item[i].Item[j].Text
            , Pos(' [', TreePC.Items.Item[0].Item[i].Item[j].Text) + 2
            , Pos('] ', TreePC.Items.Item[0].Item[i].Item[j].Text) - Pos(' [', TreePC.Items.Item[0].Item[i].Item[j].Text) - 2);
          if sRelation = '' then sRelation := '0';
          insertWOBom(sBomID, sPartID, sProcessID, sRelation, TreePC.Items.Item[0].Item[i].item[j]);
          for k := 0 to TreePC.Items.Item[0].Item[i].item[j].Count - 1 do
          begin
            insertWOBom(sBomID, sPartID, sProcessID, sRelation, TreePC.Items.Item[0].Item[i].item[j].Item[k]);
          end;
        end;
      end;
    end;
  end;
end;

procedure TfBom.CopyToHistory(RecordID: string);
begin
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RCID', ptInput);
    CommandText := 'Insert Into SAJET.SYS_HT_ROUTE ' +
      'Select * from SAJET.SYS_ROUTE ' +
      'Where ROUTE_ID = :RCID ';
    Params.ParamByName('RCID').AsString := RecordID;
    Execute;
  end;
end;

procedure TfBom.ShowProcess;
begin
  lvPartNo.Clear;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART', ptInput);
    CommandText := 'Select PART_NO,SPEC1 '
      + '  FROM SAJET.SYS_PART '
      + ' WHERE ENABLED = ''Y'' '
      + ' AND PART_NO like :PART '
      + ' ORDER BY PART_NO ';
    Params.ParamByName('PART').AsString := editPNFilter.Text;
    Open;
    while not Eof do
    begin
      with lvPartNo.Items.Add do
      begin
        Caption := FieldByName('Part_No').AsString;
        SubItems.Add(Fieldbyname('SPEC1').AsString);
        ImageIndex := 1;
      end;
      next;
    end;
    Close;
  end;
end;

procedure TfBom.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
    CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
      'From SAJET.SYS_FACTORY ' +
      'Where FACTORY_CODE = :FACTORYCODE ';
    Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
    Open;
    if not IsEmpty then
    begin
      FcID := Fieldbyname('FACTORY_ID').AsString;
      LabDesc.Caption := Fieldbyname('FACTORY_DESC').AsString;
    end;
    Close;
  end;
//  ShowProcess;
end;

procedure TfBom.TreePCDragDrop(Sender, Source: TObject; X, Y: Integer);
var S, sRelation, sProcess, sTProcess, sProcessID, sVersion, sItemPartNo: string;
  i: Integer; sResult: Boolean;
begin
  if lablReadOnly.Visible then Exit;
  if (Source is TListView) then
  begin
    if (Source as TListView).Name = 'lvPartNo' then
    begin
      if appendBomData(TreePC.Items.Item[0].Text, lvPartNo.Selected.Caption, TreePC.DropTarget) then
      begin
        updateWOBom;
        ShowBom;
      end;
      TreePC.FullExpand;
      Exit;
    end;
  end;
  if (Source as TTreeView).Name = 'TreePC' then
  begin
    if TreePC.Items.Item[0].Selected then Exit;
    if TreePC.Selected.Level = 1 then Exit;
    if (TreePC.DropTarget.Level > 2) or (TreePC.DropTarget.Level = 0) then
      Exit;
    if TreePC.DropTarget.Level = 2 then
    begin
      sTProcess := TreePC.DropTarget.Parent.Text;
      sVersion := Copy(TreePC.Selected.Text, Pos('(', TreePC.Selected.Text) + 1, Pos(')', TreePC.Selected.Text) - Pos('(', TreePC.Selected.Text) - 1);
      if TreePC.Selected.Level = 2 then
        sProcess := TreePC.Selected.Parent.Text
      else
        sProcess := TreePC.Selected.Parent.Parent.Text;
      getProcessID(sTProcess, sProcessID);
      if sTProcess <> sProcess then
      begin
        if not CheckDup(sProcessID, Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), sVersion, 0) then
        begin
          MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
          Exit;
        end;
        sItemPartNo := Trim(Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 1));
        if sItemPartNo = Trim(Copy(TreePC.DropTarget.Text, 1, Pos('(', TreePC.DropTarget.Text) - 1)) then
        else
        begin
          for i := 0 to TreePC.DropTarget.Count - 1 do
            if sItemPartNo = Trim(Copy(TreePC.DropTarget.Item[i].Text, 1, Pos('(', TreePC.DropTarget.Item[i].Text) - 1)) then
            begin
              sResult := True;
              break;
            end;
          if not sResult then
            if not CheckDup(sProcessID, Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), '', 0) then
            begin
              MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
              Exit;
            end;
        end;
      end
      else
      begin
        if TreePC.Selected.Level = 3 then
        begin
          sItemPartNo := Trim(Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 1));
          if sItemPartNo = Trim(Copy(TreePC.Selected.Parent.Text, 1, Pos('(', TreePC.Selected.Parent.Text) - 1)) then
          begin
            MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
            Exit;
          end;
          for i := 0 to TreePC.Selected.Parent.Count - 1 do
            if sItemPartNo = Trim(Copy(TreePC.Selected.Parent.Item[i].Text, 1, Pos('(', TreePC.Selected.Parent.Item[i].Text) - 1)) then
            begin
              MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
              Exit;
            end;
        end;
      end;
      S := TreePC.DropTarget.Text;
      sRelation := Copy(S, Pos(' [', S) + 2, Pos('] ', S) - Pos(' [', S) - 2);
      if sRelation = '0' then
      begin
        slMaxRelation[slProcess.IndexOf(sTProcess)] := IntToStr(StrToInt(slMaxRelation[slProcess.IndexOf(sTProcess)]) + 1);
        TreePC.DropTarget.Text := Copy(S, 1, Pos(' [', S)) + '[' + slMaxRelation[slProcess.IndexOf(sTProcess)] + Copy(S, Pos('] ', S), Length(S));
      end;
      if TreePC.Selected.Level = 2 then
      begin
        S := TreePC.Selected.Text;
        Delete(S, Pos(' [', s), Pos('] ', S) - Pos(' [', S) + 2);
        TreePC.Selected.Text := s;
      end;
    end
    else
    begin
      sVersion := Copy(TreePC.Selected.Text, Pos('(', TreePC.Selected.Text) + 1, Pos(')', TreePC.Selected.Text) - Pos('(', TreePC.Selected.Text) - 1);
      sTProcess := TreePC.DropTarget.Text;
      if TreePC.Selected.Level = 2 then
      begin
        sProcess := TreePC.Selected.Parent.Text;
        if sTProcess = sProcess then Exit;
      end
      else
        sProcess := TreePC.Selected.Parent.Parent.Text;
      getProcessID(sTProcess, sProcessID);
      if sTProcess <> sProcess then
      begin
        if not CheckDup(sProcessID, Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), sVersion, 0) then
        begin
          MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
          Exit;
        end;
        if not CheckDup(sProcessID, Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), '', 0) then
        begin
          MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
          Exit;
        end;
      end
      else if not CheckDup(sProcessID, Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), '', 1) then
      begin
        MessageDlg('Cann''t Move Sub Part No.', mtError, [mbOK], 0);
        Exit;
      end;
      S := TreePC.Selected.Text;
      if TreePC.Selected.Level = 3 then
        TreePC.Selected.Text := Copy(S, 1, Pos(' {', S) - 1) + ' [0] ' + Copy(S, Pos(' {', S), Length(S))
      else
      begin
        Delete(S, Pos(' [', s), Pos('] ', S) - Pos(' [', S) + 2);
        TreePC.Selected.Text := s;
      end;
    end;
    TreePC.Selected.MoveTo(TreePC.DropTarget, naAddChild);
    for i := TreePC.Selected.Count - 1 downto 0 do
      TreePC.Selected.Item[i].MoveTo(TreePC.Selected, naAdd);
    updateWOBom;
    ShowBom;
  end;
  TreePC.FullExpand;
end;

procedure TfBom.TreePCDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if cmbFactory.Text = '' then Exit;
  if not (((Authoritys = 'Allow To Change') or (Authoritys = 'Full Control')) or
    ((AuthorityRole = 'Allow To Change') or (AuthorityRole = 'Full Control'))) then
    Exit;
  if (Source is TTreeView) then
  begin
    if (Source as TTreeView).Selected <> nil then Accept := True;
  end;
end;

procedure TfBom.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfBom.TreeProcessGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TfBom.TreePCGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TfBom.ShowBom;
var nodeRoot, nodeProcess, nodeMain, nodeSub: TTreeNode;
  sStep, sProcess, sRelation, sBomOption: string;
begin
  TreePC.Items.Clear;
  with QryData do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'Select NVL(E.PROCESS_NAME,''ALL'') PROCESS, D.PART_NO ITEM_PART, ' +
      '       NVL(B.ITEM_GROUP, ''0'') ITEM_GROUP, B.ITEM_COUNT, NVL(B.VERSION,''N/A'') VERSION ' +
      '      ,B.LOCATION ' +
      'FROM SAJET.G_WO_BOM B, ' +
      'SAJET.SYS_PART D, ' +
      'SAJET.SYS_PROCESS E ' +
      'Where B.WORK_ORDER = :WORK_ORDER and ' +
      'B.PART_ID = :PART_ID and ' +
      'B.ITEM_PART_ID = D.PART_ID(+) and ' +
      'B.PROCESS_ID = E.PROCESS_ID(+) ' +
      'Order By PROCESS , D.PART_NO, ITEM_GROUP ';
    Params.ParamByName('WORK_ORDER').AsString := lablWorkOrder.Caption;
    Params.ParamByName('PART_ID').AsString := gsPartID;
    Open;
    sBomOption := ' (WO_BOM)';
    if IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'VER', ptInput);
      CommandText := 'SELECT NVL(D.PROCESS_NAME,''ALL'') PROCESS, C.PART_NO ITEM_PART, '
        + '       NVL(ITEM_GROUP, ''0'') ITEM_GROUP, ITEM_COUNT, NVL(A.VERSION,''N/A'') VERSION '
        + '      ,A.LOCATION '
        + '  FROM SAJET.SYS_BOM A, '
        + '       SAJET.SYS_PART C, '
        + '       SAJET.SYS_PROCESS D, '
        + '       SAJET.SYS_BOM_INFO E '
        + ' WHERE E.PART_ID = :PART_ID '
        + '   AND E.VERSION = :VER '
        + '   AND A.ENABLED = ''Y'' '
        + '   AND A.BOM_ID = E.BOM_ID '
        + '   AND A.ITEM_PART_ID = C.PART_ID '
        + '   AND A.PROCESS_ID = D.PROCESS_ID(+) '
        + ' ORDER BY PROCESS , C.PART_NO, ITEM_GROUP ';
      Params.ParamByName('PART_ID').AsString := gsPartID;
      Params.ParamByName('VER').AsString := labVersion.Caption;
      Open;
      sBomOption := ' (Default)';
    end;

    sStep := '';
    nodeProcess := nil;
    nodeMain := nil;
    nodeRoot := TreePC.Items.AddChildFirst(nil, cmbBOM.Text + sBomOption);
    slMaxRelation.Clear;
    slProcess.Clear;
    while not Eof do
    begin
      if sProcess <> FieldByName('PROCESS').AsString then
      begin
        nodeProcess := TreePC.Items.AddChild(nodeRoot, FieldByName('PROCESS').AsString);
        nodeProcess.ImageIndex := 2;
        nodeProcess.SelectedIndex := 2;
        sRelation := '';
      end;

      if (FieldByName('Item_Group').AsString = '0') or (sRelation <> FieldByName('ITEM_GROUP').AsString) then
      begin
        nodeMain := TreePC.Items.AddChild(nodeProcess, FieldByName('ITEM_PART').AsString +
          ' (' + FieldByName('VERSION').AsString + ') ' +
          ' * ' + FieldByName('ITEM_COUNT').AsString +
          ' [' + FieldByName('ITEM_GROUP').AsString + '] ' +
          ' {' + FieldByName('LOCATION').AsString + '} ');
        nodeMain.ImageIndex := 1;
        nodeMain.SelectedIndex := 1;
      end
      else
      begin
        nodeSub := TreePC.Items.AddChild(nodeMain, FieldByName('ITEM_PART').AsString +
          ' (' + FieldByName('VERSION').AsString + ') ' +
          ' * ' + FieldByName('ITEM_COUNT').AsString +
          ' {' + FieldByName('LOCATION').AsString + '} ');
        nodeSub.ImageIndex := 1;
        nodeSub.SelectedIndex := 1;
      end;
      sProcess := FieldByName('PROCESS').AsString;
      sRelation := FieldByName('ITEM_GROUP').AsString;
      try
        if slProcess.IndexOf(sProcess) = -1 then
        begin
          slProcess.Add(sProcess);
          slMaxRelation.Add('0');
        end
        else if StrToIntDef(slMaxRelation[slProcess.IndexOf(sProcess)], 0) < StrToIntDef(sRelation, 0) then
          slMaxRelation[slProcess.IndexOf(sProcess)] := sRelation;
      except
      end;
      Next;
    end;
  end;
  TreePC.FullExpand;
end;

procedure TfBom.Collapse1Click(Sender: TObject);
begin
  //TreeProcess.FullCollapse;
end;

procedure TfBom.Expanded1Click(Sender: TObject);
begin
  //TreeProcess.FullExpand ;
end;

procedure TfBom.Collapse2Click(Sender: TObject);
begin
  TreePC.FullCollapse;
end;

procedure TfBom.Expand1Click(Sender: TObject);
begin
  TreePC.FullExpand;
end;

procedure TfBom.Delete1Click(Sender: TObject);
var sItemPartID, sProcessID, sGroup: string;
begin
  if TreePC.Selected = nil then Exit;

  if Copy(TreePC.Items.Item[0].Text, Pos('(', TreePC.Items.Item[0].Text), Pos(')', TreePC.Items.Item[0].Text)) = '(Default)' then
    updateWOBom;

  if TreePC.Selected.Level = 0 then
  begin
    if MessageDlg('Delete This BOM ?', mtCustom, mbOKCancel, 0) <> mrOK then
      Exit;

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'Delete SAJET.G_WO_BOM ' +
        'Where WORK_ORDER = :WORK_ORDER ';
      Params.ParamByName('WORK_ORDER').AsString := lablWorkOrder.Caption;
      Execute;
    end;
  end
  else if TreePC.Selected.Level = 1 then
  begin
    if MessageDlg('Delete Those Part of Process ?', mtCustom, mbOKCancel, 0) <> mrOK then
      Exit;

    getProcessID(TreePC.Selected.Text, sProcessID);

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORKORDER', ptInput);
      Params.CreateParam(ftString, 'PROCESSID', ptInput);
      CommandText := 'DELETE SAJET.G_WO_BOM '
        + ' WHERE WORK_ORDER = :WORKORDER '
        + '   AND PROCESS_ID = :PROCESSID ';
      Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
      Params.ParamByName('PROCESSID').AsString := sProcessID;
      Execute;
    end;
  end
  else
  begin
    // 刪除其中一個 Item Part
    if MessageDlg('Delete This Part ?', mtCustom, mbOKCancel, 0) <> mrOK then
      Exit;
    if TreePC.Selected.Level = 2 then
      getProcessID(TreePC.Selected.Parent.Text, sProcessID)
    else
      getProcessID(TreePC.Selected.Parent.Parent.Text, sProcessID);
    getPartNoID(Copy(TreePC.Selected.Text, 1, Pos('(', TreePC.Selected.Text) - 2), False, sItemPartID);

    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORKORDER', ptInput);
      Params.CreateParam(ftString, 'ITEMPARTID', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      CommandText := 'Select ITEM_GROUP FROM SAJET.G_WO_BOM '
        + ' WHERE WORK_ORDER = :WORKORDER '
        + '   AND ITEM_PART_ID = :ITEMPARTID AND PROCESS_ID = :PROCESS_ID';
      Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
      Params.ParamByName('ITEMPARTID').AsString := sItemPartID;
      Params.ParamByName('PROCESS_ID').AsString := sProcessID;
      open;
      sGroup := FieldByName('ITEM_GROUP').asstring;


      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORKORDER', ptInput);
      Params.CreateParam(ftString, 'ITEMPARTID', ptInput);
      Params.CreateParam(ftString, 'VERSION', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      CommandText := 'DELETE SAJET.G_WO_BOM '
        + ' WHERE WORK_ORDER = :WORKORDER '
        + '   AND ITEM_PART_ID = :ITEMPARTID and VERSION = :VERSION AND PROCESS_ID = :PROCESS_ID ';
      Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
      Params.ParamByName('ITEMPARTID').AsString := sItemPartID;
      Params.ParamByName('VERSION').AsString := Copy(TreePC.Selected.Text, Pos('(', TreePC.Selected.Text) + 1, Pos(')', TreePC.Selected.Text) - Pos('(', TreePC.Selected.Text) - 1);
      Params.ParamByName('PROCESS_ID').AsString := sProcessID;
      Execute;

       //Delete後若無替代料,需將group改為0
      if sGroup <> '0' then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORKORDER', ptInput);
        Params.CreateParam(ftString, 'ITEM_GROUP', ptInput);
        CommandText := 'Select COUNT(*) cnt FROM SAJET.G_WO_BOM '
          + ' WHERE WORK_ORDER = :WORKORDER '
          + '   AND ITEM_GROUP = :ITEM_GROUP ';
        Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
        Params.ParamByName('ITEM_GROUP').AsString := sGroup;
        open;
        if FieldByName('cnt').asInteger = 1 then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'WORKORDER', ptInput);
          Params.CreateParam(ftString, 'ITEM_GROUP', ptInput);
          CommandText := 'UPDATE SAJET.G_WO_BOM '
            + 'Set ITEM_GROUP = ''0'' '
            + ' WHERE WORK_ORDER = :WORKORDER '
            + '   AND ITEM_GROUP = :ITEM_GROUP ';
          Params.ParamByName('WORKORDER').AsString := lablWorkOrder.Caption;
          Params.ParamByName('ITEM_GROUP').AsString := sGroup;
          Execute;
        end;
      end;
    end;
  end;
  ShowBom;
end;

procedure TfBom.FormCreate(Sender: TObject);
begin
  ImageAll.Picture := fData.Imagemain.Picture;
  SetTheRegion;
  slMaxRelation := TStringList.Create;
  slProcess := TStringList.Create;
end;

procedure TfBom.editPNFilterKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ShowProcess;
end;

procedure TfBom.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  slProcess.Free;
  slMaxRelation.Free;
end;

procedure TfBom.AddProcess1Click(Sender: TObject);
var nodeSub: TTreeNode;
begin
  fBomData := TfBomData.Create(Self);
  with fBomData do
  begin
    LabType2.Caption := 'Process';
    LabType1.Caption := LabType2.Caption;
    editSubPartNo.Visible := False;
    editQty.Visible := False;
    editVersion.Visible := False;
    editGroup.Visible := False;
    editLocation.Visible := False;
    lablWorkOrder.Visible := False;
    LabPartNo.Visible := False;
    Label10.Visible := False;
    Label3.Visible := False;
    Label5.Visible := False;
    Label7.Visible := False;
    Label2.Visible := False;
    Label6.Visible := False;
    Label9.Visible := False;
    Label8.Visible := False;
    if ShowModal = mrOK then
    begin
      nodeSub := fBom.TreePC.Items.AddChild(fBom.TreePC.Items.Item[0], cmbProcess.Text);
      nodeSub.ImageIndex := 2;
      nodeSub.SelectedIndex := 2;
    end;
    Free;
  end;
end;

end.

