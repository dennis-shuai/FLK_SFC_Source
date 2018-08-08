unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Db, DBClient, MConnect, SConnect,BmpRgn,
  ObjBrkr, Variants, Mask,IniFiles,math;

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
    Label4: TLabel;
    editVersion: TEdit;
    editUPC: TEdit;
    Label1: TLabel;
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    editLabelNo: TMaskEdit;
    Label19: TLabel;
    Label7: TLabel;
    LabCode: TLabel;
    Label8: TLabel;
    LabCSN: TLabel;
    lstField: TListBox;
    lstValue: TListBox;
    procedure sbtnOKClick(Sender: TObject);
    procedure editCustPartKeyPress(Sender: TObject; var Key: Char);
    procedure editVersionKeyPress(Sender: TObject; var Key: Char);
    procedure editUPCKeyPress(Sender: TObject; var Key: Char);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    G_tsParam,G_tsData:TStrings;
    gSN,gPartID,gUPC,gVer,gCustPart,mCarry,g_wo,sPackingBase,gCHECK_MI_QTY :string;
    gbChkCustPart,gbChkVer,gbChkUPC:Boolean;
    procedure SetTheRegion;
    function ShowRule_Range: Boolean;
    function ShowRule_SEQ: Boolean;
    function Count(sValue :String): Extended;
    function TransferStr(sValue :Integer): String;
    //function GetTerminalID: Boolean;
    function GetCfgData: Boolean;
    function CheckRule(NoType, sInputNo: string): Boolean;
    { Public declarations }
  end;

