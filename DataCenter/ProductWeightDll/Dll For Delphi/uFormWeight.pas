unit uFormWeight;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, ActiveX, ExtCtrls, StdCtrls, Buttons, OleCtrls, MSCommLib_TLB;   //ShareMem,

  procedure Delay(msecs:integer);

type
  TWeightForm = class(TForm)
    lblReadKG: TLabel;
    lblInfomation: TLabel;
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    EditUpLimit: TEdit;
    EditLowLimit: TEdit;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Timer1: TTimer;
    MSComPort: TMSComm;
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn2Click(Sender: TObject);
    procedure MSComPortComm(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Runing : Boolean ;

  public
    { Public declarations }
    procedure SendWeightComand ;

  end;

var
  WeightForm: TWeightForm;

implementation

uses DllInit;

{$R *.dfm}

procedure TWeightForm.SendWeightComand ;
var
  //mByteAry: array of byte;
  mByteAry:Variant;
  i : Integer ;
begin
  //SetLength(mByteAry,2);
  mByteAry := VarArrayCreate([0,2], varByte );
  mByteAry[0] := $01;
  mByteAry[1] := $73;
  MSComPort.Output := mByteAry ;

  i := 0;
  repeat
    Application.ProcessMessages;
    i := i + 1;
    If i > 30000 Then
    begin
      lblReadKG.Caption := '�q�H����';
      lblInfomation.Caption := 'FAIL';
      lblInfomation.Color := clRed ;
      break;
    end;
  Until MSComPort.InBufferCount=8;
end;

procedure Delay(msecs:integer);
var
  FirstTickCount:longint;
begin
  FirstTickCount:=GetTickCount;
  repeat
    Application.ProcessMessages;     //���t�Υi�H�B�z�O���ƥ�
  until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end ;

procedure TWeightForm.FormPaint(Sender: TObject);
var
    DC : HDC  ;
    Pen : HPEN ;
    OldPen : HPEN ;
    OldBrush : HBRUSH ;
begin
    Canvas.Pen.Color := clBlue ;
    Canvas.Brush.Color := clBlue ;
    DC := GetWindowDC(Handle);
    Pen := CreatePen(PS_SOLID, 1, clGray);
    OldPen := SelectObject(DC, Pen); //���J�۩w�q���e��,�O�s��e��
    OldBrush := SelectObject(DC, GetStockObject(NULL_BRUSH));//���J�ŵe��,�O�s��e��
    //RoundRect(DC, 0, 0, Width-1, Height-1,21,21); //�e���
    RoundRect(DC, 0, 0, Width-1, Height-1,0,0); //�e���
    SelectObject(DC,OldBrush);//���J��e��
    SelectObject(DC,OldPen); // ���J��e��
    DeleteObject(Pen);
    ReleaseDC(Handle, DC);
end;

procedure TWeightForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Action = caFree;
  //Timer1.Enabled := False ;
  //MSComPort.PortOpen := False ;  //����COM�f
  //WeightResult := Trim(lblReadKG.Caption) ;
end;

procedure TWeightForm.BitBtn2Click(Sender: TObject);
begin
  SendWeightComand ;
end;

procedure TWeightForm.MSComPortComm(Sender: TObject);
var
  str : string;     //�n���@��AnsiString�������ܶq
  Buffer : Variant ;     //�n���@�ӥΩ󱵦��ƾڪ�OleVariant�ܶq�C
  KG , TempStr : string  ;
begin
    KG := '';
    TempStr := '';
    // �����w�İϤ��O�_����Rthreshold�Ӧr�šC
    if(MSComPort.CommEvent = comEvReceive) then
    begin
        //if Boolean(MSComPort.InBufferCount) then // �O�_���r�žn�d�b�����w�İϵ��ݳQ���X
        if  MSComPort.InBufferCount = 13 then
        begin
            Buffer := MSComPort.Input;//�����ƾ�
            //str := s.AsType(varString);   //�Ⱶ���쪺OleVariant�ܶq�ഫ��AnsiString����
            //***********---------------------
            Str := Buffer ;
            lblReadKG.Caption := Trim(str) ;
            TempStr := lblReadKG.Caption ;
            if Pos('����',TempStr) >0 then
            begin
                lblInfomation.Caption := 'FAIL';
                lblInfomation.Color := clRed ;
                Exit ;
            end;

            {if Copy(TempStr,1,1) = '-' then
              KG := Copy(TempStr,1,Length(TempStr)-1)
            else
              KG := Copy(TempStr,1,Length(TempStr)-1) ;}

            KG := Copy(TempStr,1,Length(TempStr)-1) ;
            if (StrToFloat(KG)>= Low_Limit) and (StrToFloat(KG)<=Up_Limit) then
            begin
                //�X��
                lblInfomation.Caption := 'PASS';
                lblInfomation.Color := clGreen ;
            end else
            begin
              lblInfomation.Caption := 'FAIL';
              lblInfomation.Color := clRed ;
            end;
        end;
    end;
end;

procedure TWeightForm.Timer1Timer(Sender: TObject);
begin
  if not Runing then
  begin
    Runing := true ;
    SendWeightComand ;
    Delay(20);
    Runing := false ;
  end;
end;

procedure TWeightForm.BitBtn1Click(Sender: TObject);
begin
  Close ;
end;

procedure TWeightForm.FormShow(Sender: TObject);
begin
    Self.Left :=Round((Screen.Width -Self.Width)/2);
    Self.Top :=Round((Screen.Height-Self.Height)/2);

    lblReadKG.Caption := '0000.00g';
    lblInfomation.Caption := 'Ready';
    lblInfomation.Color := clGreen ;
    Runing := false ;
    if Weight_Model = 'BH-600' then
    begin
        Button1.Enabled := false;
        BitBtn2.Enabled := false;
    end else
    begin
        Button1.Enabled := true;
        BitBtn2.Enabled := true;
        if not MSComPort.PortOpen then MSComPort.PortOpen := True ;
        SendWeightComand;
        Delay(100);
        Exit ; 
    end;

    if lblReadKG.Caption= '�q�H����' then
    begin
        lblInfomation.Caption := 'FAIL';
        lblInfomation.Color := clRed ;
        Exit ;
    end else if lblReadKG.Caption ='���q����' then
    begin
        lblInfomation.Caption := 'FAIL';
        lblInfomation.Color := clRed ;
    end;
end;

procedure TWeightForm.Button1Click(Sender: TObject);
begin
    if Weight_Model <> 'BH-600' then
      Timer1.Enabled := not Timer1.Enabled  ;
end;

procedure TWeightForm.FormCreate(Sender: TObject);
  procedure HideTaskTitle(Handle :THandle );
  var
    ExTaskTitle : DWORD ;
  begin
    ExTaskTitle := GetWindowLong(Handle ,GWL_EXSTYLE);
    ExTaskTitle := ExTaskTitle + WS_EX_TOOLWINDOW ;
    SetWindowLong(Handle ,GWL_EXSTYLE ,ExTaskTitle);
  end;
begin
  SetWindowPos(Handle ,HWND_TOPMOST ,0 ,0 ,0 ,0 , SWP_NOMOVE or SWP_NOSIZE);
end;

{initialization
  CoInitialize(nil);

finalization
  CoUninitialize ;}

end.
