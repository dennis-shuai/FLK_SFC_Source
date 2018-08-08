unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    edtDefectQty: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtDefectCode: TEdit;
    Label6: TLabel;
    lblQty: TLabel;
    cmbLotNo: TComboBox;
    sbtnPrint: TSpeedButton;
    ImageReject: TImage;
    Label8: TLabel;
    StringGrid1: TStringGrid;
    lblTerminal: TLabel;
    Label7: TLabel;
    lblDefectQty: TLabel;
    edtWO: TEdit;
    Label5: TLabel;
    lblWOQty: TLabel;
    Image1: TImage;
    sbtnAdd: TSpeedButton;
    lblDefectDesc: TLabel;
    procedure FormShow(Sender: TObject);
    procedure edtWOKeyPress(Sender: TObject; var Key: Char);
    procedure edtTestQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtDefectCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtDefectQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cmbLotNoChange(Sender: TObject);
    procedure cmbLotNoKeyPress(Sender: TObject; var Key: Char);
    procedure edtDefectQtyChange(Sender: TObject);
    procedure sbtnAddClick(Sender: TObject);
    procedure sbtnPrintClick(Sender: TObject);
    procedure Label3DblClick(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO:string;
    IsError :Boolean;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID : String;
    Count,AllDefectQty,IRows:Integer;
  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}
uses uDllform,DllInit;


procedure TForm1.FormShow(Sender: TObject);
var iniFile:TIniFile;
begin
    iniFile :=TIniFile.Create('SAJET.ini');
    G_sTerminalID :=iniFile.ReadString('COB','Terminal','N/A' );
    iniFile.Free;
    QryTemp.Close;
    QryTemp.Params.Clear;
    QryTemp.Params.CreateParam(ftString,'Terminal_ID',ptInput);
    QryTemp.CommandText := 'select  b.PDLINE_NAME||''\''||a.Terminal_Name as Terminal ,a.Process_ID,b.PDLINE_ID ,a.Stage_ID from '+
                           ' SAJET.SYS_TERMINAL a,SAJET.SYS_PDLINE b where A.PDLINE_ID =B.PDLINE_ID' +
                           '  and Terminal_ID=  :Terminal_ID and a.Enabled=''Y'' ';
    QryTemp.Params.ParamByName('Terminal_ID').AsString := G_sTerminalID;
    QryTemp.Open;

    lblTerminal.Caption := 'Terminal: '+QryTemp.fieldByName('Terminal').AsString ;
    G_sProcessID := QryTemp.fieldByName('Process_ID').AsString ;
    G_sPDLineID := QryTemp.fieldByName('Process_ID').AsString ;
    G_sStageID := QryTemp.fieldByName('Stage_ID').AsString ;
    edtWO.SetFocus;
    StringGrid1.Cells[0,0] :='虫';
    StringGrid1.Cells[1,0] :='у腹';
    StringGrid1.Cells[2,0] :='ぃ▆絏';
    StringGrid1.Cells[3,0] :='ぃ▆磞瓃';
    StringGrid1.Cells[4,0] :='ぃ▆计秖';
    stringGrid1.ColWidths[0] := 100;
    stringGrid1.ColWidths[1] := 150;
    stringGrid1.ColWidths[2] := 100;
    stringGrid1.ColWidths[3] := 200;
    stringGrid1.ColWidths[4] := 100;

end;


procedure TForm1.edtWOKeyPress(Sender: TObject; var Key: Char);
var iResult:string;
begin
   if Key <> #13 Then exit;

   Sproc.Close;
   Sproc.DataRequest('SAJET.SJ_CHK_WO_INPUT');
   Sproc.FetchParams;
   Sproc.Params.ParamByName('TREV').AsString :=edtWO.Text;
   Sproc.Execute;
   iResult := Sproc.Params.parambyname('TRES').asstring ;

   if  iResult<> 'OK' then begin
       MessageDlg(iResult,mterror,[mbok],0);
       edtWO.SelectAll;
       edtWO.SetFocus;
       cmbLotNo.Enabled :=false;
       exit;
   end;
   cmbLotNo.Enabled :=true;
   cmbLotNo.Text :='';
   cmbLotNo.SetFocus;
   edtWO.Enabled :=false;
   with QryTemp do begin
     close;
     Params.Clear;
     params.CreateParam(ftstring,'WO',ptInput);
     CommandText :='select * from sajet.g_pack_carton where Work_order =:wo and Close_Flag=''Y'' and Carton_NO like ''COB%'' ';
     Params.ParamByName('WO').AsString :=edtWO.Text;
     Open;
     first;
     cmbLotNo.Items.Clear;
     while not eof do begin
         cmbLotNo.Items.Add(FieldByName('Carton_NO').AsString) ;
         next;
     end;
   end;

   with QryTemp do begin
         close;
         Params.Clear;
         params.CreateParam(ftstring,'WO',ptInput);
         CommandText :='select * from sajet.G_WO_BASE where Work_order =:wo   ';
         Params.ParamByName('WO').AsString :=edtWO.Text;
         Open;
         lblWOQty.Caption :=  FieldByName('Target_Qty').AsString;
   end;

   IRows :=1;

