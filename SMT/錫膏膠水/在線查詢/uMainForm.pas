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
      SQLStr :=' SELECT A.PART_SN,D.PART_NO,A.TERMINAL_ID,C.EMP_NO,C.EMP_NAME, B.UPDATE_TIME,'+
               ' ROUND((SYSDATE-A.UPDATE_TIME)*24,2)||''H'' BACK_HOUR,A.DateCode,A.EXP_DATE||''㏄'' EXP_DATE ,'+
               ' ROUND((SYSDATE-B.UPDATE_TIME)*24,2)||''H'' USED_HOUR FROM SAJET.G_PSN_STATUS A,'+
               ' SAJET.G_PSN_TRAVEL B ,SAJET.SYS_EMP C ,SAJET.SYS_PART D,SAJET.G_PICK_LIST E '+
               ' WHERE A.PART_SN=B.PART_SN(+) AND A.PART_SN=E.MATERIAL_NO AND D.PART_ID=E.PART_ID AND '+
               ' A.UPDATE_USERID =C.EMP_ID and A.MATERIAL_TYPE=''SMT奎籌溅'' AND A.RECID=B.RECID(+) '+
               ' AND B.OP_TYPE =''放'' ' ;
               
      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.PART_SN =:SN ';
      end;

       CommandText :=SQLStr;
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
    backHour,usedHour:double;

 begin
    if Qrytemp.recordcount>0 then
    begin
     try
        sTemp:=qrytemp.FieldByName('USED_HOUR').AsString;
        i:=Pos('H',sTemp);
        usedHour:=StrToFloat(Copy(sTemp,0,i-1));

        sTemp:=qrytemp.FieldByName('BACK_HOUR').AsString;
        i:=Pos('H',sTemp);
        backHour:=StrToFloat(Copy(sTemp,0,i-1));


        if (usedHour > 28) or  (backHour>=72) then
        begin
              DBGrid1.Canvas.Brush.Color:=clRed;
              DBGrid1.DefaultDrawColumnCell(Rect,DataCol,Column,State);
        end
        else if ( usedHour < 28 ) and (backHour<72) then
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