var
  fMain: TfMain;
  NumUdf, CarryM, CarryD, CarryW : TStrings;
  Carry16,StrDefine,CarryDefine,gsMark,g_sRule,mDateCode,g_Carton,sTerminalID  : string;
  //doing--First CSN
  sFCSN : String;
  G_sockConnection : TSocketConnection;
  //doing--Check CSN
  SNUdf: TStringList;
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
var i,iMaterialQty:integer;
    //Add by doing 2007/09/17--HH CSN=SN
    c_OP,c_CSN,c_SN:String;
    //Add by doing 2007/09/17--HH CSN=SN
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

    gSN:= G_tsData.Strings[G_tsParam.IndexOf('SERIAL_NUMBER')];
    g_Carton:= G_tsData.Strings[G_tsParam.IndexOf('CARTON_NO')];
    //doing
    sTerminalID:=G_tsData.Strings[G_tsParam.IndexOf('TERMINAL_ID')];
    //doing--First CSN
    sFCSN:=G_tsData.Strings[G_tsParam.IndexOf('FIRST_CSN')];
    LabSN.Caption:= gSN;
    NumUdf := TStringList.Create;
    CarryM := TStringList.Create;
    CarryD := TStringList.Create;
    CarryW := TStringList.Create;
    Carry16 := '0123456789ABCDEF';
    //doing
    CarryDefine := '';
    //doing
    //if not GetTerminalID then exit;
    with QryTemp1 do
    begin
      Close;
      Params.Clear;
      CommandText := 'SELECT PARAM_VALUE '
                   + 'from SAJET.SYS_BASE '
                   + 'where PARAM_NAME=''CHECK_MI_QTY'' AND ROWNUM=1 ' ;
      Open;
      if QryTemp1.IsEmpty then
        gCHECK_MI_QTY:='N'
      else
        gCHECK_MI_QTY:=FieldByName('PARAM_VALUE').asstring;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'SN', ptInput);
      CommandText := 'SELECT A.MODEL_ID,A.CUSTOMER_SN,A.WORK_ORDER,B.OPTION15 '
                   + 'from sajet.G_SN_STATUS A,SAJET.SYS_PART B '
                   + 'where A.Serial_Number = :SN AND A.MODEL_ID=B.PART_ID AND ROWNUM=1 ' ;
      Params.ParamByName('SN').AsString := gSN;
      Open;
      gPartID:=FieldByName('MODEL_ID').asstring;
      LabCSN.Caption:=FieldByName('CUSTOMER_SN').asstring;
      g_wo:=FieldByName('WORK_ORDER').asstring;
      //Add by doing 2007/09/17--HH CSN=SN
      c_OP:=FieldByName('OPTION15').asstring;
      //Add by doing 2007/09/17--HH CSN=SN
      if (Uppercase(LabCSN.Caption)='N/A') or (Trim(LabCSN.Caption)='') then
      begin
        //MessageDlg('Customer SN Error!!', mtError, [mbOK], 0);
        //Exit;
        //Modify by doing 2007/09/17--HH CSN=SN
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := 'Select PARAME_VALUE ' +
                       'From SAJET.G_WO_PARAM ' +
                       'Where WORK_ORDER = :WORK_ORDER and ' +
                       'MODULE_NAME = ''CUSTOMER SN RULE'' and '+
                       'PARAME_NAME = ''Customer SN Code'' and '+
                       'PARAME_ITEM = ''Default'' ';
        Params.ParamByName('WORK_ORDER').AsString := g_wo;
        Open;
        if not IsEmpty then
        begin
          c_CSN := FieldByName('PARAME_VALUE').asstring;
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
          CommandText := 'Select PARAME_VALUE ' +
                         'From SAJET.G_WO_PARAM ' +
                         'Where WORK_ORDER = :WORK_ORDER and ' +
                         'MODULE_NAME = ''SERIAL NUMBER RULE'' and '+
                         'PARAME_NAME = ''Serial Number Code'' and '+
                         'PARAME_ITEM = ''Default'' ';
          Params.ParamByName('WORK_ORDER').AsString := g_wo;
          Open;
          if not IsEmpty then
          begin
            c_SN := FieldByName('PARAME_VALUE').asstring;
            if c_CSN = c_SN then LabCSN.Caption:=gSN
            else
            begin
              MessageDlg('Customer SN N/A!!', mtError, [mbOK], 0);
              Exit;
            end;
          end else
          begin
            MessageDlg('SN Rule Error!!', mtError, [mbOK], 0);
            Exit;
          end;
        end else
        begin
          MessageDlg('Customer SN Rule Error!!', mtError, [mbOK], 0);
          Exit;
        end;
        //Modify by doing 2007/09/17--HH CSN=SN
      end;
      //Add by doing 2007/09/23--Check CSN
      SNUdf := TStringList.Create;
      if not CheckRule('SSN', LabCSN.Caption) then exit;
      //Add by doing 2007/09/23--Check CSN
      if c_OP='RANGE' then
      //if FieldByName('OPTION15').asstring='RANGE' then //BY 範圍卡客戶序號順序,箱號與客戶序號規則相同,箱號就是第一台客戶序號 ,只支持十進制
      begin
        if ShowRule_Range then
          Result := True;
      end else  if c_OP='SEQUENCE' then
      //end else  if FieldByName('OPTION15').asstring='SEQUENCE' then  //流水碼(最後一位)卡客戶序號順序 ,只支持十進制
      begin
        if ShowRule_SEQ then
          Result := True;
      end else
      begin
        if gCHECK_MI_QTY='Y' then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'WO', ptInput);
          CommandText := 'SELECT material_qty from sajet.G_WO_MI_QTY '
                       + 'where work_order = :WO AND ROWNUM=1 ' ;
          Params.ParamByName('WO').AsString := g_wo;
          Open;
          if QryTemp1.IsEmpty then
          begin
            MessageDlg('WO NOT MSL', mtError, [mbOK], 0);
            Exit;
          end else
          begin
            iMaterialQty:=QryTemp1.Fieldbyname('material_qty').AsInteger;
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'WO', ptInput);
            Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
            CommandText := 'SELECT A.PROCESS_ID,SUM(A.OUTPUT_QTY) OUTPUT_QTY from sajet.G_SN_COUNT A,SAJET.SYS_TERMINAL B '
                         + 'where A.work_order = :WO AND A.PROCESS_ID=B.PROCESS_ID AND B.TERMINAL_ID=:TERMINAL_ID group by  A.PROCESS_ID ' ;
            Params.ParamByName('WO').AsString := g_wo;
            Params.ParamByName('TERMINAL_ID').AsString := sTerminalID;
            Open;
            if not QryTemp1.IsEmpty then
            begin
              if QryTemp1.Fieldbyname('OUTPUT_QTY').AsInteger >= iMaterialQty then
              begin
                MessageDlg('WO: '+g_wo+' Packing QTY OVER('+IntToStr(iMaterialQty)+')', mtError, [mbOK], 0);
                Exit;
              end;
            end;
          end;
        end;
        Result := True;
      end;
    end;
    Free;
  end;
