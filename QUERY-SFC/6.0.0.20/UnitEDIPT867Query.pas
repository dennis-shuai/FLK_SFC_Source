unit UnitEDIPT867Query;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, DBClient;

type
  TFormEDIPT867 = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    btnCLOSE: TButton;
    CMBIDTYPE: TComboBox;
    Editidtype: TEdit;
    BtnQuery: TButton;
    GroupBox2: TGroupBox;
    DBGridPT867: TDBGrid;
    ClientDataSetPT867: TClientDataSet;
    DSpt867: TDataSource;
    DSNULL: TDataSource;
    Label2: TLabel;
    lblrecordcount: TLabel;
    GroupBoxpallet: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    DBGridserial: TDBGrid;
    DBGridreference: TDBGrid;
    btnclose1: TButton;
    ClientDataSetserial: TClientDataSet;
    DSserial: TDataSource;
    ClientDataSetreference: TClientDataSet;
    DSReference: TDataSource;
    Label3: TLabel;
    Label4: TLabel;
    lblserial: TLabel;
    lblreference: TLabel;
    procedure btnCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CLEARDATA;
    procedure queryitemandheader(strsql: string);
    procedure queryheader(strsql: string);
    procedure queryserial(strsql: string);
    procedure queryreference(strsql: string);
    procedure BtnQueryClick(Sender: TObject);
    procedure btnclose1Click(Sender: TObject);
    procedure DBGridPT867DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEDIPT867: TFormEDIPT867;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormEDIPT867.CLEARDATA;
begin
    editidtype.Clear ;
    editidtype.SetFocus ;
    dbgridpt867.DataSource :=dsnull;
    lblrecordcount.Caption :='';
end;

procedure TFormEDIPT867.queryitemandheader(strsql: string);
begin
    WITH CLIENTDATASETPT867 DO
      begin
          close;
          commandtext:='SELECT A.DOC_ID ,A.WORK_ORDER_NUMBER AS WORK_ORDER, B.INVENTORY_BATCH_ID AS PALLET_NO,A.TRANSFER_QUANTITY AS WO_QTY ,  '
                     + ' B.FINISH_DATE FROM  B2B.PT_ITEMS A, B2B.PT_HEADER B '
                     + '  WHERE A.DOC_ID=B.DOC_ID AND A.WORK_ORDER_NUMBER=:work_order '
                     + '  UNION SELECT A.DOC_ID ,A.WORK_ORDER_NUMBER AS WORK_ORDER, B.INVENTORY_BATCH_ID AS PALLET_NO,A.TRANSFER_QUANTITY AS WO_QTY ,  '
                     + ' B.FINISH_DATE FROM  B2B.HT_PT_ITEMS A, B2B.HT_PT_HEADER B '
                     + '  WHERE A.DOC_ID=B.DOC_ID AND A.WORK_ORDER_NUMBER=:work_order ';
          params.ParamByName('work_order').AsString :=strsql;
          open;

          dbgridpt867.DataSource :=dspt867;
          lblrecordcount.Caption :=inttostr(recordcount) ;
      end;
end;

procedure TFormEDIPT867.queryheader(strsql: string);
begin
    WITH CLIENTDATASETPT867 DO
      begin
          close;
          commandtext:='SELECT A.DOC_ID ,A.WORK_ORDER_NUMBER AS WORK_ORDER, B.INVENTORY_BATCH_ID AS PALLET_NO,A.TRANSFER_QUANTITY AS WO_QTY ,  '
                  + ' B.FINISH_DATE FROM  B2B.PT_ITEMS A, B2B.PT_HEADER B '
                  + '  WHERE A.DOC_ID=B.DOC_ID AND B.INVENTORY_BATCH_ID=:PALLET_NO '
                  + '  UNION SELECT A.DOC_ID ,A.WORK_ORDER_NUMBER AS WORK_ORDER, B.INVENTORY_BATCH_ID AS PALLET_NO,A.TRANSFER_QUANTITY AS WO_QTY ,  '
                  + ' B.FINISH_DATE FROM  B2B.HT_PT_ITEMS A, B2B.HT_PT_HEADER B '
                  + '  WHERE A.DOC_ID=B.DOC_ID AND B.INVENTORY_BATCH_ID=:PALLET_NO ';
          params.ParamByName('PALLET_NO').AsString :=strsql;
          open;

          dbgridpt867.DataSource :=dspt867;
          lblrecordcount.Caption :=inttostr(recordcount) ;
      end;
