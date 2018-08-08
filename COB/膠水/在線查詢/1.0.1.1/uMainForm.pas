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
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
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
    Query.Click;
end;

procedure TfMainForm.QueryClick(Sender: TObject);
var SQLStr:string;
begin

   with  QryTemp do
   begin
      Close;
      Params.Clear;
      SQLStr :=' SELECT AA.PART_SN,AA.UPDATE_TIME,AA.EMP_NAME, AA.PART_NO,AA.WORK_ORDER,AA.DATECODE,AA.EXP_DATE,CC.Terminal_Name,AA.BURNIN_TIME,'+
               ' BB.UPDATE_TIME JILT_TIME ,BB.EMP_NAME JILT_NAME,CC.UPDATE_TIME UPLOAD_TIME,CC.EMP_NAME UPLOAD_NAME ,'+
               ' ROUND(DECODE(CC.UPDATE_TIME,NULL,0,(SYSDATE-AA.UPDATE_TIME)*24),2) USED_HOUR,  '+
               ' ROUND(DECODE(AA.UPDATE_TIME,NULL,0,(DECODE(BB.UPDATE_TIME,NULL,SYSDATE,BB.UPDATE_TIME)-AA.UPDATE_TIME)*24),2) BACK_HOUR  '+
               ' FROM (SELECT A.RECID,A.Material_TYPE, A.PART_SN,A.UPDATE_TIME ,B.EMP_NAME ,C.PART_NO,C.BURNIN_TIME,D.WORK_ORDER,A.DATECODE,'+
               ' A.EXP_DATE||''㏄'' EXP_DATE  FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B,SAJET.SYS_PART C,SAJET.G_PICK_LIST D '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID '+
               ' AND A.OP_TYPE =''放'' AND A.PART_SN=D.MATERIAL_NO AND C.PART_ID =D.PART_ID ) AA, '+
               ' (SELECT A.RECID, A.PART_SN,A.UPDATE_TIME ,B.EMP_NAME,A.Terminal_ID FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B  '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID ANd A.OP_TYPE =''叉獁'' ) BB, '+
               ' (SELECT A.RECID, A.PART_SN,C.Terminal_Name,A.UPDATE_TIME ,B.EMP_NAME FROM SAJET.G_PSN_TRAVEL A,SAJET.SYS_EMP B ,sajet.sys_terminal c '+
               ' WHERE A.UPDATE_USERID =B.EMP_ID ANd A.OP_TYPE =''UPLOAD'' and a.terminal_id = TO_CHAR(c.terminal_id) ) CC WHERE  AA.MATERIAL_TYPE =''COB GLUE'' '+
               ' AND AA.RECID =BB.RECID(+) AND AA.RECID =CC.RECID(+) and AA.RECID IN (SELECT RECID FROM SAJET.G_PSN_STATUS WHERE'+
               ' MATERIAL_TYPE =''COB GLUE''  ';

      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and AA.PART_SN =:SN  ';
      end;

       CommandText :=SQLStr+') Order by CC.Terminal_name ';
       if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;

      Open;

   end;
end;



procedure TfMainForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var i:Integer;
    sTemp,result:string;
    backHour,usedHour,MaxHour:double;

 begin
    if Qrytemp.recordcount>0 then
    begin
       try
           usedHour := qrytemp.FieldByName('USED_HOUR').AsFloat;
           backHour := qrytemp.FieldByName('BACK_HOUR').AsFloat;
           MaxHour :=  qrytemp.FieldByName('BURNIN_TIME').AsFloat;
          if (usedHour > MaxHour) or  (backHour>=MaxHour) then
          begin
                DBGrid1.Canvas.Brush.Color:=clRed;
                DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
          end
          else
          begin
                DBGrid1.Canvas.Brush.Color:=clGreen;
                DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
          end;
        except

        end;
    end;
  end;


end.











