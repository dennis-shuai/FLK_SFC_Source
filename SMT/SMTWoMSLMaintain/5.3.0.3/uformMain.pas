unit uformMain;

interface

uses
   Windows, Messages, SysUtils, Classes,  Controls, Forms, Dialogs,
   Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, Db, DBClient,
   ComCtrls, ObjBrkr,  Clrgrid, Menus, OleCtnrs, ComOBJ, Variants,
   Excel97, Graphics, DBTables;

type
   TformMain = class(TForm)
      Panel1: TPanel;
      labTitleB: TLabel;
      labTitle: TLabel;
      imageAll: TImage;
      Image1: TImage;
      sbtnAppend: TSpeedButton;
      Image3: TImage;
      Image7: TImage;
      ImgDelete: TImage;
      sbtnDelete: TSpeedButton;
      Label1: TLabel;
    sbtnExport: TSpeedButton;
    Label5: TLabel;
    editWo: TEdit;
    dsrcData: TDataSource;
    PopupMenu1: TPopupMenu;
    Append1: TMenuItem;
    Modify1: TMenuItem;
    Delete1: TMenuItem;
    Image4: TImage;
    Image2: TImage;
    sbtnPrint: TSpeedButton;
    sbtnPreview: TSpeedButton;
    Label7: TLabel;
    lablTarget: TLabel;
    Label3: TLabel;
    lablCust: TLabel;
    SaveDialog1: TSaveDialog;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    QryData1: TClientDataSet;
    Label4: TLabel;
    lablDetail: TLabel;
    cstrGridWo1: TColorStringGrid;
    DBGrid1: TDBGrid;
    sbtnModify: TSpeedButton;
    sbtnFailSN: TSpeedButton;
    lablPartNo: TEdit;
    chkAll: TCheckBox;
    Label2: TLabel;
    N1: TMenuItem;
    Sproc: TClientDataSet;
      procedure sbtnDeleteClick(Sender: TObject);
      procedure LvDataSelectItem(Sender: TObject; Item: TListItem;
         Selected: Boolean);
      procedure sbtnAppendClick(Sender: TObject);
    procedure TreeBOMClick(Sender: TObject);
    procedure sbtnModifyClick(Sender: TObject);
    procedure editWoKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure qryDataAfterClose(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure cstrGridWo1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sbtnPreviewClick(Sender: TObject);
    procedure cstrGridWo1DblClick(Sender: TObject);
    procedure editWoChange(Sender: TObject);
    procedure dsrcDataDataChange(Sender: TObject; Field: TField);
    procedure sbtnFailSNClick(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
      sPath, SelectType, UpdateUserID, gsSpec: string;
      G_iRow:Integer;
      gbControl: Boolean;
      procedure ShowWoMSLData;
      procedure SetStatusbyAuthority;
      procedure PrintExcel(Sender: TObject);
      procedure Release_Excel;
      function checkDataCanModify(sWoSequence,sPDLine,sMachine,sSide:String):Boolean;
      function init_Excel:Boolean;
      function GetPartNoID(PartNo: string; var PartId: string): Boolean;
   end;

var
   formMain: TformMain;
   MsExcel, MsExcelWorkBook: Variant;
   G_sWoSeq: String;


implementation

uses  uSubPart,uData, uFilter, uformMoData, uformPosition, uCommData;

{$R *.DFM}
procedure TformMain.SetStatusbyAuthority;
var iPrivilege:integer;
begin
  iPrivilege:=0;
  with sproc do
  begin
    try
      Close;
      DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
      FetchParams;
      Params.ParamByName('EMPID').AsString := UpdateUserID;
      Params.ParamByName('PRG').AsString := 'SMT';
      Params.ParamByName('FUN').AsString := 'MSL Maintain';
      Execute;
      IF Params.ParamByName('TRES').AsString ='OK' Then
      begin
       iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
      end;
    finally
      close;
    end;
  end;
  sbtnAppend.Enabled := (iPrivilege >=1);
  Append1.Enabled := sbtnAppend.Enabled;

  sbtnModify.Enabled := (iPrivilege >=1);
  Modify1.Enabled := sbtnModify.Enabled;

  sbtnDelete.Enabled := (iPrivilege >=1);
  Delete1.Enabled := sbtnDelete.Enabled;

  gbControl := (iPrivilege >=2);
end;

procedure TformMain.sbtnDeleteClick(Sender: TObject);
var sTemp,sSubPart,sPart,sSLot, sMsg: string;
    iRow : Integer;
begin
   IF (not qryData.Active) or (qrydata.eof) then exit;
   if not checkDataCanModify(qryData.FieldByName('WO_SEQUENCE').AsString,qryData.FieldByName('PDLINE_NAME').AsString,qryData.FieldByName('MACHINE_CODE').AsString,qryData.FieldByName('Side').AsString) then
     exit;
   if G_iRow < 1 then exit;
   IF cstrGridWo1.RowCount = 2 then
   begin
     MessageDlg('Cann''t delete this record!',mtWarning,[mbOK],0);
     exit;
   end;
   sSLot := cstrGridWo1.Cells[0,G_iRow];
   (* judge whether it is sub or main part *)
   IF cstrGridWo1.Cells[2,G_iRow] = '' Then
    sMsg := 'Do you want to delete this data ?' + #13#10
                +'Machine: '+qryData.FieldByName('MACHINE_CODE').AsString + #13#10
                +'Side: '+ qryData.FieldByName('Side').AsString + #13#10
                +'Station No: ' + sSLot + #13#10
                +'Sub Part: ' + cstrGridWo1.Cells[1,G_iRow]
   else
     sMsg := 'Do you want to delete this data ?' + #13#10
            +'Machine: '+qryData.FieldByName('MACHINE_CODE').AsString + #13#10
            +'Side: '+ qryData.FieldByName('Side').AsString + #13#10
            +'Station No: ' + sSLot + #13#10
            +'Part: ' +  cstrGridWo1.Cells[1,G_iRow];

   if MessageDlg(sMsg, mtWarning, mbOKCancel, 0) = mrOK then
   begin
      IF cstrGridWo1.Cells[2,G_iRow] = '' Then
      begin
         (* find main part*)
         sTemp := cstrGridWo1.Cells[2,G_iRow];
         sSubPart := cstrGridWo1.Cells[1,G_iRow];
         iRow := G_iRow;
         While sTemp = '' Do
         begin
           Dec(iRow);
           sTemp := cstrGridWo1.Cells[2,iRow];
           sPart := cstrGridWo1.Cells[1,iRow];
         end;
         With QryTemp do
         begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
             Params.CreateParam(ftString	,'PART', ptInput);
             Params.CreateParam(ftString	,'SUB_PART', ptInput);
             CommandText := ' Delete SMT.G_WO_MSL_SUB '
                          + ' Where WO_SEQUENCE =:WO_SEQUENCE '
                          + '   AND ITEM_PART_ID = (SELECT PART_ID FROM SAJET.SYS_PART '
                          + '                       WHERE PART_NO = :PART '
                          + '                       AND ROWNUM = 1 ) '
                          + '   AND SUB_PART_ID = ( SELECT PART_ID FROM SAJET.SYS_PART '
                          + '                       WHERE PART_NO = :SUB_PART '
                          + '                       AND ROWNUM = 1 ) ';
             Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
             Params.ParamByName('PART').AsString := sPart;
             Params.ParamByName('SUB_PART').AsString := sSubPart;
             Execute;
             Close;
         end;

      end
      else
      begin
          sPart :=  cstrGridWo1.Cells[1,G_iRow];
          with QryTemp do
          begin
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
             Params.CreateParam(ftString	,'STATION_NO', ptInput);
             CommandText := ' Delete SMT.G_WO_MSL_DETAIL '
                          + ' Where WO_SEQUENCE =:WO_SEQUENCE '
                          + '   AND STATION_NO = :STATION_NO ';
             Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
             Params.ParamByName('STATION_NO').AsString := sSLot;
             Execute;
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
             Params.CreateParam(ftString	,'PART', ptInput);
             CommandText := ' Delete SMT.G_WO_MSL_SUB '
                          + ' Where WO_SEQUENCE =:WO_SEQUENCE '
                          + '   AND ITEM_PART_ID = (SELECT PART_ID FROM SAJET.SYS_PART '
                          + '                       WHERE PART_NO = :PART '
                          + '                       AND ROWNUM = 1 ) ';
             Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
             Params.ParamByName('PART').AsString := sPart;
             Execute;
             Close;
          end;
      End;
      G_sWoSeq := qryData.FieldByname('Wo_SEQUENCE').AsString;
      ShowWoMSLData;
   end;
end;

procedure TformMain.LvDataSelectItem(Sender: TObject; Item: TListItem;
   Selected: Boolean);
begin
   SelectType := 'Item';
end;

procedure TformMain.sbtnAppendClick(Sender: TObject);
var sPDLine,sMachine, sSide:String;
begin
  IF (not qryData.Active) or (qrydata.eof) then exit;
  sPDLine := qryData.FieldByName('PDLINE_NAME').AsString;
  sMachine := qryData.FieldByName('MACHINE_CODE').AsString;
  sSide := qryData.FieldByName('Side').AsString;
  if not checkDataCanModify(qryData.FieldByName('WO_SEQUENCE').AsString,sPDLine,sMachine,sSide) then exit;
  with TfData.Create(Self) do
  begin
      MaintainType := 'Append';
      LabType1.Caption := LabType1.Caption + ' Append';
      LabType2.Caption := LabType2.Caption + ' Append';
      editStationNo.Enabled := true;
      labLine.Caption := sPDLine;
      labMachine.Caption := sMachine;
      labSide.Caption := sSide;
      labMsl.Caption := qryData.FieldByName('WO_SEQUENCE').AsString;
      QryData.RemoteServer := qryData.RemoteServer;
      Showmodal;
      Free;
  end;
  G_sWoSeq := qryData.FieldByname('Wo_SEQUENCE').AsString;
  ShowWoMSLData;
end;

function TformMain.checkDataCanModify(sWoSequence,sPDLine,sMachine,sSide:String):Boolean;
var sMessage:String;
begin
  result := true;
  try
    with qryTemp do
    begin
      close;
      Params.Clear;
      Params.CreateParam(ftString	,'wo_sequence', ptInput);
      CommandText := ' select STATUS '
                   + ' from smt.g_wo_msl '
                   + '  where wo_sequence =:wo_sequence ';
      Params.ParamByName('wo_sequence').AsString := sWoSequence;
      open;
      if eof then
      begin
        result := false;
        sMessage:='Work Order: '+editWo.Text+#10#13
                 +'Line: '+sPDLine+#10#13
                 +'Machine: '+sMachine+#10#13
                 +'Side: '+sSide+#10#13
                 +'MLS not Found.';
        MessageDlg(sMessage,mtWarning,[mbOK],0);
        exit;
      end;
    end;
  finally
    qryTemp.Close;
  end;
end;

procedure TformMain.TreeBOMClick(Sender: TObject);
begin
  SelectType := 'Slot';
end;

procedure TformMain.sbtnModifyClick(Sender: TObject);
begin
   IF (not qryData.Active) or (qrydata.eof) then exit;
   if not checkDataCanModify(qryData.FieldByName('WO_SEQUENCE').AsString,qryData.FieldByName('PDLINE_NAME').AsString,qryData.FieldByName('MACHINE_CODE').AsString,qryData.FieldByName('Side').AsString) then exit;
   if cstrGridWo1.Cells[1,G_iRow] = '' then exit;
   if cstrGridWo1.Cells[2,G_iRow] = '' Then Exit;  (* bcz is sub part *)
   with TfData.Create(Self) do
   begin
     MaintainType := 'Modify';
     editStationNo.Enabled := False;
     LabType1.Caption := LabType1.Caption + ' Modify';
     LabType2.Caption := LabType2.Caption + ' Modify';
     labLine.Caption := qryData.FieldByName('PDLINE_NAME').AsString;
     editQty.Text := cstrGridWo1.Cells[2,G_iRow];
     editStationNo.Text := cstrGridWo1.Cells[0,G_iRow];
     G_sStationNo:= editStationNo.Text ;
     editLocation.Text := cstrGridWo1.Cells[3,G_iRow];
     gsLocation := editLocation.Text;
     labSide.Caption := qryData.FieldByName('Side').AsString;
     labMsl.Caption := qryData.FieldByName('WO_SEQUENCE').AsString;
//     editSEQ.Text := cstrGridWo1.Cells[7,G_iRow];
//     editNozzle.Text :=cstrGridWo1.Cells[5,G_iRow];
     editFedder.Text := cstrGridWo1.Cells[4,G_iRow];
//     editStationNo.Enabled := False;
     labMachine.Caption := qryData.FieldByName('MACHINE_CODE').AsString;
     edtPart.Text := cstrGridWo1.Cells[1,G_iRow];
     QryData.RemoteServer := qryData.RemoteServer;
     Showmodal;
     editStationNo.Enabled := True;
     Free;
   end;
   G_sWoSeq := qryData.FieldByname('Wo_SEQUENCE').AsString;
   ShowWoMSLData;
end;


procedure TformMain.editWoKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
  begin
    if editWo.Text <> '' then
       ShowWoMSLData;
  end;
end;

procedure TformMain.ShowWoMSLData;
begin
  lablPartNo.Text := 'N/A';
  lablTarget.Caption := 'N/A';
  lablCust.Caption := 'N/A';
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'work_order', ptInput);
    CommandText := 'Select Part_Id, PART_NO ,A.TARGET_QTY, Customer_Code, spec1 '
                 + '  FROM sajet.g_wo_base A, sajet.sys_part B, sajet.sys_customer c '
                 + 'WHERE A.work_order = :WORK_ORDER '
                 + '  AND A.model_id = B.part_id(+) '
                 + '  and a.customer_id = c.customer_id(+) '
                 + '  AND ROWNUM = 1 ';
    Params.ParamByName('WORK_ORDER').AsString := editWo.Text;
    Open;
    if eof then
    begin
       Close;
       MessageDlg('Work Order Not Found.', mtError, [mbOK], 0);
       editWo.SetFocus;
       editWo.SelectAll;
       Exit;
    end;
    lablPartNo.Text := FieldByName('PART_NO').AsString;
    gsSpec := FieldByName('Spec1').AsString;
    lablTarget.Caption := FieldByName('TARGET_QTY').AsString;
    lablCust.Caption := FieldByName('Customer_Code').AsString;
  end;

   with qryData do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'work_order', ptInput);
      CommandText := 'select A.WORK_ORDER, b.PDLINE_NAME, c.MACHINE_CODE, A.WO_SEQUENCE, A.STATUS "Status", decode(a.Side,0,''Top'',''Bottom'') "Side" '
                   + ' FROM SMT.G_WO_MSL A, sajet.sys_pdline b, sajet.sys_machine c '
                   + 'Where A.WORK_ORDER = :WORK_ORDER  '
                   + ' and a.pdline_id = b.pdline_id '
                   + ' and a.machine_id = c.machine_id '
                   + 'ORDER BY b.PDLINE_NAME, c.MACHINE_CODE ';
      Params.ParamByName('WORK_ORDER').AsString := editWo.Text;
      Open;
      if IsEmpty then
      begin
         Close;
         MessageDlg('MSL no Define!', mtError, [mbOK], 0);
         editWo.SetFocus;
         editWo.SelectAll;
         Exit;
      end else
         Locate('wo_sequence',G_sWoSeq,[]);
   end;
