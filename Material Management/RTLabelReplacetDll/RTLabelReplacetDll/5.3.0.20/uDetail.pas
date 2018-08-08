unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles,StrUtils;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    QryDetail: TClientDataSet;
    DataSource2: TDataSource;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    edtRT: TEdit;
    lablType: TLabel;
    lablOutput: TLabel;
    Bevel2: TBevel;
    sbtnRT: TSpeedButton;
    StringGridRT: TStringGrid;
    StringGridMaterial: TStringGrid;
    Label2: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Editidno: TEdit;
    Editdatacode: TEdit;
    Editpartno: TEdit;
    Editboxid: TEdit;
    Editqty: TEdit;
    Label3: TLabel;
    LBLmaterialno: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtRTKeyPress(Sender: TObject; var Key: Char);
    procedure EditidnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditdatacodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, gsBoxField, gsReelField: string;
    procedure showData(sLocate: string);
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uCommData;

procedure TfDetail.ShowData(sLocate: string);
var sSQL: string;
var i, irtrow,irtcol:integer;
var imaterialrow,imaterialcol:integer;
begin
  with stringgridrt do
      for i:=1 to RowCount do
        rows[i].Clear ;
  with stringgridmaterial do
      for i:=1 to RowCount do
        rows[i].Clear ;
        
  sSQL:= ' SELECT C.PART_NO,A.STATUS,B.INCOMING_QTY , B.PRINT_QTY,B.OUTPUT_QTY,  '+
         ' B.MFGER_NAME,B.MFGER_PART_NO from sajet.G_ERP_RTNO  A,sajet.G_ERP_RT_ITEM B, sajet.SYS_PART C  '+
         ' WHERE A.RT_ID=B.RT_ID AND B.PART_ID=C.PART_ID AND C.ENABLED=''Y'' AND  A.RT_NO=:RT_NO '+
         ' Order By PART_NO ';
  with QryDetail do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'RT_NO', ptInput);
    CommandText := sSQL;
    Params.ParamByName('RT_NO').AsString := edtRT.Text;
    Open;
    if IsEmpty then
     begin
      MessageDlg('RT No: ' + edtRT.Text + ' not found.', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
     end;
   irtrow:=0 ;
   stringgridrt.RowCount:=recordcount+1;
   first;
   while not eof do
     begin
        stringgridrt.cells[0,irtrow+1]:=fieldbyname('part_no').AsString ;
        stringgridrt.Cells[1,irtrow+1]:=fieldbyname('status').AsString ;
        stringgridrt.cells[2,irtrow+1]:=fieldbyname('incoming_qty').AsString ;
        stringgridrt.Cells[3,irtrow+1]:=fieldbyname('print_qty').AsString ;
        stringgridrt.cells[4,irtrow+1]:=fieldbyname('output_qty').AsString ;
        stringgridrt.Cells[5,irtrow+1]:=fieldbyname('MFGER_NAME').AsString ;
        stringgridrt.Cells[6,irtrow+1]:=fieldbyname('MFGER_PART_NO').AsString ;
        next;
        inc(irtrow);
     end;
    if fieldbyname('status').AsString='0' then
     begin
      MessageDlg('RT No: ' + edtRT.Text + ' 沒有展完條碼 ', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
     end;
    if fieldbyname('INCOMING_QTY').AsString<>fieldbyname('PRINT_QTY').AsString then
     begin
      MessageDlg('RT No: ' + edtRT.Text + ' 沒有展完條碼 ', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
     end;
    if fieldbyname('status').AsString='2' then
     begin
      MessageDlg('RT No: ' + edtRT.Text + ' IN STOCK ', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
     end;
    if fieldbyname('OUTPUT_QTY').AsString>'0' then
     begin
      MessageDlg('RT No: ' + edtRT.Text + ' IN STOCK ', mtError, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
      Exit;
     end;
   end;

   with qrytemp   do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'RT_NO', ptInput);
      QryTemp.CommandText := ' SELECT C.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.DATECODE,A.MFGER_NAME,A.MFGER_PART_NO,A.WAREHOUSE_ID,NVL(A.RELEASE_QTY,0) RELEASE_QTY  from  '
                           + ' sajet.G_MATERIAL A,sajet.G_ERP_RTNO B,sajet.SYS_PART C  '
                           + ' WHERE A.RT_ID=B.RT_ID AND  B.RT_NO=:RT_no  '
                           + ' AND A.PART_ID=C.PART_ID AND C.ENABLED=''Y'' '
                           + ' order by material_no ';
      Params.ParamByName('RT_NO').AsString := edtRT.Text;
      OPEN;
      if IsEmpty then
         begin
           MessageDlg('Material_no not found.', mtError, [mbOK], 0);
           edtRT.SelectAll;
           edtRT.SetFocus;
           Exit;
        end;
     imaterialrow:=0 ;
     stringgridmaterial.RowCount:=recordcount+1;
     first;
     while not eof do
       begin
          stringgridmaterial.cells[0,imaterialrow+1]:=fieldbyname('part_no').AsString ;
          stringgridmaterial.Cells[1,imaterialrow+1]:=fieldbyname('MATERIAL_NO').AsString ;
          stringgridmaterial.cells[2,imaterialrow+1]:=fieldbyname('MATERIAL_QTY').AsString ;
          stringgridmaterial.Cells[3,imaterialrow+1]:=fieldbyname('DATECODE').AsString ;
          stringgridmaterial.cells[4,imaterialrow+1]:=fieldbyname('MFGER_NAME').AsString ;
          stringgridmaterial.Cells[5,imaterialrow+1]:=fieldbyname('MFGER_PART_NO').AsString ;
          next;
          inc(imaterialrow);
       end;
     if fieldbyname('RELEASE_QTY').AsString>'0' then
       begin
         MessageDlg('RT No: ' + edtRT.Text + ' 已經有展reel_ID ', mtError, [mbOK], 0);
         edtRT.SelectAll;
         edtRT.SetFocus;
         Exit;
        end;
     if fieldbyname('warehouse_id').AsString <>'' then
       begin
         MessageDlg('RT No: ' + edtRT.Text + ' 已經入庫 ', mtError, [mbOK], 0);
         edtRT.SelectAll;
         edtRT.SetFocus;
         Exit;
        end;

    end;

     // MessageDlg('RT No: ' + edtRT.Text + #13#13 + 'Print OK.', mtInformation, [mbOK], 0);
      edtRT.SelectAll;
      edtRT.SetFocus;
end;

procedure TfDetail.FormShow(Sender: TObject);
var PIni: TIniFile;
begin
  PIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Material.Ini');
  gsBoxField := PIni.ReadString('Material', 'Material Default Qty Field', 'OPTION5');
  gsReelField := PIni.ReadString('Material', 'Reel Default Qty Field', 'OPTION6');
  PIni.Free;
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  edtRT.SetFocus;
  with stringgridrt do
    begin
       FixedCols:=0;
       fixedrows:=1;
       rowcount:=5;
       colcount:=7;
       cells[0,0]:='Part_NO';
       ColWidths[0]:=100;
       cells[1,0]:='Status';
       ColWidths[1]:=40;
       cells[2,0]:='Incoming_Qty';
       cells[3,0]:='Print_Qty';
       cells[4,0]:='Output_Qty';
       cells[5,0]:='Mfger_Name';
       ColWidths[5]:=100;
       cells[6,0]:='Mfger_Part_NO' ;
       ColWidths[6]:=100;
    end  ;
  with stringgridmaterial do
     begin
       FixedCols:=0;
       fixedrows:=1;
       rowcount:=5;
       colcount:=6;
       cells[0,0]:='Part_NO';
       ColWidths[0]:=100;
       cells[1,0]:='Material_no';
       ColWidths[1]:=120;
       cells[2,0]:='Material_Qty';
       ColWidths[2]:=80;
       cells[3,0]:='Date_Code';
       ColWidths[3]:=70;
       cells[4,0]:='Mfger_Name';
       ColWidths[4]:=100;
       cells[5,0]:='Mfger_Part_NO' ;
       ColWidths[5]:=100;
     end;
     editidno.Clear ;
     editpartno.Clear ;
     editboxid.Clear ;
     editqty.Clear ;
     editdatacode.Clear ;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'RTLABELREPLACEDLL.DLL';
    Open;
    {
   // LabTitle1.Caption := FieldByName('f1').AsString;
   // LabTitle2.Caption := LabTitle1.Caption;
    Close;
    Params.Clear;
    CommandText := 'select param_name from sajet.sys_base '
      + 'where param_value = ''Label Type'' ';
    Open;
    gsLabelField := FieldByName('param_name').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Qty Field'' ';
    Open;
    gsBoxField := FieldByName('param_value').AsString;
    Close;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Reel Qty Field'' ';
    Open;
    gsReelField := FieldByName('param_value').AsString;
    Close;
    Params.Clear;
    CommandText := 'select param_value from sajet.sys_base '
      + 'where param_name = ''Material Caps Lock'' ';
    Open;
    if not IsEmpty then begin
      edtRT.CharCase := ecUpperCase;
    end;  }
  end;
end;

procedure TfDetail.edtRTKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = vk_Return then
    ShowData('');
end;

procedure TfDetail.EditidnoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var str1:string;
begin
   if editidno.Text<>'' then
     if key=13 then
       begin
           editpartno.Text:=leftStr(editidno.Text, pos(';',editidno.Text)-1);
           str1:=copy(editidno.Text,pos(';',editidno.Text)+1,length(editidno.Text)-pos(';',editidno.Text));
           editboxid.Text := leftStr(str1, pos(';',str1)-1);
           editqty.Text:=copy(str1, pos(';',str1)+1,length(str1)-pos(';',str1)) ;

           editdatacode.SelectAll ;
           editdatacode.SetFocus ;
       end;
end;

procedure TfDetail.EditdatacodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
   begin
     lblmaterialno.Caption:='';
     if editidno.Text='' then
      begin
          editidno.SelectAll;
          editidno.SetFocus ;
          exit;
      end;
     if length(editpartno.text)<>14 then
       begin
           showmessage('Part no length IS not 14 bit! ') ;
           editidno.SelectAll ;
           editidno.SetFocus ;
           exit;
       end;
     if length(editboxid.text)<>13 then
       begin
           showmessage('BOX/QTY ID length IS not 13 bit! ') ;
           editidno.SelectAll ;
           editidno.SetFocus ;
           exit;
       end;

  with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'new_material_no', ptInput);
      CommandText :=' select new_material_no from sajet.g_material_replace  where new_material_no=:new_material_no ' ;
      Params.ParamByName('new_material_no').AsString := editboxid.Text  ;
      Open;
      if not isempty then
         begin
            MessageDlg('THE LABEL '+editboxid.Text +' IS Double!', mtError, [mbOK], 0);
            editidno.SelectAll ;
            editidno.SetFocus ;
            exit;
         end;
    end;


  with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_no', ptInput);
      Params.CreateParam(ftString, 'part_no', ptInput);
      Params.CreateParam(ftString, 'LABEL_TYPE', ptInput);
      Params.CreateParam(ftString, 'material_qty', ptInput);
      Params.CreateParam(ftString, 'datecode', ptInput);
      CommandText :=' SELECT C.PART_NO,A.MATERIAL_NO ,A.MATERIAL_QTY,A.DATECODE from '
                  +' SAJET.G_MATERIAL A,SAJET.G_ERP_RTNO B,SAJET.SYS_PART C    '
                  +' WHERE A.RT_ID=B.RT_ID AND  B.RT_NO=:rt_no   '
                  +' AND A.PART_ID=C.PART_ID   '
                  +' AND C.PART_NO=:part_no AND C.ENABLED=''Y''    '
                  +' AND substr(A.material_no,0,1)=:label_type and length(A.material_no)=8 '
                  +' AND A.MATERIAL_QTY=:material_qty AND A.DATECODE=:datecode   '
                  +' AND A.WAREHOUSE_ID IS NULL AND REEL_NO IS NULL   '
                  +' AND A.RELEASE_QTY=0 AND ROWNUM=1        ' ;
      Params.ParamByName('RT_NO').AsString := edtRT.Text ;
      Params.ParamByName('part_NO').AsString := editpartno.Text  ;
      Params.ParamByName('LABEL_TYPE').AsString := COPY(editboxid.Text,0,1)   ;
      Params.ParamByName('material_qty').AsString := editqty.Text   ;
      Params.ParamByName('datecode').AsString := editdatacode.Text   ;
      Open;
      if isempty then
         begin
            MessageDlg('Not find record to replace! ', mtError, [mbOK], 0);
            editidno.SelectAll ;
            editidno.SetFocus ;
            exit;
         end;
      lblmaterialno.Caption:=fieldbyname('material_no').AsString ;
    end;

   with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'rt_no', ptInput);
      Params.CreateParam(ftString, 'part_no', ptInput);
      Params.CreateParam(ftString, 'LABEL_TYPE', ptInput);
      params.CreateParam(ftString, 'material_no', ptInput);
      Params.CreateParam(ftString, 'material_qty', ptInput);
      Params.CreateParam(ftString, 'datecode', ptInput);
      CommandText := 'insert into sajet.g_material_replace fields(rt_id,part_id,datecode,old_material_no,material_qty) '
                  +' ('
                  +' SELECT a.Rt_id,a.part_id,a.datecode,a.material_no,a.material_qty from '
                  +' SAJET.G_MATERIAL A,SAJET.G_ERP_RTNO B,SAJET.SYS_PART C    '
                  +' WHERE A.RT_ID=B.RT_ID AND  B.RT_NO=:rt_no   '
                  +' AND A.PART_ID=C.PART_ID   '
                  +' AND C.PART_NO=:part_no AND C.ENABLED=''Y''    '
                  +' AND substr(A.material_no,0,1)=:label_type '
                  +' AND A.material_no=:material_no and  A.MATERIAL_QTY=:material_qty AND A.DATECODE=:datecode   '
                  +' AND A.WAREHOUSE_ID IS NULL AND REEL_NO IS NULL   '
                  +' AND A.RELEASE_QTY=0 AND ROWNUM=1        '
                  +' ) ';
      Params.ParamByName('RT_NO').AsString := edtRT.Text ;
      Params.ParamByName('part_NO').AsString := editpartno.Text  ;
      Params.ParamByName('LABEL_TYPE').AsString := COPY(editboxid.Text,0,1)   ;
      Params.ParamByName('material_no').AsString := lblmaterialno.Caption   ;
      Params.ParamByName('material_qty').AsString := editqty.Text   ;
      Params.ParamByName('datecode').AsString := editdatacode.Text   ;
      execute;

      close;
      Params.Clear;
      Params.CreateParam(ftString, 'new_material_no', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'old_material_no', ptInput);
      CommandText :=' update sajet.g_material_replace set new_material_no=:new_material_no,update_userid=:update_userid '
                   +' where old_material_no=:old_material_no ';
      Params.ParamByName('new_material_no').AsString := editboxid.Text  ;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('old_material_no').AsString := lblmaterialno.Caption    ;
      execute;

      close;
      Params.Clear;
      Params.CreateParam(ftString, 'new_material_no', ptInput);
      Params.CreateParam(ftString, 'update_userid', ptInput);
      Params.CreateParam(ftString, 'old_material_no', ptInput);
      CommandText :=' update sajet.g_material set material_no=:new_material_no,update_userid=:update_userid ,update_time=sysdate '
                   +' where material_no=:old_material_no ';
      Params.ParamByName('new_material_no').AsString := editboxid.Text  ;
      Params.ParamByName('update_userid').AsString := UpdateUserID;
      Params.ParamByName('old_material_no').AsString := lblmaterialno.Caption    ;
      execute;

      close;
      Params.Clear;
      Params.CreateParam(ftString, 'material_no', ptInput);
      CommandText :='insert into sajet.g_ht_material  '
                   +' (select * from sajet.g_material  where material_no=:material_no )';
      Params.ParamByName('material_no').AsString := editboxid.Text  ;
      execute;

     lblmaterialno.Caption:= lblmaterialno.Caption + ' replace ok! ' ;
    end;

     ShowData('');
     editidno.SelectAll ;
     editidno.SetFocus ;
  end;
end;

end.

