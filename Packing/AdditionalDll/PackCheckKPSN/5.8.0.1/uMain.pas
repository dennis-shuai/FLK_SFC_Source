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
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    Label7: TLabel;
    EditSN: TEdit;
    Label8: TLabel;
    lstcheckcsnField: TListBox;
    lstcheckcsnValue: TListBox;
    Label1: TLabel;
    LabCPN: TLabel;
    sgData: TStringGrid;
    Label2: TLabel;
    EditKPSN: TEdit;
    MessageInfo: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure EditKPSNKeyPress(Sender: TObject; var Key: Char);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    G_tsParam,G_tsData:TStrings;
    gSN,gCsn,gPartID,gUPC,gVer,gCustPart:string;
    gbchksn,gbChkCustPart,gbChkVer,gbChkUPC:Boolean;
    gwo:string;
    gprocessid:string;
    gkpcount:integer;
    procedure SetTheRegion;
    Function CheckKPSNRule(CheckString :String; Var sRowNum : Integer ) : boolean;
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
var i,icol,irow:integer;
begin
  gSN:= G_tsData.Strings[G_tsParam.IndexOf('SERIAL_NUMBER')];
  LabSN.Caption:= gSN;
  gProcessid:= G_tsData.Strings[G_tsParam.IndexOf('process_id')];

  gbchksn:=false;

  sgData.Cells[1,0] := 'Item Part Number';
  sgData.Cells[2,0] := 'KeyParts SN';
  sgData.Cells[3,0] := 'Version';
  sgData.Cells[4,0] := 'DESC';
  sgData.Cells[5,0] := 'GROUP';
  sgData.Cells[6,0] := 'LENGTH';
  sgData.Cells[7,0] := 'FROM1';
  sgData.Cells[8,0] := 'TO1';
  sgData.Cells[9,0] := 'FIX1';
  sgData.Cells[10,0] := 'FROM2';
  sgData.Cells[11,0] := 'TO2';
  sgData.Cells[12,0] := 'FIX2';
  sgData.Cells[13,0] := 'KPSN Flag';
  sgData.Cells[14,0] := 'Version Flag';
  sgData.Cells[15,0] := 'PART_ID';

  //Clear Grid
  for iCol := 1 to sgData.ColCount-1 do
  begin
    for iRow := 1 to sgData.RowCount-1 do
    begin
      sgData.Cells[iCol,iRow] := '';
    end;
  end;

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
    gCsn:=fieldbyname('customer_sn').AsString; 
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'PART_ID', ptInput);
    CommandText := 'SELECT * from sajet.SYS_PART '
                 + 'where PART_ID = :PART_ID ' ;
    Params.ParamByName('PART_ID').AsString := gPartID;
    Open;
    LabPart.Caption:=FieldByName('PART_NO').asstring;
    LabCPN.Caption :=fieldbyname('cust_part_no').AsString ;


    close;
    Params.Clear;
    Params.CreateParam(ftString	,'WO', ptInput);
    Params.CreateParam(ftString	,'process', ptInput);
    CommandText :=' SELECT A.WORK_ORDER,A.ITEM_PART_ID,B.PART_NO PART_NO,B.SPEC1 DES,A.ITEM_COUNT,NVL(A.VERSION,''N/A'') VERSION  '
                     +' ,A.ITEM_GROUP,NVL(C.LENGTH1,0) LENGTH1 ,C.FROM1,C.TO1,C.FIX1,C.FROM2,C.TO2,C.FIX2 '
                     +' FROM SAJET.G_WO_BOM A,SAJET.SYS_PART B,SAJET.SYS_PART_SN_RULE C '
                     +' WHERE A.WORK_ORDER= :WO AND A.PROCESS_ID=:process  '
                     +'  AND A.ITEM_PART_ID=B.PART_ID AND A.ITEM_PART_ID=C.PART_ID(+) '
                     +'  AND NVL(C.ENABLED,''Y'')=''Y'' '
                     +'  Order by ITEM_GROUP,Part_no ';
     Params.ParamByName('WO').AsString :=gwo;
     Params.ParamByName('process').AsString :=GProcessID;
     open;
     if recordcount >0 then
     begin
        irow:=0;
        while not eof do
        begin
            inc(iRow);
            sgData.Cells[1,iRow] := FieldByName('PART_NO').asString;
            sgData.Cells[3,iRow] := FieldByName('VERSION').asString;
            sgData.Cells[4,iRow] := FieldByName('DES').asString;
            sgData.Cells[5,iRow] := FieldByName('ITEM_GROUP').asString;
            sgData.Cells[6,iRow] := FieldByName('LENGTH1').asString;
            sgData.Cells[7,iRow] := FieldByName('FROM1').asString;
            sgData.Cells[8,iRow] := FieldByName('TO1').asString;
            sgData.Cells[9,iRow] := FieldByName('FIX1').asString;
            sgData.Cells[10,iRow] := FieldByName('FROM2').asString;
            sgData.Cells[11,iRow] := FieldByName('TO2').asString;
            sgData.Cells[12,iRow] := FieldByName('FIX2').asString;
            sgData.Cells[15,iRow] := FieldByName('ITEM_PART_ID').asString;
            if FieldByName('ITEM_COUNT').asInteger > 1  then
            begin //2
              for i := 1 to FieldByName('ITEM_COUNT').asInteger-1 do
              begin  //1 一個物料Assemble多個數量
                inc(iRow);
                sgData.Cells[1,iRow] := FieldByName('PART_NO').asString;
                sgData.Cells[3,iRow] := FieldByName('VERSION').asString;
                sgData.Cells[4,iRow] := FieldByName('DES').asString;
                sgData.Cells[5,iRow] := FieldByName('ITEM_GROUP').asString;
                sgData.Cells[6,iRow] := FieldByName('LENGTH1').asString;
                sgData.Cells[7,iRow] := FieldByName('FROM1').asString;
                sgData.Cells[8,iRow] := FieldByName('TO1').asString;
                sgData.Cells[9,iRow] := FieldByName('FIX1').asString;
                sgData.Cells[10,iRow] := FieldByName('FROM2').asString;
                sgData.Cells[11,iRow] := FieldByName('TO2').asString;
                sgData.Cells[12,iRow] := FieldByName('FIX2').asString;
                sgData.Cells[15,iRow] := FieldByName('ITEM_PART_ID').asString;
              end; //1
            end;//2
            next;
          end;
        end else  
        begin
          MessageDlg('NOT Define KP BOM!',mtError,[mbCancel],0);
        end;

        if iRow>0 then
          sgData.RowCount := iRow+1
        else
          sgData.RowCount := 2;
          
        close;
   end;

  editsn.SelectAll ;
  editsn.SetFocus ;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
   if FileExists(ExtractFilePath(Application.ExeName) + 'bDetail.bmp') then
   begin
     Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'bDetail.bmp');
     SetTheRegion;
   end;
