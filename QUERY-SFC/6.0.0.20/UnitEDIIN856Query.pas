unit UnitEDIIN856Query;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, DBClient, ComCtrls;

type
  TFormEDIIN856Query = class(TForm)
    Label1: TLabel;
    CMBIDTYPE: TComboBox;
    Editidtype: TEdit;
    BtnQuery: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    DBGridpallet: TDBGrid;
    DBGridcarton: TDBGrid;
    Label2: TLabel;
    Label3: TLabel;
    Editmodalnumber: TEdit;
    Editcustitemnumber: TEdit;
    Label4: TLabel;
    Edititemquantity: TEdit;
    Label5: TLabel;
    Editshipmentdate: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Totalpallet: TLabel;
    Totalcarton: TLabel;
    Totalserial: TLabel;
    BTNclose: TButton;
    ClientDataSetpallet: TClientDataSet;
    DSpallet: TDataSource;
    DSCarton: TDataSource;
    DSserial: TDataSource;
    DSNULL: TDataSource;
    Label9: TLabel;
    Editshippernumber: TEdit;
    ClientDataSetcarton: TClientDataSet;
    ClientDataSetserial: TClientDataSet;
    ClientDataSetdoc: TClientDataSet;
    StringGridserial: TStringGrid;
    btnSave: TButton;
    ProgressBarserial: TProgressBar;
    SaveDialog1: TSaveDialog;
    procedure BTNcloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnQueryClick(Sender: TObject);
    procedure cleardata;
    procedure WriteLog(sTrLog:string);
    procedure querypallet(DOC_ID:STRING);
    procedure querycarton(DOC_ID:STRING);
    procedure queryserial(DOC_ID:STRING);
    procedure CMBIDTYPEChange(Sender: TObject);
    procedure DBGridpalletDblClick(Sender: TObject);
    procedure DBGridcartonDblClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEDIIN856Query: TFormEDIIN856Query;
  irow,icol:integer;

implementation

uses UnitMain;

{$R *.dfm}

procedure   TFormEDIIN856Query.querypallet(DOC_ID:STRING);
begin
   with clientdatasetpallet  do
       begin
           close;
           commandtext:='select pallet_id,quantity from b2b.asn_in_pallet where DOC_ID=:DOC_ID';
           params.ParamByName('DOC_ID').AsString:=DOC_ID;
           open;

           dbgridpallet.DataSource :=dspallet;
           totalpallet.Caption :=inttostr(recordcount);
       end;
end;

procedure   TFormEDIIN856Query.querycarton(DOC_ID:STRING);
begin
   with clientdatasetcarton  do
       begin
           close;
           commandtext:='select carton_id,quantity from b2b.asn_in_carton where DOC_ID=:DOC_ID';
           params.ParamByName('DOC_ID').AsString:=DOC_ID;
           open;

           dbgridcarton.DataSource :=dscarton;
           totalcarton.Caption :=inttostr(recordcount);
       end;
end;

procedure   TFormEDIIN856Query.queryserial(DOC_ID:STRING);
begin
   with clientdatasetserial  do
       begin
           close;
           commandtext:='select carton_id,serial_number from b2b.asn_in_serial where DOC_ID=:DOC_ID';
           params.ParamByName('DOC_ID').AsString:=DOC_ID;
           open;

           totalserial.Caption :=inttostr(recordcount);

            stringgridSERIAL.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridserial.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               next ;
             end;
       end;
end;

procedure TFormEDIIN856Query.cleardata;
begin
   editidtype.Clear ;
   editmodalnumber.Clear ;
   editcustitemnumber.Clear ;
   edititemquantity.Clear ;
   editshippernumber.Clear ;
   editshipmentdate.Clear ;

   totalpallet.Caption:='';
   totalcarton.Caption :='';
   totalserial.Caption :='';

   dbgridpallet.DataSource:=dsnull ;
   dbgridcarton.DataSource :=dsnull ;

   with stringgridserial do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=2;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=130;
           cells[0,0]:='CARTON_NO';
           colwidths[1]:=130;
           cells[1,0]:='SERIAL';
      end;

      ProgressBarserial.Position :=0;