end;

procedure TfMain.sbtnOKClick(Sender: TObject);
var sKey:char;
begin
  sKey:=#13;
  if not gbChkCustPart then
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

  ModalResult:= mrOK;
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

procedure TfMain.editCSNKeyPress(Sender: TObject; var Key: Char);
begin
  if Key<>#13 then
    exit; 
  editCustPart.SetFocus;
  editCustPart.SelectAll;
end;

function TfMain.ShowRule_Range: Boolean;
Var sCode, sMask,sTemp,sDefault,iSeqValue : string;
    i,iStart,iMaterialQty: Integer;
    ival : Extended;
begin
  Result := False;
  // 讀取編碼規則
  gsMark := '';
  with qryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.G_WO_PARAM ' +
      'Where WORK_ORDER = :WORK_ORDER and ' +
      'MODULE_NAME = :MODULE_NAME ';
    Params.ParamByName('WORK_ORDER').AsString := g_wo;
    Params.ParamByName('MODULE_NAME').AsString := 'CUSTOMER SN RULE';
    Open;
    g_sRule := FieldByName('FUNCTION_NAME').AsString;
    while not Eof do
    begin
      if Fieldbyname('PARAME_NAME').AsString = 'Customer SN Code' then
      begin
        if Fieldbyname('PARAME_ITEM').AsString = 'Code' then
          LabCode.Caption := Fieldbyname('PARAME_VALUE').AsString;
        if (Fieldbyname('PARAME_ITEM').AsString = 'Default')  then
          editLabelNo.Text := Fieldbyname('PARAME_VALUE').AsString;
        if Fieldbyname('PARAME_ITEM').AsString = 'Code Type' then
          mCarry := '0';
          //doing--First CSN
          if Fieldbyname('PARAME_VALUE').AsString = '16' then
            mCarry := '16';
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define' then
      begin
        CarryDefine:=Fieldbyname('PARAME_VALUE').AsString;
        StrDefine:=Fieldbyname('PARAME_ITEM').AsString;
      end;
      Next;
    end;
    sCode := LabCode.Caption;
    sDefault := editLabelNo.Text;
  end;
  if g_sRule = '' then
  begin
    MessageDlg('Customer SN Rule NG!!', mtError, [mbOK], 0);
    Exit;
  end;

  with qryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT * from sajet.G_CARTON_CSN_RANGE '
                 + 'where CARTON_NO = :CARTON_NO AND ROWNUM=1 ' ;
    Params.ParamByName('CARTON_NO').AsString := g_carton;
    Open;
    if QryTemp1.IsEmpty then
    begin
      //doing--First CSN
      if sFCSN = '' then
      begin
        MessageDlg('Please Input First CSN!!', mtError, [mbOK], 0);
        Exit;
      end;
      //doing--First CSN
      sMask:='';
      if POS('S', sDefault)>0 then
      begin
        for I := Length(sCode) downto 1 do
        begin
          if sCode[I] = 'S' then
            sMask := 'S' + sMask;
        end;
        if mCarry='0' then
          CarryDefine:='0123456789'
        else
          CarryDefine:=Carry16;
        //Showmessage('sMask1'+sMask);
      end else
      begin
        for I := Length(sCode) downto 1 do
        begin
          if sCode[I] = StrDefine then
           sMask := StrDefine + sMask;
        end;
        //Showmessage('sMask2'+sMask);
      end;

      //Showmessage(sCode+'/'+sMask+'/'+sDefault);
      iStart:=POS(sMask, sDefault);
      if iStart>0 then
        //doing--First CSN
        iSeqValue:=Copy(sFCSN,iStart,Length(sMask))
        //iSeqValue:=Copy(LabCSN.Caption,iStart,Length(sMask))
      else
      begin
        MessageDlg('Customer SN Rule Seq NG!!', mtError, [mbOK], 0);
        Exit;
      end;
      if not GetCfgData then exit;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
      CommandText := 'SELECT B.CARTON_QTY from sajet.G_PACK_SPEC_TERMINAL A,SAJET.SYS_PKSPEC B '
                   + 'where  A.TERMINAL_ID=:TERMINAL_ID ';
      if sPackingBase='Work Order' then
        CommandText:=CommandText+' AND A.WORK_ORDER = :WORK_ORDER  '
      else
        CommandText:=CommandText+' AND A.MODEL_ID = :WORK_ORDER  ';
      CommandText:=CommandText+ '  AND A.PKSPEC_NAME=B.PKSPEC_NAME AND ROWNUM=1 ' ;
      if sPackingBase='Work Order' then
         Params.ParamByName('WORK_ORDER').AsString := g_wo
      else
         Params.ParamByName('WORK_ORDER').AsString := gPartID;
      Params.ParamByName('TERMINAL_ID').AsString := sTerminalID;
      Open;
      if  QryTemp1.IsEmpty then
      begin
        MessageDlg('PKSPEC NG!!', mtError, [mbOK], 0);
        Exit;
      end;
      ival:=Count(iSeqValue)+Fieldbyname('CARTON_QTY').AsInteger-1;
      iSeqValue:=TransferStr(Trunc(ival));
      if Length(iSeqValue)<Length(sMask) then
      begin
        for i:=1 to Length(sMask)-Length(iSeqValue) do
           iSeqValue:=CarryDefine[1]+iSeqValue;
      end else if Length(iSeqValue)>Length(sMask) then
      begin
        MessageDlg('Customer SN Range Seq >'+IntToStr(Length(sMask)), mtError, [mbOK], 0);
        Exit;
      end;
      sTemp:=Copy(LabCSN.Caption,1,iStart-1)+iSeqValue+Copy(LabCSN.Caption,iStart+Length(sMask),Length(LabCSN.Caption));

      {if (LabCSN.Caption<g_carton) or (LabCSN.Caption>sTemp) then
      begin
        MessageDlg('Customer SN RANGE NG!!'+#9#13+g_carton+' ---- '+ sTemp , mtError, [mbOK], 0);
        Exit;
      end;}

      //doing--First CSN
      if (LabCSN.Caption<sFCSN)
        or (LabCSN.Caption>sTemp) then
      begin
        MessageDlg('Customer SN RANGE NG!!'+#9#13+sFCSN+' ---- '+sTemp
        , mtError, [mbOK], 0);
        Exit;
      end;
      //doing--First CSN

      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      Params.CreateParam(ftString, 'RANGE_FROM', ptInput);
      Params.CreateParam(ftString, 'RANGE_TO', ptInput);
      CommandText := 'Insert Into sajet.G_CARTON_CSN_RANGE (CARTON_NO,RANGE_FROM,RANGE_TO) '
                   + 'Values (:CARTON_NO,:RANGE_FROM,:RANGE_TO) ' ;
      Params.ParamByName('CARTON_NO').AsString := g_carton;
      //doing--First CSN
      Params.ParamByName('RANGE_FROM').AsString := sFCSN;
      //Params.ParamByName('RANGE_FROM').AsString := LabCSN.Caption;
      Params.ParamByName('RANGE_TO').AsString := sTemp;
      Execute;
      //exit;
    end else
    begin
      if (LabCSN.Caption<Fieldbyname('RANGE_FROM').AsString)
        or (LabCSN.Caption>Fieldbyname('RANGE_TO').AsString) then
      begin
        MessageDlg('Customer SN RANGE NG!!'+#9#13+Fieldbyname('RANGE_FROM').AsString+' ---- '+
            Fieldbyname('RANGE_TO').AsString
        , mtError, [mbOK], 0);
        Exit;
      end;
    end;
    if gCHECK_MI_QTY='Y' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO', ptInput);
      CommandText := 'SELECT material_qty from sajet.G_WO_MI_QTY '
                   + 'where work_order = :WO AND ROWNUM=1 ' ;
      Params.ParamByName('WO').AsString := g_wo;
      Open;
      if QryTemp1.IsEmpty then
      begin
        MessageDlg('WO NOT MSL', mtError, [mbOK], 0);
        Exit;
      end else
      begin
        iMaterialQty:=QryTemp1.Fieldbyname('material_qty').AsInteger;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WO', ptInput);
        Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
        CommandText := 'SELECT A.PROCESS_ID,SUM(A.OUTPUT_QTY) OUTPUT_QTY from sajet.G_SN_COUNT A,SAJET.SYS_TERMINAL B '
                     + 'where A.work_order = :WO AND A.PROCESS_ID=B.PROCESS_ID AND B.TERMINAL_ID=:TERMINAL_ID group by  A.PROCESS_ID ' ;
        Params.ParamByName('WO').AsString := g_wo;
        Params.ParamByName('TERMINAL_ID').AsString := sTerminalID;
        Open;
        if not QryTemp1.IsEmpty then
        begin
          if QryTemp1.Fieldbyname('OUTPUT_QTY').AsInteger >= iMaterialQty then
          begin
            MessageDlg('WO: '+g_wo+' Packing QTY OVER('+IntToStr(iMaterialQty)+')', mtError, [mbOK], 0);
            Exit;
          end;
        end;
      end;
    end;
  end;
  Result := True;
end;


function TfMain.ShowRule_SEQ: Boolean;
Var sCode, sMask,sTemp,sDefault,iSeqValue : string;
    i,iStart,iMaterialQty: Integer;
begin
  Result := False;
  // 讀取編碼規則
  gsMark := '';
  mCarry:='';
  CarryDefine:='';
  NumUdf.Clear;
  with qryTemp1 do
  begin
    if gCHECK_MI_QTY='Y' then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WO', ptInput);
      CommandText := 'SELECT material_qty from sajet.G_WO_MI_QTY '
                   + 'where work_order = :WO AND ROWNUM=1 ' ;
      Params.ParamByName('WO').AsString := g_wo;
      Open;
      if QryTemp1.IsEmpty then
      begin
        MessageDlg('WO NOT MSL', mtError, [mbOK], 0);
        Exit;
      end else
      begin
        iMaterialQty:=QryTemp1.Fieldbyname('material_qty').AsInteger;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WO', ptInput);
        Params.CreateParam(ftString, 'TERMINAL_ID', ptInput);
        CommandText := 'SELECT A.PROCESS_ID,SUM(A.OUTPUT_QTY) OUTPUT_QTY from sajet.G_SN_COUNT A,SAJET.SYS_TERMINAL B '
                     + 'where A.work_order = :WO AND A.PROCESS_ID=B.PROCESS_ID AND B.TERMINAL_ID=:TERMINAL_ID group by  A.PROCESS_ID ' ;
        Params.ParamByName('WO').AsString := g_wo;
        Params.ParamByName('TERMINAL_ID').AsString := sTerminalID;
        Open;
        if not QryTemp1.IsEmpty then
        begin
          if QryTemp1.Fieldbyname('OUTPUT_QTY').AsInteger >= iMaterialQty then
          begin
            MessageDlg('WO: '+g_wo+' Packing QTY OVER('+IntToStr(iMaterialQty)+')', mtError, [mbOK], 0);
            Exit;
          end;
        end;
      end;
    end;

    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    CommandText := 'Select * ' +
      'From SAJET.G_WO_PARAM ' +
      'Where WORK_ORDER = :WORK_ORDER and ' +
      'MODULE_NAME = :MODULE_NAME ';
    Params.ParamByName('WORK_ORDER').AsString := g_wo;
    Params.ParamByName('MODULE_NAME').AsString := 'CUSTOMER SN RULE';
    Open;
    g_sRule := FieldByName('FUNCTION_NAME').AsString;
    while not Eof do
    begin
      if Fieldbyname('PARAME_NAME').AsString = 'Customer SN Code' then
      begin
        if Fieldbyname('PARAME_ITEM').AsString = 'Code' then
          LabCode.Caption := Fieldbyname('PARAME_VALUE').AsString;
        if (Fieldbyname('PARAME_ITEM').AsString = 'Default')  then
          editLabelNo.Text := Fieldbyname('PARAME_VALUE').AsString;
        if Fieldbyname('PARAME_ITEM').AsString = 'Code Type' then
        begin
          mCarry := '0';
          if Fieldbyname('PARAME_VALUE').AsString = '16' then
            mCarry := '16';
        end;
      end
      else if Fieldbyname('PARAME_NAME').AsString = 'Customer SN User Define' then
      begin
        CarryDefine:=Fieldbyname('PARAME_VALUE').AsString;
        StrDefine:=Fieldbyname('PARAME_ITEM').AsString;
      end;
      Next;
    end;
    sCode := LabCode.Caption;
    sDefault := editLabelNo.Text;
  end;
  if g_sRule = '' then
  begin
    MessageDlg('Customer SN Rule NG!!', mtError, [mbOK], 0);
    Exit;
  end;

  sMask:='';
  if POS('S', sDefault)>0 then
  begin
    for I := Length(sCode) downto 1 do
    begin
      if sCode[I] = 'S' then
        sMask := 'S' + sMask;
    end;
    if mCarry='0' then
      CarryDefine:='0123456789'
    else
      CarryDefine:=Carry16;
  end else
  begin
    for I := Length(sCode) downto 1 do
    begin
      if sCode[I] = StrDefine then
        sMask := StrDefine + sMask;
    end;
  end;
  iStart:=POS(sMask, sDefault);
  if iStart>0 then
  begin
    iSeqValue:=Copy(LabCSN.Caption,iStart,Length(sMask));
    iSeqValue:=Copy(iSeqValue,Length(iSeqValue),1);
  end else
  begin
    MessageDlg('Customer SN Rule Sequence NG!!', mtError, [mbOK], 0);
    Exit;
  end;

  iStart:=Pos(iSeqValue,CarryDefine);
  if iStart>0 then
  begin
    if length(CarryDefine)=iStart then
    begin
      iStart:=1;
      sTemp:=CarryDefine[iStart];
    end else
      sTemp:=CarryDefine[iStart+1];
  end else
  begin
    MessageDlg('Customer SN Rule Sequence NG!!', mtError, [mbOK], 0);
    Exit;
  end;
  
  with qryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'CARTON_NO', ptInput);
    CommandText := 'SELECT * from sajet.G_CARTON_CSN_RANGE '
                 + 'where CARTON_NO = :CARTON_NO AND ROWNUM=1 ' ;
    Params.ParamByName('CARTON_NO').AsString := g_carton;
    Open;
    if QryTemp1.IsEmpty then
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'CARTON_NO', ptInput);
      Params.CreateParam(ftString, 'seq', ptInput);
      CommandText := 'Insert Into sajet.G_CARTON_CSN_RANGE (CARTON_NO,RANGE_FROM) '
                   + 'Values (:CARTON_NO,:seq) ' ;
      Params.ParamByName('CARTON_NO').AsString := g_carton;
      Params.ParamByName('seq').AsString := sTemp;
      Execute;
    end else
    begin
      if  iSeqValue<>Fieldbyname('RANGE_FROM').AsString then
      begin
        MessageDlg('Customer SN Sequence NG!!'+#9#13+'Sequence : '+Fieldbyname('RANGE_FROM').AsString, mtError, [mbOK], 0);
        Exit;
      end else
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'CARTON_NO', ptInput);
        Params.CreateParam(ftString, 'seq', ptInput);
        CommandText := 'UPDATE sajet.G_CARTON_CSN_RANGE  '
                     + ' SET RANGE_FROM=:SEQ WHERE CARTON_NO=:CARTON_NO ' ;
        Params.ParamByName('CARTON_NO').AsString := g_carton;
        Params.ParamByName('seq').AsString := sTemp;
        Execute;
      end;
    end;
  end;
  Result := True;
