unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DBCtrls, Db, DBClient,
  MConnect, SConnect, ObjBrkr;

type
  TfData = class(TForm)
    sbtnExit: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    Label11: TLabel;
    DataSource1: TDataSource;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label8: TLabel;
    dbtxtType: TDBText;
    Label1: TLabel;
    dbtxtPart: TDBText;
    Label2: TLabel;
    dbtxtVersion: TDBText;
    Label6: TLabel;
    dbtxtTarget: TDBText;
    Label10: TLabel;
    dbtxtScheduledata: TDBText;
    Label12: TLabel;
    dbtxtRoute: TDBText;
    dbtxtPDLine: TDBText;
    dbtxtSProcess: TDBText;
    dbtxtEProcess: TDBText;
    dbtxtCust: TDBText;
    dbtxtPO: TDBText;
    dbtxtMastWO: TDBText;
    dbtxtInQty: TDBText;
    dbtxtOutQty: TDBText;
    dbtxtRemark: TDBText;
    Label21: TLabel;
    Label20: TLabel;
    Label19: TLabel;
    Label18: TLabel;
    Label17: TLabel;
    Label16: TLabel;
    Label15: TLabel;
    Label14: TLabel;
    Label13: TLabel;
    cmbWO: TComboBox;
    Label3: TLabel;
    LabStatus: TLabel;
    SProc: TClientDataSet;
    Image4: TImage;
    cmbFactory: TComboBox;
    Label5: TLabel;
    dbtxtDuedata: TDBText;
    Label7: TLabel;
    dbtxtSO: TDBText;
    Memo1: TMemo;
    procedure sbtnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbWOChange(Sender: TObject);
    procedure cmbFactoryChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    ChangeWOType : String;
    UpdateUserID : String;
    Authoritys : String;
    FcID : String;
    UserFcID : String; // User 本身的廠別，若為 0 可選所有廠別
    procedure SetTheRegion;
    Procedure CopyToHistory(RecordID : String);
    Procedure SetStatusbyAuthority;
  end;

var
  fData: TfData;
  AryStatus : Array[0..9] of String;
  G_sockConnection : TSocketConnection;

implementation

{$R *.DFM}

Procedure TfData.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
{  Authoritys := '';
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    Params.CreateParam(ftString	,'PRG', ptInput);
    Params.CreateParam(ftString	,'FUN', ptInput);
    CommandText := 'Select AUTHORITYS '+
                   'From SAJET.SYS_EMP_PRIVILEGE '+
                   'Where EMP_ID = :EMP_ID and '+
                         'PROGRAM = :PRG and '+
                         'FUNCTION = :FUN ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Params.ParamByName('PRG').AsString := 'Packing';
    Params.ParamByName('FUN').AsString := 'Configuration';
    Open;
    If RecordCount > 0 Then
      Authoritys := Fieldbyname('AUTHORITYS').AsString;
    Close;
  end;}
end;

Procedure TfData.CopyToHistory(RecordID : String);
begin
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'WO', ptInput);
     CommandText := 'Insert Into SAJET.G_HT_WO_BASE '+
                      'Select * from SAJET.G_WO_BASE '+
                      'Where WORK_ORDER = :WO ';
     Params.ParamByName('WO').AsString := RecordID;
     Execute;
  end;
end;

