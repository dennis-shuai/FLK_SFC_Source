unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    edtWO: TEdit;
    Label2: TLabel;
    edtCarrier: TEdit;
    lblMsg: TLabel;
    lblTerminal: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtCarrierKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count,Input_Qty:Integer;
    UpDate_Time :TDateTime;
    Function GetSysDate:TDateTime;
  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;

Function TForm1.GetSysDate:TDateTime;
begin
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.CommandText := 'Select sysdate as Curr_Time from dual';
    QryTemp.open ;
    result := qrytemp.fieldbyname('Curr_Time').AsDateTime;
end;

procedure TForm1.FormShow(Sender: TObject);
var iniFile:TIniFile;

begin
    iniFile :=TIniFile.Create('SAJET.ini');
    G_sTerminalID :=iniFile.ReadString('COB','Terminal','N/A' );
    iniFile.Free;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Terminal_ID',ptInput);
    QryTemp.CommandText := 'select  b.PDLINE_NAME||''\''||a.Terminal_Name as Terminal ,a.Process_ID,b.PDLINE_ID ,a.Stage_ID from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and Terminal_ID=  :Terminal_ID and a.Enabled=''Y'' ';
    QryTemp.Params.ParamByName('Terminal_ID').AsString := G_sTerminalID;
    QryTemp.Open;

    lblTerminal.Caption := QryTemp.fieldByName('Terminal').AsString ;
    G_sProcessID := QryTemp.fieldByName('Process_ID').AsString ;
    G_sPDLineID := QryTemp.fieldByName('Process_ID').AsString ;
    G_sStageID := QryTemp.fieldByName('Stage_ID').AsString ;
    edtWO.SetFocus;

end;

procedure TForm1.edtWOKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <> #13 then exit;

    with Sproc do
    begin
      Sproc.Close;
      Sproc.DataRequest('sajet.SJ_CHK_WO_INPUT');
      Sproc.FetchParams();
      Sproc.Params.ParamByName('TREV').AsString := edtWO.Text;
      Sproc.Execute;
      if  Sproc.Params.ParamByName('TRES').AsString <> 'OK' then
      begin
          edtCarrier.ReadOnly :=true;
          edtWo.ReadOnly :=false;
          edtWo.SetFocus;
          edtWo.SelectAll;
          lblMsg.Caption := Sproc.Params.ParamByName('TRES').AsString;
          lblMsg.Color :=clRed;
          Exit;
      end;

      QryTemp.Close;
      QryTemp.Params.Clear;
      QryTemp.Params.CreateParam(ftString,'WO',ptInput);
      QryTemp.CommandText :='Select Target_QTY ,Input_Qty From SAJET.G_WO_BASE WHERE WORK_ORDER=:WO';
      QryTemp.Params.ParamByName('WO').AsString := edtWO.Text;
      QryTemp.Open;
      Input_Qty :=QryTemp.fieldByName('Input_Qty').AsInteger;
      Label3.Caption := '總數:'+ QryTemp.fieldByName('Target_Qty').AsString ;
      Label4.Caption := '投入數:'+ QryTemp.fieldByName('Input_Qty').AsString ;
      edtCarrier.ReadOnly :=false;
      edtWo.ReadOnly :=true;
      edtCarrier.SetFocus;
      edtCarrier.Clear;
      lblMsg.Caption := 'WO OK,Please Input Carrier';
      lblMsg.Color :=clGreen;

    end;
end;

procedure TForm1.edtCarrierKeyPress(Sender: TObject; var Key: Char);
var  emp_no :String;
    i,Carrier_Count: integer;
    date :TDate;
