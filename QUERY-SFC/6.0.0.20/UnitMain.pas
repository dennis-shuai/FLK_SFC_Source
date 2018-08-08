unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, DB, DBClient, MConnect, ObjBrkr, SConnect;

type
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    MATERIAL1: TMenuItem;
    byWO1: TMenuItem;
    CONFIRMbyWO1: TMenuItem;
    INTERFACE1: TMenuItem;
    WOERPSFC1: TMenuItem;
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Clientdataset1: TClientDataSet;
    Close1: TMenuItem;
    byWO2: TMenuItem;
    EDI1: TMenuItem;
    IN8561: TMenuItem;
    WIP1: TMenuItem;
    N1: TMenuItem;
    IN8611: TMenuItem;
    PT8671: TMenuItem;
    OUT8561: TMenuItem;
    N2: TMenuItem;
    ByIDNO1: TMenuItem;
    ByPartNO1: TMenuItem;
    OOLING1: TMenuItem;
    Feefer1: TMenuItem;
    Feeder1: TMenuItem;
    Feeder2: TMenuItem;
    QC2: TMenuItem;
    Repair2: TMenuItem;
    QCQuerybyWO2: TMenuItem;
    QCDIRQuery2: TMenuItem;
    RepairresultforRepair1: TMenuItem;
    Repairresultforqc1: TMenuItem;
    QueryHDDSNBYDN1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure byWO1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure CONFIRMbyWO1Click(Sender: TObject);
    procedure WOERPSFC1Click(Sender: TObject);
    procedure byWO2Click(Sender: TObject);
    procedure IN8561Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure IN8611Click(Sender: TObject);
    procedure PT8671Click(Sender: TObject);
    procedure OUT8561Click(Sender: TObject);
    procedure ByIDNO1Click(Sender: TObject);
    procedure ByPartNO1Click(Sender: TObject);
    procedure QC1Click(Sender: TObject);
    procedure Feefer1Click(Sender: TObject);
    procedure Feeder1Click(Sender: TObject);
    procedure Feeder2Click(Sender: TObject);
    procedure AfterRepaired1Click(Sender: TObject);
    procedure repairresult1Click(Sender: TObject);
    procedure QCquerybyWO1Click(Sender: TObject);
    procedure QCDIRQuery1Click(Sender: TObject);
    procedure QCQuerybyWO2Click(Sender: TObject);
    procedure QCDIRQuery2Click(Sender: TObject);
    procedure RepairresultforRepair1Click(Sender: TObject);
    procedure Repairresultforqc1Click(Sender: TObject);
    procedure QueryHDDSNBYDN1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LoginUserID  : String;
    function LoadApServer : Boolean;
  end;

var
  FormMain: TFormMain;

implementation

uses UnitQueryCheckMaterialByWO, UnitQueryConfirmMaterialByWO,
  UnitQUERYWOBOMERPTOSFC, UnitQueryReturnMaterialByWO, UnitEDIIN856Query,
  UnitWIPVerQuery, UnitEDIIN861Query, UnitEDIPT867Query,
  UnitEDIOUT856Query, UnitMaterialYDQuerybyIDNO,
  UnitMaterialYDQuerybyPartNO, UnitWIPqcquery, UnitToolingFeederquery,
  Unittoolingfeederbaoyangquery, Unittoolingfeederrepairquery,
  UnitwipRepairresultquery, UnitWIPQCDIRQuery,
  UnitWIPRepairresultQueryForQC, UnitEDITQueryHDDSNBYDNNO;

{$R *.dfm}

