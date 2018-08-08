unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask, RzEdit,ComObj,Tlhelp32,IniFiles, DBGrids, Menus;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    lbl1: TLabel;
    lbl2: TLabel;
    edtDN: TRzEdit;
    edtSO: TRzEdit;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lbl3: TLabel;
    edtCust: TRzEdit;
    lbl5: TLabel;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    lbl6: TLabel;
    tmr1: TTimer;
    edtPN: TRzEdit;
    Image2: TImage;
    btnAdd: TSpeedButton;
    Label1: TLabel;
    edtQty: TRzEdit;
    Label2: TLabel;
    lbl4: TLabel;
    edtDnItem: TRzEdit;
    ds1: TDataSource;
    sbtnUpdate: TSpeedButton;
    Image1: TImage;
    pm1: TPopupMenu;
    Delete1: TMenuItem;
    dbgrd1: TDBGrid;
    lblTerminal: TLabel;
    procedure btnAddClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtDNKeyPress(Sender: TObject; var Key: Char);
    procedure edtPNKeyPress(Sender: TObject; var Key: Char);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtSOKeyPress(Sender: TObject; var Key: Char);
    procedure edtDnItemKeyPress(Sender: TObject; var Key: Char);
    procedure edtDNChange(Sender: TObject);
    procedure ds1DataChange(Sender: TObject; Field: TField);
    procedure Delete1Click(Sender: TObject);
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    UpdateUserID,UpdateUserNO,sDN_ID,PART_ID:string;
    G_sTerminalID,G_sProcessID,G_sPDLineID,G_sStageID,sFactoryId: String;
    Count:Integer;
    UpDate_Time :TDateTime;
    procedure QueryDNData;
    function  GetTerminalName(sTerminalID:string):string;
  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}
uses uDllform,DllInit;

function TForm1.GetTerminalName(sTerminalID:string):string;
var sPdline,sProcess,sTerminal:string;
begin
    try
      with Qrytemp do
       begin
          Close;
          Params.Clear;
          Params.CreateParam(ftString,'TerminalID',ptInput);
          CommandText :='select a.pdline_name,b.process_name,c.terminal_name,c.terminal_id,a.factory_id, ' +
                        '  b.process_id from sajet.sys_pdline a,sajet.sys_process b,sajet.sys_terminal c '+
                        '  where c.terminal_id = :TerminalID  '+
                        '  and a.pdline_id=c.pdline_id '+
                        '  and b.process_id=c.process_id';

          Params.ParamByName('TerminalID').AsString :=sTerminalID;
          Open;
          if RecordCount > 0 then
          begin
             sPdline := Fieldbyname('pdline_name').AsString  ;
             sProcess:= Fieldbyname('process_name').AsString  ;
             sFactoryId :=  Fieldbyname('Factory_id').AsString  ;
             sTerminal:= Fieldbyname('terminal_name').AsString  ;
             Result := sPdline + ' \ ' + sProcess + ' \ ' + sTerminal ;
          end   
          else
             Result :='No Terminal information!';
       end;
    Except   on e:Exception do
       Result := 'Get Terminal : ' + e.Message;

    end;
end;

