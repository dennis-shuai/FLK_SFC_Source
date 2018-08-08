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
    QryPalletData: TClientDataSet;
    Label11: TLabel;
    editRePalletNO: TEdit;
    Label16: TLabel;
    editCartonNo: TEdit;
    sbtnNewPallet: TSpeedButton;
    Image4: TImage;
    sbtnClosePallet: TSpeedButton;
    Label13: TLabel;
    lablQty2: TLabel;
    Label18: TLabel;
    lablTotal: TLabel;
    lvCarton: TListView;
    lvCSN: TListView;
    procedure FormShow(Sender: TObject);
    procedure sbtnNewPalletClick(Sender: TObject);
    procedure editCartonNoKeyPress(Sender: TObject; var Key: Char);
    procedure lvCartonClick(Sender: TObject);
    procedure sbtnClosePalletClick(Sender: TObject);
    procedure editRePalletNOKeyPress(Sender: TObject; var Key: Char);
    procedure editRePalletNOChange(Sender: TObject);
  private
    mCartonModelID, mCartonProcessID, mPalletOfCarton: String;
    TerminalID: String;
    PrintCartonLabel, PrintPalletLabel: Boolean;
    PrintCartonLabQty,
    PrintPalletLabQty,
    CodeSoftVersion: Integer;
    procedure addCarton2Pallet;
    function  CheckPCarton:Boolean;
    procedure getCartonDetail;
    function  getNewPallet:String;
    procedure showCSNofCarton(psCarton:String);
    procedure clearRePallet;
    function  getCfgData:Boolean;
  public
    { Public declarations }
    UpdateUserID : String;
    Authoritys,AuthorityRole : String;
    bInputPallet:Boolean;
    Procedure SetStatusbyAuthority;
    function checkPallet:Boolean;
  end;

var
  fRepacking: TfRepacking;
  fSubModel : Boolean;
implementation

{$R *.DFM}

uses uDllform,Dllinit;

