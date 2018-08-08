unit UnitQueryCheckMaterialByWO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls;

type
  TFormQueryCheckMaterialByWO = class(TForm)
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Butquery: TButton;
    Label1: TLabel;
    ButCLOSE: TButton;
    Label2: TLabel;
    EditWO: TEdit;
    Label3: TLabel;
    Editpart_no: TEdit;
    LABEL4: TLabel;
    Editrecordcount: TEdit;
    procedure FormShow(Sender: TObject);
    procedure ButqueryClick(Sender: TObject);
    procedure ButCLOSEClick(Sender: TObject);
    procedure Editpart_noKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormQueryCheckMaterialByWO: TFormQueryCheckMaterialByWO;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormQueryCheckMaterialByWO.FormShow(Sender: TObject);
begin
   clientdataset1.RemoteServer :=formmain.socketconnection1;
   clientdataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;

   editwo.Clear ;
   editpart_no.Clear;
   editrecordcount.Clear ;
end;

procedure TFormQueryCheckMaterialByWO.ButqueryClick(Sender: TObject);
begin
     with clientdataset1  do
        begin
            close;
            commandtext:='SELECT B.PART_NO,A.MATERIAL_NO,A.QTY, A.SEQUENCE,A.UPDATE_TIME,C.EMP_NAME AS CHECK_USER,A.MFGER_PART_NO,A.MFGER_NAME '
                  + ' FROM sajet.G_PICK_LIST A,sajet.SYS_PART B ,sajet.SYS_EMP C WHERE A.WORK_ORDER=:work_order AND A.PART_ID=B.PART_ID'
                  + ' AND A.UPDATE_USERID=C.EMP_ID(+) ORDER BY PART_NO'  ;
            params.ParamByName('work_order').AsString :=uppercase(trim(editwo.Text));
            open;


            editrecordcount.Text :=inttostr(RecordCount);
        end;
end;



procedure TFormQueryCheckMaterialByWO.ButCLOSEClick(Sender: TObject);
begin
   close;
end;

procedure TFormQueryCheckMaterialByWO.Editpart_noKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
 IF EDITWO.Text<>'' THEN
   IF KEY=13 THEN
     BEGIN
         with clientdataset1  do
        begin
            close;
            commandtext:='SELECT B.PART_NO,A.MATERIAL_NO,A.QTY, A.SEQUENCE,A.UPDATE_TIME,C.EMP_NAME AS CHECK_USER,A.MFGER_PART_NO,A.MFGER_NAME '
                  + ' FROM sajet.G_PICK_LIST A,sajet.SYS_PART B ,sajet.SYS_EMP C WHERE A.WORK_ORDER=:work_order AND B.PART_NO=:PART_NO AND A.PART_ID=B.PART_ID'
                  + ' AND A.UPDATE_USERID=C.EMP_ID(+) ORDER BY A.MATERIAL_NO'  ;
            params.ParamByName('work_order').AsString :=uppercase(trim(editwo.Text));
            params.ParamByName('PART_NO').AsString :=uppercase(trim(EDITPART_NO.Text));
            open;


            editrecordcount.Text :=inttostr(RecordCount);
        end;
     END;

end;

end.
