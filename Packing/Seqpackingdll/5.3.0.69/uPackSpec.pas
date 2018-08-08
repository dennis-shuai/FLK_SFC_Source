unit uPackSpec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TformPackSpec = class(TForm)
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    lablPart: TLabel;
    lablWO: TLabel;
    GroupBox1: TGroupBox;
    Image1: TImage;
    sbtnOK: TSpeedButton;
    Image2: TImage;
    sbtnCancel: TSpeedButton;
    LVData: TListView;
    combPackSpec: TComboBox;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton4: TSpeedButton;
    LvSort: TListView;
    procedure sbtnCancelClick(Sender: TObject);
    procedure sbtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formPackSpec: TformPackSpec;

implementation

uses uPacking, DB;

{$R *.dfm}

procedure TformPackSpec.sbtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TformPackSpec.sbtnOKClick(Sender: TObject);
var sMsg: string; iPallet, iCarton, iBox, i: Integer;
begin
  if LvSort.Items.Count = 0 then
    Exit;
  with fPacking.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
    CommandText := 'SELECT PKSPEC_NAME, PALLET_QTY, CARTON_QTY, BOX_QTY ' +
      'FROM   SAJET.SYS_PKSPEC ' +
      'WHERE  PKSPEC_NAME = :PKSPEC_NAME ';
    Params.ParamByName('PKSPEC_NAME').AsString := LvSort.Items.Item[0].Caption;
    Open;
    iPallet := FieldByName('PALLET_QTY').AsInteger;
    iCarton := FieldByName('CARTON_QTY').AsInteger;
    iBox := FieldByName('Box_QTY').AsInteger;
    Close;
  end;
{  if (iPallet < StrToInt(fPacking.LabPalletQty.Caption)) and fPacking.editPallet.Visible then
  begin
    MessageDlg('Invalid Pallet Capacity!! (' + fPacking.LabPalletQty.Caption + ' -> ' + IntToStr(iPallet) + ')', mtError, [mbOK], 0);
    Exit;
  end;
  if (iCarton < StrToInt(fPacking.LabCartonQty.Caption)) and fPacking.editCarton.Visible then
  begin
    MessageDlg('Invalid Carton Capacity!! (' + fPacking.LabCartonQty.Caption + ' -> ' + IntToStr(iCarton) + ')', mtError, [mbOK], 0);
    Exit;
  end;
  if (iBox < StrToInt(fPacking.LabBoxQty.Caption)) and fPacking.editBox.Visible then
  begin
    MessageDlg('Invalid Box Capacity!! (' + fPacking.LabBoxQty.Caption + ' -> ' + IntToStr(iBox) + ')', mtError, [mbOK], 0);
    Exit;
  end;
  sMsg := '';
  if (iPallet = StrToInt(fPacking.LabPalletQty.Caption)) and fPacking.editPallet.Visible then
  begin
    if (StrToInt(fPacking.LabCartonQty.Caption) <> 0) and fPacking.editCarton.Visible then
    begin
      MessageDlg('Invalid Pallet Capacity!! (' + fPacking.LabPalletQty.Caption + ' + 1 -> ' + IntToStr(iPallet) + ')', mtError, [mbOK], 0);
      Exit;
    end;
  end;
  if (iCarton = StrToInt(fPacking.LabCartonQty.Caption)) and fPacking.editCarton.Visible then
  begin
    if (fPacking.editBox.Visible) and (StrToInt(fPacking.LabBoxQty.Caption) <> 0) then
    begin
      MessageDlg('Invalid Carton Capacity!! (' + fPacking.LabCartonQty.Caption + ' + 1 -> ' + IntToStr(iCarton) + ')', mtError, [mbOK], 0);
      Exit;
    end;
  end; }
  with fPacking.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    CommandText := 'delete from sajet.g_pack_spec '
                 + 'where work_order = :WORK_ORDER ';
    Params.ParamByName('WORK_ORDER').AsString := lablWO.Caption;
    Execute;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODEL_ID', ptInput);
    Params.CreateParam(ftString, 'PKSPEC_NAME', ptInput);
    Params.CreateParam(ftString, 'PALLET_CAPACITY', ptInput);
    Params.CreateParam(ftString, 'CARTON_CAPACITY', ptInput);
    Params.CreateParam(ftString, 'Box_CAPACITY', ptInput);
    Params.CreateParam(ftString, 'Sequence', ptInput);
    Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
    CommandText := 'Insert Into SAJET.G_PACK_SPEC ' +
      '(WORK_ORDER,MODEL_ID,PKSPEC_NAME,PALLET_CAPACITY,CARTON_CAPACITY,BOX_CAPACITY,Sequence,UPDATE_USERID)' +
      'Values (:WORK_ORDER,:MODEL_ID,:PKSPEC_NAME,:PALLET_CAPACITY,:CARTON_CAPACITY,:BOX_CAPACITY,:Sequence,:UPDATE_USERID) ';
    for i := 0 to LvSort.Items.Count - 1 do
    begin
      Close;
      Params.ParamByName('WORK_ORDER').AsString := lablWO.Caption;
      Params.ParamByName('MODEL_ID').AsString := fPacking.mPartID;
      Params.ParamByName('PKSPEC_NAME').AsString := LvSort.Items.Item[i].Caption;
      Params.ParamByName('PALLET_CAPACITY').AsString := LvSort.Items.Item[i].SubItems[2];
      Params.ParamByName('CARTON_CAPACITY').AsString := LvSort.Items.Item[i].SubItems[1];
      Params.ParamByName('Box_CAPACITY').AsString := LvSort.Items.Item[i].SubItems[0];
      Params.ParamByName('Sequence').AsInteger := i + 1;
      Params.ParamByName('UPDATE_USERID').AsString := fPacking.UpdateUserID;
      Execute;
      Close;
    end;
  end;
  fPacking.sPKSpec := LvSort.Items.Item[0].Caption;
  fPacking.LabPalletCap.Caption := IntToStr(iPallet);
  fPacking.LabCartonCap.Caption := IntToStr(iCarton);
  fPacking.LabBoxCap.Caption := IntToStr(iBox);
{  //只更改目前的包裝方式,不動DATABASE
  fPacking.tsPackSpec.Clear;
  fPacking.tsPackSpec.Add(formPackSpec.combPackSpec.Text);
  fPacking.tsPackSpec.Add(formPackSpec.lablBoxQty.Caption);
  fPacking.tsPackSpec.Add(formPackSpec.lablCartonQty.Caption);
  fPacking.tsPackSpec.Add(formPackSpec.lablPalletQty.Caption);
  fPacking.ShowPackSpec;}
  if sMsg <> '' then
    MessageDlg(sMsg, mtWarning, [mbOK], 0);
  modalResult := mrOK;