function TfRepacking.checkPallet:Boolean;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER, A.MODEL_ID, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,A.SHIPPING_ID, '
                   + '       B.PART_NO, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B '
                   + ' WHERE A.PALLET_NO = ''' + editRePalletNo.Text + ''' '
                   + ' AND A.MODEL_ID = B.PART_ID ';
      Open;
      If RecordCount = 0 then
      begin
         Result := True;
         Close;
         Exit;
      end;
      
      {while not Eof do
      begin
        //不能是判退品
        if (FieldByName('QC_RESULT').AsString='1') then
        begin
          MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                     'Had been Reject !!',mtError,[mbCancel],0);
          Close;
          Exit;
        end;
        Next;
      end;}

      if Locate('QC_Result','1',[]) then
      begin
         MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                     'Had been Reject !!',mtError,[mbCancel],0);
         Close;
         Exit;
      end;



      Close;
   end;
   Result := True;
end;

procedure TfRepacking.showCSNofCarton(psCarton:String);
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
                   + ' WHERE CARTON_NO = ''' + psCarton + ''' '
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

procedure TfRepacking.addCarton2Pallet;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'UPDATE SAJET.G_SN_STATUS '
                   + '   SET PALLET_NO = ''' + editRePalletNo.Text + ''' '
                   + ' WHERE CARTON_NO = ''' + editCartonNo.Text + ''' ';
      Execute;
   end;
end;

procedure TfRepacking.getCartonDetail;
   Function getPalletQty:String;
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'SELECT COUNT(*) FROM SAJET.G_SN_STATUS '
                      + 'WHERE PALLET_NO = ''' + editRePalletNo.Text + ''' ';
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

   with QryPalletData do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT WORK_ORDER, MODEL_ID, PROCESS_ID, QC_NO, QC_RESULT, Out_PDLine_Time '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE PALLET_NO = ''' + editRePalletNo.Text + ''' '
                   + '   AND ROWNUM = 1 ';
      Open;
   end;

   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT CARTON_NO, COUNT(SERIAL_NUMBER) QTY '
                   + '  FROM SAJET.G_SN_STATUS '
                   + ' WHERE PALLET_NO = ''' + editRePalletNo.Text + ''' '
                   + ' GROUP BY CARTON_NO ';
      Open;
      while not Eof do
      begin
         with lvCarton.Items.Add do
         begin
            Caption := QryTemp.FieldByName('CARTON_NO').AsString;
            SubItems.Add(QryTemp.FieldByName('QTY').AsString);
         end;
         Next;
      end;
      lablQty2.Caption := IntToStr(RecordCount);
      If RecordCount = 0 then Exit;
      Close;
   end;
   lablTotal.Caption := getPalletQty;
   showCSNofCarton(lvCarton.Items[0].Caption);
   editCartonNo.SetFocus;
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

  sbtnClosePallet.Enabled := (iPrivilege >=1);
  sbtnNewPallet.Enabled := sbtnClosePallet.Enabled;
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

procedure TfRepacking.sbtnNewPalletClick(Sender: TObject);
begin
  // editRePalletNo.Text := getNewPallet;
   getCartonDetail;
end;

procedure TfRepacking.editCartonNoKeyPress(Sender: TObject; var Key: Char);
var sKey:Char;
begin
   if key<>#13 then
     exit;

   if editCartonNo.Text = '' then
     exit;

   if not bInputPallet then
   begin
     sKey:=#13;
     editRePalletNoKeyPress(self,sKey);
     if not bInputPallet then
       exit;
   end;

   if checkPCarton then
   begin
     addCarton2Pallet;
     getCartonDetail;
   end;
   editCartonNo.SetFocus;
   editcartonNo.SelectAll;

end;

procedure TfRepacking.lvCartonClick(Sender: TObject);
begin
   if lvCarton.Selected <> nil then
      showCSNofCarton(lvCarton.Selected.Caption);
end;

procedure TfRepacking.sbtnClosePalletClick(Sender: TObject);
var sPrintData,sPallet: String;
begin
   if editRePalletNO.Text = '' Then
   begin
       ShowMessage('No Pallet No. !!!');
       Exit;
   end;

   if lvCarton.Items.Count = 0 then Exit;
   if MessageDlg('Close Pallet ?',mtConfirmation,[mbYES,mbNO],0) <> mrYes then
   begin
     exit;
   End;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT * FROM SAJET.G_PACK_PALLET '
                   + ' WHERE PALLET_NO = ''' + editRepalletNo.Text + ''' ';
      Open;
      if Eof then
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         Params.CreateParam(ftString,'MODEL',ptInput);
         Params.CreateParam(ftString,'PALLET',ptInput);
         Params.CreateParam(ftString,'USERID',ptInput);
         CommandText := 'INSERT INTO SAJET.G_PACK_PALLET '
                      + ' (WORK_ORDER, MODEL_ID, PALLET_NO, CLOSE_FLAG, CREATE_EMP_ID) '
                      + 'VALUES(:WO, :MODEL, :PALLET, ''Y'', :USERID) ';
         Params.ParamByName('WO').AsString := QryPalletData.FieldByName('Work_Order').AsString;
         Params.ParamByName('MODEL').AsString := QryPalletData.FieldByName('Model_ID').AsString;
         Params.ParamByName('PALLET').AsString := editRePalletNo.Text;
         Params.ParamByName('USERID').AsString := UpdateUserID;
         Execute;
      end
      else if FieldByName('Close_Flag').AsString <> 'Y' then
      begin
         Close;
         Params.Clear;
         CommandText := 'UPDATE SAJET.G_PACK_PALLET '
                      + '   SET CLOSE_FLAG = ''Y'' '
                      + ' WHERE PALLET_NO = ''' + editRePalletNo.Text + ''' ';
         Execute;
      end;
   end;

   {if PrintPalletLabel then
   begin
     if not fSubModel then
       sPrintData:=G_getPrintData(CodesoftVersion,1,G_sockConnection,'DspQryData',editRePalletNo.Text,PrintPalletLabQty)
     else
       sPrintData:=G_getPrintData(CodesoftVersion,11,G_sockConnection,'DspQryData',editRePalletNo.Text,PrintPalletLabQty);
      //G_onTransDataToApplication(@sPrintData[1],length(sPrintData),nil);
   end; }
   sPallet := editRePalletNo.Text;
   clearRePallet;
   ShowMessage('Pallet '+ sPallet + ' Close !!!');
end;

Procedure TfRepacking.clearRePallet;
begin
   editRePalletNo.Clear;
   lvCarton.Clear;
   lvCSN.Clear;
   lablQty2.Caption := '0';
   lablTotal.Caption := '0';
   editCartonNo.Clear;
   editRepalletNo.SetFocus;
end;


function TfRepacking.CheckPCarton: Boolean;
Var
  sCarton : String;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'SELECT A.CUSTOMER_SN, A.CURRENT_STATUS, A.WORK_FLAG, A.WORK_ORDER, A.MODEL_ID, A.PROCESS_ID, A.QC_NO, A.QC_RESULT,A.SHIPPING_ID, '
                   + '       B.PART_NO, C.PROCESS_NAME, DECODE(A.QC_RESULT,''N/A'',''NULL'',''0'',''PASS'',''1'',''REJECT'') RESULT, A.OUT_PDLINE_TIME '
                   + '  FROM SAJET.G_SN_STATUS A, '
                   + '       SAJET.SYS_PART B, '
                   + '       SAJET.SYS_PROCESS C '
                   + ' WHERE A.CARTON_NO = ''' + editCartonNo.Text + ''' '
                   + '   AND A.MODEL_ID = B.PART_ID '
                   + '   AND A.PROCESS_ID = C.PROCESS_ID(+) ';
      Open;
      If RecordCount = 0 then
      begin
         MessageDlg('Carton No not found !!',mtError,[mbOK],0);
         Close;
         Exit;
      end;

      while not Eof do
      begin
        //不能是判退品
        if (FieldByName('QC_RESULT').AsString='1') then
        begin
          MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                     'Had been Reject !!',mtError,[mbCancel],0);
          Close;
          Exit;
        end;

        
        if QryPalletData.RecordCount <> 0 then
        begin  //Model不同
           if QryPalletData.FieldByName('Model_ID').AsString <> FieldByName('Model_ID').AsString then
           begin
              MessageDlg('Part No Different !!'+#13#10
                     + FieldByName('PART_NO').AsString,mterror,[mbCancel],0);
              Close;
              Exit;
           end;

           if QryPalletData.FieldByName('Out_PDLine_Time').IsNull then
           begin
              if QryPalletData.FieldByName('Process_ID').AsString <> FieldByName('Process_ID').AsString then
              begin
                 MessageDlg('Customer SN - ' + FieldByName('Customer_SN').AsString + #13#10+
                            'Process Different !!',mtError,[mbCancel],0);
                 Close;
                 Exit;
              end;
           end
           else
           begin
              if (FieldByName('Out_PDLine_Time').IsNull) then
              begin
                 MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                            'Output Status Different !!',mtError,[mbCancel],0);
                 Close;
                 Exit;
              end;
           end;

           if QryPalletData.FieldByName('QC_Result').AsString <> FieldByName('QC_Result').AsString then
           begin
              MessageDlg('Customer SN - '+FieldByName('Customer_SN').AsString + #13#10 +
                         'QC Status Different !!',mtError,[mbCancel],0);
              Close;
              Exit;
           end;
        end;

         //不良品
        { if FieldByName('Current_Status').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                       'Have to Repair !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end;
         //報廢品
         if FieldByName('Work_Flag').AsString <> '0' then
         begin
            MessageDlg('Customer SN - ' + FieldByName('Customer_Sn').AsString + #13#10 +
                       'Had been Scrap !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end;
         //已出貨
         if FieldByName('Shipping_ID').AsString <> '0' Then
         begin
            MessageDlg( editCartonNo.Text + #13#10 +
                       'Shippinged !!',mtError,[mbCancel],0);
            Close;
            Exit;
         end;
         }
         Next;
      end;
      Close;
   end;
   Result := True;
end;

procedure TfRepacking.editRePalletNOKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key <> #13) then
     exit;

   if (editRePalletNo.Text = '') then
     exit;
   if trim(editRePalletNo.Text) = 'N/A' then
   begin
     MessageDlg('Pallet Error',mtError,[mbCancel],0);
     editRePalletNo.SetFocus;
     editRePalletNo.SelectAll;
     exit;
   end;

   IF Not CheckPallet Then
   begin
     editRePalletNo.SetFocus;
     editRePalletNo.SelectAll;
     Exit;
   end;

   getCartonDetail;
   editCartonNo.SetFocus;
   bInputPallet:=True;
end;

procedure TfRepacking.editRePalletNOChange(Sender: TObject);
begin
  bInputPallet:=False;
end;

end.
