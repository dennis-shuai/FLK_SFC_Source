unit uData;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   jpeg, ExtCtrls, StdCtrls, Buttons, BmpRgn, DB;

type
   TfData = class(TForm)
      sbtnCancel: TSpeedButton;
      sbtnSave: TSpeedButton;
      Label3: TLabel;
      Image5: TImage;
      Label4: TLabel;
      Image1: TImage;
      Label6: TLabel;
      Label7: TLabel;
      LabType1: TLabel;
      LabType2: TLabel;
      Imagemain: TImage;
      editEmpNo: TEdit;
      editEmpName: TEdit;
      Label1: TLabel;
      cmbShift: TComboBox;
      cmbFactory: TComboBox;
      LabDesc: TLabel;
      Label2: TLabel;
      Label5: TLabel;
      cmbDept: TComboBox;
      procedure sbtnCancelClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure sbtnSaveClick(Sender: TObject);
      procedure cmbFactoryChange(Sender: TObject);
   private
    { Private declarations }
      procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
      procedure WMNCHitTest(var msg: TWMNCHitTest); message WM_NCHITTEST;
   public
    { Public declarations }
      MaintainType: string;
      EmpID: string;
      FcID: string; // User 所選的廠別
      UpdateSuccess: Boolean;
      function GetMaxEmpID: string;
      procedure SetTheRegion;
   end;

var
   fData: TfData;

implementation

{$R *.DFM}
uses uEmp;

procedure TfData.sbtnCancelClick(Sender: TObject);
begin
   if UpdateSuccess then
      ModalResult := mrOK
   else
      Close;
end;

procedure TfData.FormCreate(Sender: TObject);
begin
   SetTheRegion;
end;

procedure TfData.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

// This routine takes care of drawing the bitmap on the form.

procedure TfData.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
var Brush: TBrush;
begin
   Brush := TBrush.Create;
   Brush.Color := Color;
   FillRect(Msg.DC, ClientRect, Brush.Handle);
   Brush.Free;
   with Imagemain.Picture.Bitmap do
      BitBlt(Msg.DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
   Msg.Result := 1;
end;

// This routine takes care of letting the user move the form
// around on the desktop.

procedure TfData.WMNCHitTest(var msg: TWMNCHitTest);
var
   i: integer;
   p: TPoint;
   AControl: TControl;
   MouseOnControl: boolean;
begin
   inherited;
   if msg.result = HTCLIENT then
   begin
      p.x := msg.XPos;
      p.y := msg.YPos;
      p := ScreenToClient(p);
      MouseOnControl := false;
      for i := 0 to ControlCount - 1 do
      begin
         if not MouseOnControl
            then
         begin
            AControl := Controls[i];
            if ((AControl is TWinControl) or (AControl is TGraphicControl))
               and (AControl.Visible)
               then MouseOnControl := PtInRect(AControl.BoundsRect, p);
         end
         else
            break;
      end;
      if (not MouseOnControl) then msg.Result := HTCAPTION;
   end;
end;

function TfData.GetMaxEmpID: string;
var DBID: string;
begin
   with fEmp.QryTemp do
   begin
      Close;
      Params.Clear;
      CommandText := 'Select NVL(Max(EMP_ID),0) + 1 EMPID ' +
         'From SAJET.SYS_EMP';
      Open;
      if Fieldbyname('EMPID').AsString = '1' then
      begin
         Close;
         CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' EMPID ' +
            'From SAJET.SYS_BASE ' +
            'Where PARAM_NAME = ''DBID'' ';
         Open;
      end;
      Result := Fieldbyname('EMPID').AsString;
      Close;
   end;
end;

procedure TfData.sbtnSaveClick(Sender: TObject);
var S: string; sEmpId: string; I: Integer; sDeptID,sShiftID: string;
   function GetDeptID: string;
   begin
      Result := '';
      with fEmp.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'DEPT', ptInput);
         CommandText := 'Select DEPT_ID ' +
            'From SAJET.SYS_DEPT ' +
            'Where DEPT_NAME = :DEPT order by dept_name asc';
         Params.ParamByName('DEPT').AsString := cmbDept.Text;
         Open;
         if RecordCount > 0 then
            Result := Fieldbyname('DEPT_ID').AsString;
         Close;
      end;
   end;

   function GetShiftID: string;
   begin
      Result := '0';
      with fEmp.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'SHIFT', ptInput);
         CommandText := 'Select SHIFT_ID ' +
            'From SAJET.SYS_SHIFT ' +
            'Where SHIFT_CODE = :SHIFT ';
         Params.ParamByName('SHIFT').AsString := cmbShift.Text;
         Open;
         if RecordCount > 0 then
            Result := Fieldbyname('SHIFT_ID').AsString;
         Close;
      end;
   end;
