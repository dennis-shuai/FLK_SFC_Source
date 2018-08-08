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
    lbl1: TLabel;
    cmbType: TComboBox;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure sBtnExportClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
  //  procedure sBtnExportClick(Sender: TObject);
    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    //procedure clearData;


    //function CheckCustomerRule: string;      //���Customer�ַ�����,��һ��,���ȵ�
    //function CheckCustomerValue: string;    //���Customer�ַ��Ƿ���0~Z֮��

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

   if cmbType.ItemIndex =1 then
       sOptype :='ONLINE'
   else if cmbType.ItemIndex =2 then
       sOptype :='OUT'
   else  if cmbType.ItemIndex =3 then
       sOptype :='IN' ;


   with  QryTemp do
   begin
      Close;
      Params.Clear;
      SQLStr :=' select b.tooling_sn,c.emp_name,d.pdline_name,c.emp_Name,A.TEST_VALUE,A.WORK_ORDER,'+
               ' a.Maintain_Time,decode(used_hour,null,round((sysdate-a.maintain_time)*24,2),used_hour) Used_Hour, '+
               ' Decode(a.remarks,''IN'',''�J�w�M�~'',''OUT'',''�X�w�M�~'',''ONLINE'',DECODE(RECID,'''',''�b�u�M�~'',''�W�u�ϥ�'')) OP_TYPE,A.UPDATE_TIME '+
               ' from sajet.g_tooling_sn_clean a,sajet.sys_tooling_sn b, sajet.sys_emp c,sajet.sys_pdline d  '+
               ' where A.TOOLING_SN = to_char(b.tooling_sn_id) and a.Update_Userid=c.emp_id and a.recId=d.pdline_id(+) and a.tooling_type =''SMT Stencil'' ';

      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and b.TOOLING_SN=:SN ';
      end;

      if cmbType.ItemIndex >0 then
      begin
          Params.CreateParam(ftString,'OP_TYPE',ptInput);
          SQLStr :=SQLStr +' and a.remarks=:OP_TYPE ';
      end;


      CommandText :=SQLStr;

      if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;

      if cmbType.ItemIndex >0 then
      begin
          Params.ParamByName('OP_TYPE').AsString := sOptype;
      end;

      Open;

   end;
end;



procedure TfMainForm.sBtnExportClick(Sender: TObject);
    var ExcelApp: Variant; i: integer;
    strSN,strPDLINE,strOpTYPE,strVALUE,strEMP,strTIME :STRING;
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
        ExcelApp.Cells[1,1].Value := '�i�O���դβM�~�ɶ���';

        if not Qrytemp.IsEmpty then
        begin
            QryTemp.First;
            for  i:=0 to QryTemp.RecordCount-1  do
            begin
                  strSN :=Qrytemp.FieldByName('TOOLING_SN').AsString ;
                  strOpTYPE :=  Qrytemp.FieldByName('OP_TYPE').AsString;
                  strPDLINE :=  Qrytemp.FieldByName('PDLINE_NAME').AsString;
                  strVALUE :=  Qrytemp.FieldByName('TEST_VALUE').AsString;
                  strEMP :=  Qrytemp.FieldByName('EMP_NAME').AsString;
                  strTIME :=  Qrytemp.FieldByName('UPDATE_TIME').AsString;

                  ExcelApp.Cells[i+3,1].Value := stRSN;
                  ExcelApp.Cells[i+3,2].Value := strOpTYPE;
                  ExcelApp.Cells[i+3,3].Value := strPDLINE;
                  ExcelApp.Cells[i+3,4].Value := strVALUE;
                  ExcelApp.Cells[i+3,5].Value := strEMP;
                  ExcelApp.Cells[i+3,6].Value := strTIME;

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


procedure TfMainForm.FormShow(Sender: TObject);
begin
  cmbType.Style := csDropDownList;
end;

end.











