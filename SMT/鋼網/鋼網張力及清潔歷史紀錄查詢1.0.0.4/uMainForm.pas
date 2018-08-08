unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, comobj;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    Label2: TLabel;
    EditSN: TEdit;
    labInputQty: TLabel;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Query: TSpeedButton;
    Image3: TImage;
    EditWO: TEdit;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure EditWOKeyPress(Sender: TObject; var Key: Char);
  //  procedure sBtnExportClick(Sender: TObject);
    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    //procedure clearData;


    //function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    //function CheckCustomerValue: string;    //检查Customer字符是否在0~Z之间

    //procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    //procedure RemoveCarrier(sCarrier:string);


    //function GetPartID(partno :String) :String;
    //procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    //procedure SetStatusbyAuthority;
    //Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}



procedure TfMainForm.EditSNKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;
    EditSN.CharCase := ecUpperCase;
    Editwo.SetFocus;
end;

procedure TfMainForm.EditWOKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;
    Editwo.CharCase := ecUpperCase;
end;

procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr:string;
begin
   //if  EditSN.Text ='' and EditWO.Text ='' then Exit;
   
   with  QryTemp do
   begin
      Close;
      Params.Clear;
      {SQLStr :='   SELECT A.TOOLING_SN,C.WORK_ORDER,E.PDLINE_NAME,G.PROCESS_NAME,B.CUST_ASSET_NO||'' N/キよ络μ'' VALUE, '
               +'  D.EMP_NAME,B.UPDATE_TIME TIME '
               + ' FROM SAJET.SYS_TOOLING_SN A,SAJET.G_HT_TOOLING_MATERIAL B,(select * from SAJET.G_HT_TOOLING_SN_STATUS union '
               + ' SELECT * FROM SAJET.G_TOOLING_SN_STATUS ) C, '
               + ' SAJET.SYS_EMP D,SAJET.SYS_PDLINE E,SAJET.SYS_PROCESS G,SAJET.SYS_TERMINAL H '
               + ' WHERE  A.TOOLING_SN_ID=B.TOOLING_SN_ID and A.TOOLING_SN_ID = C.Tooling_SN_ID AND G.PROCESS_ID =C.PROCESS_ID '
               +'  AND E.PDLINE_ID =H.PDLINE_ID And H.TERMINAL_ID =C.TERMINAL_ID and B.UPDATE_TIME =C.LAST_MAINTAIN_TIME  AND D.EMP_ID=B.UPDATE_USERID   '
               + ' AND H.PDLINE_ID=E.PDLINE_ID  ';
      }

      SQLStr :='   SELECT A.TOOLING_SN,B.CUST_ASSET_NO||'' N/キよ络μ'' VALUE, '
               +'  D.EMP_NAME,B.UPDATE_TIME TIME '
               + ' FROM SAJET.SYS_TOOLING_SN A,SAJET.G_HT_TOOLING_MATERIAL B,'
               + ' SAJET.SYS_EMP D '
               + ' WHERE  A.TOOLING_SN_ID=B.TOOLING_SN_ID  AND D.EMP_ID=B.UPDATE_USERID   ' ;

      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.TOOLING_SN=:SN  ';
      end;
      {
      if EditWO.Text <> '' then
      begin
         Params.CreateParam(ftString,'WO',ptInput);
         SQLStr :=SQLStr +' and C.WORK_ORDER =:WO   ';
      end;
      }
      SQLStr := SQLStr + ' ORDER BY TIME DESC ';
         CommandText :=SQLStr ;
       if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;

      if EditWO.Text <> '' then
      begin
         Params.ParamByName('WO').AsString := EditWO.Text;
      end;

      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    strSN,strWO,strPDLINE,strPROCESS,strVALUE,strEMP,strTIME :STRING;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'VALUE' ;
        ExcelApp.Cells[1,1].Value := '眎代刚の睲瑍丁';

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('TOOLING_SN').AsString ;
                 // strWO :=  Qrytemp.FieldByName('WORK_ORDER').AsString;
                 // strPDLINE :=  Qrytemp.FieldByName('PDLINE_NAME').AsString;
                 // strPROCESS :=  Qrytemp.FieldByName('PROCESS_NAME').AsString;
                  strVALUE :=  Qrytemp.FieldByName('VALUE').AsString;
                  strEMP :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strTIME :=  Qrytemp.FieldByName('TIME').AsString;



                  ExcelApp.Cells[i+3,1].Value := stRSN;
                  //ExcelApp.Cells[i+3,2].Value := strWO;
                 // ExcelApp.Cells[i+3,3].Value := strPDLINE;
                 // ExcelApp.Cells[i+3,4].Value := strPROCESS;
                  ExcelApp.Cells[i+3,2].Value := strVALUE;
                  ExcelApp.Cells[i+3,3].Value := strEMP;
                  ExcelApp.Cells[i+3,4].Value := strTIME;
                  QryTEMP.Next;
             end;
        end;
         ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
         ExcelApp.Quit;
    end;



end;

end.











