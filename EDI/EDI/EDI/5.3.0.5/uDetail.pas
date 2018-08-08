unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnMaterial: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    lablType: TLabel;
    Label9: TLabel;
    editASN: TEdit;
    Label12: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    SProc: TClientDataSet;
    editCarton: TEdit;
    Label3: TLabel;
    lablMsg: TLabel;
    sgData: TStringGrid;
    Labwoqty: TLabel;
    SpeedButton1: TSpeedButton;
    Qrydata: TClientDataSet;
    Editsendor: TEdit;
    EditReceiver: TEdit;
    cmbType: TComboBox;
    cmbType1: TComboBox;
    PanelMsg: TPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    QryCarton: TClientDataSet;
    sgCarton: TStringGrid;
    LabCnt: TLabel;
    Editapplicationreceivercode: TEdit;
    procedure FormShow(Sender: TObject);
    procedure sbtnClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editCartonKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cmbTypeChange(Sender: TObject);
    procedure sbtnMaterialClick(Sender: TObject);
    procedure sgCartonDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure editASNKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    sPalletID,sCartonID:TStringList;
    procedure ShowMsg(MsgStr:string);
    function CheckCartonDup(Carton:string):boolean;
    function CheckCondition:boolean;
    function GetDocID:string;
    Procedure MoveToHT(ASNDocID:string);
    procedure ClearData;
    Procedure ClearGrid(tGrid:tstringgrid);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uData;

Procedure TfDetail.ClearGrid(tGrid:tstringgrid);
var i,j:integer;
begin
  for i:=1 to tGrid.RowCount-1 do
    for j:=0 to tGrid.ColCount-1 do
      tGrid.Cells[j,i]:='';
  tGrid.RowCount:=2;
end;

Procedure TfDetail.MoveToHT(ASNDocID:string);
begin
  with qrydata do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' insert into b2b.ht_ASN_IN_Header select * from b2b.ASN_IN_Header where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' delete from  b2b.ASN_IN_Header where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' insert into b2b.ht_ASN_IN_Shipment select * from b2b.ASN_IN_Shipment  where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' delete from  b2b.ASN_IN_Shipment where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' insert into b2b.ht_ASN_IN_Pallet select * from b2b.ASN_IN_Pallet where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' delete from  b2b.ASN_IN_Pallet where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' insert into b2b.ht_ASN_IN_Carton select * from b2b.ASN_IN_Carton where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' delete from  b2b.ASN_IN_Carton where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' insert into b2b.ht_ASN_IN_Serial select * from b2b.ASN_IN_Serial where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;

    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' delete from  b2b.ASN_IN_Serial where doc_id=:DocID';
    Params.ParamByName('DocID').AsString := ASNDocID;
    execute;


  end;

end;

function TfDetail.GetDocID:string;
begin
  with sproc do
  begin
    try
      close;
      DataRequest('SAJET.MES_EDI_GET_ID');
      FetchParams;
      Params.ParamByName('TTYPE').AsString :='RC';
      Execute;
      result:=Params.ParamByName('TRES').AsString;
    finally
      close;
    end;
  end;
end;

function TfDetail.CheckCartonDup(Carton:string):boolean;
var i:integer;
begin
   result:=true;
   for i:=1 to sgData.RowCount-1 do
   begin
     if sgData.Cells[3,i]=Carton then
     begin
        result:=false;
        break;
     end;
   end;
end;

function TfDetail.CheckCondition:boolean;
var i:integer;
begin
   result:=true;
   for i:=1 to sgData.RowCount-1 do
     if sgData.Cells[1,i]<>'GD' then
     begin
        result:=false;
        break;
     end;
end;

procedure TfDetail.ShowMsg(MsgStr:string);
begin
  PanelMsg.Caption:=MsgStr;
  if MsgStr<>'OK' then
    panelMsg.Font.Color:=clRed
  else  panelMsg.Font.Color:=clGreen;
end;

