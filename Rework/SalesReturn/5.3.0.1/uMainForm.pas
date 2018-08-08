unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj,TLHELP32;

type
  TfMainForm = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    cmbType: TComboBox;
    edtWO: TEdit;
    LblMsg: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure cmbTypeSelect(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    function CheckWO(sWO:string):string;
  public
    UpdateUserID: String;
  end;

var
  fMainForm: TfMainForm;


implementation



{$R *.dfm}


function TfMainForm.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;



procedure TfMainForm.FormShow(Sender: TObject);
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;
  Bmp.Free;
  cmbType.Style := csDropDownList;


end;

procedure TfMainForm.Image2Click(Sender: TObject);
begin
   Close;
end;


procedure TfMainForm.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    if Key <> #13 then Exit;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        if cmbType.Text ='Work Order' then
            CommandText := 'Select Serial_number,WORK_FLAG,SHIPPING_ID from SAJET.G_SN_STATUS  ' +
                       ' WHERE WORK_ORDER = :WO  '
        else
           CommandText := 'Select Serial_number,WORK_FLAG,SHIPPING_ID from SAJET.G_SN_STATUS  ' +
                       ' WHERE (Serial_number = :WO or Customer_sn =:WO) ';
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
        Open;

        if IsEmpty then begin
            LblMsg.Font.Color :=clRed;
            LblMsg.Caption :=' not Find '+cmbType.Text +' '+edtWo.Text ;
            edtWO.Clear;
            edtWO.SetFocus;
            Exit;
        end;

        if cmbType.Text ='Serial Number' then begin
            if FieldByName('SHIPPING_ID').AsString ='0'  then
            begin
                LblMsg.Font.Color :=clRed;
                LblMsg.Caption :='SN not Shipping' ;
                edtWO.Clear;
                edtWO.SetFocus;
                Exit;
            end;

            if FieldByName('WORK_FLAG').AsString ='1' then
            begin
                LblMsg.Font.Color :=clRed;
                LblMsg.Caption :='SN SRCAP' ;
                edtWO.Clear;
                edtWO.SetFocus;
                Exit;
            end;
        end;

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        if cmbType.Text ='Work Order' then
            CommandText := 'UPDATE SAJET.G_SN_STATUS SET SHIPPING_ID=0  '
                     + ' WHERE WORK_ORDER = :WO'
        else
           CommandText := 'UPDATE SAJET.G_SN_STATUS SET SHIPPING_ID=0  '
                     + ' WHERE Serial_number = :WO or Customer_sn =:WO';
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
        Execute;

         LblMsg.Font.Color :=clBlue;
         LblMsg.Caption :=cmbType.Text +'  '+edtWo.Text+ 'Update OK' ;
         edtWO.Clear;
         edtWO.SetFocus;
    end;



end;

procedure TfMainForm.cmbTypeSelect(Sender: TObject);
begin
   edtWO.SetFocus;
end;

end.
