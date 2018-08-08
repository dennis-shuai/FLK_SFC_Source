unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils, Menus;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    qrytemp1: TClientDataSet;
    Label2: TLabel;
    cmbShift: TComboBox;
    Label3: TLabel;
    cmbWS: TComboBox;
    WorkShop: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet6: TTabSheet;
    SMT_A: TPanel;
    SMT_B: TPanel;
    SMT_C: TPanel;
    COB_DB_A: TPanel;
    COB_DB_B: TPanel;
    COB_DB_C: TPanel;
    COB_HM_01: TPanel;
    COB_HM_02: TPanel;
    COB_HM_03: TPanel;
    COB_HM_04: TPanel;
    COB_HM_08: TPanel;
    COB_HM_07: TPanel;
    COB_HM_06: TPanel;
    COB_HM_05: TPanel;
    COB_DB_F: TPanel;
    COB_DB_E: TPanel;
    COB_DB_D: TPanel;
    PopupMenu1: TPopupMenu;
    btnquery: TSpeedButton;
    Image1: TImage;
    sh1: TMenuItem;
    N1: TMenuItem;
    SMT_D: TPanel;
    TabSheet5: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label12: TLabel;
    CM1_1: TPanel;
    CM1_01: TPanel;
    CM1_06: TPanel;
    CM1_04: TPanel;
    CM1_05: TPanel;
    CM1_03: TPanel;
    CM1_02: TPanel;
    CM11: TPanel;
    CM11_03: TPanel;
    CM11_04: TPanel;
    CM11_02: TPanel;
    CM11_01: TPanel;
    CM1_2: TPanel;
    CM1_08: TPanel;
    CM1_11: TPanel;
    CM1_12: TPanel;
    CM1_10: TPanel;
    CM1_09: TPanel;
    AF01_1: TPanel;
    AF01_10: TPanel;
    AF01_05: TPanel;
    AF01_07: TPanel;
    AF01_06: TPanel;
    AF01_08: TPanel;
    AF01_09: TPanel;
    AF01_04: TPanel;
    AF02_1: TPanel;
    AF02_07: TPanel;
    AF02_02: TPanel;
    AF02_04: TPanel;
    AF02_03: TPanel;
    AF02_05: TPanel;
    AF02_06: TPanel;
    AF02_01: TPanel;
    AF01_03: TPanel;
    AF01_02: TPanel;
    AF01_01: TPanel;
    AF01_2: TPanel;
    AF01_12: TPanel;
    AF01_14: TPanel;
    AF01_13: TPanel;
    AF01_15: TPanel;
    AF01_11: TPanel;
    AF03_1: TPanel;
    AF03_07: TPanel;
    AF03_02: TPanel;
    AF03_04: TPanel;
    AF03_03: TPanel;
    AF03_05: TPanel;
    AF03_06: TPanel;
    AF03_01: TPanel;
    AF02_2: TPanel;
    AF02_09: TPanel;
    AF02_11: TPanel;
    AF02_10: TPanel;
    AF02_12: TPanel;
    AF02_08: TPanel;
    AF03_2: TPanel;
    AF03_09: TPanel;
    AF03_11: TPanel;
    AF03_10: TPanel;
    AF03_12: TPanel;
    AF03_08: TPanel;
    AF04_2: TPanel;
    AF04_09: TPanel;
    AF04_11: TPanel;
    AF04_10: TPanel;
    AF04_12: TPanel;
    AF04_08: TPanel;
    AF04_1: TPanel;
    AF04_07: TPanel;
    AF04_02: TPanel;
    AF04_04: TPanel;
    AF04_03: TPanel;
    AF04_05: TPanel;
    AF04_06: TPanel;
    AF04_01: TPanel;
    CM_583: TPanel;
    CM_585: TPanel;
    CM7_1: TPanel;
    CM9_01: TPanel;
    CM9_06: TPanel;
    CM9_04: TPanel;
    CM9_05: TPanel;
    CM9_03: TPanel;
    CM9_02: TPanel;
    CM_VI01: TPanel;
    CM_VI02: TPanel;
    CM_VI03: TPanel;
    CM_VI04: TPanel;
    CM_VI05: TPanel;
    CM1_07: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    CM_R6: TPanel;
    CM_252: TPanel;
    Panel1: TPanel;
    CM2_01: TPanel;
    CM2_06: TPanel;
    CM2_04: TPanel;
    CM2_05: TPanel;
    CM2_03: TPanel;
    CM2_02: TPanel;
    Panel8: TPanel;
    CM2_08: TPanel;
    CM2_11: TPanel;
    CM2_12: TPanel;
    CM2_10: TPanel;
    CM2_09: TPanel;
    CM2_07: TPanel;
    Panel15: TPanel;
    CM3_01: TPanel;
    CM3_06: TPanel;
    CM3_04: TPanel;
    CM3_05: TPanel;
    CM3_03: TPanel;
    CM3_02: TPanel;
    Panel22: TPanel;
    CM3_08: TPanel;
    CM3_11: TPanel;
    CM3_12: TPanel;
    CM3_10: TPanel;
    CM3_09: TPanel;
    CM3_07: TPanel;
    Panel29: TPanel;
    CM4_01: TPanel;
    CM4_06: TPanel;
    CM4_04: TPanel;
    CM4_05: TPanel;
    CM4_03: TPanel;
    CM4_02: TPanel;
    Panel36: TPanel;
    CM4_08: TPanel;
    CM4_11: TPanel;
    CM4_12: TPanel;
    CM4_10: TPanel;
    CM4_09: TPanel;
    CM4_07: TPanel;
    Panel43: TPanel;
    CM5_01: TPanel;
    CM5_06: TPanel;
    CM5_04: TPanel;
    CM5_05: TPanel;
    CM5_03: TPanel;
    CM5_02: TPanel;
    Panel50: TPanel;
    CM5_08: TPanel;
    CM5_11: TPanel;
    CM5_12: TPanel;
    CM5_10: TPanel;
    CM5_09: TPanel;
    CM5_07: TPanel;
    Panel57: TPanel;
    CM6_01: TPanel;
    CM6_06: TPanel;
    CM6_04: TPanel;
    CM6_05: TPanel;
    CM6_03: TPanel;
    CM6_02: TPanel;
    Panel64: TPanel;
    CM6_08: TPanel;
    CM6_11: TPanel;
    CM6_12: TPanel;
    CM6_10: TPanel;
    CM6_09: TPanel;
    CM6_07: TPanel;
    lbl6: TLabel;
    lbl7: TLabel;
    CM9_07: TPanel;
    CM9_08: TPanel;
    Panel2: TPanel;
    CM7_01: TPanel;
    CM7_06: TPanel;
    CM7_04: TPanel;
    CM7_05: TPanel;
    CM7_03: TPanel;
    CM7_02: TPanel;
    Panel10: TPanel;
    CM8_01: TPanel;
    CM8_06: TPanel;
    CM8_04: TPanel;
    CM8_05: TPanel;
    CM8_03: TPanel;
    CM8_02: TPanel;
    CM_645: TPanel;
    Panel3: TPanel;
    CM1_MAT01: TPanel;
    CM1_MAT04: TPanel;
    CM1_MAT03: TPanel;
    CM1_MAT02: TPanel;
    CM1_MATC01: TPanel;
    Panel4: TPanel;
    CM1_MAT05: TPanel;
    CM1_MAT08: TPanel;
    CM1_MAT07: TPanel;
    CM1_MAT06: TPanel;
    CM1_MATC02: TPanel;
    lbl4: TLabel;
    CM8: TPanel;
    CM_651AF_01: TPanel;
    CM_651AF_06: TPanel;
    CM_651AF_04: TPanel;
    CM_651AF_05: TPanel;
    CM_651AF_03: TPanel;
    CM_651AF_02: TPanel;
    CM25: TPanel;
    CM_650FQC_05: TPanel;
    CM_650FQC_08: TPanel;
    CM_650FQC_07: TPanel;
    CM_650FQC_06: TPanel;
    CM33: TPanel;
    CM_650FQC_09: TPanel;
    CM_650FQC_12: TPanel;
    CM_650FQC_11: TPanel;
    CM_650FQC_10: TPanel;
    CM38: TPanel;
    CM_650AF_02: TPanel;
    CM_650AF_01: TPanel;
    CM_650AF_04: TPanel;
    CM_650AF_03: TPanel;
    CM_650AF_05: TPanel;
    CM_650AF_06: TPanel;
    CM16: TPanel;
    CM17: TPanel;
    CM18: TPanel;
    CM19: TPanel;
    CM20: TPanel;
    CM21: TPanel;
    CM22: TPanel;
    CM23: TPanel;
    CM_650FQC_01: TPanel;
    CM_650FQC_04: TPanel;
    CM_650FQC_03: TPanel;
    CM_650FQC_02: TPanel;
    CM45: TPanel;
    CM_650AF_08: TPanel;
    CM_650AF_07: TPanel;
    CM_650AF_10: TPanel;
    CM_650AF_09: TPanel;
    CM_650AF_11: TPanel;
    CM_650AF_12: TPanel;
    CM_651AF_18: TPanel;
    CM_651AF_17: TPanel;
    CM_651AF_16: TPanel;
    CM_651AF_15: TPanel;
    CM_651AF_14: TPanel;
    CM_651AF_13: TPanel;
    CM84: TPanel;
    CM_651FQC_12: TPanel;
    CM_651FQC_07: TPanel;
    CM_651FQC_09: TPanel;
    CM_651FQC_08: TPanel;
    CM_651FQC_10: TPanel;
    CM_651FQC_11: TPanel;
    CM1: TPanel;
    CM_651AF_07: TPanel;
    CM_651FQC_03: TPanel;
    CM_651FQC_01: TPanel;
    CM_651FQC_02: TPanel;
    CM_651AF_09: TPanel;
    CM_651AF_08: TPanel;
    CM_651AF_12: TPanel;
    CM_651AF_11: TPanel;
    CM_651AF_10: TPanel;
    CM_651FQC_06: TPanel;
    CM_651FQC_05: TPanel;
    CM_651FQC_04: TPanel;
    CM58: TPanel;
    CM_651AF_19: TPanel;
    CM_651AF_24: TPanel;
    CM_651AF_22: TPanel;
    CM_651AF_23: TPanel;
    CM_651AF_21: TPanel;
    CM_651AF_20: TPanel;
    CM_651AF_30: TPanel;
    CM_651AF_29: TPanel;
    CM_651AF_28: TPanel;
    CM_651AF_27: TPanel;
    CM_651AF_26: TPanel;
    CM_651AF_25: TPanel;
    CM71: TPanel;
    CM_650AF_14: TPanel;
    CM_650AF_13: TPanel;
    CM_650AF_16: TPanel;
    CM_650AF_15: TPanel;
    CM_650AF_17: TPanel;
    CM_650AF_18: TPanel;
    CM78: TPanel;
    CM_650AF_20: TPanel;
    CM_650AF_19: TPanel;
    CM_650AF_22: TPanel;
    CM_650AF_21: TPanel;
    CM_650AF_23: TPanel;
    CM_650AF_24: TPanel;
    lbl5: TLabel;
    lbl8: TLabel;
    CM98: TPanel;
    CM_659AF_01: TPanel;
    CM_659AF_06: TPanel;
    CM_659AF_04: TPanel;
    CM_659AF_05: TPanel;
    CM_659AF_03: TPanel;
    CM_659AF_02: TPanel;
    CM_659AF_07: TPanel;
    CM_659AF_08: TPanel;
    CM_659AF_09: TPanel;
    CM108: TPanel;
    CM_659FQC_01: TPanel;
    CM_659FQC_03: TPanel;
    CM_659FQC_02: TPanel;
    lbl9: TLabel;
    CM2: TPanel;
    CM7_07: TPanel;
    CM7_12: TPanel;
    CM7_10: TPanel;
    CM7_11: TPanel;
    CM7_09: TPanel;
    CM7_08: TPanel;
    CM3: TPanel;
    CM8_07: TPanel;
    CM8_12: TPanel;
    CM8_10: TPanel;
    CM8_11: TPanel;
    CM8_09: TPanel;
    CM8_08: TPanel;
    procedure FormShow(Sender: TObject);
    procedure CM15_01DblClick(Sender: TObject);
    procedure CM15DblClick(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure ClearAllPanel;
    procedure sh1Click(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    iPrivilege:integer;
    UpdateUserID,sWorkDate,sShift,sShift_Id,sPd_Status,sRepair_status:string;
    Authoritys,AuthorityRole: String;
    sHourList:TStringList;
    function AddZero(s:string;HopeLength:Integer):String;
    procedure UpdateData(pdLine_Name,subPdline_Name:string);
    Procedure SetStatusbyAuthority;
    procedure qureypdlineInfo;
  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit, uSetting;


Procedure TfDetail.SetStatusbyAuthority;
begin
  // Read Only,Allow To Change,Full Control
  iPrivilege:=0;
  with sproc do
  begin
    try
       Close;
       DataRequest('SAJET.SJ_CHK_PRG_PRIVILEGE');
       FetchParams;
       Params.ParamByName('EMPID').AsString := UpdateUserID;
       Params.ParamByName('PRG').AsString := 'W/O Manager';
       Params.ParamByName('FUN').AsString :='開線設置';
       Execute;
       IF Params.ParamByName('TRES').AsString ='OK' Then
       begin
        iPrivilege := Params.ParamByName('PRIVILEGE').AsInteger;
       end;
    finally
      close;
    end;
  end;
end;


function TfDetail.AddZero(s:string;HopeLength:Integer):String;
begin
   Result:=StringReplace(Format('%'+IntToStr(HopeLength)+'s',[s]),' ','0',[rfIgnoreCase,rfReplaceAll]);
end;

procedure TfDetail.ClearAllPanel;
var
  i,j:integer;
begin
  for i:=1 to 12 do begin
      for j:=1 to 8 do
      TPanel(FindComponent('CM'+INTTOSTR(j)+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
  end;

  


   for j:=1 to 5 do
    TPanel(FindComponent('CM_VI'+AddZero(IntToStr(j),2))).Color :=cl3DDkShadow;



   for i:=1 to 4 do
   begin
      TPanel(FindComponent('CM11'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
   end;

    for i:=1 to 30 do
    begin
      TPanel(FindComponent('CM_651AF'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;


    for i:=1 to 9 do
    begin
      TPanel(FindComponent('CM_659AF'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;

    for i:=1 to 3 do
    begin
      TPanel(FindComponent('CM_659FQC'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;

    for i:=1 to 12 do
    begin
      TPanel(FindComponent('CM_651FQC'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;

    for i:=1 to 24 do
    begin
      TPanel(FindComponent('CM_650AF'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;

    for i:=1 to 12 do
    begin
      TPanel(FindComponent('CM_650FQC'+ '_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;
    end;
  
    for j:=1 to 4 do
      for i:=1 to 12 do
       TPanel(FindComponent('AF0'+IntToStr(j)+'_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;

    for i:=13 to 15 do
      TPanel(FindComponent('AF01_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;

    TPanel(FindComponent('CM_R6')).Color :=cl3DDkShadow;
    TPanel(FindComponent('CM_252')).Color :=cl3DDkShadow;
    TPanel(FindComponent('CM_583')).Color :=cl3DDkShadow;
    TPanel(FindComponent('CM_585')).Color :=cl3DDkShadow;
    TPanel(FindComponent('CM_645')).Color :=cl3DDkShadow;

   //for i:=1 to 3 do
    TPanel(FindComponent('SMT_A')).Color :=cl3DDkShadow;
    TPanel(FindComponent('SMT_B')).Color :=cl3DDkShadow;
    TPanel(FindComponent('SMT_C')).Color :=cl3DDkShadow;
    TPanel(FindComponent('SMT_D')).Color :=cl3DDkShadow;
   //SHowMessage(chr(65));
    for i:=1 to 6 do
      TPanel(FindComponent('COB_DB_'+ chr(64+i))).Color :=cl3DDkShadow;

    for i:=1 to 8 do
      TPanel(FindComponent('COB_HM_'+AddZero(IntToStr(i),2))).Color :=cl3DDkShadow;

end;

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin
  cmbShift.Style :=csDropDownList;
  cmbWS.Style :=csDropDownList;
  DateTimePicker1.Date := now;
  for i:=0 to WorkShop.PageCount-1 do
    WorkShop.Pages[i].TabVisible:=False;
  SetStatusbyAuthority;
  cmbWS.ItemIndex := 4;
  cmbShift.ItemIndex :=0;
end;

procedure TfDetail.CM15_01DblClick(Sender: TObject);
var sRepairStatus:string;
begin
   if iPrivilege <=0 then exit;
   sWorkDate := FormatDateTime('YYYYMMDD',DateTimePicker1.Date);
   if (sender as TPANEL).Color = cl3DDkShadow then
   begin
        sPd_Status :='1';
        with qrytemp do begin
             Close;
             Params.Clear;
             Params.CreateParam(ftstring,'Pdline',ptInput);
             Params.CreateParam(ftstring,'SHIFT',ptInput);
             Params.CreateParam(ftstring,'WORKDATE',ptInput);
             CommandText := ' SELECT  NVL(PRODUCE_QTY,0)  Target_QTY , NVL(A.WORK_HOUR,0) WORK_HOUR, PD_STATUS,'+
                            ' NVL(WORK_HOUR,0)WORK_HOUR , Repair_LINE ,UPH FROM SAJET.G_PDLINE_MANAGE A, '+
                            ' SAJET.SYS_PDLINE B ,SAJET.SYS_SHIFT C'+
                            ' WHERE PDLINE_NAME = :PDLINE AND A.PDLINE_ID=B.PDLINE_ID AND '+
                            ' A.SHIFT_ID =C.SHIFT_ID AND  A.WORK_DATE =:WORKDATE  AND C.SHIFT_NAME =:SHIFT ';
             Params.ParamByName('Pdline').AsString := (sender as TPANEL).Name;
             Params.ParamByName('SHIFT').AsString :=  cmbShift.Text;
             Params.ParamByName('WORKDATE').AsString := sWorkDate;
             Open;

             if IsEmpty then begin
                  sRepairStatus :='N';
             end else begin
                  sRepairStatus :=fieldbyname('Repair_LINE').AsString;;
             end;

        end;

        if  sRepairStatus='N' then
            (sender as TPANEL).Color  := clGreen
        else
            (sender as TPANEL).Color  := clYellow;

   end
   else
    if ((sender as TPANEL).Color = clGreen)  or
         ((sender as TPANEL).Color = clYellow ) then  begin
        (sender as TPANEL).Color  := cl3DDkShadow;
        sPd_Status :='0';
    end;

   //UpdateData( (sender as TPANEL).Name, (sender as TPANEL).Name);

end;

procedure TfDetail.CM15DblClick(Sender: TObject);
var i:integer;  sRepairStatus:string;
begin
    if iPrivilege <=0 then exit;
    if TPANEL((Sender as TPanel).Controls[0]).Color = cl3DDkShadow  then
      for i:=0 to  (Sender as TPanel).ControlCount-1 do begin
        if TPanel((Sender as TPanel).Controls[i]).Visible then begin

            sPd_Status :='1';

             with qrytemp do begin
                   Close;
                   Params.Clear;
                   Params.CreateParam(ftstring,'Pdline',ptInput);
                   Params.CreateParam(ftstring,'SHIFT',ptInput);
                   Params.CreateParam(ftstring,'WORKDATE',ptInput);
                   CommandText := ' SELECT  NVL(PRODUCE_QTY,0)  Target_QTY , NVL(A.WORK_HOUR,0) WORK_HOUR, '+
                                  ' NVL(WORK_HOUR,0)WORK_HOUR , Repair_LINE ,UPH FROM SAJET.G_PDLINE_MANAGE A, '+
                                  ' SAJET.SYS_PDLINE B ,SAJET.SYS_SHIFT C'+
                                  ' WHERE PDLINE_NAME = :PDLINE AND A.PDLINE_ID=B.PDLINE_ID AND '+
                                  ' A.SHIFT_ID =C.SHIFT_ID AND  A.WORK_DATE =:WORKDATE  AND C.SHIFT_NAME =:SHIFT ';
                   Params.ParamByName('Pdline').AsString := TPanel((Sender as TPanel).Controls[0]).Name;
                   Params.ParamByName('SHIFT').AsString :=  cmbShift.Text;
                   Params.ParamByName('WORKDATE').AsString := sWorkDate;
                   Open;

                   if IsEmpty then begin
                        sRepairStatus :='N';
                   end else begin
                        sRepairStatus :=fieldbyname('Repair_LINE').AsString;;
                   end;

              end;
              if  sRepairStatus='N' then
                  TPanel((Sender as TPanel).Controls[i]).Color   := clGreen
              else
                  TPanel((Sender as TPanel).Controls[i]).Color   := clYellow;


        end;
      end
    else  if (TPANEL((Sender as TPanel).Controls[0]).Color = clGreen) or
             (TPANEL((Sender as TPanel).Controls[0]).Color = clYellow) then
        for i:=0 to  (Sender as TPanel).ControlCount-1 do begin
             if TPanel((Sender as TPanel).Controls[i]).Visible then  begin
                TPanel((Sender as TPanel).Controls[i]).Color  := cl3DDkShadow;
                sPd_Status :='0';
             end;
        end;


     for i:=0 to   (Sender as TPanel).ControlCount-1 do begin
         if TPanel((Sender as TPanel).Controls[i]).Visible then  begin
             UpdateData(TPanel((Sender as TPanel).Controls[0]).Name, TPanel((Sender as TPanel).Controls[i]).Name);
        end;
   end;

end;

procedure TfDetail.UpdateData(pdLine_Name,subPdline_Name:string);
var sRes,sWorkHour,sTargetQty,sRepairStatus,sUPH:string;
begin

     with qrytemp do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftstring,'Pdline',ptInput);
         Params.CreateParam(ftstring,'SHIFT',ptInput);
         Params.CreateParam(ftstring,'WORKDATE',ptInput);
         CommandText := ' SELECT  NVL(PRODUCE_QTY,0)  Target_QTY , NVL(A.WORK_HOUR,0) WORK_HOUR, '+
                        ' NVL(WORK_HOUR,0)WORK_HOUR , Repair_LINE ,UPH FROM SAJET.G_PDLINE_MANAGE A, '+
                        ' SAJET.SYS_PDLINE B ,SAJET.SYS_SHIFT C'+
                        ' WHERE PDLINE_NAME = :PDLINE AND A.PDLINE_ID=B.PDLINE_ID AND '+
                        ' A.SHIFT_ID =C.SHIFT_ID AND  A.WORK_DATE =:WORKDATE  AND C.SHIFT_NAME =:SHIFT ';
         Params.ParamByName('Pdline').AsString := pdLine_Name;
         Params.ParamByName('SHIFT').AsString :=  cmbShift.Text;
         Params.ParamByName('WORKDATE').AsString := sWorkDate;
         Open;

         if IsEmpty then begin
              sWorkHour :='10.5';
              sUPH :='0';
              sTargetQty :='0';
              sRepairStatus :='N';
         end else begin
              sUPH :=  fieldbyname('UPH').AsString;
              sWorkHour :=  fieldbyname('WORK_HOUR').AsString;
              sTargetQty := fieldbyname('Target_QTY').AsString;
              sRepairStatus :=fieldbyname('Repair_LINE').AsString;;
         end;

     end;

     with sproc do
     begin
        close;
        datarequest('SAJET.CCM_UPDATE_PDLINE_MANAGE2');
        fetchparams;
        params.ParamByName('TWORK_DATE').AsString := sWorkDate ;
        params.ParamByName('TMODEL').AsString := 'N/A';
        params.ParamByName('TSHIFT').AsString := cmbShift.Text;
        params.ParamByName('TPDLINE_NAME').AsString := subPdline_Name ;
        params.ParamByName('TPD_STATUS').AsString :=sPd_Status ;
        params.ParamByName('TWORK_HOUR').AsString := sWorkHour;
        params.ParamByName('TUPH').AsString := sUPH;
        params.ParamByName('TPRODUCE_QTY').AsString := sTargetQty;
        params.ParamByName('TREPAIR_FLAG').AsString := sRepairStatus;
        params.ParamByName('TEMPID').AsString := UpdateUserID;
        execute;
        sRes := params.ParamByName('TRes').AsString ;

        if  sRes <>'OK' then begin
             MessageDlg(sRes,mterror,[MBOK],0);
             btnQuery.Click;
             exit;
        end;
    end;
    
end;

procedure TfDetail.btnqueryClick(Sender: TObject);
   var i,j:integer;
   sPdlineName:string;
begin
   ClearAllPanel;
   sWorkDate := FormatDateTime('YYYYMMDD',DateTimePicker1.Date);
   if cmbShift.ItemIndex <0 then begin
       MessageDlg('請選擇班別',mterror,[MBOK],0);
       Exit;
   end;
   if cmbShift.ItemIndex <0 then begin
       MessageDlg('請選擇車間',mterror,[MBOK],0);
       Exit;
   end;
   for i:=0 to WorkShop.PageCount-1 do
   WorkShop.Pages[i].TabVisible:=False;
   WorkShop.Pages[cmbWS.ItemIndex].TabVisible:=true;
   WorkShop.TabIndex := cmbWS.ItemIndex;



   with qrytemp do
   begin
       close;
       Params.Clear;
       Params.CreateParam(ftstring,'WORKDATE',ptInput);
       Params.CreateParam(ftstring,'SHIFTNAME',ptInput);
       CommandText := ' Select * FROM SAJET.G_PDLINE_MANAGE a,sajet.sys_shift b , '+
                      ' sajet.sys_PDLINE c WHERE  a.PDLINE_ID =c.PDLINE_ID and'+
                      ' a.WORK_DATE =:WORKDATE and b.SHIFT_Name =:SHIFTNAME   ' +
                      ' and a.shift_id =b.shift_id and b.enabled=''Y'' ';
       Params.ParamByName('WORKDATE').AsString := sWorkDate;
       Params.ParamByName('SHIFTNAME').AsString := cmbShift.Text;
       Open;
   end;

   qrytemp.First;
   for j:=0 to  qrytemp.RecordCount-1 do
   begin
       TRY
          sPdlineName := qrytemp.FieldByName('PDLINE_NAME').AsString;
          sPD_Status :=qrytemp.FieldByName('PD_STATUS').AsString;
          sShift_Id :=  qrytemp.FieldByName('Shift_id').AsString;
          sRepair_Status :=qrytemp.FieldByName('Repair_Line').AsString;
          if  sPD_Status='1' then
              TPanel(FindComponent(sPdlineName)).Color:=clGreen;
          if  sPD_Status ='0' then
              TPanel(FindComponent( sPdlineName)).Color :=cl3DDkShadow;
          if  (sRepair_Status ='Y') and (sPD_Status='1')then
              TPanel(FindComponent( sPdlineName)).Color :=clYellow;

       Except
           // MessageDlg(sPdlineName+':'+SPD_STATUS ,mtError,[mbOK],0);


       end;
       qrytemp.Next;
   end;

end;

procedure TfDetail.sh1Click(Sender: TObject);

begin
     uSettings := TuSettings.Create(Self);
     uSettings.lblPDLINE.Caption := popupmenu1.PopUpComponent.name;
     if iPrivilege <=0 then begin
        uSettings.btnCopyLine.Enabled :=false;
        uSettings.btnCopyToLine.Enabled :=false;
        uSettings.btnSave.Enabled :=false;
     end;


     qureypdlineInfo;

     uSettings.ShowModal;

end;

procedure TfDetail.qureypdlineInfo();
var i,j,ipos,iPos1:integer;
    stemp,sTime,sHour:string;
begin
  sHourList := TStringList.Create;

  if cmbShift.ItemIndex =0 then begin
       for i:=1 to 12 do begin
         with uSettings do
           TPANEL(FindComponent('PnlTime'+IntToStr(i))).caption := IntToStr(7+i);
           sHourList.Add( IntToStr(7+i));
       end;
   end;

   if cmbShift.ItemIndex =1 then begin
      with uSettings do
      begin
           for i:=1 to 4 do begin
               TPANEL(FindComponent('PnlTime'+IntToStr(i))).caption := IntToStr(19+i);
               sHourList.Add( IntToStr(19+i));
           end;
           for i:=5 to 12 do begin
               TPANEL(FindComponent('PnlTime'+IntToStr(i))).caption := IntToStr(i-5);
               sHourList.Add( IntToStr(i-5));
           end;
      end;
   end;

   with qrytemp do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftstring,'Pdline',ptInput);
         Params.CreateParam(ftstring,'SHIFT',ptInput);
         Params.CreateParam(ftstring,'WORKDATE',ptInput);
         CommandText := ' SELECT Model_NAME,HOURCOUNT, NVL(A.PRODUCE_QTY,0) Target_QTY ,PD_STATUS, NVL(A.WORK_HOUR,0) WORK_HOUR ,A.Repair_Line,A.UPH ,A.ROWID iROWID '+
                        ' FROM SAJET.G_PDLINE_MANAGE  A,SAJET.SYS_PDLINE B ,SAJET.SYS_SHIFT C'+
                        ' WHERE PDLINE_NAME = :PDLINE AND A.PDLINE_ID=B.PDLINE_ID AND  '+
                        ' A.SHIFT_ID =C.SHIFT_ID AND  A.WORK_DATE =:WORKDATE  AND C.SHIFT_NAME =:SHIFT ';
         Params.ParamByName('Pdline').AsString := popupmenu1.PopUpComponent.name;
         Params.ParamByName('SHIFT').AsString :=  cmbShift.Text;
         Params.ParamByName('WORKDATE').AsString := sWorkDate;
         Open;

         if not IsEmpty then begin



              if recordCount=1 then begin
                 uSettings.cmbModel.Text := fieldByName('Model_Name').AsString;

                 uSettings.edtHour.Text := fieldByName('WORK_HOUR').AsString;
                 if fieldByName('Repair_Line').AsString = 'Y'then
                     uSettings.chkIsRepair.Checked := true
                 else
                     uSettings.chkIsRepair.Checked := false;
                 uSettings.edtUPH.Text := fieldByName('UPH').AsString;
                 uSettings.edtQty.Text := fieldByName('Target_QTY').AsString;
                 if  fieldByName('PD_STATUS').AsString ='1' then begin
                     if fieldByName('Repair_Line').AsString ='Y' then
                        uSettings.pnlStatus.Color := clYellow
                     else
                        uSettings.pnlStatus.Color := clGreen;
                 end else
                     uSettings.pnlStatus.Color :=  cl3DDKShadow;

                  sTemp := fieldByName('HOURCOUNT').AsString;
                  if sTemp <> '' then begin

                      for i :=0 to 11 do begin
                         ipos :=pos(',',sTemp);
                         if ipos >0 then begin
                            sTime := Copy(sTemp,1,ipos-1);
                            ipos1 := pos(':',sTime);
                            shour :=  Copy(sTime,iPos1+1,length(sTime)-iPos1);
                            sTime :=  Copy(sTime,1,iPos1-1);
                         end  ;
                        { else begin
                            sTime :=sTemp;
                            ipos1 := pos(':',sTime);
                            shour :=  Copy(sTime,iPos1+1,length(sTime)-iPos1);
                            sTime :=  Copy(sTime,1,iPos1-1);
                         end; }
                        with uSettings do begin
                             for j:=0 to 11 do begin
                                if  sHourList.Strings[j] = sTime then
                                begin
                                    TPANEL(FindComponent('pnlTime'+IntToStr(j+1))).Color := clGreen;
                                    TEdit(FindComponent('edtTime'+IntToStr(j+1))).Text := shour;
                                end;
                             end;
                        end;
                         stemp:= Copy(sTemp,iPos+1,length(sTemp)-iPos);
                      end;
                  end ;

                
             end;

             first;
             for i:=0 to  recordCount-1 do begin
                with uSettings.ListView1.Items.Add do
                begin
                     Caption :=fieldByName('Model_Name').AsString;
                     subitems.Add( fieldByName('WORK_HOUR').AsString);
                     subitems.Add( fieldByName('UPH').AsString);
                     subitems.Add( fieldByName('Target_QTY').AsString);
                     subitems.Add( fieldByName('Repair_Line').AsString);
                     subitems.Add( fieldByName('PD_STATUS').AsString);
                     subitems.Add( fieldByName('HOURCOUNT').AsString);
                     subitems.Add( fieldByName('iRowID').AsString);
                end;
                next;
             end;

         end;

     end;
     sHourList.Free;


     if (uSettings.edtUPH.Text ='') or (uSettings.edtUPH.Text ='0') then begin
         with qrytemp do begin
             Close;
             Params.Clear;
             Params.CreateParam(ftstring,'Pdline',ptInput);
             CommandText := ' SELECT NVL(B.TARGET_QTY,0) UPH FROM SAJET.SYS_PDLINE A,'+
                            ' SAJET.SYS_PDLINE_MONITOR_BASE B '+
                            ' WHERE A.PDLINE_ID =B.PDLINE_ID AND A.PDLINE_NAME =:Pdline ';
             Params.ParamByName('Pdline').AsString := popupmenu1.PopUpComponent.name;
             Open;
             if not Isempty then
                 uSettings.edtUPH.Text := fieldByName('UPH').AsString;

         end;

     end;

     uSettings.cmbPdline.Items.Clear;

      with qrytemp do begin
         Close;
         Params.Clear;
         Params.CreateParam(ftstring,'SHIFT',ptInput);
         Params.CreateParam(ftstring,'WORKDATE',ptInput);
         CommandText := ' SELECT   B.PDLINE_NAME  FROM SAJET.G_PDLINE_MANAGE '+
                        '  A,SAJET.SYS_PDLINE B ,SAJET.SYS_SHIFT C'+
                        ' WHERE   A.PDLINE_ID=B.PDLINE_ID AND A.SHIFT_ID =C.SHIFT_ID AND '+
                        ' A.WORK_DATE =:WORKDATE  AND C.SHIFT_NAME =:SHIFT Order By B.PDLINE_NAME ';
         Params.ParamByName('SHIFT').AsString :=  cmbShift.Text;
         Params.ParamByName('WORKDATE').AsString := sWorkDate;
         Open;

         First;
         for i:= 0  to RecordCount-1 do  begin
              uSettings.cmbPdline.Items.Add(fieldByName('PDLINE_NAME').AsString);
              Next;
         end;

     end;
end;

end.