end;

{function TfMain.GetTerminalID: Boolean;
begin
   Result := False;
   with TIniFile.Create('SAJET.ini') do
   begin
      sTerminalID := ReadString('Packing', 'Terminal', '');
      Free;
   end;
   if sTerminalID = '' then
   begin
      MessageBeep(17);
      MessageDlg('Terminal not be assign !!', mtError, [mbCancel], 0);
      Exit;
   end;
   Result := True;
end;}

function TfMain.Count(sValue :String): Extended;
Var i : Integer;
    iTmp :  Extended ;
begin
  iTmp:=0;
  for i:=1 to Length(sValue) do
    iTmp:=iTmp+(Pos(sValue[i],CarryDefine)-1)*Power(Length(CarryDefine),(Length(sValue)-i));
  result:=iTmp;
end;

function TfMain.TransferStr(sValue :Integer): String;
Var i,j,k : Integer;
    s,sTemp : String;
begin
  s:='';
  sTemp:=IntToStr(sValue);
  k:= Floor(sValue / Length(CarryDefine));
  j:= sValue mod Length(CarryDefine);
  s:=CarryDefine[j+1]+s;
  while k > 0 do
  begin
    j:= k mod Length(CarryDefine);
    k:= Floor(k / Length(CarryDefine));
    s:=CarryDefine[j+1]+s;
  end;
  result:=s;
