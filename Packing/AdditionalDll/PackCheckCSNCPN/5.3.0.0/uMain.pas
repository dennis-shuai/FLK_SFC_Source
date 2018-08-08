unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Db, DBClient, MConnect, SConnect,BmpRgn,
  ObjBrkr, Variants, Grids, DBGrids;

type
  TfMain = class(TForm)
    SProc1: TClientDataSet;
    QryTemp1: TClientDataSet;
    QryData1: TClientDataSet;
    Imagemain: TImage;
    Label5: TLabel;
    LabSN: TLabel;
    LabPart: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    editCSN: TEdit;
    editCustPart: TEdit;
    Label3: TLabel;
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    Label7: TLabel;
    EditSN: TEdit;
    Label8: TLabel;
    lstcheckcsnField: TListBox;
    lstcheckcsnValue: TListBox;
    Labcustpart: TLabel;
    Label10: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
   // procedure editVersionKeyPress(Sender: TObject; var Key: Char);
   // procedure editUPCKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure editCustPartKeyPress(Sender: TObject; var Key: Char);
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
   // procedure editCSNKeyPress(Sender: TObject; var Key: Char);
  private
    function CheckRule(NoType, sInputNo: string): Boolean;
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    G_tsParam,G_tsData:TStrings;
    gSN,gPartID,gUPC,gVer,gCustPart:string;
    gbchkcsn,gbChkCustPart,gbChkVer,gbChkUPC:Boolean;
    gwo:string;
    gkpcount:integer;
    procedure SetTheRegion;
    { Public declarations }
  end;

var
  fMain: TfMain;
  SNUdf: TStringList;
  G_sockConnection : TSocketConnection;
  function AdditionalData(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean; stdcall; export;
implementation

{$R *.DFM}

procedure TfMain.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfMain.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
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
procedure TfMain.WMNCHitTest( var msg: TWMNCHitTest );
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

function AdditionalData(tsInParam,tsInData:TStrings;parentSocketConnection : TSocketConnection): Boolean;
var i:integer;
begin
  Result := False;
  fMain := TfMain.Create(Application);
  with fMain do
  begin
    G_tsParam:=TStringList.Create;
    G_tsData:=TStringList.Create;
    G_tsParam:=tsInParam;
    G_tsData:=tsInData;

    G_sockConnection := parentSocketConnection;
    QryData1.RemoteServer := G_sockConnection;
    QryData1.ProviderName := 'DspQryData';
    QryTemp1.RemoteServer := G_sockConnection;
    QryTemp1.ProviderName := 'DspQryTemp1';
    SProc1.RemoteServer := G_sockConnection;
    SProc1.ProviderName := 'DspStoreproc';

    if ShowModal = mrOK then
    begin
      Result := True;
    end;
    Free;
  end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
var sKey:char;
begin
  sKey:=#13;
 { if not gbChkCustPart then
  begin
    editCustPartKeyPress(self,sKey);
    if not gbChkCustPart then exit;
  end;

  if not gbChkVer then
  begin
    editVersionKeyPress(self,sKey);
    if not gbChkVer then exit;
  end;

  if not gbChkUPC then
  begin
    editUPCKeyPress(self,sKey);
    if not gbChkUPC then exit;
  end;
 }
  ModalResult:= mrOK;
end;

procedure TfMain.FormShow(Sender: TObject);
var i:integer;
begin
  gSN:= G_tsData.Strings[G_tsParam.IndexOf('SERIAL_NUMBER')];
  LabSN.Caption:= gSN;
  
  with QryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'SN', ptInput);
    CommandText := 'SELECT * from sajet.G_SN_STATUS '
                 + 'where Serial_Number = :SN ' ;
    Params.ParamByName('SN').AsString := gSN;
    Open;
    gPartID:=FieldByName('MODEL_ID').asstring;
    gwo:=fieldbyname('work_order').AsString ;
    editcsn.Text :=fieldbyname('customer_sn').AsString;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'SELECT * from sajet.SYS_PART '
                 + 'where PART_ID = :PART_ID ' ;
    Params.ParamByName('PART_ID').AsString := gPartID;
    Open;
    LabPart.Caption:=FieldByName('PART_NO').asstring;
   //gUPC:= FieldByName('UPC').asstring;
   // gVer:= FieldByName('VERSION').asstring;
    gCustPart:= FieldByName('CUST_PART_NO').asstring;
    labcustpart.Caption :=gCustPart;
    Close;
  end;
     {
        with QryTemp1 do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
            CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
                  'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
                  'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
                  'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';
             Params.ParamByName('WO_NUMBER').AsString := gWO;
             Open;
             lstcheckcsnField.Items.Clear;
             lstcheckcsnValue.Items.Clear;
             if not IsEmpty then
             begin
                for i := 0 to FieldCount - 1 do
                begin
                    lstcheckcsnField.Items.Add(QryTemp1.Fields.Fields[i].FieldName);
                    lstcheckcsnValue.Items.Add(QryTemp1.Fields.Fields[i].AsString);
                 end;
            end;
         end;
      }
  SNUdf := TStringList.Create;
  editsn.SelectAll ;
  editsn.SetFocus ;
