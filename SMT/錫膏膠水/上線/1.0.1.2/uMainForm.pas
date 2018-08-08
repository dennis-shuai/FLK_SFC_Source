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


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
   if key <> #13 then exit;
   if cmb1.ItemIndex <0 then begin
      msgPanel.Caption:='�п�ܾ��x';
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
       msgPanel.Caption:=' �ܮw�o�Ʈɶ��j��72�p��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end ;

   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN,(SysDate-Update_time)*24 BackHour FROM SAJET.G_PSN_STATUS '+
                        ' WHERE PART_SN=:REEL AND MATERIAL_TYPE =''SMT���I����'' and OP_TYPE = ''�^��'' ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if QryTemp.IsEmpty then
   begin
       msgPanel.Caption:='�������I�S���^��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if  Qrytemp.FieldByName('BackHour').AsFloat <4 then
   begin
       msgPanel.Caption:=' �^�Ůɶ��p��4�p��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if   Qrytemp.FieldByName('BackHour').AsFloat >=72 then
   begin
       msgPanel.Caption:=' �^�Ůɶ��j��72�p��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;
   
   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT Count(*) UsedCount FROM SAJET.G_PSN_TRAVEL WHERE PART_SN=:REEL'+
                        ' AND MATERIAL_TYPE =''SMT���I����'' and OP_TYPE = ''�^��'' ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if Qrytemp.fieldByname('UsedCount').AsInteger >=3 then
   begin
       msgPanel.Caption:=' �^�Ŧ��Ƥj��3��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;



   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL'+
                        ' AND MATERIAL_TYPE =''SMT���I����'' and OP_TYPE = ''UPLOAD'' ';
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
       msgPanel.Caption:=' ���I�����w�g�W�u';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
    end;



     msgPanel.Caption:='���I�����W�uOK' ;
       
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
