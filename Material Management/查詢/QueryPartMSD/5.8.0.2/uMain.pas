unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  MConnect, SConnect, {FileCtrl,} ObjBrkr, Menus,DateUtils,comobj,Variants,
  ComCtrls;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    labCnt: TLabel;
    labcost: TLabel;
    qryReel: TClientDataSet;
    Image2: TImage;
    sbtnQuery: TSpeedButton;
    cmbboxlinename: TComboBox;
    Label4: TLabel;
    StringGrid1: TStringGrid;
    lblstatus: TLabel;
    Label2: TLabel;
    cmbboxmachine: TComboBox;
    Label5: TLabel;
    Editwo: TEdit;
    Label3: TLabel;
    Editpartno: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    EditReelno: TEdit;
    Editfeederno: TEdit;
    Editstationno: TEdit;
    Label9: TLabel;
    Editopentime: TEdit;
    Label11: TLabel;
    procedure FormShow(Sender: TObject);
    procedure sbtnQueryClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    OrderIdx: string;
    UpdateUserID,gsParam: string;
    Authoritys, AuthorityRole: string;
    icol,irow:integer;
    Griviseday:integer;
    procedure cleardata;
    procedure getlinename;
    procedure getmachine;
    procedure querymsd;
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}
uses uDllform;

procedure tfmain.getmachine;
begin
   with  qrytemp do
   begin
       close;
       commandtext:=' SELECT machine_code from SAJET.SYS_machine WHERE ENABLED=''Y'' order by machine_code asc ';
       open;
       IF ISEMPTY THEN EXIT;
       cmbboxmachine.Clear ;
       first;
       WHILE NOT EOF DO
         BEGIN
            cmbboxmachine.Items.Add(fieldbyname('machine_code').AsString );
            next;
         END;
   end;
end;


procedure TfMain.CLEARDATA;
var i,j:integer;
BEGIN
   Griviseday:=365;
   irow:=5;
   icol:=11;
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   stringgrid1.ColCount :=icol;
   stringgrid1.Rowcount :=irow;
   for i:=0 to irow  do
     for j:=0 to icol do
       stringgrid1.Cells[icol,irow]:='';
   stringgrid1.Cells[0,0]:='Rows';
   stringgrid1.Cells[1,0]:='Work Order';
   stringgrid1.Cells[2,0]:='Line name' ;
   stringgrid1.Cells[3,0]:='Machine' ;
   stringgrid1.Cells[4,0]:='Part no' ;
   stringgrid1.Cells[5,0]:='Reel no';
   stringgrid1.Cells[6,0]:='Start time' ;
   stringgrid1.Cells[7,0]:='Floor life(H)';
   stringgrid1.Cells[8,0]:='Open time(M)' ;
   stringgrid1.Cells[9,0]:='Feeder no' ;
   stringgrid1.Cells[10,0]:='Station no' ;

   stringgrid1.ColWidths[0]:=30;
   stringgrid1.ColWidths[1]:=90;
   stringgrid1.ColWidths[2]:=80;
   stringgrid1.ColWidths[3]:=90;
   stringgrid1.ColWidths[4]:=100;
   stringgrid1.ColWidths[5]:=90;
   stringgrid1.ColWidths[6]:=100;
   stringgrid1.ColWidths[7]:=50;
   stringgrid1.ColWidths[8]:=50;
   stringgrid1.ColWidths[9]:=90;
   stringgrid1.ColWidths[10]:=90;

   lblstatus.Caption :='';
   editwo.Clear ;
   editpartno.Clear ;
   editreelno.Clear ;
   editfeederno.Clear ;
   editstationno.Clear ;
   editopentime.Clear ;
END;

procedure TfMain.getlinename;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select * FROM SAJET.SYS_PDLINE WHERE ENABLED=''Y'' ORDER BY PDLINE_NAME ASC ';
          open;

          if recordcount<>0 then
            begin
                first;
                cmbboxlinename.Clear ;
                while not eof do
                   begin
                       cmbboxlinename.Items.Add(fieldbyname('pdline_name').AsString );
                       next; 
                   end;
            end;
        end;

end;


