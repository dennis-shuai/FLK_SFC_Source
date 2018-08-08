unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, {uRTData,} Db, DBClient,
  SConnect, Menus, Spin, IniFiles, ComCtrls;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    ImageAll: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    DataSource1: TDataSource;
    QryTemp: TClientDataSet;
    Label7: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    lablType: TLabel;
    Image1: TImage;
    btnAdd: TSpeedButton;
    lablReel: TLabel;
    Label9: TLabel;
    EditWO: TEdit;
    edtSubPN: TEdit;
    MainPN: TLabel;
    Image2: TImage;
    btnDelete: TSpeedButton;
    Image3: TImage;
    edtQty: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    DBGrid1: TDBGrid;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    sBtnChangeQty: TSpeedButton;
    Image4: TImage;
    edtOldQty: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edtNewQty: TEdit;
    procedure FormShow(Sender: TObject);
    procedure edtSubPNKeyPress(Sender: TObject; var Key: Char);
    procedure EditWOKeyPress(Sender: TObject; var Key: Char);
    procedure btnAddClick(Sender: TObject);
    procedure EditWOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnDeleteClick(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure sBtnChangeQtyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g_wo: string;
    UpdateUserID, gsLabelField, sCaps, gsReelField: string;
    function cleardate:string;

  end;

var
  fDetail: TfDetail;
implementation

{$R *.DFM}
uses uDllform,{ unitDataBase,} DllInit, uLogin,uAddPN;

function TfDetail.cleardate: string;
begin
  editwo.Clear;
  editwo.SetFocus;

end;


procedure TfDetail.FormShow(Sender: TObject);
begin
  case screen.width of
    640: self.ScaleBy(80, 100);
    800: self.ScaleBy(100, 100);
    1024: self.ScaleBy(125, 100);
  else
    self.ScaleBy(100, 100);
  end;
  editwo.Clear;
  editwo.SetFocus;
  cleardate;
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
    Params.ParamByName('dll_name').AsString := 'WOPICKLIST.DLL';
    Open;

  end;
end;


procedure TfDetail.edtSubPNKeyPress(Sender: TObject; var Key: Char);
var   Target_Qty:Integer;
      Request_Qty:Integer;
begin
  if Key = #13 then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Sub_PN', ptInput);
      CommandText := ' Select * from sajet.SYS_PART where PART_NO=:Sub_PN ';
      Params.ParamByName('Sub_PN').AsString := edtSubPN.Text;
      Open;
      if IsEmpty then
      begin
          MessageDlg('NOT FOUND PART NUMBER ', mtError, [mbYes,mbNo], 0) ;
          Exit;
        { = mryes then
        begin
              with TAddPNForm.Create(Self) do
              if  ShowModal =mrOK then
              begin
                 //AddPNForm.edtSubPN.Text := edtSubPN.text;
              end;
        end
        else
        begin
            edtSubPN.Clear;
            edtSubPN.SetFocus;
            Exit;
        end;
        }

      end;
      {
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'Main_PN', ptInput);
      Params.CreateParam(ftString, 'Sub_PN', ptInput);
      CommandText := 'select A.TARGET_QTY , B.REQUEST_QTY from sajet.G_WO_Base a,sajet.G_WO_Pick_list b ,'
                     + 'sajet.sys_part c  where A.Work_order in (select WORK_Order From sajet.G_WO_PICK_LIST)'
                     + ' and C.Part_NO=:Main_PN and  A.MODEL_ID=C.PART_ID  and B.PART_ID  IN(select PART_ID '
                     + ' from sajet.sys_Part where PART_NO=:Sub_PN)';
      Params.ParamByName('Main_PN').AsString := MainPN.Caption;
      Params.ParamByName('Sub_PN').AsString := edtSubPN.Text;
      Open;
      if not IsEmpty then
      begin
         Target_Qty := FieldbyName('Main_PN').AsInteger;
         Request_Qty :=  FieldbyName('Sub_PN').AsInteger;
      end;
      if IsEmpty then
      begin
        MessageDlg('NOT FOUND WO', mtError, [mbYes], 0);
        EditWO.SelectAll;
        EditWO.SetFocus;
      end;
      }
      edtQty.SelectAll;
      edtQty.SetFocus;

    end;
  end;
end;

procedure TfDetail.EditWOKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    with QryTemp do
    begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'select b.PART_NO from sajet.G_WO_BASE a,Sajet.sys_Part b where A.MODEL_ID=B.PART_ID and A.WORK_ORDER=:WORK_ORDER';
      Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
      Open;
      if not IsEmpty then
      begin
        MainPN.Caption := FieldbyName('PART_NO').asstring;
        edtSubPN.Enabled :=True;
        edtQty.Enabled :=True;
        edtSubPN.SetFocus;
      end;
      if IsEmpty then
      begin
        MessageDlg('NOT FOUND WO', mtError, [mbYes], 0);
        EditWO.SelectAll;
        EditWO.SetFocus;
      end;

    end;
  end;
end;

