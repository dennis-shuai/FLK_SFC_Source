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

    procedure Cmd_StartClick(Sender: TObject);
    procedure Cmd_ExitClick(Sender: TObject);

    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure Ed_ModelChange(Sender: TObject);
    procedure Ed_TestStationChange(Sender: TObject);
    procedure Ed_LightBoxNoChange(Sender: TObject);
    procedure tmr_startTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    function JugeSnExistsAndStatus:string ;
  end;

var
    FrmLogin: TFrmLogin;
    FilePath:string;
    mDate:string;
    Station,StationShip,mNo:string;
    LastLine:Integer;             //�O���奻�W�@���w�O�s�����
    mFileTestOld:integer;         //���j�pold
    TestItemAll:string;           //�аO�U���O���Ҧ����ն���
    SaveFilePathFirst:string;     //�A�Ⱦ��O���s����|
    SnLength:integer;
    mLine:Integer;
    mProgramS,mStartS,mStartE:string;
    StationProcessSeq:integer;
    SerialCode:string;
    LensID:string;
    Module_Number:string;
    StatusProgram:integer;      //StatusProgram=1  OK   StatusProgram=2   ����
    GloginUser:string;
    TestProgVer:string; //���յ{������
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
    DmWorkOrder.Free;
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
    FilePathFirst:string;
    FilePathTestConfig:string;  //���յ{��Config.txt
    mModel:string;    //�w��223���ءAmModel:='FO20FF-223H'
    CONF_LIGHTBOX,CONF_FIXTURE,CONF_LIGHTPANEL:string;
    mLine,i,j:Integer;
    S:string;
    strs:TStrings;
    StationCode:string;
    Crc:string;
begin
    CFgIniFile:=nil;

    if Not FileExists(GetAppPath+'ConFig.Ini') then  Begin
         MessageBox(handle,Pchar('���~ ,�t�m��󤣦s,�лP�u�{�v�p�t! '),Pchar('System Hint'),MB_OK+MB_ICONEXCLAMATION+MB_SYSTEMMODAL);
         Cmd_ExitClick(nil);
    End;

    try
        CFgIniFile:=TIniFile.Create(GetAppPath+'ConFig.Ini');
        Strconn:=CFGIniFile.ReadString('DataServ','StrConnServer','');
        DmWorkOrder:=TDmWorkOrder.Create(nil);
        DmWorkOrder.ADOConnFoxSystemTest.Connected:=false;
        DmWorkOrder.ADOConnFoxSystemTest.ConnectionString:=StrConn;
        DmWorkOrder.ADOConnFoxSystemTest.Connected:=true;

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

    //�����˴�
    DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@SfisVersion']:='SFIS 1.0.9';
    DmWorkOrder.ADOS_CheckVer.ExecProc;
    if DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@outFlag']=0 then
    BEGIN
       ShowMsg(DmWorkOrder.ADOS_CheckVer.Parameters.ParamValues['@Message']);
       Cmd_ExitClick(nil);
    END;

    FilePathTestConfig:=GetAppPath + 'Config.txt';
    AssignFile(FpOpen, FilePathTestConfig);
    Reset(FpOpen);//���}���
    mLine:=0;
    while not EOF(FpOpen)do begin
        Readln(FpOpen,S);//Ū���@��奻
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
    FilePath:=FilePathFirst+StationCode+'_'+mDate+'.txt';
    Ed_FilePath.text:=FilePath;
    //�P�_Crc
    if Crc<>'1' then begin
      showmsg('�ƾڱN���W��,�нT�{');
      application.Terminate;
      exit;
    end;

    IsExists:=FileExists(FilePath);
    if not IsExists then begin
        showmsg(FilePath+'��󤣦s�b�I') ;
        Cmd_ExitClick(nil);
    end ELSE begin
       Cmd_Start.Enabled:=TRUE;
       Cmd_Start.SetFocus;
       Cmd_StartClick(nil);
    end;
end;

