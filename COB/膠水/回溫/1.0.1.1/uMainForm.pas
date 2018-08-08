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
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
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


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
var id:integer;
    sDateCode,sExp_Date:string;
    CurrentDate,exp_date:Tdatetime;

begin
   if key <> #13 then exit;


   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:=' SELECT A.WORK_ORDER,B.OPTION14 ,A.DateCode,TO_date(A.DateCode,''YYYYMMDD'' ) PdateCode'+
                        ' FROM SAJET.G_PICK_LIST A,SAJET.SYS_PART B WHERE A.Material_NO=:REEL '+
                        ' AND A.PART_ID =B.PART_ID ';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if Qrytemp.IsEmpty  then
   begin
       msgPanel.Caption:='溅奎籌兵絏ゼ祇';
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       Exit;
   end;

   lbl1.Caption := ':' +Qrytemp.fieldByName('WORK_ORDER').AsString;
   sExp_Date := Qrytemp.fieldByName('OPTION14').AsString;

   if sExp_Date ='' then
   begin
       msgPanel.Caption:='赣腹⊿Τ砞竚Τ戳' ;
       msgpanel.Color:=clRed;
       EditReelno.SelectAll;
       exit;
   end;
   sDateCode := QryTemp.fieldByname('DATECODE').AsString;
   exp_date :=  QryTemp.fieldByname('PDATECODE').AsDateTime;


   Qrytemp.Close;
   Qrytemp.Params.Clear;
   Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
   Qrytemp.CommandText:='SELECT PART_SN,OP_TYPE FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL and Material_TYPE =''COB GLUE''';
   Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
   Qrytemp.Open;

   if Qrytemp.IsEmpty then
   begin
     Qrytemp1.Close;
     Qrytemp1.Params.Clear;
     Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp1.CommandText:=' SELECT COUNT(*) USED_COUNT FROM (  '+
                           ' SELECT * from sajet.g_psn_travel where  part_sn in '+
                           ' ( select NVL(material_no,''N/A'') from sajet.G_material_return where OP_TYPE =''R'' '+
                           '   start with new_material = :REEL'+
                           '   connect by prior  material_no=new_material ) and OP_TYPE =''放'' AND Material_TYPE =''COB GLUE'' '+
                           '   UNION    '+
                           '   SELECT * from sajet.g_psn_travel where part_sn=:reel  and OP_TYPE =''放'' AND Material_TYPE =''COB GLUE'' '+
                           ' )';
     Qrytemp1.Params.ParamByName('REEL').AsString :=EditReelno.Text;
     Qrytemp1.Open;

     if QryTemp1.FieldByName('USED_COUNT').AsInteger >=3 then
     begin
          msgPanel.Caption:='竒放禬筁3Ω' ;
          msgpanel.Color:=clRed;
          EditReelno.SelectAll;
          exit;
     end;
     Qrytemp1.Close;
     Qrytemp1.Params.Clear;
     Qrytemp1.CommandText:= ' SELECT SAJET.PART_SN_TITTLE_ID.NEXTVAL IID ,sysdate idate  FROM DUAL ';
     Qrytemp1.Open;
     id := Qrytemp1.fieldbyName('IID').AsInteger;
     CurrentDate := Qrytemp1.fieldbyName('idate').AsDateTime;

     try
          if exp_date+ StrToInt(sExp_Date)*7 < currentdate then
          begin
             msgPanel.Caption:='禬Τ戳 ' ;
             msgpanel.Color:= clRed;
             EditReelno.SelectAll;
             exit;
          end;
      except
            sDateCode :='N/A';
            msgPanel.Caption:='ネ玻ら戳Α岿粇 ' ;
            msgpanel.Color:= clRed;
            EditReelno.SelectAll;
            exit;
      end;




     Qrytemp1.Close;
     Qrytemp1.Params.Clear;
     Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp1.Params.CreateParam(ftstring,'USERID',ptinput);
     Qrytemp1.Params.CreateParam(ftstring,'IncrID',ptinput);
     Qrytemp1.Params.CreateParam(ftstring,'DateCode',ptinput);
     Qrytemp1.Params.CreateParam(ftstring,'Exp_Date',ptinput);
     Qrytemp1.CommandText:= 'INSERT INTO SAJET.G_PSN_STATUS (RECID,PART_SN,UPDATE_USERID,OP_TYPE,MATERIAL_TYPE,DATECODE,Exp_Date)'+
                             'VALUES(:IncrID,:REEL,:USERID,''放'',''COB GLUE'',:DATECODE,:Exp_Date)';
     Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
     Qrytemp1.Params.ParamByName('IncrID').AsInteger :=id ;
     Qrytemp1.Params.ParamByName('USERID').AsString :=UpdateuserID;
     Qrytemp1.Params.ParamByName('DateCode').AsString :=sDateCode;
     Qrytemp1.Params.ParamByName('Exp_Date').AsString :=sExp_date;
     Qrytemp1.Execute;

     Qrytemp1.Params.Clear;
     Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp1.CommandText:= 'INSERT INTO SAJET.G_PSN_TRAVEL SELECT * FROM SAJET.G_PSN_STATUS WHERE PART_SN =:REEL' ;
     Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
     Qrytemp1.Execute;

   end else
   begin
       if Qrytemp.FieldByName('OP_TYPE').AsString ='放' then
       begin
            msgPanel.Caption:='竒放' ;
            msgpanel.Color:=clRed;
            EditReelno.SelectAll;
            exit;
       end else
       if Qrytemp.FieldByName('OP_TYPE').AsString ='UPLOAD' then
       begin
            msgPanel.Caption:='竒絬' ;
            msgpanel.Color:=clRed;
            EditReelno.SelectAll;
            exit;
       end else
       if Qrytemp.FieldByName('OP_TYPE').AsString ='叉獁' then
       begin
            msgPanel.Caption:='竒絬' ;
            msgpanel.Color:=clRed;
            EditReelno.SelectAll;
            exit;
       end;
   end;

    msgPanel.Caption:='溅放OK' ;
    msgpanel.Color:=clgreen;
    EditReelno.SelectAll;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
end;

procedure TfMainForm.sbtnSaveClick(Sender: TObject);
begin
 //datetimepicker1.Date :=strtoDateTime('2016.01.01');
end;

end.
