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
    Label1: TLabel;
    edtWO: TEdit;
    Label2: TLabel;
    lbl1: TLabel;
    edt1: TEdit;
    lbl2: TLabel;
    mmo1: TMemo;
    btnConfirm: TSpeedButton;
    Image3: TImage;
    lbl3: TLabel;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    procedure btnConfirmClick(Sender: TObject);
    procedure edtWOChange(Sender: TObject);
    procedure mmo1Change(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count:Integer;
    UpDate_Time :TDateTime;
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
   
  end;

var
  fDetail: TfDetail;


implementation

{$R *.dfm}
uses uDllform,DllInit;


procedure TfDetail.btnConfirmClick(Sender: TObject);
begin

    with QryTemp do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText :='Select * from sajet.g_wo_base where work_order=:WO' ;
        Params.ParamByName('WO').AsString :=edtWO.Text;
        Open;

        if IsEmpty then
        begin
             MessageDlg('沒有該工令',mtError,[mbOK],0);
             Exit;
        end;
    end;



    with QryTemp do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText :='Select * from sajet.g_wo_repair_times where work_order=:WO' ;
        Params.ParamByName('WO').AsString :=edtWO.Text;
        Open;

        if IsEmpty  then
        begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'WO',ptInput);
            Params.CreateParam(ftString,'MAX_TIMES',ptInput);
            Params.CreateParam(ftString,'UPDATEUSERID',ptInput);
            Params.CreateParam(ftString,'REMARKS',ptInput);
            CommandText :=' Insert into  sajet.g_wo_repair_times(work_order,MAX_REPAIR_TIMES,UPDATE_USERID,UPDATE_TIME,Remarks) '+
                          ' values(:WO,:MAX_TIMES,:UPDATEUSERID,sysdate,:REMARKS)   ' ;
            Params.ParamByName('WO').AsString :=edtWO.Text;
            Params.ParamByName('MAX_TIMES').AsInteger := StrToInt(edt1.Text);
            Params.ParamByName('UPDATEUSERID').AsString :=UpdateUserID;
            Params.ParamByName('REMARKS').AsString := mmo1.Text;
            Execute;



        end else begin
            Close;
            Params.Clear;
            Params.CreateParam(ftString,'WO',ptInput);
            Params.CreateParam(ftString,'MAX_TIMES',ptInput);
            Params.CreateParam(ftString,'UPDATEUSERID',ptInput);
            Params.CreateParam(ftString,'REMARKS',ptInput);
            CommandText :='update  sajet.g_wo_repair_times set MAX_REPAIR_TIMES=:MAX_TIMES,UPDATE_USERID=:UPDATEUSERID,UPDATE_TIME =sysdate,Remarks=:Remarks where work_order=:WO  ' ;
            Params.ParamByName('WO').AsString :=edtWO.Text;
            Params.ParamByName('MAX_TIMES').AsInteger := StrToInt(edt1.Text);
            Params.ParamByName('UPDATEUSERID').AsString :=UpdateUserID;
            Params.ParamByName('REMARKS').AsString := mmo1.Text;
            Execute;

        end;

         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         CommandText :='Insert into  sajet.g_HT_wo_repair_times  select * from  sajet.g_wo_repair_times  where work_order=:WO ' ;
         Params.ParamByName('WO').AsString :=edtWO.Text;
         Execute;

    end;
    edtWO.Clear;
    edt1.Clear;
    mmo1.Clear;
    btnConfirm.Enabled :=False;
    edtWO.OnChange(Sender);
end;

procedure TfDetail.edtWOChange(Sender: TObject);
begin
    with QryData do begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText :=' Select a.work_order,a.max_repair_times,b.emp_name,a.update_time,a.remarks '+
                      ' from sajet.g_HT_wo_repair_times a , sajet.sys_emp b  where a.work_order=:WO '+
                      ' and a.update_userid =b.emp_id order by a.update_time ' ;
        Params.ParamByName('WO').AsString :=edtWO.Text;
        Open;
    end;
end;

procedure TfDetail.mmo1Change(Sender: TObject);
begin
   if Length(mmo1.Text)>0 then
       btnConfirm.Enabled :=True
   else
       btnConfirm.Enabled :=false;

end;

procedure TfDetail.edtWOKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      edt1.SetFocus;
end;

procedure TfDetail.edt1KeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then  begin

       mmo1.Clear;
       mmo1.SetFocus;
   end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
    edtWO.SetFocus;
end;

end.