procedure TForm1.btnAddClick(Sender: TObject);
begin

   if edtDn.Text =''  then exit;
   if edtPN.Text =''  then exit;
   if edtqty.Text ='' then exit;
   if edtDnItem.Text =''  then exit;

    with QryTemp do
    begin

       close;
       Params.Clear;
       Params.CreateParam(ftstring,'PART_NO',ptInPut);
       CommandText :=' select PART_ID from sajet.SYS_PART where PART_NO =:PART_NO';
       Params.ParamByName('PART_NO').AsString := edtPN.Text;
       OPEN;

       if ISEMPTY then begin
          MessageDlg('ERROR PART_NO',mterror,[mbok],0);
          Exit;
       end;

       PART_ID := fieldbyname('PART_ID').AsString;




        close;
        Params.Clear;
        Params.CreateParam(ftstring,'DN_NO',ptInPut);
        CommandText :='select * from sajet.g_DN_base where DN_NO=:DN_NO';
        Params.ParamByName('DN_NO').AsString := edtDN.Text;
        Open;

        If IsEmpty then begin

            close;
            Params.Clear;
            CommandText :='select max(DN_ID)+1 DN_ID from sajet.G_DN_BASE';
            Open;
            sDN_ID := fieldbyname('DN_ID').AsString;

            close;
            Params.Clear;
            Params.CreateParam(ftstring,'EMPID',ptInPut);
            Params.CreateParam(ftstring,'DN_ID',ptInPut);
            Params.CreateParam(ftstring,'DN_NO',ptInPut);
            Params.CreateParam(ftstring,'FACTORY_ID',ptInPut);
            CommandText :=' Insert into sajet.G_DN_BASE(DN_ID,DN_NO,UPDATE_USERID,FACTORY_ID) values( :DN_ID,:DN_NO,:EMPID,:FACTORY_ID)';
            Params.ParamByName('EMPID').AsString := UpdateUserID;
            Params.ParamByName('DN_ID').AsString := sDN_ID;
            Params.ParamByName('DN_NO').AsString := edtDN.Text;
            Params.ParamByName('FACTORY_ID').AsString := sFactoryId;
            execute;
        end
        else
           sDN_ID := fieldbyname('DN_ID').AsString;


        close;
        Params.Clear;
        Params.CreateParam(ftstring,'DN_ID',ptInPut);
        Params.CreateParam(ftstring,'DN_ITEM',ptInPut);
        CommandText :='select * from sajet.g_DN_Detail where DN_ID=:DN_ID and DN_ITEM =:DN_ITEM';
        Params.ParamByName('DN_ID').AsString := sDn_ID;
        Params.ParamByName('DN_ITEM').AsString := edtDnItem.Text;
        Open;

        if IsEmpty then begin
            close;
            Params.Clear;
            Params.CreateParam(ftstring,'EMPID',ptInPut);
            Params.CreateParam(ftstring,'DN_ID',ptInPut);
            Params.CreateParam(ftstring,'DN_ITEM',ptInPut);
            Params.CreateParam(ftstring,'SO_NO',ptInPut);
            Params.CreateParam(ftstring,'PART_ID',ptInPut);
            Params.CreateParam(ftstring,'QTY',ptInPut);
            Params.CreateParam(ftstring,'CUSTOMER',ptInPut);
            CommandText :=' Insert into sajet.G_DN_DETAIL(DN_ID,SO_NO,DN_ITEM,UPDATE_USERID,PART_ID,QTY,CUSTOMER) values( :DN_ID,:SO_NO,:DN_ITEM,:EMPID,:PART_ID,:QTY,:CUSTOMER)';
            Params.ParamByName('EMPID').AsString := UpdateUserID;
            Params.ParamByName('DN_ID').AsString := sDN_ID;
            Params.ParamByName('DN_ITEM').AsString := edtDnItem.Text;
            Params.ParamByName('SO_NO').AsString := edtSO.Text;
            Params.ParamByName('PART_ID').AsString := PART_ID ;
            Params.ParamByName('QTY').AsString := edtQty.Text ;
            Params.ParamByName('CUSTOMER').AsString := edtCust.Text ;
            execute;
            MessageDlg('Add OK',mtinformation,[mbok],0);
        end else begin
            close;
            Params.Clear;
            Params.CreateParam(ftstring,'EMPID',ptInPut);
            Params.CreateParam(ftstring,'DN_ID',ptInPut);
            Params.CreateParam(ftstring,'DN_ITEM',ptInPut);
            Params.CreateParam(ftstring,'SO_NO',ptInPut);
            Params.CreateParam(ftstring,'PART_ID',ptInPut);
            Params.CreateParam(ftstring,'QTY',ptInPut);
            Params.CreateParam(ftstring,'CUSTOMER',ptInPut);
            CommandText :=' Update sajet.G_DN_DETAIL set SO_NO=:SO_NO,PART_ID =:PART_ID ,'+
                          ' UPDATE_USERID=:EMPID,QTY=:QTY,CUSTOMER=:CUSTOMER '+
                          ' WHere  DN_ID=:DN_ID and DN_ITEM =:DN_ITEM';
            Params.ParamByName('EMPID').AsString := UpdateUserID;
            Params.ParamByName('DN_ID').AsString := sDN_ID;
            Params.ParamByName('DN_ITEM').AsString := edtDnItem.Text;
            Params.ParamByName('SO_NO').AsString := edtSO.Text;
            Params.ParamByName('PART_ID').AsString := PART_ID ;
            Params.ParamByName('QTY').AsString := edtQty.Text ;
            Params.ParamByName('CUSTOMER').AsString := edtCust.Text ;
            execute;
            MessageDlg('Update OK',mtinformation,[mbok],0);
        end;

        
    end;
    QueryDNData;


end;

procedure TForm1.FormShow(Sender: TObject);
begin
    edtDN.SetFocus;
    lblTerminal.Caption := 'Terminal Name:' +GetTerminalName(G_sTerminalID);
end;

procedure TForm1.edtDNKeyPress(Sender: TObject; var Key: Char);
begin
    if key<>#13 then exit;

    edtDnItem.SelectAll;
    edtDnItem.SetFocus;

end;

procedure TForm1.edtPNKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then exit;
   with QryTemp do
   begin

      close;
      Params.Clear;
      Params.CreateParam(ftstring,'PART_NO',ptInPut);
      CommandText :=' select PART_ID from sajet.SYS_PART where PART_NO =:PART_NO';
      QryTemp.Params.ParamByName('PART_NO').AsString := edtPN.Text;
      OPEN;
      if ISEMPTY then begin
           MessageDlg('ERROR PART_NO',mterror,[mbok],0);
           edtPN.SetFocus;
           edtPN.SelectAll;
           Exit;
      end;

      PART_ID := fieldbyname('PART_ID').AsString;
   end;
   edtQty.SelectAll;
   edtQty.SetFocus;
