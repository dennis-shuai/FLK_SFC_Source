unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj,TLHELP32;

type
  TfMainForm = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    dsData: TDataSource;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    lbldata: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    edtWO: TEdit;
    msgPanel: TPanel;
    labTargetQty: TLabel;
    dbgrd1: TDBGrid;
    LabNewTargetQty: TLabel;
    btnQuery: TSpeedButton;
    Image3: TImage;
    cmbProcess: TComboBox;
    Label1: TLabel;
    btnRecover: TSpeedButton;
    Image1: TImage;
    Label4: TLabel;
    LabQty: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtWOChange(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure btnRecoverClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;
    function CheckWO(sWO:string):string;
  public
    UpdateUserID ,sEMP_NO,sPDlineID,sStageID,sProcessID: String;
    PrintFile,iTerminal:string;
    isStart,IsOpen:boolean;
    BarApp,BarDoc,BarVars:variant;
    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
  end;

var
  fMainForm: TfMainForm;


implementation



{$R *.dfm}


function TfMainForm.CheckWO(sWO:string):string;
begin
try
  Result := 'Check WO Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Wo_Input');
      FetchParams;
      Params.ParamByName('TREV').AsString := sWO;
      Execute;
      Result := Params.ParamByName('TRES').AsString;
    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'CheckWO error : ' + e.Message;
  end;
end;
end;


procedure TfMainForm.ShowMSG(sShowHead,sShowResult,sNextMsg:string);
var sShowData:string;
begin
  if sShowResult = 'OK' then
  begin
    msgPanel.Color := clGreen;
  end
  else
  begin
    msgPanel.Color := clRed;
  end;
  sShowData := sShowHead + ' ' +  sShowResult;
  if sNextMsg <> '' then
  begin
    sShowData := sShowData + '  =>  ' + sNextMsg;
  end;
  msgPanel.Caption := sShowData;
end;



procedure TfMainForm.FormShow(Sender: TObject);
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;
  Bmp.Free;

  edtWO.SetFocus;
  edtWO.Text := '';
   

end;

procedure TfMainForm.Image2Click(Sender: TObject);
begin
   Close;
end;


procedure TfMainForm.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    if Key <> #13 then Exit;

    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := 'Select P.PART_NO,TARGET_QTY,INPUT_QTY FROM  SAJET.G_WO_BASE W'
                     + ' Left outer join SAJET.SYS_PART P ON W.MODEL_ID=P.PART_ID '
                     + ' WHERE W.WORK_ORDER = :WO';
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
        Open;
        If IsEmpty then
        begin
            ShowMSG('Error Work_Order','Error','Please Input WO Again');
            edtWO.SelectAll;
            edtWO.SetFocus;
            Exit;
        end;

    end;



end;

procedure TfMainForm.edtWOChange(Sender: TObject);
begin
    msgPanel.Caption :='please input WO';
    msgPanel.Color :=clYellow;
    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        CommandText := ' select d.process_name,c.step from sajet.g_wo_base a,sajet.sys_route b,SAJET.SYS_ROUTE_DETAIL c ,sajet.sys_process d,  '+
                       ' SAJET.SYS_ROUTE_DETAIL E where  A.ROUTE_ID =b.route_id and B.ROUTE_ID =c.route_id and  '+
                       ' C.SEQ =C.STEP and C.NEXT_PROCESS_ID =d.Process_id   '+
                       ' and A.START_PROCESS_ID =E.NEXT_PROCESS_ID and E.ROUTE_ID=B.ROUTE_ID and E.STEP=E.SEQ and C.SEQ >= E.SEQ '+
                       ' and a.work_order= :WO order by C.STEP ';
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
        Open;

        First;
        cmbProcess.Items.Clear;
        cmbProcess.Style := csDropDownList;
        while not Eof do
        begin
            cmbProcess.Items.Add(fieldbyName('Process_Name').AsString);
            Next;
        end;

    end;
end;

procedure TfMainForm.btnQueryClick(Sender: TObject);
begin
    with QryData do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        //Params.CreateParam(ftString,'StartTime',ptInput);
        //Params.CreateParam(ftString,'EndTime',ptInput);
        Params.CreateParam(ftString,'process',ptInput);
        CommandText := ' select a.work_order ,c.part_no,a.serial_number,a.customer_sn,b.process_name,a.current_status,b.process_id,round((sysdate-a.out_process_time)*24,1) Over_time '+
                       ' from sajet.g_sn_status a,sajet.sys_process b,sajet.sys_part c '+
                       ' where work_order=:WO and ((a.wip_process=b.process_id and a.next_process =0)or a.next_process=b.process_id ) and a.model_id=c.part_id '+
                       ' and b.process_name =:process order by Over_time Desc';    //and  a.out_process_time >=:starttime and a.out_process_time <:endtime
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
       // Params.ParamByName('StartTime').AsDateTime := dtp1.Date+dtp2.Time;
        //Params.ParamByName('EndTime').AsDateTime := dtp3.Date+dtp4.Time;
        Params.ParamByName('process').AsString := cmbProcess.text;
        Open;

        LabQty.Caption := IntToStr(recordCount)+'PCS';
        sProcessID := fieldByname('process_id').AsString;

        if not IsEmpty then btnRecover.Enabled :=True;

    end;
end;

procedure TfMainForm.btnRecoverClick(Sender: TObject);
begin
    with QryTemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'WO',ptInput);
        Params.CreateParam(ftString,'process',ptInput);
        CommandText := ' update sajet.g_sn_status set out_process_time=sysdate where work_order =:WO and '+
                       '((wip_process=:process  and next_process=0) or next_process =:process) and current_status=0';
        Params.ParamByName('WO').AsString := Trim(edtWO.Text);
        Params.ParamByName('process').AsString := sProcessID;
        Execute;

        msgPanel.Caption :='Update OK';
        msgPanel.Color :=clGreen;
        btnRecover.Enabled  :=false;
    end;
end;

end.
