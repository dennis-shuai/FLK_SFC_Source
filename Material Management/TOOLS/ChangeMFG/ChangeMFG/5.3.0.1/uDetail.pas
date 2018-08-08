unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryMaterial: TClientDataSet;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    editID: TEdit;
    lablType: TLabel;
    Label6: TLabel;
    Image1: TImage;
    SBTCONFIRM: TSpeedButton;
    lablReel: TLabel;
    QryReel: TClientDataSet;
    DataSource3: TDataSource;
    Label2: TLabel;
    QryHT: TClientDataSet;
    Label3: TLabel;
    editFifo: TEdit;
    DateTimePicker1: TDateTimePicker;
    EDITPARTNO: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    EDITRTNO: TEdit;
    EDITQTY: TEdit;
    EDITWAREHOUSE: TEdit;
    EDITLOCATE: TEdit;
    EDITDATECODE: TEdit;
    EDITMFGNAME: TEdit;
    EDITMFGPARTNO: TEdit;
    procedure FormShow(Sender: TObject);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure editIDChange(Sender: TObject);
    procedure editIDKeyPress(Sender: TObject; var Key: Char);
    procedure SBTCONFIRMClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;
    Function GetFIFOCode(dDate:TDateTime):string;
    Function cleardate:string;
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;

Function TfDetail.GetFIFOCode(dDate:TDateTime):string;
var strDate:string;
begin
  sTrDate:=formatDateTime('YYYYMMDD',dDate);
  with sproc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_GET_fifo');
        FetchParams;
        Params.ParamByName('TDATE').AsString := sTrDate;
        Execute;
        IF Params.ParamByName('TRES').AsString='OK' THEN
          RESULT:=Params.ParamByName('FIFOCODE').AsString
        else
          Showmessage(Params.ParamByName('TRES').AsString);
      finally
        close;
      end;
    end;
end;

Function TfDetail.cleardate :string;
begin
  editpartno.Clear ;
  editrtno.Clear ;
  editqty.Clear ;
  editwarehouse.Clear ;
  editlocate.Clear ;
  editdatecode.Clear ;
  editmfgname.Clear ;
  editmfgpartno.Clear ;
  DateTimePicker1.DateTime:=now();
  editFifo.Text := GetFIFOCode(now());
end;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
 // editid.SetFocus;
  editid.Clear ;
  editid.SelectAll ;
  editid.SetFocus ;
  cleardate;
  with QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
    Params.CreateParam(ftString, 'dll_name', ptInput);
    CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
      + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
      + 'and upper(dll_filename) = :dll_name and rownum = 1 ';
    Params.ParamByName('EXE_FILENAME').AsString := UpperCase(ChangeFileExt(ExtractFileName(Application.ExeName), ''));
    Params.ParamByName('dll_name').AsString := 'CHANGEMFGDLL.DLL';
    Open;
  //DateTimePicker1.DateTime:=now();
 // editFifo.Text := GetFIFOCode(now());
  end;
end;

{procedure TfDetail.SpeedButton1Click(Sender: TObject);
var i: Integer; sReel, sPrintData: string;
begin
  if not assigned(G_onTransDataToApplication) then
  begin
    showmessage('Not Defined Call Back Function for Code Soft');
    Exit;
  end;
  with QryReel do
  begin
    while not Eof do
    begin
      sReel := FieldByName('reel_no').AsString;
      sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', 'Reel ID*&*' + sReel, 1, '');
      G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
      Next;
    end;
    First;
  end;
end; }


procedure TfDetail.DateTimePicker1Change(Sender: TObject);
begin
    editFifo.Text := GetFIFOCode(DateTimePicker1.Date);
end;

procedure TfDetail.editIDChange(Sender: TObject);
begin
   cleardate;
end;

