unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils, ComObj,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label2: TLabel;
    Label5: TLabel;
    EdtSN: TEdit;
    EdtCSN: TEdit;
    labInputQty: TLabel;
    LabTerminal: TLabel;
    Label1: TLabel;
    edtErrCode: TEdit;
    procedure EdtSNKeyPress(Sender: TObject; var Key: Char);
    procedure EdtCSNKeyPress(Sender: TObject; var Key: Char);
    procedure fromshow(Sender: TObject);
    procedure edtErrCodeKeyPress(Sender: TObject; var Key: Char);



    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    isStart,IsOpen:boolean;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
    BarApp,BarDoc,BarVars:variant;
    function GetTerminalName(sTerminalID:string):string;
    function getempNo:string;
    function getsysdate:tdatetime;

  end;

var
  fMainForm: TfMainForm;
  iTerminal:string;

implementation


{$R *.dfm}
function TfMainForm.getempNo:string;
begin
    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'EMPID',ptinput);
    qrytemp.CommandText:='SELECT NVL(EMP_NO,''0'') EMPNO FROM SAJET.SYS_EMP   WHERE EMP_ID=:EMPID';
    qrytemp.Params.ParamByName('EMPID').AsString :=UpdateUserID;
    qrytemp.Open;
    Result := qrytemp.fieldbyname('EMPNO').AsString;
end;


function TfMainForm.getsysdate:tdatetime;
begin
    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.CommandText:='SELECT sysdate system_time FROM dual';
    qrytemp.Open;
    Result := qrytemp.fieldbyname('system_time').AsDatetime;
end;

procedure TfMainForm.EdtSNKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
    if key <> #13 then exit;

    if edtsn.Text = '' then exit;

    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:='SELECT CUSTOMER_SN FROM SAJET.G_SN_STATUS WHERE SERIAL_NUMBER=:SN or customer_SN =:SN';
    qrytemp.Params.ParamByName('SN').AsString :=Edtsn.Text;
    qrytemp.Open;

    if  qrytemp.IsEmpty then begin
        Edtsn.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := '±ø½X¿ù»~';
        msgPanel.Color :=clRed;
        exit;
    end;

    if (qrytemp.FieldByName('CUSTOMER_SN').AsString <> 'N/A') and (edtErrcode.Text ='') then
    begin
        Edtsn.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := '±ø½X¤w¸j©w';
        msgPanel.Color :=clRed;
        exit;
    end;


     with sproc do begin
         close;
         datarequest('sajet.SJ_CKRT_ROUTE');
         fetchparams;
         params.ParamByName('TERMINALID').AsString :=iTerminal;
         params.ParamByName('TSN').AsString :=edtSN.Text;
         execute;
     end;
     sRes := Sproc.Params.ParamByName('TRES').AsString;
     if sRes ='OK' then begin
          EdtCSN.SelectAll;
          edtcsn.SetFocus;
          if edterrcode.Text = '' then begin
               msgPanel.Caption := '¥DªO±ø½XOK';
               msgPanel.Color :=clGREEN;
           end else begin
               sproc.close;
               sproc.datarequest('sajet.SJ_transfer');
               sproc.fetchparams;
               sproc.params.ParamByName('TTERMINALID').AsString :=iTerminal;
               sproc.params.ParamByName('TSN').AsString :=edtSN.Text;
               sproc.params.ParamByName('TDEFECT').AsString :=edterrCode.Text;
               sproc.params.ParamByName('TNOW').AsDateTime :=getsysdate;
               sproc.params.ParamByName('TEMP').AsString :=getempno;
               sproc.execute;
               sRes := Sproc.Params.ParamByName('TRES').AsString;
                if sRes ='OK' then begin
                    edtSN.Clear;
                    edtErrCode.Clear;
                    edtErrCode.SetFocus;
                    msgPanel.Caption := '¤£¨}¿é¤JOK';
                    msgPanel.Color :=clGREEN;
                end else begin
                        EdtSN.SelectAll;
                        edtsn.SetFocus;
                        msgPanel.Caption := sRes;
                        msgPanel.Color :=clRed;
               end;
           end;
     end else begin
        EdtSN.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := sRes;
        msgPanel.Color :=clRed;

     end;
      

end;


procedure TfMainForm.EdtCSNKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
 if key <> #13 then exit;

 if Edtcsn.Text ='' then exit;



    with sproc do begin
       close;
       datarequest('sajet.CCM_BINGCSN_GO');
       fetchparams;
       params.ParamByName('TEMPID').AsString :=UPDATEUSERID;
       params.ParamByName('TTERMINALID').AsString :=iTerminal;
       params.ParamByName('TSN').AsString :=edtSN.Text;
       params.ParamByName('TCSN').AsString :=edtCSN.Text;
       execute;
    end;

    sRes :=sproc.Params.ParamByName('TRES').AsString ;
    if sRes = 'OK' then begin
        edtsn.SelectAll;
        edtsn.SetFocus;
        edtcsn.Clear;
        edtsn.Clear;
        msgPanel.Caption := '±ø½X¸j©wOK';
        msgPanel.Color :=cLGREEN;

       if (IsStart) and (IsOpen) then begin
           BarDoc.Variables.Item('SN').Value :=  edtsn.TEXT;
           Bardoc.PrintLabel(1);
           Bardoc.FormFeed;
       end;

    end else begin
        edtcsn.SelectAll;
        edtcsn.SetFocus;
        edtcsn.Clear;
       // edtsn.Clear;
        msgPanel.Caption := sRES;
        msgPanel.Color :=clRed;
    end;

 end;


procedure TfMainForm.fromshow(Sender: TObject);
var PrintFile:string;
begin
     LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
     Edtsn.SetFocus;

     isStart :=false;
     IsOpen :=false;

     try
        BarApp := CreateOleObject('lppx.Application');
      except
        Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
        isStart:=false;
        Exit;
     end;
     PrintFile:= GetCurrentDir+'\\SN_DEFAULT.Lab';
     IsStart :=true;

     If not FileExists( PrintFile) then
     begin
         MessageDlg( 'Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         IsOpen :=false;
         Exit;
     end;

     BarApp.Visible:=false;
     BarDoc:=BarApp.ActiveDocument;
     BarVars:=BarDoc.Variables;
     BarDoc.Open(  PrintFile);
     IsOpen :=true;

end;

function TfMainForm.GetTerminalName(sTerminalID:string):string;
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

procedure TfMainForm.edtErrCodeKeyPress(Sender: TObject; var Key: Char);
var sRes:string;
begin
    if Key <>#13 then exit;
    if edtErrCode.Text = '' then exit;
    with sproc do begin
       close;
       datarequest('sajet.sj_cksys_defect');
       fetchparams;
       params.ParamByName('TREV').AsString :=edtErrCode.Text;
       execute;
   end;
   sRes :=  sproc.Params.ParamByName('TRES').AsString;
   if  sRes<>'OK' then begin
       edtErrCode.SetFocus;
       edtErrCode.Clear;
       msgPanel.Caption := sRes;
       msgPanel.Color :=clRed;
   end else begin
       edtsn.SetFocus;
       msgPanel.Caption := '¤£¨}¥N½X¿é¤JOK¡A½Ð¿é¤J¥DªO±ø½X';
       msgPanel.Color :=clGreen;
   end;
end;

end.











