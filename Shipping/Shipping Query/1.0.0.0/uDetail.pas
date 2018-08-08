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
    sbtnQuery: TSpeedButton;
    ImageSample: TImage;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    edtDNO: TEdit;
    Label2: TLabel;
    btnNewNo: TBitBtn;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNewNoClick(Sender: TObject);
    procedure edtDNOKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;

  end;

var
  fDetail: TfDetail;
 // mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit,uCommData;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin

     QryData.Close;
     QryData.Params.Clear;
     QryData.Params.CreateParam(ftString,'DN_NO',ptinput);
     QryData.CommandText :='   select a.Serial_number, a.Customer_SN,a.Pallet_NO,a.Carton_NO,a.BOX_NO ,B.DN_NO ,A.UPDATE_TIME  from SAJET.G_SHIPPING_SN a '+
                           '  ,SAJET.G_DN_BASE b where a.DN_ID=b.DN_ID and b.DN_NO=:DN_NO ';
     QryData.Params.ParamByName('DN_NO').AsString := edtDNO.Text;
     QryData.Open;
     Count := QryData.RecordCount;
     Label2.Caption := IntToStr(Count)+'µ§¼Æ¾Ú';
     if not QryData.IsEmpty then edtDNO.Text :='';

end;

procedure TfDetail.sBtnExportClick(Sender: TObject);
var
     strNTF :string;
     strTitle,strFPY,strPDline,strPDLineFrist,strRepass,strTotal,strDefectName,strDefect_QTY,strDefect_Desc :string;
    i,j,LineCount,UsedRow,UsedCount,defect_count,count:integer;
    ExcelApp: Variant;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);

        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;


        if not QryData.IsEmpty then
        begin
             QryData.First;


             for i:=0 to QryData.FieldCount -1 do begin

                ExcelApp.Cells[1,i+1].Value :=   QryData.Fields.Fields[i].FieldName ;

             end;

             for  i:=0 to QryData.RecordCount-1  do
             begin
                     Application.ProcessMessages;
                      for j:=0 to QryData.FieldCount -1 do
                      begin
                          ExcelApp.Cells[2+i,j+1].Value :=   QryData.Fields.Fields[j].AsString ;
                      end;

                  QryData.Next;
             end;
        end;

        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('Save OK',mtConfirmation,[mbyes],0);

    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
    edtDNO.SetFocus;
end;

procedure TfDetail.btnNewNoClick(Sender: TObject);
var Key: Char;
begin
  with TfCommData.Create(Self) do
  begin
    LabType2.Caption := 'DN List';
    LabType1.Caption := LabType2.Caption;
    Label1.Caption := 'Search Model Name';
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if edtDNO.Text <>'' then
          Params.CreateParam(ftString, 'Model', ptInput);
      CommandText := 'Select a.DN_NO,b.qty ,c.part_no,d.model_name,a.update_time ' +
        'From SAJET.G_DN_BASE a,sajet.g_dn_detail b, sajet.sys_part c,sajet.sys_Model d ' +
        'Where  a.dn_id=b.dn_id and b.part_id=c.part_id and a.work_flag = 0 '+
        'and c.model_id=d.model_id ' ;
      if edtDNO.Text <>'' then
          CommandText := CommandText + 'and d.model_Name like :Model ';
      CommandText := CommandText + 'Order By d.model_name ,a.update_time';
      if edtDNO.Text <>'' then
         Params.ParamByName('Model').AsString := edtDNO.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      edtDNO.Text := QryTemp.FieldByName('DN_No').AsString;
      Key := #13;
      edtDNO.OnKeyPress(Self, Key);
      QryTemp.Close;
    end;
    free;
  end;
end;

procedure TfDetail.edtDNOKeyPress(Sender: TObject; var Key: Char);
begin
   if Key =#13 then
      sbtnQuery.Click;
end;

end.
