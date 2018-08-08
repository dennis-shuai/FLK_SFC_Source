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
      procedure FormCreate(Sender: TObject);
      procedure sbtnCancelClick(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
    procedure cmbAQLChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      procedure GetAllPlan;
      procedure SetTheRegion;
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
   with fQuality.QryTemp do
   begin
      Close;
      CommandText := 'Select SAMPLING_TYPE, SAMPLE_SIZE, CRITICAL_REJECT_QTY, MAJOR_REJECT_QTY, MINOR_REJECT_QTY ' +
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
begin
   // 維持原抽樣計畫
   if (cmbAQL.Text = fQuality.LabInspType.Caption) then
      Close
   else
   begin
      sSamplingSize := fQuality.LabSampleQty.Caption;
      sCriQty := fQuality.LabCriQty.Caption;
      sMajQty := fQuality.LabCriQty.Caption;
      sMinQty := fQuality.LabMinQty.Caption;
      sSamplingID := fQuality.GetSamplingPlan(cmbAQL.Text);
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

procedure TfAQL.cmbAQLChange(Sender: TObject);
begin
   dsrcSamplingPlan.DataSet := fQuality.QryTemp;
   with fQuality.QryTemp do
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
end;

procedure TfAQL.FormShow(Sender: TObject);
begin
   if cmbAQL.ItemIndex >=0 then
     cmbAQLChange(self);
end;

end.