begin
   if Trim(editEmpNo.Text) = '' then
   begin
      MessageDlg('Employee No Error !!', mtError, [mbCancel], 0);
      editEmpNo.SetFocus;
      Exit;
   end;
   
   if Trim(editEmpName.Text) = '' then
   begin
      MessageDlg('Employee Name Error !!', mtError, [mbCancel], 0);
      editEmpName.SetFocus;
      Exit;
   end;

   if (Trim(cmbDept.Text) = '') then
   begin
      MessageDlg('Department Error !!', mtError, [mbCancel], 0);
      cmbDept.SetFocus;
      Exit;
   end;

   sDeptID := GetDeptID;
   sShiftID := GetShiftID;
   if MaintainType = 'Append' then
   begin
     // 檢查 NO 是否重複
      with fEmp.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_NO', ptInput);
         CommandText := 'Select EMP_NO,EMP_NAME ' +
            'From SAJET.SYS_EMP ' +
            'Where EMP_NO = :EMP_NO ';
         Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(editEmpNo.Text));
         Open;
         if RecordCount > 0 then
         begin
            S := 'Employee No Duplicate !! ' + #13#10 +
               'Employee No. : ' + Fieldbyname('EMP_NO').AsString + #13#10 +
               'Name : ' + Fieldbyname('EMP_NAME').AsString;
            Close;
            MessageDlg(S, mtError, [mbCancel], 0);
            Exit;
         end;
      end;
     // 新增一筆員工紀錄
      I := 0;
      sEmpId := '';
      while True do
      begin
         try
            sEmpId := GetMaxEmpID;
            Break;
         except
            Inc(I); // try 10 次, 若抓不到, 則跳離開來
            if I >= 10 then
               Break;
         end;
      end;

      if sEmpId = '' then
      begin
         MessageDlg('Database Error !!' + #13#10 +
            'could not get Emp Id !!', mtError, [mbCancel], 0);
         Exit;
      end;

      try
         with fEmp.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'FCID', ptInput);
            Params.CreateParam(ftString, 'EMP_ID', ptInput);
            Params.CreateParam(ftString, 'EMP_NO', ptInput);
            Params.CreateParam(ftString, 'EMP_NAME', ptInput);
            Params.CreateParam(ftString, 'DEPT_ID', ptInput);
            Params.CreateParam(ftString, 'SHIFT', ptInput);
            Params.CreateParam(ftString, 'PASSWD', ptInput);
            Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
            CommandText := 'Insert Into SAJET.SYS_EMP '
               + ' (FACTORY_ID,EMP_ID,EMP_NO,EMP_NAME,DEPT_ID,SHIFT,PASSWD,UPDATE_USERID) '
               + 'Values (:FCID,:EMP_ID,:EMP_NO,:EMP_NAME,:DEPT_ID,:SHIFT,sajet.password.encrypt(:PASSWD),:UPDATE_USERID) ';
            Params.ParamByName('FCID').AsString := FcID;
            Params.ParamByName('EMP_ID').AsString := sEmpId;
            Params.ParamByName('EMP_NO').AsString := Trim(editEmpNo.Text);
            Params.ParamByName('EMP_NAME').AsString := Trim(editEmpName.Text);
            Params.ParamByName('DEPT_ID').AsString := sDeptID;
            Params.ParamByName('SHIFT').AsString := sShiftID;
            if fEmp.gsDefaultPasswd <> '' then
               Params.ParamByName('PASSWD').AsString := fEmp.gsDefaultPasswd
            else
               Params.ParamByName('PASSWD').AsString := Trim(editEmpNo.Text);
            Params.ParamByName('UPDATE_USERID').AsString := fEmp.UpdateUserID;
            Execute;
            fEmp.CopyToHistory(sEmpId);
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not save to Database !!', mtError, [mbCancel], 0);
         Exit;
      end;

      MessageDlg('Employee Data Append OK!!', mtCustom, [mbOK], 0);
      UpdateSuccess := True;
      if MessageDlg('Append Other Employee Data ?', mtCustom, mbOKCancel, 0) <> mrOK then
         ModalResult := mrOK
      else
      begin
         editEmpNo.Text := '';
         editEmpName.Text := '';
         editEmpNo.SetFocus;
         Exit;
      end;
      Exit;
   end;

   if MaintainType = 'Modify' then
   begin
     // 檢查 NO 是否重複
      with fEmp.QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'EMP_NO', ptInput);
         Params.CreateParam(ftString, 'EMP_ID', ptInput);
         CommandText := 'Select EMP_NO,EMP_NAME ' +
            'From SAJET.SYS_EMP ' +
            'Where EMP_NO = :EMP_NO and ' +
            'EMP_ID <> :EMP_ID ';
         Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(editEmpNo.Text));
         Params.ParamByName('EMP_ID').AsString := EMPID;
         Open;
         if RecordCount > 0 then
         begin
            S := 'Employee No Duplicate !! ' + #13#10 +
               'Employee No. : ' + Fieldbyname('EMP_NO').AsString + #13#10 +
               'Name : ' + Fieldbyname('EMP_NAME').AsString;
            Close;
            MessageDlg(S, mtError, [mbCancel], 0);
            Exit;
         end;
      end;

      try
         with fEmp.QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'FCID', ptInput);
            Params.CreateParam(ftString, 'EMP_NO', ptInput);
            Params.CreateParam(ftString, 'EMP_NAME', ptInput);
            Params.CreateParam(ftString, 'DEPT_ID', ptInput);
            Params.CreateParam(ftString, 'SHIFT', ptInput);
            Params.CreateParam(ftString, 'UPDATE_USERID', ptInput);
            Params.CreateParam(ftString, 'EMP_ID', ptInput);
            CommandText := 'Update SAJET.SYS_EMP ' +
               'Set FACTORY_ID = :FCID,' +
               'EMP_NO = :EMP_NO,' +
               'EMP_NAME = :EMP_NAME,' +
               'DEPT_ID = :DEPT_ID,' +
               'SHIFT = :SHIFT,' +
               'UPDATE_USERID = :UPDATE_USERID,' +
               'UPDATE_TIME = SYSDATE ' +
               'Where EMP_ID = :EMP_ID ';
            Params.ParamByName('FCID').AsString := FcID;
            Params.ParamByName('EMP_NO').AsString := Trim(editEmpNo.Text);
            Params.ParamByName('EMP_NAME').AsString := Trim(editEmpName.Text);
            Params.ParamByName('DEPT_ID').AsString := sDeptID;
            Params.ParamByName('SHIFT').AsString := sShiftID;
            Params.ParamByName('UPDATE_USERID').AsString := fEmp.UpdateUserID;
            Params.ParamByName('EMP_ID').AsString := EMPID;
            Execute;
            fEmp.CopyToHistory(EMPID);
            MessageDlg('Employee Data Update OK!!', mtCustom, [mbOK], 0);
            ModalResult := mrOK;
         end;
      except
         MessageDlg('Database Error !!' + #13#10 +
            'could not Update Database !!', mtError, [mbCancel], 0);
         Exit;
      end;
   end;
