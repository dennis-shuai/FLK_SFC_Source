unit uOption;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls,IniFiles, StdCtrls, Buttons, ExtCtrls, DB;

type
  TfOption = class(TForm)
    ImageList1: TImageList;
    Image1: TImage;
    sbtnClose: TSpeedButton;
    sbtnSave: TSpeedButton;
    Label4: TLabel;
    Image2: TImage;
    Label3: TLabel;
    Image5: TImage;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    edtIP: TEdit;
    procedure sbtnCloseClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fOption: TfOption;

implementation

{$R *.DFM}
Uses uData,uSetStation;

procedure TfOption.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfOption.sbtnSaveClick(Sender: TObject);
begin
  With TIniFile.Create('SAJET.ini') do
  begin
    WriteString('TGS Setup','IP Address Prefix',edtIP.Text);
    Free;
  end;
  close;
end;

procedure TfOption.FormShow(Sender: TObject);
begin
  edtIP.Text := fData.sIPPrefix;
end;

end.
