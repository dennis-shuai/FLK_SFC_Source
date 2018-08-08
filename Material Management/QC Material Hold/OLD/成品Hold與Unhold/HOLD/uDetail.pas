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
    sbtnHold: TSpeedButton;
    ImageAll: TImage;
    procedure edtMaterialKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnHoldClick(Sender: TObject);
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
    sbtnHold.Click;
end;

procedure TfDetail.sbtnHoldClick(Sender: TObject);
var IsPallet:Boolean;
begin
    IsPallet :=false;
   with qrytemp do begin
           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           commandtext := 'select * from sajet.g_SN_STATUS where Pallet_no =:Material';
           params.ParamByName('Material').AsString :=edtMaterial.Text;
           Open;

           if isempty then
           begin
               Close;
               params.Clear;
               Params.CreateParam(ftstring,'Material',ptinput);
               commandtext := 'select * from sajet.g_SN_STATUS where Carton_no =:Material';
               params.ParamByName('Material').AsString :=edtMaterial.Text;
               Open;
               if IsEmpty then begin
                  messageDlg('NOT FOUND Material',mterror,[mbok],0);
                  exit  ;
               end;
           end
           else
               IsPallet :=True;


           If IsPallet then begin
               Close;
               params.Clear;
               Params.CreateParam(ftstring,'Material',ptinput);
               commandtext := ' UPDATE SAJET.G_SN_STATUS SET WORK_FLAG=2 WHERE pallet_no =:MATERIAL';
               params.ParamByName('Material').AsString :=edtMaterial.Text;
               execute;
           end
           else begin
               Close;
               params.Clear;
               Params.CreateParam(ftstring,'Material',ptinput);
               commandtext := ' UPDATE SAJET.G_SN_STATUS SET WORK_FLAG=2 WHERE  CARTON_NO =:MATERIAL';
               params.ParamByName('Material').AsString :=edtMaterial.Text;
               execute;
           end;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           If IsPallet then
           begin
               commandtext := ' INSERT INTO SAJET.G_MATERIAL_HOLD SELECT * FROM SAJET.G_MATERIAL '+
                                    ' WHERE MATERIAL_NO IN (SELECT DISTINCT CARTON_NO FROM  SAJET.G_SN_STATUS WHERE PALLET_NO =:MATERIAL)';
           end  else begin
                commandtext := 'INSERT INTO SAJET.G_MATERIAL_HOLD SELECT * FROM SAJET.G_MATERIAL '+
                                ' WHERE MATERIAL_NO = :MATERIAL';
           end;

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           execute;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           If IsPallet then begin
                 commandtext := ' SELECT * FROM  SAJET.G_MATERIAL_HOLD '+
                                ' WHERE MATERIAL_NO IN (SELECT DISTINCT CARTON_NO FROM  SAJET.G_SN_STATUS WHERE PALLET_NO =:MATERIAL)';
           end else   begin
                  commandtext := ' SELECT * FROM  SAJET.G_MATERIAL_HOLD '+
                                 ' WHERE MATERIAL_NO = :MATERIAL';
           end;

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           open;

           IF NOT ISEMPTY THEN BEGIN
               Close;
               params.Clear;
               Params.CreateParam(ftstring,'Material',ptinput);
               If IsPallet then begin
                     commandtext := ' DELETE FROM SAJET.G_MATERIAL '+
                                    ' WHERE MATERIAL_NO IN (SELECT DISTINCT CARTON_NO FROM  SAJET.G_SN_STATUS WHERE PALLET_NO =:MATERIAL)';
               end else begin
                      commandtext := 'DELETE FROM SAJET.G_MATERIAL '+
                                    ' WHERE MATERIAL_NO = :MATERIAL';
               end;

               params.ParamByName('Material').AsString :=edtMaterial.Text;
               execute;
           END;





   end;
   edtmaterial.Text :='';
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   edtMaterial.SetFocus;
end;

end.

