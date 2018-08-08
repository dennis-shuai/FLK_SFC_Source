unit uFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TFormMain = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}
//按類名和Caption找到窗品名柄
function FindWidowByClassAndName(WinCls: String; WinName: String): Longint;
var
  winHandle1: Longint;
  clsna: array[0..254] of char;
  objtext: array[0..254] of char;
  cn,ot: string;
begin
  winHandle1 := GetTopWindow(0);
  while (winHandle1>0) do
  begin
    ZeroMemory(@clsna,255);
    ZeroMemory(@objtext,255);
    GetClassName(winHandle1,clsna,255);
    GetWindowText(winHandle1,objtext,255);
    cn := clsna;
    ot := objtext;
    cn := Trim(cn);
    ot := Trim(ot);
    if (copy(cn,1,Length(WinCls))=WinCls) and (copy(ot,1,Length(WinName))=WinName) then
    //if (copy(cn,1,Length(WinCls))=WinCls) and (Pos(WinName,ot)>0) then
    begin
      break;
    end
    else
    begin
      winHandle1 := GetNextWindow(winHandle1,GW_HWNDNEXT);
    end;
  end;
  Result := winHandle1;
end;

procedure LabelDocValueApply ;
var
  LVSetHwnd, OKHwnd : LongWord ;
  Running : Integer ;
begin
  //Running := 1; LVSetHwnd := 0 ;
  {repeat
    LVSetHwnd := FindWindow('#32770','標籤設定');
    if LVSetHwnd <= 0 then
      LVSetHwnd := FindWindow('#32770','Label Setup');
    if LVSetHwnd <= 0 then Inc(Running);
    if Running >=1000 then
    begin
      ShowMessage('Can not found LabelView Application!');
      Break ;
    end;
  until (LVSetHwnd > 0 ) ;}
  LVSetHwnd := FindWindow('#32770','標籤設定');
  if LVSetHwnd <= 0 then
    LVSetHwnd := FindWindow('#32770','Label Setup');
  if LVSetHwnd <= 0 then Exit ;

  MoveWindow(LVSetHwnd ,0,-100,0,0,False);
  Running := 1;
  repeat
    OKHwnd := FindWindowEx(LVSetHwnd , 0, 'Button', nil);
    if OKHwnd <= 0 then Inc(Running);
    if Running >=1000 then
    begin
      //ShowMessage('Can not found LabelView Application!');
      Break ;
    end;
  until (OKHwnd>0);
  if OKHwnd <= 0 then Exit ;

  //PostMessage(OKHwnd,   WM_SETFOCUS,0, 0);//TEXT1陂腕蝴擒
  //PostMessage(OKHwnd,   WM_KEYDOWN,   VK_RETURN,   0);//按下
  //PostMessage(OKHwnd,   WM_KEYUP  ,   VK_RETURN,   0);//?起

  PostMessage(OKHwnd ,  WM_LBUTTONDOWN, 0, 0);
  PostMessage(OKHwnd ,  WM_LBUTTONUP, 0, 0);
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  LabelDocValueApply;
end;

end.
