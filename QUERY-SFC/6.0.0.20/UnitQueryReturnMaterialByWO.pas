unit UnitQueryReturnMaterialByWO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, StdCtrls, Grids, DBGrids;

type
  TFormReturnMaterialByWO = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LABEL4: TLabel;
    DBGrid1: TDBGrid;
    Butquery: TButton;
    ButCLOSE: TButton;
    EditWO: TEdit;
    Editpart_no: TEdit;
    Editrecordcount: TEdit;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    procedure ButCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButqueryClick(Sender: TObject);
    procedure Editpart_noKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormReturnMaterialByWO: TFormReturnMaterialByWO;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormReturnMaterialByWO.ButCLOSEClick(Sender: TObject);
begin
   close
end;

procedure TFormReturnMaterialByWO.FormShow(Sender: TObject);
begin
   clientdataset1.RemoteServer :=formmain.socketconnection1;
   clientdataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;

   editwo.Clear ;
   editpart_no.Clear;
   editrecordcount.Clear ;
end;

procedure TFormReturnMaterialByWO.ButqueryClick(Sender: TObject);
begin
    with clientdataset1  do
        begin
            close;
            commandtext:='SELECT B.PART_NO,A.MATERIAL_NO,A.QTY,A.MFGER_PART_NO,A.MFGER_NAME '
                  + ' FROM sajet.G_HT_PICK_LIST A,sajet.SYS_PART B ,sajet.SYS_EMP C WHERE A.WORK_ORDER=:work_order AND A.PART_ID=B.PART_ID'
                  + ' AND A.UPDATE_USERID=C.EMP_ID(+) ORDER BY PART_NO'  ;
            params.ParamByName('work_order').AsString :=uppercase(trim(editwo.Text));
            open;

            editrecordcount.Text :=inttostr(RecordCount);
        end;
end;

procedure TFormReturnMaterialByWO.Editpart_noKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 IF EDITWO.Text<>'' THEN
   IF KEY=13 THEN
     BEGIN
         with clientdataset1  do
        begin
            close;
            commandtext:='SELECT B.PART_NO,A.MATERIAL_NO,A.QTY,A.MFGER_PART_NO,A.MFGER_NAME '
                  + ' FROM sajet.G_HT_PICK_LIST A,sajet.SYS_PART B ,sajet.SYS_EMP C WHERE A.WORK_ORDER=:work_order AND B.PART_NO=:PART_NO AND A.PART_ID=B.PART_ID'
                  + ' AND A.UPDATE_USERID=C.EMP_ID(+) ORDER BY A.MATERIAL_NO'  ;
            params.ParamByName('work_order').AsString :=uppercase(trim(editwo.Text));
            params.ParamByName('PART_NO').AsString :=uppercase(trim(EDITPART_NO.Text));
            open;


            editrecordcount.Text :=inttostr(RecordCount);
        end;
     END;
end;

end.
