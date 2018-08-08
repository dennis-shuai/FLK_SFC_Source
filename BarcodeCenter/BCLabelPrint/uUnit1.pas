unit uUnit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ComObj, DB, DBClient, MConnect, SConnect, Grids,
  DBGrids, ObjBrkr, Mask, ExtCtrls, Tlhelp32 ;        //,RzEdit

type
  TPrintForm = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    dsQryData: TClientDataSet;
    Panel1: TPanel;
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    lbl2: TLabel;
    DataSource1: TDataSource;
    Panel3: TPanel;
    lablLabel: TLabel;
    lablDesc: TLabel;
    lbl6: TLabel;
    EdtWO: TEdit;
    SocketConnection1: TSocketConnection;
    Label2: TLabel;
    Label3: TLabel;
    EditBOX: TEdit;
    PrintStart: TButton;
    PrintStop: TButton;
    lblCount: TLabel;
    GOTOSN: TEdit;
    Label4: TLabel;
    lblROW: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    cbbPrintQTY: TComboBox;
    procedure bbtnLinkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EdtWOKeyPress(Sender: TObject; var Key: Char);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure GOTOSNChange(Sender: TObject);
    procedure PrintStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PrintStartClick(Sender: TObject);
  private
    { Private declarations }
    Procedure OnMouseWheel(Var Msg :TMsg;var Handled:Boolean);
  public
    { Public declarations }
    procedure PrintCode(AFilePath: string; count:Integer;  AVApp: Variant);
    function  LoadApServer : Boolean;
    function KillTask(ExeFileName: string): integer;
  end;

var
  PrintForm: TPrintForm;
  BarApp,
  BarDoc:Variant;       //BarVars
  Print_FileName : string ;
  ParamsStatus : string = 'N/A';

implementation

{$R *.dfm}

procedure TPrintForm.bbtnLinkClick(Sender: TObject);
begin
  {m_CodeSoft.Linked:=not m_CodeSoft.Linked;
  if m_CodeSoft.Linked then bbtnLink.Caption:='CS LINK'
  else bbtnLink.Caption:='CS NOT LINK';
  if m_CodeSoft.Visibled then bbtnVisible.Caption:='CS Visible'
  else bbtnVisible.Caption:='CS NOT Visible';}
  BarApp := CreateOLEObject('Lppx.Application'); //Create a ole object
  BarApp.Visible := true;
end;

procedure TprintForm.PrintCode(AFilePath: string; count: Integer;
  AVApp: Variant);
var
  I,j,k: integer; (* cylce for all parameter of print inforation*)
  Vdoc, Vars, Vari: Variant;
begin
  try
    Vdoc := AVApp.ActiveDocument; //Link Doc
    Vdoc.OPen(AFilePath); //open Doc
    Vars := Vdoc.Variables; // Get Variables collections
    for k:=1 to 1 do
    begin
      for I := 0 to count-1 do
      begin
        Vari := Vars.item(i+1 ); // Get Variable       //var0    model
        for j:=1 to count do
        begin
          if Vari.name ='constname[j]' then //var2   so
          begin
            vari.Value := 'constvalue[j]'; //var4   catainer
          end;
        end;
      end;
      Vdoc.save;
      Vdoc.PrintLabel(1); // Print Label
    end;
    Vdoc.FormFeed; // Terminate Print job
  except
    on e: exception do
      raise Exception.Create(e.Message + '[Print Error!]');
  end;
end;

{procedure TForm1.print_Label;
var UpdateTime:TDateTime;

begin
     BarApp := CreateOleObject('lppx.Application');
     UpdateTime :=  GetsysTime;

     BarApp.Visible:=False;
     BarDoc:=BarApp.ActiveDocument;
     BarDoc.Open(Print_FileName);
     BarVars:=BarDoc.Variables;
     //BarDoc.Variables.
      BarDoc.Variables.Item('PART_NO').Value := Part_NO;
      BarDoc.Variables.Item('QTY').Value := Qty;
      BarDoc.Variables.Item('MACHINE_NO').Value := Machine_Code;
      BarDoc.Variables.Item('BOX ID').Value := Pallet_NO;
      BarDoc.Variables.Item('WORK_ORDER').Value := Work_Order;
      BarDoc.Variables.Item('PART_NO').Value := Part_NO;
      BarDoc.Variables.Item('PALLET_NO').Value := Pallet_NO;
      BarDoc.Variables.Item('CREATE_DATETIME').Value := UpdateTime;
      BarDoc.Variables.Item('PALLET_TOTAL').Value := QTY;
      BarDoc.Variables.Item('WORK_ORDER').Value := Work_Order;
     BarDoc.Save;
     Bardoc.PrintLabel(1);
     Bardoc.Close;
     Bardoc.FormFeed; // Terminate Print job
     BarApp.Quit;
     //BarVars.Free;
     //BarDoc.Free;
     //BarApp.Free;
     //KillTask('lppa.exe');

end; }

function TprintForm.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TPrintForm.FormCreate(Sender: TObject);
begin
  Self.Top := Round((Screen.Height - Self.Height )/2);
  Self.Left := Round((Screen.Width - Self.Width )/2);
  
  Application.OnMessage:=OnMouseWheel; // 截取鼠標滾輪事件
  LoadApServer;
  BarApp := CreateOLEObject('Lppx.Application'); //Create a ole object
  BarApp.Visible := false;
  BarApp.UserControl := true;
  BarDoc:=BarApp.ActiveDocument;
  Print_FileName := ExtractFilePath(Application.ExeName) + 'High_Temperature_Label.Lab';
