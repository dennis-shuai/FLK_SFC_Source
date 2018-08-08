unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtMaterial: TEdit;
    lablType: TLabel;
    lablMsg: TLabel;
    LabQTY: TLabel;
    Image2: TImage;
    sbtnUnHold: TSpeedButton;
    ImageAll: TImage;
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnUnHoldClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;

  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, DllInit;



procedure TfDetail.edtMaterialKeyPress(Sender: TObject; var Key: Char);
begin
    if Key <>#13 then exit;
    sbtnUnHold.Click;
end;

procedure TfDetail.sbtnUnHoldClick(Sender: TObject);
var IsPallet:Boolean;
begin
   IsPallet :=False;
   with qrytemp do begin
          Close;
          params.Clear;
          Params.CreateParam(ftstring,'Material',ptinput);
          commandtext := 'select * from sajet.G_SN_STATUS  where PALLET_NO =:Material';
          params.ParamByName('Material').AsString :=edtMaterial.Text;
          Open;

          if isempty then begin

              Close;
              params.Clear;
              Params.CreateParam(ftstring,'Material',ptinput);
              commandtext := 'select * from sajet.G_SN_STATUS where CARTON_NO =:Material';
              params.ParamByName('Material').AsString :=edtMaterial.Text;
              Open;
              if isempty then begin
                  messageDlg('NOT FOUND Material Hold',mterror,[mbok],0);
                  exit;
              end;
          end else
             IsPallet :=True;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if IsPallet then
                commandtext := 'UPDATE SAJET.G_SN_STATUS SET WORK_FLAG=0 WHERE PALLET_NO=:MATERIAL'
           else
                commandtext := 'UPDATE SAJET.G_SN_STATUS SET WORK_FLAG=0 WHERE CARTON_NO=:MATERIAL';
           params.ParamByName('Material').AsString :=edtMaterial.Text;
           execute;


           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if IsPallet then
                   commandtext := 'Insert into sajet.G_material select * from sajet.g_Material_hold '+
                                 ' where material_no IN(SELECT DISTINCT CARTON_NO FROM SAJET.G_SN_STATUS WHERE PALLET_NO =:Material)'
           else
                 commandtext := 'Insert into sajet.G_material (select * from (select * from sajet.g_Material_hold where material_no =:Material order by update_time desc) where rownum=1)';

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           execute;


           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if IsPallet then
                 commandtext := 'SELECT * FROM SAJET.G_MATERIAL WHERE MATERIAL_NO IN '+
                                ' (SELECT DISTINCT CARTON_NO FROM SAJET.G_SN_STATUS WHERE PALLET_NO=:MATERIAL)'
           else
                  commandtext := 'SELECT * FROM SAJET.G_MATERIAL WHERE MATERIAL_NO=:MATERIAL';

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           Open;

           IF ISEMPTY THEN BEGIN
                messageDlg('INSERT FAIL',mterror,[mbok],0);
                edtmaterial.Text :='';
                exit;
           END;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if IsPallet then
                commandtext := 'DELETE from sajet.g_Material_hold '+
                               ' where material_no IN(SELECT DISTINCT CARTON_NO '+
                                ' FROM SAJET.G_SN_STATUS WHERE PALLET_NO =:Material)'

           else
                commandtext := 'DELETE from sajet.g_Material_hold where material_no =:Material  ';
           params.ParamByName('Material').AsString :=edtMaterial.Text;
           execute;


          
   end;
   edtmaterial.Text :='';
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   edtMaterial.SetFocus;
end;

end.