function TformMain.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
    LoginUserID := ParamStr(1);
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 LoadApServer;
{  with csFTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'EMP_ID', ptInput);
    CommandText := 'SELECT EMP_NO, EMP_NAME, PASSWD, ENABLED '+
                   '  FROM SAJET.SYS_EMP '+
                   ' WHERE UPPER(EMP_ID) = :EMP_ID ';
    Params.ParamByName('EMP_ID').AsString := UpperCase(Trim(LoginUserID)) ;
    Open;
    if RecordCount > 0 Then
    begin
      LabNO.Caption := Fieldbyname('EMP_NO').AsString;
      LabName.Caption := Fieldbyname('EMP_NAME').AsString;
    end else
    begin
      // 檢查是否為系統使用者
      if LoginUserID <> 'Steven&Jack&Tommy' Then
      begin
        Close;
        MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
      end;
      LabNO.Caption := 'Administrator';
      LabName.Caption := '';
      Close;
    end;
  end; }
end;

procedure TFormMain.byWO1Click(Sender: TObject);
begin
      FormQueryCheckMaterialByWO.SHOWMODAL;
end;

procedure TFormMain.Close1Click(Sender: TObject);
begin
   close;
end;

procedure TFormMain.CONFIRMbyWO1Click(Sender: TObject);
begin
   FormQueryConfirmMaterialByWO.SHOWMODAL;
end;

procedure TFormMain.WOERPSFC1Click(Sender: TObject);
begin
     FormQUERYWOBOMERPTOSFC.SHOWMODAL;
end;

procedure TFormMain.byWO2Click(Sender: TObject);
begin
      FormReturnMaterialByWO.showmodal;
end;

procedure TFormMain.IN8561Click(Sender: TObject);
begin
    FORMEDIIN856QUERY.SHOWMODAL
end;

procedure TFormMain.N1Click(Sender: TObject);
begin
    FormWIPverQuery.showmodal;
end;

procedure TFormMain.IN8611Click(Sender: TObject);
begin
    FormEDIIN861Query.showmodal;
end;

procedure TFormMain.PT8671Click(Sender: TObject);
begin
  formEDIpt867.showmodal;
end;

procedure TFormMain.OUT8561Click(Sender: TObject);
begin
   FORMOUT856.SHOWMODAL;
end;

procedure TFormMain.ByIDNO1Click(Sender: TObject);
begin
    FormYDQueryByIDNO.showmodal;
end;

procedure TFormMain.ByPartNO1Click(Sender: TObject);
begin
    FormYDQueryBYPartNO.SHOWMODAL;
end;

procedure TFormMain.QC1Click(Sender: TObject);
begin
    // FormWIPQCQuery.Showmodal;
end;

procedure TFormMain.Feefer1Click(Sender: TObject);
begin
     FormToolingFeeder.showmodal;
end;

procedure TFormMain.Feeder1Click(Sender: TObject);
begin
    Formfeederbaoyangquery.showmodal;
end;

procedure TFormMain.Feeder2Click(Sender: TObject);
begin
    Formfeederrepairquery.showmodal;
end;

procedure TFormMain.AfterRepaired1Click(Sender: TObject);
begin
    FormRepairResultQuery.showmodal;
end;

procedure TFormMain.repairresult1Click(Sender: TObject);
begin
    FormRepairResultQuery.showmodal;
end;

procedure TFormMain.QCquerybyWO1Click(Sender: TObject);
begin
    FormWIPQCQuery.Showmodal;
end;

procedure TFormMain.QCDIRQuery1Click(Sender: TObject);
begin
    FormWIPQCDIRquery.showmodal;
end;

procedure TFormMain.QCQuerybyWO2Click(Sender: TObject);
begin
     FormWIPQCQuery.Showmodal;
end;

procedure TFormMain.QCDIRQuery2Click(Sender: TObject);
begin
     FormWIPQCDIRquery.showmodal;
end;

procedure TFormMain.RepairresultforRepair1Click(Sender: TObject);
begin
     FormRepairResultQuery.showmodal;
end;

procedure TFormMain.Repairresultforqc1Click(Sender: TObject);
begin
    FormWipRepairresultforQC.showmodal;
end;

procedure TFormMain.QueryHDDSNBYDN1Click(Sender: TObject);
begin
   FormEdiqueryhddsnbyDNNO.SHOWMODAL;
end;

end.
