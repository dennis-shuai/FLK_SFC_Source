unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ExtCtrls, Grids, StdCtrls, Buttons,ComObj, ADODB,IniFiles,
  DBTables;

type
  TForm1 = class(TForm)
    QryTemp: TClientDataSet;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    lblMsg: TLabel;
    Label1: TLabel;
    edtNewSN: TEdit;
    QryTemp2: TClientDataSet;
    Label7: TLabel;
    edtOldSN: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Sproc: TClientDataSet;
    procedure edtNewSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtOldSNKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    Serial_Number:String;
    CSN :integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.edtNewSNKeyPress(Sender: TObject; var Key: Char);
var iresult:string;
begin
    if (Key = #13) and (Length(edtNewSN.Text) <>0)   then
    begin
       lblMsg.Caption := 'OK';
       lblMsg.Color :=clMedGray  ;
       if Serial_Number = '' then exit;

       Sproc.Close;
       Sproc.DataRequest('SAJET.CCM_ASSY_REPLACE_SN');
       Sproc.fetchParams;
       Sproc.Params.ParamByName('TNEWSN').AsString := edtNewSN.Text;
       Sproc.Params.ParamByName('TOLDSN').AsString := edtOldSN.Text;
       SProc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
       Sproc.Execute;
       iResult :=   Sproc.Params.ParamByName('TRES').AsString;
       IF iResult  <> 'OK' THEN BEGIN
          lblMsg.Color :=clRed;
          lblMsg.Caption := iResult;
          edtNewSN.clear;
          edtNewSN.setFocus;
          exit;
       END;


       if CheckBox1.Checked then
       begin
          QryTemp.Close;
          QryTemp.Params.CreateParam(ftString, 'SN',ptInput);
          QryTemp.CommandText :='update  SAJET.G_SN_KEYPARTS set enabled =''N'' where Serial_Number =:SN';
          QryTemp.Params.ParamByName('SN').AsString :=   Serial_NUmber;
          QryTemp.Execute;
       end ;

       if CheckBox2.Checked then
       begin
          QryTemp.Close;
          QryTemp.Params.CreateParam(ftString, 'SN',ptInput);
          QryTemp.CommandText :='update  SAJET.G_SN_Status  set WIP_PROCESS = 100199,NEXT_PROCESS=100199  where Serial_Number =:SN';
          QryTemp.Params.ParamByName('SN').AsString :=   Serial_NUmber;
          QryTemp.Execute;
       end;



       lblMsg.Caption := 'OK';
       lblMsg.Color :=clGreen;
       edtOldSN.SetFocus;
       edtOldSN.Clear;
       edtNewSN.Clear;
       Sleep(200);
    end;

end;

procedure TForm1.edtOldSNKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key =#13) and (Length(edtOldSN.Text) <> 0) then
   begin
       CSN :=-1 ;
       QryTemp.Close;
       QryTemp.Params.CreateParam(ftString, 'Custermer_SN',ptInput);
       QryTemp.CommandText :='select Serial_Number from sajet.g_SN_STATUS where Customer_SN=:Custermer_SN  ';
       QryTemp.Params.ParamByName('Custermer_SN').AsString :=   edtOldSN.Text;
       QryTemp.Open;

       if QryTemp.IsEmpty then
       begin

          QryTemp2.Close;
          QryTemp2.Params.CreateParam(ftString, 'Custermer_SN',ptInput);
          QryTemp2.CommandText :='select Serial_Number from sajet.g_SN_STATUS where serial_number=:Custermer_SN  ';
          QryTemp2.Params.ParamByName('Custermer_SN').AsString :=   edtOldSN.Text;
          QryTemp2.Open;
          if QryTemp2.IsEmpty then
          begin
             CSN :=-1;
             lblMsg.Caption :='No SN';
             lblMsg.Color :=clRed;
          end else begin
               CSN :=0;
               Serial_Number :=  edtOldSn.Text;
               edtNewSN.SetFocus;
               edtNewSN.Clear;
          end;
       end
       else
       begin
           CSN :=1;
           Serial_Number :=  QryTemp.fieldbyName( 'Serial_Number').AsString;
           edtNewSN.SetFocus;
           edtNewSN.Clear;
       end;
   end;
end;

end.
