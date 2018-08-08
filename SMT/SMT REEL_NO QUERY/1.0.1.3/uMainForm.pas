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
    EditReelno: TEdit;
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
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
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


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;
    EditReelno.CharCase := ecUpperCase;
    Editwo.SetFocus;
end;

procedure TfMainForm.EditWOKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;
    Editwo.CharCase := ecUpperCase;
end;

procedure TfMainForm.QueryClick(Sender: TObject);
begin
 if (EditReelno.Text <> '') and (EditWO.Text = '') then
   begin
    Qrytemp.Close;
    Qrytemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'Reel',ptInput);
    QryTemp.CommandText:='SELECT A.WORK_ORDER,A.REEL_NO,B.EMP_NAME,A.PART_NO,'+
                         'a.update_time,a.result,a.TEST_Value,a.TEST_UNIT  From SAJET.G_REEL_NO_VALUE A,'+
                         'SAJET.SYS_EMP B WHERE A.Reel_no=:Reel AND A.UPDATE_USERID=B.EMP_ID';
    Qrytemp.Params.ParamByName('Reel').AsString :=EditReelno.Text;
    QryTemp.open;
   end
   else if (EditReelno.Text ='') and (Editwo.Text <> '') then
   begin
    Qrytemp.Close;
    Qrytemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp.CommandText:='SELECT A.WORK_ORDER,A.REEL_NO,B.EMP_NAME,A.PART_NO,'+
                         'a.update_time,a.result,a.TEST_Value,a.TEST_UNIT  From SAJET.G_REEL_NO_VALUE A,'+
                         'SAJET.SYS_EMP B WHERE A.WORK_ORDER=:WO AND A.UPDATE_USERID=B.EMP_ID';
    Qrytemp.Params.ParamByName('WO').AsString :=EditWO.Text;
    QryTemp.open;
   end
   else if (EditReelno.Text <> '') and (Editwo.Text <> '') then
   begin
    Qrytemp.Close;
    Qrytemp.Params.Clear;
    QryTemp.Params.CreateParam(ftstring,'WO',ptInput);
    QryTemp.Params.CreateParam(ftstring,'Reel',ptInput);
    QryTemp.CommandText:='SELECT A.WORK_ORDER,A.REEL_NO,B.EMP_NAME,A.PART_NO'+
                         'a.update_time,a.result,a.TEST_Value,a.TEST_UNIT  From SAJET.G_REEL_NO_VALUE A,'+
                         'SAJET.SYS_EMP B WHERE A.WORK_ORDER=:WO AND A.UPDATE_USERID=B.EMP_ID'+
                         ' AND A.REEL_NO=:REEL';
    Qrytemp.Params.ParamByName('WO').AsString :=EditWO.Text;
    Qrytemp.Params.ParamByName('Reel').AsString :=EditReelno.Text;
    QryTemp.open;
   end;
    EditReelno.Clear;
    EditWO.Clear;

end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer; strWO, strREEL,
    strEMPID,strTESTVALUE,strUPDATETIME,strRESULT,strPARTNO,StrTESTUNIT :STRING;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'VALUE QUERY.xls');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'VALUE' ;
        ExcelApp.Cells[1,1].Value := 'TEST VALUE';

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strWO :=Qrytemp.FieldByName('WORK_ORDER').AsString ;
                  strREEL :=  Qrytemp.FieldByName('REEL_NO').AsString;
                  strEMPID :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strTESTVALUE :=  Qrytemp.FieldByName('TEST_VALUE').AsString;
                  strUPDATETIME :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  strRESULT :=  Qrytemp.FieldByName('RESULT').AsString;
                  strPARTNO :=  Qrytemp.FieldByName('PART_NO').AsString;
                  strTESTUNIT :=  Qrytemp.FieldByName('TEST_UNIT').AsString;


                  ExcelApp.Cells[i+3,1].Value := strWO;
                  ExcelApp.Cells[i+3,2].Value := strreel;
                  ExcelApp.Cells[i+3,3].Value := strempid;
                  ExcelApp.Cells[i+3,4].Value := StrTESTVALUE+strTESTUNIT;
                  ExcelApp.Cells[i+3,5].Value := strUPDATETIME;
                  ExcelApp.Cells[i+3,6].Value := strPARTNO;
                  ExcelApp.Cells[i+3,7].Value := strRESULT;
                  QryTEMP.Next;
             end;
        end;
         ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
         ExcelApp.Quit;
    end;



end;


end.






 // if (EditValue.Text > Editup.Text) or (EditValue.Text < EditDOWN.Text) then
 // begin
  //   EditValue.ReadOnly:=true;
  //   msgPanel.Caption :='FAIL';
  //   msgPanel.Color :=clred;
 // end;









