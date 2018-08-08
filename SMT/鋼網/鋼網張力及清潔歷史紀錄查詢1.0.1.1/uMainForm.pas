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
    SaveDialog1: TSaveDialog;
    sBtnExport: TSpeedButton;
    Image1: TImage;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
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

end;

procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr,sOptype:string;
begin
   //if  EditSN.Text ='' and EditWO.Text ='' then Exit;

   with  QryTemp do
   begin
      Close;
      Params.Clear;
      SQLStr :=' select a.work_order,b.tooling_sn,c.emp_name,d.pdline_name,c.emp_Name,A.TEST_VALUE,'+
               ' a.Maintain_Time,round((sysdate-a.maintain_time)*24,2) Used_Hour, '+
               ' Decode(a.remarks,''IN'',''畐睲瑍'',''OUT'',''畐睲瑍'',''ONLINE'',DECODE(RECID,'''',''絬睲瑍'',''絬ㄏノ'')) OP_TYPE,A.UPDATE_TIME '+
               ' from sajet.g_HT_tooling_sn_clean a,sajet.sys_tooling_sn b, sajet.sys_emp c,sajet.sys_pdline d  '+
               ' where A.TOOLING_SN = to_char(b.tooling_sn_id) and a.Update_Userid=c.emp_id and a.recId=d.pdline_id(+) and a.tooling_type =''SMT Stencil'' ';

      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and b.TOOLING_SN=:SN ';
      end;


      CommandText :=SQLStr+' order by b.tooling_sn,a.maintain_time ';

      if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;


      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    strSN,strPDLINE,strOpTYPE,strVALUE,strEMP,strTIME ,strWO,strUseTime,strMaintainTime:STRING;
begin
    if SaveDialog1.Execute then
    begin
        if FileExists(SaveDialog1.FileName) then
           DeleteFile(SaveDialog1.FileName);
        ExcelApp :=CreateOleObject('Excel.Application');
        ExcelApp.Visible :=false;
        ExcelApp.displayAlerts:=false;
        ExcelApp.WorkBooks.Open(ExtractfilePath(ParamStr(0))+'SMTSTENCILQUERY.xls');
        ExcelApp.WorkSheets[1].Activate;
        ExcelApp.WorkSheets[1].Name := 'VALUE' ;
        ExcelApp.Cells[1,1].Value := '眎代刚の睲瑍丁';

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('TOOLING_SN').AsString ;
                  strWO :=  Qrytemp.FieldByName('Work_ORDER').AsString;
                  strOpTYPE :=  Qrytemp.FieldByName('OP_TYPE').AsString;
                  strPDLINE :=  Qrytemp.FieldByName('PDLINE_NAME').AsString;
                  strVALUE :=  Qrytemp.FieldByName('TEST_VALUE').AsString;
                  strEMP :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strMaintainTime :=  Qrytemp.FieldByName('Maintain_TIME').AsString;
                  strTIME :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  strUseTime :=  Qrytemp.FieldByName('Used_Hour').AsString;

                  ExcelApp.Cells[i+3,1].Value := stRSN;
                  ExcelApp.Cells[i+3,2].Value := strWO;
                  ExcelApp.Cells[i+3,3].Value := strPDLINE;
                  ExcelApp.Cells[i+3,4].Value := strMaintainTime;
                  ExcelApp.Cells[i+3,5].Value := strVALUE;
                  ExcelApp.Cells[i+3,6].Value := strEMP;
                  ExcelApp.Cells[i+3,7].Value := strTIME;
                  ExcelApp.Cells[i+3,8].Value := strUseTime;

                  QryTEMP.Next;
             end;
        end;
         ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
         ExcelApp.Quit;
    end;



end;


procedure TfMainForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
  var i:Integer;j,result:string;

  begin

    if Qrytemp.recordcount>0 then
    begin
         if  Qrytemp.FieldByname('PDLINE_NAME').AsString <>'' then
         try
            j:=qrytemp.FieldByName('Used_Hour').AsString;

            if StrToFloat(j) > 10  then
            begin
                  DBGrid1.Canvas.Brush.Color:=clRed;
                  DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
            end
            else if StrToFloat(j) < 10 then
            begin
                  DBGrid1.Canvas.Brush.Color:=clGreen;
                  DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
            end
            else begin
                  DBGrid1.Canvas.Brush.Color:=$D7EBFA;
                  DBGrid1.DefaultDrawColumnCell(rect,datacol,column,state);
            end;

         except

          end;
       
    end;

  end;


end.