end;

procedure TfMain.sbtnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
   SNUdf.Free ;
end;

procedure TfMain.EditSNKeyPress(Sender: TObject; var Key: Char);
begin
    gbchksn:=false;
    if (ORD(Key)<>VK_RETURN) or (trim(editsn.Text)='') or (uppercase(trim(editsn.Text))='N/A') Then
       exit;

    if (editsn.Text=gsn) or (editsn.Text=gcsn) then
    begin
       gbchksn:=true;
       editsn.Text:=gsn;
       editkpsn.SelectAll ;
       editkpsn.SetFocus;
    end
    else begin
         editsn.SelectAll ;
         editsn.SetFocus ;
         MessageDlg('SN Error',mtError,[mbCancel],0);
     end;
end;

Function TfMain.CheckKPSNRule(CheckString :String; Var sRowNum : Integer ) : boolean;
Var TempStr :String;
  LRow,from,too : integer;
begin
  Result := False;
  for LRow := 1 to sgData.RowCount-1 do
  begin
    if sgData.Cells[13,LRow] = '*' then //13表示這一行刷了KPSN
    begin
      if (CheckString=sgData.Cells[2,LRow]) and (CheckString<>sgData.Cells[9,LRow])
          and (CheckString<>sgData.Cells[1,LRow]) then
      begin
         MessageDlg('KPSN Has Used for The SN',mtError,[mbCancel],0);
         exit;
      end;
      continue;
    end else
    begin
      if Length(CheckString) <> StrToInt(sgData.Cells[6,LRow]) then
      begin
        if (CheckString = sgData.Cells[1,LRow]) and (StrToInt(sgData.Cells[6,LRow])=0) then
        begin
          sgData.Cells[13,LRow] := '*';
          sRowNum:=LRow;
          Result := true;
          Break;
        end else
          continue;
      end else
      begin
        from := StrToIntDef(sgData.Cells[7,LRow],0);
        too  := StrToIntDef(sgData.Cells[8,LRow],0);
        TempStr := copy(CheckString,from,too-from+1);
        if sgData.Cells[9,LRow] <> TempStr then
        begin
          continue;
        end else
        begin
          if sgData.CellS[10,LRow] <>'' then
          begin
            from := StrToIntDef(sgData.Cells[10,LRow],0);
            too  := StrToIntDef(sgData.Cells[11,LRow],0);
            TempStr := copy(CheckString,from,too-from+1); 
            if sgData.Cells[12,LRow] = TempStr then
            begin
              //第13位的'*'標記已經刷鍋的keyparts
              sgData.Cells[13,LRow] := '*';
              sRowNum:=LRow;
              Result := true;
              Break;
            end;
          end else
          begin
            sgData.Cells[13,LRow] := '*';
            sRowNum:=LRow;
            Result := true;
            Break;
          end;
        end;
      end;
    end;
  end;

  if Result=false then
    MessageDlg('Rule Error',mtError,[mbCancel],0);
end;

procedure TfMain.EditKPSNKeyPress(Sender: TObject; var Key: Char);
Var i,iRowNum:integer;
var ifpass :boolean;
begin
    if (key <> #13) or (editKPSN.Text='')  then exit;
    iRowNum:=0;
    if CheckKPSNRule(editKPSN.Text,iRowNum) then
    begin
       sgData.Cells[2,iRowNum] := editKPSN.Text;
       sgData.Cells[13,iRowNum] := '*';
       MessageInfo.Caption := 'KPSN OK';


       ifpass := true ;
       for i := 1 to sgData.RowCount-1 do
       begin
           if (sgData.Cells[13,i] = '')   then
              ifpass := false ;
       end;

       if ifpass then
       begin
           if gbchksn then
                ModalResult:= mrOK
           else
           begin
               editsn.SelectAll ;
               editsn.SetFocus ;
           end
       end
       else
       begin
           editkpsn.SelectAll ;
           editkpsn.SetFocus ;
       end;
   end;
end;

end.
