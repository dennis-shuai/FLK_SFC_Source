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
    lblRest: TLabel;
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
    Count:Integer;
    UpDate_Time :TDateTime;
  end;

var
  Form1: TForm1;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;



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

       edtCarrier.ReadOnly :=false;
       edtWo.ReadOnly :=true;
       edtCarrier.SetFocus;
       edtCarrier.Clear;
       lblMsg.Caption := 'WO OK,Please Input Carrier';
       lblMsg.Color :=clGreen;

    end;
end;

procedure TForm1.edtCarrierKeyPress(Sender: TObject; var Key: Char);
var SN: array [0..7] of string;
    SNSet:string;
    i,Carrier_Count,Rest_Count: integer;
    date :TDate;
begin
    if Key <> #13 then exit;

     lblMsg.Caption := '請掃描Carrier';
     lblMsg.Color :=clYellow;

    if Length(edtCarrier.Text) =0 then exit;

    if Length(edtCarrier.Text) <> 5 then begin
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

    if   QryTemp.FieldByName('C_NO').AsInteger <>0 then begin
        lblMsg.Caption := '該Carrier上還有產品';
        lblMsg.Color :=clRed;
        MessageDlg('該Carrier上還有產品,請檢查',mterror,[mbOK],0);
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;

    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'WO',ptInput);
    QryTemp.Params.CreateParam(ftString,'PROCESS_ID',ptInput);
    QryTemp.CommandText := ' select a.work_order ,A.SERIAL_NUMBER, a.Box_NO ,a.IN_PDLINE_TIME , b.Process_NAME '+
                           ' from SAJET.G_SN_STATUS a,SAJET.SYS_PROCESS b    '+
                           ' where  A.WIP_PROCESS = b.Process_ID and WORK_Order=:WO and '+
                           ' b.PROCESS_ID = :Process and a.Current_status=0 order by a.IN_PDLINE_TIME ASC ';
    QryTemp.Params.ParamByName('Process').AsString := G_sProcessID;
    QryTemp.Params.ParamByName('WO').AsString := edtWO.Text;
    QryTemp.Open;

    if  QryTemp.IsEmpty then begin
        lblMsg.Caption := '該工單已經滿了,請投入其他工單';
        lblMsg.Color :=clRed;
        MessageDlg('該工單已經滿了,請投入其他工單',mterror,[mbOK],0);
        edtCarrier.Clear;
        edtCarrier.SetFocus;
        exit;
    end;


    Rest_Count:=   QryTemp.RecordCount;
    lblRest.Caption :=IntToStr(Rest_Count);


    if  QryTemp.RecordCount <8 then begin
        Carrier_Count :=QryTemp.RecordCount ;
        QryTemp.First;
        for i:=0 to  Carrier_Count-1 do begin
           SN[i] := QryData.fieldbyName('Serial_Number').AsString;
           QryTemp.Next;
        end;
    end else begin
        Carrier_Count := 8;
        QryTemp.First;
        for i:=0 to  7 do begin
           SN[i] := QryTemp.fieldbyName('Serial_Number').AsString;
           QryTemp.Next;
        end;

    end;
    SNSet :='';
    for i:=0 to  Carrier_Count-1 do begin
        SNSet := SNSet +''''+ SN[i]+''',';
    end;
    
    SNSet := Copy( SNSet,1,Length(SNSet)-1);
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Carrier',ptInput);
    QryTemp.CommandText := 'UPDATE SAJET.G_SN_STATUS Set BOX_NO=:Carrier where Serial_Number IN (' +SNSet+')';
    QryTemp.Params.ParamByName('Carrier').AsString :=edtCarrier.Text ;
    QryTemp.Execute;
     


    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftString,'WO',ptInput);
    QryData.Params.CreateParam(ftString,':Carrier',ptInput);
    QryData.CommandText := 'select * from  SAJET.G_SN_STATUS where  WORK_ORDER=:WO and BOX_NO=:Carrier';
    QryData.Params.ParamByName('WO').AsString :=edtWO.Text;
    QryData.Params.ParamByName('Carrier').AsString :=edtCarrier.Text ;
    QryData.Open;



    SPROC.Close;
    Sproc.DataRequest('SAJET.sj_carrier_go');
    Sproc.FetchParams;
    Sproc.Params.ParamByName('tterminalid').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('trev').AsString :=G_sTerminalID;
    Sproc.Params.ParamByName('tdefect').AsString :='N/A';
    Sproc.Params.ParamByName('tnow').AsDate := Now;
    Sproc.Params.ParamByName('tTray').AsString :=edtCarrier.Text;
    Sproc.Params.ParamByName('temp').AsString :=UpdateUserID;
    Sproc.Execute;

    lblRest.Caption :=IntToStr(Rest_Count-Carrier_Count);
    lblMsg.Caption := ' Carrier :'+edtCarrier.Text +' OK';
    lblMsg.Color :=clGreen;
    edtCarrier.Clear;
    edtCarrier.SetFocus;

end;

end.
