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
    editReBoxNo: TEdit;
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
    Label2: TLabel;
    LabLORG: TLabel;
    Qryfctype: TClientDataSet;
    qrywip: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnNewCartonClick(Sender: TObject);
    procedure sbtnCloseCartonClick(Sender: TObject);
    procedure editReBoxNoChange(Sender: TObject);
    procedure editReBoxNoKeyPress(Sender: TObject; var Key: Char);
  private
    mPalletOfCSN,mCartonOfCSN,sOldCarton,sOldPallet,mProcessOfBox,sOldProcess: String;
    TerminalID: String;
    PrintCartonLabel, PrintPalletLabel: Boolean;
    PrintCartonLabQty,
    PrintPalletLabQty,
    CodeSoftVersion: Integer;
    procedure getCSNDetail;
    function  checkCSN:Boolean;
    procedure AddCSN2Box;
    function  getNewCarton:String;
    function  CheckBox:Boolean;
    procedure clearReBox;
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

implementation

{$R *.DFM}

uses uDllform,Dllinit;

function TfRepacking.CheckBox:Boolean;
Var swo:string;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.SERIAL_NUMBER,A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER,A.Pallet_NO, '
                   + ' A.MODEL_ID,A.Carton_no, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,SHIPPING_ID,A.WIP_PROCESS, '
                   + '       B.PART_NO, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B '
                   + ' WHERE A.BOX_NO = ''' + editReBoxNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID ';
      Open;
      If RecordCount = 0 then
      begin
         //MessageDlg('Carton No not found !!',mtError,[mbOK],0);
         mCartonOfCSN :='N/A';
         mPalletOfCSN :='N/A';
         Result := True;
         G_PARTNO:='';
         Close;
         Exit;
      end
      else begin
          swo:=fieldbyname('work_order').AsString;
          mCartonOfCSN := fieldbyname('Carton_no').AsString;
          mProcessOfBox := fieldbyname('WIP_PROCESS').AsString;
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

         //不良品
         if FieldByName('Current_Status').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#13#10 +
                       'Have to Repair !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         //報廢品
         else if FieldByName('Work_Flag').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('SERIAL_NUMBER').AsString + #13#13#10 +
                       'Had been Scrap !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end
         //已出貨
         else if FieldByName('Shipping_ID').AsString <> '0' Then
         begin
               MessageDlg( editReBoxNo.Text +
                           #13#13#10+
                          'Shippinged !!',mtError,[mbCancel],0);
               Close;
               Exit;
         end ;
         {
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

   //check in instock by key for fifo
   with qryfifo do
     begin
         close;
         params.Clear ;
         commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode '
                    +' from sajet.g_material where material_no=  ''' + mCartonOfCSN + ''' and rownum=1 ' ;
         open;


         IF NOT ISEMPTY  THEN
            lablfifocode.Caption :=fieldbyname('fifocode').AsString
         else
            lablfifocode.Caption :='0';
     end;

   //get org by work_order's org
   with qryfctype do
   begin
       Close;
       Params.Clear;
       CommandText := 'SELECT a.factory_id,a.factory_code||''-''||a.factory_name as fc_type '
                     +' from sajet.sys_factory a,sajet.g_wo_base b where b.work_order='''+swo+''' and a.factory_id=b.factory_id ';
       open;
       if not isempty then
          lablorg.Caption :=fieldbyname('fc_type').AsString
       else
          lablorg.Caption :='0';

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
   //Check 是否存在在temp table 代表正在包但尚未存到G_PACK_PALLET

   While not CheckBoxTemp(sNew) do
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

procedure TfRepacking.AddCSN2Box;
begin

   if QryFIFO.IsEmpty  then
   begin
        if not QryMaterial.IsEmpty then begin
             if lablQty.Caption <>'0' then begin
                MessageDlg('BOX Need A New Number',mtError,mbOKCancel,0);
                Exit;
             end;
        end;
        mCartonOfCSN := sOldCarton;
        mPalletOfCSN := sOldPallet;
   end else
   begin
       if QryMaterial.IsEmpty then begin
           Exit;
       end else
       begin
            if sOldCarton <> mCartonOfCSN then
            begin
                 with QryTemp do
                 begin
                      close;
                      params.Clear ;
                      commandtext:='Update  sajet.g_material set material_qty =material_qty-1 where '
                            +'  material_no= ''' + soldcarton + ''' and rownum=1 ';
                      execute;

                      close;
                      params.Clear ;
                      commandtext:='insert into sajet.g_ht_material '
                            +' (select * from sajet.g_material where material_no= ''' + soldcarton + ''' and rownum=1 )';
                      execute;

                      close;
                      params.Clear ;
                      commandtext:='Update  sajet.g_material set material_qty =material_qty+1,fifocode = '''+lablfifocode.Caption+''' where '
                            +'  material_no= ''' + mCartonOfCSN + ''' and rownum=1 ';
                      execute;

                      close;
                      params.Clear ;
                      commandtext:='insert into sajet.g_ht_material '
                            +' (select * from sajet.g_material where material_no= ''' + mCartonOfCSN + ''' and rownum=1 )';
                      execute;

                 end;
            end;
       end;
   end;


   //update g_sn_status
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'UPDATE SAJET.G_SN_STATUS '
                   + '   SET BOX_NO = ''' + editReBoxNo.Text + ''',CARTON_NO = '''+ mCartonOfCSN + ''',Pallet_No ='''+mPalletofCSN +''''
                   + ' WHERE SERIAL_NUMBER = ''' + g_sn + ''' ';
      Execute;
      Close;
   end;
   bInputCarton:=False;

end;

function  TfRepacking.checkCSN:Boolean;
var swo:string;
var sfcid:string;
begin
   Result := False;
   g_sn:='';
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.Serial_NUmber,A.CURRENT_STATUS, A.WORK_FLAG, A.WIP_PROCESS,A.Shipping_ID,A.WORK_ORDER, A.MODEL_ID, '
                   + 'A.QC_NO, A.QC_RESULT, A.CARTON_NO ,A.Pallet_NO,B.PART_NO,A.WIP_PROCESS '
                   + ' FROM SAJET.G_SN_STATUS A , SAJET.SYS_PART B '
                   + 'WHERE A.CUSTOMER_SN = ''' + editCSN.Text + ''' '
                   + 'AND A.MODEL_ID = B.PART_ID(+) ';
      Open;
      if IsEmpty then
      begin
         Close;
         Params.Clear;
         CommandText := 'SELECT A.Serial_NUmber,A.CURRENT_STATUS, A.WORK_FLAG, A.WIP_PROCESS, A.Shipping_ID,A.WORK_ORDER, A.MODEL_ID, '
                      + 'A.QC_NO, A.QC_RESULT, A.CARTON_NO ,A.Pallet_NO,B.PART_NO,A.WIP_PROCESS'
                      + ' FROM SAJET.G_SN_STATUS A , SAJET.SYS_PART B '
                      + 'WHERE A.SERIAL_NUMBER = ''' + editCSN.Text + ''' '
                      + ' AND A.MODEL_ID = B.PART_ID(+) ';
         Open;
         if IsEmpty then
         begin
           MessageDlg('Customer SN not exist !!',mtError,[mbCancel],0);
           Close;
           Exit;
         end;
      end;
      g_sn:=FieldByName('Serial_NUmber').asstring;
      swo:=FieldByName('work_order').asstring;
      sOldProcess:= FieldByName('WIP_PROCESS').asstring;
      sOldcarton:=  Qrytemp.fieldbyname('CARTON_NO').AsString;
      sOldPallet := Qrytemp.fieldbyname('CARTON_NO').AsString;

      if FieldByName('Current_Status').AsString <> '0' then
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

      //批退品
      if FieldByName('QC_Result').AsString = '1' then
      begin
         MessageDlg('QC Reject !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;
      //料號與Carton內不同
      if (G_PARTNO <> '') and (FieldByName('PART_NO').AsString <> G_PARTNO) THEN
      begin
          MessageDlg('Part No Different - '+FieldByName('PART_NO').AsString+' !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;

      if FieldByName('Shipping_ID').AsString <> '0' Then
      begin
          MessageDlg('Customer SN Shippinged !!',mtError,[mbCancel],0);
          Close;
          Exit;
      end;

      if lablQty.Caption <>'0' then begin
        if mProcessOfBox <> sOldProcess then
         begin
            MessageDlg('PROCESS Different!!',mtError,[mbCancel],0);
            Close;
            Exit;

         end;
      end;

   end;

    with qryfifo do
    begin
         close;
         params.Clear ;
         commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode,factory_id,factory_type '
                  +' from sajet.g_material where material_no=  ''' + mCartonOfCSN + ''' and rownum=1 ' ;
         open;
    end;


    if not qryfifo.IsEmpty then
    begin
        with qrymaterial do
        begin
              close;
              params.Clear ;
              commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode  '
                      +' from sajet.g_material where material_no=  ''' + sOldCarton  + ''' and rownum=1 ' ;
              open;
              if sOldCarton <> mCartonOfCSN then begin
                  if not IsEmpty then
                  begin
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
                  end else begin
                        MessageDlg('CSN NOT IN WAREHOUSE!',mtError,[mbCancel],0);
                        Close;
                        Exit;
                  end;
              end;
        end;
    end;

    Result := True;

end;

procedure TfRepacking.getCSNDetail;
begin
   lvCSNDetail.Items.Clear;
   mPalletOfCSN := 'N/A';
   with QryCartonData do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.WORK_ORDER, B.PART_NO, C.PROCESS_NAME, A.MODEL_ID, A.PROCESS_ID, '
                   + '       A.PALLET_NO,A.Carton_NO, A.QC_NO, A.QC_RESULT,A.SERIAL_NUMBER '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B, '
                   + '       SAJET.SYS_PROCESS C '
                   + ' WHERE A.BOX_NO = ''' + editReBoxNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID '
                   + '   AND A.PROCESS_ID = C.PROCESS_ID '
                   + ' ORDER BY A.CUSTOMER_SN ';
      Open;
      
      while not Eof do
      begin
         mCartonOfCSN :=    FieldByName('Carton_No').AsString;
         mPalletOfCSN := FieldByName('Pallet_No').AsString;
         with lvCSNDetail.Items.Add do
         begin
            Caption := FieldByName('Customer_SN').AsString;
            SubItems.Add(FieldByName('SERIAL_NUMBER').AsString);
            SubItems.Add(FieldByName('Work_Order').AsString);
            SubItems.Add(FieldByName('Part_No').AsString);
            SubItems.Add(FieldByName('Carton_No').AsString);
            SubItems.Add(FieldByName('Pallet_No').AsString);
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
  
  //If not GetCfgData Then Exit;      // 讀取 Option 值
  If UpdateUserID <> '0' Then
    SetStatusbyAuthority;

  editReBoxNo.Setfocus;
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
     
   if (editReBoxNo.Text = '') then
   begin
     MessageDlg('Box No is null',mtError,[mbCancel],0);
     editReBoxNo.SetFocus;
     editReBoxNo.SelectAll;
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
     editReBoxNoKeyPress(self,sKey);
     if not bInputCarton then
       exit;
   end;

   if checkCSN then
   begin
     addCSN2Box;
     getCSNDetail;
   end;
   editCSN.SetFocus;
   editCSN.SelectAll;

end;

procedure TfRepacking.sbtnNewCartonClick(Sender: TObject);
begin
//   editReBoxNo.Text := getNewCarton;
end;

procedure TfRepacking.sbtnCloseCartonClick(Sender: TObject);
var
   sPrintData,sBox: String;
begin
   If editReBoxNo.Text = '' then
   begin
     ShowMessage('No Box No. !!!');
     editReBoxNo.Setfocus;
     Exit;
   end;
   if lvCSNDetail.Items.Count = 0 then Exit;

    if MessageDlg('Close Box ?',mtConfirmation,[mbYES,mbNO],0) <> mrYes then
    begin
       exit;
    End;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT * FROM SAJET.G_PACK_BOX '
                   + ' WHERE BOX_NO = ''' + editReBoxNo.Text + ''' ';
      Open;
      if Eof then
      begin
         //Insert
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         Params.CreateParam(ftString,'MODEL',ptInput);
         Params.CreateParam(ftString,'BOX',ptInput);
         Params.CreateParam(ftString,'USERID',ptInput);
         CommandText := 'INSERT INTO SAJET.G_PACK_BOX '
                      + ' (WORK_ORDER, MODEL_ID, BOX_NO, CLOSE_FLAG, CREATE_EMP_ID) '
                      + ' VALUES (:WO, :MODEL, :BOX, ''Y'', :USERID) ';
         Params.ParamByName('WO').AsString := QryCartonData.FieldByName('Work_Order').AsString;
         Params.ParamByName('MODEL').AsString := QryCartonData.FieldByName('Model_ID').AsString;
         Params.ParamByName('BOX').AsString := editReBoxNo.Text;
         Params.ParamByName('UserId').AsString := UpdateUserID;
         Execute;
      end
      else if FieldByName('Close_Flag').AsString <> 'Y' then
      begin
         //Update Close Flag
         Close;
         Params.Clear;
         CommandText := 'UPDATE SAJET.G_PACK_BOX '
                      + '   SET CLOSE_FLAG = ''Y'' '
                      + ' WHERE BOX_NO = ''' + editReBoxNo.Text + ''' ';
         Execute;
      end;
   end;

   {if PrintCartonLabel then begin
     if not fSubModel then
       sPrintData:=G_getPrintData(CodesoftVersion,2,G_sockConnection,'DspQryData',editReBoxNo.Text,PrintCartonLabQty)
     else
       sPrintData:=G_getPrintData(CodesoftVersion,12,G_sockConnection,'DspQryData',editReBoxNo.Text,PrintCartonLabQty);
   end; }
   sBox := '';
   sBox := editReBoxNo.Text;

   clearReBox;
   ShowMessage('Box '+ sBox +' Close !!');
end;

Procedure TfRepacking.clearReBox;
begin
   editReBoxNo.Clear;
   lvCSNDetail.Clear;
   editCSN.Clear;
   lablQty.Caption := '0';
   editReBoxNo.SetFocus;
   G_PARTNO := '';
   lablfifocode.Caption :='0';
   lablorg.Caption :='0';
end;

procedure TfRepacking.editReBoxNoChange(Sender: TObject);
begin
    lvCSNDetail.Items.Clear;
    G_PARTNO := '';
    editCSN.Clear;
    bInputCarton:=False;
    lablqty.Caption:='0';
    lablfifocode.Caption:='0';
    lablorg.Caption :='0';
end;

procedure TfRepacking.editReBoxNoKeyPress(Sender: TObject;
  var Key: Char);
begin
   IF Key <> #13 Then
      Exit;

   if (editReBoxNo.Text = '') then
     Exit;   
   if trim(editReBoxNo.Text) = 'N/A' then
   begin
     MessageDlg('BOX Error',mtError,[mbCancel],0);
     editReBoxNo.SetFocus;
     editReBoxNo.SelectAll;
     Exit;
   end;
   
   IF Not CheckBox Then
   begin
     editReBoxNo.SetFocus;
     editReBoxNo.SelectAll;
     Exit;
   end;
   getCSNDetail;
   editCSN.SetFocus;
   bInputCarton:=True;
end;

end.
