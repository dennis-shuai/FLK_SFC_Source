unit uRepacking;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls,
  Db, DBClient, MConnect, SConnect, IniFiles, ObjBrkr, ImgList, Menus,
  //unitCSPrintData,unitDataBase,
  GradPanel;

type
  TfRepacking = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    QryCartonData: TClientDataSet;
    Label11: TLabel;
    //editReCartonNo: TEdit;
    Label16: TLabel;
    editBoxNo: TEdit;
    sbtnNewBox: TSpeedButton;
    Image4: TImage;
    sbtnClosePallet: TSpeedButton;
    Label13: TLabel;
    lablQty2: TLabel;
    Label18: TLabel;
    lablTotal: TLabel;
    lvCarton: TListView;
    lvCSN: TListView;
    Label1: TLabel;
    Lablfifocode: TLabel;
    Qrymaterial: TClientDataSet;
    QryFIFO: TClientDataSet;
    QryFCTYPE: TClientDataSet;
    Label2: TLabel;
    lblfctype: TLabel;
    editReCartonNO: TEdit;
    lbl1: TLabel;
    QryRepack: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure sbtnNewBoxClick(Sender: TObject);
    procedure editBoxNoKeyPress(Sender: TObject; var Key: Char);
    procedure lvCartonClick(Sender: TObject);
    procedure sbtnClosePalletClick(Sender: TObject);
    procedure editReCartonNoKeyPress(Sender: TObject; var Key: Char);
    procedure editReCartonNoChange(Sender: TObject);
  private
    mPalletOfCarton,mCarton,mCartonModelID,mCartonofBox, mProcessOfCarton, mProcessOfBox: String;
    mFifoOfCarton,mFifoOfBox,mWoOfBox,mWoOfCarton:string;
    TerminalID: String;
    PrintCartonLabel, PrintPalletLabel: Boolean;
    PrintCartonLabQty,
    PrintPalletLabQty,
    CodeSoftVersion: Integer;
    procedure addBox2Carton;
    function  checkBox:Boolean;
    procedure getCartonDetail;
    function  getNewPallet:String;
    procedure showCSNofBox(psBox:String);
    procedure clearReCarton;
    function  getCfgData:Boolean;
  public
    { Public declarations }
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    bInputCarton,IsCartonInStock,IsBoxInStock,IsInRepackTemp:Boolean;
    Box_Count,iBoxofRepackQty:integer;
    spartid,sfactoryid,sfifo,sfactorytype,swarehouse,slocate,sStatus,sVersion,sDateCode:string;
    Procedure SetStatusbyAuthority;
    function CheckCarton:Boolean;
    function  AddMaterialQty(Material_no:string;Qty:Integer):Boolean;
    function  ReduceMaterialQty(Material_no:string;Qty:Integer):Boolean;
    function  CheckMaterialInfo:Boolean;


  end;

var
  fRepacking: TfRepacking;
  fSubModel : Boolean;
implementation

{$R *.DFM}

uses uDllform,Dllinit;

function TfRepacking.CheckCarton:Boolean;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := ' SELECT A.SERIAL_NUMBER,A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER, '
                   + ' A.MODEL_ID, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,A.SHIPPING_ID, A.Pallet_NO,'
                   + ' B.PART_NO, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT ,'
                   + ' Decode(A.Next_process,0,A.WIP_PROCESS,A.Next_process) WIP_PROCESS '
                   + ' FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B '
                   + ' WHERE A.Carton_NO = ''' + editReCartonNo.Text + ''' '
                   + ' AND A.MODEL_ID = B.PART_ID ';
      Open;
      If RecordCount = 0 then
      begin
         Result := True;
         Close;
         Exit;
      end;
      mWoOfCarton :=  FieldByName('WORK_ORDER').AsString ;
      mPalletOfCarton := FieldByName('Pallet_No').AsString ;
      mProcessOfCarton := FieldByName('WIP_PROCESS').AsString ;
      
      if Locate('QC_Result','1',[]) then
      begin
         MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                     'Had been Reject !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;

         //不良品
      if FieldByName('Current_Status').AsString <> '0' then
      begin
            MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                       'Have to Repair !!',mtError,[mbCancel],0);
            Close;
            Exit;
      end;
         //報廢品
      if FieldByName('Work_Flag').AsString <> '0' then
      begin
          MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                     'Had been Scrap !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;

       //已出貨
      if FieldByName('Shipping_ID').AsString <> '0' Then
      begin
          MessageDlg( editBoxNo.Text + #13#10 +
                     'Shippinged !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;

      Close;
       
   end;

   Result := True;
end;

procedure TfRepacking.showCSNofBox(psBox:String);
begin
   lvCSN.Items.Clear;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.WORK_ORDER, B.PART_NO, C.PROCESS_NAME, A.MODEL_ID, A.PROCESS_ID, '
                   + '       A.PALLET_NO, A.QC_NO, A.QC_RESULT, A.SERIAL_NUMBER '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B, '
                   + '       SAJET.SYS_PROCESS C '
                   + ' WHERE BOX_NO = ''' + psBox + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID '
                   + '   AND A.PROCESS_ID = C.PROCESS_ID '
                   + ' ORDER BY CUSTOMER_SN ';
      Open;


      while not Eof do
      begin
         with lvCSN.Items.Add do
         begin
            Caption := FieldByName('Customer_SN').AsString;
            SubItems.Add(FieldByName('SERIAL_NUMBER').AsString);
            SubItems.Add(FieldByName('Work_Order').AsString);
            SubItems.Add(FieldByName('Part_No').AsString);
            SubItems.Add(FieldByName('PALLET_NO').AsString);
         end;
         Next;
      end;
   end;