end;


procedure TformMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action :=caFree;
end;

procedure TformMain.qryDataAfterClose(DataSet: TDataSet);
var i:integer;
begin
  lablDetail.Caption :='Material List Detail : 0 ';
  for i:=1 to cstrGridWo1.RowCount-1 do
    cstrGridWo1.Rows[i].Clear;
  cstrGridWo1.RowCount := 2;
  G_sWoSeq :='N/A';
end;

procedure TformMain.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80,100);
    800: self.ScaleBy(100,100);
    1024: self.ScaleBy(125,100);
  else
    self.ScaleBy(100,100);
  end;

  if UpdateUserID <> '0' then
    SetStatusbyAuthority;

  with cstrGridWo1 do
  begin
//    Cells[0,0]:='Machine';
    Cells[0,0]:='Station';
    Cells[1,0]:='Part';
//    Cells[2,0]:='Spec';
//    Cells[5,0]:='Nozzle';
    Cells[4,0]:='Feeder';
    Cells[2,0]:='Qty';
    Cells[3,0]:='Location';
  end;
  editWo.SetFocus;
end;

procedure TformMain.cstrGridWo1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  G_iRow:=ARow;
end;

procedure TformMain.sbtnPreviewClick(Sender: TObject);
begin
  if (not qrydata.Active) or (qrydata.eof) then exit;
  if qrydata.FieldByName('Status').AsString ='N/A' then
  begin
    MessageDlg('Please Save MSL!',mtWarning,[mbOK],0);
    exit;
  end;
  if not init_Excel then exit;
  PrintExcel(Sender);
  Release_Excel;