begin
    if Key <> #13 then exit;

     lblMsg.Caption := '請掃描Carrier';
     lblMsg.Color :=clYellow;

    if Length(edtCarrier.Text) =0 then exit;

    if (Length(edtCarrier.Text) < 5) or  (Length(edtCarrier.Text) >6)   then begin
        lblMsg.Caption := ' Carrier 號碼長度錯誤';
        lblMsg.Color :=clRed;
        MessageDlg('Carrier 號碼長度錯誤',mterror,[mbOK],0);
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;

    if Copy(edtCarrier.Text,1,1) <>'C'  then begin
        lblMsg.Caption := ' Carrier 編碼錯誤';
        lblMsg.Color :=clRed;
        MessageDlg('Carrier 編碼錯誤',mterror,[mbOK],0);
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Carrier',ptInput);
    QryTemp.CommandText := 'Select Count(*) as C_NO from  sajet.g_SN_STATUS    where BOX_NO = :Carrier ';
    QryTemp.Params.ParamByName('Carrier').AsString := edtCarrier.Text;
    QryTemp.Open;

    if   QryTemp.FieldByName('C_NO').AsInteger <>0  then begin
        lblMsg.Caption := '該Carrier上還有產品';
        lblMsg.Color :=clRed;
        //MessageDlg('該Carrier上還有產品,請檢查',mterror,[mbOK],0);
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'WO',ptInput);
    QryTemp.CommandText := 'select Count(*) C_COUNT from  SAJET.G_SN_STATUS where  WORK_ORDER=:WO and ' +
                           ' PROCESS_ID =0 and PDLINE_ID =0 and ROWNUM<=8 ORDER BY SERIAL_NUMBER';
    QryTemp.Params.ParamByName('WO').AsString :=edtWO.Text;
    QryTemp.Open;
    Carrier_Count := QryTemp.FieldByname('C_COUNT').AsInteger;
    if  Carrier_Count =0  then begin
        lblMsg.Caption := '沒有條碼可排片,請先展條碼';
        lblMsg.Color :=clRed;
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Carrier',ptInput);
    QryTemp.Params.CreateParam(ftString,'WO',ptInput);
    QryTemp.CommandText := ' UPDATE SAJET.G_SN_STATUS Set BOX_NO=:Carrier where WORK_ORDER =:WO and PROCESS_ID =0 ' +
                           ' and PDLINE_ID =0 and ROWNUM<=8  ';
    QryTemp.Params.ParamByName('Carrier').AsString :=edtCarrier.Text ;
    QryTemp.Params.ParamByName('WO').AsString :=edtWO.Text ;
    QryTemp.Execute;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Temp',ptInput);
    QryTemp.CommandText := 'select  EMP_NO from sajet.sys_EMP where EMP_ID =:TEMP';
    QryTemp.Params.ParamByName('Temp').AsString :=UpdateUserID;
    QryTemp.Open;
    emp_no := QryTemp.FieldByname('EMP_NO').AsString;


    SPROC.Close;
    Sproc.DataRequest('SAJET.sj_SMT_PANEL_GO2');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('tterminalid').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('tnow').AsDate := GetSysDate;
    Sproc.Params.ParamByName('TPANEL1').AsString :=edtCarrier.Text;
    Sproc.Params.ParamByName('temp').AsString :=emp_no;
    Sproc.Execute;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'WO',ptInput);
    QryData.Params.CreateParam(ftString,'Carrier',ptInput);
    QryData.CommandText := 'select WORK_ORDER,SERIAL_NUMBER,BOX_NO,OUT_PROCESS_TIME from  SAJET.G_SN_STATUS where '+
                           ' WORK_ORDER=:WO and BOX_NO=:Carrier ';
    QryData.Params.ParamByName('WO').AsString :=edtWO.Text;
    QryData.Params.ParamByName('Carrier').AsString :=edtCarrier.Text ;
    QryData.Open;

    Label4.Caption := '投入數:' +IntToStr(Input_QTY+Carrier_COunt);
    lblMsg.Caption := ' Carrier :'+edtCarrier.Text +' OK';
    lblMsg.Color :=clGreen;
    edtCarrier.Clear;
    edtCarrier.SetFocus;

end;

end.
