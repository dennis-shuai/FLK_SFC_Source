unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB, Buttons, DateUtils, IniFiles, IdGlobal;

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
    Ed_TestStation: TEdit;
    Ed_WorkOrder: TEdit;
    Ed_StationCode: TEdit;
    Ed_LightBoxNo: TEdit;
    PL_Computer: TPanel;
    ADOQ_LineStation: TADOQuery;
    tmr_start: TTimer;
    ADOConnFoxSystemTest: TADOConnection;
    ADOSPROC1: TADOStoredProc;

    procedure Cmd_StartClick(Sender: TObject);
    procedure Cmd_ExitClick(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Ed_TestStationChange(Sender: TObject);
    procedure Ed_LightBoxNoChange(Sender: TObject);
    procedure tmr_startTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
    FrmLogin: TFrmLogin;
    FilePath:string;
    mDate:string;
    FilePathFirst:string;
    Station,StationShip,mNo:string;
    LastLine:Integer;             //記錄文本上一次已保存的行數
    mFileTestOld:integer;         //文件大小old
    TestItemAll:string;           //標記各類別的所有測試項目
    SaveFilePathFirst:string;     //服務器記錄存放路徑
    SnLength:integer;
    mLine:Integer;
    mProgramS,mStartS,mStartE:string;
    StationProcessSeq:integer;
    SerialCode:string;
    LensID:string;
    Module_Number:string;
    StatusProgram:integer;      //StatusProgram=1  OK   StatusProgram=2   報錯
    GloginUser:string;
    TestProgVer:string; //測試程式版本
    Cell:string;

implementation

uses UDmWo,GCommon;

{$R *.dfm}

function GetAppPath :String;
Begin
  Result:=ExtractFilePath(Application.ExeName);
end;

procedure TFrmLogin.Cmd_ExitClick(Sender: TObject);
begin
  if DmWorkOrder<>nil then begin
    Free;
 end;
  Application.Terminate;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
    mProgramS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
    ShortDateFormat:='yyyy_mm_dd';
    mDate:=DateTimetostr(Dateof(now()));
end;

procedure TFrmLogin.FormActivate(Sender: TObject);
var
    FpOpen: TextFile;
    CFgIniFile: TIniFile;
    IsExists:Boolean;
    Strconn,Temp:string;
    FilePathTestConfig:string;  //測試程式Config.txt
    mModel:string;    //針對223機種，mModel:='FO20FF-223H'
    CONF_LIGHTBOX,CONF_FIXTURE,CONF_LIGHTPANEL:string;
    mLine,i,j:Integer;
    S:string;
    strs:TStrings;
    StationCode:string;
    Crc:string;
begin
    CFgIniFile:=nil;

    if Not FileExists(GetAppPath+'ConFig.Ini') then  Begin
         MessageBox(handle,Pchar('錯誤 ,配置文件不存,請與工程師聯系! '),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
         Cmd_ExitClick(nil);
    End;

    try
        CFgIniFile:=TIniFile.Create(GetAppPath+'ConFig.Ini');
        Strconn:=CFGIniFile.ReadString('DataServ','StrConnServer','');
      
        ADOConnFoxSystemTest.Connected:=false;
        ADOConnFoxSystemTest.ConnectionString:=StrConn;
        ADOConnFoxSystemTest.Connected:=true;

        SaveFilePathFirst:=CFGIniFile.ReadString('SavePath','SaveFilePath','');

        FilePathFirst:=CFGIniFile.ReadString('TestLogFile','LogFilePath','');
        Ed_LightBoxNo.text:=CFGIniFile.ReadString('TestLogFile','LightBox','');

        GloginUser:=CFGIniFile.ReadString('WorkOrder','UserID','');
        Ed_WorkOrder.text:=CFGIniFile.ReadString('WorkOrder','WorkOrder','');
        Ed_WoQty.text:=CFGIniFile.ReadString('WorkOrder','WoQty','');
        Ed_Model.text:=CFGIniFile.ReadString('WorkOrder','Model','');
        Ed_TestStation.text:=CFGIniFile.ReadString('WorkOrder','TestStation','');
        Cell:=CFGIniFile.ReadString('TestLogFile','Cell','');
    Finally
        CFgIniFile.Free;
    end;

    if StationProcessSeq=0 then begin
        Cmd_ExitClick(nil);
    end;
    IF copy(Ed_Model.text,1,11)='FE03FF-301H' then
        mModel:='FE03FF-301H'
    ELSE
        mModel:=Ed_Model.text; 
    {
    //版本檢測
    ADOS_CheckVer.Parameters.ParamValues['@SfisVersion']:='SFIS 1.1.1';
    ADOS_CheckVer.ExecProc;

    if ADOS_CheckVer.Parameters.ParamValues['@outFlag']=0 then
    BEGIN
       ShowMsg(ADOS_CheckVer.Parameters.ParamValues['@Message']);
       Cmd_ExitClick(nil);
    END;
    }
    FilePathTestConfig:=GetAppPath + 'Config.txt';
    AssignFile(FpOpen, FilePathTestConfig);
    Reset(FpOpen);//打開文件
    mLine:=0;
    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//讀取一行文本
        if trim(S)<>'' THEN BEGIN
            mLine:=mLine+1;
            strs := TStringList.Create;
            strs.Delimiter := ' ';
            strs.DelimitedText := S;
            i:=0;
            j:=1;
            if Strs[i]='CONF_STATION_SN(CHAR)' then
                CONF_LIGHTBOX:=Strs[j]
            else if Strs[i]='CONF_FIXTURE_SN(CHAR)' then
                CONF_FIXTURE:=Strs[j]
            else if Strs[i]='CONF_LIGHTPANEL_SN(CHAR)' then
                CONF_LIGHTPANEL:=Strs[j]
            else if Strs[i]='CONF_FILE_VERSION(CHAR)' then
                TestProgVer:=Strs[j]
            else if Strs[i]='CONF_CELL_INFO(CHAR)' then
                StationCode:=Strs[j]
            else if strs[i]='CONF_CONFIG_CRC_CHECK(INT)' then
                Crc:=strs[j];
            strs.Free;
        end;
    end;
    CloseFile(FpOpen);
    begin
       Cmd_Start.Enabled:=TRUE;
       Cmd_Start.SetFocus;
       Cmd_StartClick(nil);
    end;
end;

procedure TFrmLogin.Ed_TestStationChange(Sender: TObject);
begin
     if Ed_TestStation.Text='AOO' then
        Ed_StationCode.Text:='AOO'
end;

procedure TFrmLogin.Ed_LightBoxNoChange(Sender: TObject);
begin
    if trim(Ed_LightBoxNo.text)<>'' then
        mNo:=trim(Ed_LightBoxNo.Text);
end;

procedure TFrmLogin.Cmd_StartClick(Sender: TObject);
var
  FpOpen,FpSave,FpSaveTime: TextFile;
  S,AllText:string;

  StrStatus,ErrItem,TestVersion:string;
  N1,N2,N3,N4:Integer;
  mSaveTimePath:string; //記錄程式運行時間
  IsExists:Boolean;
  nSn,nID,nModule,nItem,nVer,nDate,nTime,nBlem,nSN_CHK,nFLR_CHK:Integer;
  TestItem,mTestDate,mTestTime,mBlem,mSN_CHK,mFLR_CHK:string;
  TestData:string;

  i :Integer;

  CopyFilePath:string;   //記錄臨時復制文件路徑
  mSizeTest:integer;     //文件大小

  mDateNew:string;   //記錄晚上12：00之后的日期，與之前的日期作比對
  mTime:string;

  ItemStr:array[1..150] of string;

  sl:TStringlist;
  sltemp:TStringList;

  sFirst,sLast:string;
  sList:TStringList;
  strs: TStringList;
  parts: TStringList;
  strsFirst,strsLast:TStrings;
  sr: TSearchRec;
  FileAttrs: Integer;
begin
    Station:=Ed_TestStation.Text;
    StationShip:=Station+mNo;

    SerialCode:='';
    Cmd_Exit.Enabled:=FALSE;
    //獲取開始時間
    mStartS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());

    Application.ProcessMessages;   //在操作過程中，程序還能繼續響應其他操作而不鎖死
    if FindFirst( FilePathFirst+'\*.txt',faAnyFile,sr)=0 then begin
       repeat
         if (sr.Attr and faAnyFile) = sr.Attr then
         begin
            FilePath :=FilePathFirst+sr.Name;
            strs := TStringList.Create;
            try
                strs.LoadFromFile(FilePath);
                if strs.Count>1 then   begin
                    mLine:=strs.Count;
                    sFirst:=strs[0];                  //臺頭
                    sLast:=strs[strs.Count-1];       //最后一行
                    if trim(sFirst)<>'' then begin
                        strsFirst := TStringList.Create;
                        strsFirst.Delimiter := ' ';
                        strsFirst.DelimitedText :=sFirst;
                        for i := 0 to strsFirst.Count-1 do
                          IF i=0 then
                              nSn:=i
                          else if i=1 then begin
                              nItem:=i;
                              TestItemAll:=strsFirst[i]
                          end
                          else if strsFirst[i]='Lens_ID' THEN
                              nID:=i
                          else if strsFirst[i]='Module_Number'  then
                              nModule:=i
                          else if strsFirst[i]='Version' THEN
                              nVer:=i
                          else if strsFirst[i]='Date' THEN
                              nDate:=i
                          else if strsFirst[i]='Time' THEN
                              nTime:=i
                          else if strsFirst[i]='BLEM' THEN
                              nBlem:=i
                          else if strsFirst[i]='SN_CHK' THEN
                              nSN_CHK:=i
                          else if strsFirst[i]='FLR_CHK' THEN
                              nFLR_CHK:=i;
                        if trim(sLast)<>'' then begin
                            strsLast := TStringList.Create;
                            strsLast.Delimiter := ' ';
                            strsLast.DelimitedText :=sLast;
                            if strsFirst.Count<>strsLast.Count then begin
                                showmsg('Error: 記錄項目數<>抬頭項目數，請工程師處理！');
                            end;
                            SerialCode:=trim(UpperCase(strsLast[nSn]));
                            LensID:=trim(UpperCase(strsLast[nID]));
                            Module_Number:=Trim(UpperCase(strsLast[nModule]));
                            TestItem:=strsLast[nItem];
                            TestVersion:=strsLast[nVer];
                            mTestDate:=strsLast[nDate];
                            mTestTime:=strsLast[nTime];
                            mBlem:=strsLast[nBlem];
                            mSN_CHK:=strsLast[nSN_CHK];
                            mFLR_CHK:=strsLast[nFLR_CHK];
                            For i:=1 to strsLast.Count-1 do
                              ItemStr[i]:=strsFirst[i]+':'+ strsLast[i];

                            IF strsLast.Count>151 THEN
                            BEGIN
                                showmessage('提示:測試項目已>150項，資料庫無法保存！');
                            END else if  strsLast.Count<151 then begin
                              for i:=strsLast.Count to 150 do
                                  ItemStr[i]:='';
                            end;
                        end else begin
                            Cmd_Exit.Enabled:=TRUE;
                            Cmd_ExitClick(nil);
                        end;
                    end;
                end else begin
                   strs.Free;
                end;
                strsFirst.Free;
                strsLast.Free;
            finally
                strs.free;
            end;


            if mLine>1 then begin   //第一行標題不寫入資料庫
                ADOSPROC1.Parameters.ParamValues['@mLine']:=mLine;
                ADOSPROC1.Parameters.ParamValues['@LogFileName']:=mDate;
                ADOSPROC1.Parameters.ParamValues['@serialCode']:=SerialCode;
//                ADOSPROC1.Parameters.ParamValues['@ProcessSeQ']:=StationProcessSeq;
                ADOSPROC1.Parameters.ParamValues['@Model']:=trim(Ed_Model.text);
                ADOSPROC1.Parameters.ParamValues['@WorkOrder']:=trim(Ed_WorkOrder.Text);
                ADOSPROC1.Parameters.ParamValues['@StationShip']:=StationShip;
                ADOSPROC1.Parameters.ParamValues['@StationName']:=trim(Ed_TestStation.Text);
                ADOSPROC1.Parameters.ParamValues['@TestStatus']:=StrStatus;
                ADOSPROC1.Parameters.ParamValues['@ErrItemCode']:=ErrItem;
                ADOSPROC1.Parameters.ParamValues['@Memo']:=trim(Ed_TestStation.Text);
                ADOSPROC1.Parameters.ParamValues['@ComputerName']:=GetComputer;
                ADOSPROC1.Parameters.ParamValues['@UserID']:=GLoginUser;
                //ADOSPROC1.Parameters.ParamValues['@TestDate']:=mTestDate;
                ADOSPROC1.Parameters.ParamValues['@TestDate']:='Cell '+Cell;
                ADOSPROC1.Parameters.ParamValues['@TestTime']:=mTestTime;
                ADOSPROC1.Parameters.ParamValues['@Ship']:='1';
                ADOSPROC1.Parameters.ParamValues['@Version']:=TestProgVer;
                ADOSPROC1.Parameters.ParamValues['@Item1']:=ItemStr[1];
                ADOSPROC1.Parameters.ParamValues['@Item2']:=ItemStr[2];
                ADOSPROC1.Parameters.ParamValues['@Item3']:=ItemStr[3];
                ADOSPROC1.Parameters.ParamValues['@Item4']:=ItemStr[4];
                ADOSPROC1.Parameters.ParamValues['@Item5']:=ItemStr[5];
                ADOSPROC1.Parameters.ParamValues['@Item6']:=ItemStr[6];
                ADOSPROC1.Parameters.ParamValues['@Item7']:=ItemStr[7];
                ADOSPROC1.Parameters.ParamValues['@Item8']:=ItemStr[8];
                ADOSPROC1.Parameters.ParamValues['@Item9']:=ItemStr[9];
                ADOSPROC1.Parameters.ParamValues['@Item10']:=ItemStr[10];
                ADOSPROC1.Parameters.ParamValues['@Item11']:=ItemStr[11];
                ADOSPROC1.Parameters.ParamValues['@Item12']:=ItemStr[12];
                ADOSPROC1.Parameters.ParamValues['@Item13']:=ItemStr[13];
                ADOSPROC1.Parameters.ParamValues['@Item14']:=ItemStr[14];
                ADOSPROC1.Parameters.ParamValues['@Item15']:=ItemStr[15];
                ADOSPROC1.Parameters.ParamValues['@Item16']:=ItemStr[16];
                ADOSPROC1.Parameters.ParamValues['@Item17']:=ItemStr[17];
                ADOSPROC1.Parameters.ParamValues['@Item18']:=ItemStr[18];
                ADOSPROC1.Parameters.ParamValues['@Item19']:=ItemStr[19];
                ADOSPROC1.Parameters.ParamValues['@Item20']:=ItemStr[20];
                ADOSPROC1.Parameters.ParamValues['@Item21']:=ItemStr[21];
                ADOSPROC1.Parameters.ParamValues['@Item22']:=ItemStr[22];
                ADOSPROC1.Parameters.ParamValues['@Item23']:=ItemStr[23];
                ADOSPROC1.Parameters.ParamValues['@Item24']:=ItemStr[24];
                ADOSPROC1.Parameters.ParamValues['@Item25']:=ItemStr[25];
                ADOSPROC1.Parameters.ParamValues['@Item26']:=ItemStr[26];
                ADOSPROC1.Parameters.ParamValues['@Item27']:=ItemStr[27];
                ADOSPROC1.Parameters.ParamValues['@Item28']:=ItemStr[28];
                ADOSPROC1.Parameters.ParamValues['@Item29']:=ItemStr[29];
                ADOSPROC1.Parameters.ParamValues['@Item30']:=ItemStr[30];
                ADOSPROC1.Parameters.ParamValues['@Item31']:=ItemStr[31];
                ADOSPROC1.Parameters.ParamValues['@Item32']:=ItemStr[32];
                ADOSPROC1.Parameters.ParamValues['@Item33']:=ItemStr[33];
                ADOSPROC1.Parameters.ParamValues['@Item34']:=ItemStr[34];
                ADOSPROC1.Parameters.ParamValues['@Item35']:=ItemStr[35];
                ADOSPROC1.Parameters.ParamValues['@Item36']:=ItemStr[36];
                ADOSPROC1.Parameters.ParamValues['@Item37']:=ItemStr[37];
                ADOSPROC1.Parameters.ParamValues['@Item38']:=ItemStr[38];
                ADOSPROC1.Parameters.ParamValues['@Item39']:=ItemStr[39];
                ADOSPROC1.Parameters.ParamValues['@Item40']:=ItemStr[40];
                ADOSPROC1.Parameters.ParamValues['@Item41']:=ItemStr[41];
                ADOSPROC1.Parameters.ParamValues['@Item42']:=ItemStr[42];
                ADOSPROC1.Parameters.ParamValues['@Item43']:=ItemStr[43];
                ADOSPROC1.Parameters.ParamValues['@Item44']:=ItemStr[44];
                ADOSPROC1.Parameters.ParamValues['@Item45']:=ItemStr[45];
                ADOSPROC1.Parameters.ParamValues['@Item46']:=ItemStr[46];
                ADOSPROC1.Parameters.ParamValues['@Item47']:=ItemStr[47];
                ADOSPROC1.Parameters.ParamValues['@Item48']:=ItemStr[48];
                ADOSPROC1.Parameters.ParamValues['@Item49']:=ItemStr[49];
                ADOSPROC1.Parameters.ParamValues['@Item50']:=ItemStr[50];
                ADOSPROC1.Parameters.ParamValues['@Item51']:=ItemStr[51];
                ADOSPROC1.Parameters.ParamValues['@Item52']:=ItemStr[52];
                ADOSPROC1.Parameters.ParamValues['@Item53']:=ItemStr[53];
                ADOSPROC1.Parameters.ParamValues['@Item54']:=ItemStr[54];
                ADOSPROC1.Parameters.ParamValues['@Item55']:=ItemStr[55];
                ADOSPROC1.Parameters.ParamValues['@Item56']:=ItemStr[56];
                ADOSPROC1.Parameters.ParamValues['@Item57']:=ItemStr[57];
                ADOSPROC1.Parameters.ParamValues['@Item58']:=ItemStr[58];
                ADOSPROC1.Parameters.ParamValues['@Item59']:=ItemStr[59];
                ADOSPROC1.Parameters.ParamValues['@Item60']:=ItemStr[60];
                ADOSPROC1.Parameters.ParamValues['@Item61']:=ItemStr[61];
                ADOSPROC1.Parameters.ParamValues['@Item62']:=ItemStr[62];
                ADOSPROC1.Parameters.ParamValues['@Item63']:=ItemStr[63];
                ADOSPROC1.Parameters.ParamValues['@Item64']:=ItemStr[64];
                ADOSPROC1.Parameters.ParamValues['@Item65']:=ItemStr[65];
                ADOSPROC1.Parameters.ParamValues['@Item66']:=ItemStr[66];
                ADOSPROC1.Parameters.ParamValues['@Item67']:=ItemStr[67];
                ADOSPROC1.Parameters.ParamValues['@Item68']:=ItemStr[68];
                ADOSPROC1.Parameters.ParamValues['@Item69']:=ItemStr[69];
                ADOSPROC1.Parameters.ParamValues['@Item70']:=ItemStr[70];
                ADOSPROC1.Parameters.ParamValues['@Item71']:=ItemStr[71];
                ADOSPROC1.Parameters.ParamValues['@Item72']:=ItemStr[72];
                ADOSPROC1.Parameters.ParamValues['@Item73']:=ItemStr[73];
                ADOSPROC1.Parameters.ParamValues['@Item74']:=ItemStr[74];
                ADOSPROC1.Parameters.ParamValues['@Item75']:=ItemStr[75];
                ADOSPROC1.Parameters.ParamValues['@Item76']:=ItemStr[76];
                ADOSPROC1.Parameters.ParamValues['@Item77']:=ItemStr[77];
                ADOSPROC1.Parameters.ParamValues['@Item78']:=ItemStr[78];
                ADOSPROC1.Parameters.ParamValues['@Item79']:=ItemStr[79];
                ADOSPROC1.Parameters.ParamValues['@Item80']:=ItemStr[80];
                ADOSPROC1.Parameters.ParamValues['@Item81']:=ItemStr[81];
                ADOSPROC1.Parameters.ParamValues['@Item82']:=ItemStr[82];
                ADOSPROC1.Parameters.ParamValues['@Item83']:=ItemStr[83];
                ADOSPROC1.Parameters.ParamValues['@Item84']:=ItemStr[84];
                ADOSPROC1.Parameters.ParamValues['@Item85']:=ItemStr[85];
                ADOSPROC1.Parameters.ParamValues['@Item86']:=ItemStr[86];
                ADOSPROC1.Parameters.ParamValues['@Item87']:=ItemStr[87];
                ADOSPROC1.Parameters.ParamValues['@Item88']:=ItemStr[88];
                ADOSPROC1.Parameters.ParamValues['@Item89']:=ItemStr[89];
                ADOSPROC1.Parameters.ParamValues['@Item90']:=ItemStr[90];
                ADOSPROC1.Parameters.ParamValues['@Item91']:=ItemStr[91];
                ADOSPROC1.Parameters.ParamValues['@Item92']:=ItemStr[92];
                ADOSPROC1.Parameters.ParamValues['@Item93']:=ItemStr[93];
                ADOSPROC1.Parameters.ParamValues['@Item94']:=ItemStr[94];
                ADOSPROC1.Parameters.ParamValues['@Item95']:=ItemStr[95];
                ADOSPROC1.Parameters.ParamValues['@Item96']:=ItemStr[96];
                ADOSPROC1.Parameters.ParamValues['@Item97']:=ItemStr[97];
                ADOSPROC1.Parameters.ParamValues['@Item98']:=ItemStr[98];
                ADOSPROC1.Parameters.ParamValues['@Item99']:=ItemStr[99];
                ADOSPROC1.Parameters.ParamValues['@Item100']:=ItemStr[100];
                ADOSPROC1.Parameters.ParamValues['@Item101']:=ItemStr[101];
                ADOSPROC1.Parameters.ParamValues['@Item102']:=ItemStr[102];
                ADOSPROC1.Parameters.ParamValues['@Item103']:=ItemStr[103];
                ADOSPROC1.Parameters.ParamValues['@Item104']:=ItemStr[104];
                ADOSPROC1.Parameters.ParamValues['@Item105']:=ItemStr[105];
                ADOSPROC1.Parameters.ParamValues['@Item106']:=ItemStr[106];
                ADOSPROC1.Parameters.ParamValues['@Item107']:=ItemStr[107];
                ADOSPROC1.Parameters.ParamValues['@Item108']:=ItemStr[108];
                ADOSPROC1.Parameters.ParamValues['@Item109']:=ItemStr[109];
                ADOSPROC1.Parameters.ParamValues['@Item110']:=ItemStr[110];
                ADOSPROC1.Parameters.ParamValues['@Item111']:=ItemStr[111];
                ADOSPROC1.Parameters.ParamValues['@Item112']:=ItemStr[112];
                ADOSPROC1.Parameters.ParamValues['@Item113']:=ItemStr[113];
                ADOSPROC1.Parameters.ParamValues['@Item114']:=ItemStr[114];
                ADOSPROC1.Parameters.ParamValues['@Item115']:=ItemStr[115];
                ADOSPROC1.Parameters.ParamValues['@Item116']:=ItemStr[116];
                ADOSPROC1.Parameters.ParamValues['@Item117']:=ItemStr[117];
                ADOSPROC1.Parameters.ParamValues['@Item118']:=ItemStr[118];
                ADOSPROC1.Parameters.ParamValues['@Item119']:=ItemStr[119];
                ADOSPROC1.Parameters.ParamValues['@Item120']:=ItemStr[120];
                ADOSPROC1.Parameters.ParamValues['@Item121']:=ItemStr[121];
                ADOSPROC1.Parameters.ParamValues['@Item122']:=ItemStr[122];
                ADOSPROC1.Parameters.ParamValues['@Item123']:=ItemStr[123];
                ADOSPROC1.Parameters.ParamValues['@Item124']:=ItemStr[124];
                ADOSPROC1.Parameters.ParamValues['@Item125']:=ItemStr[125];
                ADOSPROC1.Parameters.ParamValues['@Item126']:=ItemStr[126];
                ADOSPROC1.Parameters.ParamValues['@Item127']:=ItemStr[127];
                ADOSPROC1.Parameters.ParamValues['@Item128']:=ItemStr[128];
                ADOSPROC1.Parameters.ParamValues['@Item129']:=ItemStr[129];
                ADOSPROC1.Parameters.ParamValues['@Item130']:=ItemStr[130];
                ADOSPROC1.Parameters.ParamValues['@Item131']:=ItemStr[131];
                ADOSPROC1.Parameters.ParamValues['@Item132']:=ItemStr[132];
                ADOSPROC1.Parameters.ParamValues['@Item133']:=ItemStr[133];
                ADOSPROC1.Parameters.ParamValues['@Item134']:=ItemStr[134];
                ADOSPROC1.Parameters.ParamValues['@Item135']:=ItemStr[135];
                ADOSPROC1.Parameters.ParamValues['@Item136']:=ItemStr[136];
                ADOSPROC1.Parameters.ParamValues['@Item137']:=ItemStr[137];
                ADOSPROC1.Parameters.ParamValues['@Item138']:=ItemStr[138];
                ADOSPROC1.Parameters.ParamValues['@Item139']:=ItemStr[139];
                ADOSPROC1.Parameters.ParamValues['@Item140']:=ItemStr[140];
                ADOSPROC1.Parameters.ParamValues['@Item141']:=ItemStr[141];
                ADOSPROC1.Parameters.ParamValues['@Item142']:=ItemStr[142];
                ADOSPROC1.Parameters.ParamValues['@Item143']:=ItemStr[143];
                ADOSPROC1.Parameters.ParamValues['@Item144']:=ItemStr[144];
                ADOSPROC1.Parameters.ParamValues['@Item145']:=ItemStr[145];
                ADOSPROC1.Parameters.ParamValues['@Item146']:=ItemStr[146];
                ADOSPROC1.Parameters.ParamValues['@Item147']:=ItemStr[147];
                ADOSPROC1.Parameters.ParamValues['@Item148']:=ItemStr[148];
                ADOSPROC1.Parameters.ParamValues['@Item149']:=ItemStr[149];
                ADOSPROC1.Parameters.ParamValues['@Item150']:=ItemStr[150];

                ADOSPROC1.ExecProc;
               if ADOSPROC1.Parameters.ParamValues['@outFlag']=0 then begin
                     showmsg(ADOSPROC1.Parameters.ParamValues['@Message']);
               end;
               deleteFile(FilePath);
            end;
           end;
          until FindNext(sr) <>0;
          FindClose(sr);
  
    end;

    Cmd_Exit.Enabled:=TRUE;
    Cmd_ExitClick(nil);
end;


procedure TFrmLogin.tmr_startTimer(Sender: TObject);
begin
    Cmd_Start.Click;
end;

end.
