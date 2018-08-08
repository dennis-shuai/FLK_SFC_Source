unit uWOFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, DB, DBClient;

type
  TfSearchWO = class(TForm)
    Panel1: TPanel;
    Imagemain: TImage;
    Label13: TLabel;
    cmbStatus: TComboBox;
    Label22: TLabel;
    cmbWorkType: TComboBox;
    Label25: TLabel;
    editWO: TEdit;
    DBGrid1: TDBGrid;
    QryWO: TClientDataSet;
    DataSource1: TDataSource;
    procedure editWOChange(Sender: TObject);
    procedure cmbStatusChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSearchWO: TfSearchWO;

implementation

uses uReworkbyPiece;

{$R *.dfm}

procedure TfSearchWO.editWOChange(Sender: TObject);
begin
  If not QryWO.Active Then
    Exit;
  QryWO.Locate('WORK_ORDER',Trim(editWO.Text),[loCaseInsensitive, loPartialKey]);
end;

procedure TfSearchWO.cmbStatusChange(Sender: TObject);
begin
   With QryWO do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select WORK_ORDER,'+
                            'WO_TYPE,'+
                            'WO_RULE,'+
                            'VERSION,'+
                            'TARGET_QTY,'+
                            'WORK_FLAG,'+
                            'WO_STATUS '+
                      'from SAJET.G_WO_BASE '+
                      'where WO_STATUS not in (''0'',''5'',''6'',''7'') ';
      If cmbStatus.ItemIndex > 0 Then
      begin
         Params.CreateParam(ftString	,'WOSTATUS', ptInput);
         CommandText := CommandText + ' and WO_STATUS = :WOSTATUS ';
      end;

      If cmbWorkType.ItemIndex > 0 Then
      begin
         Params.CreateParam(ftString	,'WO_TYPE', ptInput);
         CommandText := CommandText + ' and WO_TYPE = :WO_TYPE ';
      end;

      CommandText := CommandText + ' Order by WORK_ORDER ';
      If cmbStatus.ItemIndex > 0 Then
        Params.ParamByName('WOSTATUS').AsString := IntToStr(cmbStatus.ItemIndex);
      If cmbWorkType.ItemIndex  > 0 Then
        Params.ParamByName('WO_TYPE').AsString := cmbWorkType.Text;

      Open;
   end;
end;

procedure TfSearchWO.FormShow(Sender: TObject);
begin
  cmbWorkType.Items.Clear;
  With fReworkbyPiece.QryTemp do
  begin
     Close;
     Params.Clear;
     CommandText := 'Select WO_TYPE '+
                    'From SAJET.G_WO_BASE '+
                    'where WO_TYPE is not null '+
                    'GROUP BY WO_TYPE ';
     Open;
     cmbWorkType.Items.Add('All');
     While Not Eof Do
     begin
        cmbWorkType.Items.Add(Fieldbyname('WO_TYPE').AsString);
        Next;
     end;
     Close;
  end;
end;

procedure TfSearchWO.DBGrid1DblClick(Sender: TObject);
var sKey:char;
begin
  if (not QryWo.active) or (QryWo.recordCount=0) then
    exit;
    
  fReworkbyPiece.editRWWO.Text:= QryWO.FieldByName('WORK_ORDER').AsString;
  fReworkbyPiece.GET_REWORK_NO;
  close;
end;

end.