procedure TfDetail.FormShow(Sender: TObject);
Var sTable : String;
begin
  sPalletID:=tstringlist.Create;
  sCartonID:=tstringlist.Create;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'EDIDLL.DLL';
    Open;
    LabTitle1.Caption := FieldByName('f1').AsString+'  ';
    LabTitle2.Caption := LabTitle1.Caption;  
  end;

  sgData.Cells[0,0] :='DocID';
  sgData.Cells[1,0] :='Conditon';
  sgData.Cells[2,0] :='Pallet';
  sgData.Cells[3,0] :='Carton';
  sgData.Cells[4,0] :='Qty';

  sgCarton.Cells[1,0]:='DocID';
  sgCarton.Cells[2,0] :='Pallet';
  sgCarton.Cells[3,0] :='Carton';
  sgCarton.Cells[4,0] :='Qty';
  sgCarton.Cells[5,0] :='Status';
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
  ClearData;
  ClearGrid(sgdata);
  Cleargrid(sgCarton);
  sPalletID.Clear;
  sCartonID.Clear;
  editASn.Enabled:=true;
  EditAsn.SelectAll;
  editAsn.SetFocus;
end;

procedure TfDetail.ClearData;
begin
  editAsn.Text:='';
  editCarton.Text:='';
  cmbType.ItemIndex:=0;
  cmbType1.ItemIndex:=0;
  PanelMsg.Caption:='';
  Editsendor.Text:='';
  EditReceiver.Text:='';
  Editapplicationreceivercode.Text :='';
end;

procedure TfDetail.FormDestroy(Sender: TObject);
begin
  sPalletID.Free;
  sCartonID.Free;
end;

procedure TfDetail.editCartonKeyPress(Sender: TObject; var Key: Char);
var i,iRow:integer;
begin
  if key<>#13 then exit;

  editASN.Enabled:=false;

  if not CheckCartonDup(editCarton.Text)then
  begin
    ShowMsg('The Carton Has Scan ');
    editCarton.SelectAll;
    editCarton.SetFocus;
    exit;
  end;

  with qryCarton do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'iCarton', ptInput);
    commandtext:=' select Doc_id,Pallet_id,Carton_id,QUANTITY,status from b2b.ASN_IN_Carton '
                +' where pallet_id in ( select distinct pallet_id from b2b.ASN_IN_Carton where carton_id=:iCarton) '
                +' order by carton_id ';
    Params.ParamByName('iCarton').AsString := editCarton.Text;
    open;
    iRow:=1;
    clearGrid(sgCarton);
    if not isEmpty then
    begin
      sgCarton.RowCount:=recordcount+1;
      while not eof do
      begin
        sgCarton.Cells[1,iRow]:=fieldbyname('Doc_id').AsString;
        sgCarton.Cells[2,iRow]:=fieldbyname('Pallet_id').AsString;
        sgCarton.Cells[3,iRow]:=fieldbyname('Carton_id').AsString;
        sgCarton.Cells[4,iRow]:=fieldbyname('QUANTITY').AsString;
        sgCarton.Cells[5,iRow]:=fieldbyname('status').AsString;
        next;
        inc(iRow);
      end;
    end;
  end;

  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'iCarton', ptInput);
    commandtext:=' select * from  b2b.ASN_IN_Carton '
                +' where carton_id=:iCarton ';
    Params.ParamByName('iCarton').AsString := editCarton.Text;
    open;
    if isEmpty then
    begin
      ShowMsg('NO Caron');
      editCarton.SelectAll;
      editCarton.SetFocus;
      exit;
    end
    else if fieldbyname('status').AsString='Y' then
    begin
      ShowMsg('The Carton Has Scan ');
      editCarton.SelectAll;
      editCarton.SetFocus;
      exit;
    end
    else if fieldbyname('Doc_id').asstring<>trim(editASn.Text) then
    begin
      ShowMsg('Doc ID Diffient ');
      editCarton.SelectAll;
      editCarton.SetFocus;
      exit;
    end
    else begin
       if sPalletID.IndexOf(fieldbyname('Pallet_id').AsString)=-1 then
         sPalletID.Add(fieldbyname('Pallet_id').AsString);
       if sCartonId.IndexOf(fieldbyname('Carton_id').AsString)=-1 then
         sCartonId.Add(fieldbyname('Carton_id').AsString);
    end;
  end;
  if  sgData.Cells[0,sgData.RowCount-1]<>'' then
    sgData.RowCount:=sgData.RowCount+1;
  sgData.Cells[0,sgData.RowCount-1]:=editASN.Text;
  sgData.Cells[1,sgData.RowCount-1]:=cmbType1.Text;
  sgData.Cells[2,sgData.RowCount-1]:=qrytemp.fieldbyname('pallet_id').AsString;
  sgData.Cells[3,sgData.RowCount-1]:=editCarton.Text;
  sgData.Cells[4,sgData.RowCount-1]:=qrytemp.fieldbyname('QUANTITY').AsString;

  showMsg('OK');
  editCarton.SelectAll;
  editCarton.SetFocus;
  LabCnt.Caption:=inttostr(sgData.RowCount-1);

