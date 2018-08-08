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
    sbtnSave: TSpeedButton;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    Label1: TLabel;
    cmbTime: TComboBox;
    Label3: TLabel;
    Image3: TImage;
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure cmb1Select(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
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
    UpdateUserID : String;
    LastTime:double;
    IsHadTime:boolean;
    Authoritys,AuthorityRole,FunctionName : String;
    //Language : TLanguage;
    //procedure SetStatusbyAuthority;
    //Function LoadApServer : Boolean;
  end;

var
  fMainForm: TfMainForm;

implementation


{$R *.dfm}


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
   if key <> #13 then exit;

   qrytemp.Close;
   qrytemp.Params.Clear;
   qrytemp.Params.CreateParam(ftstring,'Reel',ptInput);
   qrytemp.CommandText := ' Select b.part_no, nvl(b.Option11,0) LTime from sajet.g_pick_list a,sajet.sys_part b '+
                          ' where a.part_id=b.part_id and a.Material_No =:reel ';
   qrytemp.Params.ParamByName('Reel').AsString :=editReelNo.Text;
   qrytemp.Open;

   if qrytemp.IsEmpty then begin
       msgpanel.Caption :='該條碼沒有發料';
       msgpanel.Color:=clRed;
       EditReelno.Clear;
       EditReelno.SetFocus;
       sbtnSave.Enabled :=false;
       exit;
   end;

   LastTime := qrytemp.fieldbyname('LTime').AsFloat;
   sbtnSave.Enabled :=true;

   if LastTime =0 then begin
        msgpanel.Caption :='請輸入允許暴露時間';
        msgpanel.Color:=clYellow;
        cmbTime.SetFocus;
        IsHadTime :=false;
        exit;
   end else begin
        cmbTime.Text := qrytemp.fieldbyname('LTime').AsString;
        IsHadTime:=true;
        sbtnSave.Click;
   end;
  


end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
   IsHadTime :=false;
end;

procedure TfMainForm.cmb1Select(Sender: TObject);
begin
   EditReelno.SetFocus;
   EditReelno.SelectAll;
end;

procedure TfMainForm.sbtnSaveClick(Sender: TObject);
var id:integer;
begin
    if editReelno.Text ='' then exit;
    if cmbTime.Text = '' then exit;
    
    if cmbTime.Text ='6小時' then begin
        LastTime :=6;
    end  else if cmbTime.Text ='三天' then begin
        LastTime :=72;
    end  else if cmbTime.Text ='168小時' then begin
        LastTime :=168;
    end  else if cmbTime.Text ='1個月' then begin
        LastTime :=720;
    end  else if cmbTime.Text ='3個月' then begin
        LastTime :=2160;
    end  else if cmbTime.Text ='半年' then begin
        LastTime :=4392;
    end  else if cmbTime.Text ='1年' then begin
        LastTime :=8760;
    end else begin
        LastTime :=StrToFloat(cmbTime.Text);
    end;


    if not IsHadTime  then
    begin
       qrytemp.Close;
       qrytemp.Params.Clear;
       qrytemp.Params.CreateParam(ftstring,'sTime',ptInput);
       qrytemp.Params.CreateParam(ftstring,'reel',ptInput);
       qrytemp.CommandText := ' Update sajet.sys_part set Option11 =:sTime where part_id =(select part_id from ' +
                              ' sajet.g_pick_list where material_no =:reel and rownum=1) ';
       qrytemp.Params.ParamByName('sTime').AsFloat :=LastTime;
       qrytemp.Params.ParamByName('reel').AsString :=editReelNo.Text;
       qrytemp.Execute;
    end;

    qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'reel',ptInput);
    qrytemp.CommandText := ' select * from sajet.g_psn_status where part_sn =:reel ';
    qrytemp.Params.ParamByName('reel').AsString :=editReelNo.Text;
    qrytemp.Open;

    if qrytemp.IsEmpty then begin
          
          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.CommandText :='select sajet.PART_SN_TITTLE_ID.nextval iID from dual ';
          qrytemp.Open;
          id := qrytemp.fieldbyname('iID').AsInteger;


          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.Params.CreateParam(ftstring,'reel',ptInput);
          qrytemp.Params.CreateParam(ftstring,'LTime',ptInput);
          qrytemp.Params.CreateParam(ftstring,'UserID',ptInput);
          qrytemp.Params.CreateParam(ftstring,'iId',ptInput);
          qrytemp.CommandText := ' Insert into Sajet.g_psn_status(RecId,PART_SN,OP_TYPE,MATERIAL_TYPE,UPDATE_USERID,LASTTIME )  '+
                                 '  values(:iid,:reel,''UPLOAD'',''濕敏元件'',:UserID,:LTime )';
          qrytemp.Params.ParamByName('reel').AsString :=editReelNo.Text;
          qrytemp.Params.ParamByName('LTime').AsFloat :=LastTime;
          qrytemp.Params.ParamByName('iiD').AsString := IntToStr(id);
          qrytemp.Params.ParamByName('UserID').AsString := UpdateUserID;
          qrytemp.Execute;

          qrytemp.Close;
          qrytemp.Params.Clear;
          qrytemp.Params.CreateParam(ftstring,'reel',ptInput);
          qrytemp.CommandText := ' Insert into Sajet.g_psn_travel select * from sajet.g_psn_status where part_sn =:reel';
          qrytemp.Params.ParamByName('reel').AsString :=editReelNo.Text;
          qrytemp.Execute;

          msgpanel.Caption:='OK';
          msgpanel.Color:=clGreen;
          cmbTime.Text :='';
          EditReelno.Clear;
          EditReelno.SetFocus;
          sbtnSave.Enabled :=false;
    end else begin
          msgpanel.Caption:='已經拆封了';
          msgpanel.Color:=clRed;
          cmbTime.Text :='';
          EditReelno.Clear;
          EditReelno.SetFocus;
          sbtnSave.Enabled :=false;

    end;



end;

end.