end;

procedure TForm1.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then  exit;

    edtSO.Clear;
    edtSO.SetFocus;

end;

procedure TForm1.edtSOKeyPress(Sender: TObject; var Key: Char);
begin
   if Key <> #13 then  exit;
      edtCust.Clear;
      edtCust.SetFocus;
end;

procedure TForm1.edtDnItemKeyPress(Sender: TObject; var Key: Char);
begin
//
    if Key <>  #13 then Exit;
    edtPN.SetFocus;
    edtPN.Clear;
end;

procedure TForm1.QueryDNData;
begin
     with QryData do
     begin
         close;
         Params.Clear;
         Params.CreateParam(ftstring,'dn_no',ptInPut);
         CommandText :=' select A.DN_ID,A.DN_no,B.so_no,c.part_no,B.cusTOMER,b.Qty,b.DN_ITEM,C.part_id  from '+
                      ' sajet.G_DN_BASE a,sajet.g_DN_DETAIL b,SAJET.SYS_part C '+
                      ' where a.DN_ID=b.DN_ID and B.PART_ID =C.PART_id AND A.dn_no =:dn_no  ';
         Params.ParamByName('dn_no').AsString := EDTdN.Text;
         open;
     end;
end;

procedure TForm1.edtDNChange(Sender: TObject);
begin

    QueryDNData;
    if QryData.IsEmpty then
        sbtnUpdate.Enabled := false
    else
        sbtnUpdate.Enabled := True;
   {
    edtDnItem.Text := QryTemp.fieldbyname('DN_ITEM').AsString;
    edtPN.Text := QryTemp.fieldbyname('part_no').AsString;
    edtQty.Text := QryTemp.fieldbyname('Qty').AsString;
    edtSO.Text := QryTemp.fieldbyname('SO_NO').AsString;
    edtCust.Text := QryTemp.fieldbyname('cusTOMER').AsString;
    }

end;

procedure TForm1.ds1DataChange(Sender: TObject; Field: TField);
begin

    //edtDN.ReadOnly :=True;
    //edtDnItem.ReadOnly :=True;
    edtDnItem.Text := QryData.fieldbyname('DN_ITEM').AsString;
    edtPN.Text := QryData.fieldbyname('part_no').AsString;
    edtQty.Text := QryData.fieldbyname('Qty').AsString;
    edtSO.Text := QryData.fieldbyname('SO_NO').AsString;
    edtCust.Text := QryData.fieldbyname('cusTOMER').AsString;
    sDN_ID :=  QryData.fieldbyname('DN_ID').AsString;
    
end;

procedure TForm1.Delete1Click(Sender: TObject);
begin
//
   with QryTemp do
   begin

      //sDN_ID :=  QryData.fieldByName('DN_ID').AsString;
      close;
      Params.Clear;
      Params.CreateParam(ftstring,'DN_ID',ptInPut);
      if  QryData.fieldByName('DN_ITEM').AsString<>'' then
          Params.CreateParam(ftstring,'DN_ITEM',ptInPut);
      Params.CreateParam(ftstring,'PART_ID',ptInPut);
      if  QryData.fieldByName('DN_ITEM').AsString='' then
         CommandText :=' delete from sajet.G_DN_DETAIL where DN_ID=:DN_ID and PART_ID =:PART_ID and DN_ITEM IS NULL'
      else
         CommandText :=' delete from sajet.G_DN_DETAIL where DN_ID=:DN_ID and PART_ID =:PART_ID and DN_ITEM =:DN_ITEM ';
      Params.ParamByName('DN_ID').AsString :=  sDn_ID;
      Params.ParamByName('PART_ID').AsString := QryData.fieldByName('PART_ID').AsString;
      if  QryData.fieldByName('DN_ITEM').AsString<>'' then
        Params.ParamByName('DN_ITEM').AsString := QryData.fieldByName('DN_ITEM').AsString;
      execute;

      close;
      Params.Clear;
      Params.CreateParam(ftstring,'DN_ID',ptInPut);
      CommandText :=' Select *  from sajet.G_DN_DETAIL where DN_ID=:DN_ID';
      Params.ParamByName('DN_ID').AsString := sDN_ID;
      Open;

      if IsEmpty then begin
         close;
         Params.Clear;
         Params.CreateParam(ftstring,'DN_ID',ptInPut);
         CommandText :=' delete  from sajet.G_DN_BASE where DN_ID=:DN_ID';
         Params.ParamByName('DN_ID').AsString := sDN_ID;
         execute;
      end;

      MessageDlg('Delete OK',mtinformation,[mbok],0);
   end;
   QueryDNData;
   
end;

end.
