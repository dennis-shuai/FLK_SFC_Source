unit UnitQUERYWOBOMERPTOSFC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, StdCtrls, Grids, DBGrids;

type
  TFormQUERYWOBOMERPTOSFC = class(TForm)
    Label1: TLabel;
    LABEL4: TLabel;
    Butquery: TButton;
    ButCLOSE: TButton;
    Editrecordcount: TEdit;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    ClientDataSetWO: TClientDataSet;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    EditWO: TEdit;
    Label3: TLabel;
    Editstatus: TEdit;
    Label5: TLabel;
    Edittoerp: TEdit;
    Label6: TLabel;
    Editinputqty: TEdit;
    Label7: TLabel;
    Editoutputqty: TEdit;
    lblscrap_qty: TLabel;
    Editscrapqty: TEdit;
    Label9: TLabel;
    Edittargetqty: TEdit;
    DBGrid1: TDBGrid;
    procedure ButCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButqueryClick(Sender: TObject);
    procedure lblscrap_qtyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormQUERYWOBOMERPTOSFC: TFormQUERYWOBOMERPTOSFC;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormQUERYWOBOMERPTOSFC.ButCLOSEClick(Sender: TObject);
begin
   CLOSE;
end;

procedure TFormQUERYWOBOMERPTOSFC.FormShow(Sender: TObject);
begin
   clientdataset1.RemoteServer :=formmain.socketconnection1;
   clientdataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetWO.RemoteServer :=formmain.socketconnection1;
   clientdatasetWO.ProviderName :=formmain.Clientdataset1.ProviderName ;


   editwo.Clear ;
   editwo.SetFocus ;
   editstatus.Clear ;
   edittargetqty.Clear ;
   editinputqty.Clear ;
   editoutputqty.Clear ;
   editscrapqty.Clear ;
   edittoerp.Clear;
   editrecordcount.Clear ;

end;

procedure TFormQUERYWOBOMERPTOSFC.ButqueryClick(Sender: TObject);
begin
     with clientdatasetwo  do
        begin
            close;
            commandtext:='select work_order, target_qty,wo_status,input_qty,output_qty,scrap_qty,erp_qty from sajet.g_wo_base where work_order=:work_order' ;
            params.ParamByName('work_order').AsString :=trim(editwo.Text);
            open;


            if recordcount<>0 then
               begin
                   // editstatus.Text :=fieldbyname('wo_status').asstring  ;
                    case   fieldbyname('wo_status').AsInteger of
                       0: editstatus.Text :='INTITLE';
                       1: EDITSTATUS.Text:='PREPARE';
                       2: EDITSTATUS.Text :='RELEASED';
                       3: EDITSTATUS.Text :='WIP';
                       4: EDITSTATUS.Text:='HOLD';
                       5: EDITSTATUS.Text :='CANCEL';
                       6: EDITSTATUS.Text :='COMPLETE';
                       9: EDITSTATUS.Text :='COMPLETE-NO CHARGE';
                      ELSE
                       editstatus.Text :=fieldbyname('wo_status').asstring  ;
                    END;

                    edittargetqty.Text :=fieldbyname('target_qty').AsString ;
                    editinputqty.Text :=fieldbyname('input_qty').AsString ;
                    editoutputqty.Text :=fieldbyname('output_qty').AsString ;
                    editscrapqty.Text :=fieldbyname('scrap_qty').AsString ;
                    edittoerp.Text :=fieldbyname('erp_qty').AsString ;
                    close;
                    
               end
               else begin
                        showmessage('THE WO NOT FIND!');
                        editwo.SetFocus   ;
                        editstatus.Clear ;
                        edittargetqty.Clear ;
                        editinputqty.Clear ;
                        editoutputqty.Clear ;
                        editscrapqty.Clear ;
                        edittoerp.Clear;
                        editrecordcount.Clear ;
                   end;

                WITH clientdataset1 do
                      begin
                         close;
                         commandtext:='select B.PART_NO,A.REQUEST_QTY AS REQUEST,A.ISSUE_QTY AS ISSUE,A.AB_ISSUE_QTY AS AB_IN, A.AB_RETURN_QTY AS AB_OUT '
                                 + 'from sajet.g_wo_pick_list A ,sajet.SYS_PART B where  a.work_order=:work_order AND A.PART_ID=B.PART_ID order by b.part_no' ;
                         params.ParamByName('work_order').AsString :=trim(editwo.Text ) ;
                         open;

                         EDITRECORDCOUNT.Text :=INTTOSTR(RECORDCOUNT);
                      end;


             end;

end;

procedure TFormQUERYWOBOMERPTOSFC.lblscrap_qtyClick(Sender: TObject);
begin
  { with clientdatasetwo  do
        begin
            close;
            commandtext:='select work_order, target_qty,wo_status,input_qty,output_qty,scrap_qty,erp_qty from sajet.g_wo_base where work_order=:work_order' ;
            params.ParamByName('work_order').AsString :=trim(editwo.Text);
            open;


            if recordcount<>0 then
               begin
                   // editstatus.Text :=fieldbyname('wo_status').asstring  ;
                    case   fieldbyname('wo_status').AsInteger of
                       0: editstatus.Text :='INTITLE';
                       1: EDITSTATUS.Text:='PREPARE';
                       2: EDITSTATUS.Text :='RELEASED';
                       3: EDITSTATUS.Text :='WIP';
                       4: EDITSTATUS.Text:='HOLD';
                       5: EDITSTATUS.Text :='CANCEL';
                       6: EDITSTATUS.Text :='COMPLETE';
                       9: EDITSTATUS.Text :='COMPLETE-NO CHARGE';
                      ELSE
                       editstatus.Text :=fieldbyname('wo_status').asstring  ;
                    END;

                    edittargetqty.Text :=fieldbyname('target_qty').AsString ;
                    editinputqty.Text :=fieldbyname('input_qty').AsString ;
                    editoutputqty.Text :=fieldbyname('output_qty').AsString ;
                    editscrapqty.Text :=fieldbyname('scrap_qty').AsString ;
                    edittoerp.Text :=fieldbyname('erp_qty').AsString ;
                    close;
                    
               end
               else begin
                        showmessage('THE WO NOT FIND!');
                        editwo.SetFocus   ;
                        editstatus.Clear ;
                        edittargetqty.Clear ;
                        editinputqty.Clear ;
                        editoutputqty.Clear ;
                        editscrapqty.Clear ;
                        edittoerp.Clear;
                        editrecordcount.Clear ;
                   end;
             WITH clientdataset1 do
                begin
                close;
                commandtext:='select serial_number from sajet.g_sn_status where work_order=:work_order and work_flag=1';
                params.ParamByName('work_order').AsString :=trim(editwo.Text ) ;
                open;

                EDITRECORDCOUNT.Text :=INTTOSTR(RECORDCOUNT);
            end;
    end;
    }
end;

end.