end;

procedure TFormEDIIN856Query.BTNcloseClick(Sender: TObject);
begin
    close;
end;

procedure TFormEDIIN856Query.FormShow(Sender: TObject);
begin
   clientdatasetdoc.RemoteServer :=formmain.socketconnection1;
   clientdatasetdoc.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetpallet.RemoteServer :=formmain.socketconnection1;
   clientdatasetpallet.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetcarton.RemoteServer :=formmain.socketconnection1;
   clientdatasetcarton.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetserial.RemoteServer :=formmain.socketconnection1;
   clientdatasetserial.ProviderName :=formmain.Clientdataset1.ProviderName ;

   cleardata;
end;

procedure TFormEDIIN856Query.BtnQueryClick(Sender: TObject);
begin
    if editidtype.text='' then
      begin
          editidtype.SetFocus ;
          exit;
      end;

    if cmbidtype.Text  ='DOC' then
      begin
         with clientdatasetdoc  do
           begin
               close;
               commandtext:='select model_number,cust_item_number,item_quantity,shipper_number,shipment_date'
                          +  ' from b2b.asn_in_shipment A ,b2b.asn_in_header B WHERE   A.DOC_ID=B.DOC_ID  '
                          +  ' and A.DOC_ID=:DOC_ID';
               params.ParamByName('DOC_ID').AsString :=uppercase(trim(editidtype.Text));
               open;

               if recordcount>0 then
                  begin
                       editmodalnumber.Text :=fields[0].AsString ;
                       editcustitemnumber.Text :=fields[1].AsString ;
                       edititemquantity.Text :=fields[2].AsString ;
                       editshippernumber.Text :=fields[3].AsString ;
                       editshipmentdate.Text :=fields[4].AsString ;

                       QUERYPALLET(uppercase(trim(editidtype.Text)));
                       QUERYcarton(uppercase(trim(editidtype.Text)));
                       QUERYserial(uppercase(trim(editidtype.Text)));
                  end
                  else begin
                       showmessage('Not find the DOC!') ;
                       cleardata;
                  end;
        end;
      end;

    if cmbidtype.Text ='Pallet' then
      begin
          with clientdatasetdoc do
             begin
                 close;
                 commandtext:='select doc_id from b2b.asn_in_pallet where pallet_id=:pallet_id';
                 params.ParamByName('pallet_id').AsString :=uppercase(trim(editidtype.Text));
                 open;

                 if recordcount>0 then
                    begin
                       cmbidtype.ItemIndex:=0;
                       editidtype.Text :=fields[0].AsString ;
                    end
                    else
                       begin
                           showmessage('Not find the pallet!') ;
                           editidtype.SetFocus ;
                           cleardata;
                       end;

             end;
      end;

    if cmbidtype.Text ='Carton' then
        begin
          with clientdatasetdoc do
             begin
                 close;
                 commandtext:='select doc_id from b2b.asn_in_carton where carton_id=:carton_id';
                 params.ParamByName('carton_id').AsString :=uppercase(trim(editidtype.Text));
                 open;

                 if recordcount>0 then
                    begin
                       cmbidtype.ItemIndex:=0;
                       editidtype.Text :=fields[0].AsString ;
                    end
                    else
                       begin
                           showmessage('Not find the carton!') ;
                           editidtype.SetFocus ;
                           cleardata;
                       end;

             end;
      end;

    if cmbidtype.Text ='Shipping_Number' then
        begin
          with clientdatasetdoc do
             begin
                 close;
                 commandtext:='select doc_id from b2b.asn_in_header where shipper_number=:shipper_number';
                 params.ParamByName('shipper_number').AsString :=uppercase(trim(editidtype.Text));
                 open;

                 if recordcount>0 then
                    begin
                       cmbidtype.ItemIndex:=0;
                       editidtype.Text :=fields[0].AsString ;
                    end
                    else
                       begin
                           showmessage('Not find the Shipping_Number!') ;
                           editidtype.SetFocus ;
                           cleardata;
                       end;

             end;
      end;