end;

procedure TformMain.sbtnPrintClick(Sender: TObject);
begin
  if (not qrydata.Active) or (qrydata.eof) then exit;
  if chkAll.Checked then
  begin
    if not init_Excel then exit;
    QryData.First;
    while not QryData.Eof do
    begin
      if qrydata.FieldByName('Status').AsString <> 'N/A' then
         PrintExcel(Sender);
      QryData.Next;
    end;
    QryData.First;
    Release_Excel;
  end else
  begin
    if qrydata.FieldByName('Status').AsString = 'N/A' then
    begin
      MessageDlg('Please Save MSL!',mtWarning,[mbOK],0);
      exit;
    end;
    if not init_Excel then exit;
    PrintExcel(Sender);
    Release_Excel;
  end;
end;

procedure TformMain.PrintExcel(Sender: TObject);
var sStationNo,sLocation,sSEQ,sNozzle,sFedder,sMachineCode,sLineName,sWoSequence:String;
    iStartRow,iPartRow:Integer;
    tsLocation,tsSEQ:TStringList;
    b:Boolean;
    iLocationRow,iTemp,i, iLocationMod:integer;
    vRange1:vARIANT;
    sProgram,sProgramVer,sPCBBoard,sSide:String;
    iItemCount:integer;
begin
//  IF (not qryData.Active) or (qrydata.eof) then exit;
//  if not init_Excel then exit;

  // Location顯示個數
  iLocationMod := 10;
  tsLocation :=TStringList.Create;
  try
    with QryTemp do begin
     { close;
      Params.Clear;
      Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
      CommandText := ' select * from SMT.G_WO_MSL_PROGRAM '
                   + ' where WO_SEQUENCE =:WO_SEQUENCE ';
      Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
      open;
      if not eof then
      begin
        sProgram := FieldByName('Program_Name').AsString;
        sProgramVer := FieldByName('Program_Ver').AsString;
        sPCBBoard := FieldByName('PCB_BOARD').AsString;
      end;  }
      close;
      Params.Clear;
      Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
      CommandText := 'Select B.WO_SEQUENCE, d.PDLINE_NAME, e.MACHINE_CODE, decode(b.Side,0,''Top'',''Bottom'') "Side", '
                   + 'a.station_no, c.part_no, c.spec1, a.location, LPAD(A.STATION_NO,5,''0'') idx,A.ITEM_COUNT  '
                   + 'From SMT.G_WO_MSL B, SMT.G_WO_MSL_DETAIL A, SAJET.SYS_PART c, sajet.sys_pdline d, sajet.sys_machine e '
                   + 'Where B.WO_SEQUENCE = :WO_SEQUENCE '
                   + ' AND A.WO_SEQUENCE = B.WO_SEQUENCE '
                   + ' AND A.ITEM_PART_Id = c.PART_Id(+) '
                   + ' and b.pdline_id = d.pdline_id '
                   + ' and b.machine_id = e.machine_id '
                   + 'order By d.PDLINE_NAME, e.MACHINE_CODE, idx, location ';
      Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('Wo_SEQUENCE').AsString;
      open;
      iStartRow := 6;
      iPartRow := 0;
      sStationNo := '';
      MsExcel.Worksheets['sheet2'].Select;
      MsExcel.Cells.Select;
      MsExcel.Selection.Copy;
      MsExcel.Worksheets['sheet1'].Select;
      MsExcel.Cells.Select;
      MsExcel.ActiveSheet.Paste;
      while not eof do
      begin
        tsLocation.Clear;
        iItemCount:=0;
        //寫料號
        inc(iPartRow);
        MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow)].Value:=FieldByName('STATION_NO').AsString;
        MsExcel.WorkSheets['sheet1'].Range['B'+IntToStr(iStartRow+iPartRow)].Value:=FieldByName('PART_NO').AsString;
        MsExcel.WorkSheets['sheet1'].Range['C'+IntToStr(iStartRow+iPartRow)].Font.Size:=8;
        MsExcel.WorkSheets['sheet1'].Range['C'+IntToStr(iStartRow+iPartRow)].Value:=FieldByName('SPEC1').AsString;
        sStationNo := FieldByName('STATION_NO').AsString;
        sWoSequence := FieldByName('WO_SEQUENCE').AsString;
        //=======================================================================================================
        //取得料號的所有位置和點數
        b:= true;
        while (b) do
        begin
          tsLocation.Add(FieldByName('LOCATION').AsString);
          sStationNo := FieldByName('STATION_NO').AsString;
          sMachineCode := FieldByName('MACHINE_CODE').AsString;
          sSide := FieldByName('SIDE').AsString;
          sLineName := FieldByName('PDLINE_NAME').AsString;
          iItemCount := iItemCount+FieldByName('ITEM_COUNT').AsInteger;
          next;
          B := FALSE;
          IF (NOT EOF) AND (sStationNo = FieldByName('STATION_NO').AsString)
                       AND (sMachineCode =FieldByName('MACHINE_CODE').AsString)
                       AND (sLineName =FieldByName('PDLINE_NAME').AsString) THEN
            B := TRUE;
        end;
        //========================================================================================================
        //計算LOCATION實際的行數
        iLocationRow := tsLocation.count div iLocationMod;
        if tsLocation.Count mod iLocationMod <> 0 then
          inc(iLocationRow);
        //========================================================================================================
        //寫用量值
        MsExcel.Worksheets['sheet1'].Range['G'+IntToStr(iStartRow+iPartRow)].Value:=IntToStr(iItemCount);//IntToStr(tsLocation.Count);
        //寫用料合計
        MsExcel.Worksheets['sheet1'].Range['H'+IntToStr(iStartRow+iPartRow)].Value:=IntToStr(iItemCount*StrToInt(lablTarget.Caption));//IntToStr(tsLocation.Count*StrToInt(lablTarget.Caption));
        //寫位罝.點數title
        inc(iPartRow);
        MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow)].Value:='Location:';
        //========================================================================================================
        //寫入值
        sLocation :='';
        sSEQ :='';
        inc(iPartRow);
        iTemp := 0;
        for i:= 0 to tsLocation.Count-1 do
        begin
          sLocation := sLocation + tsLocation.Strings[i]+'     ';
          if ((i+1) mod iLocationMod) = 0 then
          begin
            inc(iTemp);
            MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow+iTemp-1)].Font.Size:=8;
            MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow+iTemp-1)].Value:=sLocation;
            sLocation :='';
          end;
        end;
        if iTemp < iLocationRow then
        begin
           MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow+iLocationRow-1)].Font.Size:=8;
           MsExcel.Worksheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow+iLocationRow-1)].Value:=sLocation;
        end;
        iPartRow := iPartRow + iLocationRow - 1;
        //畫底線
        vRange1 :=MsExcel.WorkSheets['sheet1'].Range['A'+IntToStr(iStartRow+iPartRow)+':'+'H'+IntToStr(iStartRow+iPartRow)];
        vRange1.Borders[xlEdgeBottom].Weight := xlThin;
      end;
      try
        MsExcel.Worksheets['sheet1'].Range['D2'].Value := lablPartNo.Text;
        MsExcel.Worksheets['sheet1'].Range['C3'].Value := gsSpec;
        MsExcel.Worksheets['sheet1'].Range['A3'].Value := '*'+sWoSequence+'*';
        MsExcel.Worksheets['sheet1'].Range['A4'].Value := sWoSequence;
        MsExcel.Worksheets['sheet1'].Range['D4'].Value := sMachineCode;
        MsExcel.Worksheets['sheet1'].Range['D5'].Value := sSide;
        MsExcel.Worksheets['sheet1'].Range['B5'].Value := editWo.Text;
        MsExcel.Worksheets['sheet1'].Range['H2'].Value := lablTarget.Caption;
        MsExcel.Worksheets['sheet1'].Range['F2'].Value := lablCust.Caption;
        //MsExcel.Worksheets['sheet1'].Range['F3'].Value := sProgram;
        //MsExcel.Worksheets['sheet1'].Range['F4'].Value := sProgramVer;
        //MsExcel.Worksheets['sheet1'].Range['F5'].Value := sPCBBoard;
        if Sender = sbtnPreview then
        begin
          MsExcel.Visible := True;
          MsExcel.Worksheets['Sheet1'].PrintPreview;
        end else
        begin
          MsExcel.Worksheets['Sheet1'].PrintOut;
        end;
      except
        MessageDlg('Preview Failure, please check Printer Setup!!',mtError,[mbOk],0);
      end;
    end;
  finally
    tsLocation.Free;
