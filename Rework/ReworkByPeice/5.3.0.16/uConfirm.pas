unit uConfirm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, StdCtrls, DB, DBClient, Buttons;

type
  TfConfirm = class(TForm)
    Panel1: TPanel;
    Label13: TLabel;
    Label22: TLabel;
    Label25: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    LabReworkNo: TLabel;
    LabWO: TLabel;
    LabRoute: TLabel;
    LabProcess: TLabel;
    LabQty: TLabel;
    Image3: TImage;
    sbtnSaveOK: TSpeedButton;
    Image1: TImage;
    sbtnCancel: TSpeedButton;
    procedure sbtnSaveOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fConfirm: TfConfirm;

implementation

{$R *.dfm}

procedure TfConfirm.sbtnSaveOKClick(Sender: TObject);
begin
  ModalResult:= mrOK;
end;

procedure TfConfirm.FormShow(Sender: TObject);
begin
  ModalResult:= mrNone;
end;

procedure TfConfirm.sbtnCancelClick(Sender: TObject);
begin
  close;
end;

end.
