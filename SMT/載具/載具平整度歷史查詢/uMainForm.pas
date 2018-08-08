unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, comobj,Excel2000;

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
    SaveDialog1: TSaveDialog;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
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
    Query.Click;
end;

procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr:string;
begin

   with  QryTemp do
   begin
      Close;
      Params.Clear;
      SQLStr :=' SELECT A.TOOLING_SN,B.TEST_VALUE, C.EMP_NO,C.EMP_NAME, B.UPDATE_TIME FROM SAJET.SYS_TOOLING_SN A ,'+
               ' SAJET.G_TOOLING_TEST_VALUE B ,SAJET.SYS_EMP C WHERE A.TOOLING_SN_ID=B.TOOLING_SN_ID AND '+
               ' A.UPDATE_USERID =C.EMP_ID ' ;
      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.TOOLING_SN =:SN ';
      end;

       CommandText :=SQLStr;
       if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;

      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    strSN,StrEMPNO,strVALUE,strEMP,strTIME :STRING;
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
        ExcelApp.WorkSheets[1].Name := '更ㄣキ俱菌癘魁' ;

        ExcelApp.Cells[2,1].Value := '更ㄣ絪腹';
        ExcelApp.Cells[2,2].Value := '更ㄣキ俱';
        ExcelApp.Cells[2,3].Value := '腹';
        ExcelApp.Cells[2,4].Value := '﹎';
        ExcelApp.Cells[2,5].Value := '代刚丁';

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('TOOLING_SN').AsString ;
                  strVALUE :=  Qrytemp.FieldByName('TEST_VALUE').AsString;
                  StrEMPNO:=  Qrytemp.FieldByName('EMP_NO').AsString;
                  strEMP :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strTIME :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;



                  ExcelApp.Cells[i+3,1].Value := stRSN;
                  ExcelApp.Cells[i+3,2].Value := strVALUE;
                  ExcelApp.Cells[i+3,3].Value := StrEMPNO;
                  ExcelApp.Cells[i+3,4].Value := strEMP;
                  ExcelApp.Cells[i+3,5].Value := strTIME;
                  QryTEMP.Next;
            end;
        end;
        ExcelApp.ActiveSheet.Range['A1:E1'].Merge;
        ExcelApp.Columns[1].ColumnWidth :=22;
        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[5].ColumnWidth :=22;
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
    end;



end;


end.











