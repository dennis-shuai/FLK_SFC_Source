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
    Label1: TLabel;
    edtwo: TEdit;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
   
  //  procedure sBtnExportClick(Sender: TObject);
    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    //procedure clearData;


    //function CheckCustomerRule: string;      //潰脤Customer趼睫寞寀,菴珨鎢,酗僅脹
    //function CheckCustomerValue: string;    //潰脤Customer趼睫岆瘁婓0~Z眳潔

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
      SQLStr := ' SELECT F.WORK_ORDER,E.PART_NO,A.PART_SN, A.UPDATE_TIME Split_Time,C.EMP_NAME Split_Name,B.UPDATE_TIME Merge_Time ,'+
                ' D.EMP_NAME Merge_NAME,A.LastTime, Round(Decode(B.UPDATE_TIME,null,'+
                ' ( sysdate-A.UPDATE_TIME )*24,( B.UPDATE_TIME-A.UPDATE_TIME )*24 ),2)||''H'' Used_Hour '+
                ' FROM SAJET.G_PSN_TRAVEL A,SAJET.G_PSN_TRAVEL B,SAJET.SYS_EMP C,SAJET.SYS_EMP D ,SAJET.SYS_PART E,'+
                ' SAJET.G_PICK_LIST F WHERE A.PART_SN=F.MATERIAL_NO AND F.PART_ID =E.PART_ID AND '+
                '  A.PART_SN = B.PART_SN(+) AND A.UPDATE_USERID =C.EMP_ID  AND B.UPDATE_USERID =D.EMP_ID '+
                ' and  A.OP_TYPE=''UPLOAD'' and B.OP_TYPE =''DOWN'' and a.Material_TYPE =''濕敏元件'' and  '+
                ' a.recId =b.recId   ';
      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.PART_SN =:SN ';
      end;

       if edtWO.Text <> '' then
      begin
         Params.CreateParam(ftString,'WO',ptInput);
         SQLStr :=SQLStr +' and F.WORK_ORDER =:WO ';
      end;



      SQLStr :=SQLStr+'  ORDER BY F.WORK_ORDER,E.PART_NO,A.UPDATE_TIME';
      CommandText :=SQLStr;

      if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;
      if edtWO.Text <> '' then
      begin
         Params.ParamByName('WO').AsString := edtWO.Text;
      end;
      
      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    sWO,sPN,strSN,strWO,strPDLINE,strPROCESS,strVALUE,strEMP,strTIME :STRING;
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
        ExcelApp.WorkSheets[1].Name := '錫膏膠水歷史狀態查詢' ;
        ExcelApp.Cells[1,1].Value := '錫膏膠水歷史狀態查詢';

        ExcelApp.Cells[2,1].Value := '工單';
        ExcelApp.Cells[2,2].Value := '料號';
        ExcelApp.Cells[2,3].Value := '條碼';
        ExcelApp.Cells[2,4].Value := '回溫時間';
        ExcelApp.Cells[2,5].Value := '回溫人員';
        ExcelApp.Cells[2,6].Value := '使用機台';
        ExcelApp.Cells[2,7].Value := '操作動作';
        ExcelApp.Cells[2,8].Value := '操作時間';
        ExcelApp.Cells[2,9].Value := '操作人員';
        ExcelApp.ActiveSheet.Range['A1:G1'].Merge;

        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[6].ColumnWidth :=22;

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  sWO := Qrytemp.FieldByName('WORK_ORDER').AsString ;
                  sPN := Qrytemp.FieldByName('PART_NO').AsString ;
                  strSN :=Qrytemp.FieldByName('PART_SN').AsString ;
                  strWO :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  strPDLINE :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strPROCESS :=  Qrytemp.FieldByName('TERMINAL_ID').AsString;
                  strVALUE :=  Qrytemp.FieldByName('OP_TYPE').AsString;
                  strEMP :=  Qrytemp.FieldByName('OP_TIME').AsString;
                  strTIME :=  Qrytemp.FieldByName('OP_NAME').AsString;

                  ExcelApp.Cells[i+3,1].Value := sWO;
                  ExcelApp.Cells[i+3,2].Value := sPN;
                  ExcelApp.Cells[i+3,3].Value := stRSN;
                  ExcelApp.Cells[i+3,4].Value := strWO;
                  ExcelApp.Cells[i+3,5].Value := strPDLINE;
                  ExcelApp.Cells[i+3,6].Value := strPROCESS;
                  ExcelApp.Cells[i+3,7].Value := strVALUE;
                  ExcelApp.Cells[i+3,8].Value := strEMP;
                  ExcelApp.Cells[i+3,9].Value := strTIME;
                  QryTEMP.Next;
             end;
        end;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:I'+IntToStr(I+2)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
    end;



end;



end.











