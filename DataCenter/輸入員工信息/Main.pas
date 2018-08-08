unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DB, DBClient, MConnect, SConnect, ObjBrkr;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    SProc: TClientDataSet;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    Label2: TLabel;
    Memo1: TMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function LoadApServer : Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
VAR pstring:TStringList;
    strs:string;
    i:integer;
    ss:TStringList;
begin
   if  Edit1.Text ='' then exit;
   pstring := TStringList.Create;

   pstring.LoadFromFile(Edit1.Text);

   for I:=1 to  pstring.Count-1 do begin
      ss := TStringList.Create;
      ExtractStrings([','],[' '], PChar(pstring.Strings[i]),ss);
      Sproc.Close;
      Sproc.DataRequest('SAJET.INSERT_EMP_RADONPWD');
      Sproc.FetchParams;
      Sproc.Params.ParamByName('TEMP_NO').AsString := ss.Strings[0];
      Sproc.Params.ParamByName('TEMP_NAME').AsString := ss.Strings[1];
      Sproc.Params.ParamByName('TEMP_DEPT').AsString := ss.Strings[2];
      Sproc.Params.ParamByName('TEMP_PWD').AsString := ss.Strings[3];
      Sproc.Execute;
      Memo1.lines.Add(ss.Strings[0]+','+ss.Strings[1] +':' +Sproc.Params.parambyname('TRES').AsString) ;
      ss.Free;
   end;
   Label2.Caption := 'OK';
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
VAR pstring:TStringList;
    strs:string;
    i:integer;
    ss:TStringList;
begin
   if  Edit1.Text ='' then exit;
   pstring := TStringList.Create;

   pstring.LoadFromFile(Edit1.Text);

   for I:=1 to  pstring.Count-1 do begin
      ss := TStringList.Create;
      ExtractStrings([','],[' '], PChar(pstring.Strings[i]),ss);
      Sproc.Close;
      Sproc.DataRequest('SAJET.UPDATE_EMP_RADONPWD');
      Sproc.FetchParams;
      Sproc.Params.ParamByName('TEMP_NO').AsString := ss.Strings[0];
      Sproc.Params.ParamByName('TEMP_NAME').AsString := ss.Strings[1];
      Sproc.Params.ParamByName('TEMP_DEPT').AsString := ss.Strings[2];
      Sproc.Params.ParamByName('TEMP_PWD').AsString := ss.Strings[3];
      Sproc.Execute;
      Memo1.lines.Add(ss.Strings[0]+','+ss.Strings[1] +':' +Sproc.Params.parambyname('TRES').AsString) ;
      ss.Free;
   end;
   Label2.Caption := 'OK';
end;

function TForm1.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
   if OpenDialog1.Execute then
      Edit1.Text := OpenDialog1.FileName;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   loadApServer();
end;

end.
