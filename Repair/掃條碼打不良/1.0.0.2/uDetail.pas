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
    Label1: TLabel;
    lblMsg: TLabel;
    Label3: TLabel;
    edtSN: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    cmbPdline: TComboBox;
    cmbTerminal: TComboBox;
    lbl1: TLabel;
    cmbDefect: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    procedure cmbPdlineSelect(Sender: TObject);
    procedure cmbTerminalSelect(Sender: TObject);
    procedure cmbDefectSelect(Sender: TObject);
    procedure cmbDefectKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID: String;
   
   
  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit;




procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin

    QryTemp.Close;
    QryTemp.Params.Clear;
    Qrytemp.CommandText := ' SELECT PDLINE_NAME FROM SAJET.SYS_PDLINE WHERE UPPER(PDLINE_NAME) NOT LIKE '+
                           ' ''%REPAIR%'' AND   '+
                           ' UPPER(PDLINE_NAME)  NOT LIKE ''%PACK%''  AND UPPER(PDLINE_NAME)  NOT LIKE ''%CAR%'' '+
                           '  AND UPPER(PDLINE_NAME)  '+
                           ' NOT LIKE ''%PGI%'' AND UPPER(PDLINE_NAME)  NOT LIKE ''%SHIP%'' '+
                           ' AND ENABLED =''Y'' AND UPPER(PDLINE_NAME)  NOT LIKE ''%MATERIAL%'' '+
                           ' order by PDLINE_NAME ';
    QryTemp.Open;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
         cmbPdline.Items.Add(QryTemp.fieldbyName('PDLINE_NAME').AsString);
        QryTemp.Next;
    end;
    cmbPdline.SetFocus;

    QryTemp.Close;
    QryTemp.Params.Clear;
    Qrytemp.CommandText := ' SELECT  Defect_Code FROM SAJET.SYS_DEFECT WHERE ENABLED=''Y''  ORDER BY DEFECT_CODE  ' ;
    QryTemp.Open;
    QryTemp.First;
    for i:=0 to QryTemp.RecordCount-1 do begin
         cmbDefect.Items.Add(QryTemp.fieldbyName('Defect_Code').AsString);
        QryTemp.Next;
    end;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
   if Key <> #13 then exit;
   if Length(EdtSN.Text)=0 then exit;
   if Length(cmbDefect.Text)=0 then exit;
   if cmbPdline.ItemIndex <0 then exit;
   if cmbTerminal.ItemIndex <0 then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.CCM_CSN_DEFECT_INPUT');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TSN').AsString :=edtSN.Text;
   Sproc.Params.ParamByName('TTERMINALID').AsString :=G_sTerminalID;
   Sproc.Params.ParamByName('TDEFECT').AsString :=cmbDefect.Text;
   Sproc.Params.ParamByName('TEMPID').AsString :=UpdateUserID;
   Sproc.Execute;
   iResult :=Sproc.Params.ParamByName('TRES').AsString  ;
   IF iResult <>'OK' THEN BEGIN
      lblMsg.Caption :=iResult;
      lblMsg.Color :=clRed;
       edtSn.Text :='';
       edtSN.SetFocus;
       exit;
   END;
   lblMsg.Caption :=iResult;
   lblMsg.Color :=clGreen;
   edtSn.Text :='';
   edtSN.SetFocus;
end;

procedure TfDetail.cmbPdlineSelect(Sender: TObject);
var i:Integer;
begin
   cmbTerminal.Items.Clear;
   QryTemp.Close;
   QryTemp.Params.Clear;
   QryTemp.Params.CreateParam(ftString,'PDLINE',ptInput);
   Qrytemp.CommandText :=  'SELECT B.TERMINAL_NAME FROM SAJET.SYS_PDLINE A,SAJET.SYS_TERMINAL B '+
                           ' WHERE A.PDLINE_ID=B.PDLINE_ID AND A.PDLINE_NAME=:PDLINE AND B.ENABLED =''Y''' +
                           ' ORDER BY TERMINAL_NAME ';
   QryTemp.Params.ParamByName('PDLINE').AsString := cmbPdline.Text;
   Qrytemp.Open;
   QryTemp.First;
   for i:=0 to QryTemp.RecordCount-1 do begin
        cmbTerminal.Items.Add(QryTemp.fieldbyName('TERMINAL_NAME').AsString);
        QryTemp.Next;
   end;
   cmbTerminal.Enabled :=True;