procedure TfDetail.editIDKeyPress(Sender: TObject; var Key: Char);
VAR RESULT: STRING;
begin
   IF trim(editid.Text)='' then exit;
   if Ord(Key) = vk_Return then
      begin
         with QryMaterial do
           begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'id_no', ptInput);
              CommandText := 'SELECT NVL(B.RT_NO,''N/A'') AS Rt_NO,C.PART_NO,A.DATECODE,A.MATERIAL_NO,A.MATERIAL_QTY,NVL(A.REEL_NO,''N/A'') AS REEL_NO,  '
                +  'A.REEL_QTY,D.WAREHOUSE_NAME,e.locate_name,NVL(A.REMARK,''N/A'') AS REMARK,A.MFGER_NAME,A.MFGER_PART_NO,A.TYPE,A.FIFOCODE,  '
                +  'NVL(C.OPTION13,''N'') AS INDATEFLAG ,NVL(C.OPTION14,''0'') AS INDATECODE '
                +  'FROM sajet.G_MATERIAL A,sajet.G_ERP_RTNO B,sajet.SYS_PART C,sajet.SYS_WAREHOUSE D,sajet.sys_locate e '
                + ' WHERE  A.RT_ID=B.RT_ID(+) AND A.PART_ID=C.PART_ID AND A.WAREHOUSE_ID=D.WAREHOUSE_ID(+)  '
                +  ' and a.locate_id=e.locate_id(+) ' ;
              if UPPERCASE(copy(editid.Text ,1,1))='R' then
                 commandtext:=commandtext +' and reel_no=:id_no and rownum=1 '
              else
                 commandtext:=commandtext +' and material_no=:id_no and rownum=1 ';

              Params.ParamByName('id_no').AsString := editid.Text;
              Open;

              if IsEmpty then
                 begin
                    MessageDlg('Material NO not found.', mtError, [mbOK], 0);
                    IF sbtconfirm.Enabled =true then
                       sbtconfirm.Enabled :=false;
                    EDITID.SelectAll ;
                    EDITID.SetFocus ;
                    Exit;
                 end
             {
              else if fieldbyname('warehouse_NAme').AsString='' then
                 begin
                    MessageDlg('Material NO Not Incoming.', mtError, [mbOK], 0);
                    IF sbtconfirm.Enabled =true then
                       sbtconfirm.Enabled :=false;
                    EDITID.SelectAll ;
                    EDITID.SetFocus ;
                    Exit;
              end
              }
              else if fieldbyname('type').AsString='O' then
                begin
                  MessageDlg('Transfer UnComfirm OR HAD SHIPPING PACK', mtError, [mbOK], 0);
                  IF sbtconfirm.Enabled =true then
                       sbtconfirm.Enabled :=false;
                  EDITID.SelectAll ;
                  EDITID.SetFocus ;
                  Exit;
                end
             else if fieldbyname('REEL_NO').AsString<>'N/A'  then
                begin
                 IF uppercase(COPY(EDITID.Text,1,1))<>'R' Then
                  begin
                     MessageDlg('MATERIAL NO ERROR! - HAVE REEL', mtError, [mbOK], 0);
                     IF sbtconfirm.Enabled =true then
                       sbtconfirm.Enabled :=false;
                     EDITID.SelectAll ;
                     EDITID.SetFocus ;
                     Exit;
                  end;
               end
             else if fieldbyname('INDATEFLAG').AsString='Y' THEN
               BEGIN
                IF  fieldbyname('INDATECODE').AsString <> '0'  THEN
                 begin
                   IF STRTOINT(GetFIFOCode(now()))- fieldbyname('FIFOCODE').AsInteger >= fieldbyname('INDATECODE').AsInteger then
                     begin
                       MessageDlg('OUT OF INDATE!', mtError, [mbOK], 0);
                       IF sbtconfirm.Enabled =true then
                           sbtconfirm.Enabled :=false;
                       EDITID.SelectAll ;
                       EDITID.SetFocus ;
                       Exit;
                     end;
                 end;
                END;

               IF  fieldbyname('RT_NO').AsString<>'N/A' THEN
                   EDITRTNO.Text :=fieldbyname('RT_NO').AsString
               ELSE IF   fieldbyname('REMARK').AsString<>'N/A'THEN
                   EDITRTNO.Text := fieldbyname('REMARK').AsString
               ELSE
                   EDITRTNO.Text :='';
               EDITPARTNO.Text:=fieldbyname('PART_NO').AsString;
               IF UPPERCASE(COPY(EDITID.Text,1,1))='R' THEN
                  EDITQTY.Text :=fieldbyname('REEL_QTY').AsString
               ELSE
                  EDITQTY.Text :=fieldbyname('MATERIAL_QTY').AsString;
               EDITWAREHOUSE.Text :=fieldbyname('WAREHOUSE_NAME').AsString;
               EDITLOCATE.Text  :=fieldbyname('LOCATE_NAME').AsString;
               EDITDATECODE.Text  :=fieldbyname('DATECODE').AsString;
               EDITMFGNAME.Text  :=fieldbyname('MFGER_NAME').AsString;
               EDITMFGPARTNO.Text   :=fieldbyname('MFGER_PART_NO').AsString;
               EDITFIFO.Text :=fieldbyname('FIFOCODE').AsString;

               editid.SelectAll ;
               editid.SetFocus ;
               sbtconfirm.Enabled :=true;
           end;
      end;
