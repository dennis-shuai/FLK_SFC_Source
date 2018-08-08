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
    Label3: TLabel;
    Label4: TLabel;
    SaveDialog1: TSaveDialog;
    strgridData: TStringGrid;
    Image3: TImage;
    sbtnQuery: TSpeedButton;
    Label7: TLabel;
    Lblrecordcount: TLabel;
    ImageTitle: TImage;
    EditWO: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnQueryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fDetail: TfDetail;
  icol,irow:integer;
implementation

uses uCommData, uSelect;
{$R *.DFM}

procedure TfDetail.FormShow(Sender: TObject);
var i:integer;
begin  //GetReportName;
  with strgridData do
  begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=5;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=30;
           cells[0,0]:='ROWS';
           colwidths[1]:=120;
           cells[1,0]:='WORK_ORDER';
           colwidths[2]:=120;
           CELLS[2,0]:='SERIAL_NUMBER';
           colwidths[3]:=120;
           CELLS[3,0]:='SCRAP_USER';
           colwidths[4]:=120;
           CELLS[4,0]:='SCRAP_TIME';

  end;
    lblrecordcount.Caption :='';
end;

procedure TfDetail.FormClose(Sender: TObject; var Action: TCloseAction);
begin  
  Action := caFree;
end;

procedure TfDetail.sbtnQueryClick(Sender: TObject);
var i:integer;
begin
  for i:= 1 to strgridData.ROWCount do
    strgridData.ROWs[i].Clear;

  if trim(editwo.Text)='' then
  begin
     editwo.SelectAll ;
     editwo.SetFocus ;
     exit;
  end;

  with QryData do
  begin
    Close;
    commaNDtext:=' SELECT A.WORK_ORDER,A.SERIAL_NUMBER,B.EMP_NAME AS SCRAP_USER,A.UPDATE_TIME AS SCRAP_TIME '
                +' FROM SAJET.G_SN_REPAIR_SCRAP A,SAJET.SYS_EMP B '
                +' WHERE A.UPDATE_USERID=B.EMP_ID '
                +' AND A.WORK_ORDER = +'''+TRIM(EDITWO.Text)+''' '
                +' ORDER BY A.SERIAL_NUMBER ASC ';

    Open;
    if IsEmpty then
    begin
      lblrecordcount.Caption :='TOTAL:0';
      Showmessage('No Data');
      exit;
    end;

   strgridData.RowCount:=10;
   irow:=0;
   icol:=0;

   while not eof do
    begin
        IROW:=IROW+1;
        strgridData.Cells[0,irow]:=INTTOSTR(IROW);
        Strgriddata.Cells[1,irow]:=fieldbyname('WORK_ORDER').AsString   ;
        Strgriddata.Cells[2,irow]:=fieldbyname('SERIAL_NUMBER').AsString   ;
        Strgriddata.Cells[3,irow]:=fieldbyname('SCRAP_USER').AsString;
        Strgriddata.Cells[4,irow]:=fieldbyname('SCRAP_TIME').AsString ;
        next;
        Strgriddata.RowCount:=IROW+1;
        lblrecordcount.Caption :='TOTAL:'+ inttostr(irow);
    END;
  end;
end;


end.

