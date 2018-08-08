unit uDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, jpeg, ExtCtrls, Grids, DBGrids, ComCtrls, Db,
  DBClient, MConnect, ObjBrkr, SConnect,GradPanel, Variants, comobj, Menus;

type
  TfDetail = class(TForm)
    Panel1: TPanel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    QryTemp2: TClientDataSet;
    PageControl1: TPageControl;
    TabData: TTabSheet;
    GradPanel14: TGradPanel;
    Image7: TImage;
    sbtnSave: TSpeedButton;
    Image8: TImage;
    sbtnPrint: TSpeedButton;
    ImageTitle: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    Image3: TImage;
    sbtnQuerysoheader: TSpeedButton;
    Lblrecordcount: TLabel;
    DBGrid1: TDBGrid;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Image4: TImage;
    sbtquerysoitems: TSpeedButton;
    DataSource1: TDataSource;
    DSNULL: TDataSource;
    procedure sbtnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure sbtnQuerysoheaderClick(Sender: TObject);
    procedure sbtquerysoitemsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

   // function AddCondition(sField: string; sList: TListBox): string;  
    procedure SaveExcel(MsExcel, MsExcelWorkBook: Variant);
    procedure ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.SaveExcel(MsExcel, MsExcelWorkBook: Variant);
var i, j,iStartRow,iDiv,iMod: integer;
    vRange1:Variant;
begin
   istartrow:=2 ;
   qrytemp.First ;
   for j := 0 to dbgrid1.FieldCount-1  do
      MsExcel.Worksheets['Sheet1'].Cells[iStartRow,j+1].value :=qrytemp.Fields[j].FieldName  ;
  // for i := 0 to strtoint(lblrecordcount.Caption)-1  do
    i:=0;
    while not qrytemp.Eof do
      BEGIN
          for j := 0 to dbgrid1.FieldCount-1  do
            MsExcel.Worksheets['Sheet1'].Cells[i+iStartRow+1,j+1].value :=qrytemp.Fields[j].AsString  ;
          qrytemp.Next;
          i:=i+1;
      END ;
end;


procedure TfDetail.sbtnSaveClick(Sender: TObject);
var
  sFileName, My_FileName: string;
  MsExcel, MsExcelWorkBook: Variant;
  i: Integer;
begin
  if (not Qrytemp.Active) or (Qrytemp2.active) then Exit;
  SaveDialog1.InitialDir := ExtractFilePath('C:\');
  SaveDialog1.DefaultExt := 'xls';
  SaveDialog1.Filter := 'All Files(*.xls)|*.xls';

  My_FileName := ExtractFilePath(Application.ExeName)+'QUERYEDI850.xlt';

  if not FileExists(My_FileName) then
  begin
    showmessage('Error!-The Excel File ' + My_FileName + ' can''t be found.');
    exit;
  end;

  if Sender = sbtnSave then
  begin
    if SaveDialog1.Execute then
      sFileName := SaveDialog1.FileName
    else
      exit;  
  end;

  try
    MsExcel := CreateOleObject('Excel.Application');
    MsExcelWorkBook := MsExcel.WorkBooks.Open(My_FileName);

    MsExcel.Worksheets['Sheet1'].select;
    SaveExcel(MsExcel, MsExcelWorkBook);
    if Sender = sbtnSave then
    begin
      MsExcelWorkBook.SaveAs(sFileName);
      showmessage('Save Excel OK!!');
    end;
    if Sender = sbtnPrint then
    begin
      WindowState := wsMinimized;
      MsExcel.Visible := TRUE;
      MsExcel.WorkSheets['Sheet1'].PrintPreview;
      WindowState := wsMaximized;
    end;
  except
    ShowMessage('Could not start Microsoft Excel.');
  end;
  MsExcelWorkBook.close(False);
  MsExcel.Application.Quit;
  MsExcel := Null;

end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;



procedure TfDetail.ShowAllData(sTitle,sFieldName,sFieldID:string;ListField:TListBox);
Var I,iIndex : Integer;
   tsFieldName,tsFieldID:TStringList;
begin
  //fSelect:=TfSelect.create(Self);
  with TfSelect.create(Self) do
  begin
    try
      listbAvail.Clear;
      listbSel.Clear;
      tsFieldName := TStringList.Create;
      tsFieldID := TStringList.Create;

      lablTitle.Caption := sTitle+' List ';
      if ListField.Items.Count <> 0 then begin
        for I := 0 to ListField.Items.Count - 1 do
        begin
           if listbSel.Items.IndexOf(ListField.Items[i])<0 Then
             listbSel.Items.AddObject(ListField.Items[I],
           ListField.Items.Objects[I]);
        end;
      end;

      While not fDetail.qryTemp.Eof do
      begin
        if  listbSel.Items.Indexof(fDetail.qryTemp.Fields[0].AsString)=-1 then
          listbAvail.Items.Add(fDetail.qryTemp.Fields[0].AsString);
        tsFieldName.Add(fDetail.qryTemp.Fields[0].AsString);
        fDetail.qryTemp.Next;
      end;
      if ShowModal = mrOK then
      begin
        ListField.Clear;
        if listbSel.Items.Count <> 0 then
        begin
          for I := 0 to listbSel.Items.Count - 1 do
          begin
            if ListField.Items.IndexOf(listbSel.Items[i])<0 Then
            begin
                ListField.Items.AddObject(listbSel.Items[I],listbSel.Items.Objects[I]);
                iIndex := tsFieldName.Indexof(listbSel.Items[I]);
            end;
          end;
        end;
      end;
    finally
      fDetail.qryTemp.Close;
      tsFieldName.free;
      tsFieldID.free;
      free;
    end;
  end;
end;





procedure TfDetail.FormShow(Sender: TObject);
begin
     Dbgrid1.DataSource :=dsnull;
     lblrecordcount.Caption :='0'; 
end;

procedure TfDetail.sbtnQuerysoheaderClick(Sender: TObject);
begin
     with qrytemp do
        begin
             close;
             commandtext:='select * from b2b.so_header@sfc2erp '
                        +' where so_header_id is null '
                        +' order by cust_po_date desc, doc_id desc ' ;
             open;
             dbgrid1.DataSource :=dsnull;
             dbgrid1.DataSource :=datasource1;
             lblrecordcount.Caption :=inttostr(recordcount);
        end ;
end;

procedure TfDetail.sbtquerysoitemsClick(Sender: TObject);
begin
    with qrytemp do
      begin
          close;
          commandtext:='select * from b2b.so_items@sfc2erp  '
                      +' where so_header_id is null and so_line_id is null '
                      +' order by doc_id desc ' ;
          open;
          dbgrid1.DataSource :=dsnull;
          dbgrid1.DataSource :=datasource1;
          lblrecordcount.Caption :=inttostr(recordcount);
       end;
end;

end.

