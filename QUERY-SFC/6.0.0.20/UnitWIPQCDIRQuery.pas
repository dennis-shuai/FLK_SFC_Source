unit UnitWIPQCDIRQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ComCtrls, Grids, StdCtrls, Buttons;

type
  TFormWIPQCDIRquery = class(TForm)
    Label1: TLabel;
    Label7: TLabel;
    lblrecordcount: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    btnclose: TButton;
    btnquery: TButton;
    DateTimePickerSTART: TDateTimePicker;
    DateTimePickerEND: TDateTimePicker;
    cmbBoxHSTART: TComboBox;
    cmbBoxHend: TComboBox;
    StringGridQC: TStringGrid;
    Progressfeeder: TProgressBar;
    Btnsave: TButton;
    ClientDatasetqc: TClientDataSet;
    SaveDialog1: TSaveDialog;
    ClientDataSet1: TClientDataSet;
    Memomodel: TMemo;
    Memoline: TMemo;
    btnmodel: TBitBtn;
    btnline: TBitBtn;
    GroupBoxmodel: TGroupBox;
    ListBoxmodelleft: TListBox;
    ListBoxmodelright: TListBox;
    btnmodeltoright: TBitBtn;
    btnmodeltorightall: TBitBtn;
    btnmodeltoleft: TBitBtn;
    btnmodeltoleftall: TBitBtn;
    btnmodelok: TButton;
    btnmodelcancel: TButton;
    GroupBoxline: TGroupBox;
    ListBoxlineleft: TListBox;
    ListBoxlineright: TListBox;
    btnlinetoright: TBitBtn;
    btnlinetorightall: TBitBtn;
    btnlinetoleft: TBitBtn;
    btnlinetoleftall: TBitBtn;
    btnlineok: TButton;
    btnlinecancel: TButton;
    Cmbboxmstart: TComboBox;
    cmbboxmend: TComboBox;
    procedure  cleardata;
    procedure getdata;
    procedure WriteLog(sTrLog:string);
    procedure queryqc(strtstart,strtend,strmodel,strline:string);
    procedure btncloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnmodelClick(Sender: TObject);
    procedure btnmodelcancelClick(Sender: TObject);
    procedure btnmodeltorightClick(Sender: TObject);
    procedure btnmodeltorightallClick(Sender: TObject);
    procedure btnmodeltoleftallClick(Sender: TObject);
    procedure btnmodeltoleftClick(Sender: TObject);
    procedure btnmodelokClick(Sender: TObject);
    procedure btnlineokClick(Sender: TObject);
    procedure btnlineClick(Sender: TObject);
    procedure btnlinecancelClick(Sender: TObject);
    procedure btnlinetorightClick(Sender: TObject);
    procedure btnlinetorightallClick(Sender: TObject);
    procedure btnlinetoleftClick(Sender: TObject);
    procedure btnlinetoleftallClick(Sender: TObject);
    procedure btnqueryClick(Sender: TObject);
    procedure BtnsaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWIPQCDIRquery: TFormWIPQCDIRquery;
  icol,irow:integer;
  strmodel,strline:string;
  strtstart,strtend:string;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormWIPQCDIRquery.WriteLog(sTrLog:string);
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

procedure TFormWIPQCDIRquery.getdata;
begin
   strTstart:='';
   strtend:=''  ;
   strTstart:=FormatDateTime('YYYYMMDD',datetimepickerstart.Date)+cmbboxhstart.Text+cmbboxmstart.Text ;
   strtend:=FormatDateTime('YYYYMMDD',datetimepickerEND.Date)+cmbboxhend.Text+cmbboxmend.Text ;
end;

