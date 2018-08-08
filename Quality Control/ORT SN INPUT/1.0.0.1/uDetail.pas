unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    edtPartNo: TEdit;
    lblNCount: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtSN: TEdit;
    cmbName: TComboBox;
    sbtnNewLot: TSpeedButton;
    DBGrid1: TDBGrid;
    procedure FormShow(Sender: TObject);
    procedure cmbNameSelect(Sender: TObject);
    procedure sbtnNewLotClick(Sender: TObject);
    procedure edtPartNoChange(Sender: TObject);
    procedure edtSNKeyPress(Sender: TObject; var Key: Char);
    
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
     mPartID,UpdateUserID:string;

  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit;


procedure TfDetail.FormShow(Sender: TObject);
begin
   with QryTemp do begin
     close;
     params.clear;
     commandtext :='Select Distinct ORT_NAME FROM SAJET.CCM_ORT_SN ';
     open;
     first;
     while  not eof do begin
       cmbName.Items.Add(fieldbyname('ORT_NAME').AsString);
       next;
     end;
   end;

   cmbName.SetFocus;
end;

procedure TfDetail.cmbNameSelect(Sender: TObject);
begin
   edtPartNo.Enabled := true;
   edtPartNo.Text :='';
   edtPartNo.SetFocus;
end;

procedure TfDetail.sbtnNewLotClick(Sender: TObject);
begin
   edtPartNo.Enabled :=true;
   edtPartNo.Text :='';
   edtPartNo.SetFocus;
end;

procedure TfDetail.edtPartNoChange(Sender: TObject);
begin
    with QryTemp do begin
     close;
     params.clear;
     commandtext :='Select  * FROM SAJET.SYS_PART WHERE PART_NO =''' +edtPartNO.Text+'''';
     open;
     if not IsEmpty then begin
           mpartId := fieldbyname('Part_ID').AsString;
           edtsn.Enabled :=true;
           edtsn.SetFocus;
     end ;

   end;
end;

procedure TfDetail.edtSNKeyPress(Sender: TObject; var Key: Char);
var sn,csn,iresult:string;
begin
  if Key <>#13 then exit;
  with qrytemp do begin
       close;
       params.clear;
       params.CreateParam(ftstring,'SN',ptInput);
       commandtext :=' select serial_number from sajet.g_sn_status where serial_number =:SN  or customer_sn =:SN ';
       params.ParamByName('SN').AsString :=edtsn.Text;
       open;
       if not isempty then begin
           sn := fieldbyname('serial_number').AsString;
           csn := edtsn.Text;
       end else begin
          sn := edtsn.Text;
          csn :='N/A';
       end;
  end;

  with sproc do begin
     close;

     datarequest('sajet.sj_chk_kp_rule');
     fetchparams;
     params.ParamByName('ITEM_PART_ID').AsString :=mpartid;
     params.ParamByName('ITEM_PART_SN').AsString :=edtSN.Text;
     execute;
     iResult :=params.ParamByName('TRES').Asstring;

     if iResult <> 'OK' then begin
         MessageDlg(iresult,mterror,[mbok],0);
         edtsn.SelectAll;
         edtsn.SetFocus;
         exit;

     end;



  end;

   with sproc do begin
     close;
  
     datarequest('sajet.CCM_ORT_SN_INPUT');
     fetchparams;
     params.ParamByName('TSN').AsString := sn;
     params.ParamByName('TCSN').AsString :=csn;
     params.ParamByName('TMODELID').AsString := mpartid;
     params.ParamByName('TUSERID').AsString := UpdateUserID;
     params.ParamByName('TNAME').AsString :=cmbNAME.Text;
     execute;
     iResult :=params.ParamByName('TRES').Asstring;

     if iResult <> 'OK' then begin
         MessageDlg(iresult,mterror,[mbok],0);
         exit;
     end;

     edtsn.SelectAll;
     edtsn.SetFocus;
     
  end;

  with qrydata do begin
      close;
      params.Clear;
      params.CreateParam(ftstring,'NAME',ptInput);
      commandtext :=' select a.ORT_Name,a.serial_number,C.PART_NO,a.customer_sn,a.update_TIME,b.EMP_NO,b.EMP_NAME ,a.enabled '+
                    ' from sajet.ccm_ort_sn a,sajet.sys_emp b,sajet.sys_part c '+
                    ' where a.ORT_NAME =:NAME and a.model_id =c.part_id and a.UPDATE_USERID= b.emp_id';
      params.ParamByName('NAME').AsString :=cmbNAME.Text;
      open;
      lblNCount.Caption := IntToStr(recordcount) +' Records';
  end;

end;

end.
