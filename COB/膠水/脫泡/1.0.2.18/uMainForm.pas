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
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
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
   
   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT round(to_number(SYSDATE-UPDATE_TIME)*24,2)  GlueTime,OP_TYPE FROM SAJET.G_PSN_STATUS '+
                        '  WHERE PART_SN=:REEL  ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if Qrytemp.IsEmpty  then
   begin
       msgPanel.Caption:='�������^��';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if Qrytemp.fieldByname('OP_TYPE').AsString ='��w' then begin
       msgPanel.Caption:='�����w�g��w';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end else if Qrytemp.fieldByname('OP_TYPE').AsString ='UPLOAD' then begin
        msgPanel.Caption:='�����w�g�W�u';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end ;
   
   //�W�[2H�^�Ůɶ��ޱ��A�T�ر`�Ž������b�ޱ����C�C
   QryData.Close;
   QryData.Params.Clear;
   QryData.Params.CreateParam(ftString,'REEL',ptInput);
   QryData.CommandText:='SELECT B.PART_NO FROM SAJET.G_PICK_LIST A,SAJET.SYS_PART B WHERE A.Material_NO=:REEL AND B.PART_ID=A.PART_ID '
                         +' AND B.PART_NO NOT IN (''0953-100E-0071'',''0953-00A-0070'',''0953-0000-0076'')';
   QryData.Params.ParamByName('REEL').AsString:=EditReelno.Text;
   QryData.Open;

   if not QryData.IsEmpty then begin
       if  QryTemp.FieldByName('Gluetime').AsFloat < 2 then
       begin
           msgPanel.Caption:='�����^�ť��W�L2H';
           msgpanel.Color:=clRed;
           EditReelno.SelectAll;
           Exit;
       end;
   end;



     Qrytemp1.Close;
     Qrytemp1.Params.Clear;
     Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
     Qrytemp1.CommandText:= 'UPDATE SAJET.G_PSN_STATUS SET OP_TYPE =''��w'',UPDATE_USERID =:USERID,UPDATE_TIME=SYSDATE WHERE '+
                            '  PART_SN =:REEL';
     Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
     Qrytemp1.Params.ParamByName('USERID').AsString :=UpdateuserID;
     Qrytemp1.Execute;
         
     Qrytemp1.Close;
     Qrytemp1.Params.Clear;
     Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp1.CommandText:='INSERT INTO SAJET.G_PSN_TRAVEL SELECT * FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL';
     Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
     Qrytemp1.Execute;
     msgPanel.Caption:='������wOK' ;
     msgpanel.Color:=clgreen;
     EditReelno.SelectAll;


end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
end;

end.
