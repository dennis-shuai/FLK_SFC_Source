unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls,DateUtils;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    SProc: TClientDataSet;
    QryReel: TClientDataSet;
    QryHT: TClientDataSet;
    Label2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    cmbSeg: TComboBox;
    DBGrid1: TDBGrid;
    sbtnQuery: TSpeedButton;
    Imagenewtargetqty: TImage;
    DataSource1: TDataSource;
    Label3: TLabel;
    cmbProcess: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure cmbSegSelect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;
  end;

var
  fDetail: TfDetail;
implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  DateTimePicker1.Date := Today;

end;


procedure TfDetail.sbtnQueryClick(Sender: TObject);
var StartTime,EndTime,sWO:string;
begin
    StartTime := FormatDateTime('YYYYMMDD',datetimepicker1.date)+'08';
    EndTime :=FormatDateTime('YYYYMMDD',datetimepicker1.date+1)+'08';

    if cmbSeg.Text ='SMT' then sWO :='NMS%'
    else if cmbSeg.Text ='COB' then sWO :='NM%'
    else if cmbSeg.Text ='CM' then sWO :='NMA%'
    else  sWO :='NM%';

    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'StartTime',ptInput);
    qrytemp.Params.CreateParam(ftstring,'EndTime',ptInput);
    qrytemp.Params.CreateParam(ftstring,'Seg',ptInput);
    qrytemp.Params.CreateParam(ftstring,'sWO',ptInput);
    qrytemp.Params.CreateParam(ftstring,'Process',ptInput);
    qrytemp.CommandText :=' SELECT AA.model_name,AA.PROCESS_NAME,AA.OUTPUT_QTY ,BB.TARGET_QTY PLAN_QTY ,ROUND(DECODE(BB.TARGET_QTY,0,0,AA.OUTPUT_QTY/BB.TARGET_QTY*100),1) RATE FROM '+
                         ' (                                                                   '+
                         ' SELECT model_name,PROCESS_NAME,SUM(output_qty) output_qty FROM      '+
                         ' (select c.model_name,d.Process_name,nvl(Sum(a.output_qty),0) output_qty  from sajet.g_sn_count a,sajet.sys_part b,sajet.sys_model c ,'+
                         ' sajet.sys_process d where a.process_id =d.Process_id  and a.model_id= b.part_id and b.model_id =c.Model_id  and a.work_order like  :sWO  '+
                         ' and to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) >=:StartTime and d.Process_name=:PROCESS '+
                         ' and to_char(WORK_DATE)||TRIM(to_CHAR(WORK_TIME,''00'')) <:endTime  group by c.Model_Name,d.process_name  '+
                         ' UNION                                                                       '+
                         ' SELECT A.MODEL_NAME, :PROCESS  PROCESS_NAME ,0 OUTPUT_QTY  FROM SAJET.G_PDLINE_MANAGE A,SAJET.SYS_PDLINE B  '+
                         ' WHERE  A.PDLINE_ID=B.PDLINE_ID AND B.PDLINE_NAME LIKE :Seg AND A.STARTTIME >= :StartTime  '+
                         ' AND A.ENDTIME <=:endTime  and Model_Name is not NUll) GROUP BY model_name,PROCESS_NAME ) AA,   '+
                         ' (                                                              '+
                         ' SELECT A.MODEL_NAME,NVL(SUM(A.PRODUCE_QTY),0) TARGET_QTY FROM SAJET.G_PDLINE_MANAGE A,SAJET.SYS_PDLINE B '+
                         ' WHERE  A.PDLINE_ID=B.PDLINE_ID AND B.PDLINE_NAME LIKE :Seg AND A.STARTTIME >= :StartTime   '+
                         ' AND A.ENDTIME <=:endTime  GROUP BY A.MODEL_NAME) BB WHERE AA.MODEL_NAME = BB.MODEL_NAME(+) '+
                         ' ORDER BY AA.MODEL_NAME ';
    qrytemp.Params.ParamByName('StartTime').AsString  := StartTime ;
    qrytemp.Params.ParamByName('EndTime').AsString  := EndTime;
    qrytemp.Params.ParamByName('Seg').AsString  :=cmbSeg.Text+'%';
    qrytemp.Params.ParamByName('sWO').AsString  := sWO;
    qrytemp.Params.ParamByName('Process').AsString  :=cmbProcess.Text;
    qrytemp.Open;



end;

procedure TfDetail.cmbSegSelect(Sender: TObject);
begin
   if cmbSeg.ItemIndex =0 then begin
       cmbProcess.Items.Clear;
       cmbProcess.Items.Add('SMT_INPUT_T');
       cmbProcess.Items.Add('SMT_MOUNT_T');
       cmbProcess.Items.Add('SMT_VI_T');
       cmbProcess.ItemIndex := 2;
   end;

   if cmbSeg.ItemIndex =1 then begin
       cmbProcess.Items.Clear;
       cmbProcess.Items.Add('RANK PCB');
       cmbProcess.Items.Add('DIE BOND');
       cmbProcess.Items.Add('HODLE MOUNT');
       cmbProcess.Items.Add('COB-VI');
       cmbProcess.ItemIndex := 2;

   end;


   if cmbSeg.ItemIndex =2 then begin
       cmbProcess.Items.Clear;
       cmbProcess.Items.Add('AutoTest');
       cmbProcess.Items.Add('FQC');
       cmbProcess.Items.Add('OTP');
       cmbProcess.Items.Add('CM-VI');
       cmbProcess.ItemIndex := 3;

   end;

end;

end.

