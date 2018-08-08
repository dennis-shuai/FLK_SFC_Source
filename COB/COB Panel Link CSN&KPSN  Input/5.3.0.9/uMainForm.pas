unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles;

type
  TfMainForm = class(TForm)
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
    PopupMenu1: TPopupMenu;
    Cancel1: TMenuItem;
    ClearAll1: TMenuItem;
    editCarrier: TEdit;
    editCustomer: TEdit;
    DBGrid1: TDBGrid;
    msgPanel: TPanel;
    LabTerminal: TLabel;
    labInputQty: TLabel;
    ImageAll: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label1: TLabel;
    lbl1: TLabel;
    editKPSN: TEdit;
    procedure FormShow(Sender: TObject);
    procedure editCarrierKeyPress(Sender: TObject; var Key: Char);
    procedure editCustomerKeyPress(Sender: TObject; var Key: Char);
    procedure Label4DblClick(Sender: TObject);
    procedure editKPSNKeyPress(Sender: TObject; var Key: Char);
  private
    //m_SNDefectLevel: String;
    procedure clearData;

    function CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
    function CheckCustomerRule: string;      //���Customer�ַ�����,��һ��,���ȵ�
    function CheckCustomerValue: string;    //���Customer�ַ��Ƿ���0~Z֮��

    function GetTerminalName(sTerminalID:string):string;

    procedure ShowMSG(sShowHead,sShowResult,sNextMsg:string);
    procedure RemoveCarrier(sCarrier:string);


    function GetPartID(partno :String) :String;
    procedure ShowData(sCarrier :String);
  public
    UpdateUserID,sPartID,sWO : String;
  end;

var
  fMainForm: TfMainForm;
  //gWO,gCarrierNO:string;
  iCarrierSNCount,iSNCount:Integer;
  iTerminal:string;

implementation


{$R *.dfm}

function TfMainForm.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
try
  with Qrytemp do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'TerminalID',ptInput);
      CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id  ' +
                    '  from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                    'where c.terminal_id = :TerminalID  '+
                    '  and a.pdline_id=c.pdline_id '+
                    '  and b.process_id=c.process_id';

      Params.ParamByName('TerminalID').AsString :=sTerminalID;
      Open;
      if RecordCount > 0 then
      begin
         sPdline := Fieldbyname('pdline_name').AsString  ;
         sProcess:= Fieldbyname('process_name').AsString  ;
         sTerminal:= Fieldbyname('terminal_name').AsString  ;
         Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
      end   
      else
         Result :='No Terminal information!';
   end;
Except   on e:Exception do
   Result := 'Get Terminal : ' + e.Message;

end;
end;

function TfMainForm.CheckCarrier(sCarrier:string;var iCarrierCount:Integer):string;
begin
try
  Result := 'Check Carrier Error';
  with SProc do
  begin
    try
      Close;
      DataRequest('SAJET.Sj_Chk_Carrier');
      FetchParams;
      Params.ParamByName('TREV').AsString := sCarrier;
      Execute;
      iCarrierSNCount := Params.ParamByName('TCARRIERCOUNT').AsInteger;
      iSNCount := Params.ParamByName('TSNCOUNT').AsInteger;
      sPartID :=   Params.ParamByName('TMODELID').AsString;
      Result := Params.ParamByName('TRES').AsString;

    finally
      Close;
    end;
  end;
except on e:Exception do
  begin
    Result := 'Check Carrier error : ' + e.Message;
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

procedure TfMainForm.RemoveCarrier(sCarrier:string);
begin
if editCarrier.Text ='' then exit;
try
  with Qrytemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString,'Carrier',ptInput);
    CommandText :='update SAJET.g_sn_status set box_no = ''N/A'' WHERE box_no= :Carrier ' ;
    Params.ParamByName('Carrier').AsString := sCarrier;
    Execute;
  end;
except on e:Exception do
  begin
    MessageDlg('Remove carrier err: '+e.Message,mtError,[mbOK],0);
  end;

end;
end;

function TfMainForm.GetPartID(partno :String) :String;
begin
    with Qrytemp do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString,'PARTNO',ptInput);
        CommandText :='SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO= :PARTNO AND ENABLED=''Y'' AND ROWNUM=1 ' ;
        Params.ParamByName('PARTNO').AsString := partno;
        Open;
        if Recordcount = 0 then
            Result :=''
        else
            Result := FieldbyName('PART_ID').AsString;
    end;
end;

procedure TfMainForm.ShowData(sCarrier :String);
begin

    With QryData do
    begin
       Close;
       Params.Clear;
       //Params.CreateParam(ftString,'WO',ptInput);
       Params.CreateParam(ftString,'CarrierNO',ptInput);
       CommandText := 'SELECT A.WORK_ORDER,A.BOX_NO,A.serial_number,a.Customer_SN,A.in_process_time '+
                      '  FROM SAJET.g_sn_status A '+
                      //' WHERE A.WORK_ORDER = :WO '+        //modify by phoenix 2013-5-9
                      ' WHERE A.Box_NO= :CarrierNO '+
                      '   AND A.WORK_FLAG= ''0'' '+          //add by phoenix 2013-05-09
                      '   AND A.CUSTOMER_SN <> ''N/A'' '+    //add by phoenix 2013-05-09
                      ' ORDER BY A.serial_number ';
     //Params.ParamByName('WO').AsString := sWO;
     Params.ParamByName('CarrierNO').AsString := sCarrier;
     Open;

    end;
end;

