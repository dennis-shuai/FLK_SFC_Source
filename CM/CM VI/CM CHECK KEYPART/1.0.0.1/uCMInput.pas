unit uCMInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj;

type
  TfCMInput = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    lbldata: TLabel;
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editWO: TEdit;
    editCustomer: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labWO: TLabel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label2: TLabel;
    editKP: TEdit;
    lblKPSN: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editWOKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure editKPKeyPress(Sender: TObject; var Key: Char);
  private
    function CheckWO(sWO:string):string;
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    iTerminal,gWO:string;
end;

var
  fCMInput: TfCMInput;


implementation

{$R *.dfm}


function TfCMInput.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;

function TfCMInput.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

procedure TfCMInput.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;


procedure TfCMInput.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;PrintFile:string;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  editCUstomer.Enabled :=false;
  editKP.Enabled :=false;
  editWO.SetFocus;
  editWO.Text := '';
  labWO.Caption := '';

  labTerminal.Caption :='TERMINAL:  '+ GetTerminalName(iTerminal);

end;

procedure TfCMInput.editWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
      if iTerminal = '' then
      begin
          MessageDlg('please input Terminal information!',mtError,[mbOK],0);
          Exit;
      end;
      
      iResult := CheckWO(Trim(editWO.Text));

      if iResult = 'OK' then
      begin

          with QryTemp do
          begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString,'WO',ptInput);
              CommandText := 'Select b.PART_NO,a.TARGET_QTY,a.INPUT_QTY FROM  SAJET.G_WO_BASE a'
                           + ' , SAJET.SYS_PART b '
                           + ' WHERE a.WORK_ORDER = :WO and  a.MODEL_ID=b.PART_ID';
              Params.ParamByName('WO').AsString := Trim(editWO.Text);
              Open;

              labPartNo.Caption := FieldByName('PART_NO').AsString;
              //labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
              //labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
          end;


          ShowMSG('Work Order input : ',iResult,'½Ð¿é¤J±ø½X!');
          editCustomer.Enabled :=true;
          editCustomer.Text := '';
          editCustomer.SetFocus;
          gWO := Trim(editWO.Text);
          labWO.Caption := gWO;
          editWO.Enabled := False;
          editKP.Enabled := False;
       
      end
      else
      begin
           ShowMSG('Work Order input : ',iResult,'Please input Work order again!');
           editWO.SelectAll;
           editWO.SetFocus;
      end;
  end;
end;

procedure TfCMInput.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult,sMatchWO,wo_LOT,sn_LOT,SWO:string;
begin

    if  Key <>#13 then exit;
    if  editCustomer.Text ='' then exit;



     Sproc.Close;
     Sproc.DataRequest('SAJET.CCM_GET_ASSY_SN_KPSN');
     Sproc.FetchParams;
     Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
     Sproc.Params.ParamByName('TWO').AsString := editWO.Text;
     Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
     Sproc.Execute;

     iResult := Sproc.Params.ParamByName('TRES').AsString;
   
     if iResult <> 'OK' then begin

          msgPanel.Caption :=iResult;
          msgPanel.Font.Color :=clBlack;
          msgPanel.Color :=clRed;
          editCustomer.Clear;
          editCUstomer.Setfocus;
          exit;
     end;
     lblKPSN.Caption :=  Sproc.Params.ParamByName('TKPSN').AsString ;

     {
      with QryTemp do
      begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select P.PART_NO,TARGET_QTY,INPUT_QTY FROM  SAJET.G_WO_BASE W'
                     + ' Left outer join SAJET.SYS_PART P ON W.MODEL_ID=P.PART_ID '
                     + ' WHERE W.WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(editWO.Text);
        Open;
        labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
      end;
      }
      msgPanel.Caption :='OK';
      msgPanel.Font.Color :=clBlack;
      msgPanel.Color :=clGreen;
      editKP.Enabled :=true;
      editKP.Setfocus;
      editKP.Clear;
      editCustomer.Enabled :=false;

end;

procedure TfCMInput.labWODblClick(Sender: TObject);
begin
  if not editWO.Enabled then
  begin
    editWO.Enabled := True;
    editWO.SelectAll;
    editWO.SetFocus;
  end
  else
  begin
    editWO.Enabled := False;
  end;
end;

procedure TfCMInput.editKPKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin

   if  Key <>#13 then exit;
   if  editKP.Text ='' then exit;

    if editKP.Text <> lblKPSN.Caption then
    begin
        Sproc.Close;
        Sproc.DataRequest('SAJET.CCM_KPSN_DIFF_NOGO');
        Sproc.FetchParams;
        Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
        Sproc.Params.ParamByName('TWO').AsString := editwo.Text;
        Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
        Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
        Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID ;
        Sproc.Execute;
    end
    else begin
        Sproc.Close;
        Sproc.DataRequest('SAJET.CCM_ASSY_SN_KPSN_GO');
        Sproc.FetchParams;
        Sproc.Params.ParamByName('TSN').AsString := editCustomer.Text;
        Sproc.Params.ParamByName('TKPSN').AsString := editKP.Text;
        Sproc.Params.ParamByName('TWO').AsString := editWO.Text;
        Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal ;
        Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID ;
        Sproc.Execute;
    end;

    iResult := Sproc.Params.ParamByName('TRES').AsString;
   
    if iResult <> 'OK' then
    begin
        msgPanel.Caption :=iResult;
        msgPanel.Font.Color :=clBlack;
        msgPanel.Color :=clRed;
        editKP.Clear;
        editKP.Setfocus;
        exit;
    end;
    msgPanel.Caption :='OK';
    msgPanel.Font.Color :=clBlack;
    msgPanel.Color :=clGreen;
    editCUstomer.Enabled :=true;
    editCUstomer.Setfocus;
    editKP.Enabled :=false;


end;

end.