end;

procedure TfDetail.cmbTerminalSelect(Sender: TObject);
begin
  lblMsg.Caption :='請掃描不良代碼';
  lblMsg.Color := clGreen;

  //       G_sTerminalID
  QryTemp.Close;
  QryTemp.Params.Clear;
  QryTemp.Params.CreateParam(ftstring,'PDLINE',ptInput);
  QryTemp.Params.CreateParam(ftstring,'TERMINAL',ptInput);
  QryTemp.CommandText :='SELECT b.process_id, b.TERMINAL_ID FROM SAJET.SYS_PDLINE A,SAJET.SYS_TERMINAL B WHERE '+
                        ' A.PDLINE_NAME =:PDLINE AND A.PDLINE_ID =b.PDLINE_ID AND '+
                        ' B.TERMINAL_NAME =:TERMINAL AND B.ENABLED=''Y'' ';
  QryTemp.Params.ParamByName('PDLINE').AsString := cmbPdline.Text;
  QryTemp.Params.ParamByName('TERMINAL').AsString := cmbTerminal.Text;
  QryTEmp.Open;
  G_sProcessID  :=  QryTemp.fieldbyName('process_id').AsString;
  G_sTerminalID :=  QryTemp.fieldbyName('TERMINAL_ID').AsString;
  cmbDefect.Enabled :=True;
  cmbDefect.SetFocus;

end;

procedure TfDetail.cmbDefectSelect(Sender: TObject);
begin
   { QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Defect',ptInput);
    Qrytemp.CommandText :=  ' SELECT * FROM SAJET.SYS_DEFECT WHERE DEFECT_CODE =:Defect and Enabled=''Y''';
    QryTemp.Params.ParamByName('Defect').AsString := cmbDefect.Text;
    Qrytemp.Open;
    if QryTemp.IsEmpty then begin
         lblMsg.Caption :='不良代碼錯誤';
         lblMsg.Color :=clRed;
         cmbDefect.Text :='';
         exit;
    end else begin
      lbl1.Caption :=  QryTemp.fieldBYname('Defect_Desc').AsString;
        lblMsg.Caption :='請掃描條碼';
        lblMsg.Color := clGreen;
         edtSn.SetFocus;
         edtSN.SelectAll;
    end;
    }
end;

procedure TfDetail.cmbDefectKeyPress(Sender: TObject; var Key: Char);
begin
    edtSN.Enabled :=false;
    if Key <>#13 then Exit;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Defect',ptInput);
    Qrytemp.CommandText :=  ' SELECT * FROM SAJET.SYS_DEFECT WHERE DEFECT_CODE =:Defect and Enabled=''Y''';
    QryTemp.Params.ParamByName('Defect').AsString := cmbDefect.Text;
    Qrytemp.Open;
    if (G_sProcessID ='100215') or (G_sProcessID ='100261') then begin
        if QryTemp.FieldByName('Defect_desc2').AsString <> '外觀' then
        begin
            lblMsg.Caption :='外觀和Mylar站只能刷外觀不良';
            lblMsg.Color :=clRed;
            cmbDefect.Text :='';
            exit;
        end
    end else begin
        if QryTemp.FieldByName('Defect_Code').AsString <> 'MT001' then
        begin
            lblMsg.Caption :='功能站只能刷機器不良(MT001)';
            lblMsg.Color :=clRed;
            cmbDefect.Text :='';
            exit;
        end
    end;

    if QryTemp.IsEmpty then begin
        lblMsg.Caption :='不良代碼錯誤';
        lblMsg.Color :=clRed;
        cmbDefect.Text :='';
        exit;
    end else begin
        lbl1.Caption :=  QryTemp.fieldBYname('Defect_Desc').AsString;
        lblMsg.Caption :='請掃描條碼';
        lblMsg.Color := clGreen;
        edtSN.Enabled :=true;
        edtSN.SetFocus;
        edtSN.SelectAll;
    end;
end;

end.