end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var fData:tfData;
begin
  fData:=Tfdata.Create(self);
  fdata.DataSource1.DataSet:=qrytemp;
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' select distinct a.* from b2b.ASN_IN_Header a,b2b.asn_in_carton b '
                +' where  b.status=''N''  '
                +'        and a.doc_id=b.doc_id '
                +'        and a.doc_id like :DocID ';
    Params.ParamByName('DocID').AsString := trim(editASN.Text)+'%';
    open;
  end;
  if fdata.ShowModal=mrOK then
  begin
    editASN.Text:=qrytemp.fieldbyname('doc_id').AsString;
    editSendor.Text:= qrytemp.fieldbyname('Receiver_ID').asstring;
    editReceiver.Text:= qrytemp.fieldbyname('sender_id').AsString;
    Editapplicationreceivercode.Text :=qrytemp.fieldbyname('application_receiver_code').AsString;
    editASN.Enabled:=false;
    editCarton.Enabled:=true;
    editCarton.SelectAll;
    editCarton.SetFocus;
  end;
end;

procedure TfDetail.cmbTypeChange(Sender: TObject);
begin
  cmbTYpe1.ItemIndex:=cmbType.ItemIndex;
end;

procedure TfDetail.sbtnMaterialClick(Sender: TObject);
var sDocID,sCondition,sCarton:string;
    i:integer;