procedure TfDetail.btnAddClick(Sender: TObject);
var rbMessage:string;
begin
  if   (edtQty.Text = '') or (edtSubPN.Text =  '')then
  begin
     Exit;
  end;
  with SProc do
  begin
        Close;
        DataRequest('SAJET.CCM_ADD_ERP_PICKLIST');
        FetchParams;
        Params.ParamByName('TWO').AsString := EditWO.Text;
        Params.ParamByName('TPART_NO').AsString := edtSubPN.Text;
        Params.ParamByName('TQTY').AsInteger := StrTOInt(edtQty.Text);
        Params.ParamByName('TEMPID').AsString :=UpdateUserID;
        Params.ParamByName('TOP_NO').AsInteger := 1;
        Execute;

        rbMessage := Params.ParamByName('TRES').AsString;

        if  rbMessage <> 'OK' then
        begin
            MessageDlg(rbMessage,mtError,[mbOK],0);
            edtSubPN.Clear;
            edtQty.Clear;
            edtSubPN.SetFocus;
            Abort;

        end;
  end;
  with QryTemp2 do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'select a.WORK_ORDER,b.PART_NO,a.Request_QTY  from sajet.G_WO_PICK_LIST a,Sajet.sys_Part b where A.PART_ID=B.PART_ID and A.WORK_ORDER=:WORK_ORDER';
      Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
      Open;

  end;
  edtSubPN.SelectAll;
  edtSubPN.SetFocus;
end;

procedure TfDetail.EditWOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //NMS33044
  if EditWO.Text <> '' then
  begin
  with QryTemp2 do
  begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'select a.WORK_ORDER,b.PART_NO,a.Request_QTY  from sajet.G_WO_PICK_LIST a,Sajet.sys_Part b where A.PART_ID=B.PART_ID and A.WORK_ORDER=:WORK_ORDER';
      Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
      Open;

  end;
  end;
  //QryTemp2.

end;

procedure TfDetail.btnDeleteClick(Sender: TObject);
var WO :string;
    PART_NO,iResult:string;
    strQty:Integer;
begin

   if not QryTemp2.Active or QryTemp2.IsEmpty  then
   begin
      Exit;
   end;

   WO:=QryTemp2.FieldByName('WORK_ORDER').AsString;
   PART_NO:=QryTemp2.FieldByName('PART_NO').AsString;
   strQty:=QryTemp2.FieldByName('REQUEST_QTY').AsInteger;


   with SProc do
   begin
        Close;
        DataRequest('SAJET.CCM_ADD_ERP_PICKLIST');
        FetchParams;
        Params.ParamByName('TWO').AsString := WO;
        Params.ParamByName('TPART_NO').AsString := PART_NO;
        Params.ParamByName('TQTY').AsInteger := strQty;
        Params.ParamByName('TOP_NO').AsInteger := 2;
        Params.ParamByName('TEMPID').AsString := UpdateUserID;
        Execute;
        iResult := Params.ParamByName('TRES').AsString ;
        if  iResult<>'OK' then begin
             MessageDlg(iResult,mtError,[mbOK],0);
             Exit;
        end;
   end;

   with QryTemp2 do
   begin
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
      CommandText := 'select a.WORK_ORDER,b.PART_NO,a.Request_QTY  from sajet.G_WO_PICK_LIST a,Sajet.sys_Part b where A.PART_ID=B.PART_ID and A.WORK_ORDER=:WORK_ORDER';
      Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
      Open;

   end;

end;

procedure TfDetail.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
    if Key=#13 then
    begin
        btnAdd.Click;
    end;
end;

procedure TfDetail.DBGrid1CellClick(Column: TColumn);

begin
  //Edit1.Text:=IntToStr(Column.);
end;

procedure TfDetail.sBtnChangeQtyClick(Sender: TObject);
var OldWOQty,NewWOQty:integer;
begin
    if EditWO.Text ='' then exit;
    if edtOldQty.Text  ='' then exit;
    if edtnewQty.Text  ='' then exit;
    
    with QryTemp do
    begin
         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         CommandText := 'Select * from sajet.G_WO_BASE where WORK_ORDER=:WORK_ORDER';
         Params.ParamByName('WORK_ORDER').AsString :=  editWO.Text;
         Open;
         if ISEmpty then begin
             MessageBox(0,'NOT FOUND WO','ERROR',mb_ICONERROR);
             exit;
         end;

         OldWOQty := StrTointDef(edtOldQty.Text ,0);
         NewWOQty := StrTointDef(edtNewQty.Text ,0);

         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         CommandText :=' Update SAJET.G_WO_PICK_LIST  SET REQUEST_QTY = REQUEST_QTY*'+ FloatToStr(NewWOQty/oldWOQty) +' where WORK_ORDER=:WORK_ORDER ';
         Params.ParamByName('WORK_ORDER').AsString :=  editWO.Text;
         execute;

         Close;
         Params.Clear;
         Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
         CommandText :=' Update SAJET.G_WO_PICK_Info  SET PICK_QTY = '+IntToStr(NewWOQty)+' where WORK_ORDER=:WORK_ORDER ';
         Params.ParamByName('WORK_ORDER').AsString :=  editWO.Text;
         execute;


         
    end;
    

    with QryTemp2 do
    begin
        Close;
        Params.Clear;
        Params.CreateParam(ftString, 'WORK_ORDER', ptInput);
        CommandText := 'select a.WORK_ORDER,b.PART_NO,a.Request_QTY  from sajet.G_WO_PICK_LIST a,Sajet.sys_Part b where A.PART_ID=B.PART_ID and A.WORK_ORDER=:WORK_ORDER';
        Params.ParamByName('WORK_ORDER').AsString := EditWO.Text;
        Open;
    end;
    MessageBox(0,'Change OK','Information ',mb_ICONINFORMATION);


    
end;

end.