procedure TFrmLogin.Ed_ModelChange(Sender: TObject);
begin
  if trim(Ed_Model.text)<>'' then begin
      //Ū��SN����
      ADOQ_LineStation.Close;
      ADOQ_LineStation.SQL.Clear;
      ADOQ_LineStation.SQL.Add('Select * from W_Model');
      ADOQ_LineStation.SQL.Add(' Where Model='+''''+Ed_Model.text+'''');
      ADOQ_LineStation.Open;
      if not ADOQ_LineStation.IsEmpty then
      begin
          SnLength:=ADOQ_LineStation.fieldByName('SnLength').asinteger;
          Ed_Type.Text:=ADOQ_LineStation.fieldByName('Type').asstring;;
      end;
  end;
end;

procedure TFrmLogin.Ed_TestStationChange(Sender: TObject);
begin
     if Ed_TestStation.Text='AOO' then
        Ed_StationCode.Text:='AOO'
    else IF Ed_TestStation.text='BACTIVEALIGNMENT' then
        Ed_StationCode.text:='BAA'
    else if Ed_TestStation.Text='AACTIVEALIGNMENT' then
        Ed_StationCode.Text:='AAA'
    else if Ed_TestStation.Text='�յJ'  then
        Ed_StationCode.Text:='BFF'
    else if Ed_TestStation.Text='�յJ2' then
        Ed_StationCode.Text:='AFF'
    else if Ed_TestStation.Text='COLORCALIBRATION' then
        Ed_StationCode.Text:='CC'
    else if Ed_TestStation.Text='LIGHT' then
        Ed_StationCode.Text:='Light'
    else if Ed_TestStation.Text='NOISETEST' then
        Ed_StationCode.Text:='NoiseTest'
    else if Ed_TestStation.Text='����'    then
        Ed_StationCode.Text:='FQC';

    IF Ed_TestStation.text<>'OQC'  then begin
        ADOQ_LineStation.Close;
        ADOQ_LineStation.SQL.Clear;
        ADOQ_LineStation.SQL.Add('Select * from Routing');
        ADOQ_LineStation.SQL.Add(' Where StationName='+''''+Trim(Ed_TestStation.text)+'''');
        ADOQ_LineStation.SQL.Add(' and Model='+''''+Trim(Ed_Model.text)+'''');
        ADOQ_LineStation.Open;
        if Not ADOQ_LineStation.IsEmpty then  begin
            StationProcessSeq:=ADOQ_LineStation.fieldByName('ProcessSeq').AsInteger;
        end else begin
            showmsg('Error:�t�Τ��L�����ت���{�H���A�лP�u�{�v�p�t�I');
            Cmd_Exit.Enabled:=true;
            Cmd_ExitClick(nil);
        end;
    end;
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
  mSaveTimePath:string; //�O���{���B��ɶ�
  IsExists:Boolean;
  nSn,nID,nModule,nItem,nVer,nDate,nTime,nBlem,nSN_CHK,nFLR_CHK:Integer;
  TestItem,mTestDate,mTestTime,mBlem,mSN_CHK,mFLR_CHK:string;
  TestData:string;

  i :Integer;

  CopyFilePath:string;   //�O���{�ɴ_������|
  mSizeTest:integer;     //���j�p

  mDateNew:string;   //�O���ߤW12�G00���Z������A�P���e������@���
  mTime:string;

  ItemStr:array[1..150] of string;

  sl:TStringlist;
  sltemp:TStringList;

  sFirst,sLast:string;
  sList:TStringList;
  strs: TStringList;
  parts: TStringList;
  strsFirst,strsLast:TStrings;

begin
    Station:=Ed_TestStation.Text;
    StationShip:=Station+mNo;

    SerialCode:='';
    Cmd_Exit.Enabled:=FALSE;
    //����}�l�ɶ�
    mStartS:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());

    Application.ProcessMessages;   //�b�ާ@�L�{���A�{���ٯ��~���T����L�ާ@�Ӥ��ꦺ

    strs := TStringList.Create;
    try
        strs.LoadFromFile(FilePath);
        if strs.Count>1 then   begin
            mLine:=strs.Count;
            sFirst:=strs[0];                  //�O�Y
            sLast:=strs[strs.Count-1];       //�̦Z�@��
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
                        showmsg('Error: �O�����ؼ�<>���Y���ؼơA�Фu�{�v�B�z�I');
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
                        showmessage('����:���ն��ؤw>150���A��Ʈw�L�k�O�s�I');
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

    //�P�_���A
    if length(SerialCode)<>SnLength then begin
        PL_Computer.Caption:='SN:'+SerialCode+'���׿��~�A�нT�{�I';
        showmsg(PL_Computer.Caption);
        PL_Computer.Font.Size:=10;
        Cmd_Exit.Enabled:=TRUE;
        Cmd_ExitClick(nil);
    end else begin
        //�P�_�O�_�O�Ĥ@���AR_SerialCode�����L�O��

        JugeSnExistsAndStatus;
        if StatusProgram<>1 then begin          //�O�sSerialCode�X��
            Cmd_Exit.Enabled:=TRUE;
            Cmd_ExitClick(nil);
        end;
    end;

    N1:=pos('X',TestItem);
    if N1=0 THEN BEGIN
        ErrItem:='';
        StrStatus:='PASS';
    END ELSE BEGIN
        StrStatus:='FAIL';
        if trim(Ed_WorkOrder.Text)='FN13FF-262H' THEN BEGIN
            IF (trim(Ed_TestStation.Text)='SC����') OR (trim(Ed_TestStation.Text)='OQC') then begin
                IF  mSN_CHK='0' THEN  BEGIN   //0  NG
                    ErrItem:='*';
                END else if mFLR_CHK='1' then BEGIN //1  NG
                    ErrItem:='#';
                END;
            end else begin
                IF mBlem='1' THEN
                    ErrItem:='P'
                else
                    ErrItem:=copy(TestItemAll,N1,1);
            end;
        end else begin
            IF mBlem='1' THEN
                ErrItem:='P'
            else
                ErrItem:=copy(TestItemAll,N1,1);
        end;
    END;

    if mLine>1 then begin   //�Ĥ@����D���g�J��Ʈw
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@mLine']:=mLine;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@LogFileName']:=mDate;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@serialCode']:=SerialCode;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@ProcessSeQ']:=StationProcessSeq;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Model']:=trim(Ed_Model.text);
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@WorkOrder']:=trim(Ed_WorkOrder.Text);
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@StationShip']:=StationShip;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@StationName']:=trim(Ed_TestStation.Text);
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@TestStatus']:=StrStatus;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@ErrItemCode']:=ErrItem;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Memo']:=trim(Ed_TestStation.Text);
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@ComputerName']:=GetComputer;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@UserID']:=GLoginUser;
        //DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@TestDate']:=mTestDate;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@TestDate']:='Cell '+Cell;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@TestTime']:=mTestTime;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Ship']:='1';
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Version']:=TestProgVer;
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item1']:=ItemStr[1];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item2']:=ItemStr[2];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item3']:=ItemStr[3];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item4']:=ItemStr[4];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item5']:=ItemStr[5];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item6']:=ItemStr[6];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item7']:=ItemStr[7];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item8']:=ItemStr[8];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item9']:=ItemStr[9];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item10']:=ItemStr[10];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item11']:=ItemStr[11];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item12']:=ItemStr[12];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item13']:=ItemStr[13];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item14']:=ItemStr[14];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item15']:=ItemStr[15];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item16']:=ItemStr[16];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item17']:=ItemStr[17];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item18']:=ItemStr[18];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item19']:=ItemStr[19];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item20']:=ItemStr[20];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item21']:=ItemStr[21];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item22']:=ItemStr[22];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item23']:=ItemStr[23];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item24']:=ItemStr[24];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item25']:=ItemStr[25];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item26']:=ItemStr[26];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item27']:=ItemStr[27];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item28']:=ItemStr[28];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item29']:=ItemStr[29];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item30']:=ItemStr[30];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item31']:=ItemStr[31];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item32']:=ItemStr[32];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item33']:=ItemStr[33];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item34']:=ItemStr[34];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item35']:=ItemStr[35];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item36']:=ItemStr[36];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item37']:=ItemStr[37];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item38']:=ItemStr[38];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item39']:=ItemStr[39];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item40']:=ItemStr[40];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item41']:=ItemStr[41];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item42']:=ItemStr[42];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item43']:=ItemStr[43];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item44']:=ItemStr[44];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item45']:=ItemStr[45];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item46']:=ItemStr[46];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item47']:=ItemStr[47];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item48']:=ItemStr[48];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item49']:=ItemStr[49];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item50']:=ItemStr[50];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item51']:=ItemStr[51];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item52']:=ItemStr[52];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item53']:=ItemStr[53];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item54']:=ItemStr[54];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item55']:=ItemStr[55];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item56']:=ItemStr[56];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item57']:=ItemStr[57];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item58']:=ItemStr[58];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item59']:=ItemStr[59];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item60']:=ItemStr[60];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item61']:=ItemStr[61];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item62']:=ItemStr[62];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item63']:=ItemStr[63];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item64']:=ItemStr[64];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item65']:=ItemStr[65];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item66']:=ItemStr[66];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item67']:=ItemStr[67];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item68']:=ItemStr[68];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item69']:=ItemStr[69];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item70']:=ItemStr[70];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item71']:=ItemStr[71];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item72']:=ItemStr[72];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item73']:=ItemStr[73];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item74']:=ItemStr[74];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item75']:=ItemStr[75];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item76']:=ItemStr[76];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item77']:=ItemStr[77];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item78']:=ItemStr[78];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item79']:=ItemStr[79];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item80']:=ItemStr[80];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item81']:=ItemStr[81];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item82']:=ItemStr[82];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item83']:=ItemStr[83];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item84']:=ItemStr[84];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item85']:=ItemStr[85];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item86']:=ItemStr[86];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item87']:=ItemStr[87];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item88']:=ItemStr[88];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item89']:=ItemStr[89];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item90']:=ItemStr[90];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item91']:=ItemStr[91];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item92']:=ItemStr[92];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item93']:=ItemStr[93];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item94']:=ItemStr[94];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item95']:=ItemStr[95];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item96']:=ItemStr[96];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item97']:=ItemStr[97];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item98']:=ItemStr[98];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item99']:=ItemStr[99];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item100']:=ItemStr[100];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item101']:=ItemStr[101];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item102']:=ItemStr[102];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item103']:=ItemStr[103];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item104']:=ItemStr[104];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item105']:=ItemStr[105];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item106']:=ItemStr[106];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item107']:=ItemStr[107];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item108']:=ItemStr[108];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item109']:=ItemStr[109];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item110']:=ItemStr[110];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item111']:=ItemStr[111];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item112']:=ItemStr[112];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item113']:=ItemStr[113];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item114']:=ItemStr[114];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item115']:=ItemStr[115];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item116']:=ItemStr[116];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item117']:=ItemStr[117];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item118']:=ItemStr[118];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item119']:=ItemStr[119];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item120']:=ItemStr[120];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item121']:=ItemStr[121];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item122']:=ItemStr[122];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item123']:=ItemStr[123];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item124']:=ItemStr[124];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item125']:=ItemStr[125];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item126']:=ItemStr[126];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item127']:=ItemStr[127];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item128']:=ItemStr[128];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item129']:=ItemStr[129];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item130']:=ItemStr[130];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item131']:=ItemStr[131];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item132']:=ItemStr[132];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item133']:=ItemStr[133];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item134']:=ItemStr[134];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item135']:=ItemStr[135];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item136']:=ItemStr[136];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item137']:=ItemStr[137];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item138']:=ItemStr[138];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item139']:=ItemStr[139];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item140']:=ItemStr[140];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item141']:=ItemStr[141];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item142']:=ItemStr[142];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item143']:=ItemStr[143];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item144']:=ItemStr[144];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item145']:=ItemStr[145];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item146']:=ItemStr[146];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item147']:=ItemStr[147];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item148']:=ItemStr[148];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item149']:=ItemStr[149];
        DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Item150']:=ItemStr[150];

        DmWorkOrder.ADOS_SaveTestFile108_2.ExecProc;
       if DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@outFlag']=0 then begin
             showmsg(DmWorkOrder.ADOS_SaveTestFile108_2.Parameters.ParamValues['@Message']);
       end;
  end;

  //�O�s�}�l�ε����ɶ�
  mSaveTimePath:=ExtractFilePath(Application.ExeName) + 'SfisTime.txt';
  IsExists:=FileExists(mSaveTimePath);
  if not IsExists then
  begin
       //��󤣦s�b�A�Ыؤ��
      AssignFile(FpSaveTime,mSaveTimePath );   //�Ыؤ奻���
      Rewrite(FpSaveTime);
      Writeln(FpSaveTime,'StartProgram         StartUp              EndUp');
  end else begin
      AssignFile(FpSaveTime,mSaveTimePath );
      Append(FpSaveTime);
  end;
  //��������ɶ�
  mStartE:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
  Writeln(FpSaveTime,mProgramS,'  ',mStartS,' ',mStartE);
  CloseFile(FpSaveTime);
  Cmd_Exit.Enabled:=TRUE;
  Cmd_ExitClick(nil);
