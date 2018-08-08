unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, SConnect, ObjBrkr, StdCtrls, Buttons,
  ExtCtrls ,ComObj;

type
  TForm1 = class(TForm)
    SimpleObjectBroker1: TSimpleObjectBroker;
    SocketConnection1: TSocketConnection;
    QryData: TClientDataSet;
    Label1: TLabel;
    Label3: TLabel;
    edtTray1: TEdit;
    Label5: TLabel;
    edtTray2: TEdit;
    Label7: TLabel;
    edtTray3: TEdit;
    Label9: TLabel;
    edtTray4: TEdit;
    Image1: TImage;
    sbtnPrint: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure edtTray1KeyPress(Sender: TObject; var Key: Char);
    procedure edtTray2KeyPress(Sender: TObject; var Key: Char);
    procedure edtTray3KeyPress(Sender: TObject; var Key: Char);
    procedure edtTray4KeyPress(Sender: TObject; var Key: Char);
    procedure sbtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sFirstWO,sWO ,sBox,sProcess:string;
    sBox_NO :array [1..4] of string;
    BarApp,BarDoc,BarVars:variant;
    i_Count,count:integer;
    function LoadApServer: Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function TForm1.LoadApServer: Boolean;
var F: TextFile;
   S: string;
begin
   Result := False;
   SocketConnection1.Connected := False;
   SimpleObjectBroker1.Servers.Clear;
   SocketConnection1.Host:='';
   SocketConnection1.Address:='';
   if  FileExists(GetCurrentDir + '\ApServer.cfg') then
     AssignFile(F, GetCurrentDir + '\ApServer.cfg')
   else
     exit;
   Reset(F);
   while True do
   begin
      Readln(F, S);
      if trim(S) <> '' then
      begin
        SimpleObjectBroker1.Servers.Add;
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
        SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
      end else
        Break;
   end;
   CloseFile(F);
   Result := True;
end;

procedure TForm1.FormShow(Sender: TObject);
var i:integer;
    PrintFile:string;
begin
     LoadApServer;
     i_Count :=0;
     Count :=0;
     for i:=0 to 4 do begin
        sBox_NO[i] :='';
     end;
     try
        BarApp := CreateOleObject('lppx.Application');
      except
        Application.MessageBox('›]¨S¦³¦w¸Ëcodesoft³nÅé','¿ù»~',MB_OK+MB_ICONERROR);
        Exit;
     end;
     PrintFile:= GetCurrentDir+'\\ESD_DEFAULT.Lab';

     If not FileExists( PrintFile) then
     begin
         MessageDlg( 'Label ÀÉ®×¤£¦s¦b',mterror,[mbOK],0);
         Exit;
     end;

     BarApp.Visible:=false;
     BarDoc:=BarApp.ActiveDocument;
     BarVars:=BarDoc.Variables;
     BarDoc.Open(  PrintFile);
     
end;

procedure TForm1.edtTray1KeyPress(Sender: TObject; var Key: Char);
VAR i:INTEGER;
begin
    if Key <>#13 then exit;

    Count:=0;
    i_Count:=0;

    FOR I:=1 TO 4 DO BEGIN
       sBox_NO[I] :='';
    END;

    sBox_NO[1] :=edtTray1.Text;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftstring,'BOX_NO',ptInput);
    QryData.CommandText := 'Select   A.work_order, b.PROCESS_NAME ,a.boX_nO ,COUNT(*) qty  FROM SAJET.G_SN_STATUS A,SAJET.SYS_PROCESS B where '
                          +' A.WIP_PROCESS=B.PROCESS_ID AND BOX_NO = :BOX_NO GROUP BY A.WORK_ORDER,B.pROCESS_NAME,A.box_no';
    QryData.Params.ParamByName('BOX_NO').AsString := edtTray1.Text;
    QryData.Open;

    if QryData.IsEmpty then begin
        MessageDlg('NO SN',mterror,[MBOK],0);
        edtTray1.SetFocus;
        edtTray1.SelectAll;
        exit;
    end;

    if QryData.RecordCount >1 then begin
        MessageDlg('too more wo or process ',mterror,[MBOK],0);
        edtTray1.SetFocus;
        edtTray1.SelectAll;
        exit;
    end;
    
    sProcess := QryData.FieldByName('PROCESS_NAME').AsString;

    if  sProcess <> 'CM-PACK-CARTON' then begin
        MessageDlg('Router error:'+sProcess,mterror,[MBOK],0);
        edtTray1.SetFocus;
        edtTray1.SelectAll;
        exit;
    end;

    sWO :=  QryData.FieldByName('WORK_ORDER').AsString;
    sFirstWO := sWO;
    I_COUNT :=  QryData.FieldByName('QTY').AsInteger;
    count :=count+I_Count;

    edtTray2.ReadOnly :=FALSE;
    edtTray2.SetFocus;
    edtTray2.SelectAll;