procedure TfMainForm.FormShow(Sender: TObject);
Var DestRect,SurcRect : TRect; Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;

  Bmp.Free;

  editCarrier.SetFocus;
  LabTerminal.Caption := LabTerminal.Caption + '    ' + GetTerminalName(iTerminal);

end;

procedure TfMainForm.clearData;
begin
end;
 


procedure TfMainForm.editCarrierKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
  if Key = #13 then
  begin
      iResult := CheckCarrier(editCarrier.Text,iCarrierSNCount);
      Label1.Caption := IntTOStr(iSNCOunt)+'/'+IntToStr(iCarrierSNCount);
      if iResult <>'OK' then begin
          ShowMsg('ERROR',iResult,'');
          editCarrier.SetFocus;
          editCarrier.Text :='';
          exit;
      end;

       if iSNCOUnt = ICarrierSNCOunt then begin
          ShowMsg('','OK','');
          editCarrier.SetFocus;
          editCarrier.Text :='';
          exit;
      end;

       sproc.Close;
       sproc.DataRequest('SAJET.CCM_CHK_CARRIER_ROUTE');
       sproc.FetchParams;
       sproc.Params.ParamByName('TRev').AsString := editCarrier.Text;

       sproc.Params.ParamByName('TERMINALID').AsString :=iterminal;
       sproc.Execute;

       iResult := sproc.Params.parambyname('TRES').AsString;
        if iResult <>'OK' then
        begin
            ShowMsg('ERROR',iResult,'');
            editCarrier.SetFocus;
            editCarrier.Text :='';
            exit;
        end;

        editCustomer.SetFocus;
        editCustomer.Clear;
        editCarrier.Enabled:=false;
  end;
end;

procedure TfMainForm.editCustomerKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
    iqty:integer;
begin
  if Key <> #13 then exit;
  editCustomer.Text := Trim(UpperCase(editCustomer.Text));

  iResult :=CheckCustomerValue;
  if iResult <> 'OK' then begin
        ShowMsg('���~','�Ȥ���X�W�h���~','');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;

  sproc.Close;
  sproc.DataRequest('SAJET.CCM_COB_CHK_PANEL_CSN');
  sproc.FetchParams;
  sproc.Params.ParamByName('TPANEL').AsString := editCarrier.Text;
  sproc.Params.ParamByName('TSN').AsString :=editCustomer.Text;
  sproc.Params.ParamByName('TTERMINALID').AsString :=iterminal;
  sproc.Execute;

  iResult := sproc.Params.parambyname('TRES').AsString;

  if iResult <> 'OK' then begin
        ShowMsg('���~',iResult,'');
        editCustomer.Setfocus;
        editCustomer.SelectAll;
        exit;
  end;
   ShowMsg('�б��y�U�@��',iResult,'');
   editCustomer.Setfocus;
   editCustomer.SelectAll;

end;

function TfMainForm.CheckCustomerRule: string;
begin
  try
    Result := 'Check CustomerID Rule Error';
    with SProc do
    begin
      try
        Close;
        DataRequest('SAJET.SJ_CHK_KP_RULE');
        FetchParams;
        Params.ParamByName('ITEM_PART_ID').AsString := sPartID;
        Params.ParamByName('ITEM_PART_SN').AsString := trim(editCustomer.Text);
        Execute;
        Result := Params.ParamByName('TRES').AsString;
      finally
        Close;
      end;
    end;
  except on e:Exception do
  begin
    Result := '�Ȥ���X�W�h���~ : ' + e.Message;
  end;
end;
end;

function TfMainForm.CheckCustomerValue: string;
var
  i,vLength: integer;
  sValue,vChar: string;
begin
  sValue := trim(editCustomer.Text);
  vLength := length(sValue);
  for i := 1 to vLength do
  begin
    vChar := copy(sValue,i,1);
    if ((vChar >= '0') and (vChar <= '9')) or ((vChar >= 'A') and (vChar <= 'Z')) or (vChar ='-') then
      Result := 'OK'
    else
    begin
      Result := 'Error';
      Exit;
    end;
  end;
end;

procedure TfMainForm.Label4DblClick(Sender: TObject);
begin
    //RemoveCarrier(editCarrier.Text);
    editCarrier.Clear;
    editCarrier.Enabled :=true;
    editCarrier.SetFocus;
    editCustomer.Clear;
    Label1.Caption :='0/0';
end;

procedure TfMainForm.editKPSNKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
    sproc.Close;
    sproc.DataRequest('SAJET.CCM_COB_CHK_PANEL_CSN');
    sproc.FetchParams;
    sproc.Params.ParamByName('TPANEL').AsString := editCarrier.Text;
    sproc.Params.ParamByName('TSN').AsString :=editCustomer.Text;
    sproc.Params.ParamByName('TKPSN').AsString :=editKP.Text;
    sproc.Params.ParamByName('TTERMINALID').AsString :=iterminal;
    sproc.Execute;

    ShowData(editCarrier.Text);
    iSNCOunt := iSNCOunt+1;
    Label1.Caption :=  InttoStr(iSNCOunt)+'/' +  InttoStr(iCarrierSNCOunt) ;
    editCustomer.SetFocus;
    editCustomer.Text :='';
    ShowMsg('OK',iResult,'');
    if iSNCount>=iCarrierSNCOunt then   begin
      //   RemoveCarrier(editCarrier.Text);
        editCarrier.Clear;
        editCarrier.Enabled :=true;
        editCarrier.SetFocus;
        editCustomer.Clear;
        Label1.Caption :='0/0';
    end;

end;

end.