end;

procedure TPrintForm.EdtWOKeyPress(Sender: TObject; var Key: Char);
var i:Integer ;
begin
  IF Key = #13 then
  begin
    with dsQryData do
    begin
      Close ;
      Params.Clear ;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'SELECT DISTINCT(BOX_NO),WORK_ORDER FROM SAJET.G_SN_STATUS  ' +
                     ' WHERE  WORK_ORDER =:WORK_ORDER AND IN_PDLINE_TIME IS NULL ' +
                     ' AND BOX_NO <>''N/A'' ORDER BY BOX_NO' ; //
      Params.ParamByName('WORK_ORDER').AsString := EdtWo.Text;
      Application.ProcessMessages ;
      Open;
      if IsEmpty then
      begin
        MessageDlg(#13+#10 +'Can not find data,pls check this worder_order !', mtError, [mbOK], 0);
        EdtWO.SelectAll ;
        Exit ;
      end;
      PrintStart.Enabled := True ;
      GOTOSN.Enabled := True ;
      GOTOSN.Color := clYellow;
      //EditSN.Text := Fieldbyname('SERIAL_NUMBER').AsString;
      EditBOX.Text := Fieldbyname('BOX_NO').AsString;
      lblCount.Caption :='S/N_Count:'+ InttoStr(RecordCount);
      cbbPrintQTY.Clear ;
      for i :=1 to RecordCount do
        cbbPrintQTY.AddItem(IntToStr(i),cbbPrintQTY);
    end;
  end;
end;

procedure TPrintForm.btnNextClick(Sender: TObject);
begin
  dsQryData.Next ;     //下一個
end;

procedure TPrintForm.btnPriorClick(Sender: TObject);
begin
  dsQryData.Prior ;  //上一個
end;

procedure TPrintForm.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if dsQryData.Eof then
    Exit;
  //EditSN.Text := dsQryData.Fieldbyname('SERIAL_NUMBER').AsString;
  EditBOX.Text := dsQryData.Fieldbyname('BOX_NO').AsString;
  lblROW.Caption :='Present_Row:' + IntToStr(dsQryData.RecNo) ;    //當前選中行
end;

procedure TPrintForm.GOTOSNChange(Sender: TObject);
begin
  dsQryData.Locate('BOX_NO', Trim(GOTOSN.Text), [loCaseInsensitive, loPartialKey]);
end;

procedure TPrintForm.PrintStopClick(Sender: TObject);
begin
  PrintStart.Enabled := true;
  ParamsStatus := 'STOP';
end;

function TprintForm.KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOLean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
        OpenProcess(PROCESS_TERMINATE,
        BOOL(0),
        FProcessEntry32.th32ProcessID),
        0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TPrintForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BarDoc.Save;
  BarDoc.close;
  BarApp.quit;
  printForm:=nil;
  KillTask('lppa.exe');
end;

Procedure TPrintForm.OnMouseWheel(Var Msg :TMsg;var Handled:Boolean);
begin
  if Msg.message = WM_MouseWheel then
  begin
    if Msg.wParam > 0 then
     begin
       if DBGrid1.Focused then
         dsQryData.Prior;
         //SendMessage(DBGrid1.Handle,WM_VSCROLL,SB_PAGEUP,0);  //向上翻頁
     end
    else
     begin
       if DBGrid1.Focused then
         dsQryData.Next;
         //SendMessage(DBGrid1.Handle,WM_VSCROLL,SB_PAGEDOWN,0);    //向下翻頁
     end;
    Handled:= True;
  end;
end;


procedure TPrintForm.PrintStartClick(Sender: TObject);
var i : Integer ;
begin
  if cbbPrintQTY.Text = '' then
  begin
    messagedlg('Pls Select Print QTY !',mtError, [mbOK], 0);
    Exit ;
  end;

  if  StrToInt(cbbPrintQTY.Text) > dsQryData.RecordCount - dsQryData.RecNo then
  begin
    messagedlg('Print QTY > Count QTY',mtError, [mbOK], 0);
    Exit ;
  end;
  
  PrintStart.Enabled := False;
  PrintStop.Enabled :=true;
  cbbPrintQTY.Enabled := false;
  GOTOSN.Enabled := false;
  ParamsStatus := 'N/A';
  BarDoc.Open(Print_FileName);
  lablDesc.Caption :=  Print_FileName ;
  with dsQryData do
  begin
    for i :=0 to StrToInt(cbbPrintQTY.Text)-1 do
    begin
      Application.ProcessMessages ;
      if ParamsStatus ='STOP' then Break ;
      BarDoc.Variables.Item('NUMBER').Value := RecNo;
      BarDoc.Variables.Item('SN').Value := FieldByName('BOX_NO').AsString;
      BarDoc.Variables.Item('W/O').Value := FieldByName('WORK_ORDER').AsString;
      BarDoc.Save;
      Bardoc.PrintLabel(1);
      Bardoc.FormFeed; // Terminate Print job
      Next ;
    end ;
  end;
  PrintStart.Enabled := true;
  PrintStop.Enabled := false;
  cbbPrintQTY.Enabled := true;
  GOTOSN.Enabled := true;
end;

end.