end;

procedure TForm1.edtTestQtyKeyPress(Sender: TObject; var Key: Char);
begin

   if Key =#13 then begin
       edtDefectCode.Enabled :=true;
       edtDefectCode.SetFocus;
       edtDefectCode.Text :='';
   end;
   

end;

procedure TForm1.edtDefectCodeKeyPress(Sender: TObject; var Key: Char);
begin
   if key <>#13 then exit;

    with Qrytemp do begin
       close;
       params.Clear;
       params.CreateParam(ftstring,'ERROR_CODE',ptInput);
       commandText :='select * from sajet.sys_defect where defect_code =:error_code';
       params.ParamByName('ERROR_CODE').AsString :=edtDefectCode.Text;
       open;
       if isempty then begin
           MessageDlg('ERROR Defect Code',mterror,[mbOK],0);
           edtDefectCode.SetFocus;
           edtDefectCode.SelectAll;
           exit;
       end;
       lblDefectDesc.Caption := fieldByname('Defect_Desc').AsString;
       edtDefectQty.Enabled :=true;
       edtDefectQty.Text :='';
       edtDefectQty.SetFocus;
    end;
end;

procedure TForm1.edtDefectQtyKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <>#13 then exit;
   IsError:=false;
   sbtnAdd.Click;

   if IsError then begin
       edtDefectQty.Text :='';
       edtDefectQty.SetFocus;
       exit;
   end;

   AllDefectQty := AllDefectQty+ StrToIntDef(edtDefectQty.Text,0);
   StringGrid1.RowCount := IRows+1;
   StringGrid1.Cells[0,iRows] :=edtWo.Text;
   StringGrid1.Cells[1,iRows] :=cmbLotNo.Text;
   StringGrid1.Cells[2,iRows] :=edtDefectCode.Text;
   StringGrid1.Cells[3,iRows] :=lblDefectDesc.Caption;
   StringGrid1.Cells[4,iRows] :=edtDefectQty.Text;
   inc(IRows);

   edtDefectCode.Enabled :=false;
   edtDefectQty.Enabled :=false;
   cmbLotNo.Text :='';
   edtDefectCode.Text :='';
   edtDefectQty.Text :='';
   cmbLotNo.SetFocus;

end;

procedure TForm1.cmbLotNoChange(Sender: TObject);
var Key:char;
begin
   Key :=#13;
   AllDefectQty:=0;
   cmbLotNo.OnKeyPress(sender,key);

end;

procedure TForm1.cmbLotNoKeyPress(Sender: TObject; var Key: Char);
begin

    with qrytemp do begin
       close;
       params.Clear;
       params.CreateParam(ftstring,'WO',ptInput);
       params.CreateParam(ftstring,'carton',ptInput);
       commandtext := 'select Count(*) LOTQTY from sajet.g_sn_status where  WOrk_order=:wo and carton_NO =:carton';
       params.ParamByName('wo').AsString := edtWO.Text;
       params.ParamByName('carton').AsString := cmbLotNo.Text;
       open;
       if fieldByName('LOTQTY').AsInteger =0 then exit;
       lblQty.Caption :=    fieldbyName('LOTQTY').AsString;
   end;



   with qrytemp do begin
       close;
       params.Clear;
      // params.CreateParam(ftstring,'process',ptInput);
       params.CreateParam(ftstring,'WO',ptInput);
       params.CreateParam(ftstring,'carton',ptInput);
       commandtext := ' select A.WORK_ORDER,B.CARTON_NO,C.DEFECT_CODE,C.DEFECT_DESC,COUNT(*) QTY '+
                      ' from sajet.g_sn_defect_first a,sajet.g_sn_status b ,sajet.sys_defect c '+
                      ' where A.SERIAL_NUMBER =B.SERIAL_NUMBER and A.DEFECT_ID =c.Defect_ID and A.WORK_ORDER =b.WORK_ORDER '+
                      ' and A.PROCESS_ID =B.PROCESS_ID and A.WORK_ORDER=:WO AND B.CARTON_NO =:CARTON GROUP BY  '+
                      '  A.WORK_ORDER,B.CARTON_NO,C.DEFECT_CODE,C.DEFECT_DESC ';
       //params.ParamByName('process').AsString := G_sProcessID;
       params.ParamByName('wo').AsString := edtWO.Text;
       params.ParamByName('carton').AsString := cmbLotNo.Text;
       open;
       //if isEmpty then exit;
       first;
       AllDefectQty :=0;
       iRows:=1;
       while not eof do begin
            AllDefectQty := AllDefectQty + fieldByname('QTY').AsInteger;
            StringGrid1.RowCount := iRows+1;
            StringGrid1.Cells[0,iRows] :=fieldByname('WORK_ORDER').AsString;
            StringGrid1.Cells[1,iRows] :=fieldByname('CARTON_NO').AsString;
            StringGrid1.Cells[2,iRows] :=fieldByname('DEFECT_CODE').AsString;
            StringGrid1.Cells[3,iRows] :=fieldByname('DEFECT_DESC').AsString;
            StringGrid1.Cells[4,iRows] :=fieldByname('QTY').AsString;
            Next;
            Inc(iRows);
       end;
       lblDefectQty.Caption :=  IntToStr(AllDefectQty);
   end;

   if lblQty.Caption =lblDefectQty.Caption then begin

       with qrytemp do begin
         close;
         params.Clear;
         params.CreateParam(ftstring,'WO',ptInput);
         params.CreateParam(ftstring,'carton',ptInput);
         commandtext := 'select CLOSE_FLAG from sajet.G_PACK_CARTON where  WOrk_order=:wo and carton_NO =:carton';
         params.ParamByName('wo').AsString := edtWO.Text;
         params.ParamByName('carton').AsString := cmbLotNo.Text;
         open;
         if fieldByname('CLOSE_FLAG').AsString ='C' then begin
              MessageDlg('у竒ЧΘ',mterror,[mbok],0);
              exit;
         end;
       end;


   end;

   edtDefectCode.Enabled :=true;
   edtDefectCode.SetFocus;
   edtDefectCode.Text :='';
