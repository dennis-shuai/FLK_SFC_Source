unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    edtPartNo: TEdit;
    lblNCount: TLabel;
    Label3: TLabel;
    cmbName: TComboBox;
    DBGrid1: TDBGrid;
    sbtnQuery: TSpeedButton;
    Image5: TImage;
    sbtnExport: TSpeedButton;
    Image1: TImage;
    Label2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label4: TLabel;
    DateTimePicker2: TDateTimePicker;
    procedure FormShow(Sender: TObject);
    procedure cmbNameSelect(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
     mPartID,UpdateUserID:string;

  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit;


procedure TfDetail.FormShow(Sender: TObject);
begin
   with QryTemp do begin
     close;
     params.clear;
     commandtext :='Select Distinct ORT_NAME FROM SAJET.CCM_ORT_SN ';
     open;
     first;
     while  not eof do begin
       cmbName.Items.Add(fieldbyname('ORT_NAME').AsString);
       next;
     end;
   end;
   datetimepicker1.Date :=today;
   datetimepicker2.Date :=tomorrow;
   cmbName.Style := csDropDownList;
   cmbName.SetFocus;
end;

procedure TfDetail.cmbNameSelect(Sender: TObject);
begin
   edtPartNo.Enabled := true;
   edtPartNo.Text :='';
   edtPartNo.SetFocus;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
   with qrydata do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'NAME',ptInput);
       params.CreateParam(ftstring,'StartTime',ptInput);
       params.CreateParam(ftstring,'EndTime',ptInput);
       commandtext :=' select a.ORT_Name,decode(a.customer_sn,''N/A'',a.serial_number,a.customer_sn) SN ,C.PART_NO,a.update_TIME,b.EMP_NO,b.EMP_NAME ,a.enabled '+
                    ' from sajet.ccm_ort_sn a,sajet.sys_emp b,sajet.sys_part c '+
                    ' where a.ORT_NAME =:NAME and a.model_id =c.part_id and a.UPDATE_USERID= b.emp_id '+
                    ' and a.update_time >= :starttime and a.update_time <:endtime';
       if edtpartNo.text <> '' then begin
          commandtext := commandtext + '  and c.Part_no ='''+edtpartno.Text +'''';
       end;
       
       params.ParamByName('NAME').AsString := cmbName.Text;
       params.ParamByName('StartTime').AsDate:= datetimepicker1.Date;
       params.ParamByName('EndTime').AsDate := datetimepicker2.Date;
      open;
   end;
end;

procedure TfDetail.sbtnExportClick(Sender: TObject);
var s,sFileName,prfix:string;
i,j:integer;
F:TextFile;
begin
  if qrydata.IsEmpty then exit;
  if saveDialog1.Execute then
    if saveDialog1.fileName ='' then exit;
    prfix :=  Copy(saveDialog1.fileName,Length(saveDialog1.fileName)-3,4);
    if prfix <>'.CSV' then begin
       sFileName := saveDialog1.fileName+'.csv';
       
    if fileexists( saveDialog1.fileName) then
     deletefile(  saveDialog1.fileName);
    end;
    AssignFile (F, sFileName);
    ReWrite(F);
    S:='';
    for  I:=0 to qrydata.FieldCount-1 do
      S:=S+qrydata.Fields[i].FieldName+','  ;
    WriteLn(F,S);

    qrydata.First;
    for  j:=0 to qrydata.RecordCount-1 do begin
      Application.ProcessMessages;
      S:='';
      for  i:=0 to qrydata.FieldCount-1 do
       S:=S+qrydata.Fields.Fields[i].AsString+','  ;
       WriteLn(F,S);
       qrydata.Next;
    end;
    CloseFile(F);
end;

end.
