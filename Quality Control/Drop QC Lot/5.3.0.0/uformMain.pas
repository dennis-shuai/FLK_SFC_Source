unit uformMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, DB, DBClient, Grids, DBGrids;

type
  TformMain = class(TForm)
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    dsrcLot: TDataSource;
    DBGrid1: TDBGrid;
    Image3: TImage;
    Label2: TLabel;
    lablRecordcount: TLabel;
    sbtnAddMore: TSpeedButton;
    procedure sbtnAddMoreClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetUnusedLot;
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

procedure TformMain.GetUnusedLot;
var sLotNO:String;
begin
  with qryData do
  begin
    try
      Close;
      Params.Clear;
      CommandText := 'Select A.QC_LOTNO ,A.NG_CNT,A.START_TIME,A.END_TIME,A.LOT_SIZE,A.PASS_QTY,A.FAIL_QTY '
                    +'       ,A.QC_RESULT,C.EMP_NAME '
                    +'       ,B.TERMINAL_NAME '
                    + ' FROM SAJET.G_QC_LOT A '
                    +'      ,SAJET.SYS_TERMINAL B '
                    +'      ,SAJET.SYS_EMP C '
                    +'  WHERE A.LOT_SIZE = 0 '
                    +'    AND A.TERMINAL_ID = B.TERMINAL_ID(+) '
                    +'    AND A.INSP_EMPID = C.EMP_ID (+) '
                    +'  ORDER BY A.QC_LOTNO,A.NG_CNT ';
     Open;
     lablRecordcount.Caption := IntToStr(RecordCount);
    except
    end;
  end;
end;

procedure TformMain.sbtnAddMoreClick(Sender: TObject);
var sLotNo:string;
begin
  if (not qryData.Active) or (qryData.Eof) then exit;
  sLotNo := qryData.FieldByName('QC_LOTNO').AsString;
  IF MessageDlg('Are you sure to Drop Lot No : '+sLotNo+' ? ',mtConfirmation,[mbOK,mbCancel],0) <> mrOK then exit;
  //檢查是不是有檢驗記錄
  with qryTemp do
  begin
    try
      try
        close;
        Params.Clear;
        Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
        commandText := 'Select serial_number from sajet.g_qc_sn '
                      +'  wherer qc_lotno = :QC_LOTNO '
                      +'  and rownum = 1 ';
        Params.ParamByName('QC_LOTNO').AsString := sLotNo;
        if not eof then
        begin
          MessageDlg('Lot No : '+ sLotNo +' Can''t be Deleted!',mtWarning,[mbOK],0);
          exit;
        end;
        close;
        Params.Clear;
        Params.CreateParam(ftString, 'QC_LOTNO', ptInput);
        commandText := ' DELETE SAJET.G_QC_LOT '
                      +'  where qc_lotno = :QC_LOTNO ';
        Params.ParamByName('QC_LOTNO').AsString := sLotNo;
        Execute;
        GetUnusedLot;
      except
        on E : Exception do
          MessageDlg('Delete Lot Error!'+#10#13+E.MESSAGE,mtError,[mbOK],0);
      end;
    finally
      close;
    end;
  end;
end;

procedure TformMain.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80,100);
    800: self.ScaleBy(100,100);
    1024: self.ScaleBy(125,100);
  else
    self.ScaleBy(100,100);
  end;

  GetUnusedLot;
end;

procedure TformMain.FormDestroy(Sender: TObject);
begin
  qryData.Close;
end;

end.
