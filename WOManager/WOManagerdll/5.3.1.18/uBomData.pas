unit uBomData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
  TfBomData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    Label6: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    editSubPartNo: TEdit;
    Label1: TLabel;
    editGroup: TEdit;
    Label2: TLabel;
    editQty: TEdit;
    Label5: TLabel;
    Label7: TLabel;
    editVersion: TEdit;
    cmbProcess: TComboBox;
    Label8: TLabel;
    LabPartNo: TLabel;
    Label9: TLabel;
    lablWorkOrder: TLabel;
    Label10: TLabel;
    editLocation: TEdit;
    Label3: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
    giNodeLevel: Integer;
    procedure GetAllProcess;
    //Function  GetProcessID(Process : String; var ProcessId : String) : Boolean;
    procedure CopyToHistory(RecordID: string);
    procedure SetTheRegion;
    //Function  GetPartNoID(PartNo : String; var PartId : String) : Boolean;
  end;

var
  fBomData: TfBomData;

implementation

{$R *.DFM}

uses uBOM, uWOManager;

procedure TfBomData.GetAllProcess;
begin
  cmbProcess.Items.Clear;
  if editSubPartNo.Visible then
    cmbProcess.Items.Add('');
  with fWoManager.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select PROCESS_NAME ' +
      'From SAJET.SYS_PROCESS ' +
      'Where ENABLED = ''Y'' ' +
      'Order By PROCESS_NAME ';
    Open;
    while not Eof do
    begin
      cmbProcess.Items.Add(Fieldbyname('PROCESS_NAME').AsString);
      Next;
    end;
    Close;
  end;
end;

procedure TfBomData.sbtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfBomData.FormCreate(Sender: TObject);
begin
  Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
  SetTheRegion;
  GetAllProcess;
end;

procedure TfBomData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfBomData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect(Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfBomData.WMNCHitTest(var msg: TWMNCHitTest);
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

procedure TfBomData.sbtnSaveClick(Sender: TObject);
var PartID, SubPartID, ProcessID: string; i: Integer;
begin
  ModalResult := mrNone;
  if editSubPartNo.Visible then
  begin
    if Trim(editSubPartNo.Text) = '' then
    begin
      MessageDlg('Sub Parts Error !!', mtError, [mbCancel], 0);
      editSubPartNo.SetFocus;
      Exit;
    end;

    if cmbProcess.ItemIndex = -1 then
    begin
      MessageDlg('Process not found !!', mtError, [mbCancel], 0);
      cmbProcess.SetFocus;
      Exit;
    end;

    if StrtoIntDef(editQty.Text, 0) = 0 then
    begin
      MessageDlg('Qty Error !!', mtError, [mbCancel], 0);
      editQty.SetFocus;
      Exit;
    end;

    PartID := '';
    if not fBom.GetPartNoID(Copy(LabPartNo.Caption, 1, Pos('(', LabPartNo.Caption) - 2), True, PartId) then
      Exit;

    SubPartID := '';
    if not fBom.GetPartNoID(editSubPartNo.Text, True, SubPartId) then
      Exit;

    ProcessId := '0';
    fBom.GetProcessID(cmbProcess.Text, ProcessId);

  //若加入替代料,Group不可為0
    if (fBom.g_sChangeGroup) and ((editGroup.Text = '0') or (trim(editGroup.Text) = '')) then
    begin
      MessageDlg('Please Change Group (Sub Parts)!!', mtError, [mbCancel], 0);
      editGroup.SetFocus;
      Exit;
    end;

    with fWOManager.QryTemp do
    begin
      if giNodeLevel <> 2 then
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        Params.CreateParam(ftString, 'PART_ID', ptInput);
        Params.CreateParam(ftString, 'sProcessID', ptInput);
        Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
        Params.CreateParam(ftString, 'item_group', ptInput);
        CommandText := 'Select PART_ID ' +
          'From SAJET.G_WO_BOM ' +
          'Where WORK_ORDER = :WORK_ORDER ' +
          'and PART_ID = :PART_ID ' +
          'and Process_ID = :sProcessID ' +
          'and ITEM_PART_ID = :ITEM_PART_ID ';
        CommandText := CommandText + 'and item_group <> :item_group ';
        Params.ParamByName('WORK_ORDER').AsString := lablWorkOrder.Caption;
        Params.ParamByName('PART_ID').AsString := PartId;
        Params.ParamByName('sProcessID').AsString := ProcessId;
        Params.ParamByName('ITEM_PART_ID').AsString := SubPartId;
        Params.ParamByName('item_group').AsString := editGroup.Text;
        Open; ;
        if not IsEmpty then
        begin
          Close;
          MessageDlg('Sub Part No Duplicate!!', mtError, [mbOK], 0);
          Exit;
        end;
      end;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'VER', ptInput);
      Params.CreateParam(ftString, 'sProcessID', ptInput);
      Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
      CommandText := 'Select PART_ID ' +
        'From SAJET.G_WO_BOM ' +
        'Where WORK_ORDER = :WORK_ORDER ' +
        'and PART_ID = :PART_ID and VERSION = :VER ' +
        'and Process_ID = :sProcessID ' +
        'and ITEM_PART_ID = :ITEM_PART_ID ';
      Params.ParamByName('WORK_ORDER').AsString := lablWorkOrder.Caption;
      Params.ParamByName('PART_ID').AsString := PartId;
      if editVersion.Text = '' then
        Params.ParamByName('VER').AsString := 'N/A'
      else
        Params.ParamByName('VER').AsString := editVersion.Text;
      Params.ParamByName('sProcessID').AsString := ProcessId;
      Params.ParamByName('ITEM_PART_ID').AsString := SubPartId;
      Open; ;
      if not IsEmpty then
      begin
        Close;
        MessageDlg('Sub Part No Duplicate!!', mtError, [mbOK], 0);
        Exit;
      end;
      Close;
    end;
    ModalResult := mrOK;
  end
  else
  begin
    for i := 0 to fBom.TreePc.Items.Count - 1 do
      if fBom.TreePC.Items.Item[i].Level = 1 then
        if fBom.TreePC.Items.Item[i].Text = cmbProcess.Text then
        begin
          MessageDlg('Process Duplicate!!', mtError, [mbOK], 0);
          Exit;
        end;
    ModalResult := mrOK;
  end;
end;

procedure TfBomData.CopyToHistory(RecordID: string);
begin
end;

end.