end;

procedure TForm1.edtTray2KeyPress(Sender: TObject; var Key: Char);
begin
    if Key <>#13 then exit;

    sBox_NO[2] :=edtTray2.Text;

    if edtTray2.Text = edtTray1.Text then begin
       MessageDlg ('Tray No double',mterror,[mbok],0);
       edtTray2.SetFocus;
       edtTray2.SelectAll;
       exit;
    end;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftstring,'BOX_NO',ptInput);
    QryData.CommandText := 'Select  A.WORK_ORDER,  b.PROCESS_NAME ,a.boX_nO ,COUNT(*) qty  FROM SAJET.G_SN_STATUS A,SAJET.SYS_PROCESS B where '
                          +' A.WIP_PROCESS=B.PROCESS_ID AND BOX_NO = :BOX_NO GROUP BY A.WORK_ORDER,B.pROCESS_NAME,A.box_no';
    QryData.Params.ParamByName('BOX_NO').AsString := edtTray2.Text;
    QryData.Open;

    if QryData.IsEmpty then begin
        MessageDlg('NO SN',mterror,[MBOK],0);
        edtTray2.SetFocus;
        edtTray2.SelectAll;
        exit;
    end;

    if QryData.RecordCount >1 then begin
        MessageDlg('too more process',mterror,[MBOK],0);
        edtTray2.SetFocus;
        edtTray2.SelectAll;
        exit;
    end;


    sProcess := QryData.FieldByName('PROCESS_NAME').AsString;

    if  sProcess <> 'CM-PACK-CARTON' then begin
        MessageDlg('Router error:'+sProcess,mterror,[MBOK],0);
        edtTray2.SetFocus;
        edtTray2.SelectAll;
        exit;
    end;

    sWO := QryData.FieldByName('WORK_ORDER').AsString;

    if sWO <> sFirstWO then begin
        MessageDlg('WO error' ,mterror,[MBOK],0);
        edtTray2.SetFocus;
        edtTray2.SelectAll;
        exit;
    end;

    I_COUNT :=  QryData.FieldByName('QTY').AsInteger;
    count :=count+I_Count;

    edtTray3.ReadOnly :=false;
    edtTray3.SetFocus;
    edtTray3.SelectAll;

end;

procedure TForm1.edtTray3KeyPress(Sender: TObject; var Key: Char);
var i:integer ;
begin
    if Key <>#13 then exit;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftstring,'BOX_NO',ptInput);
    QryData.CommandText := 'Select   A.WORK_ORDER, b.PROCESS_NAME ,a.boX_nO ,COUNT(*) qty  FROM SAJET.G_SN_STATUS A,SAJET.SYS_PROCESS B where '
                          +' A.WIP_PROCESS=B.PROCESS_ID AND BOX_NO = :BOX_NO GROUP BY A.WORK_ORDER,B.pROCESS_NAME,A.box_no';
    QryData.Params.ParamByName('BOX_NO').AsString := edtTray3.Text;
    QryData.Open;

    if QryData.IsEmpty then begin
        MessageDlg('NO SN',mterror,[MBOK],0);
        edtTray3.SetFocus;
        edtTray3.SelectAll;
        exit;
    end;

    if QryData.RecordCount >1 then begin
        MessageDlg('too more process',mterror,[MBOK],0);
        edtTray3.SetFocus;
        edtTray3.SelectAll;
        exit;
    end;


    sProcess := QryData.FieldByName('PROCESS_NAME').AsString;

    if  sProcess <> 'CM-PACK-CARTON' then begin
        MessageDlg('Router error:'+sProcess,mterror,[MBOK],0);
        edtTray3.SetFocus;
        edtTray3.SelectAll;
        exit;
    end;

    sWO := QryData.FieldByName('WORK_ORDER').AsString;

     if sWO <> sFirstWO then begin
        MessageDlg('WO error' ,mterror,[MBOK],0);
        edtTray2.SetFocus;
        edtTray2.SelectAll;
        exit;
    end;

     for i:=1 to 2 do begin
        if sBOX_No[i] = edtTray3.Text then
        begin
           MessageDlg ('Tray No double',mterror,[mbok],0);
           edtTray3.SetFocus;
           edtTray3.SelectAll;
           exit;
       end;
    end;

    edtTray4.ReadOnly :=false;
    edtTray4.Setfocus;
    edtTray4.selectall;
    sBox_NO[3] :=edtTray3.Text;

    I_COUNT :=  QryData.FieldByName('QTY').AsInteger;
    count :=count+I_Count;


