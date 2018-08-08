unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles, RzButton;

type
  TfMainForm = class(TForm)
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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editLot: TEdit;
    labInputQty: TLabel;
    ImageAll: TImage;
    Label2: TLabel;
    Label5: TLabel;
    LabPartNo: TLabel;
    Label1: TLabel;
    CM3: TPanel;
    CM1: TPanel;
    Image1: TImage;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    btnAdd: TSpeedButton;
    Label12: TLabel;
    Label13: TLabel;
    cmbMachine: TComboBox;
    dtpDate: TDateTimePicker;
    dtpTime: TDateTimePicker;
    edtEmpNo: TEdit;
    chkNecessary: TCheckBox;
    edtDefect: TEdit;
    lvDefect: TListView;
    seditDefectQty: TSpinEdit;
    LabProcess: TLabel;
    LabName: TLabel;
    LabPassQty: TLabel;
    btnSubmit: TSpeedButton;
    Image5: TImage;
    msgPanel: TPanel;
    dbgrd1: TDBGrid;
    LabFailQty: TLabel;
    Route: TPanel;
    Label4: TLabel;
    LabWO: TLabel;
    LabDefectDesc: TLabel;
    Label6: TLabel;
    LabLotQty: TLabel;
    LabButtonName: TLabel;
    procedure FormShow(Sender: TObject);
    procedure editLotKeyPress(Sender: TObject; var Key: Char);
    procedure edtDefectKeyPress(Sender: TObject; var Key: Char);
    procedure btnAddClick(Sender: TObject);
    procedure seditDefectQtyKeyPress(Sender: TObject; var Key: Char);
    procedure btnSubmitClick(Sender: TObject);
    procedure edtEmpNoChange(Sender: TObject);
  private
    //function CheckCustomerRule: string;      //检查Customer字符规则,第一码,长度等
    function CheckCustomerValue(SN:string): string;    //检查Customer字符是否在0~Z之间
    function GetTerminalName(sTerminalID:string):string;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  public
    UpdateUserID,sPartID,sEmpNo,sEmpID: String;
    sPdline,sProcess,sProcessId,sTerminal,sWO:string;
    iTerminal:string;
    procedure newButtonClick(Sender: TObject);
    function  IsDefect: Boolean;
    function  checkInput: Boolean;

  end;

var
  fMainForm: TfMainForm;


implementation


{$R *.dfm}

function TfMainForm.GetTerminalName(sTerminalID:string):string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id ,b.Process_id ' +
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
         sProcessId :=Fieldbyname('process_ID').AsString  ;
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


procedure TfMainForm.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
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



procedure TfMainForm.FormShow(Sender: TObject);
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;
  editLot.SetFocus;
end;



function TfMainForm.CheckCustomerValue(SN:string): string;
var
  i,vLength: integer;
  sValue,vChar: string;
begin
  sValue := trim(SN);
  vLength := length(sValue);
  for i := 1 to vLength do
  begin
    vChar := copy(sValue,i,1);
    if ((vChar >= '0') and (vChar <= '9')) or ((vChar >= 'A') and (vChar <= 'Z')) or (vChar ='-') then
      Result := 'OK'
    else
    begin
      Result := 'Error';
      Exit;
    end;
  end;
end;

procedure TfMainForm.editLotKeyPress(Sender: TObject; var Key: Char);
var routebtn:TRzButton;
i:Integer;
begin
    if Key <>#13 then Exit;
    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'Lot_No',ptInput);
        CommandText := 'select work_order from sajet.g_pack_pallet where pallet_no=:Lot_No';
        Params.ParamByName('Lot_No').AsString :=editLot.Text;
        Open;

        if IsEmpty then begin
            msgPanel.Caption :='NO LOT NO';
            msgPanel.Color :=clRed;
            Exit;
        end;
        sWO :=FieldByName('work_order').AsString;
        LabWO.Caption := sWO;

        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := ' Select B.PROCESS_NAME,D.NECESSARY from sajet.G_WO_BASE A,SAJET.SYS_PROCESS B,SAJET.SYS_ROUTE C,'+
                       ' SAJET.SYS_ROUTE_DETAIL D WHERE A.WORK_ORDER=:WO AND A.ROUTE_ID=C.ROUTE_ID AND C.ROUTE_ID =D.ROUTE_ID '+
                       ' AND D.NEXT_PROCESS_ID =B.PROCESS_ID AND D.STEP=D.SEQ ORDER BY D.STEP ';
        Params.ParamByName('WO').AsString :=sWO;
        Open;

        if IsEmpty then begin
            msgPanel.Caption :='NO FOUND WO ROUTE';
            msgPanel.Color :=clRed;
            Exit;
        end;
        i:=0;
        First;
        while not Eof  do begin
            routebtn := TRzButton.Create(Self);
            routebtn.parent := Route;
            routebtn.Caption := fieldbyName('PROCESS_NAME').AsString;

            if i<7 then begin
                routebtn.Left := 70+120*i;
                routebtn.Width :=100;
                routebtn.Top :=5;
            end else if i<14 then  begin
                routebtn.Top :=35;
                routebtn.Left := 70+120*(i-7);
                routebtn.Width :=100;
            end else if i<21 then begin
                routebtn.Top :=65;
                routebtn.Left := 70+120*(i-14);
                routebtn.Width :=100;
            end;
            if  fieldbyName('Necessary').AsString ='Y' then
                routebtn.Color :=clGreen
            else
                routebtn.Color :=clFuchsia;

            Inc(i);
            routebtn.Name := 'R'+IntToStr(i);
            routebtn.OnClick :=newButtonClick;
            Next;
            if routebtn.Name ='R1' then
            begin
              routebtn.Down :=True;
            end;

        end;

    end;
