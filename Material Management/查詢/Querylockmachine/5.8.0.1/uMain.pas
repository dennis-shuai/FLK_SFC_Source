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
    procedure querylockmachine;
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
   icol:=6;
   stringgrid1.FixedRows:=1;
   stringgrid1.FixedCols:=0;
   stringgrid1.ColCount :=icol;
   stringgrid1.Rowcount :=irow;
   for i:=0 to irow  do
     for j:=0 to icol do
       stringgrid1.Cells[icol,irow]:='';
   stringgrid1.Cells[0,0]:='Rows';
   stringgrid1.Cells[1,0]:='Line name' ;
   stringgrid1.Cells[2,0]:='Machine' ;
   stringgrid1.Cells[3,0]:='stauts' ;
   stringgrid1.Cells[4,0]:='update flag';
   stringgrid1.Cells[5,0]:='update time' ;


   stringgrid1.ColWidths[0]:=30;
   stringgrid1.ColWidths[1]:=150;
   stringgrid1.ColWidths[2]:=150;
   stringgrid1.ColWidths[3]:=180;
   stringgrid1.ColWidths[4]:=150;
   stringgrid1.ColWidths[5]:=200;

   lblstatus.Caption :='';
END;

procedure TfMain.getlinename;
begin
      with QryTemp do
        begin
          Close;
          commandtext:='select distinct b.pdline_name from sajet.g_machine_status a,sajet.sys_pdline b '
                      +' where a.pdline_id =b.pdline_id' ;
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


procedure TfMain.querylockmachine;
var i,j:integer;
var strsql:string;
begin
   for i:=1 to stringgrid1.RowCount  do
     for j:=0 to stringgrid1.ColCount  do
       stringgrid1.Cells[j,i]:='';
   strsql:=' select c.pdline_name,b.machine_code,  '
          +' decode(a.status,''ON'',''Machine is OPEN status'',''OFF'',''Machine is STOP status'',''TM'',''Wait Time'') as status, '
          +' decode(a.update_flag,''Y'',''Waitting to change'',''N'',''had changed'') as update_flag,a.update_time    '
          +' from sajet.g_machine_status a,sajet.sys_machine b,sajet.sys_pdline c    '
          +' where a.machine_id=b.machine_id and a.pdline_id=c.pdline_id ';

   if trim(cmbboxlinename.Text)<>'' then
      strsql:=strsql+' and c.pdline_name='+''''+cmbboxlinename.Text+'''';
   if trim(cmbboxmachine.Text)<>'' then
      strsql:=strsql+' and b.machine_code='+''''+cmbboxmachine.Text+'''';

   strsql:=strsql+' order by pdline_name,machine_code    ';

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
          stringgrid1.Cells[1,irow]:= fieldbyname('pdline_name').AsString ;
          stringgrid1.Cells[2,irow]:=fieldbyname('machine_code').AsString ;
          stringgrid1.Cells[3,irow]:= fieldbyname('status').AsString ;
          stringgrid1.Cells[4,irow]:=fieldbyname('update_flag').AsString;
          stringgrid1.Cells[5,irow]:=fieldbyname('update_time').AsString ;
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
    Params.ParamByName('dll_name').AsString := 'Querylockmachine.DLL';
    Open;
  end;


  getlinename;
  getmachine;
  cleardata;
end;



procedure TfMain.sbtnQueryClick(Sender: TObject);
begin
   querylockmachine;
end;



end.




