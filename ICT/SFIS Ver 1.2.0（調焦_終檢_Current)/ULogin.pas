unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Variants,
  Controls, Classes, ExtCtrls, Graphics,Forms,
  Dialogs, StdCtrls,  DB, ADODB, Buttons, DateUtils, IniFiles, IdGlobal;

type
  TFrmLogin = class(TForm)
    Panel1: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Ed_Type: TEdit;
    Ed_Model: TEdit;
    Ed_WoQty: TEdit;
    Ed_FilePath: TEdit;
    Cmd_Start: TBitBtn;
    Cmd_Exit: TBitBtn;
    Ed_WorkOrder: TEdit;
    Ed_StationCode: TEdit;
    Ed_LightBoxNo: TEdit;
    PL_Computer: TPanel;
    ADOConnFoxSystemTest: TADOConnection;
    ADOS_SaveTestFile108_2: TADOStoredProc;

    procedure Cmd_StartClick(Sender: TObject);
    procedure Cmd_ExitClick(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    //procedure Ed_LightBoxNoChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
     connStr,FilePath,mDate,TestProgVer:string;
     mLine:Integer;
  end;

var
    FrmLogin: TFrmLogin;



implementation

uses GCommon;

{$R *.dfm}

function GetAppPath :String;
Begin
  Result:=ExtractFilePath(Application.ExeName);
end;

procedure TFrmLogin.Cmd_ExitClick(Sender: TObject);
begin
   Application.Terminate;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
    //mProgramS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
   // ShortDateFormat:='yyyy_mm_dd';
    //mDate:=DateTimetostr(Dateof(now()));
end;

procedure TFrmLogin.FormActivate(Sender: TObject);
var
    FpOpen: TextFile;
    iniFile: TIniFile;
    sSFCConfig:string;
    sPath,FilePathTestConfig:string;  //測試程式Config.txt
    CONF_MODEL,sLightBox:string;
    CONF_LIGHTBOX,CONF_FIXTURE,CONF_LIGHTPANEL,StationCode:string;
    i,j:Integer;
    S:string;
    strs:TStrings;
    IsExists:Boolean;

begin


   sSFCConfig := ExtractFilePath(ParamStr(0))+'SFCS_Config.ini';

   if FileExists(sSFCConfig) then
   begin
      iniFile :=  TIniFile.Create(sSFCConfig);
      connStr := iniFile.ReadString('DataServ','StrConnServer','');
      sLightBox := iniFile.ReadString('TestLogFile','LightBox','');
      sPath := iniFile.ReadString('TestLogFile','LogFilePath','');
      iniFile.Free;

      if connStr = '' then begin
          showmsg ( 'NG;找不到連接字串');
          Cmd_ExitClick(nil);
      end;

      if sPath ='' then begin
         sPath :=ExtractFilePath(ParamStr(0))+'Log\';

         if not DirectoryExists(sPath) then begin
             showmsg( 'NG;找不到測試Log路徑:'+sPath);
             Cmd_ExitClick(nil);
         end;
      end else begin
         if not DirectoryExists(sPath) then begin
             sPath :=  ExtractFilePath(ParamStr(0))+'Log\';
             if not DirectoryExists(sPath) then begin
                 showmsg('NG;找不到測試Log路徑'+sPath);
                 Cmd_ExitClick(nil);
             end;
         end;
      end;

   end else begin
       showmsg('NG;找不到文件 SFCS_Config.ini');
       Cmd_ExitClick(nil);
   end;


    
    FilePathTestConfig:= ExtractFilePath(ParamStr(0)) +'Config.txt';
    if not FileExists(FilePathTestConfig) then
    begin
       showmsg( 'NG;找不到測試程式Config文件:'+FilePathTestConfig);
       Cmd_ExitClick(nil);
    end;


    //版本檢測
    {
    DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@SfisVersion']:='SFIS 1.2.0';
    DmWorkOrder.ADOS_CheckVer.ExecProc;
    if DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@outFlag']=0 then
    BEGIN
       ShowMsg(DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@Message']);
       Cmd_ExitClick(nil);
    END;
    }

    AssignFile(FpOpen, FilePathTestConfig);
    Reset(FpOpen);//打開文件
    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//讀取一行文本
        if trim(S)<>'' THEN BEGIN
            strs := TStringList.Create;
            strs.Delimiter := ' ';
            strs.DelimitedText := S;
            i:=0;
            j:=1;
            if Strs[i]='CONF_PROJECT_NAME(CHAR)' then
                   CONF_MODEL:=Strs[j]
            else if Strs[i]='CONF_STATION_SN(CHAR)' then
                CONF_LIGHTBOX:=Strs[j]
            else if Strs[i]='CONF_FIXTURE_SN(CHAR)' then
                CONF_FIXTURE:=Strs[j]
            else if Strs[i]='CONF_LIGHTPANEL_SN(CHAR)' then
                CONF_LIGHTPANEL:=Strs[j]
            else if Strs[i]='CONF_FILE_VERSION(CHAR)' then
                TestProgVer:=Strs[j]
            else if Strs[i]='CONF_CELL_INFO(CHAR)' then
                StationCode:=Strs[j];
            strs.Free;
        end;
    end;
    CloseFile(FpOpen);
    mDate:=FormatDateTime('YYYY_MM_DD',Now);

    FilePath:=sPath+CONF_MODEL+'_'+mDate+'_'+StationCode+'_'+CONF_LIGHTBOX+'_'+CONF_FIXTURE+'_'+CONF_LIGHTPANEL+'.txt';
    Ed_Model.Text :=CONF_MODEL;
    Ed_StationCode.Text :=StationCode;
    Ed_LightBoxNo.Text :=sLightBox;
    Ed_FilePath.Text :=FilePath;
    IsExists:=FileExists(FilePath);
    if not IsExists then begin
        showmsg(FilePath+'文件不存在！') ;
        Cmd_ExitClick(nil);
    end ELSE begin
       Cmd_Start.Enabled:=TRUE;
       Cmd_Start.SetFocus;
       Cmd_StartClick(nil);
    end;
end;


procedure TFrmLogin.Cmd_StartClick(Sender: TObject);
var
  i,iTitleCount,iDataCount:Integer;
  ItemStr:array[1..150] of string;
  sData,sSN,sFirst,sLast:string;
  strs,slTitle,slData: TStringList;
begin
    Cmd_Exit.Enabled:=FALSE;
    //獲取開始時間
    //mStartS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
    sSN :='';
    iDataCount :=0;
    iTitleCount :=0;
    mLine :=0;
    Application.ProcessMessages;   //在操作過程中，程序還能繼續響應其他操作而不鎖死

    try
        strs :=TStringList.Create;
        strs.LoadFromFile(FilePath);
        mLine := strs.Count;
        sFirst := strs.Strings[0];
        if sFirst = '' then begin
            ShowMsg( 'NG;找不到項目抬頭') ;
            Cmd_ExitClick(nil);
        end;

        slTitle := TStringList.Create;
        slTitle.Delimiter := #9;
        slTitle.DelimitedText :=sFirst;
        iTitleCount := slTitle.Count;

        sData :=  strs.Strings[strs.Count-1];
        slData := TStringList.Create;
        slData.Delimiter := #9;
        slData.DelimitedText := sData;
        iDataCount := slData.Count;
        sSN := slData.Strings[0];

        if sSN ='' then begin
            slTitle.Free;
            slData.Free;
            strs.Free;
            showmsg('NG;條碼為空,數據不保存');
            Exit;
        end;
    except
        if Assigned(slTitle) then
           slTitle.Free;
        if Assigned(slData) then
           slData.Free;
        if Assigned(strs) then
           strs.Free;
        showmsg('NG;解析數據錯誤');
        Cmd_ExitClick(nil);
    end;

    if iDataCount <> iTitleCount then
    begin
        if Assigned(slTitle) then
           slTitle.Free;
        if Assigned(slData) then
           slData.Free;
        if Assigned(strs) then
           strs.Free;
       showmsg('NG;項目抬頭數不等於測試記錄項目數');
       Cmd_ExitClick(nil);
    end;

    if  iDataCount > 151 then begin
       if Assigned(slTitle) then
           slTitle.Free;
       if Assigned(slData) then
           slData.Free;
       if Assigned(strs) then
           strs.Free;
       ShowMsg('NG;測試數值項目大於150項，資料庫無法保存');
       Cmd_ExitClick(nil);
    end;

    for i:= 1 to iDataCount-1 do
       ItemStr[i] := slTitle[i] +':'+slData[i];

    if Assigned(slTitle) then
           slTitle.Free;
    if Assigned(slData) then
           slData.Free;
    if Assigned(strs) then
           strs.Free;

    try
        ADOConnFoxSystemTest.Close;
        ADOConnFoxSystemTest.ConnectionString := connStr;
        ADOConnFoxSystemTest.ConnectionTimeout := 15;
        ADOConnFoxSystemTest.LoginPrompt :=False;
        ADOConnFoxSystemTest.Connected := True;
    except
        ShowMsg('NG;連接測試數據庫失敗');
        Cmd_ExitClick(nil);
    end;

    try
        if mLine>1 then begin   //第一行標題不寫入資料庫

             ADOS_SaveTestFile108_2.Parameters.ParamValues['@serialCode']:=sSN;
             ADOS_SaveTestFile108_2.Parameters.ParamValues['@Model']:=Ed_Model.Text;
             ADOS_SaveTestFile108_2.Parameters.ParamValues['@WorkOrder']:='LightBox:'+Ed_LightBoxNo.Text;
             ADOS_SaveTestFile108_2.Parameters.ParamValues['@StationName']:=trim(Ed_StationCode.Text);
             ADOS_SaveTestFile108_2.Parameters.ParamValues['@UserID']:=GetComputer+'@'+GetIP;
             for i:=1 to 150  do
                ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item'+IntToStr(i)]:=ItemStr[i];


             ADOS_SaveTestFile108_2.ExecProc;
             if ADOS_SaveTestFile108_2.Parameters.ParamValues['@outFlag']=0 then begin
                 showmsg(ADOS_SaveTestFile108_2.Parameters.ParamValues['@Message']);
             end;

        end;
        Cmd_Exit.Enabled:=TRUE;
        Cmd_ExitClick(nil);
    except
         ShowMsg('NG;測試數據上傳失敗');
         Cmd_ExitClick(nil);
    end;

end;


end.
