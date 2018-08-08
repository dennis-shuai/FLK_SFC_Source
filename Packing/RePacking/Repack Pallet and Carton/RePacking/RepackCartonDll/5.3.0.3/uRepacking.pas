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
    QryCartonData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    DataSource1: TDataSource;
    Label3: TLabel;
    editReCartonNo: TEdit;
    Label5: TLabel;
    editCSN: TEdit;
    sbtnNewCarton: TSpeedButton;
    Label19: TLabel;
    lablQty: TLabel;
    Image3: TImage;
    sbtnCloseCarton: TSpeedButton;
    lvCSNDetail: TListView;
    QryFIFO: TClientDataSet;
    QryMaterial: TClientDataSet;
    Label1: TLabel;
    Lablfifocode: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnNewCartonClick(Sender: TObject);
    procedure sbtnCloseCartonClick(Sender: TObject);
    procedure editReCartonNoChange(Sender: TObject);
    procedure editReCartonNoKeyPress(Sender: TObject; var Key: Char);
  private
    mPalletOfCarton: String;
    TerminalID: String;
    PrintCartonLabel, PrintPalletLabel: Boolean;
    PrintCartonLabQty,
    PrintPalletLabQty,
    CodeSoftVersion: Integer;
    procedure getCSNDetail;
    function  checkCSN:Boolean;
    procedure addCSN2Carton;
    function  getNewCarton:String;
    function  CheckCarton:Boolean;
    procedure clearReCarton;
    function  getCfgData:Boolean;
  public
    { Public declarations }
    UpdateUserID : String;
    G_PARTNO : String;
    Authoritys,AuthorityRole : String;
    bInputCarton:Boolean;
    g_sn:string;
    Procedure SetStatusbyAuthority;
  end;

var
  fRepacking: TfRepacking;
  fSubModel : Boolean;
  SOldCarton: string;
implementation

{$R *.DFM}

uses uDllform,Dllinit;

