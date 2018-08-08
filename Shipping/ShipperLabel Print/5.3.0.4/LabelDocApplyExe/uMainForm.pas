unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, SysTray, PBJustOne;

type
  TLabelDocApplyForm = class(TForm)
    Timer1: TTimer;
    SysTray1: TSysTray;
    PBJustOne1: TPBJustOne;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LabelDocApplyForm: TLabelDocApplyForm;

implementation

{$R *.dfm}

procedure LabelDocValueApply ;
var
  LVSetHwnd, OKHwnd : LongWord ;
  Running : Integer ;
begin
  LVSetHwnd := FindWindow('#32770','標籤設定');
  if LVSetHwnd <= 0 then
    LVSetHwnd := FindWindow('#32770','Label Setup');
  if LVSetHwnd <= 0 then Exit ;

  //MoveWindow(LVSetHwnd ,0,-100,0,0,False);
  Running := 1;
  repeat
    OKHwnd := FindWindowEx(LVSetHwnd , 0, 'Button', nil);
    if OKHwnd <= 0 then Inc(Running);
    if Running >=1000 then Break ;
  until (OKHwnd>0);
  if OKHwnd <= 0 then Exit ;

  //PostMessage(OKHwnd,   WM_SETFOCUS,0, 0);//TEXT1陂腕蝴擒
  //PostMessage(OKHwnd,   WM_KEYDOWN,   VK_RETURN,   0);//按下
  //PostMessage(OKHwnd,   WM_KEYUP  ,   VK_RETURN,   0);//?起

  PostMessage(OKHwnd ,  WM_LBUTTONDOWN, 0, 0);
  PostMessage(OKHwnd ,  WM_LBUTTONUP, 0, 0);
end;

procedure TLabelDocApplyForm.Timer1Timer(Sender: TObject);
begin
  if Self.Caption = 'START' then
    LabelDocValueApply
  else if Self.Caption = 'KILL ME' then
    self.Close ;
end;

procedure TLabelDocApplyForm.FormCreate(Sender: TObject);
var
  ParmarStr : string;
begin
  ParmarStr := ParamStr(1) ;
  if  ParmarStr <> 'LabelPrint' then
  begin
    //ShowMessage('Start parameter Error');
    MessageDlg('Start parameter Error !!',mtError ,[mbOK],0);
    Self.Close ;
    Application.Terminate ;
  end;
end;

end.