//    tsSEQ.Free;
{    MsExcelWorkBook.close(False);
    MsExcel.Application.Quit;
    MsExcel:=Null;}
  end;
end;

function TformMain.init_Excel():Boolean;
var mPath,PntName:String;
begin
  Result := True;
  mPath := GetCurrentDir+'\';
  PntName :='SMT_MSL';
  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(mPath+PntName+'.xlt');
    MsExcel.Worksheets['sheet1'].select;
  except
    MessageDlg('Could not start Microsoft Excel.',mtWarning,[mbOK],0);
    MsExcelWorkBook.close(False);
    MsExcel.Application.Quit;
    MsExcel:=Null;
    Result := False;
  end;
end;

procedure TformMain.Release_Excel;
begin
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel:=Null;
end;

function TformMain.GetPartNoID(PartNo: string; var PartId: string): Boolean;
   function GetMaxPartID: string;
   begin
      with QryTemp do
      begin
         Close;
         Params.Clear;
         CommandText := 'Select NVL(Max(PART_ID),0) + 1 PARTID '
               + 'From SAJET.SYS_PART';
         Open;
         if Fieldbyname('PARTID').AsString = '1' then
         begin
            Close;
            Params.Clear;
            CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || ''000001'' PARTID '
                +    'From SAJET.SYS_BASE '
                +    'Where PARAM_NAME = ''DBID'' ';
            Open;
         end;
         Result := Fieldbyname('PARTID').AsString;
         Close;
      end;
   end;
   function InsertPart(sItem, Spec1: string): string;
   var sPartId: string; i: Integer;
   begin
      with QryTemp do
      begin
          I := 0;
          sPartId := '';
          while True do
          begin
             try
                sPartId := GetMaxPartID;
                Break;
             except
                Inc(I); // try 10 次, 若抓不到, 則跳離開來
                if I >= 10 then
                   Break;
             end;
          end;
          if sPartId = '' then
          begin
             MessageDlg('Database Error !!' + #13#10 +
                'could not get Part Id !!', mtError, [mbCancel], 0);
             Exit;
          end;
          try
             Close;
             Params.Clear;
             Params.CreateParam(ftString	,'PART_ID', ptInput);
             Params.CreateParam(ftString	,'PART_NO', ptInput);
             Params.CreateParam(ftString	,'Spec1', ptInput);
             CommandText := 'Insert Into SAJET.SYS_PART '
                    + ' (Part_ID, PART_NO, Spec1) '
                    + ' Values  '
                    +'(:Part_ID, :PART_NO, :Spec1) ';
             Params.ParamByName('PART_ID').AsString := sPartId;
             Params.ParamByName('PART_NO').AsString := Trim(sItem);
             Params.ParamByName('Spec1').AsString := Trim(Spec1);
             Execute;
             Close;
             Result := sPartId;
          except
             MessageDlg('Database Error !!' + #13#10 +
                ' could not save to Database !!', mtError, [mbCancel], 0);
          end;
      end;
   end;