procedure TFormWIPQCDIRquery.cleardata;
begin
     lblrecordcount.Caption :='';
     memomodel.Clear ;
     memoline.Clear ;
     if groupboxmodel.Visible =true then
         groupboxmodel.Visible :=false;
     if groupboxline.Visible =true then
         groupboxline.Visible :=false;
     listboxmodelleft.Sorted :=true;
     listboxmodelright.Sorted :=true;
     listboxlineleft.Sorted :=true;
     listboxlineright.Sorted :=true;
     with stringgridqc do
       begin
           FixedCols:=0;
           FixedRows :=1;
           RowCount  :=10;
           ColCount  :=10;
           for icol:=0 to colcount-1 do
               for irow:=0 to rowcount-1 do
                  Cells[icol,irow]:='';
           ColWidths[0]:=25;
           cells[0,0]:='NO.';
           colwidths[1]:=70;
           cells[1,0]:='Line no';
           colwidths[2]:=130;
           CELLS[2,0]:='Inspection No.';
           colwidths[3]:=80;
           CELLS[3,0]:='MODEL NAME';
           colwidths[4]:=50;
           CELLS[4,0]:='Quantity';
           colwidths[5]:=50;
           CELLS[5,0]:='samples';
           colwidths[5]:=50;
           CELLS[6,0]:='Insp';
           colwidths[7]:=80;
           CELLS[7,0]:='Judge';
           colwidths[8]:=100;
           CELLS[8,0]:='Defect desciption';
           colwidths[9]:=80;
           CELLS[9,0]:='Remark';
      end;
end;

procedure TFormWIPQCDIRquery.queryqc(strtstart,strtend,strmodel,strline:string);
begin
     with ClientDatasetqc do
        begin
            close;
            commandtext:='select B.pdline_NAME, a.qc_lotno, E.MODEL_NAME, a.work_order,a.lot_size,  '
                    +' a.sampling_size,D.EMP_NAME,qc_result,a.lot_memo    '
                    +' from sajet.g_qc_lot A,sajet.SYS_PDLINE B,sajet.SYS_PART C,sajet.SYS_EMP D,sajet.SYS_MODEL E   '
                    +' WHERE  TO_CHAR(a.START_TIME,''YYYYMMDDHH24MI'') BETWEEN :start_time AND :end_time and e.model_name in ( +' + STRMODEL + ' )  '
                    +'  and b.pdline_name in ( '  +STRLINE + ') '
                    +' and A.PDLINE_ID=B.PDLINE_ID AND A.MODEL_ID=C.PART_ID AND C.MODEL_ID=E.MODEL_ID AND A.insp_empid=D.EMP_ID   ' ;
            params.ParamByName('start_time').AsString :=strtstart;
            params.ParamByName('end_time').AsString :=strtend;

            OPEN;
            FIRST;
            if fieldbyname('pdline_NAME').asstring='' then
               begin
                 cleardata  ;
                 exit;
               end;
            stringgridqc.RowCount:=10;
            irow:=0;
            icol:=0;
            WHILE NOT EOF DO
              BEGIN
                  IROW:=IROW+1;
                  stringgridqc.Cells[0,irow]:=inttostr(irow);
                  stringgridqc.Cells[1,irow]:=fieldbyname('pdline_NAME').AsString   ;
                  stringgridqc.Cells[2,irow]:=fieldbyname('qc_lotno').AsString   ;
                  stringgridqc.Cells[3,irow]:=fieldbyname('MODEL_NAME').AsString ;
                  stringgridqc.Cells[4,irow]:=fieldbyname('lot_size').AsString ;
                  stringgridqc.Cells[5,irow]:= fieldbyname('sampling_size').AsString;
                  stringgridqc.Cells[6,irow]:= fieldbyname('EMP_NAME').AsString ;
                  //stringgridqc.Cells[7,irow]:= fieldbyname('qc_result').AsString;
                  if  fieldbyname('qc_result').AsString='N/A' THEN
                       stringgridqc.Cells[7,irow]:='I(ÀËÅç¤¤)';
                  if  fieldbyname('qc_result').AsString='0' THEN
                       stringgridqc.Cells[7,irow]:='A(Acceptance)';
                  if  fieldbyname('qc_result').AsString='1' THEN
                       stringgridqc.Cells[7,irow]:='R(Rej)';
                  if  fieldbyname('qc_result').AsString='2' THEN
                       stringgridqc.Cells[7,irow]:='W(Waive)';
                  if  fieldbyname('qc_result').AsString='4' THEN
                       stringgridqc.Cells[7,irow]:='S(Select)';
                  stringgridqc.Cells[8,irow]:=fieldbyname('lot_memo').AsString ;
                  stringgridqc.Cells[9,irow]:= fieldbyname('work_order').AsString ;
                  next;
                  stringgridqc.RowCount:=IROW+1;
                  lblrecordcount.Caption :=inttostr(irow);
            END; 

        END;