end;
{
procedure TfMain.editCustPartKeyPress(Sender: TObject; var Key: Char);
begin
  gbChkCustPart:=False;
  if Key<>#13 then
    exit;

  if editCustPart.Text <> gCustPart then
  begin
    MessageDlg('Customer Part No Error',mtError,[mbCancel],0);
    editCustPart.SetFocus;
    editCustPart.SelectAll;
    Exit;
  end;

  gbChkCustPart:=True;
  editVersion.SetFocus;
  editVersion.SelectAll;

end;

procedure TfMain.editVersionKeyPress(Sender: TObject; var Key: Char);
begin
  gbChkVer:=False;
  if Key<>#13 then
    exit;

  if editVersion.Text <> gVer then
  begin
    MessageDlg('Version Error',mtError,[mbCancel],0);
    editVersion.SetFocus;
    editVersion.SelectAll;
    Exit;
  end;
  gbChkVer:=True;
  editUPC.SetFocus;
  editUPC.SelectAll;
end;

procedure TfMain.editUPCKeyPress(Sender: TObject; var Key: Char);
begin
  gbChkUPC:=False;
  if Key<>#13 then
    exit;

  if editUPC.Text <> gUPC then
  begin
    MessageDlg('UPC Code Error',mtError,[mbCancel],0);
    editUPC.SetFocus;
    editUPC.SelectAll;
    Exit;
  end;
  gbChkUPC:=True;
  sbtnOK.OnClick(self);
end;
}
procedure TfMain.FormCreate(Sender: TObject);
begin
   if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
   begin
     Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
     SetTheRegion;
   end;
end;
{
procedure TfMain.editCSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key<>#13 then
    exit;

  editCustPart.SetFocus;
  editCustPart.SelectAll;
end;
}
procedure TfMain.sbtnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfMain.EditSNKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if ORD(Key)=VK_RETURN then
     begin
       if editsn.Text <> gsn then
         begin
             with qrytemp1 do
               begin
                  Close;
                  Params.Clear;
                  Params.CreateParam(ftString, 'CSN', ptInput);
                  commandtext:='select SERIAL_NUMBER,CUSTOMER_SN from SAJET.G_SN_STATUS WHERE CUSTOMER_SN=:CSN and rownum=1' ;
                  Params.ParamByName('CSN').AsString := EDITSN.Text;
                  open;
                if isempty then
                  begin
                       MessageDlg('CSN '+editsn.Text+ ' NOT FIND!',mtError,[mbCancel],0);
                       exit;
                  end
                else
                  begin
                      editsn.Text:=fieldbyname('serial_number').AsString ;
                      editcsn.Text :=fieldbyname('customer_sn').AsString ;
                      editsn.SelectAll ;
                      editsn.SetFocus ;
                      if editsn.Text <>gsn then
                        begin
                          MessageDlg('SN '+editsn.Text+ '<>'+ gsn,mtError,[mbCancel],0);
                          exit;
                        end;
                  end;
             end;
         end;

        {
        with QryTemp1 do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
            CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
                  'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
                  'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
                  'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';
             Params.ParamByName('WO_NUMBER').AsString := gWO;
             Open;
             lstcheckcsnField.Items.Clear;
             lstcheckcsnValue.Items.Clear;
             if not IsEmpty then
             begin
                for i := 0 to FieldCount - 1 do
                begin
                    lstcheckcsnField.Items.Add(QryTemp1.Fields.Fields[i].FieldName);
                    lstcheckcsnValue.Items.Add(QryTemp1.Fields.Fields[i].AsString);
                 end;
            end;
         end;
         }

         if not CheckRule('SSN', editCSN.Text) then
         begin
             editsn.SelectAll ;
             editsn.SetFocus ;
             exit;
          end;

        //  ModalResult:= mrOK;
     end;
