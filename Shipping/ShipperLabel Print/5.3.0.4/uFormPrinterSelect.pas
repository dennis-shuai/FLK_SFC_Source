unit uFormPrinterSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uFormPrint, uFormMain ;

const
  VerInfo = '5.3.0.2 (Build 20120604)';

type
  TFormPrinterSelect = class(TForm)
    rg1: TRadioGroup;
    procedure rg1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPrinterSelect: TFormPrinterSelect;

implementation

{$R *.dfm}

procedure TFormPrinterSelect.rg1Click(Sender: TObject);
begin
  if rg1.ItemIndex = 0 then
  begin
    FormPrint := TFormPrint.Create(Self);
    FormPrint.Show ;
    if FormMain.chkMinglePack.Checked then
    begin
      FormPrint.tsErie.Show();
      FormPrint.tsPrint.TabVisible := False ;
      FormPrint.tsRetail.TabVisible := False ;
      if (ModelName <> '') and  (ModelName <> 'N/A') then
        FormPrint.Caption := ModelName +'_Shipper_Package_Print_Shell ' +VerInfo + ' (混合包裝)'
      else
        FormPrint.Caption := 'Shipper_Package_Print_Shell ' +VerInfo + ' (混合包裝)' ;

    end else if FormMain.chkRetailLabel.Checked  then
    begin
      FormPrint.tsRetail.Show();
      FormPrint.tsPrint.TabVisible := False ;
      FormPrint.tsErie.TabVisible := False ;
      if (ModelName <> '') and  (ModelName <> 'N/A') then
        FormPrint.Caption := ModelName +'_Retail_Label_Print_Shell ' +VerInfo
      else
        FormPrint.Caption := 'Retail_Label_Print_Shell ' +VerInfo ;
    end else
    begin
      FormPrint.tsPrint.Show();
      FormPrint.tsErie.TabVisible := False ;
      FormPrint.tsRetail.TabVisible := False ;
      if (ModelName <> '') and  (ModelName <> 'N/A') then
        FormPrint.Caption := ModelName +'_Shipper_Package_Print_Shell ' +VerInfo
      else
        FormPrint.Caption := 'Shipper_Package_Print_Shell ' +VerInfo ;
    end;
  end else
  begin
    MessageDlg('你點我幹什麼?這個功能還沒完成,過些時日再試吧!',mtWarning,[mbOK],0);
    rg1.ItemIndex := -1 ;
    Exit ;
  end;
  Self.Hide ;
end;

procedure TFormPrinterSelect.FormShow(Sender: TObject);
begin
    Self.Left :=Round((Screen.Width -Self.Width)/2);
    Self.Top :=Round((Screen.Height-Self.Height)/2);
end;

procedure TFormPrinterSelect.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FormMain.Show ;
  Action := caFree ;
end;

end.
