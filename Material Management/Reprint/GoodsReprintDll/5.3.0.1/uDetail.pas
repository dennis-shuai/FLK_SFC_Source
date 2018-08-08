unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls,
  Db, DBClient, MConnect, SConnect, IniFiles, ObjBrkr, ImgList, Menus, unitDataBase;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabelPacking: TLabel;
    Label1: TLabel;
    Image1: TImage;
    QryTemp: TClientDataSet;
    Label4: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    editSN: TEdit;
    sbtnReprint: TSpeedButton;
    Label2: TLabel;
    QryTemp1: TClientDataSet;
    lablMsg: TLabel;
    procedure editSNKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure sbtnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField: string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}

uses Dllinit, uDllform, uCommData;

procedure TfDetail.editSNKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    if editSN.Text = '' then Exit;
    sbtnExecuteClick(Self);
    editSN.SelectAll;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
  end;
  editSN.SetFocus;
end;

procedure TfDetail.sbtnExecuteClick(Sender: TObject);
var sType, sPrintData: string;
begin
  if editSN.Text = '' then Exit;
  try
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText := 'Select a.material_no '
        + 'From SAJET.G_material a '
        + 'Where a.material_no = :material_no ';
      Params.ParamByName('material_no').AsString := editSN.Text;
      Open;
      if IsEmpty then begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'material_no', ptInput);
        CommandText := 'Select a.material_no '
          + 'From SAJET.G_material a '
          + 'Where a.reel_no = :material_no ';
        Params.ParamByName('material_no').AsString := editSN.Text;
        Open;
        if IsEmpty then begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString, 'material_no', ptInput);
          CommandText := 'Select a.material_no '
            + 'From SAJET.G_pick_list a '
            + 'Where a.material_no = :material_no ';
          Params.ParamByName('material_no').AsString := editSN.Text;
          Open;
          if IsEmpty then begin
            MessageDlg('ID No not found.', mtError, [mbOK], 0);
            lablMsg.Caption := 'ID No: ' + editSN.Text + ' not found.';
            lablMsg.Font.Color := clRed;
            editSN.SelectAll;
            editSN.SetFocus;
            Close;
            Exit;
          end else begin
            sType := 'Pick List';
          end;
        end else begin
          sType := 'Reel ID';
        end;
      end else begin
        sType := 'Material ID';
      end;
      Close;
    end;
    sPrintData := G_getPrintData(6, 19, G_sockConnection, 'DspQryData', sType + '*&*' + editSN.Text, 1, 'DEFAULT');
    if assigned(G_onTransDataToApplication) then
      G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
    else
      showmessage('Not Defined Call Back Function for Code Soft');
    lablMsg.Caption := 'ID No: ' + editSN.Text + ' print OK.';
    lablMsg.Font.Color := clWindowText;
    editSN.SetFocus;
    editSN.SelectAll;  
  except
    on E: Exception do ShowMessage(E.message);
  end;
end;

end.

