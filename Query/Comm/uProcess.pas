unit uProcess;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ExtCtrls, Buttons, StdCtrls, jpeg, GradPanel,
  Menus, IniFiles;

type
  TfProcess = class(TForm)
    GradPanel14: TGradPanel;
    Image3: TImage;
    Image4: TImage;
    sbtnClose: TSpeedButton;
    sbtnOK: TSpeedButton;
    Iimglist1: TImageList;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    LVStage: TTreeView;
    TreeProcess: TTreeView;
    PopupMenu1: TPopupMenu;
    muitemDisable: TMenuItem;
    N2: TMenuItem;
    Collapse1: TMenuItem;
    Expand1: TMenuItem;
    TreeProcessID: TTreeView;
    LVStageID: TTreeView;
    procedure sbtnOKClick(Sender: TObject);
    procedure sbtnCloseClick(Sender: TObject);
    procedure LVStageGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeProcessGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TreeProcessDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeProcessDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Collapse1Click(Sender: TObject);
    procedure Expand1Click(Sender: TObject);
    procedure muitemDisableClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    gsSQL: string;
    procedure ShowProcess;
  end;

var
  fProcess: TfProcess;

implementation

uses uDetail;

{$R *.dfm}

procedure TfProcess.sbtnOKClick(Sender: TObject);
var i: Integer;
begin
  TreeProcess.SaveToFile(fDetail.gsPath + fDetail.RpID + '.Txt');
  TreeProcessID.SaveToFile(fDetail.gsPath + fDetail.RpID + 'View.Txt');
  StrLstProcess.Clear;
  StrLstProcessName.Clear;
  for i := 0 to TreeProcessID.Items.Count - 1 do
    if TreeProcessID.Items[i].Level = 1 then begin
      StrLstProcess.Add(TreeProcessID.Items[i].Text);
      StrLstProcessName.Add(TreeProcess.Items[i].Text);
    end;
  StrLstProcess.SaveToFile(fDetail.gsPath + fDetail.RpID + 'ID.Txt');
  StrLstProcessName.SaveToFile(fDetail.gsPath + fDetail.RpID + 'Name.Txt');
  if TreeProcess.Items.Count = 0 then
  begin
    DeleteFile(fDetail.gsPath + fDetail.RpID + '.Txt');
    DeleteFile(fDetail.gsPath + fDetail.RpID + 'View.txt');
    DeleteFile(fDetail.gsPath + fDetail.RpID + 'ID.txt');
    DeleteFile(fDetail.gsPath + fDetail.RpID + 'Name.txt');
  end;
  modalresult := mrOK;
end;

procedure TfProcess.sbtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfProcess.LVStageGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TfProcess.TreeProcessGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TfProcess.ShowProcess;
var mS: string; mNode, mNode1: TTreeNode;
begin
  TreeProcess.Items.Clear;
  with fDetail.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := gsSQL;
    Open;
    if not IsEmpty then
    begin
      mS := Fieldbyname('STAGE_NAME').AsString;
      mNode := LVStage.Items.AddChildFirst(nil, FieldByName('STAGE_NAME').asstring);
      mNode1 := LVStageID.Items.AddChildFirst(nil, FieldByName('STAGE_NAME').asstring);
      mNode.ImageIndex := 0;
    end;
    while not Eof do
    begin
      if mS <> Fieldbyname('STAGE_NAME').AsString then
      begin
        mS := Fieldbyname('STAGE_NAME').AsString;
        mNode := LVStage.Items.AddChild(nil, FieldByName('STAGE_NAME').asstring);
        mNode1 := LVStageID.Items.AddChild(nil, FieldByName('STAGE_NAME').asstring);
        mNode.ImageIndex := 0;
      end;
      with LVStage.Items.AddChild(mNode, FieldByName('PROCESS_NAME').asstring) do
        ImageIndex := 1;
      LVStageId.Items.AddChild(mNode1, FieldByName('PROCESS_ID').asstring);
      next;
    end;
    Close;
    mNode := nil;
  end;
end;