begin
  sCarton:='(';
  for i:=0 to sCartonId.Count-1 do
  begin
    sCarton:=sCarton+''''+sCartonid[i]+''''+',';
  end;
  sCarton:=copy(sCarton,1,length(sCarton)-1)+')'; 

  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' select * from b2b.asn_in_carton '
                +' where doc_id=:DocID '
                +'      and carton_id not in '+sCarton;
    Params.ParamByName('DocID').AsString := trim(editASN.Text);
    open;
    if not isEmpty then
    begin
      showMsg('The DocID '+editASN.Text+' '+Fieldbyname('carton_id').AsString+' not Complete');
      editCarton.SelectAll;
      editCarton.SetFocus;
      exit;
    end;
  end;

  sDocID:=GetDocId;

  if CheckCondition then sCondition:='F' else sCondition:='I';
  //insert Header
  with qrydata do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    Params.CreateParam(ftString, 'SendorID', ptInput);
    Params.CreateParam(ftString, 'Receiver', ptInput);
    Params.CreateParam(ftString, 'ASNDOCID', ptInput);
    Params.CreateParam(ftString, 'Codition', ptInput);
    Params.CreateParam(ftString, 'application_sender_code', ptInput);
    commandtext:=' insert into b2b.rc_header(DOC_ID,SENDER_ID,RECEIVER_ID,ASN_DOC_ID,RECV_CONDITION_CODE,RECEIVED_DATE,application_sender_code)'
                +' values (:DocID,:SendorID,:Receiver,:ASNDOCID,:Codition,sysdate,:application_sender_code) ';
    Params.ParamByName('DocID').AsString := sDocID;
    Params.ParamByName('SendorID').AsString :=Editsendor.Text;
    Params.ParamByName('Receiver').AsString :=EditReceiver.Text;
    Params.ParamByName('ASNDOCID').AsString :=editASN.Text;
    Params.ParamByName('Codition').AsString := sCondition;
    Params.ParamByName('application_sender_code').AsString := Editapplicationreceivercode.Text ;
    execute;
  end;

  //insert Pallet
  for i:=0 to sPalletId.Count-1 do
  begin
    with qrydata do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DocID', ptInput);
      Params.CreateParam(ftString, 'Pallet', ptInput);
      commandtext:=' insert into b2b.rc_pallet(DOC_ID,PALLET_ID) '
                  +' values(:DocID,:Pallet) ';
      Params.ParamByName('DocID').AsString := sDocID;
      Params.ParamByName('Pallet').AsString := sPalletID[i];
      execute;
    end;
  end;

  //insert Carton
  for i:=1 to sgData.RowCount-1 do
  begin
    //insert Carton
    with qrydata do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'DocID', ptInput);
      Params.CreateParam(ftString, 'Pallet', ptInput);
      Params.CreateParam(ftString, 'Carton', ptInput);
      Params.CreateParam(ftString, 'Condition', ptInput);
      Params.CreateParam(ftString, 'Qty', ptInput);
      commandtext:=' insert into b2b.rc_carton(DOC_ID,PALLET_ID,CARTON_ID,RECV_CONDITION_CODE,RECV_CONDITION_QTY)'
                  +' values(:DocID,:Pallet,:Carton,:Condition,:Qty) ';
      Params.ParamByName('DocID').AsString := sDocID;
      Params.ParamByName('Pallet').AsString := sgData.Cells[2,i];
      Params.ParamByName('Carton').AsString := sgData.Cells[3,i];
      Params.ParamByName('Condition').AsString := sgData.Cells[1,i];
      Params.ParamByName('Qty').AsString := sgData.Cells[4,i];
      execute;
    end;

    //update
    with qrydata do
    begin
      close;
      params.Clear;
      Params.CreateParam(ftString, 'Carton', ptInput);
      commandtext:=' update b2b.ASN_IN_CARTON set status=''Y'' where carton_id=:carton and rownum=1 ';
      Params.ParamByName('Carton').AsString := sgData.Cells[3,i];
      execute;
    end;
  end;
  MoveToHT(trim(editASN.Text));

  clearData;
  clearGrid(sgData);
  ClearGrid(sgCarton);
  sPalletID.Clear;
  sCartonID.Clear;
  editAsn.Enabled:=true;
  editCarton.Enabled:=false;
  editAsn.SelectAll;
  editAsn.SetFocus;
end;

procedure TfDetail.sgCartonDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  Var K : Integer;
begin
  if (ACol<=0) then exit;
  K:=sgCarton.RowCount;
  if (ARow=0) and (ACol<k) then exit ;
  if ARow=0 then exit;
  if sCartonid.IndexOf(sgCarton.Cells[3,ARow])=-1 then
  begin
    sgCarton.Canvas.Brush.Color:=clWindow;
    sgCarton.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgCarton.Cells[ACol, ARow]);
  end
  else begin
    sgCarton.Canvas.Brush.Color:=clAqua;
    sgCarton.Canvas.TextRect(Rect, Rect.Left+5 , Rect.Top+2, sgCarton.Cells[ACol, ARow]);
  end;
end;

procedure TfDetail.editASNKeyPress(Sender: TObject; var Key: Char);
begin
  if key<>#13 then exit;
  if trim(editAsn.Text)='' then exit;
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'DocID', ptInput);
    commandtext:=' select distinct a.* from b2b.ASN_IN_Header a,b2b.asn_in_carton b '
                +' where  b.status=''N''  '
                +'        and a.doc_id=b.doc_id '
                +'        and a.doc_id like :DocID ';
    Params.ParamByName('DocID').AsString := trim(editASN.Text);
    open;
    if isempty then
      showmsg('No DocID or DocID Has Out')
    else begin
      editAsn.Enabled:=false;
      editCarton.Enabled:=true;
      editSendor.Text:= fieldbyname('Receiver_ID').asstring;
      editReceiver.Text:= fieldbyname('sender_id').AsString;
      Editapplicationreceivercode.Text :=qrytemp.fieldbyname('application_receiver_code').AsString;
      editCarton.SelectAll;
      editCarton.SetFocus;
    end;
  end;
end;

end.

