unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    Image3: TImage;
    LabTitle2: TLabel;
    sbtnconfirm: TSpeedButton;
    LabTitle1: TLabel;
    QryTemp: TClientDataSet;
    Label1: TLabel;
    Label10: TLabel;
    lablType: TLabel;
    Image1: TImage;
    sbtnClear: TSpeedButton;
    SProc: TClientDataSet;
    lablMsg: TLabel;
    Labwoqty: TLabel;
    SpeedButton1: TSpeedButton;
    Qrydata: TClientDataSet;
    PanelMsg: TPanel;
    DataSource1: TDataSource;
    QryCarton: TClientDataSet;
    LabCnt: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edtwo: TEdit;
    Label4: TLabel;
    Edtpallet: TEdit;
    Label5: TLabel;
    Edtpartno: TEdit;
    SpeedButton2: TSpeedButton;
    Edtsn: TEdit;
    DBGrid1: TDBGrid;
    SpeedButton3: TSpeedButton;
    Image2: TImage;
    LBLSTATUS: TLabel;
    CMBBOXTYPE: TComboBox;
    Label6: TLabel;
    Label7: TLabel;
    EdTCUSTPARTNO: TEdit;
    Image4: TImage;
    SpeedButton4: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure EdtsnKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdtwoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdtwoChange(Sender: TObject);
    procedure sbtnClearClick(Sender: TObject);
    procedure sbtnconfirmClick(Sender: TObject);
    procedure CMBBOXTYPEChange(Sender: TObject);
    procedure EdTCUSTPARTNOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdTCUSTPARTNOChange(Sender: TObject);
    procedure EdtsnChange(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    g_orgid: string;
    function get_orgid(tempid:string):string;

  end;

var
  fDetail: TfDetail;

implementation

{$R *.DFM}
uses uDllform, unitDataBase, DllInit, uLogin, uData;

function TfDetail.get_orgid(tempid:string):string;
begin
    with qrycarton do
    begin
        close;
        params.Clear ;
        commandtext:='SELECT FACTORY_CODE as ORG_ID FROM SAJET.SYS_FACTORY a, SAJET.SYS_EMP b '
                    +' WHERE b.EMP_ID ='+ tempid
                    +' AND a.FACTORY_ID = b.FACTORY_ID AND rownum = 1 ';
        open;
        result:=fieldbyname('org_id').AsString ;
    end;
end;

procedure TfDetail.FormShow(Sender: TObject);
Var sTable : String;
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
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
    Params.ParamByName('dll_name').AsString := 'MRBDLL.DLL';
    Open;
    //LabTitle1.Caption := FieldByName('f1').AsString+'  ';
   // LabTitle2.Caption := LabTitle1.Caption;  
  end;

  edtwo.Clear ;
  edtwo.SetFocus ;
  edtpallet.Clear ;
  edtpartno.Enabled :=TRUE;
  edtpartno.Clear ;
  edtcustpartno.Enabled :=TRUE;
  edtcustpartno.Clear ;
  edtsn.Enabled :=TRUE;
  edtsn.Clear ;
  lblstatus.Caption :='';

  g_orgid:=get_orgid(fDllForm.UpdateUserID);
  if trim(g_orgid)='' then
    showmessage('ORG_ID IS ERROR!');
  LabTitle1.Caption :=LabTitle1.Caption +'('+g_orgid+')';
  LabTitle2.Caption :=LabTitle2.Caption +'('+g_orgid+')';

end;

procedure TfDetail.SpeedButton1Click(Sender: TObject);
var fData:tfData;
begin
  fData:=Tfdata.Create(self);
  fdata.DataSource1.DataSet:=qrytemp;
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
    Params.CreateParam(ftString, 'org_id', ptInput);
    commandtext:='SELECT distinct work_order  FROM SAJET.MES_TO_MRB_SN where work_order like :work_order and move_flag=''N'' and org_id=:org_id ';
    Params.ParamByName('WORK_ORDER').AsString := trim(edtwo.Text)+'%';
    Params.ParamByName('org_id').AsString := g_orgid;
    open;
  end;
  if fdata.ShowModal=mrOK then
  begin
    edtwo.Text:=qrytemp.fieldbyname('WORK_ORDER').AsString;
  end;

END;

procedure TfDetail.SpeedButton2Click(Sender: TObject);
var fData:tfData;
begin
  fData:=Tfdata.Create(self);
  fdata.DataSource1.DataSet:=qrytemp;
  with qrytemp do
  begin
    close;
    params.Clear;
    Params.CreateParam(ftString, 'part_no', ptInput);
    commandtext:='select part_no,spec1 from sajet.sys_part where PART_NO like :PART_NO AND  enabled=''Y'' ';
    Params.ParamByName('part_no').AsString := trim(edtpartno.Text)+'%';
    open;
  end;
  if fdata.ShowModal=mrOK then
  begin
    edtPARTNO.Text:=qrytemp.fieldbyname('PART_NO').AsString;
  end;

end;

procedure TfDetail.SpeedButton3Click(Sender: TObject);
begin
  with sproc do
   begin
    try
      close;
      DataRequest('SAJET.MES_MRB_GET_ID');
      FetchParams;
      Params.ParamByName('TTYPE').AsString :='B';
      Execute;
      edtwo.Text :=Params.ParamByName('TRES').AsString;
    finally
      close;
    end;
   with sproc do
    begin
     try
        close;
        DataRequest('SAJET.MES_MRB_GET_ID');
        FetchParams;
        Params.ParamByName('TTYPE').AsString :='FMB';
        Execute;
        edtPALLET.Text :=Params.ParamByName('TRES').AsString;
        finally
        close;
      end;
     END;


  end;
end;


procedure TfDetail.EdtsnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var  result: string;
begin
    IF TRIM(EDTWO.Text )='' THEN
       BEGIN
           LBLSTATUS.Caption :='WO IS NULL';
           EXIT;
       END;
    IF TRIM(EDTPALLET.Text  )='' THEN
       BEGIN
           LBLSTATUS.Caption :='PALLET IS NULL';
           EXIT;
       END;
   IF TRIM(EDTPARTNO.Text )='' THEN
       BEGIN
           LBLSTATUS.Caption :='PART_NO IS NULL';
           EXIT;
       END;
   IF TRIM(EDTCUSTPARTNO.Text  )='' THEN
       BEGIN
           LBLSTATUS.Caption :='CUST_PARTNO IS NULL';
           EXIT;
       END;
    IF trim(edtsn.text)<>'' then
     if key=13 then
      Begin
       with sproc do
         begin
           try
               close;
               //  SAJET.MES_MRB_SN_INPUT(TTYPE IN VARCHAR2,TPARTNO IN VARCHAR2, TWO IN VARCHAR2,
               //TPALLET IN VARCHAR2,TSN IN VARCHAR2, TEMPID IN VARCHAR2,TCUSTPARTNO IN VARCHAR2, TRES OUT VARCHAR2) AS
               DataRequest('SAJET.MES_MRB_SN_INPUT');
               FetchParams;
               Params.ParamByName('TTYPE').AsString :='MB';
               Params.ParamByName('TPARTNO').AsString :=EDTPARTNO.Text ;
               Params.ParamByName('TWO').AsString :=EDTWO.Text ;
               Params.ParamByName('TPALLET').AsString :=EDTPALLET.Text  ;
               Params.ParamByName('TSN').AsString :=TRIM(EDTSN.Text);
               Params.ParamByName('TEMPID').AsString :=fDllForm.UpdateUserID ;
               Params.ParamByName('TCUSTPARTNO').AsString :=EDTCUSTPARTNO.Text  ;
               Execute;
               result:=Params.ParamByName('TRES').AsString;
               if result='OK' then
                  begin
                     edtsn.Enabled :=false;
                     edtcustpartno.Enabled:=true;
                     edtcustpartno.Clear;
                     edtcustpartno.SelectAll ;
                     edtcustpartno.SetFocus ;
                     lblstatus.Caption :=edtsn.Text+' ADD OK '
                  end
               else
                  begin
                     edtsn.SelectAll ;
                     edtsn.SetFocus;
                     lblstatus.Caption :=result;
                  end;

            finally
              close;
            end;
         END;
         with qryDATA do
           begin
              close;
              params.Clear;
              Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
              commandtext:=' SELECT A.SERIAL_NUMBER, B.PART_NO,A.WORK_ORDER,A.PALLET_NO,A.MOVE_FLAG,A.CUST_PART_NO FROM '
                   +' (SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG,CUST_PART_NO FROM SAJET.MES_TO_MRB_SN WHERE  WORK_ORDER=:WORK_ORDER)  A, '
                   +' SAJET.SYS_PART B WHERE '
                   +' A.ITEM_ID=B.OPTION7 '  ;
             Params.ParamByName('WORK_ORDER').AsString :=edtwo.Text;
             open;
             lblstatus.Caption := lblstatus.Caption+'('+INTTOSTR(RECORDCOUNT)+')';
           END;
      end;
end;

procedure TfDetail.EdtwoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    IF TRIM(EDTWO.Text )<>'' THEN
    IF KEY=13 THEN
    with qryDATA do
     begin
       close;
       params.Clear;
       Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
       Params.CreateParam(ftString, 'org_id', ptInput);
       commandtext:=' SELECT A.SERIAL_NUMBER, B.PART_NO,A.WORK_ORDER,A.PALLET_NO,A.MOVE_FLAG,A.CUST_PART_NO FROM '
                   +' (SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG,CUST_PART_NO FROM SAJET.MES_TO_MRB_SN WHERE  WORK_ORDER=:WORK_ORDER and org_id=:org_id   '
                   +' UNION ALL '
                   +' SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG,CUST_PART_NO FROM SAJET.MES_HT_TO_MRB_SN WHERE WORK_ORDER=:WORK_ORDER and org_id=:org_id  ) A, '
                   +' SAJET.SYS_PART B WHERE '
                   +' A.ITEM_ID=B.OPTION7 '  ;
       Params.ParamByName('WORK_ORDER').AsString :=edtwo.Text;
       Params.ParamByName('org_id').AsString :=g_orgid;
       open;

       IF NOT ISEMPTY THEN
          BEGIN
              edtpallet.Text :=fieldbyname('pallet_no').AsString ;
              edtpartno.Text :=fieldbyname('part_no').AsString ;
              edtpartno.Enabled :=false;
              if   fieldbyname('MOVE_FLAG').AsString='Y'  then
                    edtsn.Enabled :=false;
          END;

     end;

end;

procedure TfDetail.EdtwoChange(Sender: TObject);
begin
   EDTPALLET.Clear ;
   EDTPARTNO.Clear ;
   EDTCUSTPARTNO.Clear ;
   EDTSN.Clear ;
end;

procedure TfDetail.sbtnClearClick(Sender: TObject);
begin
 IF TRIM(EDTPALLET.Text) <>'' THEN
 if MessageDlg('CLEAR [' + EDTPALLET.Text  +  '] ,Are you Sure?', mtCustom, mbOKCancel, 0) = mrOK  then
   BEGIN
    with qrytemp do
      begin
        begin
          close;
          params.Clear;
          Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
          Params.CreateParam(ftString, 'PALLET_NO', ptInput);
          commandtext:='delete sajet.MES_TO_MRB_SN where work_order=:work_order and pallet_no=:pallet_no and move_flag=''N'' ' ;
          Params.ParamByName('WORK_ORDER').AsString :=edtwo.Text;
          params.ParamByName('pallet_no').AsString :=edtpallet.Text;
          execute;
        END;

      with qryDATA do
           begin
              close;
              params.Clear;
              Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
              commandtext:=' SELECT A.SERIAL_NUMBER, B.PART_NO,A.WORK_ORDER,A.PALLET_NO,A.MOVE_FLAG FROM '
                   +' (SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG FROM SAJET.MES_TO_MRB_SN WHERE  WORK_ORDER=:WORK_ORDER)  A, '
                   +' SAJET.SYS_PART B WHERE '
                   +' A.ITEM_ID=B.OPTION7 '  ;
             Params.ParamByName('WORK_ORDER').AsString :=edtwo.Text;
             open;

             if isempty then
                lblstatus.Caption := 'DELETE ALL OK ' ;
           end;
          
      end;
   END;
end;

procedure TfDetail.sbtnconfirmClick(Sender: TObject);
begin
    IF TRIM(CMBBOXTYPE.Text) ='' THEN
      BEGIN
          LBLSTATUS.Caption :='TYPE IS NULL';
          EXIT;
      END;
    IF TRIM(EDTPALLET.Text) ='' THEN
      BEGIN
          LBLSTATUS.Caption :='PALLET IS NULL';
          EXIT;
      END;

    if MessageDlg('TYPE IS [ '+CMBBOXTYPE.Text+' ], CONFIRM [' + EDTPALLET.Text  +  '] ,Are you Sure?', mtCustom, mbOKCancel, 0) = mrOK  then
       BEGIN
          with sproc do
            begin
             try
               close;
               //MES_MRB_SN_CONFIRM(TWO IN VARCHAR2, TPALLET IN VARCHAR2,TTRANSFERTYPE IN VARCHAR2, TEMPID IN VARCHAR2, TRES OUT VARCHAR2) AS
               DataRequest('SAJET.MES_MRB_SN_CONFIRM');
               FetchParams;
               Params.ParamByName('TWO').AsString :=EDTWO.Text ;
               Params.ParamByName('TPALLET').AsString :=EDTPALLET.Text  ;
               Params.ParamByName('TTRANSFERTYPE').AsString :=CMBBOXTYPE.Text   ;
               Params.ParamByName('TEMPID').AsString :=fDllForm.UpdateUserID ;
               Execute;
               lblstatus.Caption:=Params.ParamByName('TRES').AsString;
              finally
              close;
             end;
            end;
         with qryDATA do
           begin
              close;
              params.Clear;
              Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
              commandtext:=' SELECT A.SERIAL_NUMBER, B.PART_NO,A.WORK_ORDER,A.PALLET_NO,A.MOVE_FLAG FROM '
                   +' (SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG FROM SAJET.MES_TO_MRB_SN WHERE  WORK_ORDER=:WORK_ORDER)  A, '
                   +' SAJET.SYS_PART B WHERE '
                   +' A.ITEM_ID=B.OPTION7 '  ;
             Params.ParamByName('WORK_ORDER').AsString :=edtwo.Text;
             open;
             IF NOT ISEMPTY THEN
              BEGIN
                 edtpallet.Text :=fieldbyname('pallet_no').AsString ;
                 edtpartno.Text :=fieldbyname('part_no').AsString ;
                 edtpartno.Enabled :=false;
                 if   fieldbyname('MOVE_FLAG').AsString='Y'  then
                    edtsn.Enabled :=false;
              END;
           end;
      end;
end;

procedure TfDetail.CMBBOXTYPEChange(Sender: TObject);
begin
    IF CMBBOXTYPE.Text ='BG' THEN
       LBLSTATUS.Caption :='1(RAW-->MRB/FG) OR 3(FG-->MRB/FG)';
    IF CMBBOXTYPE.Text ='BJ' THEN
       LBLSTATUS.Caption :='2A_Single(RAW-->MRB/FG)';
    IF CMBBOXTYPE.Text ='BK' THEN
       LBLSTATUS.Caption :='2B_Multiple(RAW-->MRB/FG)';
end;

procedure TfDetail.EdTCUSTPARTNOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    IF trim(edtcustpartno.Text )<>'' then
     IF KEY=13 then
     with qrytemp do
        begin
          close;
          params.Clear;
          Params.CreateParam(ftString, 'part_no', ptInput);
          Params.CreateParam(ftString, 'cust_part_no', ptInput);
          commandtext:='select part_no from sajet.sys_part where part_no=:part_no and  cust_part_no=:cust_part_no AND rownum=1 ' ;
          Params.ParamByName('part_no').AsString :=edtpartno.Text ;
          params.ParamByName('cust_part_no').AsString :=edtcustpartno.Text;
          open;

          if isempty then
            begin
               LBLSTATUS.Caption :='CUST_PART_NO NOT FIND';
               edtcustpartno.SelectAll ;
               edtcustpartno.SetFocus ;
               exit;
            end;
          if not isempty then
            begin
                edtcustpartno.Enabled :=false;
                edtsn.Enabled:=true;
                edtsn.Clear ;
                edtsn.SelectAll ;
                edtsn.SetFocus ;
            end;

        END;

end;

procedure TfDetail.EdTCUSTPARTNOChange(Sender: TObject);
begin
   LBLSTATUS.Caption:='';
end;

procedure TfDetail.EdtsnChange(Sender: TObject);
begin
   LBLSTATUS.Caption:='';
end;

procedure TfDetail.SpeedButton4Click(Sender: TObject);
begin
    IF EDTSN.Enabled=FALSE THEN
       EDTSN.ENABLED:=TRUE;
    if trim(edtsn.Text )<>'' then   
    with qryDATA do
     begin
       close;
       params.Clear;
       Params.CreateParam(ftString, 'SERIAL_NUMBER', ptInput);
       Params.CreateParam(ftString, 'org_id', ptInput);
       commandtext:=' SELECT A.SERIAL_NUMBER, B.PART_NO,A.WORK_ORDER,A.PALLET_NO,A.MOVE_FLAG,A.CUST_PART_NO FROM '
                   +' (SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG,CUST_PART_NO FROM SAJET.MES_TO_MRB_SN WHERE  SERIAL_NUMBER=:SERIAL_NUMBER and org_id=:org_id '
                   +' UNION ALL '
                   +' SELECT SERIAL_NUMBER, ITEM_ID,WORK_ORDER,PALLET_NO,MOVE_FLAG,CUST_PART_NO FROM SAJET.MES_HT_TO_MRB_SN WHERE SERIAL_NUMBER=:SERIAL_NUMBER and org_id=:org_id ) A, '
                   +' SAJET.SYS_PART B WHERE '
                   +' A.ITEM_ID=B.OPTION7 '  ;
       Params.ParamByName('SERIAL_NUMBER').AsString :=edtsn.Text;
       Params.ParamByName('org_id').AsString :=g_orgid;
       open;

       IF NOT ISEMPTY THEN
          EDTWO.Text :=FIELDBYNAME('WORK_ORDER').AsString ;
    END;
          
end;

end.

