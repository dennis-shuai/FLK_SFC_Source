unit uDetail;

 
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles,unitCSPrintData;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    QryEMP: TClientDataSet;
    QryTemp: TClientDataSet;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    SProc: TClientDataSet;
    lablType: TLabel;
    Image1: TImage;
    sbtnquery: TSpeedButton;
    lablReel: TLabel;
    QryReel: TClientDataSet;
    Image2: TImage;
    SpeedButton1: TSpeedButton;
    lablDesc: TLabel;
    lablLabel: TLabel;
    EditEMP: TEdit;
    Label2: TLabel;
    Editempname: TEdit;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure sbtnqueryClick(Sender: TObject);
    procedure Queryempno ;


  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;

    function G_getTableData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sTableName, f_sParam, f_sData: string; var f_tsParam, f_tsData: tstrings): boolean;
    function G_getParamData(f_tsParam, f_tsData: tstrings; f_sParam: string): string;
    procedure G_deleteParamData(f_sParam: string; var f_tsParam, f_tsData: tstrings);
    function G_getFieldsData(f_Fields: TFields; var f_tsParam, f_tsData: tstrings): boolean;
    function G_getEMPData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;
    function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string): string; overload;
    function G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord, f_sRuleName: string): string; overload;
    
  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  editemp.Clear ;
  editemp.SetFocus ;
  editempname.Clear ;
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
    Params.ParamByName('dll_name').AsString := 'QueryEmp.DLL';
    Open;
  end;
end;

     {begin
      sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', 'Reel ID*&*' + sReel, 1, '');
      if assigned(G_onTransDataToApplication) then
       G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
      else
       showmessage('Not Defined Call Back Function for Code Soft');
     end; }

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var i: Integer; semp, sPrintData: string;
begin
  if not assigned(G_onTransDataToApplication) then
  begin
    showmessage('Not Defined Call Back Function for Code Soft');
    Exit;
  end;

  Queryempno;
  WITH QRYEMP  DO
   BEGIN
     SEMP:=FIELDBYNAME('EMP_NO').ASSTRING;
     if semp='' then
       exit;
   END;
   
   sPrintData := G_getPrintData(6, 17, G_sockConnection, 'DspQryData', 'EMP*&*' + sEMP, 1, '');
   //G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil);
   if assigned(G_onTransDataToApplication) then
       G_onTransDataToApplication(@sPrintData[1], length(sPrintData), nil)
      else
       showmessage('Not Defined Call Back Function for Code Soft');
   
end;

procedure TfDetail.Queryempno;
begin
  with QryEMP do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'emp_no', ptInput);
      CommandText := 'select emp_no,emp_name from sajet.sys_emp where emp_no=:emp_no and rownum = 1 ';
      Params.ParamByName('emp_no').AsString := editemp.Text ;
      Open;

      if isempty  then
        begin
            editemp.Clear ;
            editemp.SetFocus ;
            editempname.Clear ;
            showmessage('NOT FIND THE EMP !') ;
            exit;
        end
        else begin
           editempname.Text :=fieldbyname('emp_name').AsString ;
           editemp.SelectAll ;
           editemp.SetFocus ;
         end;
    end;
end;

procedure TfDetail.sbtnqueryClick(Sender: TObject);
begin
   QUERYEMPNO;
end;

function TfDetail.G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord, f_sRuleName: string): string;
begin
  result := G_getPrintData(f_iVersion, f_iType, f_SocketConnection, f_sProvideName, f_sKeyWord, 1, f_sRuleName);
end;

function TfDetail.G_getPrintData(f_iVersion, f_iType: integer; f_SocketConnection: TSocketConnection; f_sProvideName, f_sKeyWord: string; f_iQty: integer; f_sRuleName: string): string;
var printTemp: TCSPrintData;
  sPartNo, sTitle, sSN, sWo, sType, sValue, sFileName: string;
