unit UnitEDIIN861Query;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, ComCtrls, Grids, DBGrids;

type
  TFormEDIIN861Query = class(TForm)
    Label1: TLabel;
    CMBIDTYPE: TComboBox;
    Editidtype: TEdit;
    BtnQuery: TButton;
    BTNclose: TButton;
    ClientDataSetpallet: TClientDataSet;
    DSpallet: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    DBGridenvelope: TDBGrid;
    DBGridheader: TDBGrid;
    DBGridpallet: TDBGrid;
    DBGridcarton: TDBGrid;
    ClientDataSetenvelope: TClientDataSet;
    DSENVELOPE: TDataSource;
    ClientDataSetheader: TClientDataSet;
    Dsheader: TDataSource;
    ClientDataSetcarton: TClientDataSet;
    DSCARTON: TDataSource;
    DSNULL: TDataSource;
    Label2: TLabel;
    Label3: TLabel;
    pallet_total: TLabel;
    carton_total: TLabel;
    procedure BTNcloseClick(Sender: TObject);
    procedure cleardata;
    procedure FormShow(Sender: TObject);
    procedure CMBIDTYPEChange(Sender: TObject);
    procedure queryenvelope(strdoc:string);
    procedure queryheader(strdoc:string);
    procedure querypallet(strdoc:string);
    procedure querycarton(strdoc:string);
    procedure BtnQueryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEDIIN861Query: TFormEDIIN861Query;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormEDIIN861Query.cleardata;
begin
  // editidtype.Clear ;
  // editidtype.SetFocus ;
   dbgridenvelope.DataSource :=dsnull;
   dbgridheader.DataSource :=dsnull;
   dbgridpallet.DataSource :=dsnull;
   dbgridcarton.DataSource :=dsnull;

   pallet_total.Caption :='';
   carton_total.Caption :='';
end;

procedure TFormEDIIN861Query.queryenvelope(strdoc:string);
begin
    with clientdatasetenvelope do
         begin
             close;
             commandtext:='select doc_id,doc_datetime,move_flag from b2b.envelope where doc_id =:doc_id '
                         +' union select doc_id,doc_datetime,move_flag from b2b.ht_envelope where doc_id =:doc_id ';
             params.parambyname('doc_id').AsString :=strdoc;
             open;

             dbgridenvelope.DataSource :=dsenvelope;

         end;

end;

procedure TFormEDIIN861Query.queryheader(strdoc:string);
begin
    with clientdatasetheader do
         begin
             close;
             commandtext:='select DOC_ID, ASN_DOC_ID,RECEIVED_DATE,MOVE_FLAG from b2b.RC_HEADER where doc_id =:doc_id'
                     +  ' union select DOC_ID, ASN_DOC_ID,RECEIVED_DATE,MOVE_FLAG from b2b.ht_RC_HEADER where doc_id =:doc_id' ;
             params.parambyname('doc_id').AsString :=strdoc;
             open;

             dbgridheader.DataSource :=dsheader;

         end;

end;

procedure TFormEDIIN861Query.querypallet(strdoc:string);
begin
    with clientdatasetpallet do
         begin
             close;
             commandtext:='select pallet_id,move_flag from b2b.RC_pallet where doc_id =:doc_id '
                         + 'union select pallet_id,move_flag from b2b.ht_RC_pallet where doc_id =:doc_id' ;
             params.parambyname('doc_id').AsString :=strdoc;
             open;

             dbgridpallet.DataSource :=dspallet;

             pallet_total.Caption :=inttostr(recordcount);

         end;

end;

procedure TFormEDIIN861Query.querycarton(strdoc:string);
begin
    with clientdatasetcarton do
         begin
             close;
             commandtext:='select pallet_id,carton_id,recv_condition_qty as carton_qty,move_flag from b2b.RC_carton where doc_id =:doc_id'
                         +' union select pallet_id,carton_id,recv_condition_qty as carton_qty,move_flag from b2b.ht_RC_carton where doc_id =:doc_id';
             params.parambyname('doc_id').AsString :=strdoc;
             open;

             dbgridcarton.DataSource :=dscarton;

             carton_total.Caption :=inttoStr(recordcount);

         end;