procedure TfProcess.TreeProcessDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var I, j: Integer; mNodeLine, mNodeChild, mNode: TTreeNode; mB, mFind: Boolean;
begin
  if (Source is TTreeView) then
  begin
    if (Source as TTreeView).Name <> 'LVStage' then Exit;
    if LVStage.Selected.Level = 0 then
    begin
      mB := False;
      for I := 0 to TreeProcess.Items.Count - 1 do
        if TreeProcess.Items[i].Level = 0 then
          if TreeProcess.Items[i].Text = LVStage.Selected.Text then
          begin
            mNodeLine := TreeProcess.Items[i];
            mNodeChild := TreeProcessID.Items[i];
            mB := True;
            Break;
          end;
      if not mB then
      begin
        mNodeLine := TreeProcess.Items.AddChild(nil, LVStage.Selected.Text);
        mNodeChild := TreeProcessID.Items.AddChild(nil, LVStage.Selected.Text);
        mNodeLine.ImageIndex := 0;
      end;
      for I := 0 to LVStage.Selected.Count - 1 do
      begin
        mFind := False;
        if mB then
          for j := 0 to mNodeLine.Count - 1 do
            if mNodeLine.Item[j].Text = LVStage.Selected.Item[i].Text then
            begin
              mFind := True;
              Break;
            end;
        if not mFind then begin
          with TreeProcess.Items.AddChild(mNodeLine, LVStage.Selected.Item[I].Text) do
            ImageIndex := 1;
          TreeProcessID.Items.AddChild(mNodeChild, LVStageID.Items[LVStage.Selected.Item[I].AbsoluteIndex].Text);
        end;
      end;
      mNodeLine := nil;
    end
    else
    begin
      mB := False;
      for I := 0 to TreeProcess.Items.Count - 1 do
        if TreeProcess.Items[I].Text = LVStage.Selected.Parent.Text then
        begin
          mNodeLine := TreeProcess.Items[I];
          mNodeChild := TreeProcessID.Items[I];
          mB := True;
          Break;
        end;

      if not mB then
      begin
        mNodeLine := TreeProcess.Items.AddChild(nil, LVStage.Selected.Parent.Text);
        mNodeChild := TreeProcessID.Items.AddChild(nil, LVStage.Selected.Parent.Text);
        mNodeChild.ImageIndex := 0;
      end
      else
      begin
        // 找子節點存不存在
        mB := False;
        for I := 0 to mNodeLine.Count - 1 do
          if mNodeLine.Item[I].Text = LVStage.Selected.Text then
          begin
            mB := True;
            Break;
          end;
      end;
      if not mB then begin
        with TreeProcess.Items.AddChild(mNodeLine, LVStage.Selected.Text) do
          ImageIndex := 1;
        TreeProcessID.Items.AddChild(mNodeChild, LVStageID.Items[LVStage.Selected.AbsoluteIndex].Text);
      end;
      mNodeChild := nil;
    end;
  end;
end;

procedure TfProcess.TreeProcessDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Source is TTreeView) then
  begin
    if (Source as TTreeView).Name <> 'LVStage' then Exit;
    if (Source as TTreeView).Selected <> nil then Accept := True;
  end;
end;

procedure TfProcess.FormShow(Sender: TObject);
begin
  ShowProcess;
  if FileExists(fDetail.gsPath + fDetail.RpID + '.Txt') then begin
    TreeProcess.LoadFromFile(fDetail.gsPath + fDetail.RpID + '.Txt');
    TreeProcessID.LoadFromFile(fDetail.gsPath + fDetail.RpID + 'View.Txt');
  end;
end;

procedure TfProcess.Collapse1Click(Sender: TObject);
begin
  TreeProcess.FullCollapse;
end;

procedure TfProcess.Expand1Click(Sender: TObject);
begin
  TreeProcess.FullExpand;
end;

procedure TfProcess.muitemDisableClick(Sender: TObject);
begin
  if TreeProcess.Selected = nil then Exit;
  TreeProcessID.Items.Delete(TreeProcessID.Items[TreeProcess.Selected.AbsoluteIndex]);
  TreeProcess.Selected.Delete;
end;

end.