end;

procedure TFormWIPQCDIRquery.btncloseClick(Sender: TObject);
begin
    CLOSE;
end;

procedure TFormWIPQCDIRquery.FormShow(Sender: TObject);
begin
    ClientDataset1.RemoteServer :=formmain.socketconnection1;
    ClientDataset1.ProviderName :=formmain.Clientdataset1.ProviderName ;

    ClientDatasetqc.RemoteServer :=formmain.socketconnection1;
    ClientDatasetqc.ProviderName :=formmain.Clientdataset1.ProviderName ;

    datetimepickerstart.Date:=now;
    datetimepickerend.Date :=now;
    cmbboxhstart.ItemIndex:=0;
    cmbboxhend.ItemIndex:=23;
    cmbboxmstart.ItemIndex :=0;
    cmbboxmend.ItemIndex :=0;

    cleardata;
end;

procedure TFormWIPQCDIRquery.btnmodelClick(Sender: TObject);
begin
     if groupboxmodel.Visible =false then
         groupboxmodel.Visible :=true;
     listboxmodelleft.Clear ;
     listboxmodelright.Clear ;
     with clientdataset1 do
       begin
           close;
           commandtext:='select MODEL_NAME from SAJET.sys_model where enabled=''Y'' ORDER BY MODEL_name';
           open;
           first;
           listboxmodelleft.Clear ;
           while not eof do
             begin
                listboxmodelleft.Items.Add(fieldbyname('model_name').AsString);
                next;
             end;
           listboxmodelleft.ItemIndex :=0;
       end;   
end;

procedure TFormWIPQCDIRquery.btnmodelcancelClick(Sender: TObject);
begin
    if groupboxmodel.Visible =true then
        groupboxmodel.Visible :=false;
end;

procedure TFormWIPQCDIRquery.btnmodeltorightClick(Sender: TObject);
begin
   if listboxmodelleft.ItemIndex =-1 then
      begin
       listboxmodelleft.ItemIndex :=0;
      end;
   listboxmodelright.Items.Add(listboxmodelleft.Items[listboxmodelleft.ItemIndex]);
   listboxmodelleft.Items.Delete(listboxmodelleft.ItemIndex );

end;

procedure TFormWIPQCDIRquery.btnmodeltorightallClick(Sender: TObject);
var i: integer;
begin
    for i:=0 to listboxmodelleft.Count-1 do
      begin
         listboxmodelleft.ItemIndex :=0;
         listboxmodelright.Items.Add(listboxmodelleft.Items[listboxmodelleft.ItemIndex]);
         listboxmodelleft.Items.Delete(listboxmodelleft.ItemIndex );
      end
end;

procedure TFormWIPQCDIRquery.btnmodeltoleftallClick(Sender: TObject);
var i: integer;
begin
    for i:=0 to listboxmodelright.Count-1 do
      begin
         listboxmodelright.ItemIndex :=0;
         listboxmodelleft.Items.Add(listboxmodelright.Items[listboxmodelright.ItemIndex]);
         listboxmodelright.Items.Delete(listboxmodelright.ItemIndex );
      end

end;

procedure TFormWIPQCDIRquery.btnmodeltoleftClick(Sender: TObject);
begin
     if listboxmodelright.ItemIndex =-1 then
      begin
       listboxmodelright.ItemIndex :=0;
      end;
   listboxmodelleft.Items.Add(listboxmodelright.Items[listboxmodelright.ItemIndex]);
   listboxmodelright.Items.Delete(listboxmodelright.ItemIndex );
end;

procedure TFormWIPQCDIRquery.btnmodelokClick(Sender: TObject);
var i: integer;
begin
    memomodel.Clear ;
    strmodel:='';
    for i:=0 to listboxmodelright.Count-1 do
      begin
          if strmodel='' then
                strmodel:=chr(39)+listboxmodelright.Items[i]+chr(39)
          else
                strmodel:=strmodel+','+chr(39) +listboxmodelright.Items[i]+chr(39);
      end;
     memomodel.Text :=strmodel;
     if groupboxmodel.Visible =true then
        groupboxmodel.Visible :=false ;
