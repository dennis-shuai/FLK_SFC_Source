unit uData;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
  TfData = class(TForm)
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    Image5: TImage;
    Image1: TImage;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    Label2: TLabel;
    cmbToolingNo: TComboBox;
    lbltoolingid: TLabel;
    Image2: TImage;
    lblDeptid: TLabel;
    Label1: TLabel;
    cmbPdline: TComboBox;
    Label3: TLabel;
    cmbTerminal: TComboBox;
    Label4: TLabel;
    cmbToolingSN: TComboBox;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure cmbToolingNoSelect(Sender: TObject);
    procedure cmbToolingNoChange(Sender: TObject);
    procedure cmbPdlineChange(Sender: TObject);
    procedure cmbPdlineSelect(Sender: TObject);
    procedure cmbTerminalSelect(Sender: TObject);
    procedure cmbToolingSNSelect(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
    function  GetID(sfieldID,sField,sTable,sCondition:string):integer;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess : Boolean;
    stoolingId,spdlineName,spdlineid,stoolingsn,sterminal,sterminalid:string;
    procedure SetTheRegion;
  end;

var
  fData: TfData;

implementation

{$R *.DFM}
uses uDPPM;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  If UpdateSuccess Then
    ModalResult := mrOK
  Else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
 if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
 begin
   Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
   SetTheRegion;
 end;
  with fDetail.QryTemp do
  begin
    close;
    Params.Clear;
    CommandText := ' SELECT A.TOOLING_NO FROM SAJET.SYS_TOOLING A WHERE A.ENABLED=''Y'' '+
                   ' and A.IsRepair_Control =''Y'' ORDER BY A.TOOLING_NO  ';
    Open;
    cmbToolingNo.Clear;
    First;
    while not Eof do
    begin
      cmbToolingNo.Items.Add(FieldByName('TOOLING_NO').AsString);
      Next;
    end;

    close;
    Params.Clear;
    CommandText := ' SELECT PDLINE_NAME FROM SAJET.SYS_PDLINE A WHERE A.ENABLED=''Y'' '+
                   ' ORDER BY A.PDLINE_NAME  ';
    Open;
    cmbPdline.Clear;
    First;
    while not Eof do
    begin
      cmbPdline.Items.Add(FieldByName('PDLINE_NAME').AsString);
      Next;
    end;
  end;


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

function TfData.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With fDetail.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select '+sFieldID + ' sID from '+sTable+' where '+sField+' = '+''''+ sCondition+'''';
    open;
    if Not IsEmpty then
      Result:=fieldbyname('sID').AsInteger;
  end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String; I : Integer;
begin


  If (cmbToolingSN.ItemIndex = -1) or (stoolingId='0') Then
  begin
     MessageDlg('tooling sn Error !!',mtError, [mbCancel],0);
     cmbToolingSN.SetFocus ;
     Exit;
  end;
  If (cmbTerminal.ItemIndex = -1) or (sterminalid='0') Then
  begin
     MessageDlg('Terminal name Error !!',mtError, [mbCancel],0);
     cmbTerminal.SetFocus ;
     Exit;
  end;

  If MaintainType = 'Append' Then
  begin

     with fDetail.QryTemp do
     begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'tooling_sn_id', ptInput);
        Params.CreateParam(ftString	,'terminal_id', ptInput);
        CommandText := 'Select *  From sajet.sys_tooling_TERMINAL '+
                       'Where terminal_id = :terminal_id '+
                       'or tooling_sn_id = :tooling_sn_id ';
        Params.ParamByName('tooling_sn_id').AsString := stoolingId;
        Params.ParamByName('terminal_id').AsString := sterminalid;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'tooling SN : '+ cmbToolingSN.Text + #13#10 +
                'Pdline : '+ cmbPdline.Text + #13#10 +
                'Terminal : '+ cmbTerminal.Text  ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With fDetail.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'terminal_id', ptInput);
           CommandText := 'Insert Into sajet.sys_tooling_TERMINAL'+
                          ' (tooling_sn_id,terminal_id, UPDATE_USERID,update_time) '+
                          'Values (:tooling_id,:terminal_id, :UPDATE_USERID,sysdate) ';
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_id').AsString := stoolingId;
           Params.ParamByName('terminal_id').AsString := sterminalid ;
           Execute;
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('tooling_no Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Part_no Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
       // cmbToolingNo.ItemIndex:=-1;
        sterminalid :='0';
        stoolingId :='0';
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     with fDetail.QryTemp do
     begin

        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'tooling_sn_id', ptInput);
        Params.CreateParam(ftString	,'terminal_id', ptInput);
        CommandText := ' Select b.tooling_sn  From sajet.sys_tooling_TERMINAL a,sajet.sys_toolind_sn b  '+
                       ' Where a.terminal_id = :terminal_id '+
                       ' and a.tooling_sn_id <> :tooling_sn_id '+
                       ' and  a.tooling_sn_id=b.tooling_sn_id ';
        Params.ParamByName('tooling_sn_id').AsString := stoolingId;
        Params.ParamByName('terminal_id').AsString := sterminalid;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'tooling SN : '+ fieldbyName('tooling_sn').AsString + #13#10 +
                'pdline  : '+ cmbPdline.Text + #13#10 +
                'Terminal : '+ cmbTerminal.Text  ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With fDetail.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'tooling_id', ptInput);
           Params.CreateParam(ftString	,'Terminal_id', ptInput);
           CommandText := 'Update SAJET.sys_tooling_terminal '+
                          'Set Terminal_id =:Terminal_id  ,'+
                          'UPDATE_USERID = :UPDATE_USERID,'+
                          'UPDATE_TIME = SYSDATE '+
                          'Where tooling_sn_id = :tooling_id ';
           Params.ParamByName('UPDATE_USERID').AsString := fDetail.UpdateUserID;
           Params.ParamByName('tooling_ID').AsString := stoolingId;
           Params.ParamByName('Terminal_id').AsString := sterminalid;
           Execute;
           
           MessageDlg('tooling_no Data Update OK!!',mtCustom, [mbOK],0);
           ModalResult := mrOK;
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;  
     end;
  End;


