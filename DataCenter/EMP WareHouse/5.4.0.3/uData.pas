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
    Label6: TLabel;
    LabType1: TLabel;
    LabType2: TLabel;
    Imagemain: TImage;
    edtEmp: TEdit;
    Label1: TLabel;
    edtwarehouse: TEdit;
    Label2: TLabel;
    Label5: TLabel;
    lablEmpNo: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    lablDesc: TLabel;
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
    procedure WMEraseBkGnd( Var Msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure WMNCHitTest( Var msg: TWMNCHitTest ); message WM_NCHITTEST;
  public
    { Public declarations }
    MaintainType : String;
    UpdateSuccess:boolean;
    sOWarehouseID:string;
    procedure SetTheRegion;
    function GetID(sFieldID,sfield,sTable,sCondition:string):integer;
  end;

var
  fData: TfData;

implementation

uses uEmpWarehouse,uDetail;

{$R *.DFM}
//uses uDPPM;
function TfData.GetID(sfieldID,sField,sTable,sCondition:string):integer;
begin
  result:=0;
  With fDPPM.QryTemp do
  begin
    close;
    params.Clear;
    commandtext:=' select '+sFieldID + ' sID from '+sTable+' where '+sField+' = '+''''+ sCondition+'''';
    open;
    if Not IsEmpty then
      Result:=fieldbyname('sID').AsInteger;
  end;
end;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
  if UpdateSuccess then
     ModalResult:=mrok
  else
    Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
 if FileExists(ExtractFilePath(Application.ExeName) + 'sDetail.bmp') then
 begin
   Imagemain.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sDetail.bmp');
   SetTheRegion;
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

procedure TfData.sbtnSaveClick(Sender: TObject);
Var S : String; I : Integer;
   sEmpID,sWarehouseID:integer;
begin
  sEmpID:= getID('emp_id','emp_no','sajet.sys_emp',trim(edtEMp.Text));
  if sEmpID=0 then
  begin
     MessageDlg('Emp name Error !!',mtError, [mbCancel],0);
     edtEmp.SelectAll;
     edtEmp.SetFocus ;
     Exit;
  end;
  sWarehouseID := getID('warehouse_id','warehouse_name','sajet.sys_warehouse',trim(edtWarehouse.Text)) ;
  if sWarehouseID=0 then
  begin
     MessageDlg('Warehouse Error !!',mtError, [mbCancel],0);
     edtWarehouse.SelectAll;
     edtWarehouse.SetFocus ;
     Exit;
  end;


  If MaintainType = 'Append' Then
  begin
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'empID', ptInput);
        Params.CreateParam(ftString	,'WarehouseID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_emp_warehouse '+
                       'Where emp_id = :empID '+
                       'and warehouse_id = :WarehouseID ';
        Params.ParamByName('empID').AsInteger := sEMPID;
        Params.ParamByName('WarehouseID').AsInteger := sWarehouseID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'EMP : '+ trim(edtEMp.Text) + #13#10 +
                'Warehouse : '+ trim(edtWarehouse.Text) ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;

     Try
        With fDPPM.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'emp_id', ptInput);
           Params.CreateParam(ftString	,'warehouse_id', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           CommandText := 'Insert Into SAJET.sys_emp_warehouse '+
                          ' (emp_id,warehouse_id,update_userid) '+
                          'Values (:emp_id,:warehouse_id,:UPDATE_USERID) ';
           Params.ParamByName('emp_id').AsInteger := sEMPID;
           Params.ParamByName('warehouse_id').AsInteger := sWarehouseID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Execute;
           fDPPM.CopyToHistory(inttostr(sEMPID),inttostr(sWarehouseID));
        end;
     Except
       on E:Exception do
       begin
         MessageDlg('Database Error !!'+#13#10 +
                    E.Message ,mtError, [mbCancel],0);
         Exit;
       end;
     end;

     MessageDlg('Data Append OK!!',mtCustom, [mbOK],0);
     UpdateSuccess := True;
     If MessageDlg('Append Other Data ?',mtCustom, mbOKCancel,0) <> mrOK Then
        ModalResult := mrOK
     else
     begin
        lablempno.Caption:='';
        edtEmp.Text:='';
        edtWarehouse.Text:='';
        lablDesc.Caption:='';
        Exit;
     end;
     Exit;
  end;

  If MaintainType = 'Modify' Then
  begin
     With fDPPM.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString	,'empID', ptInput);
        Params.CreateParam(ftString	,'WarehouseID', ptInput);
        CommandText := 'Select * '+
                       'From SAJET.sys_emp_warehouse '+
                       'Where emp_id = :empID '+
                       'and warehouse_id = :WarehouseID ';
        Params.ParamByName('empID').AsInteger := sEMPID;
        Params.ParamByName('WarehouseID').AsInteger := sWarehouseID;
        Open;
        If RecordCount > 0 Then
        begin
           S := 'Duplicate !! '+#13#10 +
                'EMP : '+ trim(edtEMp.Text) + #13#10 +
                'Warehouse : '+ trim(edtWarehouse.Text) ;
           Close;
           MessageDlg(S,mtError, [mbCancel],0);
           Exit;
        end;
     end;
     Try
        With fDPPM.QryTemp do
        begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString	,'WarehouseID', ptInput);
           Params.CreateParam(ftString	,'EMPID', ptInput);
           Params.CreateParam(ftString	,'UPDATE_USERID', ptInput);
           Params.CreateParam(ftString	,'OWarehouseID', ptInput);
           commandtext := ' Update sajet.sys_emp_warehouse '
                          +' set warehouse_id=:WarehouseID '
                          +'     ,update_userID=:UPDATE_USERID '
                          +'     ,update_time =sysdate '
                          +' where emp_id=:EMPID and warehouse_id=:OWarehouseID ';
           Params.ParamByName('WarehouseID').AsInteger := sWarehouseID;
           Params.ParamByName('EmpID').AsInteger := sEMpID;
           Params.ParamByName('UPDATE_USERID').AsString := fDPPM.UpdateUserID;
           Params.ParamByName('OWarehouseID').AsString := sOWarehouseID;
           Execute;
           fDPPM.CopyToHistory(inttostr(sEMPID),inttostr(sWarehouseID));
           MessageDlg('Data Update OK!!',mtCustom, [mbOK],0);
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