procedure TfData.sbtnExitClick(Sender: TObject);
begin
   Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  ImageMain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
  SetTheRegion;
  AryStatus[0] := 'Initial';
  AryStatus[1] := 'Prepare';
  AryStatus[2] := 'Release';
  AryStatus[3] := 'Work In Process';
  AryStatus[4] := 'Hold';
  AryStatus[5] := 'Cancel';
  AryStatus[6] := 'Complete';
  AryStatus[7] := 'Delete';
  AryStatus[8] := 'Resume';
  AryStatus[9] := 'Complete-No Charge';
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect( Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt( Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.
procedure TfData.WMNCHitTest( var msg: TWMNCHitTest );
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient( p);
    MouseOnControl := false;
    for i := 0 to ControlCount-1 do begin
      if not MouseOnControl
      then begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
        then MouseOnControl := PtInRect( AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

procedure TfData.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    CommandText := 'Select NVL(FACTORY_ID,0) FACTORY_ID '+
                   'From SAJET.SYS_EMP '+
                   'Where EMP_ID = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpdateUserID;
    Open;
    If RecordCount = 0 Then
    begin
      Close;
      MessageDlg('Account Error !!',mtError, [mbOK],0);
      Exit;
    end;
    UserFcID := Fieldbyname('FACTORY_ID').AsString;
    FcID     := UserFcID;
    Close;
  end;

  cmbFactory.Items.Clear;
  With QryTemp do
  begin
     Close;
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC '+
                    'From SAJET.SYS_FACTORY '+
                    'Where ENABLED = ''Y'' ';
     Open;
     While Not Eof do
     begin
       cmbFactory.Items.Add(Fieldbyname('FACTORY_CODE').AsString + ' ' + Fieldbyname('FACTORY_NAME').AsString);
       If Fieldbyname('FACTORY_ID').AsString = UserFcID Then
       begin
         cmbFactory.ItemIndex := cmbFactory.Items.Count - 1;
       end;
       Next;
     end;
     Close;
  end;
   {
   //change by key 20080505 for 同一個user 可以操作多個org 的工令。
   //禁用如下3個語句
  cmbFactory.Enabled := (UserFcID = '0');
  }
  If UserFcID = '0' Then
    cmbFactory.ItemIndex := 0;

  cmbFactoryChange(Self);

end;

procedure TfData.sbtnSaveClick(Sender: TObject);
Var sRes ,sQty: String;
    bWIP : Boolean;  
begin
  If Trim(cmbWO.Text) = '' Then begin
    MessageDlg('Please input Work Order', mtWarning, [mbOK], 0);
    Exit;
  end;

  If cmbWO.Items.IndexOf(cmbWO.Text) < 0 Then
  begin
    MessageDlg('W/O not found.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if Trim(Memo1.Lines.CommaText) = '' then begin
    MessageDlg('Please input Memo.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if Length(Memo1.Lines.CommaText) > 100 then
  begin
    ShowMessage('Memo length must less 100!!');
    Exit;
  end;      

  //W/O Complete前檢查該工單是否有WIP的產品, 若有需要提示訊息並要求確認
  bWIP:=False;
  if ChangeWOType='6' then
  begin
    With QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'WORK_ORDER', ptInput);
      CommandText := 'Select count(*) cnt from SAJET.G_SN_STATUS '
                   + 'Where WORK_ORDER = :WORK_ORDER '
                   + 'And OUT_PDLINE_TIME IS NULL '
                   + 'And WIP_PROCESS <> 0 ';
      Params.ParamByName('WORK_ORDER').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
      Open;
      if not IsEmpty then
      begin
        bWIP:=True;
        sQty:=FieldByName('cnt').asstring;
      end;
      Close;
    end;
  end;


  if bWIP then
  begin
    If MessageDlg('SN - Work In Process : '+ sQty +#13#10+ 'Change Work Order Status to Complete ?'
                 , mtConfirmation	, [mbNo,mbOK] ,0) <> mrOK Then
      Exit;
  end else
  begin
    If MessageDlg('Change Work Order Status to ' + AryStatus[StrTointDef(ChangeWOType,0)]+' ?' ,
                 mtConfirmation	, [mbOK, mbCancel],0) <> mrOK Then
      Exit;
  end;

  With QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO_STATUS', ptInput);
    Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
    Params.CreateParam(ftString	,'WORK_ORDER', ptInput);
    CommandText := 'Update SAJET.G_WO_BASE '
                 + 'Set WO_STATUS = :WO_STATUS ';
    if ChangeWOType='6' then //close
      CommandText := CommandText+',WO_CLOSE_DATE = SYSDATE ';
    CommandText := CommandText
                 + ',UPDATE_USERID = :UPDATE_USERID '
                 + ',UPDATE_TIME = SYSDATE '
                 + 'Where WORK_ORDER = :WORK_ORDER ';
    Params.ParamByName('WO_STATUS').AsString := ChangeWOType;
    If ChangeWOType = '2' Then
    begin
      If QryData.FieldByName('INPUT_QTY').AsInteger > 0 Then
         Params.ParamByName('WO_STATUS').AsString := '3';
    end else If ChangeWOType = '8' Then
    begin
      Params.ParamByName('WO_STATUS').AsString := '2';
      If QryData.FieldByName('INPUT_QTY').AsInteger > 0 Then
         Params.ParamByName('WO_STATUS').AsString := '3';
    end;
    Params.ParamByName('UPDATE_USERID').AsString := UpdateUserID;
    Params.ParamByName('WORK_ORDER').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    Execute;

    // 紀錄狀態變更
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'STA', ptInput);
    Params.CreateParam(ftString	,'EMP', ptInput);
    Params.CreateParam(ftString	,'WO', ptInput);
    Params.CreateParam(ftString	,'MEMO', ptInput);
    CommandText := 'Insert into SAJET.G_WO_STATUS (Work_Order,WO_Status,Memo,update_userid) '+
                   'values (:WO,:STA,:MEMO,:EMP)';
    Params.ParamByName('STA').AsString := ChangeWOType;
    If ChangeWOType = '2' Then
      If QryData.FieldByName('INPUT_QTY').AsInteger > 0 Then
         Params.ParamByName('STA').AsString := '3';

    Params.ParamByName('EMP').AsString := UpdateUserID;
    Params.ParamByName('WO').AsString := QryData.Fieldbyname('WORK_ORDER').AsString;
    Params.ParamByName('MEMO').AsString := Memo1.Lines.CommaText;
    Execute;
  end;
  CopyToHistory(QryData.Fieldbyname('WORK_ORDER').AsString);
  If ChangeWOType = '7' Then
  begin
    Try
      With SProc do
      begin
        Close;
        Params.Clear;
        DataRequest('SAJET.SJ_DELETE_WO');
        FetchParams;
        Params.ParamByName('WO').AsString := cmbWO.Text;
        Execute;
        sRes := Params.ParamByName('TRES').AsString;
        If sRes <> 'OK' Then
          MessageDlg(sRes, mtCustom, [mbOK],0)
        Else
          MessageDlg('Delete Work Order OK !!', mtCustom, [mbOK],0);
      end;
    Except
      MessageDlg('Delete Fail', mtCustom, [mbOK],0);
    End;
  end Else
    MessageDlg('Change Work Order Status OK !!', mtCustom, [mbOK],0);
  FormShow(Self);
end;

procedure TfData.cmbWOChange(Sender: TObject);
begin
  LabStatus.Caption := '';
  DataSource1.DataSet := nil;
  If QryData.Locate('WORK_ORDER',Trim(cmbWO.Text),[loCaseInsensitive]) Then
  begin
    LabStatus.Caption := AryStatus[QryData.Fieldbyname('WO_STATUS').AsInteger];
    DataSource1.DataSet := QryData;
  end;

end;

procedure TfData.cmbFactoryChange(Sender: TObject);
begin
  FcID := '';
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'FACTORYCODE', ptInput);
     CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC '+
                    'From SAJET.SYS_FACTORY '+
                    'Where FACTORY_CODE = :FACTORYCODE ';
     Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text,1,POS(' ',cmbFactory.Text)-1) ;
     Open;
     If RecordCount > 0 Then
        FcID := Fieldbyname('FACTORY_ID').AsString;
     Close;
  end;

  DataSource1.DataSet := nil;
  With QryData do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select A.WORK_ORDER,'+
                          'A.WO_TYPE,'+
                          'A.WO_RULE,'+
                          'A.VERSION,'+
                          'A.TARGET_QTY,'+
                          'A.WO_CREATE_DATE,'+
                          'A.WO_SCHEDULE_DATE,'+
                          'A.WO_DUE_DATE,'+
                          'A.WO_START_DATE,'+
                          'A.WO_CLOSE_DATE,'+
                          'A.INPUT_QTY,'+
                          'A.OUTPUT_QTY,'+
                          'A.WORK_FLAG,'+
                          'A.WO_STATUS,'+
                          'A.PO_NO,'+
                          'A.MASTER_WO,'+
                          'A.REMARK,'+
                          'A.MODEL_NAME, '+
                          'B.PART_NO,'+
                          'C.ROUTE_NAME,'+
                          'D.PDLINE_NAME,'+
                          'E.CUSTOMER_CODE,'+
                          'E.CUSTOMER_NAME,'+
                          'F.PROCESS_NAME START_PROCESS,'+
                          'G.PROCESS_NAME END_PROCESS, '+
                         // 'H.PKSPEC_NAME, '+
                          'A.SALES_ORDER '+
                    'From SAJET.G_WO_BASE A,'+
                         'SAJET.SYS_PART B,'+
                         'SAJET.SYS_ROUTE C,'+
                         'SAJET.SYS_PDLINE D,'+
                         'SAJET.SYS_CUSTOMER E,'+
                         'SAJET.SYS_PROCESS F,'+
                         'SAJET.SYS_PROCESS G '+
                         //'SAJET.G_PACK_SPEC H '+
                    'Where A.MODEL_ID=B.PART_ID(+) and '+
                          'A.ROUTE_ID=C.ROUTE_ID(+) and '+
                          'A.DEFAULT_PDLINE_ID=D.PDLINE_ID(+) and '+
                          'A.CUSTOMER_ID=E.CUSTOMER_ID(+) and '+
                          'A.START_PROCESS_ID=F.PROCESS_ID(+) and '+
                          'A.END_PROCESS_ID=G.PROCESS_ID(+) and '+
                         // 'A.WORK_ORDER = H.WORK_ORDER(+) and '+
                          'A.FACTORY_ID = :FCID ';
      Params.CreateParam(ftString	,'FCID', ptInput);
      If ChangeWOType = '2' Then CommandText := CommandText + ' and A.WO_STATUS = ''1'' ';
      If ChangeWOType = '3' Then CommandText := CommandText + ' and A.WO_STATUS = ''2'' ';
      If ChangeWOType = '4' Then CommandText := CommandText + ' and A.WO_STATUS IN (''1'',''2'',''3'') ';
      If ChangeWOType = '5' Then CommandText := CommandText + ' and A.WO_STATUS <= ''4'' ';
      If ChangeWOType = '6' Then CommandText := CommandText + ' and A.WO_STATUS IN (''3'',''4'') ';
      If ChangeWOType = '7' Then CommandText := CommandText + ' and A.WO_STATUS >= ''0'' ';
      If ChangeWOType = '8' Then CommandText := CommandText + ' and A.WO_STATUS = ''4'' ';
      if ChangeWOType = '9' Then CommandText := CommandText + ' and A.WO_STATUS = ''6'' ';
      CommandText := CommandText + ' Order by WORK_ORDER ';
      Params.ParamByName('FCID').AsString := FcID;
      Open;

      {
      AryStatus[0] := 'Initial';
      AryStatus[1] := 'Prepare';
      AryStatus[2] := 'Release';
      AryStatus[3] := 'Work In Process';
      AryStatus[4] := 'Hold';
      AryStatus[5] := 'Cancel';
      AryStatus[6] := 'Complete';
      }
      Open;
      cmbWO.Text := '';
      cmbWO.Items.Clear;
      While not Eof do
      begin
         cmbWO.Items.Add(Fieldbyname('WORK_ORDER').AsString);
         Next;
      end;
   end;
   LabType1.Caption := 'Change Work Order Status to ' + AryStatus[StrTointDef(ChangeWOType,0)];
   LabType2.Caption := 'Change Work Order Status to ' + AryStatus[StrTointDef(ChangeWOType,0)];
   If ChangeWOType = '7' Then
   begin
     LabType1.Caption := 'Delete Work Order';
     LabType2.Caption := 'Delete Work Order';
   end;
   if (ChangeWOType = '9') or (ChangeWOType = '3') then
      sbtnSave.Caption := 'Save'
   else
      sbtnSave.Caption := AryStatus[StrTointDef(ChangeWOType,0)];
end;

end.