end;

procedure TformPackSpec.FormCreate(Sender: TObject);
begin
  modalResult := mrNone;
end;

procedure TformPackSpec.SpeedButton1Click(Sender: TObject);
var I, j: Integer; mS, m1, m2, m3: string;
begin
  If LvSort.Selected = nil Then Exit;
  If LvSort.Selected.Index = 0 Then Exit;
  I :=LvSort.Selected.Index;

  mS := LvSort.Items[I].Caption;
  m1 := LvSort.Items[I].SubItems[0];
  m2 := LvSort.Items[I].SubItems[1];
  m3 := LvSort.Items[I].SubItems[2];
  LvSort.Items[I].Caption := LvSort.Items[I - 1].Caption;
  for j := 0 to 2 do
    LvSort.Items[I].SubItems[j] := LvSort.Items[I - 1].SubItems[j];
  LvSort.Items[I].Caption := LvSort.Items[I - 1].Caption;
  LvSort.Items[I - 1].Caption := mS;
  LvSort.Items[I - 1].SubItems[0] := m1;
  LvSort.Items[I - 1].SubItems[1] := m2;
  LvSort.Items[I - 1].SubItems[2] := m3;
  LvSort.ItemIndex := I - 1;
end;

procedure TformPackSpec.SpeedButton4Click(Sender: TObject);
var I, j: Integer; mS, m1, m2, m3: string;
begin
  If LvSort.Selected = nil Then Exit;
  If LvSort.Selected.Index = (LvSort.Items.Count - 1) Then Exit;
  I :=LvSort.Selected.Index;

  mS := LvSort.Items[I].Caption;
  m1 := LvSort.Items[I].SubItems[0];
  m2 := LvSort.Items[I].SubItems[1];
  m3 := LvSort.Items[I].SubItems[2];
  LvSort.Items[I].Caption := LvSort.Items[I + 1].Caption;
  for j := 0 to 2 do
    LvSort.Items[I].SubItems[j] := LvSort.Items[I + 1].SubItems[j];
  LvSort.Items[I + 1].Caption := mS;
  LvSort.Items[I + 1].SubItems[0] := m1;
  LvSort.Items[I + 1].SubItems[1] := m2;
  LvSort.Items[I + 1].SubItems[2] := m3;
  LvSort.ItemIndex := I + 1;
end;

procedure TformPackSpec.SpeedButton3Click(Sender: TObject);
var i: Integer;
begin
  If LvData.Selected = nil Then Exit;
  With LvSort.Items.Add do begin
    Caption := LvData.Selected.Caption;
    for i := 0 to 2 do
      SubItems.Add(LvData.Selected.SubItems[i]);
  end;
  LvData.Items.Delete(LvData.ItemIndex);
end;

procedure TformPackSpec.SpeedButton2Click(Sender: TObject);
var i: Integer;
begin
  If LvSort.Selected = nil Then Exit;
  With LvData.Items.Add do begin
    Caption := LvSort.Selected.Caption;
    for i := 0 to 2 do
      SubItems.Add(LvSort.Selected.SubItems[i]);
  end;
  LvSort.Items.Delete(LvSort.ItemIndex);
end;

end.

