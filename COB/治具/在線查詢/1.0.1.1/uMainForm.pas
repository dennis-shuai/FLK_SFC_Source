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
    pm1: TPopupMenu;
    N1: TMenuItem;
    lblQtyDesc: TLabel;
    cmbType: TComboBox;
    lbl2: TLabel;
    procedure EditSNKeyPress(Sender: TObject; var Key: Char);
    procedure QueryClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure N1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
    UpdateUserID : String;
    Authoritys,AuthorityRole,FunctionName : String;
  end;

var
  fMainForm: TfMainForm;

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
      SQLStr :=' SELECT  A.TOOLING_SN,A.Update_time,b.emp_name ,round((sysdate-A.update_time )*24,2)  used_hour from '+
               ' sajet.g_tooling_sn_clean a,sajet.sys_emp b where a.update_userId=b.emp_id and a.enabled=''Y'' and a.Tooling_TYPE=''COB_TOOLING'' ';

      if EditSN.Text <> '' then
      begin
         Params.CreateParam(ftString,'SN',ptInput);
         SQLStr :=SQLStr +' and A.tooling_sn =:SN  ';
      end;

      if cmbType.ItemIndex >=0 then begin
           if cmbType.ItemIndex = 0 then
              SQLStr :=SQLStr +' and A.tooling_sn like ''C%'''
           else if cmbType.ItemIndex = 1 then
              SQLStr :=SQLStr +' and A.tooling_sn like ''T%'''
           else if cmbType.ItemIndex = 2 then
              SQLStr :=SQLStr +' and A.tooling_sn like ''M%''';
      end;

       CommandText :=SQLStr+' Order by  A.tooling_sn ';
       if EditSN.Text <> '' then
      begin
         Params.ParamByName('SN').AsString := EditSN.Text;
      end;

      Open;
      lblQtyDesc.Caption := '羆Τ'+IntToStr(RecordCount)+'掸计沮';
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

          if (usedHour > 12 ) then
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


procedure TfMainForm.N1Click(Sender: TObject);
var sSn:string;
begin
//
   sSn:=QryTemp.fieldByname('tooling_sn').AsString;

   with  QryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'SN',ptInput);
      CommandText :='Update sajet.g_tooling_sn_clean set enabled=''N'' where tooling_sn =:sn ';

      Params.ParamByName('SN').AsString :=sSn;
      Execute;
   end;
   Query.Click;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   cmbType.Style := csDropDownList;
end;

end.