begin
   Result := False;
   with QryTemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'PARTNO', ptInput);
      CommandText := 'Select Part_ID '
                   + 'From SAJET.SYS_PART '
                   + 'Where PART_NO = :PARTNO ';
      Params.ParamByName('PARTNO').AsString := PartNo;
      Open;
      if not IsEmpty then
      begin
        PartId := Fieldbyname('PART_Id').AsString;
        Result := True;
      end
      else
      begin
        if gbControl then
        begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString	,'PARTNO', ptInput);
          CommandText := 'Select Part_ID, Spec1 '
                       + 'From SAJET.SYS_PART '
                       + 'Where PART_NO = :PARTNO ';
          Params.ParamByName('PARTNO').AsString := PartNo;
          Open;
          if not IsEmpty then
          begin
             PartId := InsertPart(PartNo, FieldByName('Spec1').AsString);
             if PartId <> '' then
               Result := True;
          end;
        end;
        if not Result then
        begin
          MessageDlg('Part No Error !!', mtError, [mbCancel], 0);
        end;
      end;
      Close;
   end;
end;

procedure TformMain.cstrGridWo1DblClick(Sender: TObject);
Var
 sType,sTemp,sPart,sSubPart :String;
 iRow : Integer;
begin
  //if G_iRow < 1 then exit;
  if cstrGridWo1.Cells[0,G_iRow] = '' then exit;
  if cstrGridWo1.Cells[2,G_iRow] <> '' then
     sType := 'Append' (*Appen a sub part to main part *)
  else
     sType := 'Modify'; (*Modify a exist sub part *)

  IF  sType = 'Modify' Then
  begin
     sTemp := cstrGridWo1.Cells[2,G_iRow];
     sSubPart := cstrGridWo1.Cells[1,G_iRow];
     iRow := G_iRow;
     While sTemp = '' Do
     begin
       Dec(iRow);
       sTemp := cstrGridWo1.Cells[2,iRow];
       sPart := cstrGridWo1.Cells[1,iRow];
     end;
  end;

  with TfSubPart.Create(Self) do
  begin
    try
      qryTemp.RemoteServer := formMain.QryData.RemoteServer;
      G_sWoSeq := formMain.qryData.FieldByName('WO_SEQUENCE').AsString;
      G_WO := formMain.editWo.Text;
      g_type := sType;
      Label1.Caption :=  g_type;
      IF  g_type = 'Modify' Then
      begin
          gsPart := sPart;
          G_SubPart := formMain.cstrGridWo1.Cells[1,G_iRow];
      end
      else
      begin
          gsPart := formMain.cstrGridWo1.Cells[1,G_iRow];
          G_SubPart := '';
      end;
      ShowModal;
    finally
      free;
    end;
    formMain.ShowWoMSLData;
  end;
