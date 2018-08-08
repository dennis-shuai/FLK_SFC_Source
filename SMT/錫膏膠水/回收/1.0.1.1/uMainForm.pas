unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    msgPanel: TPanel;
    Label2: TLabel;
    EditReelno: TEdit;
    labInputQty: TLabel;
    sbtnSave: TSpeedButton;
    QryTemp1: TClientDataSet;
    ImageAll: TImage;
    procedure EditReelnoKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);

  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
  end;

var
  fMainForm: TfMainForm;
  gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}


procedure TfMainForm.EditReelnoKeyPress(Sender: TObject; var Key: Char);
begin
     if key <> #13 then exit;

     Qrytemp.Close;
     Qrytemp.Params.Clear;
     Qrytemp.Params.CreateParam(ftstring,'REEL',ptinput);
     Qrytemp.CommandText:='SELECT PART_SN FROM SAJET.G_PSN_STATUS WHERE PART_SN=:REEL and OP_TYPE = ''UPLOAD'' ';
     Qrytemp.Params.ParamByName('REEL').AsString :=EditReelno.Text;
     Qrytemp.Open;
     
     if Qrytemp.IsEmpty then begin
         msgPanel.Caption:='�������I���X���b�ϥΤ�';
         msgpanel.Color:=clRed;
         EditReelno.SelectAll;
         Exit;
     end
     else
     begin
         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
         Qrytemp1.CommandText:='UPDATE SAJET.G_PSN_STATUS SET OP_TYPE =''DOWN'',UPDATE_TIME =sysdate  WHERE PART_SN=:REEL';
         Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
         Qrytemp1.Execute;

         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
         Qrytemp1.CommandText:='INSERT INTO SAJET.G_PSN_TRAVEL SELECT * FROM SAJET.G_PSN_STATUS  WHERE PART_SN=:REEL';
         Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
         Qrytemp1.Execute;

         Qrytemp1.Close;
         Qrytemp1.Params.Clear;
         Qrytemp1.Params.CreateParam(ftstring,'REEL',ptinput);
         Qrytemp1.CommandText:='DELETE FROM SAJET.G_PSN_STATUS  WHERE PART_SN=:REEL';
         Qrytemp1.Params.ParamByName('REEL').AsString := EditReelno.Text;
         Qrytemp1.Execute;

     end;

      msgPanel.Caption:='�^��OK' ;
       
       msgpanel.Color:=clgreen;
       EditReelno.SelectAll;
end;

procedure TfMainForm.FormShow(Sender: TObject);
begin
   Editreelno.SetFocus;
end;

end.

