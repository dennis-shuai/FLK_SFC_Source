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
    QryTemp1: TClientDataSet;
    msgPanel: TPanel;
    ImageAll: TImage;
    Label5: TLabel;
    edtSN: TEdit;
    labInputQty: TLabel;
    LabTerminal: TLabel;
    Label1: TLabel;
    edtErrCode: TEdit;
    Label2: TLabel;
    edtOuterBox: TEdit;
    Label3: TLabel;
    edtInnerBox: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    LabPartNo: TLabel;
    LabOuterQty: TLabel;
    Label7: TLabel;
    LabInnerQty: TLabel;
    chkClear: TCheckBox;
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure fromshow(Sender: TObject);
    procedure edtErrCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtOuterBoxKeyPress(Sender: TObject; var Key: Char);
    procedure edtInnerBoxKeyPress(Sender: TObject; var Key: Char);



    //procedure editReelnoKeyPress(Sender: TObject; var Key: Char);
  private

  public
    UpdateUserID,sPartID : String;
    sPdline,sProcess,sTerminal:string;
    Authoritys,AuthorityRole,FunctionName : String;
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

procedure TfMainForm.edtSNKeyPress(Sender: TObject; var Key: Char);
var sRes,SSN,sCarton,sEMP:string;
sNow:TDateTime;
begin
    if key <> #13 then exit;

    if edtsn.Text = '' then exit;

    Qrytemp.Close;
    qrytemp.Params.Clear;
    qrytemp.Params.CreateParam(ftstring,'SN',ptinput);
    qrytemp.CommandText:=' SELECT A.SERIAL_NUMBER,A.Carton_No,A.pallet_no FROM SAJET.G_SN_STATUS A '+
                         ' WHERE  A.SERIAL_NUMBER=:SN or A.CUSTOMER_SN=:SN  ';
    qrytemp.Params.ParamByName('SN').AsString :=edtsn.Text;
    qrytemp.Open;

    SSN:=QryTemp.FieldByName('SERIAL_NUMBER').AsString;
    sCarton := QryTemp.FieldByName('Carton_No').AsString;
    if  qrytemp.IsEmpty then begin
        edtsn.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := 'NO SN';
        msgPanel.Color :=clRed;
        exit;
    end;

    if  sCarton <> edtInnerBox.Text then begin
        edtsn.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := '內箱號碼不匹配';
        msgPanel.Color :=clRed;
        exit;
    end;


     with sproc do begin
         close;
         datarequest('sajet.SJ_CKRT_ROUTE');
         fetchparams;
         params.ParamByName('TERMINALID').AsString :=iTerminal;
         params.ParamByName('TSN').AsString :=SSN;
         execute;
     end;
     sRes := Sproc.Params.ParamByName('TRES').AsString;
     
     if sRes ='OK' then begin
          sEMP := getempno;
          sNow := getsysdate;
          if edterrcode.Text = '' then begin

               sproc.close;
               sproc.datarequest('sajet.SJ_GO');
               sproc.fetchparams;
               sproc.params.ParamByName('TTERMINALID').AsString :=iTerminal;
               sproc.params.ParamByName('TSN').AsString :=SSN;
               sproc.params.ParamByName('TNOW').AsDateTime :=sNow;
               sproc.params.ParamByName('TEMP').AsString :=sEMP;
               sproc.execute;

               edtsn.SelectAll;
               edtsn.SetFocus;
               msgPanel.Caption := sRes;
               msgPanel.Color :=clGreen;

          end else begin

               sproc.close;
               sproc.datarequest('sajet.SJ_transfer');
               sproc.fetchparams;
               sproc.params.ParamByName('TTERMINALID').AsString :=iTerminal;
               sproc.params.ParamByName('TSN').AsString :=SSN;
               sproc.params.ParamByName('TDEFECT').AsString :=edterrCode.Text;
               sproc.params.ParamByName('TNOW').AsDateTime :=sNow;
               sproc.params.ParamByName('TEMP').AsString :=sEMP;
               sproc.execute;
               sRes := Sproc.Params.ParamByName('TRES').AsString;

                if sRes ='OK' then begin
                    edtSN.Clear;
                    edtErrCode.Clear;
                    edtErrCode.SetFocus;
                    msgPanel.Caption := '不良輸入OK';
                    msgPanel.Color :=clGreen;
                end else begin
                    edtsn.SelectAll;
                    edtsn.SetFocus;
                    msgPanel.Caption := sRes;
                    msgPanel.Color :=clRed;
                end;
           end;
     end else begin
        edtsn.SelectAll;
        edtsn.SetFocus;
        msgPanel.Caption := sRes;
        msgPanel.Color :=clRed;

     end;
      

end;



procedure TfMainForm.fromshow(Sender: TObject);
begin
   LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);
   edtOuterBox.SetFocus;
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
       msgPanel.Caption := '不良代碼輸入OK，請輸入成品條碼';
       msgPanel.Color :=clGreen;
   end;
end;

procedure TfMainForm.edtOuterBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if key <>#13 then Exit;
  with QryTemp do begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'outbox',ptInput);
      CommandText := 'select a.pallet_no,b.part_no,count(*) qty '+
                     ' from sajet.g_sn_status a,sajet.sys_part b '+
                     ' where a.pallet_no =:outbox and a.model_id=b.part_id '+
                     ' group by a.pallet_no,b.part_no';
      Params.ParamByName('outbox').AsString  := edtOuterBox.Text;
      Open;
      if IsEmpty then begin
          msgPanel.Color := clRed;
          msgPanel.Caption := '沒有該外箱號';
          edtOuterBox.SelectAll;
          edtOuterBox.SetFocus;
          Exit;
      end;

      LabPartNo.Caption  := fieldByName('Part_no').AsString;
      LabOuterQty.Caption := fieldByName('qty').AsString;
      edtOuterBox.Enabled :=false;
      edtInnerBox.Enabled := True;
      edtInnerBox.SetFocus;
      
  end;
end;

procedure TfMainForm.edtInnerBoxKeyPress(Sender: TObject; var Key: Char);
var sPallet:string;
begin
  if key <>#13 then Exit;
  with QryTemp do begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'outbox',ptInput);
      CommandText := 'select a.Pallet_no,a.Carton_no ,count(*) qty '+
                     ' from sajet.g_sn_status a  '+
                     ' where a.Carton_no =:outbox   '+
                     ' group by a.Pallet_no,a.Carton_no ';
      Params.ParamByName('outbox').AsString  := edtInnerBox.Text;
      Open;
      if IsEmpty then begin
          msgPanel.Color := clRed;
          msgPanel.Caption := '沒有該內箱號';
          edtInnerBox.SelectAll;
          edtInnerBox.SetFocus;
          Exit;
      end;


      sPallet :=  fieldByName('Pallet_no').AsString;
      if  sPallet <> edtOuterBox.Text then
      begin
          msgPanel.Color := clRed;
          msgPanel.Caption := '外箱應該為:'+sPallet;
          edtInnerBox.SelectAll;
          edtInnerBox.SetFocus;
          Exit;
      end;

      LabInnerQty.Caption := fieldByName('Qty').AsString;
      edtInnerBox.Enabled :=false;
      edtSN.Enabled := True;
      edtSN.SetFocus;

  end;
end;

end.