function TfRepacking.checkCarton:Boolean;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER, A.MODEL_ID, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,SHIPPING_ID, '
                   + '       B.PART_NO, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B '
                   + ' WHERE A.CARTON_NO = ''' + editReCartonNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID ';
      Open;
      If RecordCount = 0 then
      begin
         //MessageDlg('Carton No not found !!',mtError,[mbOK],0);
         Result := True;
         G_PARTNO:='';
         Close;
         Exit;
      end;
      
      while not Eof do
      begin
        //����O�P�h�~
        if (FieldByName('QC_RESULT').AsString='1') then
        begin
          MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                     'Had been Reject !!',mtError,[mbCancel],0);
          Close;
          Exit;
        end;

         //���}�~
         {if FieldByName('Current_Status').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#13#10 +
                       'Have to Repair !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         //���o�~
         else if FieldByName('Work_Flag').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#13#10 +
                       'Had been Scrap !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         //�w�X�f
         else if FieldByName('Shipping_ID').AsString <> '0' Then
         begin
               MessageDlg( editReCartonNo.Text +
                           #13#13#10+
                          'Shippinged !!',mtError,[mbCancel],0);
               Close;
               Exit;
         end
         else if FieldByName('QC_RESULT').AsString <> '0' Then
         begin
               MessageDlg('Customer SN - '+FieldByName('Customer_SN').AsString +
                           #13#13#10+
                          'QC Result Error !!',mtError,[mbCancel],0);
               Close;
               Exit;
         end
         else If FieldByName('QC_No').AsString = 'N/A' Then
         begin 
               MessageDlg('Customer SN - '+FieldByName('Customer_SN').AsString +
                          ' ('+FieldByName('QC_No').AsString+') ' + #13#13#10+
                          'QC Lot No Error !!',mtError,[mbCancel],0);
               Close;
               Exit;
         end;  }
         Next;
      end;
      G_PARTNO := FieldByName('Part_No').AsString;
      Close;
   end;

   //check is instock by key for fifo
   with qryfifo do
     begin
         close;
         params.Clear ;
         commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode '
                    +' from sajet.g_material where material_no=  ''' + editReCartonNo.Text + ''' and rownum=1 ' ;
         open;


         IF NOT ISEMPTY  THEN
            lablfifocode.Caption :=fieldbyname('fifocode').AsString
         else
            lablfifocode.Caption :='0';
     end;



   Result := True;
end;

function TfRepacking.getNewCarton:String;
var iSeq:Integer;
    sNew : String;
begin
   {sNew := '';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT NVL(MAX(CARTON_NO),''CX''||TO_CHAR(SYSDATE,''YYYYMMDD'')||''0000'') NEWCARTON '
                   + '  FROM SAJET.G_PACK_CARTON '
                   + ' WHERE SUBSTR(CARTON_NO,1,10) = ''CX''||TO_CHAR(SYSDATE,''YYYYMMDD'') ';
      Open;
      iSeq := StrToInt(Copy(FieldByName('NewCarton').AsString,11,4))+1;
      sNew := Copy(FieldByName('NewCarton').AsString,1,10) + FormatFloat('0000',iSeq);
      Close;
   end;
   //Check �O�_�s�b�btemp table �N���b�]���|���s��G_PACK_PALLET

   While not CheckCartonTemp(sNew) do
   begin
      iSeq := StrToInt(Copy(sNew,11,4))+1;
      sNew := Copy(sNew,1,10) + FormatFloat('0000',iSeq);
   end;
   with QryTemp do
   begin
        Close;
        Params.Clear;
        //Params.CreateParam(ftString,'WO',ptInput);
        //Params.CreateParam(ftString,'MODEL',ptInput);
        Params.CreateParam(ftString,'CARTON',ptInput);
        Params.CreateParam(ftString,'USERID',ptInput);
        CommandText := 'INSERT INTO SAJET.G_PACK_PARAM '
                     + ' (Temp_no,update_date, update_userID) '
                     + ' VALUES (:CARTON, sysdate, :USERID) ';
        //Params.ParamByName('WO').AsString := 'N/A';
        //Params.ParamByName('MODEL').AsString := '0';
        Params.ParamByName('Carton').AsString := sNew;
        Params.ParamByName('UserId').AsString := UpdateUserID;
        Execute;
        Close;
   end;
   Result := sNew; }
end;

procedure TfRepacking.addCSN2Carton;
begin
   //update g_sn_status
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'UPDATE SAJET.G_SN_STATUS '
                   + '   SET CARTON_NO = ''' + editReCartonNo.Text + ''' '
                   + '      ,PALLET_NO = ''' + mPalletOfCarton + ''' '
                   + ' WHERE SERIAL_NUMBER = ''' + g_sn + ''' ';
      Execute;
      Close;
   end;

   //update g_material for fifocode by key
   if ((lablfifocode.Caption<>'0' ) or ((lablfifocode.Caption='0' )and qrycartondata.IsEmpty ))
     and (editReCartonNo.Text<>soldcarton ) then
      with qrymaterial do
        begin
           //check new carton is in g_material
           close;
           params.Clear ;
           commandtext:='select material_no from sajet.g_material '
                      +' where material_no= ''' +  editReCartonNo.Text + ''' and rownum=1 ';
           open;
           if isempty then
              begin
                 close;
                 params.Clear;
                 commandtext:=' insert into sajet.g_material  '
                          +'(part_id,material_no,material_qty,status,locate_id,warehouse_id,update_userid,update_time,version,type,fifocode) '
                          +' SELECT part_id,''' +  editReCartonNo.Text + ''',''1'',status,locate_id,warehouse_id,'''+UpdateUserID+''',SYSDATE,version,type,fifocode '
                          +' FROM SAJET.G_MATERIAL WHERE MATERIAL_NO=''' + soldcarton + ''' AND ROWNUM=1 ';
                 EXECUTE;
                 
                 close;
                 params.Clear ;
                 commandtext:='insert into sajet.g_ht_material '
                        +' (select * from sajet.g_material where material_no= ''' + editReCartonNo.Text + ''' and rownum=1 )';
                 execute;

                 close;
                 params.Clear ;
                 commandtext:='select fifocode from sajet.g_material '
                      +' where material_no= ''' + editReCartonNo.Text + ''' and rownum=1 ';
                 open;

                 lablfifocode.Caption:=fieldbyname('fifocode').AsString ;

              end
           else
             begin
                 //  update new carton
                 close;
                 params.Clear ;
                 commandtext:='update sajet.g_material  '
                         +'  set material_qty=material_qty+1, update_userid='''+UpdateUserID+''',update_time=sysdate,fifocode='''+lablfifocode.Caption+''' '
                         +' where material_no= ''' + editReCartonNo.Text + ''' and rownum=1 ';
                 execute;

                 close;
                 params.Clear ;
                 commandtext:='insert into sajet.g_ht_material '
                        +' (select * from sajet.g_material where material_no= ''' + editReCartonNo.Text + ''' and rownum=1 )';
                  execute;
               end ;



           //update old carton
           close;
           params.Clear ;
           commandtext:='update sajet.g_material  '
                   +'  set material_qty=material_qty-1, update_userid='''+UpdateUserID+''',update_time=sysdate '
                   +' where material_no= ''' + soldcarton + ''' and rownum=1 ';
           execute;

           close;
           params.Clear ;
           commandtext:='insert into sajet.g_ht_material '
                      +' (select * from sajet.g_material where material_no= ''' + soldcarton + ''' and rownum=1 )';
           execute;

           //chech material_qty=0 for old carton_no
           close;
           params.Clear ;
           commandtext:='select material_qty from sajet.g_material '
                      +' where material_no= ''' + soldcarton + ''' and rownum=1 ';
           open;

           if fieldbyname('material_qty').AsInteger <=0 then
              begin
                // close;
                // params.Clear ;
                // commandtext:='insert into sajet.g_ht_material '
                 //     +' (select * from sajet.g_material where material_no= ''' + soldcarton + ''' and rownum=1 )';
                 //execute;

                 close;
                 params.Clear ;
                 commandtext:='delete  sajet.g_material '
                         +' where material_no= ''' + soldcarton + ''' and rownum=1 ';
                 execute;
              end;

        end;
   
end;

function  TfRepacking.checkCSN:Boolean;
begin
   Result := False;
   g_sn:='';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.Serial_NUmber,A.CURRENT_STATUS, A.WORK_FLAG, A.Shipping_ID,A.WORK_ORDER, A.MODEL_ID, '
                   + ' A.QC_NO, A.QC_RESULT, A.CARTON_NO ,B.PART_NO '
                   + 'FROM SAJET.G_SN_STATUS A , SAJET.SYS_PART B '
                   + 'WHERE A.CUSTOMER_SN = ''' + editCSN.Text + ''' '
                   + 'AND A.MODEL_ID = B.PART_ID(+) ';
      Open;
      if IsEmpty then
      begin
         Close;
         Params.Clear;
         CommandText := 'SELECT A.Serial_NUmber,A.CURRENT_STATUS, A.WORK_FLAG, A.Shipping_ID,A.WORK_ORDER, A.MODEL_ID, '
                      + ' A.QC_NO, A.QC_RESULT, A.CARTON_NO ,B.PART_NO '
                      + 'FROM SAJET.G_SN_STATUS A , SAJET.SYS_PART B '
                      + 'WHERE A.SERIAL_NUMBER = ''' + editCSN.Text + ''' '
                      + 'AND A.MODEL_ID = B.PART_ID(+) ';
         Open;
         if IsEmpty then
         begin
           MessageDlg('Customer SN not exist !!',mtError,[mbCancel],0);
           Close;
           Exit;
         end;  
      end;
      g_sn:=FieldByName('Serial_NUmber').asstring;

    {  if FieldByName('Current_Status').AsString <> '0' then
      begin
         MessageDlg('Customer SN have to Repair !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;
      if FieldByName('Work_Flag').AsString <> '0' then
      begin
         MessageDlg('Customer SN had been Scrap !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;
      if FieldByName('QC_NO').AsString = 'N/A' then
      begin
         MessageDlg('Not pass QC !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;  }
      //��h�~
      if FieldByName('QC_Result').AsString = '1' then
      begin
         MessageDlg('QC Reject !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;
      //�Ƹ��PCarton�����P
      if (G_PARTNO <> '') and (FieldByName('PART_NO').AsString <> G_PARTNO) THEN
      begin
          MessageDlg('Part No Different - '+FieldByName('PART_NO').AsString+' !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;

    {  if FieldByName('Shipping_ID').AsString <> '0' Then
      begin
          MessageDlg('Customer SN Shippinged !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;
       }

     { if QryCartonData.RecordCount <> 0 then
      begin
         if QryCartonData.FieldByName('Model_ID').AsString <> FieldByName('Model_ID').AsString then
         begin
            MessageDlg('Customer SN Model not Match !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         else if (QryCartonData.FieldByName('QC_NO').AsString = 'N/A') and
                 (FieldByName('QC_No').AsString <> 'N/A') then
         begin
            MessageDlg('Customer SN QC Lot No not Match !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         else if QryCartonData.FieldByName('QC_Result').AsString <> FieldByName('QC_Result').AsString then
         begin
            MessageDlg('Customer SN QC Result not Match !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end;
      end; }

       SOldcarton:= Qrytemp.fieldbyname('carton_no').AsString;
       with qrymaterial do
         begin
            close;
            params.Clear ;
            commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode  '
                    +' from sajet.g_material where material_no=  ''' + SOldcarton  + ''' and rownum=1 ' ;
            open;

            if not qrycartondata.IsEmpty  then
              begin  //chech warehouse
                  if qryfifo.FieldByName('warehouse_id').AsString <>fieldbyname('warehouse_id').AsString then
                     begin
                         MessageDlg('Warehouse is different!',mtError,[mbCancel],0);
                         Close;
                         Exit;
                     end;
                  //check locate
                  if qryfifo.FieldByName('locate_id').AsString <>fieldbyname('locate_id').AsString then
                     begin
                         MessageDlg('locate is different!',mtError,[mbCancel],0);
                         Close;
                         Exit;
                     end;
                  //check fifocode
                  if (NOT ISEMPTY ) AND (fieldbyname('fifocode').AsString < lablfifocode.Caption)then
                      lablfifocode.Caption:= fieldbyname('fifocode').AsString ;
              end;

       end;


      Close;
   end;
   Result := True;
end;

procedure TfRepacking.getCSNDetail;
begin
   lvCSNDetail.Items.Clear;
   mPalletOfCarton := 'N/A';
   with QryCartonData do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.WORK_ORDER, B.PART_NO, C.PROCESS_NAME, A.MODEL_ID, A.PROCESS_ID, '
                   + '       A.PALLET_NO, A.QC_NO, A.QC_RESULT,A.SERIAL_NUMBER '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B, '
                   + '       SAJET.SYS_PROCESS C '
                   + ' WHERE A.CARTON_NO = ''' + editReCartonNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID '
                   + '   AND A.PROCESS_ID = C.PROCESS_ID '
                   + ' ORDER BY A.CUSTOMER_SN ';
      Open;
      while not Eof do
      begin
         mPalletOfCarton := FieldByName('Pallet_No').AsString;
         with lvCSNDetail.Items.Add do
         begin
            Caption := FieldByName('Customer_SN').AsString;
            SubItems.Add(FieldByName('SERIAL_NUMBER').AsString);
            SubItems.Add(FieldByName('Work_Order').AsString);
            SubItems.Add(FieldByName('Part_No').AsString);
         end;
         Next;
      end;
      lablQty.Caption := IntToStr(RecordCount);
   end;
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
      Params.ParamByName('FUN').AsString := 'Repacking/Carton';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
       iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end; 

  sbtnCloseCarton.Enabled := (iPrivilege >=1);
  sbtnNewCarton.Enabled := sbtnCloseCarton.Enabled;
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

  //If not GetCfgData Then Exit;      // Ū�� Option ��

  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editReCartonNo.Setfocus;
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