end;

procedure TfData.cmbFactoryChange(Sender: TObject);
begin
   FcID := '';
   if cmbFactory.Text = 'N/A' then
   begin
      FcID := '0';
      LabDesc.Caption := '';
   end
   else
   begin
     with fEmp.QryTemp do
     begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'FACTORYCODE', ptInput);
        CommandText := 'Select FACTORY_ID,FACTORY_CODE,FACTORY_NAME,FACTORY_DESC ' +
           'From SAJET.SYS_FACTORY ' +
           'Where FACTORY_CODE = :FACTORYCODE ';
        Params.ParamByName('FACTORYCODE').AsString := Copy(cmbFactory.Text, 1, POS(' ', cmbFactory.Text) - 1);
        Open;
        if RecordCount > 0 then
        begin
           FcID := Fieldbyname('FACTORY_ID').AsString;
           LabDesc.Caption := Fieldbyname('FACTORY_DESC').AsString;
        end;
        Close;
     end;
   end;
   
   cmbDept.Items.Clear;
   with fEmp.QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'FCID', ptInput);
      CommandText := 'Select DEPT_ID,DEPT_NAME ' +
         'From SAJET.SYS_DEPT ' +
         'Where ENABLED = ''Y'' and ' +
         'FACTORY_ID = :FCID order by dept_name asc';
      Params.ParamByName('FCID').AsString := FcID;
      Open;
      while not Eof do
      begin
         cmbDept.Items.Add(Fieldbyname('DEPT_NAME').AsString);
         Next;
      end;
      Close;
   end;
end;

end.

