unit uLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin, jpeg, ExtCtrls, Grids, Menus,IniFiles;

type
  TformLine = class(TForm)
    Label1: TLabel;
    combLine: TComboBox;
    Label2: TLabel;
    seditChange: TSpinEdit;
    Label3: TLabel;
    seditRefresh: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    ImageData: TImage;
    StringGrid1: TStringGrid;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    bbtnOK: TSpeedButton;
    Image3: TImage;
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    SpeedButton2: TSpeedButton;
    Image2: TImage;
    combProcessName: TComboBox;
    procedure bbtnCancelClick(Sender: TObject);
    procedure bbtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
    FieldsRow: Integer;
  public
    { Public declarations }
  end;

var
  formLine: TformLine;

implementation

uses MainForm;

{$R *.dfm}

procedure TformLine.bbtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TformLine.bbtnOKClick(Sender: TObject);
Var i : Integer;
  fInI: TIniFile;
begin
    if not (DirectoryExists(ExtractFilePath(Application.ExeName)+'\InI')) then
      ForceDirectories(ExtractFilePath(Application.ExeName)+'\InI');

    fInI:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\InI\SAJETMonitor.ini');
    fInI.EraseSection('Monitor Chosen Pdline Name');

    if (StringGrid1.RowCount>1) and (StringGrid1.Cells[1,1]<>'') then
    begin
      uMainForm.sPDLine := ''''+ StringGrid1.Cells[1,1]+'''';
      fInI.WriteString('Monitor Chosen Pdline Name', 'Pdline_1',StringGrid1.Cells[1,1]);
      for i:=2 to  StringGrid1.RowCount-1  do
      begin
         uMainForm.sPDLine := uMainForm.sPDLine +','''+  StringGrid1.Cells[1,i] +'''';
         fInI.WriteString('Monitor Chosen Pdline Name', 'Pdline_' + IntToStr(i),StringGrid1.Cells[1,i]);
      end;

      fInI.WriteString('Monitor Chosen Pdline Name', 'Count' ,IntToStr(StringGrid1.RowCount-1));
      uMainForm.Timer1.Interval := 60000 * seditRefresh.Value;
      uMainForm.Timer2.Interval := 1000 * seditChange.Value;
      fIni.Free;
      ModalResult := mrOK;
    end;
end;

procedure TformLine.FormShow(Sender: TObject);
Var i ,j,k,count: Integer;
    fInI: TIniFile;
begin

      with uMainForm.csFTemp do
      begin
        close;
        params.Clear;
        CommandText := 'SELECT A.PDLINE_ID, B.PDLINE_NAME,C.PROCESS_NAME,A.PROCESS_ID,D.SHIFT_ID '
                     + 'FROM   SAJET.SYS_PDLINE_MONITOR_BASE A, SAJET.SYS_PDLINE B,SAJET.SYS_PROCESS C ,SAJET.SYS_PDLINE_SHIFT_BASE D '
                     + 'WHERE  A.PDLINE_ID=B.PDLINE_ID AND A.PROCESS_ID=C.PROCESS_ID AND A.PDLINE_ID=D.PDLINE_ID AND D.ACTIVE_FLAG=''Y'' ORDER BY PDLINE_NAME ';
        Open;
        First;
        count := RecordCount;
        while not Eof do
        begin
           combLine.Items.Add(FieldByName('PDLINE_NAME').AsString);
           combProcessNAME.Items.Add(FieldByName('PROCESS_NAME').AsString);
           Next;
        end;
        Close ;
      end;

      StringGrid1.Cells[0,0]:='No.';
      StringGrid1.Cells[1,0]:='PDLine Name';
      StringGrid1.Cells[2,0]:='Process Name';
      fInI:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\InI\SAJETMonitor.ini');
      j:=StrToInt(fInI.ReadString('Monitor Chosen Pdline Name', 'Count', '0'));
      StringGrid1.RowCount :=j+1;
      for i:=1 to j do begin
      begin
           StringGrid1.Cells[0,i]:= IntToStr(i);
           StringGrid1.Cells[1,i]:= fInI.ReadString('Monitor Chosen Pdline Name', 'PDLINE_'+intToStr(i), '0');
           for k:=0 to count-1 do
               if   StringGrid1.Cells[1,i] = combLine.Items.Strings[k] then
                   StringGrid1.Cells[2,i]:= combProcessNAME.Items.Strings[k];
           end;

       end;
       fInI.Free;
      
end;


procedure TformLine.BitBtn1Click(Sender: TObject);
Var i : Integer;
begin
  if Trim(combLine.Text)='' then exit;
  for i:=1 to StringGrid1.RowCount-1 do
  begin
    if (combLine.Items.Strings[combLine.ItemIndex]=StringGrid1.Cells[1,i])
       and (combProcessName.Items.Strings[combLine.ItemIndex]=StringGrid1.Cells[2,i]) then
    begin
      MessageDlg('Duplicate',mtError, [mbOK],0);
      exit;
    end;
  end;
  if (StringGrid1.RowCount=2) and (StringGrid1.Cells[0,1]='')  then
  begin
    StringGrid1.Cells[0,1]:='1';
    StringGrid1.Cells[1,1]:=combLine.Items.Strings[combLine.ItemIndex];
    StringGrid1.Cells[2,1]:=combProcessName.Items.Strings[combLine.ItemIndex];
  end else
  begin
    StringGrid1.RowCount:=StringGrid1.RowCount+1;
    StringGrid1.Cells[0,StringGrid1.RowCount-1]:=IntToStr(StringGrid1.RowCount-1);
    StringGrid1.Cells[1,StringGrid1.RowCount-1]:=combLine.Items.Strings[combLine.ItemIndex];
    StringGrid1.Cells[2,StringGrid1.RowCount-1]:=combProcessName.Items.Strings[combLine.ItemIndex];
    StringGrid1.Row:=StringGrid1.RowCount-1;
  end;
end;

procedure TformLine.Delete1Click(Sender: TObject);
Var i : Integer;
begin
  if (StringGrid1.RowCount=2) then
  begin
    StringGrid1.Cells[0,1]:= '';
    StringGrid1.Cells[1,1]:= '';
    StringGrid1.Cells[2,1]:= '';
  end
  else begin
    for i:=FieldsRow to StringGrid1.RowCount-1 do
    begin
      StringGrid1.Cells[0,i]:= inttostr(i);
      StringGrid1.Cells[1,i]:= StringGrid1.Cells[1,i+1];
      StringGrid1.Cells[2,i]:= StringGrid1.Cells[2,i+1];

    end;
    StringGrid1.RowCount:=StringGrid1.RowCount-1;
  end;
end;

procedure TformLine.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    FieldsRow:=ARow;
end;

end.
