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
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    edtLDM: TEdit;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labTargetQty: TLabel;
    labInputQty: TLabel;
    Label2: TLabel;
    edtCT: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    edtRGB: TEdit;
    edtIR: TEdit;
    lbl3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtLDMKeyPress(Sender: TObject; var Key: Char);
    procedure edtCTKeyPress(Sender: TObject; var Key: Char);
    procedure edtIRKeyPress(Sender: TObject; var Key: Char);
    procedure edtRGBKeyPress(Sender: TObject; var Key: Char);
  private
    function  GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    function CheckItemSN(sn,group:string):string;
  public
    UpdateUserID ,sProcessID,sPartID: String;
    sn,sItem_Part_Id,iResult,iTerminal,sWO:string;
end;

var
  fCMInput: TfCMInput;


implementation

{$R *.dfm}



function TfCMInput.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id, ' +
                    '  b.process_id from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    '  where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sProcessID :=  Fieldbyname('process_ID').AsString  ;
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

  edtCT.Enabled :=True;
  edtLDM.Enabled :=false;
  edtIR.Enabled :=false;
  edtCT.SetFocus;

  labTerminal.Caption :='TERMINAL:  '+ GetTerminalName(iTerminal);

end;


procedure TfCMInput.edtLDMKeyPress(Sender: TObject; var Key: Char);
var CSN:string;
begin
   if  Key <>#13 then exit;
   if  edtLDM.Text = '' then exit;
   iResult := CheckItemSN(edtLDM.Text,'2');
   ShowMSG('LDM Label Input',iResult,'');
   if iResult <> 'OK' then
   begin
       edtLDM.Clear;
       edtLDM.SetFocus;
       Exit;
   end;


   with sproc do
   begin
       Close;
       DataRequest('SAJET.CCM_SN_3KP_ITEM_GO');
       FetchParams;
       Params.ParamByName('TWO').AsString :=sWO;
       Params.ParamByName('TSN').AsString :=edtCT.Text;
       Params.ParamByName('TITEM_PART_SN1').AsString := edtIR.Text;
       Params.ParamByName('TITEM_PART_SN2').AsString := edtRGB.Text;
       Params.ParamByName('TITEM_PART_SN3').AsString := edtLDM.Text;
       Params.ParamByName('TPROCESSID').AsString :=sProcessID;
       Params.ParamByName('TTERMINALID').AsString :=iTerminal;
       Params.ParamByName('TEMPID').AsString :=UpdateUserID;
       Execute;
   end;

   iResult :=SProc.Params.ParamByName('TRES').AsString;
   if iResult ='OK' then
      ShowMsg('Input Status:',iResult,'請掃描下一個')
   else
      ShowMsg('Input Error ：',iResult,'請掃描下一個');
  
   edtLDM.Enabled := False;
   edtIR.Enabled := False;
   edtRGB.Enabled := False;
   edtCT.Enabled := True;
   edtCT.Clear;
   edtRGB.Clear;
   edtLDM.Clear;
   edtIR.Clear;
   edtCT.SetFocus;
   

end;


procedure TfCMInput.edtCTKeyPress(Sender: TObject; var Key: Char);
begin

   if  Key <>#13 then exit;
   if  edtCT.Text ='' then exit;

   with QryTemp do
   begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'serial',ptInput);
        CommandText :=' Select a.work_order,a.serial_number,a.model_Id from sajet.g_sn_status a  '+
                      ' where a.serial_number=:serial or a.customer_sn =:serial';
        Params.ParamByName('serial').AsString := edtCT.Text;
        Open;
   end;

   if  QryTemp.IsEmpty then
   begin
         ShowMSG('NO SN','Error','');
         edtCT.SetFocus;
         edtCT.Clear;
         Exit
   end;

   sn := QryTemp.fieldByName('serial_number').AsString;
   sPartID :=  QryTemp.fieldByName('Model_ID').AsString;
   sWO :=  QryTemp.fieldByName('Work_Order').AsString;

   with  SProc do
   begin
        Close;
        DataRequest('SAJET.SJ_CKRT_ROUTE');
        FetchParams;
        Params.ParamByName('TERMINALID').AsString :=iTerminal;
        Params.ParamByName('TSN').AsString := sn;
        Execute;

        iResult :=Params.ParamByName('TRES').AsString;
        if Copy(iResult,1,2) <> 'OK' then
        begin
            msgPanel.Color :=clRed;
            msgPanel.Caption := iResult;
            edtCT.SelectAll;
            edtCT.Clear;
            exit;
        end ;
   end;

   
   with  SProc do
   begin
        Close;
        DataRequest('SAJET.SJ_CHK_KP_RULE');
        FetchParams;
        Params.ParamByName('ITEM_PART_ID').AsString :=sPartID;
        Params.ParamByName('ITEM_PART_SN').AsString := edtCT.Text;
        Execute;
        iResult := Params.ParamByName('TRES').AsString;
        if Copy(iResult,1,2) <> 'OK' then
        begin
            msgPanel.Color :=clRed;
            msgPanel.Caption := iResult;
            edtCT.SelectAll;
            edtCT.Clear;
        end else begin
            edtCT.Enabled := False;
            edtIR.Enabled := True;
            edtIR.SetFocus;
            msgPanel.Color := clGreen;
            msgPanel.Caption := 'Main Board OK';
        end;
   end;

end;


function  TfCMInput.CheckItemSN(sn,group:string):string;
begin
   with SProc do
   begin
       Close;
       DataRequest('SAJET.SJ_CHK_KP_ITEM_RULE');
       FetchParams;
       Params.ParamByName('TWO').AsString := sWO;
       Params.ParamByName('TITEM_PART_SN').AsString := sn;
       Params.ParamByName('TERMINALID').AsString :=iTerminal;
       Params.ParamByName('TPROCESSID').AsString := sProcessID;
       Params.ParamByName('TITEM_GROUP').AsString := group;
       Execute;
   end;
   Result := sproc.Params.ParamByName('TRES').AsString ;



end;



procedure TfCMInput.edtIRKeyPress(Sender: TObject; var Key: Char);
begin
   if  Key <>#13 then exit;
   if  edtIR.Text = '' then exit;
   iResult := CheckItemSN(edtIR.Text,'0');
   ShowMSG('IR Label Input',iResult,'');
   if iResult = 'OK' then
   begin
       edtIR.Enabled := False;
       edtRGB.Enabled := True;
       edtRGB.SetFocus;
   end else begin
       edtIR.Clear;
       edtIR.SetFocus;
   end;
end;

procedure TfCMInput.edtRGBKeyPress(Sender: TObject; var Key: Char);
begin
   if  Key <>#13 then exit;
   if  edtRGB.Text = '' then exit;
   iResult := CheckItemSN(edtRGB.Text,'1');
   ShowMSG('RGB Label Input',iResult,'');
   if iResult = 'OK' then
   begin
       edtRGB.Enabled := False;
       edtLDM.Enabled := True;
       edtLDM.SetFocus;
   end else begin
       edtRGB.Clear;
       edtRGB.SetFocus;
   end;
end;

end.
