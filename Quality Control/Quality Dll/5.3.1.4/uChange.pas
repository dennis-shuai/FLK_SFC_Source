unit uChange;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, DB, DBClient, BmpRgn, Buttons, jpeg;

type
   TfChangeSN = class(TForm)
      Image1: TImage;
      LabType2: TLabel;
      Label6: TLabel;
    editChangeSN: TEdit;
      Label1: TLabel;
    combProcess: TComboBox;
      Image2: TImage;
      sbtnCancel: TSpeedButton;
      Image5: TImage;
      sbtnSave: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    editDefectSN: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    lablWO: TLabel;
    lablPart: TLabel;
      procedure FormCreate(Sender: TObject);
      procedure sbtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure editChangeSNKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSaveClick(Sender: TObject);
    procedure editChangeSNChange(Sender: TObject);
   private
    { Private declarations }
    slProcessID: TStrings;
    bCheckSN: Boolean;
    m_sSN: String;
    procedure GetProcess;
    function  checkSN: Boolean;
    function  processChange: Boolean;
   public
    { Public declarations }
      procedure SetTheRegion;
   end;

var
   fChangeSN: TfChangeSN;

implementation

uses uQuality;

{$R *.dfm}

{ TfChangeSN }

function TfChangeSN.checkSN:Boolean;
begin
   Result := False;

   m_sSN := '';
   with fQuality.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select A.Serial_Number, A.Work_Order, A.Model_ID, B.Part_No, A.Current_Status, A.Work_Flag, A.Process_ID '
                   + '  From SAJET.G_SN_STATUS A '
                   + '      ,SAJET.SYS_PART B '
                   + ' Where A.Serial_Number = ''' + editChangeSN.Text + ''' '
                   + '   And A.Model_ID = B.Part_ID ';
      Open;
      if IsEmpty then
      begin
         Close;
         Params.Clear;
         CommandText := 'Select A.Serial_Number, A.Work_Order, A.Model_ID, B.Part_No, A.Current_Status, A.Work_Flag, A.Process_ID '
                   + '  From SAJET.G_SN_STATUS A '
                   + '      ,SAJET.SYS_PART B '
                   + ' Where A.Customer_SN = ''' + editChangeSN.Text + ''' '
                   + '   And A.Model_ID = B.Part_ID ';
         Open;
         if IsEmpty then
         begin
            MessageDlg('The S/N not Found !!',mtError,[mbOK],0);
            Close;
            Exit;
         end;
      end;
      lablWO.Caption := FieldByName('Work_Order').AsString;
      lablPart.Caption := FieldByName('Part_No').AsString;

      if FieldByName('Model_ID').AsString <> fQuality.PartID then
      begin
         MessageDlg('The Part No Different with QC Lot !!',mtError,[mbOK],0);
         Close;
         Exit;
      end;

      if FieldByName('Process_ID').AsString <> slProcessID.Strings[combProcess.ItemIndex] then
      begin
         MessageDlg('The Change S/N. Process Error !!',mtError,[mbOK],0);
         Close;
         Exit;
      end;

      if FieldByName('Current_Status').AsString <> '0' then
      begin
         MessageDlg('The Change S/N. not Repair OK !!',mtError,[mbOK],0);
         Close;
         Exit;
      end;

      if FieldByName('Work_Flag').AsString <> '0' then
      begin
         MessageDlg('The Change S/N. Scrap !!',mtError,[mbOK],0);
         Close;
         Exit;
      end;
      m_sSN := FieldByName('Serial_Number').AsString;
      Close;
   end;

   Result := True;
end;

Procedure TfChangeSN.GetProcess;
begin
   with fQuality.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select Process_Name, Process_ID '
                   + '  From SAJET.SYS_PROCESS '
                   + ' Where Enabled = ''Y'' '
                   + ' Order by Process_Name ';
      Open;
      while not Eof do
      begin
         combProcess.Items.Add(FieldByName('Process_Name').AsString);
         slProcessID.Add(FieldByName('Process_ID').AsString);
         Next;
      end;
      Close;
   end;
end;


procedure TfChangeSN.FormCreate(Sender: TObject);
begin
   SetTheRegion;
   slProcessID := TStringList.Create;
end;

procedure TfChangeSN.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Image1.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

procedure TfChangeSN.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfChangeSN.FormShow(Sender: TObject);
begin
   GetProcess;
end;

procedure TfChangeSN.FormDestroy(Sender: TObject);
begin
   slProcessID.Free;
end;

procedure TfChangeSN.editChangeSNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
   begin
      if not checkSN then
      begin
         editChangeSN.SetFocus;
         editChangeSN.SelectAll;
      end
      else
         bCheckSN := True;
   end;
end;

procedure TfChangeSN.sbtnSaveClick(Sender: TObject);
var sKey : Char;
begin
   if combProcess.ItemIndex = -1 then
   begin
      MessageDlg('Input Process !',mtError,[mbOK],0);
      Exit
   end;

   if not bCheckSN then
   begin
      sKey := #13;
      editChangeSNKeyPress(Sender, sKey);
      if not bCheckSN then Exit;
   end;

   if MessageDlg('Change Defect S/N to "' + editChangeSN.Text + '" ?',mtConfirmation,[mbOK,mbCancel],0) = mrOK then
   begin
      if processChange then
         ModalResult := mrOK;
   end;
end;

function TfChangeSN.processChange:Boolean;
begin
   Result := False;

   fQuality.QryData.Close;
   fQuality.QryData.Params.Clear;
   fQuality.QryData.CommandText := 'Select * From SAJET.G_SN_STATUS '
                   + ' Where Serial_Number = ''' + editDefectSN.Text + ''' ';
   fQuality.QryData.Open;
   try
      with fQuality.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'Pallet_No',ptInput);
         Params.CreateParam(ftString,'Carton_No',ptInput);
         Params.CreateParam(ftString,'QC_NO',ptInput);
         Params.CreateParam(ftString,'QC_Result',ptInput);
         CommandText := 'Update SAJET.G_SN_STATUS '
                      + '   Set Pallet_No = :Pallet_No '
                      + '      ,Carton_No = :Carton_No '
                      + '      ,QC_NO = :QC_NO '
                      + '      ,QC_Result = :QC_Result '
                      + ' Where Serial_Number = ''' + m_sSN + ''' ';
         Params.ParamByName('Pallet_No').AsString := fQuality.QryData.FieldByName('Pallet_No').AsString;
         Params.ParamByName('Carton_No').AsString := fQuality.QryData.FieldByName('Carton_No').AsString;
         Params.ParamByName('QC_NO').AsString := fQuality.QryData.FieldByName('QC_NO').AsString;
         Params.ParamByName('QC_Result').AsString := fQuality.QryData.FieldByName('QC_Result').AsString;
         Execute;

         Close;
         Params.Clear;
         Params.CreateParam(ftString,'QC_No',ptInput);
         Params.CreateParam(ftString,'QC_Cnt',ptInput);
         CommandText := 'Delete SAJET.G_QC_SN '
                      + ' Where QC_LotNo = :QC_No '
                      + '   And QC_CNT = :QC_Cnt '
                      + '   And Serial_Number = ''' + editDefectSN.Text + ''' ';
         Params.ParamByName('QC_No').AsString := fQuality.cmbQCLotNo.Text;
         Params.ParamByName('QC_CNT').AsString := fQuality.lablInspTimes.Caption;
         Execute;

         Close;
         Params.Clear;
         Params.CreateParam(ftString,'QC_No',ptInput);
         Params.CreateParam(ftString,'QC_Cnt',ptInput);
         CommandText := 'Delete SAJET.G_QC_SN_DEFECT '
                      + ' Where QC_LotNo = :QC_No '
                      + '   And QC_CNT = :QC_CNT '
                      + '   And Serial_Number = ''' + editDefectSN.Text + ''' ';
         Params.ParamByName('QC_No').AsString := fQuality.cmbQCLotNo.Text;
         Params.ParamByName('QC_CNT').AsString := fQuality.lablInspTimes.Caption;
         Execute;

         Close;
         Params.Clear;
         CommandText := 'Update SAJET.G_SN_STATUS '
                      + '   Set Pallet_No = ''N/A'' '
                      + '      ,Carton_No = ''N/A'' '
                      + '      ,QC_No = ''N/A'' '
                      + '      ,QC_Result = ''N/A'' '
                      + ' Where Serial_Number = ''' + editDefectSN.Text + ''' ';
         Execute;

         Close;
         Params.Clear;
         Params.CreateParam(ftString,'QC_LotNo',ptInput);
         Params.CreateParam(ftString,'NG_CNT',ptInput);
         CommandText := 'Update SAJET.G_QC_LOT '
                      + '   Set Fail_Qty = Fail_Qty - 1 '
                      + '      ,Sampling_Size = Sampling_Size - 1 '
                      + ' Where QC_LotNO = :QC_LotNo '
                      + '   And NG_CNT = :NG_CNT ';
         Params.ParamByName('QC_LotNo').AsString := fQuality.cmbQCLotNo.Text;
         Params.ParamByName('NG_CNT').AsString := fQuality.lablInspTimes.Caption;
         Execute;
      end;
      Result := True;
   except
      MessageDlg('Process Change Fail !!',mtError,[mbOK],0);
   end;
   fQuality.QryData.Close;
end;

procedure TfChangeSN.editChangeSNChange(Sender: TObject);
begin
   bCheckSN := False;
   lablWO.Caption := '';
   lablPart.Caption := '';
end;

end.