end;

function TFrmLogin.JugeSnExistsAndStatus:string;
begin
    if StationProcessSeq=100 then begin
        //�K�[�O�sSerialCode�\��A���P�_���X�O�_�s�b�A���s�b�K�[
        DmWorkOrder.ADOS_JudgeCurrentSNExists.Parameters.ParamValues['@SerialCode']:=SerialCode;
        DmWorkOrder.ADOS_JudgeCurrentSNExists.Parameters.ParamValues['@Type']:=Trim(Ed_Type.Text);
        DmWorkOrder.ADOS_JudgeCurrentSNExists.ExecProc;
        if DmWorkOrder.ADOS_JudgeCurrentSNExists.Parameters.ParamValues['@outFlag']=0 then
        begin
            //���s�b�AInsert SerialCode
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@SerialCode']:=SerialCode;
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@WorkorderNo']:=Trim(Ed_WorkOrder.Text);
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@Type']:=Trim(Ed_Type.Text);
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@Model']:=Trim(Ed_Model.Text);
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@ProcessSeq']:=0;
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@HW']:='';
            DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@Line']:='';
            DmWorkOrder.ADOS_WriterSnSerialCode.ExecProc;
            if DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@outFlag']=0 then
            BEGIN
                ShowMsg(DmWorkOrder.ADOS_WriterSnSerialCode.Parameters.ParamValues['@Message']);
                StatusProgram:=2;
            end else begin
                StatusProgram:=1;
            END;
        end else begin
            //�s�b�A�P�_���A
            DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@SerialCode']:=SerialCode;
            DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@ProcessSeQ']:=StationProcessSeq;
            DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@Type']:=Trim(Ed_Type.Text);
            DmWorkOrder.ADOS_JudgeCurrentSNStatus.ExecProc;
            if DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@outFlag']=0 then begin
                ShowMsg(DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@Message']);
                StatusProgram:=3;
            end else begin
                StatusProgram:=1;
            end;
        end;
    end else if Ed_StationCode.Text='OQC' then begin
        DmWorkOrder.ADOS_JudgeSNStatusOQC.Parameters.ParamValues['@SerialCode']:=SerialCode;
        DmWorkOrder.ADOS_JudgeSNStatusOQC.Parameters.ParamValues['@StationName']:='OQC';
        DmWorkOrder.ADOS_JudgeSNStatusOQC.Parameters.ParamValues['@Type']:=SerialCode;
        if DmWorkOrder.ADOS_JudgeSNStatusOQC.Parameters.ParamValues['@outFlag']=0 then begin
            ShowMsg(DmWorkOrder.ADOS_JudgeSNStatusOQC.Parameters.ParamValues['@Message']);
            StatusProgram:=4;
        end else begin
            StatusProgram:=1;
        end;
    end else begin
        DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@SerialCode']:=SerialCode;
        DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@ProcessSeQ']:=StationProcessSeq;
        DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@Type']:=Trim(Ed_Type.Text);
        DmWorkOrder.ADOS_JudgeCurrentSNStatus.ExecProc;
        if DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@outFlag']=0 then begin
            ShowMsg(DmWorkOrder.ADOS_JudgeCurrentSNStatus.Parameters.ParamValues['@Message']);
            StatusProgram:=3;
        end else begin
            StatusProgram:=1;
        end;
    end;
    if Ed_StationCode.Text='AOO' then begin
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@SerialCode']:=SerialCode;
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@WorkorderNo']:=Trim(Ed_WorkOrder.Text);
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@LensID']:=LensID;
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@Module_Number']:=Module_Number;
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@Type']:=Trim(Ed_Type.Text);
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@Model']:=Trim(Ed_Model.Text);
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@ProcessSeq']:=0;
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@HW']:='';
            DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@Line']:='';
            DmWorkOrder.ADOS_WriterSnSerialCodeID.ExecProc;
            if DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@OutFlag']=0 then
            BEGIN
                ShowMsg(DmWorkOrder.ADOS_WriterSnSerialCodeID.Parameters.ParamValues['@Message']);
                StatusProgram:=2;
            end else begin
                StatusProgram:=1;
            END;
     end;

end;

procedure TFrmLogin.tmr_startTimer(Sender: TObject);
begin
    Cmd_Start.Click;
end;

end.
