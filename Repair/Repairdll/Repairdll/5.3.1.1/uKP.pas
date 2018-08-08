unit uKP;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, Buttons, DB, BmpRgn, DBClient,
  jpeg;

type
  TformKP = class(TForm)
    Label1: TLabel;
    Label5: TLabel;
    dbgridKP: TDBGrid;
    DataSource1: TDataSource;
    LabNewKP: TLabel;
    editKP: TEdit;
    memo: TMemo;
    LabRemark: TLabel;
    labSN: TLabel;
    Imagemain: TImage;
    Image3: TImage;
    sbtnSave: TSpeedButton;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    IMGRemove: TImage;
    sbtnRemoveKP: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lablMsg: TLabel;
    IMGRemoveAll: TImage;
    sbtnRemoveAllKP: TSpeedButton;
    labEC: TLabel;
    editEc: TEdit;
    cmbEC: TComboBox;
    rbYes: TRadioButton;
    rbNo: TRadioButton;
    cmbECID: TComboBox;
    Bevel1: TBevel;
    strEC: TStringGrid;
    LabNewKPNO: TLabel;
    EditKPNO: TEdit;
    CBYes: TCheckBox;
    LabcbYES: TLabel;
    procedure sbtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure sbtnRemoveKPClick(Sender: TObject);
    procedure rbYesClick(Sender: TObject);
    procedure rbNoClick(Sender: TObject);
    procedure editEcKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure sbtnRemoveAllKPClick(Sender: TObject);
    procedure dbgridKPCellClick(Column: TColumn);
  private
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
    { Private declarations }
  public
    RecID: string;
    procedure SetTheRegion;
    function CheckNewKP: Boolean;
    function CheckNewKP_Replace: Boolean;
    function GET_PARTNO(sKPSN: string): string;
    function GET_PARTID(sKPSN: string): string;
    function GetKPRECID: string;
    function GetKPDefectRECID: string;
    function CheckNewKPNO: Boolean;
    { Public declarations }

  end;

var
  formKP: TformKP;

implementation

{$R *.dfm}

uses uRepair;
{ TformKP }