end;

procedure TFormEDIPT867.queryserial(strsql: string);
begin
    WITH CLIENTDATASETserial DO
      begin
          close;
          commandtext:='SELECT SERIAL_NUMBER AS EDA_SN, FIRMWARE_VERSION AS EDA_VER,MOVE_FLAG from B2B.PT_SERIAL '
                     +' where DOC_ID=:DOC_ID '
                     +' UNION SELECT SERIAL_NUMBER AS EDA_SN, FIRMWARE_VERSION AS EDA_VER,MOVE_FLAG from B2B.HT_PT_SERIAL '
                     +' where DOC_ID=:DOC_ID ' ;

          params.ParamByName('DOC_ID').AsString :=strsql;
          open;

          dbgridserial.DataSource :=DSSERIAL;
          lblSERIAL.Caption :=inttostr(recordcount) ;
      end;
end;

procedure TFormEDIPT867.queryreference(strsql: string);
begin
    WITH CLIENTDATASETreference DO
      begin
          close;
          commandtext:='SELECT SERIAL_NUMBER AS EDA_SN ,DRIVE_SERIAL_NUMBER AS HDD_SN,DRIVE_POSITION AS HDD_POS, '
                      +' DRIVE_FIRMWARE_VERSION AS HDD_VER,MOVE_FLAG from B2B.PT_REFERENCE where doc_id=:doc_id '
                      +'union SELECT SERIAL_NUMBER AS EDA_SN ,DRIVE_SERIAL_NUMBER AS HDD_SN,DRIVE_POSITION AS HDD_POS, '
                      +' DRIVE_FIRMWARE_VERSION AS HDD_VER,MOVE_FLAG from B2B.HT_PT_REFERENCE where doc_id=:doc_id ';
          params.ParamByName('DOC_ID').AsString :=strsql;
          open;

          dbgridreference.DataSource :=DSreference;
          lblreference.Caption :=inttostr(recordcount) ;
      end;
end;

procedure TFormEDIPT867.btnCLOSEClick(Sender: TObject);
begin
    if clientdatasetpt867.Active then
       clientdatasetpt867.Close;
    close;
end;

procedure TFormEDIPT867.FormShow(Sender: TObject);
begin
   clientdatasetPT867.RemoteServer :=formmain.socketconnection1;
   clientdatasetPT867.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetserial.RemoteServer :=formmain.socketconnection1;
   clientdatasetserial.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetreference.RemoteServer :=formmain.socketconnection1;
   clientdatasetreference.ProviderName :=formmain.Clientdataset1.ProviderName ;
   cleardata;
   if groupboxpallet.Visible  =true then
      groupboxpallet.Visible  :=false;
end;

procedure TFormEDIPT867.BtnQueryClick(Sender: TObject);
begin
    if cmbidtype.Text ='Work_order' then
        begin
          queryitemandheader(uppercase(trim(editidtype.Text )));
        end;
    if cmbidtype.Text = 'Pallet' then
       begin
          queryheader(uppercase(trim(editidtype.Text )));
       end;

 end;

procedure TFormEDIPT867.btnclose1Click(Sender: TObject);
begin
   lblserial.Caption :='';
   lblreference.Caption :='';
   dbgridserial.DataSource :=dsnull;
   dbgridreference.DataSource :=dsnull;
   if clientdatasetserial.Active  then
      clientdatasetserial.Close ;
   if clientdatasetreference.Active  then
      clientdatasetreference.Close ;
   if groupboxpallet.Visible  =true then
      groupboxpallet.Visible  :=false ;
      
end;

procedure TFormEDIPT867.DBGridPT867DblClick(Sender: TObject);
begin
    if not clientdatasetpt867.Active then
       exit;

    lblserial.Caption :='';
    lblreference.Caption :='';
    dbgridserial.DataSource :=dsnull;
    dbgridreference.DataSource :=dsnull;
    if groupboxpallet.Visible  =false then
       groupboxpallet.Visible  :=true ;


    queryserial(dbgridpt867.Fields[0].asstring);
    queryreference(dbgridpt867.Fields[0].asstring);
    dbgridserial.Columns[0].Width:=80;
    dbgridreference.Columns[0].Width:=80;
    dbgridreference.Columns[1].Width:=80;
    dbgridreference.Columns[2].Width:=60;
    dbgridreference.Columns[3].Width:=60;
end;

end.
