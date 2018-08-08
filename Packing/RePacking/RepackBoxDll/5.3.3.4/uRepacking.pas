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
    QryBoxData: TClientDataSet;
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
    QryMaterialofBox: TClientDataSet;
    QryMaterialOfSN: TClientDataSet;
    Label1: TLabel;
    Lablfifocode: TLabel;
    Label2: TLabel;
    LabLORG: TLabel;
    Qryfctype: TClientDataSet;
    lbl1: TLabel;
    QryBoxRepack: TClientDataSet;
    QryCSNRepack: TClientDataSet;
    procedure FormShow(Sender: TObject);
    procedure editCSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnNewCartonClick(Sender: TObject);
    procedure sbtnCloseCartonClick(Sender: TObject);
    procedure editReBoxNoChange(Sender: TObject);
    procedure editReBoxNoKeyPress(Sender: TObject; var Key: Char);
  private
    mPalletOfCSN,mCartonOfCSN,mCartonOfBox,mBoxOfCSN,mPalletOfBox,mProcessOfBox,mProcessOfCSN: String;
    TerminalID: String;
    PrintCartonLabel, PrintPalletLabel: Boolean;
    PrintCartonLabQty,
    PrintPalletLabQty,
    CodeSoftVersion: Integer;
    procedure getBoxDetail;
    function  checkCSN:Boolean;
    procedure AddCSN2Box;
    function  getNewCarton:String;
    function  CheckBox:Boolean;
    procedure clearReBox;
    function  getCfgData:Boolean;
    procedure  UpdateBoxOfSN(SN,sCarton,sPallet:string);
    Procedure UpdateRepackTemp(SN,FifoCode,Box:string);
    procedure DeleteRepackTemp(SN:string);
  public
    { Public declarations }
    UpdateUserID : String;
    G_PARTNO,sPartID,mWoOfBox,mWoOfCSN: String;
    Authoritys,AuthorityRole : String;
    bInputBox:Boolean;
    g_sn,sBoxNo:string;
    IsBoxInStock,IsCSNInStock,IsCSNInRepackTemp,IsBoxInRepackTemp:Boolean;
    Procedure SetStatusbyAuthority;
    procedure InsertIntoRepackTemp;
    function ReduceMaterialQty(Material_No:string):Boolean;
    function AddMaterialQty(material_no:string):boolean;
  end;

var
  fRepacking: TfRepacking;
  fSubModel : Boolean;

implementation

{$R *.DFM}

uses uDllform,Dllinit;

