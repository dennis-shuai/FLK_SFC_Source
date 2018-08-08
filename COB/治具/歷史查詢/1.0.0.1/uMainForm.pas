unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, comobj,Excel2000,DateUtils;

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
    Query: TSpeedButton;
    Image3: TImage;
    SaveDialog1: TSaveDialog;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    lbl1: TLabel;
    lbl2: TLabel;
    dbgrd1: TDBGrid;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
   
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
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    //procedure SetStatusbyAuthority;
    //Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;


implementation


{$R *.dfm}



procedure TfMainForm.EditSNKeyPress(Sender: TObject; var Key: Char);
begin
 if key <> #13 then exit;
    EditSN.CharCase := ecUpperCase;
    Query.Click;
end;

procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr:string;
begin

   with  QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftDateTime,'Start_time',ptInput);
      Params.CreateParam(ftDateTime,'End_Time',ptInput);
      SQLStr :=' SELECT A.TOOLING_SN,A.UPDATE_TIME,B.EMP_NAME,NVL(A.Used_hour,round((sysdate-A.update_time)*24,2)) used_hour,'+
               ' A.ENABLED FROM SAJET.G_HT_TOOLING_SN_CLEAN A,sajet.sys_emp b '+
               ' where A.Update_time>=:start_Time and A.Update_time <:end_Time and a.update_userId=b.emp_id and  a.Tooling_TYPE=''COB_TOOLING''';
      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +'   and A.TOOLING_SN =:SN  ';
      end;

      SQLStr :=SQLStr+'  ORDER BY A.TOOLING_SN,A.UPDATE_TIME ';
      CommandText :=SQLStr;
      Params.ParamByName('Start_time').AsDateTime := dtp1.DateTime;
      Params.ParamByName('end_time').AsDateTime := dtp2.DateTime;

      if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
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
        ExcelApp.WorkBooks.Add;
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'COB獀ㄣ睲瑍菌琩高' ;
        ExcelApp.Cells[1,1].Value := 'COB獀ㄣ睲瑍菌琩高';

        ExcelApp.Cells[2,1].Value := '兵絏';
        ExcelApp.Cells[2,2].Value := '睲瑍丁';
        ExcelApp.Cells[2,3].Value := '巨';
        ExcelApp.Cells[2,4].Value := '丁筳(H)';
        ExcelApp.Cells[2,5].Value := '獀ㄣΤ';

        ExcelApp.ActiveSheet.Range['A1:E1'].Merge;

        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[4].ColumnWidth :=20;
        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('Tooling_SN').AsString ;
                  strWO :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  strPDLINE :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strPROCESS :=  Qrytemp.FieldByName('Used_hour').AsString;
                  strVALUE :=  Qrytemp.FieldByName('Enabled').AsString;


                  ExcelApp.Cells[i+3,1].Value := stRSN;
                  ExcelApp.Cells[i+3,2].Value := strWO;
                  ExcelApp.Cells[i+3,3].Value := strPDLINE;
                  ExcelApp.Cells[i+3,4].Value := strPROCESS;
                  ExcelApp.Cells[i+3,5].Value := strVALUE;

                  QryTEMP.Next;
             end;
        end;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:E'+IntToStr(I+2)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
        MessageDlg('旧ЧΘ',mtInformation,[mbOK],0);
    end;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   dtp1.Date := Today;
   dtp2.Date := Tomorrow;
end;

end.











