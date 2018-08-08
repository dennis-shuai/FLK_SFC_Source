unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    lblNCount: TLabel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    sbtnQuery: TSpeedButton;
    Image5: TImage;
    sbtnExport: TSpeedButton;
    Image1: TImage;
    edtWo: TEdit;
    procedure sbtnQueryClick(Sender: TObject);
    procedure sbtnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
     mPartID,UpdateUserID:string;

  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit;


procedure TfDetail.sbtnQueryClick(Sender: TObject);
begin
   with qrydata do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'wo',ptInput);
       commandtext :=' select SubStr(a.customer_sn,9,7) PCB_No, a.customer_sn  Serial_No, b.Item_part_sn TID_NO, '+
                     ' to_char(b.Update_time,''YYYY/MM/DD'') Test_Date ,to_char(b.Update_time,''hh24:Mi:ss'') Test_Time '+
                     ' from sajet.g_sn_status a,sajet.g_sn_keyparts b '+
                     ' where a.serial_number =b.serial_number and a.work_order =:wo '+
                     ' and B.PROCESS_ID = 100287 ' ;

       params.ParamByName('wo').AsString := edtwo.Text;
       open;
   end;
end;

procedure TfDetail.sbtnExportClick(Sender: TObject);
var s,sFileName,prfix:string;
i,j:integer;
F:TextFile;
begin
  if qrydata.IsEmpty then exit;
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
    for  I:=0 to qrydata.FieldCount-1 do
      S:=S+qrydata.Fields[i].FieldName+','  ;
    WriteLn(F,S);

    qrydata.First;
    for  j:=0 to qrydata.RecordCount-1 do begin
      Application.ProcessMessages;
      S:='';
      for  i:=0 to qrydata.FieldCount-1 do
       S:=S+qrydata.Fields.Fields[i].AsString+','  ;
       WriteLn(F,S);
       qrydata.Next;
    end;
    CloseFile(F);
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
 edtWO.SetFocus;
end;

end.