procedure TformKP.sbtnCloseClick(Sender: TObject);
begin
   // replace kp介面
  IF  (sbtnSave.Visible)  Then
     begin
          fRepair.ShowKP;
          fRepair.g_endkpcount:=0;
          fRepair.g_endkpcount:= fRepair.QryData.RecordCount;  //replace kp　之後kpsn的個數
          if  (fRepair.g_startkpcount)<>(fRepair.g_endkpcount) then
            begin
              showmessage('KPSN COUNT IS ERROR '#13#10+ 'Replace Before is '+inttostr(fRepair.g_startkpcount)+#13#10+'Replace After is ' +inttostr(fRepair.g_endkpcount)+#13#10+'Call SFC Administrator');
              exit;
            end;
     end;
  Close;
end;

procedure TformKP.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
  SetWindowRgn(handle, HR, true);
  Invalidate;
end;

procedure TformKP.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
  begin
    Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
    SetTheRegion;
  end;
end;

procedure TformKP.sbtnSaveClick(Sender: TObject);
var sOldKPSN, sNewKPSN, sRes, sNewKPNO: string; sPass: Integer;
  sFlag, sNewRecID, sSUBRecID, sOldKPSNID: string;
  I, iTemp: Integer;
  sNewItem: string;
begin
  lablMsg.Caption := '';
  if (rbYes.Checked) then
  begin
    if cmbEC.Items.Count = 0 then
    begin
      ShowMessage('Input Defect Code!!');
      Exit;
    end;
    sFlag := 'Y';
  end
  else
    sFlag := 'N';
  if dbgridKP.SelectedIndex < 0 then
    Exit;
  if editKP.Text = '' then
    Exit;
  if fRepair.QryData.RecordCount = 0 then
    Exit;
     //chECK r108
  // add by key 20070918 for check new kpno ,KPNO 不記錄到資料庫中
  if CBYES.Checked then
    BEGIN
      if editkpno.Text ='' then
         begin
            editkpno.SelectAll ;
            editkpno.SetFocus ;
            ShowMessage('Input New KPNO!!');
            Exit;
        end
     ELSE
      IF not checknewkpno then
        begin
            editkpno.SelectAll ;
            editkpno.SetFocus ;
            ShowMessage('New KPNO Is Error');
            Exit;
        end;
    END;

  if not CheckNewKP then
  begin
    ShowMessage('New KPSN already in use!!');
    editKp.SelectAll;
    Exit;
  end;
     // 檢查 G_SN_REPAIR_REPLACE_KP 中的Flag
  if not CheckNewKP_Replace then
  begin
    ShowMessage('KPSN not Repair !!');
    editKp.SelectAll;
    Exit;
  end;
  sOldKPSN := fRepair.QryData.FieldByName('KPSN').AsString;
  sNewKPSN := editKP.Text;
  sNewKPNO := '';
     {sTemp := fRepair.QryData.FieldByName('Process_Id').AsString;
     sTemp := sNewKPSN;
     sTemp := labSN.Caption;
     sTemp := fRepair.QryData.FieldByName('ID').AsString;
     sTemp :=  fRepair.QryData.FieldByName('ITEM_GROUP').AsString;
     Exit;  }
     // 檢查 KPSN 相關項目
  with fRepair.SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_REPAIR_PART');
      FetchParams;
      Params.ParamByName('TPROCESSID').AsString := fRepair.QryData.FieldByName('Process_Id').AsString;
      Params.ParamByName('TREV').AsString := sNewKPSN;
      Params.ParamByName('TSN').AsString := labSN.Caption;
      Params.ParamByName('TKPSN').AsString := sOldKPSN;
      Params.ParamByName('TKPID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('TITEMG').AsString := fRepair.QryData.FieldByName('ITEM_GROUP').AsString;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
      sPass := Params.ParamByName('TPASS').AsInteger;
      sNewKPNO := Params.ParamByName('U_PARTID').AsString;
      sNewItem := Params.ParamByName('U_ITEM').AsString;
    except
      on E: Exception do
        sRes := 'SJ_REPAIR_PART Exception:' + E.Message;
    end;
    editKP.SelectAll;
    Close;
  end;

  //ADD BY KEY 2007/09/15 CHECK NEW KP IS PART_NO OR CUST_PART_NO OR VENDOR_PART_NO
  //CHECK OLD KPSN IS 'N/A'
  if (sres='OK') and (sPass=2) and  (sOldKPSN <> 'N/A') then
    begin
      ShowMessage('NEW KPSN IS PART_NO(CUST_PART_NO OR VENDOR_PART_NO)'+#13#10+'OLD KPSN<>N/A' );
      Exit;
    end;

  if sRes <> 'OK' then
  begin
    if sPass = 1 then
    begin
      if MessageDlg('Sure to Replace ' + fRepair.QryData.FieldByName('KPSN').AsString + '?'
        , mtWarning, [mbYes, mbNo], 0) <> mrYes then
        exit;
    end
    else
    begin
      MessageDlg(sRes, mtError, [mbOK], 0);
      Exit;
    end;
  end;

           //若有PartMap,檢查New KP的料號是否正確
{           sNewKPNO := GET_PARTNO(sNewKPSN);
           if (sNewKPNO <> '') and (sNewKPNO <> fRepair.QryData.FieldByName('KPNO').AsString) then
           begin
             MessageDlg('KPNO "'+sNewKPNO+'" Error',mtError,[mbCancel],0);
             exit;
           end;}

  //UPdate 2008/12/25
  IF CBYES.Checked THEN
     sNewKPNO:=fRepair.QryData.FieldByName('ID').AsString;

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'KPSN', ptInput);
    Params.CreateParam(ftString, 'KPNO', ptInput);
    Params.CreateParam(ftString, 'ID', ptInput);
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftString, 'PARTID', ptInput);
    CommandText := 'Update SAJET.G_SN_KEYPARTS ' +
      'Set ITEM_PART_SN = :KPSN, ' +
      'item_part_id = :kpno, ' +
      'Update_USERID = :ID, ' +
      'Update_Time = sysdate ' +
     // 'Item_Group = :Item_Group ' +
      'Where SERIAL_NUMBER = :SN ' +
      'And ITEM_PART_SN = :PARTID';
                               //'And Item_PART_ID = :PARTID';
    if sOldKPSN = 'N/A' then
      Params.ParamByName('KPSN').AsString := 'N/A'
    else
      Params.ParamByName('KPSN').AsString := sNewKPSN;
    if (sNewKPNO <> '') and (sNewKPNO <> '0') then
      Params.ParamByName('KPNO').AsString := sNewKPNO
    else
      Params.ParamByName('KPNO').AsString := fRepair.QryData.FieldByName('ID').AsString;
    Params.ParamByName('ID').AsString := fRepair.UpdateUserID;
   // Params.ParamByName('Item_Group').AsString := sNewItem;  //update by key 2007/09/24 現在程式replace kp 時，item_group valve is null(bg),並且為了入庫等程式依kp bom  ,check kpcount  個數。在g_sn_keypats 中,需要建kp bom的kp,item_group value is not null,不需要建kp bom的kp,item_group value is null
    Params.ParamByName('SN').AsString := labSN.Caption;
    Params.ParamByName('PARTID').AsString := sOldKPSN;
                //Params.ParamByName('PARTID').AsString := fRepair.QryData.FieldByName('ID').AsString;
    Execute;
    Close;
  end;

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RECID', ptInput);
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftString, 'EMP', ptInput);
    Params.CreateParam(ftString, 'PartID', ptInput);
    Params.CreateParam(ftString, 'OldKPSN', ptInput);
    Params.CreateParam(ftString, 'NewKPSN', ptInput);
    Params.CreateParam(ftString, 'REMARK', ptInput);
    Params.CreateParam(ftString, 'Flag', ptInput);
    CommandText := 'Insert Into SAJET.G_SN_REPAIR_REPLACE_KP '
      + '(recid, serial_number, replace_emp_id, replace_time,item_part_id,old_part_sn,new_part_id,new_part_sn,remark,Flag) '
      + 'Values(:RECID,:SN,:EMP,Sysdate,:PartID,:OldKPSN,:NewPartID,:NewKPSN,:Remark,:Flag) ';
    Params.ParamByName('RECID').AsString := RecID;
    Params.ParamByName('SN').AsString := labSN.Caption;
    Params.ParamByName('EMP').AsString := fRepair.UpdateUserID;
    Params.ParamByName('PartID').AsString := fRepair.QryData.FieldByName('ID').AsString;
    Params.ParamByName('OldKPSN').AsString := sOldKPSN;
    if (sNewKPNO <> '') and (sNewKPNO <> '0') then
      Params.ParamByName('NewPartID').AsString := sNewKPNO
    else
      Params.ParamByName('NewPartID').AsString := fRepair.QryData.FieldByName('ID').AsString;
    if sOldKPSN = 'N/A' then
      Params.ParamByName('NewKPSN').AsString := 'N/A'
    else
      Params.ParamByName('NewKPSN').AsString := sNewKPSN;
    Params.ParamByName('REMARK').AsString := memo.Text;
    Params.ParamByName('Flag').AsString := sFlag;
    Execute;
    Close;
  end;
 // 填入KP Defect
  if sFlag = 'Y' then
  begin
    with fRepair.QryTemp do
    begin
      sNewRecID := GetKPRECID;
      sOldKPSNID := GET_PARTID(sOldKPSN);
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'PART_SN', ptInput);
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'STAGE_ID', ptInput);
      Params.CreateParam(ftString, 'PDLINE_ID', ptInput);
      Params.CreateParam(ftString, 'TEST_EMP_ID', ptInput);
      CommandText := 'INSERT INTO SAJET.G_KP_DEFECT_H '
        + '(RECID,PART_SN,PART_ID,TERMINAL_ID,PROCESS_ID,STAGE_ID,PDLINE_ID ,TEST_EMP_ID) '
        + 'VALUES '
        + '(:RECID,:PART_SN,:PART_ID,:TERMINAL_ID,:PROCESS_ID,:STAGE_ID,:PDLINE_ID ,:TEST_EMP_ID) ';
      Params.ParamByName('RECID').AsString := sNewRecID;
      Params.ParamByName('PART_SN').AsString := sOldKPSN;

      if (sNewKPNO <> '') and (sNewKPNO <> '0') then
        Params.ParamByName('PART_ID').AsString := sNewKPNO
      else
        Params.ParamByName('PART_ID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('TERMINAL_ID').AsString := fRepair.TerminalID;
      Params.ParamByName('PROCESS_ID').AsString := fRepair.ProcessId;
      Params.ParamByName('STAGE_ID').AsString := fRepair.StageID;
      Params.ParamByName('PDLINE_ID').AsString := fRepair.PDLineId;
      Params.ParamByName('TEST_EMP_ID').AsString := fRepair.UpdateUserID;
      Execute;
      Close;
      for iTemp := 0 to cmbEC.Items.Count - 1 do
      begin
                       // Defect
        sSUBRecID := GetKPDEFECTRECID;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PARENT_ID', ptInput);
        Params.CreateParam(ftString, 'RECID', ptInput);
        Params.CreateParam(ftString, 'DEFECT_ID', ptInput);
        Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
        Params.CreateParam(ftString, 'TEST_EMP_ID', ptInput);
        CommandText := 'INSERT INTO SAJET.G_KP_DEFECT_D '
          + '(PARENT_ID,RECID,DEFECT_ID,PROCESS_ID,TEST_EMP_ID ) '
          + 'VALUES '
          + '(:PARENT_ID,:RECID,:DEFECT_ID,:PROCESS_ID,:TEST_EMP_ID ) ';
        Params.ParamByName('PARENT_ID').AsString := sNewRecID;
        Params.ParamByName('RECID').AsString := sSUBRecID;
        Params.ParamByName('DEFECT_ID').AsString := cmbECID.Items.Strings[iTemp];
        Params.ParamByName('PROCESS_ID').AsString := fRepair.ProcessId;
        Params.ParamByName('TEST_EMP_ID').AsString := fRepair.UpdateUserID;
        Execute;
        Close;
      end;
      Close;
                   {Params.Clear;
                   Params.CreateParam(ftString	,'KPSN', ptInput);
                   CommandText := 'UPDATE SAJET.G_PART_MAP  SET STATUS=''1'' WHERE PART_SN  = :KPSN ';
                   Params.ParamByName('KPSN').AsString := sOldKPSN;
                   Execute;
                   Close;}
    end;
  end; //IF sFlag = 'Y'


  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'OldKPSN', ptInput);
    CommandText := 'Update SAJET.G_PART_MAP '
      + 'Set Used_Flag = ''0'' '
      + 'Where PART_SN = :OldKPSN ';
    Params.ParamByName('OldKPSN').AsString := sOldKPSN;
    Execute;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'NewKPSN', ptInput);
    CommandText := 'Update SAJET.G_PART_MAP '
      + 'Set Used_Flag = ''1'' '
      + 'Where PART_SN = :NewKPSN ';
    Params.ParamByName('NewKPSN').AsString := sNewKPSN;
    Execute;
    Close;
  end;
  fRepair.QryData.Close;
  fRepair.QryData.Open;
  fRepair.QryData.Locate('KPSN', sNewKPSN, []);
  if lablMsg.Font.Color = clWindowText then
    lablMsg.Font.Color := clRed
  else
    lablMsg.Font.Color := clWindowText;
  lablMsg.Caption := 'Replace OK';
  editKP.Text := '';
  editkpno.Text :='';
  cbyes.Checked :=True;
  memo.Lines.Clear;
  cmbEC.Items.Clear;
  cmbECID.Items.Clear;
  for I := 1 to strEC.RowCount - 1 do
    strEC.Rows[I].Clear;
  strEC.RowCount := 2;
