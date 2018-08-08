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
    Label3: TLabel;
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    edtWO: TEdit;
    edtNewWo: TEdit;
    msgPanel: TPanel;
    Label1: TLabel;
    labPartNo: TLabel;
    Label7: TLabel;
    labTargetQty: TLabel;
    Label8: TLabel;
    labInputQty: TLabel;
    dbgrd1: TDBGrid;
    lbl1: TLabel;
    LabNewPartNo: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lblCount: TLabel;
    LabNewTargetQty: TLabel;
    LabNewInput: TLabel;
    LabMoveQty: TLabel;
    btnOK: TSpeedButton;
    Image3: TImage;
    chkWO: TCheckBox;
    chkPartNo: TCheckBox;
    chkInfo: TCheckBox;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtNewWoKeyPress(Sender: TObject; var Key: Char);
    procedure labWODblClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
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
        labPartNo.Caption := FieldByName('PART_NO').AsString;
        labTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
        labInputQty.Caption := FieldByName('INPUT_QTY').AsString;
    end;

    with QryData do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString,'WO',ptInput);
         CommandText := ' select AA.* ,bb.Process_name WIP_PROCESS_Name   from (Select A.WORK_ORDER,B.PART_NO,A.SERIAL_NUMBER,'+
                        ' A.CUSTOMER_SN ,C.Process_Name,C.process_code,Decode(A.Next_process,0,A.wip_process,A.Next_process) '+
                        ' WIP_PROCESS ,A.Current_status FROM SAJET.G_SN_STATUS A,SAJET.SYS_PART B,'+
                        '  sajet.sys_process C  '+
                        ' WHERE A.WORK_ORDER=:WO AND A.MODEL_ID=B.PART_ID AND A.process_id=c.Process_id and '+
                        ' (A.WIP_PROCESS <>0 OR A.NEXT_PROCESS<>0) AND A.SHIPPING_ID=0 )AA,sajet.sys_process BB '+
                        ' where aa.WIP_PROCESS=bb.Process_id  Order By AA.process_code';
         Params.ParamByName('WO').AsString := Trim(edtWo.Text);
         Open;
         LabMoveQty.Caption := IntToStr(RecordCount);

         if RecordCount=0 then begin
             ShowMSG('可移動數量為0 ','','請輸入新工令!');
             edtWo.SelectAll;
             edtWo.SetFocus;
             edtNewWO.Enabled := False;
             exit;
         end;
    end;

    ShowMSG('Work Order input : ','OK','請輸入新工令!');
    edtNewWo.Text := '';
    edtNewWo.Enabled :=True;
    edtNewWo.SetFocus;
    edtNewWo.ReadOnly :=False;
    edtWO.Enabled := False;

end;

procedure TfMainForm.edtNewWoKeyPress(Sender: TObject; var Key: Char);
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
        Params.ParamByName('WO').AsString := Trim(edtNewWo.Text);
        Open;

        If IsEmpty then
        begin
            ShowMSG('Error Work_Order','Error','Please Input WO Again');
            edtNewWO.SelectAll;
            edtNewWO.SetFocus;
            Exit;
        end;
        labNewPartNo.Caption := FieldByName('PART_NO').AsString;
        labNewTargetQty.Caption := FieldByName('TARGET_QTY').AsString;
        LabNewInput.Caption := FieldByName('INPUT_QTY').AsString;
    end;

   
end;

procedure TfMainForm.labWODblClick(Sender: TObject);
begin

  if not edtWO.Enabled then
  begin
      edtWO.Enabled := True;
      edtWO.SelectAll;
      edtWO.SetFocus;
  end
  else
  begin
      edtWO.Enabled := False;
  end;

end;

procedure TfMainForm.btnOKClick(Sender: TObject);
var iResult:string;
Key: Char;
begin

   if chkPartNo.Checked then begin
       if labPartNo.Caption <> LabNewPartNo.Caption then begin
          ShowMSG('料號不同','','請重新輸入新工令');
          Exit;
       end;
   end;
   if StrToIntDef(LabMoveQty.Caption,0) =0 then begin
      ShowMSG('可移動數量為0','','請重新輸入舊工令');
      Exit;
   end;

   if chkWO.Checked then begin
       if StrToIntDef(LabMoveQty.Caption,0) + StrToIntDef(LabNewInput.Caption,0)>
            StrToIntDef(LabNewTargetQty.Caption,0) then
       begin
            ShowMSG('可移動數量+已投入數量大於工令總數','','請重新輸入舊工令');
            Exit;
       end;
   end;

   with SProc do begin
       Close;
       DataRequest('SAJET.CCM_WO_TRANSFER');
       FetchParams;
       Params.ParamByName('TWO').AsString :=edtWO.Text;
       Params.ParamByName('TNEWWO').AsString :=edtNewWo.Text;
       if chkInfo.Checked then
           Params.ParamByName('TFLAG').AsString :='1'
       else
           Params.ParamByName('TFLAG').AsString :='0';
       Execute;
       iResult := Params.ParamByName('TRES').AsString;
       if iResult ='OK' then
       begin
           ShowMSG(iResult,'OK','Complete');
           Key :=#13;
           edtNewWo.OnKeyPress(Sender,Key);
           edtWO.Clear;
           edtNewWo.Clear;
           edtNewWo.ReadOnly :=True;
           edtWO.ENabled :=true;
           edtWO.SetFocus;
           LabMoveQty.Caption :='0';
           chkWO.Enabled :=True;
       end else begin
           ShowMSG(iResult,'','Please Check WO');
           edtNewWo.Clear;
           edtNewWo.SetFocus;
       end;

   end;

end;

end.
