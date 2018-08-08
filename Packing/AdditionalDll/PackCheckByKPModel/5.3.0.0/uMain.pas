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
    Label4: TLabel;
    editVersion: TEdit;
    editUPC: TEdit;
    Label1: TLabel;
    sbtnOK: TBitBtn;
    sbtnCancel: TBitBtn;
    Label7: TLabel;
    EditSN: TEdit;
    sgdata: TStringGrid;
    Label8: TLabel;
    procedure sbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
   // procedure editCustPartKeyPress(Sender: TObject; var Key: Char);
   // procedure editVersionKeyPress(Sender: TObject; var Key: Char);
   // procedure editUPCKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure EditSNKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
   // procedure editCSNKeyPress(Sender: TObject; var Key: Char);
  private
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    { Private declarations }
  public
    G_tsParam,G_tsData:TStrings;
    gSN,gPartID,gUPC,gVer,gCustPart:string;
    gbChkCustPart,gbChkVer,gbChkUPC:Boolean;
    gwo:string;
    gkpcount:integer;
    procedure SetTheRegion;
    { Public declarations }
  end;

var
  fMain: TfMain;
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
var i,j:integer;
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
   // gCustPart:= FieldByName('CUST_PART_NO').asstring;
    Close;
  end;

  sgData.Cells[0,0] :='KP_SN';
  sgData.Cells[1,0] :='KP_PART_NO';
  sgData.Cells[2,0] :='PROCESS_NAME';
  sgData.Cells[3,0] :='ITEM_GROUP';
  sgData.ColWidths[0]:=120; 
  sgData.ColWidths[1]:=120;
  sgData.ColWidths[2]:=120;
  sgData.ColWidths[3]:=80;
  for i:=1 to sgData.RowCount-1  do
     for j:=0 to 3 do
       sgData.Cells[j,i]:='';
  with qrydata1 do
      begin
        Close;
        Params.Clear;
      //  Params.CreateParam(ftString, 'work_order', ptInput);
        params.CreateParam(ftString, 'serial_number', ptInput) ;
        CommandText := 'SELECT A.ITEM_PART_SN AS  KP_SN,B.PART_NO, C.PROCESS_NAME,A.ITEM_GROUP  '
                            +' FROM SAJET.G_SN_KEYPARTS A,SAJET.SYS_PART B,SAJET.SYS_PROCESS C '
                            //+' WHERE a.work_order=:work_order and a.serial_number=:serial_number '
                            +' WHERE  a.serial_number=:serial_number '
                            +' AND A.ITEM_PART_ID=B.PART_ID   '
                            +' AND A.PROCESS_ID=C.PROCESS_ID '
                            +' and item_group is not null';
      // Params.ParamByName('work_order').AsString := gwo;
       Params.ParamByName('serial_number').AsString :=gsn;
       Open;

       if not isempty then
          BEGIN
            first;
            i:=1;
            while not eof do
               begin
                  sgData.Cells[0,i] :=fieldbyname('KP_SN').AsString ;
                  sgData.Cells[1,i] :=fieldbyname('PART_NO').AsString ;
                  sgData.Cells[2,i] :=fieldbyname('PROCESS_NAME').AsString ;
                  sgData.Cells[3,i] :=fieldbyname('ITEM_GROUP').AsString ;
                  next;
                  inc(i);
               end;
            sgdata.RowCount:=i;
            gkpcount:=recordcount;
          END
       else
           gkpcount:=0 ;
      end;




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
  var i,j: integer;
  var strkp:string;
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
                  commandtext:='select SERIAL_NUMBER from SAJET.G_SN_STATUS WHERE CUSTOMER_SN=:CSN and rownum=1' ;
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
         with qrytemp1 do
           begin
               Close;
               Params.Clear;
               Params.CreateParam(ftString, 'work_order', ptInput);
               commandtext:='select nvl(sum(item_count),0) as item_count from '
                           +'(select nvl(sum(item_count),0) as item_count from  '
                           + ' (select item_group,item_count,process_id from SAJET.g_wo_bom where work_order=:work_order and item_group<>''0'' '
                           + '   group by item_group,item_count, process_id) '
                           +'  union '
                           +'  select nvl(sum(item_count),0) as item_count from SAJET.g_wo_bom where work_order=:work_order and item_group=''0'')  ';
               Params.ParamByName('work_order').AsString := gwo;
               open;
               if fieldbyname('item_count').AsString>'0' then
                 begin
                   if   fieldbyname('item_count').AsInteger<>gkpcount then
                      begin
                          editsn.SelectAll ;
                          editsn.SetFocus ;
                          MessageDlg('SN '+EDITSN.Text +#13#10+' KP COUNT IS ERROR '+#13#10+fieldbyname('item_count').AsString +'<>'+INTTOSTR(GKPCOUNT),mtError,[mbCancel],0);
                          exit;
                      end;
                 end
               else
                 begin
                      if gkpcount=0 then
                         begin
                            editsn.SelectAll ;
                            editsn.SetFocus ;
                         end
                      else
                         begin
                           editsn.SelectAll ;
                           editsn.SetFocus ;
                           MessageDlg('WO '+GWO+' Not Define KP BOM',mtError,[mbCancel],0);
                           exit;
                      end;
                 end;
           end;

           //check kp ¬O§_¬°¶Ã½X¡@
          for i:=1 to sgdata.RowCount do
             begin
                strkp:=sgdata.Cells[0,i];
                for j:=1 to length(sgdata.Cells[0,i]) DO
                   if not( strkp[J] in ['A'..'Z','0'..'9']) then
                     begin
                         editsn.SelectAll ;
                         editsn.SetFocus ;
                         MessageDlg('KP_SN '+STRKP+#13#10+'has char of ('+strkp[j]+')',mtError,[mbCancel],0);
                         exit;
                     end;
             end;

           
          ModalResult:= mrOK; 
     end;
end;

end.