procedure TfMain.querymsd;
var i,j:integer;
var strsql:string;
begin
   for i:=1 to stringgrid1.RowCount  do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   strsql:=' select e.work_order,d.pdline_name,f.machine_code,b.part_no,a.reel_no,   '
          +' a.in_time,c.floor_life as floor_life, '
         // +' c.floor_life*60 - nvl(substr((sysdate - a.in_time)*60*24,0,(instr((sysdate - a.in_time)*60*24,''.'' )-1)),1) as open_time,  '
          +' c.floor_life*60 - substr((sysdate - a.in_time)*60*24,0,decode(instr((sysdate - a.in_time)*60*24,''.'' ),''0'',length((sysdate - a.in_time)*60*24),instr((sysdate - a.in_time)*60*24,''.'' )-1)) as open_time, '
          +' a.feeder_no,a.station_no  '
          +' from smt.g_smt_status a,sajet.sys_part b,sajet.sys_part_msd c ,sajet.sys_pdline d ,smt.g_wo_msl e, '
          +' sajet.sys_machine f   '
          +' where      '
          +' a.wo_sequence=e.wo_sequence and     '
          +' a.item_part_id=b.part_id and a.item_part_id=c.part_id   '
          +' and a.pdline_id=d.pdline_id '
          +' and e.machine_id=f.machine_id '
          +' and C.CHECK_MSD=''Y'' and a.station_no<>''DIP'' ';

   if trim(editwo.Text )<>'' then
      strsql:=strsql+' and e.work_order='+''''+trim(editwo.Text)+'''';
   if cmbboxlinename.Text<>'' then
      strsql:=strsql+' and d.pdline_name='+''''+cmbboxlinename.Text+'''';
   if cmbboxmachine.Text<>'' then
      strsql:=strsql+' and f.machine_code='+''''+cmbboxmachine.Text+'''';
   if trim(editpartno.Text  )<>'' then
      strsql:=strsql+' and b.part_no='+''''+trim(editpartno.Text)+'''';
   if trim(editreelno.Text  )<>'' then
      strsql:=strsql+' and a.reel_no='+''''+trim(editreelno.Text )+'''';
   if trim(editfeederno.Text )<>'' then
      strsql:=strsql+' and a.feeder_no='+''''+trim(editfeederno.Text)+'''';
   if trim(editstationno.Text )<>'' then
      strsql:=strsql+' and a.station_no='+''''+trim(editstationno.Text)+'''';
   if trim(editopentime.Text)<>'' then
   begin
     try
     if (strtoint(editopentime.Text)>=0) or (strtoint(editopentime.Text)< 0) then
        //strsql:=strsql+' and  c.floor_life*60 - nvl(substr((sysdate - a.in_time)*60*24,0,(instr((sysdate - a.in_time)*60*24,''.'' )-1)),1)  <= '+''''+trim(editopentime.Text)+'''';
          strsql:=strsql+' and c.floor_life*60 - substr((sysdate - a.in_time)*60*24,0,decode(instr((sysdate - a.in_time)*60*24,''.'' ),''0'',length((sysdate - a.in_time)*60*24),instr((sysdate - a.in_time)*60*24,''.'' )-1)) <= '+''''+trim(editopentime.Text)+'''';
     except
       MessageDlg('Open time Error!!',mtError, [mbCancel],0);
       editopentime.SelectAll;
       editopentime.SetFocus ;
       Exit;
     end;
   end;
   strsql:=strsql+' order by work_order, pdline_name,machine_code,part_no    ';

   with Qrydata do
       begin
          close;
          commandtext:=strsql;
          open;

      first;
      irow:=1;
      while not eof do
       begin
          stringgrid1.Cells[0,irow]:=inttostr(irow);
          stringgrid1.Cells[1,irow]:= fieldbyname('work_order').AsString ;
          stringgrid1.Cells[2,irow]:=fieldbyname('pdline_name').AsString ;
          stringgrid1.Cells[3,irow]:= fieldbyname('machine_code').AsString ;
          stringgrid1.Cells[4,irow]:=fieldbyname('part_no').AsString;
          stringgrid1.Cells[5,irow]:=fieldbyname('reel_no').AsString;
          stringgrid1.Cells[6,irow]:=fieldbyname('in_time').AsString ;
          stringgrid1.Cells[7,irow]:= fieldbyname('floor_life').AsString ;
          stringgrid1.Cells[8,irow]:=fieldbyname('open_time').AsString ;
          stringgrid1.Cells[9,irow]:= fieldbyname('feeder_no').AsString ;
          stringgrid1.Cells[10,irow]:=fieldbyname('station_no').AsString;
          inc(irow);
          next;
       end;
       if irow<=5 then
          irow:=5;
       stringgrid1.FixedCols :=0;
       stringgrid1.FixedRows :=1;
       stringgrid1.ColCount :=icol;
       stringgrid1.Rowcount :=irow;

       lblstatus.Caption :=inttostr(recordcount) ;
      end;

end;


procedure TfMain.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;

  with QryTemp do
  begin
    Close;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    if gsParam <> '' then
      CommandText := CommandText + 'and fun_param = ''' + gsParam + ''' ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'QueryPartMSD.DLL';
    Open;
  end;


  getlinename;
  getmachine;
  cleardata;
end;



procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   querymsd;
end;



end.




