unit uSubPart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, DB, DBTables, DBClient;

type
  TfSubPart = class(TForm)
    Label5: TLabel;
    edtSubPart: TEdit;
    Image2: TImage;
    sbtnFilter: TSpeedButton;
    labName: TLabel;
    edtPart: TEdit;
    Image5: TImage;
    Image1: TImage;
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    qryTemp: TClientDataSet;
    Label1: TLabel;
    procedure sbtnFilterClick(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g_type,gsPart, G_sMSLNO, G_WO,G_sWoSeq, G_SubPart: string;
  end;

var
  fSubPart: TfSubPart;

implementation

uses uFilter, uformPosition, uformMain;

{$R *.dfm}

procedure TfSubPart.sbtnFilterClick(Sender: TObject);
begin
  try
    fFilter := TfFilter.Create(self);
    with fFilter.qryData do
    begin
      RemoteServer := formMain.QryTemp.RemoteServer;
      Close;
      Params.Clear;
      Params.CreateParam(ftString,'PART_NO',ptInput);
      CommandText :='  SELECT Part_No, Spec1 '
                  + '   FROM SAJET.SYS_PART '
                  + '   WHERE PART_NO LIKE :PART_NO '
                  + '   ORDER BY PART_NO ';
      Params.ParamByName('PART_NO').AsString := Trim(edtSubPart.Text) + '%';
      Open;
      if not IsEmpty then
         if fFilter.Showmodal = mrOK then
            edtSubPart.Text := Fieldbyname('PART_NO').AsString;
      Close;
    end;
  finally
    fFilter.Free;
  end;
end;

procedure TfSubPart.sbtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfSubPart.sbtnSaveClick(Sender: TObject);
   Function CheckPart(sItem: string ;Var sID :String):Boolean;
   begin
      Result := False;
      with QryTemp do
      begin
         Close;
         PArams.Clear;
         PArams.CreateParam(ftString,'KEY_PART_NO',ptInput);
         CommandText := 'Select PART_ID ' +
                  'From SAJET.SYS_PART ' +
                  'Where PART_NO = :KEY_PART_NO '+
                  '  and rownum = 1 ';
         PArams.ParamByName('KEY_PART_NO').AsString := sItem;
         Open;
         if IsEmpty then
               MessageDlg('Part Error !!' , mtError, [mbCancel], 0)
         else
         begin
           sID := FieldByName('PART_ID').AsString;
           Result := True;
         end;
      end;
   end;
var sTable, sField, sMslNo, sTable1,sPartID ,sPartItemID,sOldSubPart: String;
begin
  sPartID :='';
  sPartItemID :='';
  sOldSubPart :='';
  IF edtPart.Text = edtSubPart.Text Then
  begin
     Exit;
  end;
  IF Trim(edtSubPart.Text)='' Then
  begin
     Exit;
  end;
  If Not CheckPart(edtPart.Text,sPartID) Then
     Exit;
  If Not CheckPart(edtSubPart.Text,sPartItemID) Then
     Exit;
  with qryTemp do
  begin
    Close;
    PArams.Clear;
    Params.CreateParam(ftString,'WO_SEQUENCE',ptInput);
    Params.CreateParam(ftString,'ITEM_PART_ID',ptInput);
    Params.CreateParam(ftString,'SUB_PART_ID',ptInput);
    commandText := 'select * from SMT.G_WO_MSL_SUB '
                 + 'where WO_SEQUENCE  = :WO_SEQUENCE '
                 + 'and  ITEM_PART_ID = :ITEM_PART_ID '
                 + 'and  SUB_PART_ID = :SUB_PART_ID ';
    Params.ParamByName('WO_SEQUENCE').AsString := G_sWoSeq;
    Params.ParamByName('ITEM_PART_ID').AsString := sPartID;
    Params.ParamByName('SUB_PART_ID').AsString := sPartItemID;
    Open;
    if not IsEmpty then
    begin
      MessageDlg('Substitue Part NO Duplicate.', mtError, [mbOK], 0);
      Exit;
    end
  End;
  IF g_Type = 'Append' Then
  begin
      with qryTemp do
      begin
        Close;
        PArams.Clear;
        Params.CreateParam(ftString,'WO_SEQUENCE',ptInput);
        Params.CreateParam(ftString,'ITEM_PART_ID',ptInput);
        Params.CreateParam(ftString,'SUB_PART_ID',ptInput);
        Params.CreateParam(ftString,'WORK_ORDER',ptInput);
        commandText := 'Insert Into SMT.G_WO_MSL_SUB '
                     + ' (WO_SEQUENCE,ITEM_PART_ID,SUB_PART_ID,WORK_ORDER) '
                     + 'Values (:WO_SEQUENCE,:ITEM_PART_ID,:SUB_PART_ID,:WORK_ORDER) ';
        Params.ParamByName('WO_SEQUENCE').AsString := G_sWoSeq;
        Params.ParamByName('ITEM_PART_ID').AsString := sPartID;
        Params.ParamByName('SUB_PART_ID').AsString := sPartItemID;
        Params.ParamByName('WORK_ORDER').AsString := G_WO;
        Execute;
        Close;
      end;
  end
  else
  begin
    If Not CheckPart(G_SubPart,sOldSubPart) Then
       Exit;
    with qryTemp do begin
      Close;
      PArams.Clear;
      Params.CreateParam(ftString,'SUB_PART_ID',ptInput);
      Params.CreateParam(ftString,'WO_SEQUENCE',ptInput);
      Params.CreateParam(ftString,'ITEM_PART_ID',ptInput);
      Params.CreateParam(ftString,'OLD',ptInput);
      commandText := 'update SMT.G_WO_MSL_SUB '
                   + ' set SUB_PART_ID = :SUB_PART_ID '
                   + ' where WO_SEQUENCE = :WO_SEQUENCE '
                   + ' and ITEM_PART_ID = :ITEM_PART_ID '
                   + ' and SUB_PART_ID = :OLD ';
      Params.ParamByName('SUB_PART_ID').AsString := sPartItemID;
      Params.ParamByName('WO_SEQUENCE').AsString := G_sWoSeq;
      Params.ParamByName('ITEM_PART_ID').AsString := sPartID;
      Params.ParamByName('OLD').AsString := sOldSubPart;
      Execute;
      Close;
    end;
  end;
  ModalResult := mrOK;
end;

procedure TfSubPart.FormShow(Sender: TObject);
begin
  edtPart.Text :=  gsPart ;
  IF G_SubPart <> '' Then
     edtSubPart.Text := G_SubPart
  else
     edtSubPart.Text := '';
end;

end.