end;

function TfMain.CheckRule(NoType, sInputNo: string): Boolean;
var sCode, sDefault, sM, sD, sW, uM, uD, uK, uW, sP, sQ, sR, sF, sSeqType, S: string;
  i, iR, j: integer; slValue: TStringList;
  sField1, sType1, sField2, sType2, sField3, sType3, sValue: string;
begin
  SNUdf.Clear;
  Result := True;
    with qryTemp1 do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
      CommandText := 'SELECT * FROM SAJET.G_WO_PARAM '
        + 'WHERE WORK_ORDER = :WORK_ORDER '
        + 'AND MODULE_NAME = :MODULE_NAME ';
      Params.ParamByName('WORK_ORDER').AsString := gWO;
      if NoType = 'Carton' then
        Params.ParamByName('MODULE_NAME').AsString := 'CARTON NO RULE'
      else if NoType = 'Box' then
        Params.ParamByName('MODULE_NAME').AsString := 'BOX NO RULE'
      else if NoType = 'Pallet' then
        Params.ParamByName('MODULE_NAME').AsString := 'PALLET NO RULE'
      else
        Params.ParamByName('MODULE_NAME').AsString := 'CUSTOMER SN RULE';
      Open;

      if not IsEmpty then
      begin
        if Locate('PARAME_ITEM', 'Code', []) then
          sCode := FieldByName('parame_value').asstring
        else
          exit;
        if Locate('PARAME_ITEM', 'Default', []) then
          sDefault := FieldByName('parame_value').asstring
        else
          exit;
        if Locate('PARAME_ITEM', 'Code Type', []) then
          sSeqType := FieldByName('parame_value').asstring;
        if Locate('PARAME_NAME', '1-Digit Type & Field', []) then
        begin
          sField1 := Fieldbyname('PARAME_VALUE').AsString;
          sType1 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        if Locate('PARAME_NAME', '2-Digit Type & Field', []) then
        begin
          sField2 := Fieldbyname('PARAME_VALUE').AsString;
          sType2 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        if Locate('PARAME_NAME', '3-Digit Type & Field', []) then
        begin
          sField3 := Fieldbyname('PARAME_VALUE').AsString;
          sType3 := Fieldbyname('PARAME_ITEM').AsString;
        end;
        First;
        while not Eof do begin
          if (Fieldbyname('PARAME_NAME').AsString = 'Carton No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Pallet No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Box No User Define') or
            (Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define') then
            SNUdf.Add(Fieldbyname('PARAME_ITEM').AsString + ' : ' +
              Fieldbyname('PARAME_VALUE').AsString);
          Next;
        end;
        //檢查長度
        if Length(sCode) <> Length(sInputNo) then
        begin
          Result := False;
          MessageDlg('Rule not match (Length)',mtError,[mbCancel],0);
          exit;
        end;
        //檢查固定碼
        sM := ''; sD := ''; sW := ''; uM := ''; uK := ''; uD := ''; uW := ''; sR := ''; sF := ''; sP := ''; sQ := '';
        for i := 1 to length(sCode) do
        begin
          if sCode[i] in ['A', 'C', 'L', '9'] then
          begin
            if (sDefault[i] <> ' ') and (sDefault[i] <> sInputNo[i]) then
            begin
              Result := False;
              MessageDlg('Rule not match (Fix Character)',mtError,[mbCancel],0);
              exit;
            end;
          end
          else if sCode[i] = 'Y' then
          begin
            if StrToIntDef(sInputNo[i], -1) = -1 then
            begin
              Result := False;
              MessageDlg('Rule not match (Year)',mtError,[mbCancel],0);
              exit;
            end;
          end
          else if sCode[i] = 'K' then
          begin
            if sInputNo[i] in ['1'..'7'] then
            else
            begin
              Result := False;
              MessageDlg('Rule not match (Day of Week)',mtError,[mbCancel],0);
              exit;
            end;
          end
          else if sCode[i] = 'S' then
          begin
            if sSeqType = '10' then
            begin
              if StrToIntDef(sInputNo[i], -1) = -1 then
              begin
                Result := False;
                MessageDlg('Rule not match (Sequence)',mtError,[mbCancel],0);
                exit;
              end;
            end
            else
            begin
              if sInputNo[i] in ['0'..'F'] then
              else
              begin
                Result := False;
                MessageDlg('Rule not match (Sequence)',mtError,[mbCancel],0);
                exit;
              end;
            end;
          end
          else if sCode[i] = 'P' then
            sP := sP + sInputNo[i]
          else if sCode[i] = 'Q' then
            sQ := sQ + sInputNo[i]
          else if sCode[i] = 'R' then
            sR := sR + sInputNo[i]
          else if sCode[i] = 'M' then
            sM := sM + sInputNo[i]
          else if sCode[i] = 'D' then
            sD := sD + sInputNo[i]
          else if sCode[i] = 'W' then
            sW := sW + sInputNo[i]
          else if sCode[i] = 'm' then
            uM := uM + sInputNo[i]
          else if sCode[i] = 'k' then
            uK := uK + sInputNo[i]
          else if sCode[i] = 'd' then
            uD := uD + sInputNo[i]
          else if sCode[i] = 'w' then
            uW := uW + sInputNo[i]
          else begin
            for j := 0 to SNUdf.Count - 1 do begin
              if Copy(SNUdf.Strings[j], 1, 1) = sCode[i] then
              begin
                S := Trim(Copy(SNUdf.Strings[j], POS(':', SNUdf.Strings[j]) + 1, Length(SNUdf.Strings[j]) - POS(':', SNUdf.Strings[j])));
                if Pos(sInputNo[i], S) = 0 then begin
                  Result := False;
                  MessageDlg('Rule not match (User Define Sequence)',mtError,[mbCancel],0);
                  exit;
                end;
                break;
              end;
            end;
          end; // if
        end; // for
      end; // if
      slValue := TStringList.Create;
      if uM <> '' then
      begin
        Locate('PARAME_NAME', 'Month User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uM) = -1 then
        begin
          slValue.Free;
          Result := False;
          MessageDlg('Rule not match (Month User Define)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if uD <> '' then
      begin
        Locate('PARAME_NAME', 'Day User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uD) = -1 then
        begin
          slValue.Free;
          Result := False;
          MessageDlg('Rule not match (Day User Define)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if uW <> '' then
      begin
        Locate('PARAME_NAME', 'Week User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uW) = -1 then
        begin
          slValue.Free;
          Result := False;
          MessageDlg('Rule not match (Week User Define)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if uK <> '' then
      begin
        Locate('PARAME_NAME', 'Day of Week User Define', []);
        slValue.CommaText := Fieldbyname('PARAME_VALUE').AsString;
        if slValue.IndexOf(uK) = -1 then
        begin
          slValue.Free;
          Result := False;
          MessageDlg('Rule not match (Day of Week User Define)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      slValue.Free;
      if sField1 <> '' then
      begin
        sValue := lstcheckcsnValue.Items[lstcheckcsnField.Items.IndexOf(sField1)];
        with QryTemp1 do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType1 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sP <> sValue then
        begin
          Result := False;
          MessageDlg('Rule not match (1-Option)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sField2 <> '' then
      begin
        sValue := lstcheckcsnValue.Items[lstcheckcsnField.Items.IndexOf(sField2)];
        with QryTemp1 do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType2 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sQ <> sValue then
        begin
          Result := False;
          MessageDlg('Rule not match (2-Option)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sField3 <> '' then
      begin
        sValue := lstcheckcsnValue.Items[lstcheckcsnField.Items.IndexOf(sField3)];
        with QryTemp1 do
        begin
          Close;
          Params.Clear;
          CommandText := 'select ' + sType3 + '(''' + sValue + ''') snid from dual ';
          Open;
          sValue := FieldByName('snid').AsString;
        end;
        if sR <> sValue then
        begin
          Result := False;
          MessageDlg('Rule not match (3-Option)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sM <> '' then
      begin
        iR := StrToIntDef(sM, -1);
        if (iR < 1) or (iR > 12) then
        begin
          Result := False;
          MessageDlg('Rule not match (Month)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sD <> '' then
      begin
        iR := StrToIntDef(sD, -1);
        if (iR < 1) or (iR > 31) then
        begin
          Result := False;
          MessageDlg('Rule not match (Day)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sW <> '' then
      begin
        iR := StrToIntDef(sW, -1);
        if (iR < 1) or (iR > 53) then
        begin
          Result := False;
          MessageDlg('Rule not match (Week)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      if sF <> '' then
      begin
        iR := StrToIntDef(sF, -1);
        if (iR < 1) or (iR > 366) then
        begin
          Result := False;
          MessageDlg('Rule not match (Day of Year)',mtError,[mbCancel],0);
          exit;
        end;
      end;
      Close;
    end;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
   SNUdf.Free ;
end;

procedure TfMain.editCustPartKeyPress(Sender: TObject; var Key: Char);
begin
  gbChkCustPart:=False;
  if Key<>#13 then
    exit;

  if editCustPart.Text <> gCustPart then
  begin
    MessageDlg('Customer Part No Error',mtError,[mbCancel],0);
    editCustPart.SetFocus;
    editCustPart.SelectAll;
    Exit;
  end;

  gbChkCustPart:=True;

  if not gbchkcsn then
  begin
     EditSNKeyPress(self,Key);
     if not gbchkcsn then
     begin
         editsn.SelectAll ;
         editsn.SetFocus ;
         exit;
      end;
  end;

  ModalResult:= mrOK;
  
end;

procedure TfMain.EditSNKeyPress(Sender: TObject; var Key: Char);
begin
    gbchkcsn:=false;
    if ORD(Key)=VK_RETURN then
     begin
       if editsn.Text <> gsn then
         begin
             with qrytemp1 do
               begin
                  Close;
                  Params.Clear;
                  Params.CreateParam(ftString, 'CSN', ptInput);
                  commandtext:='select SERIAL_NUMBER,CUSTOMER_SN from SAJET.G_SN_STATUS WHERE CUSTOMER_SN=:CSN and rownum=1' ;
                  Params.ParamByName('CSN').AsString := EDITSN.Text;
                  open;
                if isempty then
                  begin
                       MessageDlg('CSN '+editsn.Text+ ' NOT FIND!',mtError,[mbCancel],0);
                       editsn.SelectAll ;
                       editsn.SetFocus ;
                       exit;
                  end
                else
                  begin
                      editsn.Text:=fieldbyname('serial_number').AsString ;
                      editcsn.Text :=fieldbyname('customer_sn').AsString ;
                      if editsn.Text <>gsn then
                        begin
                          MessageDlg('SN '+editsn.Text+ '<>'+ gsn,mtError,[mbCancel],0);
                          editsn.SelectAll ;
                          editsn.SetFocus ;
                          exit;
                        end;
                  end;
             end;
         end;

        {
        with QryTemp1 do
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'WO_NUMBER', ptInput);
            CommandText := 'SELECT A.*, B.PART_NO, Label_File, CUST_PART_NO ' +
                  'FROM   SAJET.G_WO_BASE A, SAJET.SYS_PART B ' +
                  'WHERE  A.WORK_ORDER = :WO_NUMBER ' +
                  'AND    A.MODEL_ID = B.PART_ID(+) and rownum = 1';
             Params.ParamByName('WO_NUMBER').AsString := gWO;
             Open;
             lstcheckcsnField.Items.Clear;
             lstcheckcsnValue.Items.Clear;
             if not IsEmpty then
             begin
                for i := 0 to FieldCount - 1 do
                begin
                    lstcheckcsnField.Items.Add(QryTemp1.Fields.Fields[i].FieldName);
                    lstcheckcsnValue.Items.Add(QryTemp1.Fields.Fields[i].AsString);
                 end;
            end;
         end;
         }

         if not CheckRule('SSN', editCSN.Text) then
         begin
             editsn.SelectAll ;
             editsn.SetFocus ;
             exit;
          end
          else
          begin
             gbchkcsn:=true;
             editcustpart.SelectAll ;
             editcustpart.SetFocus ;
          end;

        //  ModalResult:= mrOK;
     end;
end;

end.