end;

function TfRepacking.getNewPallet:String;
var iSeq : integer;
    sNew : String;
begin
{   sNew :='';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT NVL(MAX(PALLET_NO),''PX''||TO_CHAR(SYSDATE,''YYYYMMDD'')||''0000'') NEWPALLET '
                   + '  FROM SAJET.G_PACK_PALLET '
                   + ' WHERE SUBSTR(PALLET_NO,1,10) = ''PX''||TO_CHAR(SYSDATE,''YYYYMMDD'') ';
      Open;
      iSeq := StrToInt(Copy(FieldByName('NewPallet').AsString,11,4))+1;
      sNew := Copy(FieldByName('NewPallet').AsString,1,10) + FormatFloat('0000',iSeq);
      Close;
   end;
   While not CheckCartonTemp(sNew) do
   begin
      iSeq := StrToInt(Copy(sNew,11,4))+1;
      sNew := Copy(sNew,1,10) + FormatFloat('0000',iSeq);
   end;
   with QryTemp do
   begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Pallet',ptInput);
        Params.CreateParam(ftString,'USERID',ptInput);
        CommandText := 'INSERT INTO SAJET.G_PACK_PARAM '
                     + ' (Temp_no,update_date, update_userID) '
                     + ' VALUES (:Pallet, sysdate, :USERID) ';
        Params.ParamByName('Pallet').AsString := sNew;
        Params.ParamByName('UserId').AsString := UpdateUserID;
        Execute;
        Close;
   end;
   Result := sNew; }
end;