end;

procedure TfMainForm.newButtonClick(Sender: TObject);
begin
    LabProcess.Caption :=TRzButton(Sender).Caption;
    cmbMachine.SetFocus;
    LabButtonName.Caption := TRzButton(Sender).Name;
end;

function TfMainForm.IsDefect: Boolean;
var sSQL: string;
begin
  Result := False;
  sSQL := 'SELECT DEFECT_CODE, DEFECT_DESC, DEFECT_LEVEL, DEFECT_DESC2, '
    + '       DECODE(DEFECT_LEVEL,''0'',''CRITICAL'',''1'',''MAJOR'',''2'',''MINOR'') "LEVEL" '
    + '  FROM SAJET.SYS_DEFECT '
    + ' WHERE DEFECT_CODE = ''' + edtDefect.Text + ''' ';
  with QryTemp do
  begin
    try
      Close;
      Params.Clear;
      CommandText := sSQL;
      Open;
      if Eof then Exit;

      labDefectDesc.Caption := FieldByName('Defect_Desc').AsString;
      //lablDefectDesc2.Caption := FieldByName('Defect_Desc2').AsString;
      //if combDefectLevel.ItemIndex = -1 then
       // combDefectLevel.ItemIndex := FieldByName('DEFECT_LEVEL').AsInteger;
    finally
      Close;
    end;
  end;
  Result := True;
end;

function TfMainForm.checkInput: Boolean;
begin
  Result := False;
  if edtDefect.Text = '' then
  begin
    MessageDlg('Please input Defect Code !!', mtError, [mbOK], 0);
    edtDefect.SetFocus;
    Exit;
  end
  else if not IsDefect then
  begin
    MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
    edtDefect.SelectAll;
    edtDefect.SetFocus;
    Exit;
  end
  else if seditDefectQty.Value <= 0 then
  begin
    MessageDlg('Defect Qty'' can''t be 0 !!', mtError, [mbOK], 0);
    seditDefectQty.SetFocus;
    seditDefectQty.SelectAll;
    Exit;
  end;
  Result := True;
end;


procedure TfMainForm.edtDefectKeyPress(Sender: TObject; var Key: Char);
begin
   if Ord(Key) = VK_Return then
   begin
      edtDefect.Text := UpperCase(edtDefect.Text);
     // combDefectLevel.ItemIndex := -1;
      if not IsDefect then
      begin
        MessageDlg('No such Defect Code !!', mtError, [mbOK], 0);
        edtDefect.SelectAll;
        edtDefect.SetFocus;
        Exit;
      end;
      seditDefectQty.SetFocus;
      seditDefectQty.SelectAll;
   end;
end;

procedure TfMainForm.btnAddClick(Sender: TObject);
var i, iNgCnt: integer;
  bFlag: Boolean;
begin

    if not checkInput then Exit;

    bFlag := True;
    for i := 0 to lvDefect.Items.Count - 1 do
    begin
      if lvDefect.Items[i].Caption = edtDefect.Text then
      begin
        iNgCnt := StrToInt(lvDefect.Items[i].SubItems[1]);
        lvDefect.Items[i].SubItems[1] := IntToStr(iNgCnt + seditDefectQty.Value);
        bFlag := False;
      end;
    end;

    if bFlag then
    begin
      with lvDefect.Items.Add do
      begin
        Caption := edtDefect.Text;
        SubItems.Add(seditDefectQty.Text);
        //SubItems.Add(combDefectLevel.Text);
        //SubItems.Add(IntToStr(combDefectLevel.Items.IndexOf(combDefectLevel.Text)));
        SubItems.Add(labDefectDesc.Caption);
       // SubItems.Add(lablDefectDesc2.Caption);
       // SubItems.Add(trim(editDefectMemo.Text));

      end;
    end;

    edtDefect.Clear;
    labDefectDesc.Caption := '';
    seditDefectQty.Value := 0;
    edtDefect.SetFocus;

end;

procedure TfMainForm.seditDefectQtyKeyPress(Sender: TObject;
  var Key: Char);
begin
    btnAdd.Click;
end;

procedure TfMainForm.btnSubmitClick(Sender: TObject);
begin
     if LabProcess.Caption <> '' then
     begin
         msgPanel.Caption :='Error Process';
         msgPanel.Color := clRed;
         Exit;
     end;
     if cmbMachine.ItemIndex <= -1 then begin
         msgPanel.Caption :='Error Machine';
         msgPanel.Color := clRed;
         Exit;
     end;

     if sempNo ='' then begin
         msgPanel.Caption :='Error Emp No';
         msgPanel.Color := clRed;
         edtEmpNo.SetFocus;
         Exit;
     end;
     
end;

procedure TfMainForm.edtEmpNoChange(Sender: TObject);
begin
    with QryTemp do begin
        Close;
        Params.Clear;
        CommandText := 'select emp_id,emp_no from sajet.sys_emp where emp_no='''+edtEmpNo.Text+'''';
        Open;
        sEmpNo := fieldByName('emo_no').AsString;
        sEmpId :=  fieldByName('emo_id').AsString;
    end;
end;

end.