end;

procedure TForm1.edtDefectQtyChange(Sender: TObject);
begin
 if trim( edtDefectQty.Text) = '' then exit;
   if StrToIntDef(edtDefectQty.Text,0)=0 then begin
       MessageDlg('岿粇计',mterror,[mbok],0);
       edtDefectQty.Text :='';
       edtDefectQty.SetFocus;
   end;
   if  StrToIntDef(edtDefectQty.Text,0)>    StrToIntDef(lblQty.Caption,0) then begin
       MessageDlg('ぃ▆计秖ぃ代刚计秖',mterror,[mbok],0);
       edtDefectQty.Text :='';
       edtDefectQty.SetFocus;
   end;
end;

procedure TForm1.sbtnAddClick(Sender: TObject);
Var iResult:string;
begin

   if edtDefectQty.Text ='' then exit;
   Sproc.Close;
   sproc.DataRequest('SAJET.CCM_TEST_FOR_LOT_NOGO');
   sproc.FetchParams;
   Sproc.Params.ParamByName('tterminalid').AsString := G_STerminalID;
   Sproc.Params.ParamByName('TEMP').AsString := UpdateUserID;
   Sproc.Params.ParamByName('TLOTNO').AsString := cmbLotNo.Text;
   Sproc.Params.ParamByName('TDEFECT').AsString := edtDefectCode.Text;
   Sproc.Params.ParamByName('TDEFECTQTY').AsString := edtDefectQty.Text;
   Sproc.Execute;
   iResult := Sproc.Params.parambyName('TRES').AsString ;
   if iResult <>'OK' Then begin
       MessageDlg(IResult,mterror,[mbOK],0);
       IsError:=True;
       exit;
   end;

end;

procedure TForm1.sbtnPrintClick(Sender: TObject);
var iResult:string;
Key:char;
i:integer;
begin
   if trim(cmbLotNo.Text) ='' then exit;
   IF mrNo = MessageDlg('眤絋﹚ぃ璶ЧΘу秖',mtConfirmation,[MBNO,MBYes],1) then begin
      Sproc.Close;
      sproc.DataRequest('SAJET.CCM_TEST_FOR_LOT_GO');
      sproc.FetchParams;
      Sproc.Params.ParamByName('tterminalid').AsString := G_STerminalID;
      Sproc.Params.ParamByName('TEMP').AsString := UpdateUserID;
      Sproc.Params.ParamByName('TLOTNO').AsString := cmbLOTNO.Text;
      Sproc.Params.ParamByName('TPASSQTY').AsInteger := StrToIntDef(lblQty.Caption,0)- AllDefectQty;
      Sproc.Execute;
      iResult := Sproc.Params.parambyName('TRES').AsString ;
      if iResult <>'OK' Then begin
          MessageDlg(IResult,mterror,[mbOK],0);
      end;
    end;

   edtDefectCode.Enabled :=false;
   edtDefectQty.Enabled :=false;
   cmbLotNo.Text :='';
   edtDefectCode.Text :='';
   edtDefectQty.Text :='';
   cmbLotNo.SetFocus;
   Key :=#13;
   edtWO.OnKeyPress(self,Key);

   IRows :=1;
   for I:=1 to iRows-1 do begin
        StringGrid1.Cells[0,iRows] :='';
        StringGrid1.Cells[1,iRows] :='';
        StringGrid1.Cells[2,iRows] :='';
        StringGrid1.Cells[3,iRows] :='';
        StringGrid1.Cells[4,iRows] :='';
   end;


end;

procedure TForm1.Label3DblClick(Sender: TObject);
begin
   edtWO.Enabled :=true;
   edtWO.SelectAll;
   edtWo.SetFocus ;
   cmbLotNo.Text :='';
   edtDefectQty.Text :='';
   edtDefectCode.Text :='';
   cmbLotNo.Enabled :=FALSE;
   edtDefectQty.Enabled :=FALSE;
   edtDefectCode.Enabled :=FALSE;
end;

end.