procedure TfRepacking.addBox2Carton;
begin

   //update fifocode in table of g_material

     if IsInRepackTemp then begin
          if not IsCartonInStock then begin
              Lablfifocode.Caption := QryRepack.fieldbyName('FIFOCODE').AsString;
              mFifoOfCarton :=Lablfifocode.Caption ;
          end else if  QryRepack.fieldbyName('FIFOCODE').AsString < Lablfifocode.Caption then begin
              Lablfifocode.Caption := QryRepack.fieldbyName('FIFOCODE').AsString ;
          end;
     end;

     if not IsCartonInStock then
     begin
          if IsBoxInStock or IsInRepackTemp then
          begin
              //Insert G_MATERIAL
               with QryTemp do
               begin
                    Close;
                    Params.Clear;
                    Params.CreateParam(ftString,'partid',ptInput);
                    Params.CreateParam(ftString,'Material_no',ptInput);
                    Params.CreateParam(ftString,'Material_Qty',ptInput);
                    Params.CreateParam(ftString,'fifo',ptInput);
                    Params.CreateParam(ftString,'factoryid',ptInput);
                    Params.CreateParam(ftString,'factorytype',ptInput);
                    Params.CreateParam(ftString,'warehouse',ptInput);
                    Params.CreateParam(ftString,'locate',ptInput);
                    Params.CreateParam(ftString,'userid',ptInput);
                    Params.CreateParam(ftString,'status',ptInput);
                    Params.CreateParam(ftString,'version',ptInput);
                    Params.CreateParam(ftString,'DateCode',ptInput);
                    commandtext:=' insert into sajet.G_MATERIAL(PART_ID,Material_no,Material_Qty,FIFOCODE,FACTORY_ID,FACTORY_TYPE,WAREHOUSE_ID,'+
                                 ' LOCATE_ID,UPDATE_TIME,UPDATE_USERID,status,version,DateCode ) ' +
                                 ' values(:partid,:Material_no,:Material_Qty,:fifo,:factoryid,'+
                                 ' :factorytype,:warehouse,:locate,SYSDATE,:userid,:status,:version,:DateCode) ';
                    Params.ParamByName('partid').AsString :=spartid;
                    Params.ParamByName('Material_no').AsString :=editReCartonNO.Text;
                    if iBoxofRepackQty >0 then
                       Params.ParamByName('Material_Qty').AsInteger := iBoxofRepackQty;
                    if not Qrymaterial.IsEmpty then
                       Params.ParamByName('Material_Qty').AsInteger := Box_Count;
                    Params.ParamByName('fifo').AsString :=sfifo;
                    Params.ParamByName('factoryid').AsString :=sfactoryid;
                    Params.ParamByName('factorytype').AsString :=sfactorytype;
                    Params.ParamByName('warehouse').AsString := swarehouse;
                    Params.ParamByName('locate').AsString :=   slocate;
                    Params.ParamByName('Userid').AsString :=   UpdateUserID;
                    Params.ParamByName('status').AsString :=   sStatus;
                    Params.ParamByName('version').AsString :=  sVersion;
                    Params.ParamByName('DateCode').AsString := sDateCode;
                    execute;

                    // backup
                    close;
                    params.Clear ;
                    commandtext:='insert into sajet.g_ht_material (select * from sajet.g_material where material_no = ''' + editRecartonNo.Text + ''' and rownum=1 )' ;
                    execute;

               end;


          end;


     end
     else begin

        if (IsBoxInStock) or IsInRepackTemp then
        begin
            AddMaterialQty(mCarton,Box_Count);
        end;

     end;

     if  IsBoxInStock then
         ReduceMaterialQty(mCartonofBox,Box_Count);


     //delete G_SN_REPACK
     if IsInRepackTemp then
     begin
          with QryTemp do begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString,'partid',ptInput);
              CommandText :='DELETE FROM SAJET.G_SN_REPACK WHERE BOX_NO=:BOXNO' ;
              Params.ParamByName('BOXNO').AsString := editBoxNo.Text;
              Execute;
          end  ;
     end;
     
     with qrytemp do
     begin
         close;
         params.Clear ;
         Params.CreateParam(ftString,'PalletNo',ptInput);
         commandtext:='UPDATE SAJET.G_SN_STATUS SET CARTON_NO ='''+editRecartonNo.Text +''',PALLET_NO =:PalletNo'+
                    ' where  BOX_NO ='''+editBOXNO.Text +'''';
          Params.ParamByName('PalletNo').AsString := mPalletOfCarton;
          execute;
     end;

end;
function  TfRepacking.AddMaterialQty(Material_no:string;Qty:Integer):Boolean;
begin
    with QryTemp do
   begin
        close;
        params.Clear ;
        commandtext:=' update sajet.g_material  '
                   +'  set material_qty=material_qty+ '+IntToStr(Qty)+', update_userid='''+UpdateUserID
                   +''',update_time=sysdate,fifocode='''+lablfifocode.Caption+''' '
                   +' where material_no= ''' + Material_no + ''' and rownum=1 ';
         execute;

         close;
         params.Clear ;
         commandtext:=' insert into sajet.g_ht_material '
                  +' (select * from sajet.g_material where material_no= ''' + Material_no + ''' and rownum=1 )';
         execute;
   end;
end;
function  TfRepacking.ReduceMaterialQty(Material_no:string;Qty:Integer):Boolean;
begin
    with QryTemp do begin

        close;
        params.Clear ;
        commandtext:='update sajet.g_material  '
                 +'  set material_qty=material_qty-'+IntTOStr(qty)+', update_userid='''+UpdateUserID+''',update_time=sysdate '
                 +' where material_no= ''' + Material_no + ''' and rownum=1 ';
        execute;

        close;
        params.Clear ;
        commandtext:='insert into sajet.g_ht_material '
                    +' (select * from sajet.g_material where material_no= ''' + Material_no + ''' and rownum=1 )';
        execute;

         //chech material_qty=0 for old carton_no
        close;
        params.Clear ;
        commandtext:='select material_qty from sajet.g_material '
                    +' where material_no= ''' + Material_no + ''' and rownum=1 ';
        open;

         if fieldbyname('material_qty').AsInteger <=0 then
         begin
               close;
               params.Clear ;
               commandtext:='delete  sajet.g_material '
                       +' where material_no= ''' + Material_no + ''' and rownum=1 ';
               execute;
         end;
    end;
end;

procedure TfRepacking.getCartonDetail;
   Function getCartonQty:String;
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'SELECT COUNT(*) FROM SAJET.G_SN_STATUS '
                      + 'WHERE Carton_NO = ''' + editReCartonNo.Text + ''' ';
         Open;
         Result := FieldByName('Count(*)').AsString;
         Close;
      end;
   end;
begin
   lvCarton.Items.Clear;
   lablQty2.Caption := '0';
   lvCSN.Items.Clear;
   lablTotal.Caption := '0';
   lablfifocode.Caption :='0';
   lblfctype.Caption :='0';

   with QryCartonData do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT WORK_ORDER, MODEL_ID, PROCESS_ID,QC_NO, QC_RESULT, Out_PDLine_Time '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE Carton_NO = ''' + editReCartonNo.Text + ''' '
                   + '   AND ROWNUM = 1 ';
      Open;
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT BOX_NO, COUNT(SERIAL_NUMBER) QTY '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE Carton_No = ''' + editReCartonNo.Text + ''' '
                   + ' GROUP BY BOX_NO ';
      Open;
      while not Eof do
      begin
         with lvCarton.Items.Add do
         begin
            Caption := QryTemp.FieldByName('Box_NO').AsString;
            SubItems.Add(QryTemp.FieldByName('QTY').AsString);
         end;
         Next;
      end;
      lablQty2.Caption := IntToStr(RecordCount);
      If RecordCount = 0 then
      begin
          mFifoOfCarton :='0';
          Exit;
      end;
      Close;
   end;

   //check fifocode  add by key 2007/08/06
   with QryFIFO do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT NVL(WAREHOUSE_ID,''0'') AS WAREHOUSE_ID ,NVL(LOCATE_ID,''0'') LOCATE_ID,FIFOCODE  '
                 +'  from SAJET.G_MATERIAL WHERE MATERIAL_NO='''+editRecartonNo.Text+''' AND ROWNUM=1';
      Open;
      IF NOT ISEMPTY THEN begin
         mFifoOfCarton :=  FIELDBYNAME('FIFOCODE').AsString ;
         LABLFIFOCODE.Caption :=  mFifoOfCarton;
         IsCartonInStock :=True;
      end else begin
         mFifoOfCarton :='0';
         IsCartonInStock :=false;
      end;
   end;

   lablTotal.Caption := getCartonQty;
   showCSNofBox(lvCarton.Items[0].Caption);



   //check ORG(FACTORY TYPE) ADD BY KEY 2008/05/21
   with QryFCTYPE do
   begin
         Close;
         Params.Clear;
         CommandText := ' SELECT A.FACTORY_ID,A.FACTORY_CODE||''-''||A.FACTORY_NAME AS FC_TYPE  '
                    +' from SAJET.SYS_FACTORY A,SAJET.G_WO_BASE B  '
                    +' WHERE B.WORK_ORDER='''+lvCSN.Items[0].SubItems[1] +''' AND A.FACTORY_ID=B.FACTORY_ID AND ROWNUM=1  ' ;

         Open;
         IF NOT ISEMPTY THEN
            lblfctype.Caption  :=FIELDBYNAME('fc_type').AsString ;
   end;
       

   editBoxNo.SetFocus;


end;

Procedure TfRepacking.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'Packing';
      Params.ParamByName('FUN').AsString := 'Repacking/Pallet';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
       iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end; 

  //sbtnClosePallet.Enabled := (iPrivilege >=1);
  //sbtnNewPallet.Enabled := sbtnClosePallet.Enabled;
end;

procedure TfRepacking.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80,100);
    800: self.ScaleBy(100,100);
    1024: self.ScaleBy(125,100);
  else
    self.ScaleBy(100,100);
  end;

  //If not GetCfgData Then Exit;      // 讀取 Option 值

  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;
 
end;

Function TfRePacking.GetCfgData : Boolean;
begin
  Result := False;
  With QryTemp do
  begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString	,'MODULE_NAME', ptInput);
     Params.CreateParam(ftString	,'FUNCTION_NAME', ptInput);
     Params.CreateParam(ftString	,'TERMINALID', ptInput);
     CommandText := 'Select * '+
                    'From SAJET.SYS_MODULE_PARAM '+
                    'Where MODULE_NAME = :MODULE_NAME and '+
                          'FUNCTION_NAME = :FUNCTION_NAME and '+
                          'PARAME_NAME = :TERMINALID ';
     Params.ParamByName('MODULE_NAME').AsString := 'PACKING';
     Params.ParamByName('FUNCTION_NAME').AsString := 'Work Station Configuration';
     Params.ParamByName('TERMINALID').AsString := TerminalID;
     Open;
     If RecordCount <= 0 Then
     begin
        Close;
        MessageDlg('Configuration not Exist !!',mtError, [mbCancel],0);
        Exit;
     end;

     While not Eof do
     begin
        {//Customer SN
        If Fieldbyname('PARAME_ITEM').AsString = 'Customer SN' Then
           //AutoCreateCSN := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
           CreateCSNType := Fieldbyname('PARAME_VALUE').AsString;
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label' Then
           PrintCSNLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Method' Then
           PrintCSNMethod := Fieldbyname('PARAME_VALUE').AsString;
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Customer SN Label Qty' Then
           PrintCSNLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString,1);}

        //Carton
        //If Fieldbyname('PARAME_ITEM').AsString = 'Carton No' Then
           //AutoCreateCarton := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label' Then
           PrintCartonLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
        //If Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Method' Then
           //PrintCartonMethod := Fieldbyname('PARAME_VALUE').AsString;
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Carton No Label Qty' Then
           PrintCartonLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString,1);
        //If Fieldbyname('PARAME_ITEM').AsString = 'Link Customer Carton' Then
        //begin
           //LinkCustCarton := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
           //Label4.Enabled := LinkCustCarton;
           //editCustCarton.Enabled := LinkCustCarton;
        //end;

        //Pallet
        //If Fieldbyname('PARAME_ITEM').AsString = 'Pallet No' Then
           //AutoCreatePallet := (Fieldbyname('PARAME_VALUE').AsString = 'System Create');
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label' Then
           PrintPalletLabel := (Fieldbyname('PARAME_VALUE').AsString = 'Y');
        //If Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Method' Then
           //PrintPalletMethod := Fieldbyname('PARAME_VALUE').AsString;
        If Fieldbyname('PARAME_ITEM').AsString = 'Print Pallet No Label Qty' Then
           PrintPalletLabQty := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString,1);

        //If Fieldbyname('PARAME_ITEM').AsString = 'Packing Base' Then
           //PackingBase := Fieldbyname('PARAME_VALUE').AsString;
        If Fieldbyname('PARAME_ITEM').AsString = 'CodeSoft' Then
           CodesoftVersion := StrToIntDef(Fieldbyname('PARAME_VALUE').AsString,6);
        Next;
     end;

     //editCSN.Enabled       := (CreateCSNType = 'Input');//not AutoCreateCSN;
     //LabeditCSN.Enabled    := editCSN.Enabled;//not AutoCreateCSN;

     //editCarton.Enabled    := not AutoCreateCarton;

     //editPallet.Enabled    := not AutoCreatePallet;

     Close;
  end;
  Result := True;
end;

procedure TfRepacking.sbtnNewBoxClick(Sender: TObject);
begin
  // editReCartonNo.Text := getNewPallet;
   getCartonDetail;
end;

procedure TfRepacking.editBoxNoKeyPress(Sender: TObject; var Key: Char);
var sKey:Char;
begin
   if key<>#13 then
     exit;

   if editBoxNo.Text = '' then
     exit;

   IsBoxInStock :=False;
   if not bInputCarton then
   begin
     sKey:=#13;
     editReCartonNoKeyPress(self,sKey);
     if not bInputCarton then
       exit;
   end;

   Qrytemp.Close;
   Qrytemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'BoxNO',ptinput);
   QryTemp.CommandText :='select Count(*) BOX_COUNT from sajet.g_SN_STATUS where BOX_No=:BOXNO and WORK_FLAG=0 ';
   QryTemp.Params.ParamByName('BOXNO').AsString := editBoxNo.Text;
   QryTemp.Open;

   if QryTemp.IsEmpty then Exit;

   Box_Count :=  Qrytemp.FieldByName('BOX_COUNT').AsInteger;

   if CheckBox then
   begin
       addBox2Carton;
       getCartonDetail;
   end;
   editBoxNo.SetFocus;
   editBoxNo.SelectAll;

end;

procedure TfRepacking.lvCartonClick(Sender: TObject);
begin
   if lvCarton.Selected <> nil then
      showCSNofBox(lvCarton.Selected.Caption);
end;

procedure TfRepacking.sbtnClosePalletClick(Sender: TObject);
var sPrintData,sCarton: String;
begin
   if editReCartonNo.Text = '' Then
   begin
       ShowMessage('No Carton No. !!!');
       Exit;
   end;

   if lvCarton.Items.Count = 0 then Exit;
   if MessageDlg('Close Carton ?',mtConfirmation,[mbYES,mbNO],0) <> mrYes then
   begin
     exit;
   End;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT * FROM SAJET.G_PACK_Carton '
                   + ' WHERE Carton_NO = ''' + editReCartonNo.Text + ''' ';
      Open;
      if Eof then
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         Params.CreateParam(ftString,'MODEL',ptInput);
         Params.CreateParam(ftString,'CARTON',ptInput);
         Params.CreateParam(ftString,'USERID',ptInput);
         CommandText := 'INSERT INTO SAJET.G_PACK_Carton '
                      + ' (WORK_ORDER, MODEL_ID, Carton_NO, CLOSE_FLAG, CREATE_EMP_ID) '
                      + 'VALUES(:WO, :MODEL, :CARTON, ''Y'', :USERID) ';
         Params.ParamByName('WO').AsString := QryCartonData.FieldByName('Work_Order').AsString;
         Params.ParamByName('MODEL').AsString := QryCartonData.FieldByName('Model_ID').AsString;
         Params.ParamByName('CARTON').AsString := editReCartonNo.Text;
         Params.ParamByName('USERID').AsString := UpdateUserID;
         Execute;
      end
      else if FieldByName('Close_Flag').AsString <> 'Y' then
      begin
         Close;
         Params.Clear;
         CommandText := 'UPDATE SAJET.G_PACK_CARTON '
                      + '   SET CLOSE_FLAG = ''Y'' '
                      + ' WHERE CARTON_NO = ''' + editReCartonNo.Text + ''' ';
         Execute;
      end;
   end;

   {if PrintPalletLabel then
   begin
     if not fSubModel then
       sPrintData:=G_getPrintData(CodesoftVersion,1,G_sockConnection,'DspQryData',editReCartonNo.Text,PrintPalletLabQty)
     else
       sPrintData:=G_getPrintData(CodesoftVersion,11,G_sockConnection,'DspQryData',editReCartonNo.Text,PrintPalletLabQty);
      //G_onTransDataToApplication(@sPrintData[1],length(sPrintData),nil);
   end; }
   
   sCarton := editReCartonNo.Text;
   clearReCarton;
   ShowMessage('Pallet '+ sCarton + ' Close !!!');
end;

Procedure TfRepacking.clearReCarton;
begin
   editReCartonNo.Clear;
   lvCarton.Clear;
   lvCSN.Clear;
   lablQty2.Caption := '0';
   lablTotal.Caption := '0';
   lablfifocode.Caption :='0';
   lblfctype.Caption :='0';
   editBoxNo.Clear;
   editReCartonNo.SetFocus;
end;


function TfRepacking.CheckBox: Boolean;
Var
   sWO:String;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.SERIAL_NUMBER,A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER, A.MODEL_ID,'
                   + ' A.CARTON_NO, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,A.SHIPPING_ID, '
                   + ' B.PART_NO, C.PROCESS_NAME, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT, A.OUT_PDLINE_TIME,'
                   + ' decode(A.next_process,0,A.WIP_PROCESS,A.next_process) WIP_PROCESS  '
                   + ' FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B, '
                   + '       SAJET.SYS_PROCESS C '
                   + ' WHERE A.BOX_NO = ''' + editBoxNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID '
                   + '   AND A.PROCESS_ID = C.PROCESS_ID(+) ';
      Open;

      If RecordCount = 0 then
      begin
         MessageDlg('box No not found !!',mtError,[mbOK],0);
         Close;
         Exit;
      end else begin
         mWoOfBox:=FieldByName('Work_order').AsString ;
         mCartonofBox :=  FieldByName('CARTON_NO').AsString ;
         mProcessOfbox := FieldByName('WIP_PROCESS').AsString ;
         spartid :=  FieldByName('MODEL_ID').AsString ;
      end;


      while not Eof do
      begin
          //不能是判退品
          if (FieldByName('QC_RESULT').AsString='1') then
          begin
            MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                       'Had been Reject !!',mtError,[mbCancel],0);
            Close;
            Exit;
          end;

          if QryCartonData.RecordCount <> 0 then
          begin  //Model不同
             if QryCartonData.FieldByName('Model_ID').AsString <> FieldByName('Model_ID').AsString then
             begin
                MessageDlg('Part No Different !!'+#13#10
                       + FieldByName('PART_NO').AsString,mterror,[mbCancel],0);
                Close;
                Exit;
             end;

             if  mProcessOfCarton <> mProcessofbox then
             begin
                MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10+
                              'Process Different !!',mtError,[mbCancel],0);
                Close;
                Exit;
             end;

             if QryCartonData.FieldByName('Out_PDLine_Time').IsNull then
             begin
                if  mProcessOfCarton <> mProcessofbox then
                begin
                   MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10+
                              'Process Different !!',mtError,[mbCancel],0);
                   Close;
                   Exit;
                end;
             end
             else
             begin
                if (FieldByName('Out_PDLine_Time').IsNull) then
                begin
                   MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                              'Output Status Different !!',mtError,[mbCancel],0);
                   Close;
                   Exit;
                end;
             end;

             if QryCartonData.FieldByName('QC_Result').AsString <> FieldByName('QC_Result').AsString then
             begin
                MessageDlg('Customer SN - '+FieldByName('Customer_SN').AsString + #13#10 +
                           'QC Status Different !!',mtError,[mbCancel],0);
                Close;
                Exit;
             end;

          end;

           //不良品
           if FieldByName('Current_Status').AsString <> '0' then
           begin
              MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                         'Have to Repair !!',mtError,[mbCancel],0);
              Close;
              Exit;
           end;
           //報廢品
           if FieldByName('Work_Flag').AsString <> '0' then
           begin
              MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#10 +
                         'Had been Scrap or Hold!!',mtError,[mbCancel],0);
              Close;
              Exit;
           end;

           //已出貨
           if FieldByName('Shipping_ID').AsString <> '0' Then
           begin
              MessageDlg( editBoxNo.Text + #13#10 +
                         'Shippinged !!',mtError,[mbCancel],0);
              Close;
              Exit;
           end;

           Next;
      end;
      Close;
   end;


    with qrymaterial do
    begin
         close;
         params.Clear ;
         CommandText := 'SELECT NVL(WAREHOUSE_ID,''0'') AS WAREHOUSE_ID ,NVL(LOCATE_ID,''0'') LOCATE_ID,nvl(FIFOCODE,0) FIFOCODE,'
                 +'  FACTORY_ID,FACTORY_TYPE,status,version,dateCode  from SAJET.G_MATERIAL WHERE MATERIAL_NO= ''' + mCartonOfBox + '''  AND ROWNUM=1';
         Open;

         if (not IsEmpty) then begin
           
              IsBoxInStock :=True;
              sfactoryid :=fieldbyname('FACTORY_ID').AsString ;
              sfifo :=fieldbyname('FIFOCODE').AsString ;
              sfactorytype:=fieldbyname('FACTORY_TYPE').AsString ;
              swarehouse :=fieldbyname('warehouse_id').AsString ;
              slocate:=fieldbyname('LOCATE_ID').AsString ;
              sStatus := fieldbyName('STATUS').AsString;
              sVersion := fieldbyName('version').AsString;
              sDateCode :=  fieldbyName('DateCode').AsString;
              if not CheckMaterialInfo then Exit;

         end
         else  begin
             IsBoxInStock :=False;
         end;
            
    end;

    IsInRepackTemp :=False;
    with QryRepack do
    begin
         close;
         params.clear;
         commandtext:='select Count(*) BOX_QTY from  SAJET.G_SN_REPACK WHERE BOX_NO = '''+editBoxNo.Text+'''';
         Open;

         iBoxofRepackQty :=FieldbyName('BOX_QTY').AsInteger;
    end;

    if  iBoxofRepackQty>0 then
    begin
         IsInRepackTemp :=True;
         with QryRepack do
         begin
             close;
             params.clear;
             commandtext:='select * from  SAJET.G_SN_REPACK WHERE BOX_NO = '''+editBoxNo.Text+'''';
             Open;

             spartid := fieldbyName('PART_ID').AsString;
             sfactoryid := fieldbyName('FACTORY_ID').AsString;
             sfifo := fieldbyName('FIFOCODE').AsString;
             sfactorytype := fieldbyName('FACTORY_TYPE').AsString;
             swarehouse := fieldbyName('WAREHOUSE_ID').AsString;
             slocate := fieldbyName('LOCATE_ID').AsString;
             sStatus := fieldbyName('STATUS').AsString;
             sVersion := fieldbyName('version').AsString;
             sDateCode :=  fieldbyName('DateCode').AsString;
         end;

         if Box_Count<> iBoxofRepackQty then
         begin
            MessageDlg('repack sn qty <> box qty',mtError,[mbCancel],0);
            Exit;
         end;
    end
    else begin
        IsInRepackTemp :=False;
    end;

    if IsCartonInStock  then
    begin
          if IsInRepackTemp then
              if not CheckMaterialInfo then Exit 
          else begin
              MessageDlg('SN No Warehouse',mtError,[MBOK],0);
              Exit;
          end;
    end;
    Result := True;

end;

function TfRepacking.CheckMaterialInfo:Boolean;
begin
    Result :=false;

   if not QryCartonData.IsEmpty then
    begin
         // warehosue is different
         if Qryfifo.FieldByName('warehouse_id').AsString <> swarehouse  then
         begin
             MessageDlg('WareHouse is different!',mtError,[mbCancel],0);
             Close;
             Result :=false;
             Exit;
         end;
         //locate is differdent;
         if Qryfifo.FieldByName('locate_id').AsString<>slocate then
         begin
             MessageDlg('Locate is different!',mtError,[mbCancel],0);
             Close;
             Result :=false;
             Exit;
         end;

         with QryTemp do
         begin
             close;
             params.Clear ;
             CommandText := ' SELECT A.FACTORY_ID,A.FACTORY_CODE||''-''||A.FACTORY_NAME AS FC_TYPE  '
                        +' from SAJET.SYS_FACTORY A,SAJET.G_WO_BASE B  '
                        +' WHERE B.WORK_ORDER='''+mWOOfBox+''' AND A.FACTORY_ID=B.FACTORY_ID AND ROWNUM=1  ' ;
             Open;
             IF QryFCTYPE.FieldByName('factory_id').AsString<>fieldbyname('factory_id').AsString Then
             begin
                   MessageDlg('ORG is different!',mtError,[mbCancel],0);
                   Close;
                   Result :=false;
                   Exit;
             end;
         end;

        // get min(fifocode)  of instock
         if  Qryfifo.FieldByName('warehouse_id').AsString<>'0' then
         begin
            if Qryfifo.IsEmpty then
                mFifoOfBox := '0'
            else
                mFifoOfBox := Qryfifo.fieldbyname('FIFOCODE').AsString ;

            if  mFifoOfCarton > mFifoOfBox then
            begin
                lablfifocode.Caption :=  mFifoOfBox;
            end else if mFifoOfCarton ='0' then
            begin
                lablfifocode.Caption :=  mFifoOfBox;
            end;
         end;
          Result :=True;
   end else
       Result :=True;
end;

procedure TfRepacking.editReCartonNoKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key <> #13) then
     exit;
   editReCartonNo.Text := Trim( editReCartonNo.Text );
   mCarton :=editReCartonNO.Text;
   mPalletOfCarton := 'N/A';
   if (editReCartonNo.Text = '') then
     exit;
   if trim(editReCartonNo.Text) = 'N/A' then
   begin
     MessageDlg('Carton Error',mtError,[mbCancel],0);
     editReCartonNo.SetFocus;
     editReCartonNo.SelectAll;
     exit;
   end;

   IsCartonInStock :=False;
   IsBoxInStock :=False;
   IsInRepackTemp :=False;

   IF Not CheckCarton Then
   begin
     editReCartonNo.SetFocus;
     editReCartonNo.SelectAll;
     Exit;
   end;

   getCartonDetail;
   editBoxNo.SetFocus;
   bInputCarton:=True;
end;

procedure TfRepacking.editReCartonNoChange(Sender: TObject);
begin
  bInputCarton:=False;
end;

end.