end;

function TfMain.GetCfgData: Boolean;
begin
  Result := False;
  with QryTemp1 do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
    Params.CreateParam(ftString, 'FUNCTION_NAME', ptInput);
    Params.CreateParam(ftString, 'TERMINALID', ptInput);
    CommandText := 'SELECT * ' +
      'FROM SAJET.SYS_MODULE_PARAM ' +
      'WHERE MODULE_NAME = :MODULE_NAME AND ' +
      'FUNCTION_NAME = :FUNCTION_NAME AND PARAME_ITEM=''Packing Base'' AND ' +
      'PARAME_NAME = :TERMINALID ';
    Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
    Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
    Params.ParamByName('TERMINALID').AsString := sTerminalID;
    Open;
    if IsEmpty then
    begin
      Close;
      MessageDlg('Configuration not Exist !!',mtError, [mbCancel],0);
      Exit;
    end;
    sPackingBase := Fieldbyname('PARAME_VALUE').AsString;
  end;
  Result := True;
end;

//doing--Check CSN
function TfMain.CheckRule(NoType, sInputNo: string): Boolean;
var sCode, sDefault, sM, sD, sW, uM, uD, uK, uW, sP, sQ, sR, sF, sSeqType, S: string;
  i, iR, j: integer; slValue: TStringList;
  sField1, sType1, sField2, sType2, sField3, sType3, sValue: string;
