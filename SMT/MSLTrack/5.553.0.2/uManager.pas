unit uManager;

interface

uses
   Windows, Messages,Variants, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,
   MConnect, SConnect, ComCtrls,Excel97, ObjBrkr, ImgList, Clrgrid, Menus,comobj,
   Math, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, StdCtrls, Grids, DBGrids, GradPanel,
  Buttons,comobj,Excel97, ComCtrls, Clrgrid,StrUtils;
}
type
   TfManager = class(TForm)
      Panel1: TPanel;
      labTitleB: TLabel;
      labTitle: TLabel;
      Image5: TImage;
      imageAll: TImage;
      Image2: TImage;
      Label13: TLabel;
      sbtnFilter: TSpeedButton;
      qryTemp: TClientDataSet;
      Label35: TLabel;
      edtMSL: TEdit;
      Image1: TImage;
      LabAppend: TLabel;
      sbtnAppend: TSpeedButton;
      Image3: TImage;
      LabModify: TLabel;
      sbtnModify: TSpeedButton;
      Image7: TImage;
      Label11: TLabel;
      sbtnExport: TSpeedButton;
      ImgDelete: TImage;
      LabDelete: TLabel;
      sbtnDelete: TSpeedButton;
      TreeBOM: TTreeView;
      LvData: TListView;
      Label1: TLabel;
      Label2: TLabel;
      Label3: TLabel;
      lablPartNo: TLabel;
      lablPDLine: TLabel;
      lablVersion: TLabel;
      ImageList1: TImageList;
    Edit1: TEdit;
    Label4: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Qrytemp1: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryTemp2: TClientDataSet;
    DataSource1: TDataSource;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    ITEMNAME: TcxGridDBColumn;
    ITEMBC: TcxGridDBColumn;
    SLOTNO: TcxGridDBColumn;
    INTIME: TcxGridDBColumn;
    EMPNAME: TcxGridDBColumn;
    SIDE: TcxGridDBColumn;
    vendorlotno: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    sbtnSearch: TSpeedButton;
    Label5: TLabel;
    cmbLine: TComboBox;
    machine: TcxGridDBColumn;
    feeder: TcxGridDBColumn;
    Image4: TImage;
    sbtnCheck: TSpeedButton;
    Label6: TLabel;
    Image6: TImage;
    cmbMSL: TComboBox;
    sbtnClose: TSpeedButton;
      procedure sbtnCloseClick(Sender: TObject);
      procedure sbtnFilterClick(Sender: TObject);
      procedure edtMSLKeyPress(Sender: TObject; var Key: Char);
      procedure TreeBOMClick(Sender: TObject);
      procedure sbtnDeleteClick(Sender: TObject);
      procedure LvDataSelectItem(Sender: TObject; Item: TListItem;
         Selected: Boolean);
      procedure sbtnAppendClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure cmbLineChange(Sender: TObject);
    procedure sbtnCheckClick(Sender: TObject);
    procedure edtMSLChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      sPath, SelectType, UpdateUserID,sPartID,sPdLineID: string;
      procedure ShowPartData(sSlot: string);
      procedure ShowData;
      function GetPartNoID(PartNo: string; var PartId: string): Boolean;
      procedure ShowSMT(sMslNo,sSlot,sLine :String);
      procedure GetLine;
   end;

var
   fManager: TfManager;

implementation

uses uFilter, uData, uCheck, uDllform;

{$R *.DFM}

procedure TfManager.sbtnCloseClick(Sender: TObject);
begin
   close;
end;
procedure TfManager.ShowSMT(sMslNo,sSlot,sLine :String);
var sSQL :String;
    i :integer;
