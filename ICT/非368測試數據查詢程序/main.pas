unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, ADODB, Grids, DBGrids, StdCtrls, Buttons,DateUtils;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    cmbProcess: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    edtIPAddr: TEdit;
    Label4: TLabel;
    edtDb: TEdit;
    Label5: TLabel;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    Label6: TLabel;
    edtSN: TEdit;
    Label7: TLabel;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    ADOQry: TADOQuery;
    ADOConn: TADOConnection;
    ProgressBar1: TProgressBar;
    btnConnect: TBitBtn;
    btnQuery: TBitBtn;
    BitBtn1: TBitBtn;
    lblQty: TLabel;
    SaveDialog1: TSaveDialog;
    procedure btnConnectClick(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnConnectClick(Sender: TObject);
begin
   AdoConn.Close;
   ADOConn.ConnectionString :='Provider=SQLOLEDB.1;Persist Security Info=False;'+
                ' User ID=sa;PWD=foxlinkccm;Initial Catalog='+edtDB.Text+';Data Source='+ edtIPAddr.Text+
                ' ;Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;'+
                '  Use Encryption for Data=False;'+
                ' Tag with column collation when possible=False';
   AdoConn.Connected :=true;

end;

procedure TForm1.btnQueryClick(Sender: TObject);
var sqlText,S,STARTDATE,ENDDATE,sFileName:string;
 F: TextFile;
begin
    btnConnect.Click;
    sqlText :='';
    STARTDATE :=FormatDateTime('YYYY/MM/DD ',DateTimepicker1.Date)+FormatDateTime('HH:MM:SS',DateTimepicker2.Time);
    ENDDATE :=  FormatDateTime('YYYY/MM/DD ',DateTimepicker3.Date)+FormatDateTime('HH:MM:SS',DateTimepicker4.Time);
    if ADOConn.Connected =true then begin
         ADOQry.Close;
         ADOQry.SQL.Clear;
         if cmbProcess.ItemIndex >=1 then begin
           sFileName := ExtractFilePath(ParamStr(0))+'\'+cmbProcess.Text+'.SQL';
           Assignfile(F, sFileName);
           Reset(F);
           while not eof(F) do begin
             readln(F, s);
             sqlText :=   sqlText + s;
           end;
           closefile(F);
         end;
         if  edtSN.Text<> '' then begin
            if cmbProcess.ItemIndex <1 then begin
                sqlText :='select * from R_HISTORYLOGFILE WHERE SERIALCODE = '''+ edtSN.TEXT+'''';

            end else begin

                sqlText:=sqlText+ ' and SERIALCODE = '''+ edtSN.TEXT+'''';
            end;

         end else begin
            if cmbProcess.ItemIndex <1 then
                sqlText :='select * from R_HISTORYLOGFILE where  TESTDATE >='''+STARTDATE+''' and TESTDATE<=''' +ENDDATE+''''
            else
             sqlText:=sqlText+ ' and TESTDATE >='''+STARTDATE+''' and TESTDATE<=''' +ENDDATE+'''';

         end;
         ADOQry.SQL.Text :=sqlText;
         ADoQry.Open;
         lblQty.Caption :='共查詢到'+IntToStr(ADOQry.RecordCount)+'筆數據';
    end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var s,sFileName,prfix:string;
i,j:integer;
F:TextFile;
begin
  if AdoQry.IsEmpty then exit;
  if saveDialog1.Execute then
    if saveDialog1.fileName ='' then exit;
    prfix :=  Copy(saveDialog1.fileName,Length(saveDialog1.fileName)-3,4);
    if prfix <>'.CSV' then begin
       sFileName := saveDialog1.fileName+'.csv';
       
    if fileexists( saveDialog1.fileName) then
     deletefile(  saveDialog1.fileName);
    end;
    AssignFile (F, sFileName);
    ReWrite(F);
    S:='';
    for  I:=0 to AdoQry.FieldCount-1 do
      S:=S+AdoQry.Fields[i].FieldName+','  ;
    WriteLn(F,S);

    AdoQry.First;
    for  j:=0 to AdoQry.RecordCount-1 do begin
      Application.ProcessMessages;
      S:='';
      for  i:=0 to AdoQry.FieldCount-1 do
       S:=S+AdoQry.Fields.Fields[i].AsString+','  ;
       WriteLn(F,S);
       AdoQry.Next;
    end;
    CloseFile(F);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   DateTimePicker1.DateTime :=today;
   DateTimePicker2.DateTime :=StrToDateTime('08:00:00');
   DateTimePicker3.DateTime :=tomorrow;
   DateTimePicker4.DateTime :=StrToDateTime('08:00:00');
end;

end.