end;


procedure TFormEDIIN861Query.BTNcloseClick(Sender: TObject);
begin
   close;
end;

procedure TFormEDIIN861Query.FormShow(Sender: TObject);
begin
   editidtype.Clear ;
   editidtype.SetFocus ;

   clientdatasetenvelope.RemoteServer :=formmain.socketconnection1;
   clientdatasetenvelope.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetheader.RemoteServer :=formmain.socketconnection1;
   clientdatasetheader.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetpallet.RemoteServer :=formmain.socketconnection1;
   clientdatasetpallet.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetcarton.RemoteServer :=formmain.socketconnection1;
   clientdatasetcarton.ProviderName :=formmain.Clientdataset1.ProviderName ;

   cleardata;
end;

procedure TFormEDIIN861Query.CMBIDTYPEChange(Sender: TObject);
begin
    cleardata;

    editidtype.Clear ;
    editidtype.SetFocus ;
end;

procedure TFormEDIIN861Query.BtnQueryClick(Sender: TObject);
begin
    cleardata;
    editidtype.SetFocus ;
    if editidtype.Text<>'' then
      begin
         if cmbidtype.Text='861-OUT-DOC' then
            begin
                 queryenvelope(uppercase(trim(editidtype.text)));
                 queryheader(uppercase(trim(editidtype.text)));
                 querypallet(uppercase(trim(editidtype.text)));
                 querycarton(uppercase(trim(editidtype.text)));
            end;
          if cmbidtype.Text ='IN-856-DOC' then
             begin
                with clientdatasetheader do
                   begin
                        close;
                        commandtext:='select doc_id from B2B.rc_header where asn_doc_id=:asn_doc_id '
                                    +' union select doc_id from B2B.HT_rc_header where asn_doc_id=:asn_doc_id ';
                        params.parambyname('asn_doc_id').AsString :=trim(editidtype.Text);
                        open;

                        if recordcount>0 then
                           begin
                               cmbidtype.ItemIndex :=0;
                               editidtype.Text :=fields.fieldbyname('doc_id').asstring;
                           end
                           else
                             begin
                                 showmessage('NOT FIND THE ID NO.')  ;
                                 editidtype.SetFocus ;
                             end;
                   end;
              end;
          if cmbidtype.Text = 'Pallet' then
            begin
                with clientdatasetpallet do
                   begin
                        close;
                        commandtext:='select doc_id from B2B.rc_pallet where pallet_id=:pallet_id '
                                    +' union select doc_id from B2B.HT_rc_pallet where pallet_id=:pallet_id ';
                        params.parambyname('pallet_id').AsString :=trim(editidtype.Text);
                        open;

                        if recordcount>0 then
                           begin
                               cmbidtype.ItemIndex :=0;
                               editidtype.Text :=fields.fieldbyname('doc_id').asstring;
                           end
                           else
                             begin
                                 showmessage('NOT FIND THE ID NO.')  ;
                                 editidtype.SetFocus ;
                             end;
                   end;
            end;
          if cmbidtype.Text ='Carton' then
            begin
                with clientdatasetcarton do
                   begin
                        close;
                        commandtext:='select doc_id from B2B.rc_carton where carton_id=:carton_id '
                                    +' union select doc_id from B2B.HT_rc_carton where carton_id=:carton_id ';
                        params.parambyname('carton_id').AsString :=trim(editidtype.Text);
                        open;

                        if recordcount>0 then
                           begin
                               cmbidtype.ItemIndex :=0;
                               editidtype.Text :=fields.fieldbyname('doc_id').asstring;
                           end
                           else
                             begin
                                 showmessage('NOT FIND THE ID NO.')  ;
                                 editidtype.SetFocus ;
                             end;
                   end;
            end;
      end;

end;

end.