end;

procedure TFormEDIIN856Query.CMBIDTYPEChange(Sender: TObject);
begin
   cleardata;
end;

procedure TFormEDIIN856Query.DBGridpalletDblClick(Sender: TObject);
var strcarton:string;
begin
    strcarton:='';
    with clientdatasetcarton  do
       begin
           close;
           commandtext:='select carton_id,quantity from b2b.asn_in_carton where pallet_id=:pallet_id order by carton_id';
           params.ParamByName('pallet_id').AsString:=dbgridpallet.Fields[0].AsString ;
           open;

           dbgridcarton.DataSource :=dscarton;
           totalcarton.Caption :=inttostr(recordcount);

           if recordcount>0 then
             begin
                 first;
                 while not eof do
                   begin
                      if strcarton='' then
                          begin
                              strcarton:='carton_id='+#39+Fields[0].AsString+#39;
                              NEXT;
                          end
                          else begin
                             strcarton:=strcarton+' OR CARTON_ID=' + #39+Fields[0].AsString+#39 ;
                             next;
                          end;
                   end;
                 strcarton:='('+strcarton+')';
                 with clientdatasetserial  do
                    begin
                        close;
                        commandtext:='select carton_id,serial_number from b2b.asn_in_serial where '+STRcarton;
                        open;

                        stringgridSERIAL.RowCount :=recordcount+1;
                        first;
                        for icol:=1 to recordcount do
                          begin
                             for irow:=1 to fieldcount do
                                 begin
                                     stringgridserial.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                                  end;
                                  next ;
                           end;


                    end;

             end;

           
       end;

end;

procedure TFormEDIIN856Query.DBGridcartonDblClick(Sender: TObject);
begin
   with clientdatasetserial  do
       begin
           close;
           commandtext:='select carton_id,serial_number from b2b.asn_in_serial where carton_id=:carton_id order by serial_number';
           params.ParamByName('carton_id').AsString:=dbgridcarton.Fields[0].AsString ;
           open;

           totalserial.Caption :=inttostr(recordcount);
           stringgridSERIAL.RowCount :=recordcount+1;
            first;
            for icol:=1 to recordcount do
              begin
                for irow:=1 to fieldcount do
                  begin
                     stringgridserial.Cells[irow-1,icol]:=fields[irow-1].AsString ;
                  end;
               next ;
             end;

       end;
end;

procedure TFormEDIIN856Query.WriteLog(sTrLog:string);
var vFile: Textfile;
var sBackupFile,sDir:string;
begin
 // sBackupFile := 'C:\'+FormatDateTime('YYYYMMDD',now())+EDITIDTYPE.TEXT+'.log';


 // savedialog1.Execute ;
  sbackupfile:=savedialog1.FileName ;
  AssignFile(vFile, sBackupFile);
  if FileExists(sBackupFile) then
    Append(vFile)
  else
    Rewrite(vFile);
  WriteLn(vFile, sTrlog);
  CloseFile(vFile);

end;

procedure TFormEDIIN856Query.btnSaveClick(Sender: TObject);
begin
 if trim(stringgridserial.Cells[0,1]) <> '' then
   begin
    if savedialog1.Execute then
      begin
           btnsave.Enabled :=false;
           ProgressBarserial.Position :=0;
           progressbarserial.Max:=stringgridserial.RowCount ;
           for icol:=0 to strtoint(totalserial.Caption )do
               begin
                     writelog(stringgridserial.Cells[1,icol]);
                     progressbarserial.Position :=icol ;
               end;
          showmessage('Save ok!');
          btnsave.Enabled :=true;
          ProgressBarserial.Position :=0;
      end;
   end;
end;

end.
