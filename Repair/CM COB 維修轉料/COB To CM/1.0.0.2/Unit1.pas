unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ExtCtrls, Grids, StdCtrls, Buttons,ComObj, ADODB,IniFiles;

type
  TForm1 = class(TForm)
    QryTemp: TClientDataSet;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    edtSN: TEdit;
    Sproc: TClientDataSet;
    Label7: TLabel;
    lblMsg: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblCount: TLabel;
    lblTerminal: TLabel;
    lblWO: TLabel;
    edtWO: TEdit;
    procedure cmbDefectSelect(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID : String;
    Serial_Number,terminal_Name,iTerminal:String;
  //  CSN :integer;
    iProcess,iCount:integer;
    function GetTerminalName(sTerminalID:string):string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.cmbDefectSelect(Sender: TObject);
begin
{
   if cmbDefect.ItemIndex<0 then exit;
   if cmbDefect.ItemIndex =0 then  begin
      iTerminal :=10012350  ;
      iProcess :=100257;
    end else if cmbDefect.ItemIndex =1 then  begin
      iTerminal := 10012352 ;
      iProcess :=100258;
    end else if cmbDefect.ItemIndex =2 then begin
      iTerminal := 10012351;
      iProcess :=100259;
    end;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.CommandText := 'Select Terminal_Name from sajet.sys_terminal where Terminal_ID ='+inttoStr(iTerminal) ;
   QryTemp.Open;
   terminal_Name := QryTemp.fieldbyname('Terminal_Name').AsString ;
   lblTerminal.Caption := terminal_Name;
   edtWO.SelectAll;
   edtWO.SetFocus;
   }
 

end;

function TForm1.GetTerminalName(sTerminalID:string):string;
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

procedure TForm1.edtSNKeyPress(Sender: TObject; var Key: Char);
var msg,sProcess,sDefect:String;
begin
   if Key <> #13 then exit;
   if edtWO.Text ='' then begin
      MessageBox(0,'Please Input WO','Error',MB_ICONERROR);
      Exit;
   end;

   SProc.Close;
   SProc.DataRequest('SAJET.CCM_COB_TO_CM_TRANSFER2');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TWO').AsString :=edtWO.Text;
   Sproc.Params.ParamByName('TSN').AsString :=edtSN.Text;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=iTerminal;
   Sproc.Params.ParamByName('TEMPID').AsString := UpdateUserID;
   Sproc.Execute;
   msg :=  Sproc.Params.ParamByName('TRES').AsString;

   if msg <> 'OK' then begin
       lblMsg.Color :=clRed;
       lblMsg.Caption := msg;
       edtSN.Clear;
       edtSN.SetFocus;
       Exit;
   end;
   
   lblMsg.Caption :=msg;
   lblMsg.Color :=clGreen;
   iCount := iCount+1;
   lblCount.Caption :=IntToStr(iCount);
   edtSN.SetFocus;
   edtSN.Text :='';

end;

procedure TForm1.edtWOKeyPress(Sender: TObject; var Key: Char);
var msg:String;
begin
   if Key<> #13 then exit;
   if edtWO.Text = '' then exit;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftstring,'SN',ptInput);
   QryTemp.CommandText := 'Select WORK_ORDER FROM SAJET.G_SN_STATUS WHERE CUSTOMER_SN =:SN OR SERIAL_NUMBER =:SN';
   Qrytemp.Params.ParamByName('SN').AsString :=edtWO.Text;
   QryTemp.Open;
   if not QryTEmp.IsEmpty then begin
       edtWO.Text :=QryTEmp.fieldbyname('WORK_ORDER').AsString;
   end;
   iCount :=0;

   SProc.Close;
   SProc.DataRequest('SAJET.Sj_Chk_Wo_Input');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TREV').AsString :=edtWO.Text;
   Sproc.Execute;
   msg :=  Sproc.Params.ParamByName('TRES').AsString;
   if msg <>'OK' then begin
       MessageBox(0,PChar(msg),'Error',MB_ICONERROR);

       edtWO.SelectAll;
       edtWO.SetFocus;
       Exit;
   end;
   edtSN.SelectAll;
   edtSN.SetFocus;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
    iTerminal := '10013386';
    lblTerminal.Caption := 'Terminal:'+GetTerminalName(iTerminal);
    edtwo.SetFocus;
end;

end.