end;

procedure TformMain.editWoChange(Sender: TObject);
begin
  qryData.Close;
  lablPartNo.Text := 'N/A';
  lablTarget.Caption := 'N/A';
  lablCust.Caption := 'N/A';
end;

procedure TformMain.dsrcDataDataChange(Sender: TObject; Field: TField);
var sStationNo: String; iRow, i: Integer; bReset: Boolean;
begin
  lablDetail.Caption :='Material List Detail : 0 ';
  for i:=1 to cstrGridWo1.RowCount-1 do
    cstrGridWo1.Rows[i].Clear;
  cstrGridWo1.RowCount := 2;
  with qryTemp do
  begin
    try
      Close;
      Params.Clear;
      Params.CreateParam(ftString	,'WO_SEQUENCE', ptInput);
      Params.CreateParam(ftString	,'WO_SEQUENCE1', ptInput);
      CommandText :=
                 'SELECT   a.station_no, c.part_no,a.Item_count, LOCATION, a.fedder,  LPAD (a.station_no, 5, ''0'') idx '
                +'    FROM smt.g_wo_msl_detail a, sajet.SYS_PART c '
                +'   WHERE a.wo_sequence = :WO_SEQUENCE '
                +'    AND a.item_part_id = c.part_id(+) '
                +'UNION ALL '
                +'SELECT   a.station_no, c.part_no,DECODE(a.Item_count,0,0) ,'''' LOCATION, a.fedder,  LPAD (a.station_no, 5, ''0'') idx '
                +'    FROM smt.g_wo_msl_detail a , smt.g_wo_msl_sub b,sajet.SYS_PART c '
                +'WHERE  a.WO_SEQUENCE =  :WO_SEQUENCE1 '
                +'    AND   a.WO_SEQUENCE =  b.WO_SEQUENCE '
                +'    AND   a.ITEM_PART_ID = b.ITEM_PART_ID '
                +'	AND   b.SUB_PART_ID = c.PART_ID(+) '
                +'ORDER BY idx,Item_count desc ,part_no, LOCATION ';
      Params.ParamByName('WO_SEQUENCE').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
      Params.ParamByName('WO_SEQUENCE1').AsString := qryData.FieldByName('WO_SEQUENCE').AsString;
      Open;
      sStationNo :='';
      iRow :=0;
      bReset := False;
      while not eof do
      begin
       // if  sStationNo <> FieldByName('STATION_NO').AsString then
       // begin
           inc(iRow);
//           cstrGridWo1.Cells[0,iRow] := qryData.FieldByName('MACHINE_CODE').AsString;
           cstrGridWo1.Cells[0,iRow] := FieldByName('STATION_NO').AsString;
           cstrGridWo1.Cells[1,iRow] := FieldByName('Part_No').AsString;
           cstrGridWo1.Cells[2,iRow] := FieldByName('Item_count').AsString;
           cstrGridWo1.Cells[3,iRow] := FieldByName('LOCATION').AsString;
           bReset := True;
           cstrGridWo1.Cells[4,iRow] := FieldByName('FEDDER').AsString;
//           cstrGridWo1.Cells[5,iRow] := FieldByName('NOZZLE').AsString;
       // end;
        //cstrGridWo1.Cells[2,iRow] := IntToStr(StrToIntDef(cstrGridWo1.Cells[2,iRow], 0) + 1);
        //if bReset then
        //  cstrGridWo1.Cells[3,iRow] := FieldByName('LOCATION').AsString
        //else
        //  cstrGridWo1.Cells[3,iRow] :=cstrGridWo1.Cells[3,iRow]+','+FieldByName('LOCATION').AsString;
//        cstrGridWo1.Cells[7,iRow] :=cstrGridWo1.Cells[7,iRow]+','+FieldByName('SEQ').AsString;
        bReset := False;
        sStationNo := FieldByName('STATION_NO').AsString;
        next;
      end;
      if iRow > 0 then
      begin
         cstrGridWo1.RowCount := iRow+1;
         lablDetail.Caption :='Material List Detail : '+IntToStr(iRow);
      end;
    finally
      close;
    end;
  end;
end;

procedure TformMain.sbtnFailSNClick(Sender: TObject);
begin
  with TfCommData.Create(Self) do
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      if editWo.Text <> '' then
        Params.CreateParam(ftString, 'work_order', ptInput);
      CommandText := 'select work_order "Work Order", target_qty "Target Qty", '
        + 'part_no "Part No", part_type "Part Type", spec1 "Spec1", spec2 "Spec2" '
        + 'from sajet.g_wo_base a, sajet.sys_part b '
        + 'where wo_status > 0 and wo_status < 5 ';
      if editWo.Text <> '' then
        CommandText := CommandText + 'and work_order like :work_order ';
      CommandText := CommandText + 'and a.model_id = b.part_id '
        + 'order by work_order ';
      if editWo.Text <> '' then
        Params.ParamByName('work_order').AsString := editWo.Text + '%';
      Open;
    end;
    if Showmodal = mrOK then
    begin
      editWo.Text := QryTemp.FieldByName('work order').AsString;
      QryTemp.Close;
      ShowWoMSLData;
      editWo.SetFocus;
    end;
    free;
  end;
end;

end.