end;

procedure TForm1.edtTray4KeyPress(Sender: TObject; var Key: Char);
var i:integer;
begin
   if Key <>#13 then exit;
   sBox_NO[4] :=edtTray4.Text;

   for i:=1 to 3 do begin
        if sBOX_No[i] = edtTray4.Text then
        begin
           MessageDlg ('Tray No double',mterror,[mbok],0);
           edtTray4.SetFocus;
           edtTray4.SelectAll;
           exit;
       end;
    end;

    QryData.Close;
    QryData.Params.Clear;
    QryData.Params.CreateParam(ftstring,'BOX_NO',ptInput);
    QryData.CommandText := 'Select  A.WORK_ORDER,  b.PROCESS_NAME ,a.boX_nO ,COUNT(*) qty  FROM SAJET.G_SN_STATUS A,SAJET.SYS_PROCESS B where '
                          +' A.WIP_PROCESS=B.PROCESS_ID AND BOX_NO = :BOX_NO GROUP BY A.WORK_ORDER,B.pROCESS_NAME,A.box_no';
    QryData.Params.ParamByName('BOX_NO').AsString := edtTray4.Text;
    QryData.Open;

    if QryData.IsEmpty then begin
        MessageDlg('NO SN',mterror,[MBOK],0);
        edtTray4.SetFocus;
        edtTray4.SelectAll;
        exit;
    end;

    if QryData.RecordCount >1 then begin
        MessageDlg('too more process',mterror,[MBOK],0);
        edtTray4.SetFocus;
        edtTray4.SelectAll;
        exit;
    end;


    sProcess := QryData.FieldByName('PROCESS_NAME').AsString;

    if  sProcess <> 'CM-PACK-CARTON' then begin
        MessageDlg('Router error:'+sProcess,mterror,[MBOK],0);
        edtTray4.SetFocus;
        edtTray4.SelectAll;
        exit;
    end;

    sWO := QryData.FieldByName('WORK_ORDER').AsString;

     if sWO <> sFirstWO then begin
        MessageDlg('WO error' ,mterror,[MBOK],0);
        edtTray4.SetFocus;
        edtTray4.SelectAll;
        exit;
    end;

    I_COUNT :=  QryData.FieldByName('QTY').AsInteger;
    count :=count+I_Count;
    
    BarDoc.Variables.Item('TRAY_1').Value := edtTray1.Text;
    BarDoc.Variables.Item('TRAY_2').Value := edtTray2.Text;
    BarDoc.Variables.Item('TRAY_3').Value := edtTray3.Text;
    BarDoc.Variables.Item('TRAY_4').Value := edtTray4.Text;
    BarDoc.Variables.Item('QTY').Value := Count;
    BarDoc.Variables.Item('WO').Value := SWO;
    Bardoc.PrintLabel(1);
    Bardoc.FormFeed;


    edtTray1.Clear;
    edtTray2.Clear;
    edtTray3.Clear;
    edtTray4.Clear;

    edtTray1.ReadOnly:=false;
    edtTray2.ReadOnly:=false;
    edtTray3.ReadOnly:=false;
    edtTray4.ReadOnly:=false;
    edtTray1.SetFocus;


end;



procedure TForm1.sbtnPrintClick(Sender: TObject);
begin


    BarDoc.Variables.Item('TRAY_1').Value := SbOX_NO[1];
    BarDoc.Variables.Item('TRAY_2').Value := SbOX_NO[2];
    BarDoc.Variables.Item('TRAY_3').Value := SbOX_NO[3];
    BarDoc.Variables.Item('TRAY_4').Value := SbOX_NO[4];
    BarDoc.Variables.Item('QTY').Value := Count;
    BarDoc.Variables.Item('WO').Value := SWO;
    Bardoc.PrintLabel(1);
    Bardoc.FormFeed;
 
 
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
    Bardoc.Close;
    BarApp.Quit;
end;

end.