end;

procedure TFormWIPQCDIRquery.btnlineokClick(Sender: TObject);
var i: integer;
begin
    memoline.Clear ;
    strline:='';
    for i:=0 to listboxlineright.Count-1 do
      begin
          if strline='' then
             strline:= chr(39)+listboxlineright.Items[i]+ chr(39)
          else
             strline:=strline+','+chr(39)+listboxlineright.Items[i]+chr(39);
      end;
     memoline.Text :=strline;
     if groupboxline.Visible =true then
        groupboxline.Visible :=false ;

end;

procedure TFormWIPQCDIRquery.btnlineClick(Sender: TObject);
begin
    if groupboxline.Visible =false then
         groupboxline.Visible :=true;
     listboxlineleft.Clear ;
     listboxlineright.Clear ;
     with clientdataset1 do
       begin
           close;
           commandtext:='select pdline_NAME from SAJET.sys_pdline where enabled=''Y'' ORDER BY pdline_name';
           open;
           first;
           listboxlineleft.Clear ;
           while not eof do
             begin
                listboxlineleft.Items.Add(fieldbyname('pdline_name').AsString);
                next;
             end;
           listboxlineleft.ItemIndex :=0;
       end;
end;

procedure TFormWIPQCDIRquery.btnlinecancelClick(Sender: TObject);
begin
    if groupboxline.Visible=true then
       groupboxline.Visible :=false;
end;

procedure TFormWIPQCDIRquery.btnlinetorightClick(Sender: TObject);
begin
    if listboxlineleft.ItemIndex =-1 then
      begin
       listboxlineleft.ItemIndex :=0;
      end;
   listboxlineright.Items.Add(listboxlineleft.Items[listboxlineleft.ItemIndex]);
   listboxlineleft.Items.Delete(listboxlineleft.ItemIndex );
end;

procedure TFormWIPQCDIRquery.btnlinetorightallClick(Sender: TObject);
var i: integer;
begin
    for i:=0 to listboxlineleft.Count-1 do
      begin
         listboxlineleft.ItemIndex :=0;
         listboxlineright.Items.Add(listboxlineleft.Items[listboxlineleft.ItemIndex]);
         listboxlineleft.Items.Delete(listboxlineleft.ItemIndex );
      end

end;

procedure TFormWIPQCDIRquery.btnlinetoleftClick(Sender: TObject);
begin
    if listboxlineright.ItemIndex =-1 then
      begin
       listboxlineright.ItemIndex :=0;
      end;
   listboxlineleft.Items.Add(listboxlineright.Items[listboxlineright.ItemIndex]);
   listboxlineright.Items.Delete(listboxlineright.ItemIndex );
end;

procedure TFormWIPQCDIRquery.btnlinetoleftallClick(Sender: TObject);
var i: integer;
begin
    for i:=0 to listboxlineright.Count-1 do
      begin
         listboxlineright.ItemIndex :=0;
         listboxlineleft.Items.Add(listboxlineright.Items[listboxlineright.ItemIndex]);
         listboxlineright.Items.Delete(listboxlineright.ItemIndex );
      end

end;

procedure TFormWIPQCDIRquery.btnqueryClick(Sender: TObject);
begin
    GETDATA;
    queryqc(strtstart,strtend,strmodel,strline);
end;

procedure TFormWIPQCDIRquery.BtnsaveClick(Sender: TObject);
var strfieldsvalue: string;
begin
 if length(stringgridqc.Cells[0,1]) >0 then
   begin
    if savedialog1.Execute then
      begin
           btnsave.Enabled :=false;
           Progressfeeder.Position :=0;
           Progressfeeder.Max:=stringgridqc.RowCount ;
           for icol:=0 to strtoint(lblrecordcount.Caption )do
               begin
                  strfieldsvalue:='';
                  for irow:=0 to stringgridqc.ColCount do
                     begin
                         if  strfieldsvalue='' then
                              strfieldsvalue:=stringgridqc.Cells[irow,icol]
                          else
                              strfieldsvalue:=strfieldsvalue+';'+ stringgridqc.Cells[irow,icol] ;
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