begin
  result := '';

  printTemp := TCSPrintData.create(Application);
  try
    printTemp.clear;
    if  f_iType=17 then
        begin
          sType := Copy(f_sKeyWord, 1, Pos('*&*', f_sKeyWord) - 1);
          sValue := Copy(f_sKeyWord, Pos('*&*', f_sKeyWord) + 3, Length(f_sKeyWord));
          if not G_getEMPData(f_SocketConnection, f_sProvideName, sType, sValue, printTemp.m_tsParam, printTemp.m_tsData, sTitle) then raise Exception.Create('Get ' + sType + '(' + sValue + ') Data Fail');
          sTitle := 'EMP'+ '_';
        end
    else begin
      raise Exception.Create('Unknow Print Type');
    end;

   IF f_iType = 17 then
        begin
          sPartNo := G_getParamData(printTemp.m_tsParam, printTemp.m_tsData, 'PART_NO');
          sFileName := G_getParamData(printTemp.m_tsParam, printTemp.m_tsData, 'LABEL_FILE');
          printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sFileName + '.LAB';
          if not FileExists(printTemp.m_sSampleFile) then
            printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + sPartNo + '.LAB';
          if not FileExists(printTemp.m_sSampleFile) then
            printTemp.m_sSampleFile := ExtractFilePath(Application.ExeName) + sTitle + 'DEFAULT' + '.LAB';
        end
    else begin
      raise Exception.Create('Unknow Print Type');
    end;

    printTemp.m_iQty := f_iQty;
    if f_iVersion in [0, 4, 5, 6] then printTemp.m_iVerstion := f_iVersion;
    result := printTemp.encodePrintData;
  finally
    printTemp.free;
  end;
end;

function TfDetail.G_getEMPData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sType, f_sLabelNO: string; var f_tsParam, f_tsData: tstrings; var sTitle: string): boolean;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'emp_no', ptInput);
        CommandText := 'select emp_no,emp_name from sajet.sys_emp where emp_no=:emp_no and rownum = 1 ';
        Params.ParamByName('emp_no').AsString := f_sLabelNO;
        Open;
        G_getFieldsData(Fields, f_tsParam, f_tsData);
        Close;
      finally
        free;
      end;
    end;
    result := true;
  except
  end;
end;

procedure TfDetail.G_deleteParamData(f_sParam: string; var f_tsParam, f_tsData: tstrings);
var iIndex: integer;
begin
  iIndex := f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex < 0 then exit;
  f_tsParam.Delete(iIndex);
  f_tsData.Delete(iIndex);
end;

function TfDetail.G_getParamData(f_tsParam, f_tsData: tstrings; f_sParam: string): string;
var iIndex: integer;
begin
  result := '';
  iIndex := f_tsParam.indexof(UpperCase(f_sParam));
  if iIndex < 0 then exit;
  result := f_tsData[iIndex];
end;

function TfDetail.G_getTableData(f_SocketConnection: TSocketConnection; f_sProvideName, f_sTableName, f_sParam, f_sData: string; var f_tsParam, f_tsData: tstrings): boolean;
begin
  result := false;
  try
    with TClientDataSet.Create(Application) do
    begin
      try
        RemoteServer := f_SocketConnection;
        ProviderName := f_sProvideName;

        Params.Clear;
        params.CreateParam(ftString, f_sParam, ptinput);
        CommandText := ' select * from ' + f_sTableName + ' ' +
          ' where ' + f_sParam + '=:' + f_sParam + ' and rownum=1 ';
        Params.parambyname(f_sParam).asstring := f_sData;
        open;

        G_getFieldsData(Fields, f_tsParam, f_tsData);

        close;
      finally
        free;
      end;
    end;
    result := true;
  except
  end;
end;

function TfDetail.G_getFieldsData(f_Fields: TFields; var f_tsParam, f_tsData: tstrings): boolean;
var i: integer;
begin
  result := false;
  try
    for i := 1 to f_Fields.Count do
    begin
      if f_tsParam.IndexOf(Uppercase(f_Fields.Fields[i - 1].FieldName)) < 0 then
      begin
        f_tsParam.Add(UpperCase(f_Fields.Fields[i - 1].FieldName));
        f_tsData.add(f_Fields.Fields[i - 1].AsString);
      end;
    end;
    result := true;
  except
  end;
end;

end.

