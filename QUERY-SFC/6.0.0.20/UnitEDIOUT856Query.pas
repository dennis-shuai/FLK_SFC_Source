unit UnitEDIOUT856Query;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, Grids, DBGrids;

type
  TFormOut856 = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    btnCLOSE: TButton;
    CMBIDTYPE: TComboBox;
    Editidtype: TEdit;
    BtnQuery: TButton;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    lblrecordcount: TLabel;
    DBGridOUT856: TDBGrid;
    ClientDataSetOUT856: TClientDataSet;
    DSOUT856: TDataSource;
    DSNULL: TDataSource;
    procedure CLEARDATA;
    procedure OUT856QueryBYDNNO(STRSQL:STRING);
    procedure OUT856QueryBYpallet(STRSQL:STRING);
    procedure btnCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnQueryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormOut856: TFormOut856;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormOut856.CLEARDATA;
begin
   editidtype.Clear ;
   editidtype.SetFocus ;
   dbgridout856.DataSource :=dsnull;
   lblrecordcount.Caption :='';
end;

procedure TFormOut856.OUT856QueryBYDNNO(STRSQL:STRING);
begin
   WITH clientdatasetout856 do
      begin
          close;
          commandtext:=' select A.DOC_ID,SHIPPER_NUMBER AS DN_NO,B.PALLET_ID AS PALLET_NO,A.SHIP_CREATE_DATE FROM b2b.asn_out_header A,  '
                      +' b2b.asn_out_pallet B WHERE A.DOC_ID=B.DOC_ID AND A.SHIPPER_NUMBER=:shipper_number '
                      +' union select A.DOC_ID,SHIPPER_NUMBER AS DN_NO,B.PALLET_ID AS PALLET_NO,A.SHIP_CREATE_DATE FROM b2b.ht_asn_out_header A,  '
                      +' b2b.ht_asn_out_pallet B WHERE A.DOC_ID=B.DOC_ID AND A.SHIPPER_NUMBER=:shipper_number ' ;
          params.ParamByName('shipper_number').AsString :=strsql;
          open;

          dbgridout856.DataSource :=dsout856;
          lblrecordcount.Caption :=inttostr(recordcount); 
     end;
end;

procedure TFormOut856.OUT856QueryBYpallet(STRSQL:STRING);
begin
   WITH clientdatasetout856 do
      begin
          close;
          commandtext:=' select A.DOC_ID,SHIPPER_NUMBER AS DN_NO,B.PALLET_ID AS PALLET_NO,A.SHIP_CREATE_DATE FROM b2b.asn_out_header A,  '
                      +' b2b.asn_out_pallet B WHERE A.DOC_ID=B.DOC_ID AND b.pallet_id=:pallet_id '
                      +' union select A.DOC_ID,SHIPPER_NUMBER AS DN_NO,B.PALLET_ID AS PALLET_NO,A.SHIP_CREATE_DATE FROM b2b.ht_asn_out_header A,  '
                      +' b2b.ht_asn_out_pallet B WHERE A.DOC_ID=B.DOC_ID AND  b.pallet_id=:pallet_id ' ;
          params.ParamByName('pallet_id').AsString :=strsql;
          open;

          dbgridout856.DataSource :=dsout856;
          lblrecordcount.Caption :=inttostr(recordcount);
     end;
end;

procedure TFormOut856.btnCLOSEClick(Sender: TObject);
begin
   close;
end;

procedure TFormOut856.FormShow(Sender: TObject);
begin
   clientdatasetOUT856.RemoteServer :=formmain.socketconnection1;
   clientdatasetOUT856.ProviderName :=formmain.Clientdataset1.ProviderName ;

   CLEARDATA;
end;

procedure TFormOut856.BtnQueryClick(Sender: TObject);
begin
    if trim(editidtype.Text) <>'' then
       begin
           if cmbidtype.Text='DN_NO' THEN
               OUT856QueryBYDNNO(trim(editidtype.Text ));
           if cmbidtype.Text ='Pallet' then
               OUT856QueryBYpallet(trim(editidtype.Text ));

           dbgridout856.Columns[0].Width :=80;
           dbgridout856.Columns[1].Width :=60;
           dbgridout856.Columns[2].Width :=120;
           dbgridout856.Columns[3].Width :=200;
       end;
end;

end.
