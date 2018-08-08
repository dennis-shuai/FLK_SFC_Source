unit TestProg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ExtCtrls;

type
  TForm1 = class(TForm)
    Connect: TButton;
    btn1: TButton;
    btn2: TButton;
    shp1: TShape;
    shp2: TShape;
    btn3: TButton;
    shp3: TShape;
    lbl1: TLabel;
    edtModel: TEdit;
    edtPath: TEdit;
    Model: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    edtSN: TEdit;
    procedure ConnectClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IsConnect:Boolean;
  end;

  //function ConnectServer:PChar; stdcall; external 'TestDataUploaddll.dll';
  //function UploadDataOnly(Model,Path,SN:PChar): PChar; stdcall;external 'TestDataUploaddll.dll';
  function ConnAndUploadData(Model,Path,SN,Msg,ilen:Pointer): Boolean; stdcall;external 'TestDataUploaddll.dll';

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ConnectClick(Sender: TObject);
var sresult:string;
begin
      //
  { sresult := ConnectServer;
   if Copy(sresult,1,2) <> 'OK' then
   begin
       IsConnect :=False;
       shp1.Brush.Color :=clRed;
       MessageDlg( sresult,mtError,[mbOK],0);

   end
   else
   begin
       IsConnect :=True;
       shp1.Brush.Color :=clgreen;
       MessageDlg( sresult,mtInformation,[mbOK],0);
   end;
   }

end;

procedure TForm1.btn1Click(Sender: TObject);
var model,path,sn:PChar;
sresult :string;
begin
//
{
   if IsConnect then
   begin
       Model :='FH50AF-429H';
       path := 'F:\Delphi\SFC Source Code\ICT\TestDataUpload\TestProgram\';
       sn :=PChar(edtSN.text);
       sresult := UploadDataOnly(model,path,sn);
       MessageDlg(sresult,mtInformation,[mbOK],0);
        if Copy(sresult,1,2) <> 'OK' then
       begin
           shp2.Brush.Color :=clRed;
       end
       else
       begin
           shp2.Brush.Color :=clgreen;
       end;
   end
   else
      MessageDlg('沒有連接到數據庫',mtInformation,[mbOK],0);
      }

end;

procedure TForm1.btn2Click(Sender: TObject);
begin

   {IsConnect := CloseConnect;
   MessageDlg(BoolToStr(IsConnect),mtInformation,[mbOK],0);  }

end;

procedure TForm1.btn3Click(Sender: TObject);
var  Model,Path,sn:PChar;
starttime,endtime:TDateTime;
Msg:string;
ilen:Integer;
bResult:Boolean;
begin

   Model := @(edtModel.text)[1];
   path :=  @(edtPath.text)[1];
   sn :=  @(edtSN.Text)[1];
   starttime := Now;
   ilen :=100;
   SetLength(Msg,ilen);
   bResult := ConnAndUploadData(model,path,sn,@Msg[1],@ilen);
   endtime := Now;

   //lbl1.Caption := FloatToStr(Round((endtime-starttime)*24*60*60*1000))+'ms';
   if not bResult then begin
        SetLength(Msg,ilen);
        MessageDlg(Msg,mtInformation,[mbOK],0);
        shp3.Brush.Color :=clRed;
   end else
        shp3.Brush.Color :=clGreen;
   
end;

end.
