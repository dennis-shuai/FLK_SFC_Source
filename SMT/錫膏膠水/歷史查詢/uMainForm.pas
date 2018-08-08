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
      SQLStr :=' SELECT AA.PART_SN,AA.UPDATE_TIME,AA.EMP_NAME, AA.PART_NO,AA.WORK_ORDER,AA.DATECODE,AA.EXP_DATE,BB.TERMINAL_ID,'+
               ' BB.UPDATE_TIME UPLOAD_TIME ,BB.EMP_NAME UPLOAD_NAME,CC.UPDATE_TIME REUSE_TIME,CC.EMP_NAME REUSE_NAME  '+
               ' FROM (SELECT A.RECID,A.Material_TYPE, A.PART_SN,A.UPDATE_TIME ,B.EMP_NAME ,C.PART_NO,D.WORK_ORDER,A.DATECODE,'+
               ' A.EXP_DATE||''周'' EXP_DATE  FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B,SAJET.SYS_PART C,SAJET.G_PICK_LIST D '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID '+
               ' AND A.OP_TYPE =''回溫'' AND A.PART_SN=D.MATERIAL_NO AND C.PART_ID =D.PART_ID ) AA, '+
               ' (SELECT A.RECID, A.PART_SN,A.UPDATE_TIME ,B.EMP_NAME,A.Terminal_ID FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B  '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID ANd A.OP_TYPE =''UPLOAD'' ) BB, '+
               ' (SELECT A.RECID, A.PART_SN,A.UPDATE_TIME ,B.EMP_NAME FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID ANd A.OP_TYPE =''DOWN'' ) CC WHERE  AA.MATERIAL_TYPE =''SMT錫膏膠水'' '+
               ' AND AA.RECID =BB.RECID(+) AND AA.RECID =CC.RECID(+) ' ;

      if editSN.Text <> '' then begin
         Params.CreateParam(ftString,'reel',ptInput);
         SQLStr :=sqlStr +'AND (AA.PART_SN IN (select material_no from sajet.G_material_return  where OP_TYPE =''R'' '+
                 ' start with new_material =:reel connect by prior material_no=new_material ) OR (AA.PART_SN =:reel)) ';
      end;

      SQLStr :=SQLStr+'  ORDER BY AA.UPDATE_TIME ,AA.PART_NO';
      CommandText :=SQLStr;
      if editSN.Text <> '' then
          Params.ParamByName('reel').AsString := editsn.Text;
      Open;


   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
       sPN,sSN,sBTime,sBName,sTerminal,sUpTime,sUpName,sReTime,sReName,sWO,sEXPDate,sDateCode :STRING;
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

        ExcelApp.Cells[2,1].Value := '條碼';
        ExcelApp.Cells[2,2].Value := '料號';
        ExcelApp.Cells[2,3].Value := '回溫時間';
        ExcelApp.Cells[2,4].Value := '回溫人員';
        ExcelApp.Cells[2,5].Value := '使用機台';
        ExcelApp.Cells[2,6].Value := '上線人員';
        ExcelApp.Cells[2,7].Value := '上線時間';
        ExcelApp.Cells[2,8].Value := '回收人員';
        ExcelApp.Cells[2,9].Value := '回收時間';
        ExcelApp.Cells[2,10].Value := '工單';
        ExcelApp.Cells[2,11].Value := '生產日期';
        ExcelApp.Cells[2,12].Value := '有效期';
        ExcelApp.ActiveSheet.Range['A1:L1'].Merge;

        ExcelApp.Columns[1].ColumnWidth :=15;
        ExcelApp.Columns[2].ColumnWidth :=22;
        ExcelApp.Columns[3].ColumnWidth :=22;
        ExcelApp.Columns[7].ColumnWidth :=22;
        ExcelApp.Columns[9].ColumnWidth :=22;
        i:=0;
        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  sSN := Qrytemp.FieldByName('PART_SN').AsString ;
                  sPN := Qrytemp.FieldByName('PART_NO').AsString ;
                  sBTime :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  sBName :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  sTerminal :=  Qrytemp.FieldByName('TERMINAL_ID').AsString;
                  sUpTime :=  Qrytemp.FieldByName('Upload_Time').AsString;
                  sUpName :=  Qrytemp.FieldByName('Upload_Name').AsString;
                  sReTime :=  Qrytemp.FieldByName('Reuse_Time').AsString;
                  sReName :=  Qrytemp.FieldByName('Reuse_Name').AsString;
                  sWO :=  Qrytemp.FieldByName('WORK_ORDER').AsString;
                  sDateCode :=  Qrytemp.FieldByName('DATECODE').AsString;
                  sExpDate :=  Qrytemp.FieldByName('EXP_DATE').AsString;

                  ExcelApp.Cells[i+3,1].Value := sSN;
                  ExcelApp.Cells[i+3,2].Value := sPN;
                  ExcelApp.Cells[i+3,3].Value := sBTime;
                  ExcelApp.Cells[i+3,4].Value := sBName;
                  ExcelApp.Cells[i+3,5].Value := sTerminal;
                  ExcelApp.Cells[i+3,6].Value := sUpName;
                  ExcelApp.Cells[i+3,7].Value := sUpTime;
                  ExcelApp.Cells[i+3,8].Value := sReName;
                  ExcelApp.Cells[i+3,9].Value := sReTime;
                  ExcelApp.Cells[i+3,10].Value := sWo;
                  ExcelApp.Cells[i+3,11].Value := sDateCode;
                  ExcelApp.Cells[i+3,12].Value := sExpDate+'周';
                  QryTEMP.Next;
             end;
        end;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:l'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:L'+IntToStr(I+2)].Borders[10].Weight := xlThick;
        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
    end;



end;



end.