procedure TfData.SpeedButton1Click(Sender: TObject);
var fDetail : TfDetail;
begin
   fDetail:=TfDetail.create(self);
   fDetail.DBGrid1.DataSource.DataSet:=fDppm.QryTemp;
   with fDPPM.Qrytemp do
   begin
     close;
     params.Clear;
     commandtext:='select emp_no,emp_name from sajet.sys_emp where emp_no like '+''''+trim(edtEmp.Text)+'%'+'''';
     open;
   end;
   if fDetail.ShowModal = mrOk then
   begin
     edtemp.Text:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('emp_no').AsString;
     lablempno.Caption:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('emp_name').AsString;
   end;
   fDetail.Free;
end;

procedure TfData.SpeedButton2Click(Sender: TObject);
var fDetail : TfDetail;
begin
   fDetail:=TfDetail.create(self);
   fDetail.DBGrid1.DataSource.DataSet:=fDppm.QryTemp;
   with fDPPM.Qrytemp do
   begin
     close;
     params.Clear;
     commandtext:='select warehouse_name,warehouse_desc from sajet.sys_warehouse where warehouse_name like '+''''+trim(edtwarehouse.Text)+'%'+'''';
     open;
   end;
   if fDetail.ShowModal = mrOk then
   begin
     edtwarehouse.Text:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('warehouse_name').AsString;
     labldesc.Caption:=fDetail.DBGrid1.DataSource.DataSet.fieldbyname('warehouse_desc').AsString+' ';
   end;
   fDetail.Free;  
end;

end.
