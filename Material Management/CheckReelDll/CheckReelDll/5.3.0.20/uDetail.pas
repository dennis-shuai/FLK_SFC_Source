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
    edtBOXNO: TEdit;
    lablType: TLabel;
    lablOutput: TLabel;
    Bevel2: TBevel;
    StringGridReel: TStringGrid;
    Label2: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Editidno: TEdit;
    Editpartno: TEdit;
    EditREELNO: TEdit;
    Editqty: TEdit;
    LBLmaterialno: TLabel;
    lblstatus: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtBOXNOKeyPress(Sender: TObject; var Key: Char);
    procedure EditidnoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  //  procedure EditdatacodeKeyDown(Sender: TObject; var Key: Word;
    //  Shift: TShiftState);
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
var i, irow,icol:integer;
begin
  with stringgridREEL do
      for i:=1 to RowCount do
        rows[i].Clear ;
       with QryTemp do
         begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString, 'material_no', ptInput);
            CommandText := ' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,A.TYPE,   '
                          +' A.DATECODE,A.MFGER_NAME,A.MFGER_PART_NO from  '
                          +' SAJET.G_MATERIAL A,SAJET.SYS_PART B  '
                          +' WHERE A.PART_ID=B.PART_ID AND A.MATERIAL_NO=:material_no '
                          +' ORDER BY A.REEL_NO  ';
            Params.ParamByName('material_no').AsString := edtboxno.text;
            Open;

         if isempty then
           begin
                MessageDlg('Not find record ! ', mtError, [mbOK], 0);
                edtboxno.SelectAll ;
                edtboxno.SetFocus ;
                exit;
           end;

          stringgridreel.RowCount :=recordcount+1;
          first;
          irow:=1;
          while not eof do
            begin
               stringgridreel.Cells[0,irow]:=fieldbyname('part_no').AsString ;
               stringgridreel.Cells[1,irow]:=fieldbyname('material_no').AsString ;
               stringgridreel.Cells[2,irow]:=fieldbyname('material_qty').AsString ;
               stringgridreel.Cells[3,irow]:=fieldbyname('REEL_NO').AsString ;
               stringgridreel.Cells[4,irow]:=fieldbyname('REEL_QTY').AsString ;
               stringgridreel.Cells[5,irow]:=fieldbyname('TYPE').AsString ;
               stringgridreel.Cells[6,irow]:=fieldbyname('DATECODE').AsString ;
               stringgridreel.Cells[7,irow]:=fieldbyname('MFGER_NAME').AsString ;
               stringgridreel.Cells[8,irow]:=fieldbyname('MFGER_PART_NO').AsString ;
               NEXT;
               INC(IROW);
            end;
         end;

      edtBOXNO.SelectAll;
      edtBOXNO.SetFocus;
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
  edtBOXNO.SetFocus;
  with stringgridREEL do
     begin
       FixedCols:=0;
       fixedrows:=1;
       rowcount:=5;
       colcount:=9;
       cells[0,0]:='Part_NO';
       ColWidths[0]:=100;
       cells[1,0]:='Material_no';
       ColWidths[1]:=120;
       cells[2,0]:='Material_Qty';
       ColWidths[2]:=80;
       cells[3,0]:='Reel_no';
       ColWidths[3]:=120;
       cells[4,0]:='Reel_Qty';
       ColWidths[4]:=80;
       cells[5,0]:='Type';
       ColWidths[5]:=40;
       cells[6,0]:='Date_Code';
       ColWidths[6]:=70;
       cells[7,0]:='Mfger_Name';
       ColWidths[7]:=100;
       cells[8,0]:='Mfger_Part_NO' ;
       ColWidths[8]:=100;
     end;
     editidno.Clear ;
     editpartno.Clear ;
     editREELNO.Clear ;
     editqty.Clear ;
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
    Params.ParamByName('dll_name').AsString := 'CheckReelDLL.DLL';
    Open;
  end;
end;

procedure TfDetail.edtBOXNOKeyPress(Sender: TObject; var Key: Char);
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
           lblstatus.Caption:='';

           editpartno.Text:=leftStr(editidno.Text, pos(';',editidno.Text)-1);
           str1:=copy(editidno.Text,pos(';',editidno.Text)+1,length(editidno.Text)-pos(';',editidno.Text));
           editREELNO.Text := leftStr(str1, pos(';',str1)-1);
           editqty.Text:=copy(str1, pos(';',str1)+1,length(str1)-pos(';',str1)) ;

            with QryTemp do
              begin
                 Close;
                 Params.Clear;
                 Params.CreateParam(ftString, 'MATERIAL_NO', ptInput);
                 Params.CreateParam(ftString, 'REEL_NO', ptInput);
                 Params.CreateParam(ftString, 'REEL_QTY', ptInput);
                 Params.CreateParam(ftString, 'PART_NO', ptInput);
                 CommandText :=' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY,A.TYPE,A.DATECODE,A.MFGER_NAME,A.MFGER_PART_NO from   '
                              +' SAJET.G_MATERIAL A,SAJET.SYS_PART B   '
                              +' WHERE A.PART_ID=B.PART_ID AND A.MATERIAL_NO=:MATERIAL_NO AND A.REEL_NO=:REEL_NO AND A.REEL_QTY=:REEL_QTY '
                              +' AND B.PART_NO=:PART_NO AND ROWNUM=1 ';
                 Params.ParamByName('MATERIAL_NO').AsString := EDTBOXNO.Text ;
                 Params.ParamByName('REEL_NO').AsString := EDITREELNO.Text ;
                 Params.ParamByName('REEL_QTY').AsString := EDITQTY.Text  ;
                 Params.ParamByName('PART_NO').AsString := EDITPARTNO.Text  ; ;
                 Open;

                if isempty then
                  begin
                     MessageDlg('Not find record can to check ! ', mtError, [mbOK], 0);
                     editidno.SelectAll ;
                     editidno.SetFocus ;
                     exit;
                  end;
                if fieldbyname('type').AsString ='K' THEN
                  begin
                     MessageDlg('The record had checked ! ', mtError, [mbOK], 0);
                     editidno.SelectAll ;
                     editidno.SetFocus ;
                     exit;
                  end;

                 Close;
                 Params.Clear;
                 Params.CreateParam(ftString, 'REEL_NO', ptInput);
                 Params.CreateParam(ftString, 'update_userid ', ptInput);
                 CommandText :=' UPDATE SAJET.G_MATERIAL SET TYPE=''K'',UPDATE_TIME=SYSDATE,update_userid=:update_userid  '
                              +' where  reel_no=:reel_no and ROWNUM=1 ';
                 Params.ParamByName('REEL_NO').AsString := EDITREELNO.Text ;
                 Params.ParamByName('update_userid').AsString := UpdateUserID ;
                 execute;

                 Close;
                 Params.Clear;
                 Params.CreateParam(ftString, 'REEL_NO', ptInput);
                 CommandText :=' insert into sajet.g_ht_material  '
                              +' (select * from sajet.g_material where  reel_no=:reel_no and ROWNUM=1 )';
                 Params.ParamByName('REEL_NO').AsString := EDITREELNO.Text ;
                 execute;

                 ShowData('');
                 lblstatus.Caption :=editreelno.Text +' check ok! ';

                 editidno.SelectAll ;
                 editidno.SetFocus ;

              end;
       end;
end;

end.