end;

procedure TfData.cmbToolingNoSelect(Sender: TObject);
begin
   cmbToolingNoChange(Sender);
end;

procedure TfData.cmbToolingNoChange(Sender: TObject);
begin
   with fDetail.QryTemp do
   begin
      close;
      Params.Clear;
      Params.CreateParam(ftString,'Tooling_Name',ptInput);
      CommandText := ' SELECT B.TOOLING_SN FROM SAJET.SYS_TOOLING A,SAJET.SYS_TOOLING_SN B WHERE B.ENABLED=''Y'' '+
                     ' AND A.IsRepair_Control =''Y'' AND a.tooling_NO =:Tooling_Name '+
                     ' AND  A.TOOLING_ID=B.TOOLING_ID ORDER BY B.TOOLING_SN  ';
      Params.ParamByName('Tooling_Name').AsString := cmbToolingNo.Items.Strings[cmbToolingNo.ItemIndex];
      Open;
      cmbToolingSN.Clear;
      First;
      while not Eof do
      begin
        cmbToolingSN.Items.Add(FieldByName('TOOLING_SN').AsString);
        Next;
      end;
   end;

end;

procedure TfData.cmbPdlineChange(Sender: TObject);
begin
   sterminalid :='0';
   with fDetail.QryTemp do
   begin
      close;
      Params.Clear;
      Params.CreateParam(ftString,'pdline_Name',ptInput);
      CommandText := ' SELECT b.Terminal_Id, B.TERMINAL_NAME FROM SAJET.SYS_PDLINE A,SAJET.SYS_TERMINAL B WHERE B.ENABLED=''Y'' '+
                     ' and    A.PDLINE_ID=B.PDLINE_ID  and a.pdline_name =:pdline_Name ORDER BY B.TERMINAL_NAME  ';
      Params.ParamByName('pdline_Name').AsString := cmbPdline.Items.Strings[cmbPdline.ItemIndex];
      Open;

      cmbTerminal.Clear;
      First;
      while not Eof do
      begin
        cmbTerminal.Items.Add(FieldByName('TERMINAL_NAME').AsString);
        Next;
      end;
      if RecordCount=1 then  begin
          cmbTerminal.ItemIndex :=0;
          sterminalid :=FieldByName('TERMINAL_ID').AsString;
      end;

   end;
end;

procedure TfData.cmbPdlineSelect(Sender: TObject);
begin
    cmbPdlineChange(Sender);
end;

procedure TfData.cmbTerminalSelect(Sender: TObject);
begin
   with fDetail.QryTemp do
   begin
   
      close;
      Params.Clear;
      Params.CreateParam(ftString,'pdline_Name',ptInput);
      Params.CreateParam(ftString,'Terminal_Name',ptInput);
      CommandText := ' SELECT b.Terminal_Id FROM SAJET.SYS_PDLINE A,SAJET.SYS_TERMINAL B WHERE B.ENABLED=''Y'' '+
                     ' and A.PDLINE_ID=B.PDLINE_ID and a.pdline_name =:pdline_Name and b.terminal_Name =:Terminal_Name ORDER BY B.TERMINAL_NAME  ';
      Params.ParamByName('pdline_Name').AsString := cmbPdline.Items.Strings[cmbPdline.ItemIndex];
      Params.ParamByName('Terminal_Name').AsString := cmbTerminal.Items.Strings[cmbTerminal.ItemIndex];
      Open;
      sterminalid :=FieldByName('TERMINAL_ID').AsString;

   end;

end;

procedure TfData.cmbToolingSNSelect(Sender: TObject);
begin
   with fDetail.QryTemp do
   begin
      close;
      Params.Clear;
      Params.CreateParam(ftString,'tooling_sn',ptInput);
      CommandText := ' SELECT a.tooling_sn_id FROM SAJET.SYS_Tooling_sn A  WHERE A.ENABLED=''Y'' '+
                     ' and A.tooling_SN = :tooling_sn ';
      Params.ParamByName('tooling_sn').AsString := cmbToolingSN.Items.Strings[cmbToolingSN.ItemIndex];
      Open;


      stoolingId :=FieldByName('tooling_sn_id').AsString;


   end;

end;

end.
