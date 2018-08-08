unit uAQL;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, DB, DBClient, BmpRgn, Buttons, jpeg, Grids,
  DBGrids;

type
   TfAQL = class(TForm)
      Image1: TImage;
      LabType2: TLabel;
      Label6: TLabel;
      editQCLot: TEdit;
      Label1: TLabel;
      cmbAQL: TComboBox;
      Image2: TImage;
      sbtnCancel: TSpeedButton;
      Image5: TImage;
      sbtnSave: TSpeedButton;
    DBGrid2: TDBGrid;
    dsrcSamplingPlan: TDataSource;
    Label3: TLabel;
    combLevel: TComboBox;
      procedure FormCreate(Sender: TObject);
      procedure sbtnCancelClick(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
    procedure cmbAQLChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure combLevelChange(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      procedure GetAllPlan;
      procedure SetTheRegion;
      procedure GetSamplingDetail;
   end;

var
   fAQL: TfAQL;

implementation

uses uQuality;

{$R *.dfm}

{ TfAQL }

procedure TfAQL.GetAllPlan;
begin
   cmbAQL.Clear;
   with fQuality.qryTemp do
   begin
      Close;
      CommandText := 'Select DISTINCT D.SAMPLING_TYPE '+
                     'From ' +
                     'SAJET.SYS_QC_SAMPLING_PLAN_DETAIL C, ' +
                     'SAJET.SYS_QC_SAMPLING_PLAN D ' +
                     'Where C.SAMPLING_ID = D.SAMPLING_ID ';

      Open;
      while not Eof do
      begin
         if cmbAQL.Items.IndexOF(Fieldbyname('SAMPLING_TYPE').AsString) < 0 then
            cmbAQL.Items.Add(Fieldbyname('SAMPLING_TYPE').AsString);
         Next;
      end;
      cmbAQL.ItemIndex := cmbAQL.Items.IndexOF(fQuality.LabInspType.Caption);
      //Close;
   end;
end;

procedure TfAQL.FormCreate(Sender: TObject);
begin
   SetTheRegion;
    
end;

procedure TfAQL.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Image1.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

procedure TfAQL.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfAQL.sbtnSaveClick(Sender: TObject);
var sSamplingID: string;
   sSamplingSize, sCriQty, sMajQty, sMinQty: string;
   iLotSize:integer;
begin
   // 維持原抽樣計畫
   if (cmbAQL.Text = fQuality.LabInspType.Caption) then
      Close
   else
   begin
      iLotSize:=StrToIntDef(fQuality.LabTotQty.Caption,0);
      sSamplingSize := fQuality.LabSampleQty.Caption;
      sCriQty := fQuality.LabCriQty.Caption;
      sMajQty := fQuality.LabCriQty.Caption;
      sMinQty := fQuality.LabMinQty.Caption;
      if iLotSize =0 then
      begin
         sSamplingID := '0';
         with fQuality.QryTemp do
         begin
            close;
            Params.Clear;
            Params.CreateParam(ftString, 'SAMPLING_TYPE', ptInput);
            Commandtext :=' select SAMPLING_ID FROM SAJET.SYS_QC_SAMPLING_PLAN '
                         +'  WHERE SAMPLING_TYPE =:SAMPLING_TYPE '
                         +'   AND ROWNUM = 1';
            Params.ParamByName('SAMPLING_TYPE').AsString := cmbAQL.Text;
            Open;
            if not eof then
              sSamplingID := FieldByName('SAMPLING_ID').AsString;
            close;
            Params.Clear;
            CommandText := 'UPDATE SAJET.G_QC_LOT '
                         + '   SET Sampling_Plan_Id = ' + sSamplingID
                         + '      ,INSP_EMPID = ''' + fQuality.UpdateUserID + ''' '
                         + ' WHERE QC_LOTNO = ''' + editQCLot.Text + ''' '
                         + '   AND NG_CNT = ''' + fQuality.lablInspTimes.Caption + ''' ';
            Execute;
            fQuality.LabInspType.Caption := cmbAQL.Text;
            Close;
            ModalResult := mrOK;
         end;
      end else
      begin
        sSamplingID := fQuality.GetSamplingPlan(cmbAQL.Text,iLotSize);
        if sSamplingID = '0' then
        begin
           fQuality.LabSampleQty.Caption := sSamplingSize;
           fQuality.LabCriQty.Caption := sCriQty;
           fQuality.LabMajQty.Caption := sMajQty;
           fQuality.LabMinQty.Caption := sMinQty;
        end
        else
        begin
           with fQuality.QryTemp do
           begin
              Close;
              Params.Clear;
              CommandText := 'UPDATE SAJET.G_QC_LOT '
                 + '   SET Sampling_Plan_Id = ' + sSamplingID
                 + '      ,INSP_EMPID = ''' + fQuality.UpdateUserID + ''' '
                 + ' WHERE QC_LOTNO = ''' + editQCLot.Text + ''' '
                 + '   AND NG_CNT = ''' + fQuality.lablInspTimes.Caption + ''' ';
              Execute;
              Close;
           end;
           ModalResult := mrOK;
        end
      end;
   end;
end;

procedure TfAQL.cmbAQLChange(Sender: TObject);
begin
   GetSamplingDetail;
   {
   dsrcSamplingPlan.DataSet := fQuality.qryData;
   with fQuality.qryData do
   begin
     try
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'SAMPLING_TYPE',ptInput);
        CommandText := 'Select C.MIN_LOT_SIZE "Min Size" ,C.MAX_LOT_SIZE "Max Size" '
                      +'      ,C.SAMPLE_SIZE "Sample Size", CRITICAL_REJECT_QTY "Critical Qty"   '
                      +'      , MAJOR_REJECT_QTY "Major Qty", MINOR_REJECT_QTY "Minor Qty" '
                      +'From '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN_DETAIL C, '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN D '
                      + 'Where D.SAMPLING_TYPE = :SAMPLING_TYPE '
                      + '  AND C.SAMPLING_ID = D.SAMPLING_ID '
                       +'ORDER BY MIN_LOT_SIZE ';
        Params.ParamByName('SAMPLING_TYPE').AsString := cmbAQL.Text;
        Open;
     finally

     end;
   end;
   }
end;

procedure TfAQL.FormShow(Sender: TObject);
begin
   if cmbAQL.ItemIndex >=0 then
     cmbAQLChange(self);
end;
procedure TfAQL.GetSamplingDetail;
begin
   dsrcSamplingPlan.DataSet := fQuality.qryData;
   with fQuality.qryData do
   begin
     try
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'SAMPLING_TYPE',ptInput);
        Params.CreateParam(ftString,'SAMPLING_LEVEL',ptInput);
        CommandText := 'Select C.MIN_LOT_SIZE "Min Size" ,C.MAX_LOT_SIZE "Max Size" '
                      +'      ,C.SAMPLE_SIZE "Sample Size", CRITICAL_REJECT_QTY "Critical Qty"   '
                      +'      , MAJOR_REJECT_QTY "Major Qty", MINOR_REJECT_QTY "Minor Qty" '
                      +'From '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN_DETAIL C, '
                      + 'SAJET.SYS_QC_SAMPLING_PLAN D '
                      + 'Where D.SAMPLING_TYPE = :SAMPLING_TYPE '
                      + '  AND C.SAMPLING_ID = D.SAMPLING_ID '
                      + '  AND C.SAMPLING_LEVEL =:SAMPLING_LEVEL '
                       +'ORDER BY MIN_LOT_SIZE ';
        Params.ParamByName('SAMPLING_TYPE').AsString := cmbAQL.Text;
        Params.ParamByName('SAMPLING_LEVEL').AsString :=IntToStr(combLevel.ItemIndex);
        Open;
     finally

     end;
   end;
end;


procedure TfAQL.combLevelChange(Sender: TObject);
begin
GetSamplingDetail
end;

end.