//           ModalResult := mrOK;
end;

procedure TformKP.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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

procedure TformKP.WMNCHitTest(var msg: TWMNCHitTest);
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

function TformKP.CheckNewKP: Boolean;
begin

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'KPSN', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.G_SN_KEYPARTS ' +
      'Where ITEM_PART_SN = :KPSN ';
    Params.ParamByName('KPSN').AsString := editKP.Text;
    Open;
    if RecordCount <> 0 then
      Result := False
    else
      Result := True;
    Close;
  end;
end;

//add by key 20070918 for check kpno
function TformKP.CheckNewKPNO: Boolean;
VAR  TKPID :STRING;
begin
  Result := False ;

  TKPID:= fRepair.QryData.FieldByName('ID').AsString;
  with fRepair.QryTemp do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      CommandText := 'SELECT PART_NO, CUST_PART_NO, VENDOR_PART_NO  FROM SAJET.SYS_PART '
                 +'  WHERE PART_ID=:PART_ID AND ROWNUM = 1 ';
      Params.ParamByName('PART_ID').AsString := TKPID;
      Open;
      if not isempty then
      BEGIN
          if fieldbyname('part_no').AsString = editkpno.text then
             Result := True
          else if fieldbyname('cUST_PART_NO').AsString = editkpno.text then
             Result := True
          else if fieldbyname('VENDOR_PART_NO').AsString = editkpno.text then
             Result := True;
      END;
  END;
