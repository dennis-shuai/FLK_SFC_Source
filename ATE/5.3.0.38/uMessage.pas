unit uMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons;

type
  TfMessage = class(TForm)
    sbtnMsg: TSpeedButton;
    procedure sbtnMsgClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure show(tStr:string);
    procedure close;
  end;

var
  fMessage: TfMessage;

implementation

uses unitMain;

{$R *.dfm}
procedure TfMessage.show(tstr:string);
begin
 try
   if animatewindow(handle,100,aw_ver_negative)=false then
   begin
     try
       free;
     except
     end;
   end;
 except
 end;
 sbtnMsg.Caption:= tStr;
 inherited show;
end;

procedure TfMessage.Close;
begin
  try
    if animatewindow(handle,100,aw_ver_positive+aw_hide)=false then
    begin
      try
        free;
      except
      end;
    end;
  except
  end;
  inherited close;
end;

procedure TfMessage.sbtnMsgClick(Sender: TObject);
begin
  if animatewindow(handle,200,aw_ver_positive+aw_hide)=false then
  begin
    showmessage('Close Error');
    free;
  end;
  formMain.Timer2.Enabled:=false;
  inherited close;
end;

end.
