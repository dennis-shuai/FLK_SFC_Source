unit uSampleFileImport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls, Buttons;

type
  TfSampleFileImport = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    editName: TEdit;
    editFile: TEdit;
    SpeedButton1: TSpeedButton;
    Image9: TImage;
    sbtnOK: TSpeedButton;
    Image2: TImage;
    sbtnCancel: TSpeedButton;
    OpenDialog1: TOpenDialog;
    procedure sbtnCancelClick(Sender: TObject);
    procedure sbtnOKClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sbtnDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DefineType : String;
  end;

var
  fSampleFileImport: TfSampleFileImport;

implementation

{$R *.DFM}

procedure TfSampleFileImport.sbtnCancelClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TfSampleFileImport.sbtnOKClick(Sender: TObject);
begin
   // 檢查名稱是否正確
   If editName.Text = '' Then
   begin
      Showmessage('Report Name Define Error !!');
      Exit;
   end;

   // 檢查檔案是否存在
   If editFile.Text <> '' Then
   begin
      If not FileExists(editFile.Text) Then
      begin
         Showmessage('Report Sample File dosn''t Exists '+#13#10 + 'Please check again !!');
         Exit;
      end;
   end;
   DefineType := 'OK';
   ModalResult := mrOK;
end;

procedure TfSampleFileImport.SpeedButton1Click(Sender: TObject);
begin
   If OpenDialog1.Execute Then
      editFile.Text := OpenDialog1.FileName;
end;

procedure TfSampleFileImport.sbtnDeleteClick(Sender: TObject);
begin
   DefineType := 'DELETE';
   ModalResult := mrOK;
end;

end.