end;

function TformKP.GET_PARTNO(sKPSN: string): string;
begin
  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'KPSN', ptInput);
    CommandText := 'Select b.part_no ' +
      'From SAJET.G_PART_MAP a ' +
      '    ,SAJET.SYS_PART b ' +
      'Where a.PART_SN = :KPSN ' +
      'and a.Part_ID = b.Part_ID(+) ';
    Params.ParamByName('KPSN').AsString := sKPSN;
    Open;
    if RecordCount > 0 then
      Result := FieldByName('part_no').asstring
    else
      Result := '';
    Close;
  end;
end;

function TformKP.GET_PARTID(sKPSN: string): string;
begin
  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'KPSN', ptInput);
    CommandText := 'Select part_ID ' +
      'From SAJET.G_PART_MAP ' +
      'Where PART_SN = :KPSN ';
    Params.ParamByName('KPSN').AsString := sKPSN;
    Open;
    if RecordCount > 0 then
      Result := FieldByName('part_ID').asstring
    else
      Result := '';
    Close;
  end;
end;

procedure TformKP.sbtnRemoveKPClick(Sender: TObject);
var
  sFlag, sOldKPSNID, sNewRecID, sSUBRecID: string;
  I, iTemp: Integer;
begin
     // remove 單筆也記錄  是否不良 與 Defect Code 等
  lablMsg.Caption := '';
  if dbgridKP.SelectedIndex < 0 then
    Exit;
  if fRepair.QryData.RecordCount = 0 then
    Exit;
  if (rbYes.Checked) then
  begin
    if cmbEC.items.Count = 0 then
    begin
      ShowMessage('Input Defect Code!!');
      Exit;
    end;
    sFlag := 'Y';
  end
  else
    sFlag := 'N';

  if MessageDlg('Remove ' + fRepair.QryData.FieldByName('KPSN').AsString + '?'
    , mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    exit;

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    Params.CreateParam(ftString, 'PARTSN', ptInput);
    CommandText := 'Delete SAJET.G_SN_KEYPARTS ' +
      'Where SERIAL_NUMBER = :SN ' +
      'And ITEM_PART_SN = :PARTSN';
    Params.ParamByName('SN').AsString := labSN.Caption;
    Params.ParamByName('PARTSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
    Execute;
    close;
  end;

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'OldKPSN', ptInput);
    CommandText := 'Update SAJET.G_PART_MAP '
      + 'Set Used_Flag = ''0'' '
      + 'Where PART_SN = :OldKPSN ';
    Params.ParamByName('OldKPSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
    Execute;
    Close;
  end;

  //ADD BY KEY 2007/09/18  NO KP DEFECT
  if sFlag = 'N' then
   //填入 G_SN_REPAIR_REPLACE_KP
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'SN', ptInput);
      Params.CreateParam(ftString, 'EMP', ptInput);
      Params.CreateParam(ftString, 'PartID', ptInput);
      Params.CreateParam(ftString, 'OldKPSN', ptInput);
              //Params.CreateParam(ftString	,'NewKPSN', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'Flag', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR_REPLACE_KP '
        + '(recid, serial_number, replace_emp_id, replace_time,item_part_id,old_part_sn,remark,Flag) '
        + 'Values(:RECID,:SN,:EMP,Sysdate,:PartID,:OldKPSN,:Remark,:FLAG) ';
      Params.ParamByName('RECID').AsString := RecID;
      Params.ParamByName('SN').AsString := labSN.Caption;
      Params.ParamByName('EMP').AsString := fRepair.UpdateUserID;
      Params.ParamByName('PartID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('OldKPSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
              {if (sNewKPNO <> -1) and (sNewKPNO <> 0) then
                Params.ParamByName('NewPartID').AsInteger := sNewKPNO
              else
                Params.ParamByName('NewPartID').AsInteger := fRepair.QryData.FieldByName('ID').AsInteger;
              if sOldKPSN = 'N/A' then
                Params.ParamByName('NewKPSN').AsString := 'N/A'
              else
                Params.ParamByName('NewKPSN').AsString := sNewKPSN;}
      Params.ParamByName('REMARK').AsString := 'Remove ONE KPSN';
      Params.ParamByName('Flag').AsString := sFlag;
      Execute;
      Close;
    end;


   // 填入KP Defect
  if sFlag = 'Y' then
  begin
    //填入 G_SN_REPAIR_REPLACE_KP
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'SN', ptInput);
      Params.CreateParam(ftString, 'EMP', ptInput);
      Params.CreateParam(ftString, 'PartID', ptInput);
      Params.CreateParam(ftString, 'OldKPSN', ptInput);
              //Params.CreateParam(ftString	,'NewKPSN', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'Flag', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR_REPLACE_KP '
        + '(recid, serial_number, replace_emp_id, replace_time,item_part_id,old_part_sn,remark,Flag) '
        + 'Values(:RECID,:SN,:EMP,Sysdate,:PartID,:OldKPSN,:Remark,:Flag) ';
      Params.ParamByName('RECID').AsString := RecID;
      Params.ParamByName('SN').AsString := labSN.Caption;
      Params.ParamByName('EMP').AsString := fRepair.UpdateUserID;
      Params.ParamByName('PartID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('OldKPSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
              {if (sNewKPNO <> -1) and (sNewKPNO <> 0) then
                Params.ParamByName('NewPartID').AsInteger := sNewKPNO
              else
                Params.ParamByName('NewPartID').AsInteger := fRepair.QryData.FieldByName('ID').AsInteger;
              if sOldKPSN = 'N/A' then
                Params.ParamByName('NewKPSN').AsString := 'N/A'
              else
                Params.ParamByName('NewKPSN').AsString := sNewKPSN;}
      Params.ParamByName('REMARK').AsString := 'Remove Fail KPSN';
      Params.ParamByName('Flag').AsString := sFlag;
      Execute;
      Close;
    end;
    with fRepair.QryTemp do
    begin
      sNewRecID := GetKPRECID;
      sOldKPSNID := GET_PARTID(fRepair.QryData.FieldByName('KPSN').AsString);
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'PART_SN', ptInput);
      Params.CreateParam(ftString, 'PART_ID', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
      Params.CreateParam(ftString, 'STAGE_ID', ptInput);
      Params.CreateParam(ftString, 'PDLINE_ID', ptInput);
      Params.CreateParam(ftString, 'TEST_EMP_ID', ptInput);
      CommandText := 'INSERT INTO SAJET.G_KP_DEFECT_H '
        + '(RECID,PART_SN,PART_ID,TERMINAL_ID,PROCESS_ID,STAGE_ID,PDLINE_ID ,TEST_EMP_ID) '
        + 'VALUES '
        + '(:RECID,:PART_SN,:PART_ID,:TERMINAL_ID,:PROCESS_ID,:STAGE_ID,:PDLINE_ID ,:TEST_EMP_ID) ';
      Params.ParamByName('RECID').AsString := sNewRecID;
      Params.ParamByName('PART_SN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
      Params.ParamByName('PART_ID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('TERMINAL_ID').AsString := fRepair.TerminalID;
      Params.ParamByName('PROCESS_ID').AsString := fRepair.ProcessId;
      Params.ParamByName('STAGE_ID').AsString := fRepair.StageID;
      Params.ParamByName('PDLINE_ID').AsString := fRepair.PDLineId;
      Params.ParamByName('TEST_EMP_ID').AsString := fRepair.UpdateUserID;
      Execute;
      Close;
      for iTemp := 0 to cmbEC.Items.Count - 1 do
      begin
                 // Defect
        sSUBRecID := GetKPDEFECTRECID;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'PARENT_ID', ptInput);
        Params.CreateParam(ftString, 'RECID', ptInput);
        Params.CreateParam(ftString, 'DEFECT_ID', ptInput);
        Params.CreateParam(ftString, 'PROCESS_ID', ptInput);
        Params.CreateParam(ftString, 'TEST_EMP_ID', ptInput);
        CommandText := 'INSERT INTO SAJET.G_KP_DEFECT_D '
          + '(PARENT_ID,RECID,DEFECT_ID,PROCESS_ID,TEST_EMP_ID ) '
          + 'VALUES '
          + '(:PARENT_ID,:RECID,:DEFECT_ID,:PROCESS_ID,:TEST_EMP_ID ) ';
        Params.ParamByName('PARENT_ID').AsString := sNewRecID;
        Params.ParamByName('RECID').AsString := sSUBRecID;
        Params.ParamByName('DEFECT_ID').AsString := cmbECID.Items.Strings[iTemp];
        Params.ParamByName('PROCESS_ID').AsString := fRepair.ProcessId;
        Params.ParamByName('TEST_EMP_ID').AsString := fRepair.UpdateUserID;
        Execute;
        Close;
      end;
      Close;
    end;
  end; //IF sFlag = 'Y'
  cmbEC.Items.Clear;
  cmbECID.Items.Clear;
  for I := 1 to strEC.RowCount - 1 do
    strEC.Rows[I].Clear;
  strEC.RowCount := 2;
  lablMsg.Caption := 'Remove OK !!';
  fRepair.ShowKP;
end;

procedure TformKP.rbYesClick(Sender: TObject);
var I: Integer;
begin
  if (rbYes.Checked = True) then
  begin
    EditEC.Visible := True;
    labEC.Visible := EditEC.Visible;
    strEC.Visible := EditEC.Visible;
    EditEC.Text := '';
    EditEC.SetFocus;
    for I := 1 to strEC.RowCount - 1 do
      strEC.Rows[I].Clear;
    strEC.RowCount := 2;
    cmbEC.Clear;
    cmbECID.Clear;
  end;
end;

procedure TformKP.rbNoClick(Sender: TObject);
var I: integer;
begin
  if (rbNo.Checked = True) then
  begin
    EditEC.Visible := False;
    labEC.Visible := EditEC.Visible;
    strEC.Visible := EditEC.Visible;
    cmbEC.Clear;
    cmbECID.Clear;
    for I := 1 to strEC.RowCount - 1 do
      strEC.Rows[I].Clear;
    strEC.RowCount := 2;
  end;
end;

procedure TformKP.editEcKeyPress(Sender: TObject; var Key: Char);
var S: string;
begin
  if Ord(Key) = VK_Return then
  begin
    editEc.Text := Trim(editEc.Text);
    with fRepair.QryTemp do
    begin
      try
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'DEFECT_CODE', ptInput);
        CommandText := 'SELECT DEFECT_ID,DEFECT_CODE, DEFECT_DESC, ENABLED '
          + '  FROM SAJET.SYS_DEFECT '
          + ' WHERE DEFECT_CODE =:DEFECT_CODE ';
        Params.ParamByName('DEFECT_CODE').AsString := editEc.Text;
        Open;
        if Eof then
        begin
          ShowMessage('Defect Code Error!!');
          editEc.SelectAll;
          Exit;
        end;
        if FieldByName('ENABLED').AsString <> 'Y' then
        begin
          ShowMessage('Defect Code Disable!!');
          editEc.SelectAll;
          Exit;
        end;
        if cmbEc.Items.IndexOf(editEc.Text) > -1 then
        begin
          ShowMessage('Defect Code Duplicate!!');
          editEc.SelectAll;
          Exit;
        end;
        cmbEc.Items.Add(FieldByName('DEFECT_Code').AsString);
        cmbECID.Items.Add(FieldByName('DEFECT_ID').AsString);
        strEC.RowCount := cmbEc.Items.Count + 1;
        strEC.Cells[0, strEC.RowCount - 1] := FieldByName('DEFECT_Code').AsString;
        editEc.Text := '';
        S := '';
              //For I:=0 To cmbEc.Items.Count-1 do
              //    S:= S + cmbEc.Items.Strings[I]+#10#13;
        ShowMessage('Defect Code Append!!' + #10#13);
      finally
        Close;
      end;
    end;
  end;
end;

function TformKP.CheckNewKP_Replace: Boolean;
begin
  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'KPSN1', ptInput);
    Params.CreateParam(ftString, 'KPSN2', ptInput);
    CommandText := 'Select Flag ' +
      'From SAJET.G_SN_REPAIR_REPLACE_KP ' +
      'Where OLD_PART_SN = :KPSN1 ' +
      'AND REPLACE_TIME = ( ' +
      '    SELECT MAX(Replace_Time) ' +
      '    FROM SAJET.G_SN_REPAIR_REPLACE_KP ' +
      '    WHERE OLD_PART_SN =:KPSN2 ) ';
    Params.ParamByName('KPSN1').AsString := editKP.Text;
    Params.ParamByName('KPSN2').AsString := editKP.Text;
    Open;
    if FieldByName('Flag').AsSTring = 'Y' then // 尚未維修
      Result := False
    else
      Result := True;
    Close;
  end;
end;

function TformKP.GetKPDefectRECID: string;
begin
  // 取新的 Rec ID
  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || TO_CHAR(SYSDATE,''YYMMDD'') || LPAD(SAJET.S_KP_DEFECT.NEXTVAL,5,''0'') SNID ' +
        'From SAJET.SYS_BASE ' +
        'Where PARAM_NAME = ''DBID'' ';
      Open;
      Result := Fieldbyname('SNID').AsString;
      Close;
    end;
  except
    MessageDlg('Database Error !!' + #13#10 +
      'Can not get new Defect Record ID !!', mtError, [mbCancel], 0);
    Result := '';
  end;
end;

function TformKP.GetKPRECID: string;
begin
  // 取新的 Rec ID
  try
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || TO_CHAR(SYSDATE,''YYMMDD'') || LPAD(SAJET.S_KP_REPAIR.NEXTVAL,5,''0'') SNID ' +
        'From SAJET.SYS_BASE ' +
        'Where PARAM_NAME = ''DBID'' ';
      Open;
      Result := Fieldbyname('SNID').AsString;
      Close;
    end;
  except
    MessageDlg('Database Error !!' + #13#10 +
      'Can not get new KP Record ID !!', mtError, [mbCancel], 0);
    Result := '';
  end;
end;

procedure TformKP.FormShow(Sender: TObject);
begin
  strEC.Cells[0, 0] := 'Input Code';
  rbYes.Checked := True;
  lablMsg.Caption := '';
  if EditKp.Visible = True then
    EditKp.SetFocus;
  if fRepair.QryData.RecordCount <> 0 then
    if fRepair.QryData.FieldByName('KPSN').AsString = 'N/A' then
    begin
      rbYes.Enabled := False;
      EditEC.Enabled := False;
      rbno.Checked := tRUE;
    end;

end;

procedure TformKP.sbtnRemoveAllKPClick(Sender: TObject);
begin
    // remove all 則不紀錄defect
     // remove 單筆也記錄  是否不良 與 Defect Code 等
  lablMsg.Caption := '';
  if fRepair.QryData.RecordCount = 0 then
    Exit;

  if MessageDlg('Remove All KPSN ?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    exit;

     // 先迴圈update SAJET.G_PART_MAP
  fRepair.QryData.First;
  while not fRepair.QryData.Eof do
  begin
    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'OldKPSN', ptInput);
      CommandText := 'Update SAJET.G_PART_MAP '
        + 'Set Used_Flag = ''0'' '
        + 'Where PART_SN = :OldKPSN ';
      Params.ParamByName('OldKPSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
      Execute;
      Close;
    end;

  // add by key 2007/09/18
   //填入 G_SN_REPAIR_REPLACE_KP

    with fRepair.QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RECID', ptInput);
      Params.CreateParam(ftString, 'SN', ptInput);
      Params.CreateParam(ftString, 'EMP', ptInput);
      Params.CreateParam(ftString, 'PartID', ptInput);
      Params.CreateParam(ftString, 'OldKPSN', ptInput);
              //Params.CreateParam(ftString	,'NewKPSN', ptInput);
      Params.CreateParam(ftString, 'REMARK', ptInput);
      Params.CreateParam(ftString, 'Flag', ptInput);
      CommandText := 'Insert Into SAJET.G_SN_REPAIR_REPLACE_KP '
        + '(recid, serial_number, replace_emp_id, replace_time,item_part_id,old_part_sn,remark,Flag) '
        + 'Values(:RECID,:SN,:EMP,Sysdate,:PartID,:OldKPSN,:Remark,:FLAG) ';
      Params.ParamByName('RECID').AsString := RecID;
      Params.ParamByName('SN').AsString := labSN.Caption;
      Params.ParamByName('EMP').AsString := fRepair.UpdateUserID;
      Params.ParamByName('PartID').AsString := fRepair.QryData.FieldByName('ID').AsString;
      Params.ParamByName('OldKPSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
              {if (sNewKPNO <> -1) and (sNewKPNO <> 0) then
                Params.ParamByName('NewPartID').AsInteger := sNewKPNO
              else
                Params.ParamByName('NewPartID').AsInteger := fRepair.QryData.FieldByName('ID').AsInteger;
              if sOldKPSN = 'N/A' then
                Params.ParamByName('NewKPSN').AsString := 'N/A'
              else
                Params.ParamByName('NewKPSN').AsString := sNewKPSN;}
      Params.ParamByName('REMARK').AsString := 'Remove ALL KPSN';
      //Params.ParamByName('Flag').AsString := sFlag;
      Params.ParamByName('Flag').AsString :='N';
      Execute;
      Close;
    end;



    fRepair.QryData.Next;
  end;

  with fRepair.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
          //Params.CreateParam(ftString	,'PARTSN', ptInput);
    CommandText := 'Delete SAJET.G_SN_KEYPARTS ' +
      'Where SERIAL_NUMBER = :SN ';
                        // 'And ITEM_PART_SN = :PARTSN'
    Params.ParamByName('SN').AsString := labSN.Caption;
          //Params.ParamByName('PARTSN').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
    Execute;
    close;
  end;

  cmbEC.Items.Clear;
  cmbECID.Items.Clear;
  lablMsg.Caption := 'Remove All OK !!';
  fRepair.ShowKP;
end;

procedure TformKP.dbgridKPCellClick(Column: TColumn);
var
  sPARTSN, sREs: string;
begin
  if fRepair.QryData.RecordCount = 0 then
    Exit;
     // Part no 不可以輸入Defct
  with fRepair.SProc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_ASSY_CHK_PART');
      FetchParams;
      Params.ParamByName('TTERMINALID').AsString := fRepair.TerminalID;
      Params.ParamByName('TREV').AsString := fRepair.QryData.FieldByName('KPSN').AsString;
      Execute;
      sRes := Params.ParamByName('TRES').AsString;
      sPARTSN := Params.ParamByName('U_PARTSN').AsString;
    except
      on E: Exception do
        sRes := 'SJ_ASSY_CHK_PART Exception:' + E.Message;
    end;
    Close;
  end;
  if (sRes = 'NO KPSN') then
    if (sPARTSN = 'N/A') then
    begin
      rbYes.Enabled := False;
      EditEC.Enabled := False;
      rbno.Checked := tRUE;
    end
    else
    begin
      rbYes.Enabled := True;
      EditEC.Enabled := True;
    end;
end;

end.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
