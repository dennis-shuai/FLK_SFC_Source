unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    label1: TLabel;
    Label2: TLabel;
    Editwo: TEdit;
    Editpallet: TEdit;
    panlMessage: TLabel;
      procedure FormClose(Sender: TObject; var Action: TCloseAction); 
   procedure sbtnQueryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations } 
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uDllForm;
{$R *.DFM}

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;


procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
  if (trim(editwo.Text)='') or (trim(editpallet.Text)='') then exit;
  with Sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_GOODS_DOUBLE');
      FetchParams;
      Params.ParamByName('tterminalid').AsString :='';
      Params.ParamByName('tnow').AsString :='';
      Params.ParamByName('TWO').AsString := editWO.Text;
      Params.ParamByName('TPALLET').AsString :=Editpallet.text;
      Params.ParamByName('TEMPID').AsString :=fDllForm.UpdateUserID;
      Execute;
      panlMessage.Caption := Params.ParamByName('TRES').AsString;
      if Params.ParamByName('TRES').AsString = 'OK' then
      begin
        panlMessage.Caption := Editpallet.Text +' OK ';
        panlMessage.Font.Color := clBlue;
        editpallet.SelectAll ;
        editpallet.SetFocus ;
      end else
      begin
        panlMessage.Font.Color := clRed;
        MessageBeep(48);
        editpallet.SelectAll ;
        editpallet.SetFocus ;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   editwo.Clear ;
   editwo.SetFocus ;
   editpallet.Clear ;
end;

end.