begin
  with QryTemp2 do
    begin
      close;
      sSQL:='select c.part_no,a.reel_no,b.vendor_lotno,a.slot_no,decode(g.side,''0'',''TOP'',''BOT'') side,a.in_time,d.emp_name,f.machine_code,g.feeder_type '+
                   ' from smt.g_smt_status a,sajet.g_part_map b,sajet.sys_part c,sajet.sys_emp d,sajet.sys_machine f,smt.g_msl g,sajet.sys_pdline h '+
                   ' where a.reel_no=b.part_sn '+
                   '   and b.part_id=c.part_id '+
                   '   and a.msl_no=g.msl_no '+
                   '   and a.slot_no=g.slot_no '+
                   '   and a.emp_id=d.emp_id '+
                   '   and g.machine_id=f.machine_id '+
                   '   and a.pdline_id=h.pdline_id '+
                   '   and a.msl_no='''+sMslNo+''''+
                   '   and h.pdline_name='''+sLine+'''';
      if sSlot<>'' then
        sSQL:=sSQL+' and a.slot_no='''+sSlot+'''';
      sSQL:=sSQL+'group by c.part_no, a.reel_no, b.vendor_lotno, a.slot_no, side, a.in_time, d.emp_name,f.machine_code,g.feeder_type ';
      CommandText:=sSQL;
      open;
      for i:=0 to cxGrid1DBTableView1.ColumnCount-1 do    //add by ice 080916
      begin
        cxGrid1DBTableView1.ApplyBestFit;
      end;
    end;
end;
procedure TfManager.sbtnFilterClick(Sender: TObject);
var sSQL:string;
begin
   with fFilter.qryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL', ptInput);

      CommandText := 'Select MSL_No, Part_No, PDLine_Name, A.Version ' +
         'From SMT.G_MSL a, sajet.sys_pdline b, sajet.sys_part c ' +
         'Where MSL_NO Like :MSL ' +
         'and a.part_id = c.part_id(+) ' +
         'and a.pdline_id = b.pdline_id(+) ' +
         'group by MSL_No, Part_No, PDLine_Name, A.Version ' +
         'Order By MSL_NO';
      sSQL:=CommandText;   
      Params.ParamByName('MSL').AsString := Trim(edtMSL.Text) + '%';
      Open;
      if RecordCount <> 0 then
      begin
         if fFilter.Showmodal = mrOK then
         begin
            edtMSL.Text := Fieldbyname('MSL_NO').AsString;
            lablVersion.Caption := Fieldbyname('Version').AsString;
            //lablPDLine.Caption := Fieldbyname('PDLine_Name').AsString;     //delete by ice 080909
            lablPartNo.Caption := Fieldbyname('PART_NO').AsString;
     //       labSide.Caption := Fieldbyname('SIDE').AsString;
            ShowData;
            GetLine;     //add by ice 080909
            //ShowSMT(edtMSL.Text,'');          //delete by ice 080901
         end;
      end;
      Close;
   end;
end;

procedure TfManager.ShowData;
begin
   TreeBOM.Items.Clear;
   LvData.Items.Clear;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL', ptInput);
      CommandText := 'Select MSL_No, Part_No, A.Version ' +
         'From SMT.G_MSL a, sajet.sys_part c ' +
         'Where MSL_NO = :MSL ' +
         'and a.part_id = c.part_id ' +
//         'group by MSL_No, Part_No, PDLine_Name, Version ' +
      'Order By MSL_NO';
      Params.ParamByName('MSL').AsString := Trim(edtMSL.Text);
      Open;
      if RecordCount <= 0 then
      begin
         Close;
         MessageDlg('MSL No Error!!', mtError, [mbOK], 0);
         edtMSL.SetFocus;
         edtMSL.SelectAll;
         Exit;
      end;
      edtMSL.Text := qryTemp.Fieldbyname('MSL_NO').AsString;
      lablVersion.Caption := qryTemp.Fieldbyname('Version').AsString;
      //lablPDLine.Caption := qryTemp.Fieldbyname('PDLine_Name').AsString;     //delete by ice 080909
      QryTemp2.Close;
      lablPDLine.Caption := '';   //add by ice 080911
      lablPartNo.Caption := qryTemp.Fieldbyname('PART_NO').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL', ptInput);
      CommandText := 'Select slot_no ' +
         'From SMT.G_MSL a ' +
         'Where MSL_NO = :MSL ' +
         'group By slot_no order by slot_no';
      Params.ParamByName('MSL').AsString := Trim(edtMSL.Text);
      Open;
      while not eof do
      begin
         //mNode :=
         TreeBOM.Items.AddChild(nil, FieldByName('slot_no').AsString);
         Next;
      end;
      ShowPartData(TreeBOM.Items.Item[0].Text);
      //mNode := nil;
   end;
end;

procedure TfManager.ShowPartData(sSlot: string);
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSLNO', ptInput);
      Params.CreateParam(ftString, 'sSlot', ptInput);
      CommandText := 'Select A.PART_NO ITEM_PART_NO,decode(B.SIDE,''0'',''TOP'',''BOT'') SIDE,C.LOCATION, ' +    //MODIFY BY ICE 080904
         'B.ITEM_COUNT, a.spec1 ' +
         'From SAJET.SYS_PART A,' +
         'SMT.G_MSL B, ' +
         'SMT.G_MSL_LOCATION C ' +
         'Where B.MSL_NO = :MSLNO and ' +
         'B.slot_no = :sSlot and ' +
         'B.ITEM_PART_ID = A.PART_ID AND ' +
         'B.MSL_NO = C.MSL_NO AND ' +
         'B.slot_no = C.slot_no ' +
         'order by b.part_type';
      Params.ParamByName('MSLNO').AsString := edtMSL.Text;
      Params.ParamByName('sSlot').AsString := sSlot;
      Open;
      LvData.Items.Clear;
      while not Eof do
      begin
         with LvData.Items.Add do
         begin
            ImageIndex := 2;
            Caption := Fieldbyname('ITEM_PART_NO').AsString;
            Subitems.Add(Fieldbyname('ITEM_COUNT').AsString);
            //Subitems.Add(Fieldbyname('spec1').AsString);
            Subitems.Add(Fieldbyname('SIDE').AsString);
            Subitems.Add(Fieldbyname('LOCATION').AsString);
         end;
         Next;
      end;
      Close;
   end;
end;

procedure TfManager.edtMSLKeyPress(Sender: TObject; var Key: Char);
begin
   if Ord(Key) = vk_Return then
   begin
      if edtMSL.Text <> '' then
         begin
           ShowData;
           GetLine;     //add by ice 080909
           //ShowSMT(edtMSL.Text,'');     //delete by ice 080904
         end;
   end;
end;

procedure TfManager.TreeBOMClick(Sender: TObject);
begin
   SelectType := 'Slot';
   ShowPartData(TreeBOM.Selected.Text);
   if cmbLine.ItemIndex<>-1 then
      ShowSMT(edtMSL.Text,TreeBOM.Selected.Text,cmbLine.Text);     //delete by ice 080904
end;

function TfManager.GetPartNoID(PartNo: string; var PartId: string): Boolean;
begin
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'PARTNO', ptInput);
      CommandText := 'Select PART_ID,ENABLED ' +
         'From SAJET.SYS_PART ' +
         'Where PART_NO = :PARTNO ';
      Params.ParamByName('PARTNO').AsString := PartNo;
      Open;
      if RecordCount > 0 then
      begin
         if Fieldbyname('ENABLED').AsString = 'Y' then
         begin
            PartId := Fieldbyname('PART_ID').AsString;
            Result := True;
         end
         else
         begin
            MessageDlg('Part No Invalid !!', mtError, [mbCancel], 0);
            Result := False;
         end;
      end
      else
      begin
         MessageDlg('Part No Error !!', mtError, [mbCancel], 0);
         Result := False;
      end;
      Close;
   end;
end;

procedure TfManager.sbtnDeleteClick(Sender: TObject);
var sSLot, SubPartNo, SubPartID, sMsg: string;
begin
   if edtMSL.Text='' then
     begin
       MessageDlg('Msl NO. is Null !!', mtCustom, [mbOK], 0);
       exit;
     end;

   with qrytemp do
      begin
        close;
        CommandText:='select * from smt.G_SMT_STATUS where msl_no='''+edtMSL.Text+''' ';    //modify by ice 080911
        open;
        if recordcount>0 then
        begin
          MessageDlg('MSL is running now!', mtError, [mbOK], 0);
          Exit;
        end;
      end;

   if TreeBOM.Selected = nil then
      sSLot := TreeBOM.Items.Item[0].Text
   else
      sSLot := TreeBOM.Selected.Text;
   if SelectType = 'Item' then
   begin
      if LvData.Selected = nil then
         Exit;
      SubPartNo := LvData.Selected.Caption;
      if not GetPartNoID(SubPartNo, SubPartId) then
         Exit;
      sMsg := 'Do you want to delete this data ?' + #13#10 +
         'Part No : ' + SubPartNo;
   end
   else
   begin
      if TreeBOM.Selected = nil then
         Exit;
      SubPartNo := '';
      sMsg := 'Do you want to delete this data ?' + #13#10 +
         'SLot No : ' + sSLot;
   end;
   if MessageDlg(sMsg, mtWarning, mbOKCancel, 0) = mrOK then
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'MSL_NO', ptInput);
         Params.CreateParam(ftString, 'SLOT_NO', ptInput);
         if SelectType = 'Item' then
            Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
         CommandText := 'Delete SMT.G_MSL ' +
            'Where MSL_NO = :MSL_NO and ' +
            'slot_no = :slot_no ';
         if SelectType = 'Item' then
            CommandText := CommandText + 'and ITEM_PART_ID = :ITEM_PART_ID ';
         Params.ParamByName('MSL_NO').AsString := edtMSL.Text;
         Params.ParamByName('SLOT_NO').AsString := sSLot;
         if SelectType = 'Item' then
            Params.ParamByName('ITEM_PART_ID').AsString := SubPartID;
         Execute;

         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'MSL_NO', ptInput);
         Params.CreateParam(ftString, 'SLOT_NO', ptInput);
         CommandText := 'select * from SMT.G_MSL ' +
            'Where MSL_NO = :MSL_NO and ' +
            'slot_no = :slot_no ';
         Params.ParamByName('MSL_NO').AsString := edtMSL.Text;
         Params.ParamByName('SLOT_NO').AsString := sSLot;
         open;
         if recordcount=0 then
         begin
           Close;
           Params.Clear;
           Params.CreateParam(ftString, 'MSL_NO', ptInput);
           Params.CreateParam(ftString, 'SLOT_NO', ptInput);
           CommandText := 'Delete SMT.G_MSL_LOCATION ' +
              'Where MSL_NO = :MSL_NO and ' +
              'slot_no = :slot_no ';
           Params.ParamByName('MSL_NO').AsString := edtMSL.Text;
           Params.ParamByName('SLOT_NO').AsString := sSLot;
           Execute;
         end;
         close;
      end;
      ShowData;
   end;
end;

procedure TfManager.LvDataSelectItem(Sender: TObject; Item: TListItem;
   Selected: Boolean);
begin
   SelectType := 'Item';
end;

procedure TfManager.sbtnAppendClick(Sender: TObject);
var sSlot :string;
begin
   if edtMSL.Text='' then
     begin
       MessageDlg('Msl NO. is Null !!', mtCustom, [mbOK], 0);
       exit;
     end;

   with qrytemp do
      begin
        close;
        CommandText:='select * from smt.G_SMT_STATUS where msl_no='''+edtMSL.Text+''' ';    //modify by ice 080911
        open;
        if recordcount>0 then
        begin
          MessageDlg('MSL is running now!', mtError, [mbOK], 0);
          Exit;
        end;
      end;

   if  TreeBom.Selected=nil then
     begin
       sSLot:=InputBox('Please Input','MSL NO:'+edtMSL.Text,'');
       if sSlot='' then
         exit;
       With QryTemp do
         begin
           close;
           CommandText:='select msl_no from smt.g_msl '+
                        ' where msl_no='''+trim(edtMSL.Text)+''''+
                        '   and slot_no='''+sSLot+'''';
           open;
           if recordcount>0 then
             begin
               close;
               MessageDlg('Slot NO. Duplicate !!', mtCustom, [mbOK], 0);
               exit;
             end
           else begin
                  {Close;
                  Params.Clear;
                  //Params.CreateParam(ftString, 'ITEM_PART_ID', ptInput);
                  //Params.CreateParam(ftString, 'EMP_ID', ptInput);
                  //Params.CreateParam(ftString, 'Msl_No', ptInput);
                  //Params.CreateParam(ftString, 'Slot_No', ptInput);
                  Params.CreateParam(ftString, 'SLOT_NO', ptInput);
                  //Params.CreateParam(ftString, 'SIDE', ptInput);
                  //Params.CreateParam(ftString, 'LOCATION', ptInput);
                  CommandText := 'Insert Into SMT.g_msl ' +
                     ' select MSL_NO,PDLINE_ID,PART_ID,MACHINE_ID,:SLOT_NO,' +
                     'FEEDER_TYPE,SIDE,''0'',ITEM_COUNT,VERSION,EMP_ID,sysdate,''M'',0 ' +
                     'from smt.g_msl where msl_no = :msl_no and rownum = 1 ';
                  //Params.ParamByName('ITEM_PART_ID').AsString := PartId;
                  //Params.ParamByName('EMP_ID').AsString := fManager.UpdateUserID;
                  Params.ParamByName('Msl_No').AsString := trim(edtMSL.Text);
                  Params.ParamByName('Slot_No').AsString := sSlot;
                  //Params.ParamByName('ITEM_COUNT').AsString := EditItemCount.Text;
                  //Params.ParamByName('SIDE').AsString := CombSide.Text;
                  //Params.ParamByName('LOCATION').AsString := EditLocation.Text;
                  Execute;
                  close;}
                  TreeBOM.Items.AddChild(nil, sSLot);
                  //ShowData;
                  //ShowPartData(TreeBOM.Selected.Text);
                end;
         end;
   //else
     with TfData.Create(Self) do
       begin
          MaintainType := 'Append';
          LabType1.Caption := LabType1.Caption + ' Append';
          LabType2.Caption := LabType2.Caption + ' Append';
          labMSL.Caption := edtMSL.Text;
          labSlot.Caption := sSLot;
            with qrytemp do
            begin
              close;
              CommandText:='select A.*,B.LOCATION from smt.g_msl A,SMT.G_MSL_LOCATION B '+
                        ' where A.msl_no='''+trim(edtMSL.Text)+''''+
                        ' AND A.msl_no=B.msl_no '+
                        ' AND A.slot_no=B.slot_no '+
                        '   and A.slot_no='''+labSlot.Caption+'''';
              open;
              if recordcount>0 then
              begin
                EditItemCount.Text:= Fieldbyname('ITEM_COUNT').AsString;
                EditFeeder.Text:= Fieldbyname('FEEDER_TYPE').AsString;
                CombSide.ItemIndex:= Fieldbyname('SIDE').AsInteger;
                EditLocation.Text:= Fieldbyname('LOCATION').AsString;
                EditItemCount.Enabled:=FALSE;
                EditFeeder.Enabled:=FALSE;
                CombSide.Enabled:=FALSE;
                EditLocation.Enabled:=FALSE;
              end;
            end;
          Showmodal;
          ShowData;
          {if TreeBom.Selected=nil then
            ShowPartData(sSLot)
          else
            ShowPartData(TreeBOM.Selected.Text); }

          Free;
       end;
     end
     else
     with TfData.Create(Self) do
       begin
          MaintainType := 'Append';
          LabType1.Caption := LabType1.Caption + ' Append';
          LabType2.Caption := LabType2.Caption + ' Append';
          labMSL.Caption := edtMSL.Text;
          labSlot.Caption := TreeBom.Selected.Text;
            with qrytemp do
            begin
              close;
              CommandText:='select A.*,B.LOCATION from smt.g_msl A,SMT.G_MSL_LOCATION B '+
                        ' where A.msl_no='''+trim(edtMSL.Text)+''''+
                        ' AND A.msl_no=B.msl_no '+
                        ' AND A.slot_no=B.slot_no '+
                        '   and A.slot_no='''+labSlot.Caption+'''';
              open;
              if recordcount>0 then
              begin
                EditItemCount.Text:= Fieldbyname('ITEM_COUNT').AsString;
                EditFeeder.Text:= Fieldbyname('FEEDER_TYPE').AsString;
                CombSide.ItemIndex:= Fieldbyname('SIDE').AsInteger;
                EditLocation.Text:= Fieldbyname('LOCATION').AsString;
                EditItemCount.Enabled:=FALSE;
                EditFeeder.Enabled:=FALSE;
                CombSide.Enabled:=FALSE;
                EditLocation.Enabled:=FALSE;
              end;
            end;
          Showmodal;
          ShowData;
          {if TreeBom.Selected=nil then
            ShowPartData(sSLot)
          else
            ShowPartData(TreeBOM.Selected.Text); }

          Free;
       end;
end;

procedure TfManager.SpeedButton1Click(Sender: TObject);
var i:string;
begin
 if edit1.Text='' then
  begin
   showmessage('Plseae input no!');
   exit;
  end;
 i:=trim(edit1.Text);

 with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL', ptInput);
      CommandText := 'update smt.g_msl a set  a.slot_no=to_char(to_number(a.slot_no)+  '
                   +i+')'+' where msl_no=:MSL ';

      Params.ParamByName('MSL').AsString := Trim(edtMSL.Text);
      execute;
      Close;
   end;
   showmessage('UPDATE OK');
   if edtMSL.Text <> '' then
         ShowData;

end;

procedure TfManager.SpeedButton2Click(Sender: TObject);
 Var i:string;
begin
 if edit1.Text='' then
  begin
   showmessage('Plseae input no!');
   exit;
  end;
 i:=trim(edit1.Text);

 with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'MSL', ptInput);
      CommandText := 'update smt.g_msl a set  a.slot_no=to_char(to_number(a.slot_no)- '
                   +i+')'+' where msl_no=:MSL ';

      Params.ParamByName('MSL').AsString := Trim(edtMSL.Text);
      execute;
   end;
   showmessage('UPDATE OK');
   if edtMSL.Text <> '' then
         ShowData;
end;

procedure TfManager.sbtnExportClick(Sender: TObject);
var MsExcel, MsExcelworkBook: Variant;
    MslNo:string;
    sExcelFile,sFileName,My_FileName: String;
    i:integer;
begin
MslNo:=trim(edtMSL.Text);
i:=2;
if MslNo='' then
  begin
    Showmessage('Msl Not Exits!');
    Exit;
  end;
 with Qrytemp1 do
    begin
      close;
      params.Clear;
      params.CreateParam(ftstring,'MSLNO',ptinput);
      CommandText:='select b.Part_no Model_Name,a.Version,d.part_no Part_No,a.Slot_no,c.Pdline_name,decode(a.Side,''0'',''TOP'',''BOT'') Side '+
                   ' from SMT.g_MSL a,sajet.sys_part b,sajet.sys_part d,sajet.sys_pdline c '+
                   ' where MSL_NO=:MslNo '+
                   ' and a.part_id=b.part_id '+
                   ' and a.item_part_id=d.part_id '+
                   ' and a.Pdline_id=c.Pdline_id ';
      params.ParamByName('MslNo').AsString:=MslNo;  
      open;
    end;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xlt)|*.xlt|All Files(*.xls)|*.xls';
 if  not  FileExists(ExtractFilePath(Application.EXEName)+'MSLSampleFile.xls') then
  begin
    MessageDlg('MSLSampleFile.xls Not Exist!',mtWarning,[mbOK],0);
    exit;
  end;
 sFileName := ExtractFilePath(Application.EXEName)+'MSLSampleFile.xls';
 try
   try
     MsExcel := CreateOleObject('Excel.Application');
     MsExcelWorkBook := MsExcel.WorkBooks.Open(sFileName);
      If SaveDialog1.Execute Then
      begin
         sFileName := ExtractFilePath(Application.EXEName)+'MSLSampleFile.xls';
         MsExcel := CreateOleObject('Excel.Application');
         MsExcelWorkBook := MsExcel.WorkBooks.Open(sFileName);
         MsExcel.Worksheets['Sheet1'].select;
         QryTemp1.First ;
         MsExcel.WorkSheets[1].Range[Chr(65) + IntToStr(1)].Value:='Model Name' ;
         MsExcel.WorkSheets[1].Range[Chr(66) + IntToStr(1)].Value:='Version' ;
         MsExcel.WorkSheets[1].Range[Chr(67) + IntToStr(1)].Value:='Part No' ;
         MsExcel.WorkSheets[1].Range[Chr(68) + IntToStr(1)].Value:='SlotNo' ;
         MsExcel.WorkSheets[1].Range[Chr(69) + IntToStr(1)].Value:='SMT Line' ;
         MsExcel.WorkSheets[1].Range[Chr(70) + IntToStr(1)].Value:='SIDE' ;
         QryTemp1.next;
         While not QryTemp1.Eof do
         begin
           MsExcel.WorkSheets[1].Range[Chr(65) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('Model_Name').AsString;
           MsExcel.WorkSheets[1].Range[Chr(66) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('Version').AsString;
           MsExcel.WorkSheets[1].Range[Chr(67) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('Part_No').AsString;
           MsExcel.WorkSheets[1].Range[Chr(68) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('slot_no').AsString;
           MsExcel.WorkSheets[1].Range[Chr(69) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('Pdline_Name').AsString;
           MsExcel.WorkSheets[1].Range[Chr(70) + IntToStr(i)].Value:=QryTemp1.Fieldbyname('Side').AsString ;
          {  S := QryTemp1.Fieldbyname('Model_Name').AsString + ',' +
             //    QryTemp.Fieldbyname('part_no').AsString + ',' +
                 QryTemp1.Fieldbyname('Version').AsString + ',' +
                 QryTemp1.Fieldbyname('Part_No').AsString + ',' +
                 QryTemp1.Fieldbyname('slot_no').AsString + ',' +
            //     QryTemp.Fieldbyname('Feeder_no').AsString + ',' +

                 QryTemp1.Fieldbyname('Pdline_Name').AsString + ',' +
              //   QryTemp.Fieldbyname('out_time').AsString + ',' +
                 QryTemp1.Fieldbyname('Side').AsString;
            Writeln(F,S); }
            inc(i);
            QryTemp1.Next;
         end;
         sFileName := SaveDialog1.FileName;
         MsExcelWorkBook.SaveAs(sFileName);
      //   SaveExcel(MsExcel,MsExcelWorkBook);
         MessageDlg('Export OK !!',mtCustom, [mbOK],0);
        end;
      
     Except
      ShowMessage('Could not start Microsoft Excel.');
    end;

 finally
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel:=Null;
 end;
end;

procedure TfManager.GetLine;
begin
  cmbLine.Items.Clear;
  with qrytemp do
  begin
    close;
    CommandText:='select distinct(b.pdline_name) from smt.G_SMT_STATUS a,sajet.sys_pdline b' +
                ' where a.msl_no='''+edtMSL.Text+''' and a.pdline_id=b.pdline_id order by b.pdline_name ';
    open;
    while not eof do
    begin
      cmbLine.Items.Add(Fieldbyname('pdline_name').AsString);
      next;
    end;
  end;
  sbtnCheck.Enabled:=false;
end;

procedure TfManager.cmbLineChange(Sender: TObject);     //modify by ice 080918
begin
  cmbMSL.Items.Clear;
  with qrytemp do
  begin
    close;
    CommandText:='select distinct(a.msl_no) from smt.G_SMT_STATUS a,sajet.sys_pdline b' +
                ' where a.pdline_id=b.pdline_id and b.pdline_name='''+cmbLine.Text+''' order by a.msl_no ';
    open;
    while not eof do
    begin
      cmbMSL.Items.Add(Fieldbyname('msl_no').AsString);
      next;
    end;
  end;
  if cmbMSL.Items.Count=1 then
  begin
    cmbMSL.ItemIndex:=0;
    sbtnCheckClick(self);
  end;
end;

procedure TfManager.sbtnCheckClick(Sender: TObject);        //add by ice 080917
var i : integer;
begin
  fCheck.WindowState:=wsMaximized;

  fCheck.cmbLine.Items.Clear;
  for i:=0 to cmbline.Items.Count-1 do
  begin
    fCheck.cmbLine.Items.Add(cmbline.Items[i]);
  end;
  fCheck.cmbLine.ItemIndex:=cmbline.ItemIndex;

  fCheck.cmbMSL.Items.Clear;
  for i:=0 to cmbMSL.Items.Count-1 do
  begin
    fCheck.cmbMSL.Items.Add(cmbMSL.Items[i]);
  end;
  fCheck.cmbMSL.ItemIndex:=cmbMSL.ItemIndex;
  
  fCheck.sbtnStartClick(self);

  fCheck.Show;

  //fcheck.Timer1Timer(SELF);
  {with  fFilter.QryData do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString	,'MSL_NO', ptInput);
    commandtext:=' SELECT A.MSL_NO,C.PART_NO FROM SMT.G_MSL A,'+
                 ' SAJET.SYS_PART C WHERE MSL_NO=:MSL_NO '+
                 ' AND A.PART_ID =C.PART_ID AND ROWNUM=1 ';
    Params.ParamByName('MSL_NO').AsString :=trim(edtMSL.Text);
    OPEN;
    fCheck.MSLNO.Caption:=FieldByName('MSL_NO').AsString;
    fCheck.PDLINE.Caption:=trim(cmbLine.Text);
    fCheck.PARTNO.Caption:=FieldByName('PART_NO').AsString;
  end; }

end;

procedure TfManager.edtMSLChange(Sender: TObject);   //add by ice 080917
begin
  sbtnCheck.Enabled:=false;
  cmbLine.Items.Clear;
end;

procedure TfManager.FormShow(Sender: TObject);       //add by ice 080918
begin
  cmbLine.Items.Clear;
  with qrytemp do
  begin
    close;
    CommandText:='select distinct(b.pdline_name) from smt.G_SMT_STATUS a,sajet.sys_pdline b' +
                ' where a.pdline_id=b.pdline_id order by b.pdline_name ';
    open;
    while not eof do
    begin
      cmbLine.Items.Add(Fieldbyname('pdline_name').AsString);
      next;
    end;
  end;
  sbtnCheckClick(self);
end;

end.

