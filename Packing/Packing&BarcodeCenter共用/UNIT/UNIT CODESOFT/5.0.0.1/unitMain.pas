unit unitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,unitCodeSoft, StdCtrls, Buttons ,FileCtrl,LabelManager2_TLB,
  ExtCtrls;

type
  TForm1 = class(TForm)
    bbtnLink: TButton;
    bbtnVisible: TButton;
    bbtnOpen: TButton;
    editFilePath: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Button4: TButton;
    Edit1: TEdit;
    SpeedButton2: TSpeedButton;
    Edit2: TEdit;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bbtnLinkClick(Sender: TObject);
    procedure bbtnVisibleClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure bbtnOpenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
    m_CodeSoft : TCodeSoft;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.FormCreate(Sender: TObject);
begin
  m_CodeSoft:=TCodeSoft.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  m_CodeSoft.free;
end;

procedure TForm1.bbtnLinkClick(Sender: TObject);
begin
  m_CodeSoft.Linked:=not m_CodeSoft.Linked;
  if m_CodeSoft.Linked then bbtnLink.Caption:='CS LINK'
  else bbtnLink.Caption:='CS NOT LINK';
  if m_CodeSoft.Visibled then bbtnVisible.Caption:='CS Visible'
  else bbtnVisible.Caption:='CS NOT Visible';
end;

procedure TForm1.bbtnVisibleClick(Sender: TObject);
begin
  m_CodeSoft.Visibled:=not m_CodeSoft.Visibled;
  if m_CodeSoft.Visibled then bbtnVisible.Caption:='CS Visible'
  else bbtnVisible.Caption:='CS NOT Visible';
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog1.Filter := 'Label files (*.LAB)|*.LAB';
  if not OpenDialog1.Execute then exit;
  editFilePath.Text:=OpenDialog1.FileName;
end;

procedure TForm1.bbtnOpenClick(Sender: TObject);
var sSampleFile,sMessage : string;
begin
  if not m_CodeSoft.SelectSampleFile(sSampleFile,sMessage) then showmessage(sMessage)
  else editFilePath.Text:=sSampleFile;
end;

procedure TForm1.Button1Click(Sender: TObject);
var sMessage : string;
begin
  if not m_CodeSoft.openSampleFile(editFilePath.Text,sMessage) then showmessage(sMessage);
end;

procedure TForm1.Button2Click(Sender: TObject);
var sMessage : string;
begin
  if not m_CodeSoft.openSampleFile('',sMessage) then showmessage(sMessage);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  showmessage(m_CodeSoft.getSampleFile);
end;

procedure TForm1.Button4Click(Sender: TObject);
var tsTemp : tstrings;
    sMessage : string;
    i : integer;
begin
  tsTemp:=TStringList.create;
  try
    if not m_CodeSoft.getParameter(tsTemp,sMessage) then begin
      showmessage(sMessage);
      exit;
    end;

    ListBox1.Clear;
    ListBox2.Clear;
    for i := 1 to tsTemp.count do ListBox1.Items.Add(tsTemp[i-1]);
  finally
    tsTemp.free;
  end;

end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  if Edit1.Text<>'' then ListBox1.Items.Add(Edit1.Text)
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  if Edit2.Text<>'' then ListBox2.Items.Add(Edit2.Text)
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  ListBox1.Clear;
  ListBox2.Clear;
end;

procedure TForm1.Button5Click(Sender: TObject);
var sMessage : string;
begin
  if not  m_CodeSoft.selectPrinter(sMessage) then showmessage(sMessage);
end;

procedure TForm1.Button6Click(Sender: TObject);
var sMessage : string;
begin
  if not  m_CodeSoft.setupPrinter(sMessage) then showmessage(sMessage);
end;

procedure TForm1.Button7Click(Sender: TObject);
var i : integer;
begin
  if ListBox1.Items.Count<>ListBox2.Items.Count then showmessage('Count Not Match');
  for i:=1 to ListBox1.Items.Count do m_CodeSoft.assignPrintData(ListBox1.Items[i-1],ListBox2.Items[i-1]);
  m_CodeSoft.print(1);
end;

procedure TForm1.Button8Click(Sender: TObject);
var sMessage : string;
    CS6 :TCS_6;
begin
  cs6:=TCS_6.Create(self);
  with Cs6 do begin
    try
      Locked:=true;                 //設定不讓user修改
      AutoQuit:=true;
      Visible:=true;
      Documents.Open('C:\Documents and Settings\Administrator\My Documents\我已接收的檔案\P_DEFAULT.Lab',true);

      CS6.ActiveDocument.PrintDocument(1);
      showmessage('');

    finally
      free;
    end;
  end;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  case RadioGroup1.ItemIndex of
    0 : m_CodeSoft.Version:=CS6;
    1 : m_CodeSoft.Version:=CS5;
  end;  
end;

end.
