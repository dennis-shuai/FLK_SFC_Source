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
    cnkRework: TCheckBox;
    Bevel1: TBevel;
    Label7: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    Label5: TLabel;
    cnkVer: TCheckBox;
    Label6: TLabel;
    cnkInputProcess: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Bevel4: TBevel;
    chkUpperCase: TCheckBox;
    Label10: TLabel;
    chkSN: TCheckBox;
    Label11: TLabel;
    Label12: TLabel;
    cnkPartno: TCheckBox;
    Label13: TLabel;
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
Uses uData;

procedure TfOption.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfOption.sbtnSaveClick(Sender: TObject);
begin
  With TIniFile.Create('SAJET.ini') do
  begin
    if cnkRework.Checked then
      WriteString('ASSY','Rework','True')
    else
      WriteString('ASSY','Rework','False');
    Free;
  end;

  With TIniFile.Create('SAJET.ini') do
  begin
    if cnkVer.Checked then
      WriteString('ASSY','CheckVer','True')
    else
      WriteString('ASSY','CheckVer','False');
    Free;
  end;
  With TIniFile.Create('SAJET.ini') do
  begin
    if cnkInputProcess.Checked then
      WriteString('ASSY','InputProcess','True')
    else
      WriteString('ASSY','InputProcess','False');
    Free;
  end;
  With TIniFile.Create('SAJET.ini') do
  begin
    if chkUpperCase.Checked then
      WriteString('ASSY','Upper','True')
    else
      WriteString('ASSY','Upper','False');
    Free;
  end;
  With TIniFile.Create('SAJET.ini') do
  begin
    if chkSN.Checked then
      WriteString('ASSY','CheckSN','True')
    else
      WriteString('ASSY','CheckSN','False');
    Free;
  end;
  With TIniFile.Create('SAJET.ini') do
  begin
    if cnkpartno.Checked then
      WriteString('ASSY','Checkpartno','True')
    else
      WriteString('ASSY','Checkpartno','False');
    Free;
  end;

  close;
end;

procedure TfOption.FormShow(Sender: TObject);
begin

  if fData.Rework = 'True' then
    cnkReworK.Checked := true;
  if fData.Rework = 'False' then
    cnkReworK.Checked := false;
  if fData.CheckVer = 'True' then
    cnkVer.Checked := true;
  if fData.CheckVer = 'False' then
    cnkVer.Checked := false;
  if fData.Checkpartno ='False' then
    cnkpartno.Checked := false;
  if fData.Checkpartno = 'True' then
    cnkpartno.Checked := True;
  if fData.InputProcess = 'False' then
    cnkInputProcess.Checked := false;
  if fData.InputProcess = 'True' then
    cnkInputProcess.Checked := True;
  if fData.Upper = 'True' then
    chkUpperCase.Checked := True;
  if fData.CheckSN = 'True' then
    chkSN.Checked := True;
end;

end.