end;

procedure TfDetail.SBTCONFIRMClick(Sender: TObject);
begin
IF trim(editdatecode.Text)='' then
   begin
      MessageDlg('Please Input DateCode', mtError, [mbOK], 0);
      editdatecode.SelectAll ;
      editdatecode.SetFocus ;
      exit;
   end;
IF trim(editmfgname.Text)='' then
   begin
      MessageDlg('Please Input MFGER NAME', mtError, [mbOK], 0);
      editMFGNAME.SelectAll ;
      editmfgname.SetFocus ;
      exit;
   end;
IF trim(editmfgpartno.Text)='' then
   begin
      MessageDlg('Please Input MFGER Part_NO', mtError, [mbOK], 0);
      editmfgpartno.SelectAll ;
      editmfgpartno.SetFocus ;
      exit;
   end;

if MessageDlg('Change MFG OR DataCode ,Are you Sure?', mtCustom, mbOKCancel, 0) = mrOK then
   BEGIN
     with QryMaterial do
          begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString, 'update_userid', ptInput);
              Params.CreateParam(ftString, 'datecode', ptInput);
              Params.CreateParam(ftString, 'mfger_name', ptInput);
              Params.CreateParam(ftString, 'mfger_part_no', ptInput);
              Params.CreateParam(ftString, 'id_no', ptInput);
              CommandText := 'update  sajet.g_material '
                    +' set update_time=sysdate,update_userid=:update_userid,datecode=:datecode,mfger_name=:mfger_name,mfger_part_no=:mfger_part_no ' ;

              if UPPERCASE(copy(editid.Text ,1,1))='R' then
                 commandtext:=commandtext +' where reel_no=:id_no and rownum=1 '
              else
                 commandtext:=commandtext +' where material_no=:id_no and rownum=1 ';

              Params.ParamByName('update_userid').AsString := UpdateUserID;
              Params.ParamByName('datecode').AsString := editdatecode.Text ;
              Params.ParamByName('mfger_name').AsString := editmfgname.Text ;
              Params.ParamByName('mfger_part_no').AsString := editmfgpartno.Text;
              Params.ParamByName('id_no').AsString := editid.Text;
              execute;

              close;
              Params.Clear;
              Params.CreateParam(ftString, 'id_no', ptInput);
              CommandText := 'insert into sajet.g_ht_material(select * from sajet.g_material ';

              if UPPERCASE(copy(editid.Text ,1,1))='R' then
                 commandtext:=commandtext +' where reel_no=:id_no and rownum=1) '
              else
                 commandtext:=commandtext +' where material_no=:id_no and rownum=1) ';

              Params.ParamByName('id_no').AsString := editid.Text;
              execute;

              showmessage('MFG OR DataCode UPDATE OK!');
              sbtconfirm.Enabled:=true;
              editid.SelectAll ;
              editid.SetFocus ;

         end;

   END;
end;

end.

