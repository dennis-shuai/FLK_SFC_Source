unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB, Grids, DBGrids;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    Label6: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    Label1: TLabel;
    Label4: TLabel;
    cmbMachine: TComboBox;
    cmbMachineID: TComboBox;
    cmbPdline: TComboBox;
    cmbPdlineID: TComboBox;
    cmbTerminal: TComboBox;
    cmbterminalID: TComboBox;
    cmbMline: TComboBox;
    cmbMlineID: TComboBox;
    Label2: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbMachineChange(Sender: TObject);
    procedure cmbPdlineChange(Sender: TObject);
    procedure cmbTerminalChange(Sender: TObject);
    procedure cmbMlineChange(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    ItemID,tLevel: String;
    g_terminalID,g_machineID:string;
    UpdateSuccess : Boolean;
    procedure SetTheRegion;
    Procedure GetMachine;
    procedure GetPdline;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uformMain, uDetail;

procedure TfData.GetPdline;
begin
  cmbPdline.Clear;
  cmbPdlineID.Clear;
  cmbMline.Clear;
  cmbMlineID.Clear;
  With formMain.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select * '
                +' from sajet.sys_pdline '
                +' where enabled=''Y'' ';
    open;
    while not eof do
    begin
      cmbPdline.Items.Add(fieldbyname('pdline_name').AsString);
      cmbPdlineID.Items.Add(fieldbyname('pdline_id').AsString);
      cmbMline.Items.Add(fieldbyname('pdline_name').AsString);
      cmbMlineID.Items.Add(fieldbyname('pdline_id').AsString);
      next;
    end;
  end;
end;

Procedure TfData.GetMachine;
begin
  cmbmachine.Clear;
  cmbMachineID.Clear;
  With formMain.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select * from sajet.sys_machine where enabled = ''Y'' ';
    open;
    while not eof do
    begin
      cmbMachine.Items.Add(fieldbyname('machine_code').AsString);
      cmbMachineID.Items.Add(fieldbyname('machine_id').AsString);
      next;
    end;
  end;
end;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  If UpdateSuccess Then
    ModalResult := mrOK
  else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
  SetTheRegion;
  GetPdline;
  GetMachine;
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
  HR := BmpToRegion( Self, Imagemain.Picture.Bitmap);
  SetWindowRgn( handle, HR, true);
  Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.
procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
  Brush := TBrush.Create;
  Brush.Color := Color;
  FillRect( Msg.DC, ClientRect, Brush.Handle);
  Brush.Free;
  with Imagemain.Picture.Bitmap do
    BitBlt( Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.
procedure TfData.WMNCHitTest( var msg: TWMNCHitTest );
var
  i: integer;
  p: TPoint;
  AControl: TControl;
  MouseOnControl: boolean;
begin
  inherited;
  if msg.result = HTCLIENT then begin
    p.x := msg.XPos;
    p.y := msg.YPos;
    p := ScreenToClient( p);
    MouseOnControl := false;
    for i := 0 to ControlCount-1 do begin
      if not MouseOnControl
      then begin
        AControl := Controls[i];
        if ((AControl is TWinControl) or (AControl is TGraphicControl))
          and (AControl.Visible)
        then MouseOnControl := PtInRect( AControl.BoundsRect, p);
      end
      else
        break;
    end;
    if (not MouseOnControl) then msg.Result := HTCAPTION;
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String;
begin
  if cmbMachine.Items.IndexOf(cmbMachine.Text)=-1 then
  begin
     MessageDlg('Machine Error !!',mtError, [mbCancel],0);
     cmbMachine.SetFocus ;
     Exit;
  end;

  if cmbMline.Items.IndexOf(cmbMline.Text) = -1 then
  begin
     MessageDlg('Machine Line Error !!',mtError, [mbCancel],0);
     cmbMline.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin
     // ÀË¬d Name ¬O§_­«½Æ
     With formMain.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'MachineID', ptInput);
        Params.CreateParam(ftString	,'PdlineID', ptInput);
        Params.CreateParam(ftString	,'TerminalID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_machine_relation '+
                       'Where machine_id=:MachineID '+
                       ' and pdline_id = :PdlineID '+
                       ' and  terminal_id=:TerminalID ';
        Params.ParamByName('machineID').AsString := cmbMachineID.Text;
        Params.ParamByName('pdlineID').AsString := cmbMlineid.Text;
        Params.ParamByName('TerminalID').AsString := cmbTerminalID.Text;
        Open;
        If RecordCount > 0 Then
        begin
           S := ' Data Duplicate !! ';
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;

       { Close;
        Params.Clear;
        Params.CreateParam(ftString	,'TerminalID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_machine_relation '+
                       'Where Terminal_id=:TerminalID ';
        Params.ParamByName('TerminalID').AsString := cmbTerminalID.Text;
        Open;
        If RecordCount > 0 Then
        begin
           S := ' Terminal Has Assign To Another Machine !! ';
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;}
     end;

     Try
        With formMain.QryTemp do
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString	,'TerminalID', ptInput);
          CommandText := 'Select * '+
                       'From SAJET.sys_machine_relation '+
                       'Where Terminal_id=:TerminalID ';
          Params.ParamByName('TerminalID').AsString := cmbTerminalID.Text;
          Open;
          If RecordCount > 0 Then
          begin
            S := ' Terminal Has Assign To Another Machine !! ';
            Close;
            MessageDlg(S,mtError, [mbCancel],0);
            Exit;
          end;
        end;

        With formMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'MachineID', ptInput);
           Params.CreateParam(ftString	,'PdlineID', ptInput);
           Params.CreateParam(ftString	,'TerminalID', ptInput);
           Params.CreateParam(ftString	,'UserID', ptInput);
           CommandText := 'Insert Into SAJET.sys_machine_relation '+
                          ' (pdline_id,machine_id,terminal_id,update_time,update_user_id) '+
                          'Values (:PdlineID,:MachineID,:TerminalID,sysdate,:UserID) ';
           Params.ParamByName('MachineID').AsString := cmbMachineID.Text;
           Params.ParamByName('PdlineID').AsString := cmbMlineID.Text;
           Params.ParamByName('TerminalID').AsString := cmbTerminalID.Text;
           Params.ParamByName('UserID').AsString := formMain.UpdateUserID;
           Execute;
        end;
        formMain.copytoht(cmbMachineID.Text,cmbTerminalID.Text, cmbMlineID.Text)
     Except
       ON E:Exception do
       begin
         MessageDlg('Database Error !!'+e.Message+#13#10 +
                    'could not save to Database !!' ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg(' Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Data ?',mtCustom, mbOKCancel,0) = mrOK Then
     begin
        cmbmachine.ItemIndex:= -1;
        cmbMachineID.ItemIndex:=-1;
        cmbMline.ItemIndex:=-1;
        cmbMlineID.ItemIndex:=-1;
        cmbPdline.ItemIndex:=-1;
        cmbPdlineID.ItemIndex:=-1;
        cmbTerminal.ItemIndex:=-1;
        cmbTerminalID.ItemIndex:=-1;
        Exit;
     end;
  end;

  If MaintainType = 'Modify' Then
  begin
     Try
        With formMain.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'TerminalID', ptInput);
           Params.CreateParam(ftString	,'PdlineID', ptInput);
           Params.CreateParam(ftString	,'UserID', ptInput);
           Params.CreateParam(ftString	,'MachineID', ptInput);
           CommandText := 'Update SAJET.sys_machine_relation  '+
                          'Set terminal_id=:TerminalID, '+
                          '    update_time=sysdate, '+
                              'update_user_id = :UserID '+
                          'Where Machine_id = :MachineID and terminal_id=:oTerminalID and pdline_id = :PdlineID  and rownum=1 ';
           Params.ParamByName('TerminalID').AsString := Trim(cmbTerminalID.Text);
           Params.ParamByName('PdlineID').AsString := Trim(cmbMlineID.Text);
           Params.ParamByName('oTerminalID').AsString := g_terminalID;
           Params.ParamByName('UserID').AsString := formMain.UpdateUserID;;
           Params.ParamByName('MachineID').AsString := Trim(cmbMachineID.Text);
           //Params.ParamByName('MachoineID').AsString := g_machineID;
           Execute;
           
           MessageDlg(' Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;
        formMain.copytoht(Trim(cmbTerminalID.Text),Trim(cmbMachineID.Text),trim(cmbMlineID.Text));
     Except
       ON E:Exception do
       begin
         MessageDlg('Database Error !!'+e.Message+#13#10 +
                    'could not save to Database !!' ,mtError, [mbCancel],0);
         Exit;
       end;
     end;
  End;
  ModalResult := mrOK ;  
end;


procedure TfData.cmbMachineChange(Sender: TObject);
begin
  cmbMachineID.ItemIndex:=cmbMachine.ItemIndex;
end;

procedure TfData.cmbPdlineChange(Sender: TObject);
begin
  cmbPdlineID.ItemIndex:=cmbPdline.ItemIndex;

  With formMain.QryTemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString	,'PdlineID', ptInput);
    commandtext:=' select * from sajet.sys_terminal '
                +' where pdline_id = :PdlineID '
                +'    and Enabled = ''Y'' ';
    Params.ParamByName('PdlineID').AsString := cmbPdlineID.Text;
    open;
    cmbTerminalID.Clear;
    cmbTerminal.Clear;
    while not eof do
    begin
      cmbTerminal.Items.Add(fieldbyname('Terminal_name').AsString);
      cmbTerminalID.Items.Add(fieldbyname('terminal_id').AsString);
      next;
    end;
  end;
end;

procedure TfData.cmbTerminalChange(Sender: TObject);
begin
  cmbTerminalID.ItemIndex:=cmbTerminal.ItemIndex;
end;

procedure TfData.cmbMlineChange(Sender: TObject);
begin
cmbMlineID.ItemIndex:=cmbMline.ItemIndex;
end;

end.
