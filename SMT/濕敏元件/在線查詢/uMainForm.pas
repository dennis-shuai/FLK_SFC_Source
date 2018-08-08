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
    edtWO: TEdit;
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
      SQLStr :=' SELECT C.WORK_ORDER,B.PART_NO,A.PART_SN,C.EMP_NO,C.EMP_NAME, A.UPDATE_TIME,ROUND((SYSDATE-A.UPDATE_TIME)*24,2) USED_HOUR ,' +
               ' A.LastTime FROM SAJET.g_psn_status A, SAJET.SYS_EMP C,SAJET.SYS_PART B,SAJET.G_PICK_LIST C   '+
               ' WHERE A.UPDATE_USERID =C.EMP_ID  AND A.MATERIAL_TYPE =''濕敏元件'' and A.PART_SN =C.MATERIAL_NO AND C.PART_ID =B.PART_ID ' ;
      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.PART_SN =:SN ';
      end;

       if edtWO.Text <> '' then
      begin
         Params.CreateParam(ftString,'WO',ptInput);
         SQLStr :=SQLStr +' and C.WORK_ORDER =:WO ';
      end;

       CommandText :=SQLStr +'order by C.WORK_ORDER,A.Update_Time';
       if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;
      if edtWO.Text <> '' then
      begin
         Params.ParamByName('WO').AsString := edtwo.Text;
      end;

      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    strSN,strEMPNO,strEMPNAME,strUpdateTime,strHours,strTIME :STRING;
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
        ExcelApp.WorkSheets[1].Name := '濕敏元件拆封狀態表' ;
        ExcelApp.Cells[1,1].Value := '濕敏元件拆封狀態表';
        ExcelApp.Cells[2,1].Value := '條碼';
        ExcelApp.Cells[2,2].Value := '工號';
        ExcelApp.Cells[2,3].Value := '姓名';
        ExcelApp.Cells[2,4].Value := '拆封時間';
        ExcelApp.Cells[2,5].Value := '暴露時間(小時)';
        ExcelApp.Cells[2,6].Value := '有效時間(小時)';

        i:=0;
        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('PART_SN').AsString ;
                  strEMPNO :=  Qrytemp.FieldByName('EMP_NO').AsString;
                  strEMPNAME:=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strUpdateTime :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;
                  strHours :=  Qrytemp.FieldByName('Used_Hour').AsString;
                  strTIME :=  Qrytemp.FieldByName('LastTime').AsString;


                  ExcelApp.Cells[i+3,1].Value := strSN;
                  ExcelApp.Cells[i+3,2].Value := strEMPNO;
                  ExcelApp.Cells[i+3,3].Value := strEMPNAME;
                  ExcelApp.Cells[i+3,4].Value := strUpdateTime;
                  ExcelApp.Cells[i+3,5].Value := strHours;
                  ExcelApp.Cells[i+3,6].Value := strTIME;
                  ExcelApp.Range['A1:F'+IntToStr(i+3)].

                  QryTEMP.Next;
              end;

        end;
        ExcelApp.ActiveSheet.Range['A1:F1'].Merge;
        ExcelApp.Columns[1].ColumnWidth :=22;
        ExcelApp.Columns[4].ColumnWidth :=22;
        ExcelApp.Columns[5].ColumnWidth :=22;
        ExcelApp.Columns[6].ColumnWidth :=22;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].HorizontalAlignment :=3;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].VerticalAlignment :=2;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[1].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[2].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[3].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[4].Weight := 2;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[7].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[8].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[9].Weight := xlThick;
        ExcelApp.ActiveSheet.Range['A1:F'+IntToStr(I+2)].Borders[10].Weight := xlThick;

        ExcelApp.ActiveSheet.SaveAs(SaveDialog1.FileName);
        ExcelApp.Quit;
    end;



end;


procedure TfMainForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
  var i:Integer;
      Used_Time,Exp_Time:double;

  begin
    if Qrytemp.recordcount>0 then
    begin
     try
        Used_Time:=qrytemp.FieldByName('USED_HOUR').AsFloat;
        Exp_Time := qrytemp.FieldByName('LastTime').AsFloat;

        if Used_Time > Exp_Time  then
        begin
              DBGrid1.Canvas.Brush.Color:=clRed;
              DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
        end
        else   if Used_Time < Exp_Time  then
        begin
              DBGrid1.Canvas.Brush.Color:=clGreen;
              DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
        end else    if Used_Time >= Exp_Time -2  then
              DBGrid1.Canvas.Brush.Color:=clYellow;
              DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
      except

      end;
     end;
  end;


end.











