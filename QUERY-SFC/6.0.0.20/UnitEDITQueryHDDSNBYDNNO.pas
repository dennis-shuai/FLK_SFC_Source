unit UnitEDITQueryHDDSNBYDNNO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, ComCtrls, Grids;

type
  TFormEdiqueryhddsnbyDNNO = class(TForm)
    Label2: TLabel;
    ClientDataSetOUT856: TClientDataSet;
    GroupBox1: TGroupBox;
    btnCLOSE: TButton;
    Editdnno: TEdit;
    BtnQuery: TButton;
    Label1: TLabel;
    StringGridedi: TStringGrid;
    Label7: TLabel;
    lblrecordcount: TLabel;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    SaveDialog1: TSaveDialog;
    procedure cleardata;
    PROCEDURE queryedi;
    procedure WriteLog(sTrLog:string);
    procedure btnCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnQueryClick(Sender: TObject);
    procedure BtnsaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEdiqueryhddsnbyDNNO: TFormEdiqueryhddsnbyDNNO;
  icol,irow: integer;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormEdiqueryhddsnbyDNNO.WriteLog(sTrLog:string);
var vFile: Textfile;
var sBackupFile,sDir:string;
begin
  sbackupfile:=savedialog1.FileName ;
  AssignFile(vFile, sBackupFile);
  if FileExists(sBackupFile) then
    Append(vFile)
  else
    Rewrite(vFile);
  WriteLn(vFile, sTrlog);
  CloseFile(vFile);

end;

procedure TFormEdiqueryhddsnbyDNNO.cleardata;
begin
     lblrecordcount.Caption :='';
     editdnno.Clear;
     editdnno.SetFocus ;
     with stringgridedi do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=3;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=120;
           cells[0,0]:='Work_Order';
           colwidths[1]:=120;
           cells[1,0]:='PCBA SN';
           colwidths[2]:=120;
           CELLS[2,0]:='HDD SN';
      end;
end;

procedure TFormEdiqueryhddsnbyDNNO.queryedi;
begin
     with ClientDatasetout856 do
        begin
            close;
            commandtext:=' select doc_id from b2b.asn_out_header where shipper_number=:dn_no  '
                        +' union  '
                        +' select doc_id from b2b.ht_asn_out_header where shipper_number=:dn_no  ';
            params.ParamByName('dn_no').AsString :=trim(editdnno.Text );

            OPEN;
            if fieldbyname('doc_id').asstring='' then
               begin
                 cleardata  ;
                 exit;
               end;

            close;
            commandtext:=' select work_order_number AS work_order,serial_number AS PCBA_SN,drive_serial_number as HDD_SN  '
                        +' from b2b.ht_pt_reference where doc_id in   '
                        +' (select doc_id from b2b.ht_pt_header where inventory_batch_id in   '
                        +' (select pallet_id from b2b.ht_asn_out_pallet where doc_id in  '
                        +' (select doc_id from b2b.ht_asn_out_header where shipper_number=:dn_no))) '
                        +' union   '
                        +' select work_order_number AS WO,serial_number AS PCBA_SN,drive_serial_number as HDD_SN   '
                        +' from b2b.pt_reference where doc_id in  '
                        +' (select doc_id from b2b.pt_header where inventory_batch_id in    '
                        +' (select pallet_id from b2b.asn_out_pallet where doc_id in  '
                        +' (select doc_id from b2b.asn_out_header where shipper_number=:dn_no))) ';
            params.ParamByName('dn_no').AsString :=trim(editdnno.Text );

            OPEN;
            FIRST;
            if fieldbyname('work_order').asstring='' then
               begin
                 cleardata  ;
                 exit;
               end;
            stringgridedi.RowCount:=10;
            irow:=0;
            icol:=0;
            WHILE NOT EOF DO
              BEGIN
                  IROW:=IROW+1;
                  stringgridedi.Cells[0,irow]:=fieldbyname('work_order').AsString;
                  stringgridedi.Cells[1,irow]:=fieldbyname('PCBA_SN').AsString   ;
                  stringgridedi.Cells[2,irow]:=fieldbyname('HDD_SN').AsString   ;
                  next;
                  stringgridedi.RowCount:=IROW+1;
                  lblrecordcount.Caption :=inttostr(irow);
            END; 

        END;
end;

procedure TFormEdiqueryhddsnbyDNNO.btnCLOSEClick(Sender: TObject);
begin
   close;
end;

procedure TFormEdiqueryhddsnbyDNNO.FormShow(Sender: TObject);
begin
    ClientDatasetout856.RemoteServer :=formmain.socketconnection1;
    ClientDatasetout856.ProviderName :=formmain.Clientdataset1.ProviderName ;
    CLEARDATA;
end;

procedure TFormEdiqueryhddsnbyDNNO.BtnQueryClick(Sender: TObject);
begin
    if trim(editdnno.text)<>'' then
        queryedi;
end;

procedure TFormEdiqueryhddsnbyDNNO.BtnsaveClick(Sender: TObject);
var strfieldsvalue: string;
begin
 if length(stringgridedi.Cells[0,1]) >0 then
   begin
    if savedialog1.Execute then
      begin
           btnsave.Enabled :=false;
           Progressfeeder.Position :=0;
           Progressfeeder.Max:=stringgridedi.RowCount ;
           for icol:=0 to strtoint(lblrecordcount.Caption )do
               begin
                  strfieldsvalue:='';
                  for irow:=0 to stringgridedi.ColCount do
                     begin
                         if  strfieldsvalue='' then
                              strfieldsvalue:=stringgridedi.Cells[irow,icol]
                          else
                              strfieldsvalue:=strfieldsvalue+';'+ stringgridedi.Cells[irow,icol] ;
                     end;
                     writelog(strfieldsvalue);
                     Progressfeeder.Position :=icol ;
               end;
          showmessage('Save ok!');
          btnsave.Enabled :=true;
          Progressfeeder.Position :=0;
      end;
   end;


end;

end.