function TfRepacking.CheckBox:Boolean;
var iBool:Boolean;
begin
   Result := False;
   IsBoxInRepackTemp :=false;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := ' SELECT A.SERIAL_NUMBER,A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER,A.Pallet_NO, '
                   + '  A.MODEL_ID,A.Carton_no, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,SHIPPING_ID,'
                   + '  decode(a.next_process,0,A.WIP_PROCESS,a.next_process) wip_process, '
                   + '  B.PART_NO, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B '
                   + ' WHERE A.BOX_NO = ''' + editReBoxNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID ';
      Open;
      If RecordCount = 0 then
      begin
         //MessageDlg('Carton No not found !!',mtError,[mbOK],0);
         mCartonOfBox :='N/A';
         mPalletOfBox :='N/A';
         mWoOfBox := 'N/A';
         Result := True;
         G_PARTNO:='';
         Close;
         Exit;
      end
      else begin
          mWoOfBox:=fieldbyname('work_order').AsString;
          mCartonOfBox := fieldbyname('Carton_no').AsString;
          mPalletOfBox := fieldbyname('Pallet_no').AsString;
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
           Next;
      end;

      G_PARTNO := FieldByName('Part_No').AsString;
      Close;

   end;

   with QryBoxRepack do
   begin
       close;
       params.Clear ;
       Params.CreateParam(ftstring,'Box',ptInput);
       commandtext:='select * from sajet.g_sn_repack where box_no =:box' ;
       Params.ParamByName('Box').AsString := sBoxNo;
       Open;

       if not IsEmpty then begin
           lablfifocode.Caption := fieldbyname('FIFOCODE').AsString;
           IsBoxInRepackTemp :=True;
       end else  begin
           lablfifocode.Caption :='0';
           IsBoxInRepackTemp :=false;
       end;
   end;


   //check in instock by key for fifo
   if mCartonOfBox <>'N/A' then
   begin
       with QryMaterialOfBox do
       begin
           close;
           params.Clear ;
           commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode,factory_id  '
                      +' from sajet.g_material where material_no=  ''' + mCartonOfBox + ''' and rownum=1 ' ;
           open;


           if not IsEmpty  then begin
               lablfifocode.Caption :=fieldbyname('fifocode').AsString ;
               IsBoxInStock :=True;
           end else begin
               lablfifocode.Caption :='0';
               IsBoxInStock :=false;
           end;
       end;

       if IsBoxInRepackTemp and IsBoxInStock then
       begin
           MessageDlg( '衝突,BOX 在暫存區和庫房都有!!',mtError,[mbCancel],0);
           Exit;
       end;
   end else begin
       IsBoxInStock :=False;
       if IsBoxInRepackTemp then
           lablfifocode.Caption := QryBoxRepack.fieldbyname('fifocode').AsString
       else
           lablfifocode.Caption :='0';
   end;

   //get org by work_order's org
   with qryfctype do
   begin
       Close;
       Params.Clear;
       CommandText := 'SELECT a.factory_id,a.factory_code||''-''||a.factory_name as fc_type '
                     +' from sajet.sys_factory a,sajet.g_wo_base b where b.work_order='''+mWoOfBox+''' and a.factory_id=b.factory_id ';
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

procedure TfRepacking.InsertIntoRepackTemp;
begin
     with QryTemp do
     begin
          close;
          params.Clear ;
          Params.CreateParam(ftString,'WO',ptInput);
          Params.CreateParam(ftString,'partid',ptInput);
          Params.CreateParam(ftString,'sn',ptInput);
          Params.CreateParam(ftString,'boxno',ptInput);
          Params.CreateParam(ftString,'fifo',ptInput);
          Params.CreateParam(ftString,'factoryid',ptInput);
          Params.CreateParam(ftString,'factorytype',ptInput);
          Params.CreateParam(ftString,'warehouse',ptInput);
          Params.CreateParam(ftString,'locate',ptInput);
          Params.CreateParam(ftString,'status',ptInput);
          Params.CreateParam(ftString,'version',ptInput);
          Params.CreateParam(ftString,'DateCode',ptInput);
          commandtext:=' insert into sajet.g_sn_repack(WORK_ORDER,PART_ID,SERIAL_NUMBER,BOX_NO,FIFOCODE,FACTORY_ID,'+
                       ' FACTORY_TYPE,WAREHOUSE_ID,LOCATE_ID,status,version,DateCode) '+
                       ' values(:wo,:partid,:sn,:boxno,:fifo,:factoryid,:factorytype,:warehouse,:locate,:status,:version,:DateCode) ';
          Params.ParamByName('wo').AsString :=mWoOfCSN;
          Params.ParamByName('partid').AsString :=sPartID;
          Params.ParamByName('sn').AsString :=g_sn;
          Params.ParamByName('boxno').AsString :=editReBoxNo.Text;
          Params.ParamByName('fifo').AsString := Lablfifocode.Caption;
          Params.ParamByName('factoryid').AsString :=QryMaterialofSN.fieldbyName('FACTORY_ID').AsString;
          Params.ParamByName('factorytype').AsString :=QryMaterialofSN.fieldbyName('FACTORY_TYPE').AsString;
          Params.ParamByName('warehouse').AsString := QryMaterialofSN.fieldbyName('warehouse_id').AsString;
          Params.ParamByName('locate').AsString := QryMaterialofSN.fieldbyName('locate_id').AsString;
          Params.ParamByName('status').AsString := QryMaterialofSN.fieldbyName('status').AsString;
          Params.ParamByName('version').AsString := QryMaterialofSN.fieldbyName('version').AsString;
          Params.ParamByName('DateCode').AsString := QryMaterialofSN.fieldbyName('DateCode').AsString;
          execute;
     end;
end;
procedure TfRepacking.AddCSN2Box;
begin

   if QryBoxData.IsEmpty then
   begin
       if IsCSNInStock then begin
            //CSN 已經入庫
           if mCartonOfCSN <> mCartonOfBox then
           begin
                InsertIntoRepackTemp;
                ReduceMaterialQty(mCartonOfCSN);
           end;
       end else begin
           if IsCSNInRepackTemp then
               UpdateRepackTemp(g_sn,Lablfifocode.Caption,editReBoxNo.Text);
       end;
   end else begin

       if IsBoxInStock then begin
          //BOX 在庫房
           if IsCSNInStock then begin
                ReduceMaterialQty(mCartonOfCSN);
                AddMaterialQty(mCartonOfBox);
           end else if IsCSNInRepackTemp then begin
               AddMaterialQty(mCartonOfBox);
               DeleteRepackTemp(g_sn);
           end else begin
               MessageDlg('CSN NOT IN WAHREHOUSE ',mtError,[mbCancel],0);
               Exit;
           end;

       end  else if IsBoxInRepackTemp then
       begin
         //BOX 在緩衝區
           if IsCSNInStock then begin
               ReduceMaterialQty(mCartonOfCSN);
               InsertIntoRepackTemp;
           end else if IsCSNInRepackTemp then begin
               UpdateRepackTemp(g_sn,Lablfifocode.Caption,editReBoxNo.Text);
           end else begin
               MessageDlg('CSN NOT IN WAHREHOUSE ',mtError,[mbCancel],0);
               Exit;
           end;
       end else begin
         // BOX 未入庫
           if IsCSNInStock or IsCSNInRepackTemp then begin
                MessageDlg('CSN IN WAHREHOUSE ',mtError,[mbCancel],0);
                Exit;
           end;
       end;
   end;

   UpdateBoxOfSN(g_sn,mCartonOfBox,mPalletOfBox);

   bInputBox:=False;

end;

procedure TfRepacking.DeleteRepackTemp(SN:string);
begin
    with QryTemp do
    begin
         //delete   from sajet.g_sn_repack
        close;
        params.Clear ;
        commandtext:='delete  from sajet.g_sn_repack where serial_number ='''+SN+'''';
        execute;
    end;
end;

Procedure TfRepacking.UpdateRepackTemp(SN,FifoCode,Box:string);
begin
   with QryTemp do
   begin
      close;
      params.Clear ;
      Params.CreateParam(ftString,'SN',ptInput);
      if FifoCode <>'0' then
           Params.CreateParam(ftString,'FifoCode',ptInput);
      Params.CreateParam(ftString,'BoxNo',ptInput);
      if FifoCode <>'0' then
            commandtext:='update sajet.g_sn_repack set BOX_NO=:BOXNO,FifoCode=:FifoCode where serial_number =:SN '
      else
           commandtext:='update sajet.g_sn_repack set BOX_NO=:BOXNO where serial_number =:SN ';
      Params.ParamByName('SN').AsString :=g_sn;
      if FifoCode <>'0' then
           Params.ParamByName('FifoCode').AsString :=FifoCode;
      Params.ParamByName('BoxNo').AsString :=editReBoxNo.Text;
      Execute;
   end;
end;

procedure TfRepacking.UpdateBoxOfSN(SN,sCarton,sPallet:string);
begin

  with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'Carton',ptInput);
      Params.CreateParam(ftString,'Pallet',ptInput);
      CommandText := 'UPDATE SAJET.G_SN_STATUS '
                   + '   SET BOX_NO = ''' + editReBoxNo.Text +''',CARTON_NO= :carton ,Pallet_NO=:pallet '
                   + ' WHERE SERIAL_NUMBER = ''' + SN + ''' ';
      Params.ParamByName('Carton').AsString := sCarton;
      Params.ParamByName('Pallet').AsString := sPallet;
      Execute;
      Close;
   end;

end;

function TfRepacking.AddMaterialQty(material_no:string):boolean;
begin
    with QryTemp do
    begin
         close;
         params.Clear ;
         commandtext:='Update  sajet.g_material set material_qty =material_qty+1,update_time=sysdate,fifocode = '''+lablfifocode.Caption+''' where '
                +'  material_no= ''' + material_no + ''' and rownum=1 ';
         execute;

         close;
         params.Clear ;
         commandtext:='insert into sajet.g_ht_material '
                +' (select * from sajet.g_material where material_no= ''' + material_no + ''' and rownum=1 )';
         execute;

    end ;
end;

function  TfRepacking.ReduceMaterialQty(Material_no:string):Boolean;
begin
   Result :=false;
   with QryTemp do
    begin
          close;
          params.Clear ;
          commandtext:='Update  sajet.g_material set material_qty =material_qty-1 where '
                +'  material_no= ''' + Material_no + ''' and rownum=1 ';
          execute;

          close;
          params.Clear ;
          commandtext:='insert into sajet.g_ht_material '
                +' (select * from sajet.g_material where material_no= ''' + Material_no + ''' and rownum=1 )';
          execute;

          close;
          params.Clear ;
          commandtext:='select * from sajet.g_material where material_no= ''' + Material_no + ''' and rownum=1' ;
          Open;

          if FieldByName('Material_Qty').AsInteger  <=0 then begin
               close;
               params.Clear ;
               commandtext:='delete from   sajet.g_material where   material_no= ''' + Material_no + ''' ';
               execute;
          end;
    end;
    Result :=True;
end;

function  TfRepacking.checkCSN:Boolean;
var sfcid:string;
bCheckWO:Boolean;
begin
   Result := False;
   g_sn:='';
   IsCSNInRepackTemp :=false;
   IsCSNInStock :=false;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'select PARAM_VALUE FROM SAJET.sys_BASE WHERE PARAM_NAME =''Repack Check WO''';
      Open;
      if IsEmpty then bCheckWO := False
      else bCheckWO := (FieldByName('PARAM_VALUE').AsString='1');

      Close;
      Params.Clear;
      CommandText := ' select A.Serial_Number,A.CURRENT_STATUS, A.WORK_FLAG,A.model_id, '
                   + ' Decode(A.next_process,0,A.WIP_PROCESS,A.next_process) WIP_PROCESS, '
                   + ' A.Shipping_ID,A.work_order, A.model_ID, a.box_no,'
                   + ' A.QC_NO, A.QC_RESULT, A.CARTON_NO ,A.Pallet_NO,B.PART_NO  '
                   + ' FROM SAJET.G_SN_STATUS A , SAJET.SYS_PART B '
                   + ' WHERE (A.CUSTOMER_SN = ''' + editCSN.Text + ''' or   A.SERIAL_NUMBER = ''' + editCSN.Text + ''' )'
                   + ' AND A.MODEL_ID = B.PART_ID(+) ';
      Open;

      if IsEmpty then
      begin
         MessageDlg('Customer SN not exist !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;

      g_sn:=FieldByName('Serial_Number').asstring;
      mWoOfCSN:=FieldByName('work_order').asstring;
      sPartID := FieldByName('model_id').asstring;
      mBoxOfCSN :=  FieldByName('BOX_NO').asstring;
      mProcessOfCSN:= FieldByName('WIP_PROCESS').asstring;
      mCartonOfCSN:=  Qrytemp.fieldbyname('CARTON_NO').AsString;
      mPalletOfCSN := Qrytemp.fieldbyname('Pallet_no').AsString;

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
        if mProcessOfBox <> mProcessOfCSN then
         begin
            MessageDlg('PROCESS Different!!',mtError,[mbCancel],0);
            Close;
            Exit;

         end;
      end;

   end;
   {
    with qryfifo do
    begin
         close;
         params.Clear ;
         commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode,factory_id,factory_type '
                  +' from sajet.g_material where material_no=  ''' + mCartonOfBox + ''' and rownum=1 ' ;
         open;
    end;
   }
    with qrymaterialofSN do
    begin
        close;
        params.Clear ;
        commandtext:='select nvl(warehouse_id,''0'') as warehouse_id,nvl(locate_id,''0'') as locate_id,fifocode ,factory_id,factory_type  '
                    +' ,status,version,datecode from sajet.g_material where material_no=  ''' + mCartonOfCSN  + ''' and rownum=1 ' ;
        open;
        if IsEmpty then
            IsCSNInStock :=false
        else begin
            IsCSNInStock :=True;
        end;
    end;

    with QryCSNRepack do
    begin
        close;
        params.Clear ;
        Params.CreateParam(ftString,'SN',ptInput);
        commandtext:=' select * from sajet.g_sn_repack where serial_number =:SN ';
        Params.ParamByName('SN').AsString :=g_sn;
        Open;

        if IsEmpty then begin
            IsCSNInRepackTemp :=false;
        end else begin
            IsCSNInRepackTemp := True;
            if IsBoxInStock and (FieldByName('fifoCode').AsString < Lablfifocode.Caption) then begin
                 Lablfifocode.Caption := FieldByName('fifoCode').AsString;
            end;
        end;
    end;


    if IsCSNInRepackTemp and IsCSNInStock then
    begin
       MessageDlg( '衝突,SN 在暫存區和庫房都有!!',mtError,[mbCancel],0);
       Close;
       Exit;
    end;

    if IsBoxInStock then
    begin
        if IsCSNInStock then
        begin
              if QryMaterialofBox.FieldByName('warehouse_id').AsString <>QryMaterialofSN.fieldbyname('warehouse_id').AsString then
              begin
                  MessageDlg('Warehouse is different!',mtError,[mbCancel],0);
                  Exit;
              end;
              //check locate
              if QryMaterialofBox.FieldByName('locate_id').AsString <>QryMaterialofSN.fieldbyname('locate_id').AsString then
              begin
                  MessageDlg('locate is different!',mtError,[mbCancel],0);
                    //Close;
                  Exit;
              end;
              //check fifocode
              if QryMaterialofSN.fieldbyname('fifocode').AsString < lablfifocode.Caption then
                  lablfifocode.Caption:= QryMaterialofSN.fieldbyname('fifocode').AsString ;
              if QryMaterialofBox.fieldbyname('factory_id').AsString <> QryMaterialofSN.fieldbyname('factory_id').AsString then
              begin
                  MessageDlg('Org is different!',mtError,[mbCancel],0);
                  Exit;
              end;
        end else begin

              if  IsCSNInRepackTemp then begin

                   if QryMaterialofBox.FieldByName('warehouse_id').AsString <>QryCSNRepack.fieldbyname('warehouse_id').AsString then
                   begin
                        MessageDlg('Warehouse is different!',mtError,[mbCancel],0);
                          // Close;
                        Exit;
                   end;
                    //check locate
                   if QryMaterialofBox.FieldByName('locate_id').AsString <>QryCSNRepack.fieldbyname('locate_id').AsString then
                   begin
                        MessageDlg('locate is different!',mtError,[mbCancel],0);
                          //Close;
                        Exit;
                   end;
                    //check fifocode
                   if QryCSNRepack.fieldbyname('fifocode').AsString < lablfifocode.Caption then
                        lablfifocode.Caption:= QryCSNRepack.fieldbyname('fifocode').AsString ;

                   if QryMaterialofBox.fieldbyname('factory_id').AsString <> QryCSNRepack.fieldbyname('factory_id').AsString then
                   begin
                        MessageDlg('Org is different!',mtError,[mbCancel],0);
                        Exit;
                   end;
              end else begin
                   MessageDlg('SN not in warehouse!',mtError,[mbCancel],0);
                   Exit;

              end;
        end;
    end
    else
    begin

         if IsBoxInRepackTemp    then begin
              //Box 沒入庫  ,但是在暫存區

             Lablfifocode.Caption :=  QryBoxRepack.fieldByName('fifocode').AsString;
             if IsCSNInStock  then begin

                   if QryBoxRepack.FieldByName('WareHouse_ID').AsString <> QryMaterialOfSN.FieldByName('WareHouse_ID').AsString  then
                   begin
                         MessageDlg('Warehouse is different!',mtError,[mbCancel],0);
                         Exit;
                   end;

                   if QryBoxRepack.FieldByName('Locate_ID').AsString <> QryMaterialOfSN.FieldByName('Locate_ID').AsString  then
                   begin
                        MessageDlg('Locate  is different!',mtError,[mbCancel],0);
                        Exit;
                   end;

                   if QryMaterialofSN.fieldbyname('fifocode').AsString <  Lablfifocode.Caption then
                         Lablfifocode.Caption :=  QryMaterialofSN.fieldByName('fifocode').AsString;
                   if QryBoxRepack.fieldbyname('factory_id').AsString <> QryMaterialofSN.fieldbyname('factory_id').AsString then
                   begin
                        MessageDlg('Org is different!',mtError,[mbCancel],0);
                        Exit;
                   end;

             end else if  IsCSNInRepackTemp  then begin

                    if QryBoxRepack.FieldByName('WareHouse_ID').AsString <> QryCSNRepack.FieldByName('WareHouse_ID').AsString  then
                    begin
                         MessageDlg('Warehouse is different!',mtError,[mbCancel],0);
                         Exit;
                    end;

                    if QryBoxRepack.FieldByName('Locate_ID').AsString <> QryCSNRepack.FieldByName('Locate_ID').AsString  then
                    begin
                         MessageDlg('Locate  is different!',mtError,[mbCancel],0);
                         Exit;
                    end;

                    if QryCSNRepack.fieldbyname('fifocode').AsString <  Lablfifocode.Caption then
                         Lablfifocode.Caption :=  QryCSNRepack.fieldByName('fifocode').AsString;

                    if QryBoxRepack.fieldbyname('factory_id').AsString <> QryCSNRepack.fieldbyname('factory_id').AsString then
                   begin
                        MessageDlg('Org is different!',mtError,[mbCancel],0);
                        Exit;
                   end;

             end;
         end  else begin
             //BOX 沒入庫，也不在暫存區
             if not QryBoxData.IsEmpty then
             begin
                 if  IsCSNInStock or   IsCSNInRepackTemp then begin
                     MessageDlg('SN in warehouse!',mtError,[mbCancel],0);
                     Exit;
                 end else begin
                     if bCheckWO then
                         if (mWoOfBox <>'N/A') and  (mWoOfBox <> mWoOfCSN) then
                         begin
                            MessageDlg('WORK ORDER is Different!',mtError,[mbCancel],0);
                            Exit;
                         end;
                 end;
             end else begin
                 if IsCSNInStock then begin
                     Lablfifocode.Caption := QryMaterialOfSN.fieldbyName('FifoCOde').AsString;
                     LabLORG.Caption :=  QryMaterialOfSN.fieldbyName('Factory_id').AsString;
                 end else if IsCSNInRepackTemp then  begin
                     Lablfifocode.Caption :=QryCSNRepack.fieldbyName('FifoCOde').AsString;
                     LabLORG.Caption :=  QryCSNRepack.fieldbyName('Factory_id').AsString;
                 end;
             end;
         end;
    end;

    if IsBoxInStock or IsBoxInRepackTemp then begin
          if IsCSNInStock or IsCSNInRepackTemp then
          begin
                if Copy(mWoOfBox,Length(mWoOfBox)-1,2) ='-F' then begin
                     if Copy(mWoOfCSN,Length(mWoOfCSN)-1,2) <> '-F' then begin
                         MessageDlg('不能刷入非試產工令',mtError,[mbCancel],0);
                         Exit;
                     end;
                end else if Copy(mWoOfBox,Length(mWoOfBox)-1,2) ='-C' then begin
                     if Copy(mWoOfCSN,Length(mWoOfCSN)-1,2) <> '-C' then begin
                         MessageDlg('不能刷入非試驗工令',mtError,[mbCancel],0);
                         Exit;
                     end;
                end else begin
                     if (Copy(mWoOfCSN,Length(mWoOfCSN)-1,2) ='-F') or (Copy(mWoOfCSN,Length(mWoOfCSN)-1,2) = '-C') then begin
                          MessageDlg('不能刷入非試驗工令或者試產工令',mtError,[mbCancel],0);
                          Exit;
                     end;
                end;
          end;
    end;
    
    Result := True;

end;

procedure TfRepacking.getboxDetail;
begin
   lvCSNDetail.Items.Clear;
   mWoOfBox :=  'N/A';
   mCartonOfBox :=  'N/A';
   mPalletOfbox :=  'N/A';
   with QryBoxData do
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
         mWoOfBox :=      FieldByName('Work_order').AsString;
         mCartonOfBox :=  FieldByName('Carton_No').AsString;
         mPalletOfbox :=  FieldByName('Pallet_No').AsString;
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

   If not bInputBox then
   begin
     sKey:=#13;
     editReBoxNoKeyPress(self,sKey);
     if not bInputBox then
       exit;
   end;

   if checkCSN then
   begin
     addCSN2Box;
     getBoxDetail;
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
         Params.ParamByName('WO').AsString := QryBoxData.FieldByName('Work_Order').AsString;
         Params.ParamByName('MODEL').AsString := QryBoxData.FieldByName('Model_ID').AsString;
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
    bInputBox:=False;
    lablqty.Caption:='0';
    lablfifocode.Caption:='0';
    lablorg.Caption :='0';
end;

procedure TfRepacking.editReBoxNoKeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key <> #13 then
      Exit;
   IsBoxInStock :=False;
   IsBoxInRepackTemp :=false;
   if (editReBoxNo.Text = '') then  Exit;

   if trim(editReBoxNo.Text) = 'N/A' then
   begin
      MessageDlg('Box Error',mtError,[mbCancel],0);
      editReBoxNo.SetFocus;
      editReBoxNo.SelectAll;
      Exit;
   end;
   sBoxNo :=Trim(editReBoxNo.Text);
   
   if not CheckBox then
   begin
       editReBoxNo.SetFocus;
       editReBoxNo.SelectAll;
       Exit;
   end;
   getBoxDetail;
   editCSN.SetFocus;
   bInputBox:=True;
end;

end.
