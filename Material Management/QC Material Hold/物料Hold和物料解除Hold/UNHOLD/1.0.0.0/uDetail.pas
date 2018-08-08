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
begin
   with qrytemp do begin
          Close;
          params.Clear;
          Params.CreateParam(ftstring,'Material',ptinput);
          if (copy(edtMaterial.Text,1,1) ='Q') or (copy(edtMaterial.Text,1,1) = 'B')  then begin
                 commandtext := 'select * from sajet.g_Material_HOLD where material_no =:Material';
          end else if copy(edtMaterial.Text,1,1) ='R'  then begin
                 commandtext := 'select * from sajet.g_Material_HOLD where Reel_no =:Material';
          end ;

          params.ParamByName('Material').AsString :=edtMaterial.Text;
          Open;

          if isempty then begin
               messageDlg('NOT FOUND Material Hold',mterror,[mbok],0);
               exit;
          end;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if (copy(edtMaterial.Text,1,1) ='Q') or (copy(edtMaterial.Text,1,1) = 'B') or (copy(edtMaterial.Text,1,1) = 'F') then begin
                 commandtext := 'Insert into sajet.G_material (select * from (select * from sajet.g_Material_hold where material_no =:Material order by update_time desc) where rownum=1)';
           end else if copy(edtMaterial.Text,1,1) ='R'  then begin
                  commandtext := 'Insert into sajet.G_material ( select * from (select * from sajet.g_Material_hold where Reel_no =:Material order by update_time desc) where rownum=1)';
           end else  begin
                messageDlg('Error Material',mterror,[mbok],0);
                edtmaterial.Text :='';
                exit;
           end;

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           execute;

           Close;
           params.Clear;
           Params.CreateParam(ftstring,'Material',ptinput);
           if (copy(edtMaterial.Text,1,1) ='Q') or (copy(edtMaterial.Text,1,1) = 'B') or (copy(edtMaterial.Text,1,1) = 'F') then begin
                 commandtext := 'select * from sajet.g_Material where material_no =:Material';
           end else if copy(edtMaterial.Text,1,1) ='R'  then begin
                  commandtext := 'select * from sajet.g_Material where Reel_no =:Material';
           end;

           params.ParamByName('Material').AsString :=edtMaterial.Text;
           Open;

           if isempty then begin
               messageDlg('Inser fail',mterror,[mbok],0);
               edtmaterial.Text :='';
               exit;
           end;
           
   end;
   edtmaterial.Text :='';
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   edtMaterial.SetFocus;
end;

end.