begin
  SNUdf.Clear;
  Result := True;
  {if gsRuleFunction <> '' then
  begin
    with qryTemp do
    begin
      Close;
      Params.Clear;
      CommandText := 'select ' + gsRuleFunction + '(''' + NoType + ''',''' + sInputNo + ''') result from dual ';
      Open;
      if FieldByName('result').AsString <> 'OK' then
      begin
        Result := False;
        ShowMsg(FieldByName('result').AsString, 'ERROR');
      end;
      Close;
    end;
  end
  else
  begin}
    with qryTemp1 do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      Params.CreateParam(ftString, 'MODULE_NAME', ptInput);
      CommandText := 'SELECT * FROM SAJET.G_WO_PARAM '
        + 'WHERE WORK_ORDER = :WORK_ORDER '
        + 'AND MODULE_NAME = :MODULE_NAME ';
      Params.ParamByName('WORK_ORDER').AsString := g_wo;
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
          MessageDlg('Rule not match (Length)!!', mtError, [mbOK], 0);
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
              MessageDlg('Rule not match (Fix Character)!!', mtError, [mbOK], 0);
              exit;
            end;
          end
          else if sCode[i] = 'Y' then
          begin
            if StrToIntDef(sInputNo[i], -1) = -1 then
            begin
              Result := False;
              MessageDlg('Rule not match (Year)!!', mtError, [mbOK], 0);
              exit;
            end;
          end
          else if sCode[i] = 'K' then
          begin
            if sInputNo[i] in ['1'..'7'] then
            else
            begin
              Result := False;
              MessageDlg('Rule not match (Day of Week)!!', mtError, [mbOK], 0);
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
                MessageDlg('Rule not match (Sequence)!!', mtError, [mbOK], 0);
                exit;
              end;
            end
            else
            begin
              if sInputNo[i] in ['0'..'F'] then
              else
              begin
                Result := False;
                MessageDlg('Rule not match (Sequence)!!', mtError, [mbOK], 0);
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
                  MessageDlg('Rule not match (User Define Sequence)!!', mtError, [mbOK], 0);
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
          MessageDlg('Rule not match (Month User Define)!!', mtError, [mbOK], 0);
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
          MessageDlg('Rule not match (Day User Define)!!', mtError, [mbOK], 0);
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
          MessageDlg('Rule not match (Week User Define)!!', mtError, [mbOK], 0);
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
          MessageDlg('Rule not match (Day of Week User Define)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      slValue.Free;
      if sField1 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField1)];
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
          MessageDlg('Rule not match (1-Option)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sField2 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField2)];
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
          MessageDlg('Rule not match (2-Option)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sField3 <> '' then
      begin
        sValue := lstValue.Items[lstField.Items.IndexOf(sField3)];
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
          MessageDlg('Rule not match (3-Option)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sM <> '' then
      begin
        iR := StrToIntDef(sM, -1);
        if (iR < 1) or (iR > 12) then
        begin
          Result := False;
          MessageDlg('Rule not match (Month)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sD <> '' then
      begin
        iR := StrToIntDef(sD, -1);
        if (iR < 1) or (iR > 31) then
        begin
          Result := False;
          MessageDlg('Rule not match (Day)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sW <> '' then
      begin
        iR := StrToIntDef(sW, -1);
        if (iR < 1) or (iR > 53) then
        begin
          Result := False;
          MessageDlg('Rule not match (Week)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      if sF <> '' then
      begin
        iR := StrToIntDef(sF, -1);
        if (iR < 1) or (iR > 366) then
        begin
          Result := False;
          MessageDlg('Rule not match (Day of Year)!!', mtError, [mbOK], 0);
          exit;
        end;
      end;
      Close;
    end;
  //end;
end;

end.