procedure TfRepacking.editCSNKeyPress(Sender: TObject; var Key: Char);
var sKey:Char;
begin
   if key <> #13 then
     exit;
     
   if (editReCartonNo.Text = '') then
   begin
     MessageDlg('Carton No is null',mtError,[mbCancel],0);
     editReCartonNo.SetFocus;
     editReCartonNo.SelectAll;
     exit;
   end;
   if (editCSN.Text = '') then
   begin
     MessageDlg('Customer SN is null',mtError,[mbCancel],0);
     editCSN.SetFocus;
     editCSN.SelectAll;
     exit;
   end;

   If not bInputCarton then
   begin
     sKey:=#13;
     editReCartonNoKeyPress(self,sKey);
     if not bInputCarton then
       exit;
   end;

   if checkCSN then
   begin
     addCSN2Carton;
     getCSNDetail;
   end;
   editCSN.SetFocus;
   editCSN.SelectAll;

end;

procedure TfRepacking.sbtnNewCartonClick(Sender: TObject);
begin
//   editReCartonNo.Text := getNewCarton;
end;

procedure TfRepacking.sbtnCloseCartonClick(Sender: TObject);
var
   sPrintData,sCarton: String;
begin
   If editReCartonNo.Text = '' then
   begin
     ShowMessage('No Carton No. !!!');
     editReCartonNo.Setfocus;
     Exit;
   end;
   if lvCSNDetail.Items.Count = 0 then Exit;

    if MessageDlg('Close Carton ?',mtConfirmation,[mbYES,mbNO],0) <> mrYes then
    begin
       exit;
    End;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT * FROM SAJET.G_PACK_CARTON '
                   + ' WHERE CARTON_NO = ''' + editReCartonNo.Text + ''' ';
      Open;
      if Eof then
      begin
         //Insert
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         Params.CreateParam(ftString,'MODEL',ptInput);
         Params.CreateParam(ftString,'CARTON',ptInput);
         Params.CreateParam(ftString,'USERID',ptInput);
         CommandText := 'INSERT INTO SAJET.G_PACK_CARTON '
                      + ' (WORK_ORDER, MODEL_ID, CARTON_NO, CLOSE_FLAG, CREATE_EMP_ID) '
                      + ' VALUES (:WO, :MODEL, :CARTON, ''Y'', :USERID) ';
         Params.ParamByName('WO').AsString := QryCartonData.FieldByName('Work_Order').AsString;
         Params.ParamByName('MODEL').AsString := QryCartonData.FieldByName('Model_ID').AsString;
         Params.ParamByName('Carton').AsString := editReCartonNo.Text;
         Params.ParamByName('UserId').AsString := UpdateUserID;
         Execute;
      end
      else if FieldByName('Close_Flag').AsString <> 'Y' then
      begin
         //Update Close Flag
         Close;
         Params.Clear;
         CommandText := 'UPDATE SAJET.G_PACK_CARTON '
                      + '   SET CLOSE_FLAG = ''Y'' '
                      + ' WHERE CARTON_NO = ''' + editReCartonNo.Text + ''' ';
         Execute;
      end;
   end;

   {if PrintCartonLabel then begin
     if not fSubModel then
       sPrintData:=G_getPrintData(CodesoftVersion,2,G_sockConnection,'DspQryData',editReCartonNo.Text,PrintCartonLabQty)
     else
       sPrintData:=G_getPrintData(CodesoftVersion,12,G_sockConnection,'DspQryData',editReCartonNo.Text,PrintCartonLabQty);
   end; }
   sCarton := '';
   sCarton := editReCartonNo.Text;

   clearReCarton;
   ShowMessage('Carton '+ sCarton +' Close !!');
end;

Procedure TfRepacking.clearReCarton;
begin
   editReCartonNo.Clear;
   lvCSNDetail.Clear;
   editCSN.Clear;
   lablQty.Caption := '0';
   editReCartonNo.SetFocus;
   G_PARTNO := '';
   lablfifocode.Caption :='0';
end;

procedure TfRepacking.editReCartonNoChange(Sender: TObject);
begin
    lvCSNDetail.Items.Clear;
    G_PARTNO := '';
    editCSN.Clear;
    bInputCarton:=False;
    lablqty.Caption:='0';
    lablfifocode.Caption:='0'; 
end;

procedure TfRepacking.editReCartonNoKeyPress(Sender: TObject;
  var Key: Char);
begin
   IF Key <> #13 Then
      Exit;

   if (editReCartonNo.Text = '') then
     Exit;   
   if trim(editReCartonNo.Text) = 'N/A' then
   begin
     MessageDlg('Carton Error',mtError,[mbCancel],0);
     editReCartonNo.SetFocus;
     editReCartonNo.SelectAll;
     Exit;
   end;
   
   IF Not CheckCarton Then
   begin
     editReCartonNo.SetFocus;
     editReCartonNo.SelectAll;
     Exit;
   end;
   getCSNDetail;
   editCSN.SetFocus;
   bInputCarton:=True;
end;

end.
