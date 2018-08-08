unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    msgPanel: TPanel;
    Label2: TLabel;
    EditReelno: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    lbl1: TLabel;
    cmb1: TComboBox;
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cmb1Select(Sender: TObject);
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


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
   if key <> #13 then exit;
   if cmb1.ItemIndex <0 then begin
      msgPanel.Caption:='請選擇機台';
      msgpanel.Color:=clRed;
      EditReelno.SelectAll;
      Exit;
   end;

   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT  (SysDate-Update_time)*24 BackHour FROM SAJET.G_PICK_LIST '+
                        ' WHERE Material_no=:REEL  ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if  Qrytemp.FieldByName('BackHour').AsFloat >72 then
   begin
       msgPanel.Caption:=' 倉庫發料時間大於72小時';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end ;

   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN,(SysDate-Update_time)*24 BackHour FROM SAJET.G_PSN_STATUS '+
                        ' WHERE PART_SN=:REEL AND MATERIAL_TYPE =''SMT錫膏膠水'' and OP_TYPE = ''回溫'' ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if QryTemp.IsEmpty then
   begin
       msgPanel.Caption:='膠水錫膏沒有回溫';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if  Qrytemp.FieldByName('BackHour').AsFloat <4 then
   begin
       msgPanel.Caption:=' 回溫時間小於4小時';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if   Qrytemp.FieldByName('BackHour').AsFloat >=72 then
   begin
       msgPanel.Caption:=' 回溫時間大於72小時';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;
   
   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT Count(*) UsedCount FROM SAJET.G_PSN_TRAVEL WHERE PART_SN=:REEL'+
                        ' AND MATERIAL_TYPE =''SMT錫膏膠水'' and OP_TYPE = ''回溫'' ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if Qrytemp.fieldByname('UsedCount').AsInteger >=3 then
   begin
       msgPanel.Caption:=' 回溫次數大於3次';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;



   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL'+
                        ' AND MATERIAL_TYPE =''SMT錫膏膠水'' and OP_TYPE = ''UPLOAD'' ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

    if Qrytemp.IsEmpty then
       begin
           Qrytemp1.Close;
           Qrytemp1.Params.Clear;
           Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
           Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
           Qrytemp1.Params.CreateParam(ftstring,'TERMINAL',ptinput);
           Qrytemp1.CommandText:= ' UPDATE SAJET.G_PSN_STATUS  SET TERMINAL_ID =:TERMINAL , OP_TYPE =''UPLOAD'' ,  '+
                                  ' UPDATE_USERID =:USERID ,UPDATE_TIME =sysdate '+
                                  '  WHERE PART_SN =:REEL';
           Qrytemp1.Params.ParamByName('TERMINAL').AsString := cmb1.Text;
           Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
           Qrytemp1.Params.ParamByName('USERID').AsString :=UpdateuserID;
           Qrytemp1.Execute;

           
           Qrytemp1.Close;
           Qrytemp1.Params.Clear;
           Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
           Qrytemp1.CommandText:='INSERT INTO SAJET.G_PSN_TRAVEL SELECT * FROM  SAJET.G_PSN_STATUS WHERE PART_SN=:REEL';
           Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
           Qrytemp1.Execute;
       end
    else
    begin
       msgPanel.Caption:=' 錫膏膠水已經上線';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
    end;



     msgPanel.Caption:='錫膏膠水上線OK' ;
       
     msgpanel.Color:=clgreen;
     EditReelno.Clear;
     EditReelno.SetFocus;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
end;

procedure TfMainForm.cmb1Select(Sender: TObject);
begin
   EditReelno.SetFocus;
   EditReelno.SelectAll;
end;

end.
