unit UnitMAIN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, MConnect, ObjBrkr, SConnect, StdCtrls, Grids,
  DBGrids, Mask;

type
  TFormMAIN = class(TForm)
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    Clientdatasetgmaterial: TClientDataSet;
    ClientDataSetgmaterialclear: TClientDataSet;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Editpartno: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox2: TGroupBox;
    BTNQuery: TButton;
    Label5: TLabel;
    EditIDNO: TEdit;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    DBGridmaterial: TDBGrid;
    DBGridmaterialCLEAR: TDBGrid;
    DBGridnotinputmaterial: TDBGrid;
    BTNCHeck: TButton;
    BTNConfirm: TButton;
    BTNCLOSE: TButton;
    ClientDataSetnoinputmaterial: TClientDataSet;
    DSMATERIAL: TDataSource;
    DsMATERIALCLEAR: TDataSource;
    DSNOTINPUTmaterial: TDataSource;
    DSNULL: TDataSource;
    CMBwarehouse: TComboBox;
    cmblocate: TComboBox;
    ClientDataSetwarehouse: TClientDataSet;
    ClientDataSetlocate: TClientDataSet;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lbltotalmaterial: TLabel;
    lbltotalinput: TLabel;
    lbltotalnotinput: TLabel;
    ClientDataSetIDNO: TClientDataSet;
    BTNCLEAR: TButton;
    ClientDataSettemp: TClientDataSet;
    Label9: TLabel;
    Editemp: TEdit;
    Label10: TLabel;
    MaskEditpassword: TMaskEdit;
    BtnOK: TButton;
    procedure FormShow(Sender: TObject);
    procedure BTNQueryClick(Sender: TObject);
    procedure cleardata;
    procedure BTNCLOSEClick(Sender: TObject);
    procedure CMBwarehouseDropDown(Sender: TObject);
    procedure cmblocateDropDown(Sender: TObject);
    procedure CMBwarehouseChange(Sender: TObject);
    procedure EditIDNOKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BTNCLEARClick(Sender: TObject);
    procedure BTNCHeckClick(Sender: TObject);
    procedure BTNConfirmClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UpdateUserID: string;
    function SetStatusbyAuthority: Boolean;
    function LoadApServer : Boolean;
  end;

var
  FormMAIN: TFormMAIN;

implementation

{$R *.dfm}

procedure TFormMAIN.cleardata;
begin
   editpartno.Clear ;
   editpartno.SetFocus ;
   cmbwarehouse.Clear ;
   cmblocate.Clear ;
   editidno.Clear ;
   dbgridmaterial.DataSource :=dsnull;
   dbgridmaterialclear.DataSource :=dsnull;
   dbgridnotinputmaterial.DataSource :=dsnull;
   lbltotalmaterial.Caption :='';
   lbltotalinput.Caption :='';
   lbltotalnotinput.Caption :='';
end;

function TformMain.LoadApServer : Boolean;
var
  F : TextFile;
  S : String;
begin
  Result := False;
  SocketConnection1.Connected := False;
  SimpleObjectBroker1.Servers.Clear;
  If not FileExists(GetCurrentDir+'\ApServer.cfg') Then
     Exit;
  AssignFile(F,GetCurrentDir+'\ApServer.cfg');
  Reset(F);
  While True do
  begin
    Readln(F, S);
    If S <> '' Then
    begin
      SimpleObjectBroker1.Servers.Add;
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].ComputerName := Trim(S);
      SimpleObjectBroker1.Servers[SimpleObjectBroker1.Servers.Count-1].Enabled := True;
    end Else
      Break;
  end;
  CloseFile(F);
  Result := True;
end;

procedure TFormMAIN.FormShow(Sender: TObject);
begin
   LoadApServer;

   WITH clientdatasettemp do
   begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString, 'EXE_FILENAME', ptInput);
     Params.CreateParam(ftString, 'dll_name', ptInput);
     CommandText := 'select a.function f1 from sajet.sys_program_name b, sajet.sys_program_fun a '
         + 'where upper(b.EXE_FILENAME) = :EXE_FILENAME and b.program = a.program '
         + ' and rownum = 1 ';
     Params.ParamByName('EXE_FILENAME').AsString :='CLEARWH';
     Open;

     IF ISEMPTY THEN
     BEGIN
         btncheck.Enabled :=false;
         btnconfirm.Enabled :=false;
         SHOWMESSAGE('NOT FIND THE CLEARWH PROGRAM!');
         EXIT;
     END;
  end;
   CLEARDATA;
   btnconfirm.Enabled :=false;
   
end;

procedure TFormMAIN.BTNQueryClick(Sender: TObject);
begin
    if editpartno.Enabled =false then
       editpartno.Enabled :=true;
    if cmbwarehouse.Enabled =false  then
       cmbwarehouse.Enabled :=true ;
    if cmblocate.Enabled =false then
       cmblocate.Enabled :=true;
    if btnconfirm.Enabled =true then
       btnconfirm.Enabled :=false;

    if trim(editpartno.text)=''  then
       begin
           cleardata;
           showmessage('THE PART_NO CAN NOT NULL!') ;
           EXIT;
       end;
    if cmbwarehouse.Text='' then
      begin
          cleardata;
          showmessage('THE WAREHOUSE CAN NOT NULL');
          EXIT;
      end;
    WITH clientdatasetgmaterial do
       begin
            close;
            commandtext:='select * from sajet.sys_part where part_no=:part_no';
            params.ParamByName('part_no').AsString :=editpartno.Text ;
            open;

            if recordcount=0 then
              begin
                  cleardata;
                  showmessage('NOT FIND THE PART NO!') ;
                  EXIT;
              end
              ELSE
                BEGIN
                    IF CMBLOCATE.Text ='' THEN
                      BEGIN
                         close;
                         commandtext:='select B.PART_NO,A.MATERIAL_NO,A.FIFOCODE,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME  '
                                 +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                 +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID IS NOT NULL  '
                                 +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                 +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                 +    '  ORDER BY FIFOCODE ' ;
                         params.ParamByName('part_no').AsString :=trim(editpartno.text);
                         params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                         OPEN;

                         dbgridmaterial.DataSource :=dsmaterial;
                         lbltotalmaterial.Caption :=inttostr(recordcount);
                      END;
                    IF CMBLOCATE.Text<>'' THEN
                      BEGIN
                           close;
                           commandtext:='select B.PART_NO,A.MATERIAL_NO,A.FIFOCODE,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME,D.LOCATE_NAME  '
                                 +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C, SAJET.SYS_LOCATE D '
                                 +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                 +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                 +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                 +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                 +    '  ORDER BY FIFOCODE ' ;
                           params.ParamByName('part_no').AsString :=trim(editpartno.text);
                           params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                           params.ParamByName('locate_name').AsString :=cmblocate.Text ; 
                           OPEN;

                           dbgridmaterial.DataSource :=dsmaterial;
                           lbltotalmaterial.Caption :=inttostr(recordcount);
                      END;
                END;

            
       end;

       with clientdatasetgmaterialclear do
             begin
                  IF CMBLOCATE.Text ='' THEN
                      BEGIN
                         close;
                         commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                 +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                 +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID IS NOT NULL   '
                                 +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                 +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '   ;
                         params.ParamByName('part_no').AsString :=trim(editpartno.text);
                         params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                         OPEN;

                         dbgridmaterialclear.DataSource :=dsmaterialclear;
                         lbltotalinput.Caption :=inttostr(recordcount);
                      END;
                    IF CMBLOCATE.Text<>'' THEN
                      BEGIN
                           close;
                           commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY, C.WAREHOUSE_NAME,D.LOCATE_NAME  '
                                 +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C, SAJET.SYS_LOCATE D '
                                 +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                 +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                 +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                 +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '   ;
                           params.ParamByName('part_no').AsString :=trim(editpartno.text);
                           params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                           params.ParamByName('locate_name').AsString :=cmblocate.Text ; 
                           OPEN;

                           dbgridmaterialclear.DataSource :=dsmaterialclear;
                           lbltotalinput.Caption :=inttostr(recordcount);
                      END;
             end;

    
end;

procedure TFormMAIN.BTNCLOSEClick(Sender: TObject);
begin
   CLOSE;
end;

procedure TFormMAIN.CMBwarehouseDropDown(Sender: TObject);
begin
    with clientdatasetwarehouse do
       begin
           close;
           commandtext:='select warehouse_name from sajet.sys_warehouse order by warehouse_name';
           open;

           first;
           cmbwarehouse.Clear ;
           while not eof do
             begin
                 cmbwarehouse.Items.Add(fields[0].asstring);
                 next;
             end;
       end;
end;

procedure TFormMAIN.cmblocateDropDown(Sender: TObject);
begin
    if cmbwarehouse.Text ='' then
       begin
           showmesSage('PLEASE SELECT WAREHOUSE FIRST!') ;
           EXIT;
       end;
    with clientdatasetlocate do
       begin
           close;
           commandtext:='SELECT locate_name FROM SAJET.SYS_LOCATE WHERE WAREHOUSE_ID in '
                      +  ' (select warehouse_id from SAJET.sys_warehouse where warehouse_name=:WAREHOUSE_NAME) '
                      +  '  AND LOCATE_NAME IS NOT NULL ORDER BY LOCATE_NAME';
           PARAMS.ParamByName('WAREHOUSE_NAME').AsString :=CMBWAREHOUSE.Text ;
           open;

           first;
           cmbLOCATE.Clear ;
           while not eof do
             begin
                 cmbLOCATE.Items.Add(fields[0].asstring);
                 next;
             end;
       end;
end;

procedure TFormMAIN.CMBwarehouseChange(Sender: TObject);
begin
   cmblocate.Clear ;
end;

procedure TFormMAIN.EditIDNOKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
VAR SIDNO:STRING;
begin
    SIDNO:=COPY(TRIM(EDITIDNO.Text),1,1) ;
    if TRIM(editidno.Text) <>'' then
       if key=13 then
          begin
              // 如果是查reel_id
           IF SIDNO='R' THEN
              begin
                // if comlocate.text is null
                 if cmblocate.Text='' then
                    BEGIN
                       with clientdatasetidno do
                           begin
                                //check the id_id 是否在g_material_clear 中
                                     close;
                                     commandtext:='select * from sajet.g_material_clear where material_no=:material_no';
                                     params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                     open;
                                     if recordcount>0 then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO IS ALREADY EXIST!');
                                            EXIT;
                                        end;
                                    close;
                                   //commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                    commandtext:='select A.part_id,A.material_no,A.material_qty,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                        +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                        +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                        +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                        +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) AND ROWNUM=1  ';
                                     params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                                     params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                     params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                     OPEN;

                                     if recordcount> 0 then
                                         begiN
                                         //if reel_no is null
                                         if fields[3].AsString='' then
                                             begin
                                                  close;
                                                  commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                       +    'select A.part_id,A.material_no,A.material_qty,A.locate_id,A.warehouse_id  '
                                                       +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                       +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                       +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                       +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) AND ROWNUM=1  ';
                                                   params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                                                   params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                   params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                   execute;
                                                end
                                                // if reel_no is not null
                                                else
                                                    begin
                                                         close;
                                                         commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                              +    'select A.part_id,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                                              +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                              +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                              +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                              +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) AND ROWNUM=1  ';
                                                          params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                                                          params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                          params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                          execute;
                                                      end;

                                                showmessage('add ok!') ;
                                                editidno.SelectAll ;
                                                with clientdatasetgmaterialclear do
                                                     BEGIN
                                                         close;
                                                         commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                                              +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                              +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                              +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                              +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '   ;
                                                         params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                         params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                         OPEN;

                                                         dbgridmaterialclear.DataSource :=dsmaterialclear;
                                                         lbltotalinput.Caption :=inttostr(recordcount);
                                                      END;
                                       end
                                       else
                                          begin
                                              EDITIDNO.SelectAll ; ;
                                              showmessage('NOT FIND THE ID NO!') ;
                                               EXIT;
                                          end;
                                  end;
                          END;
                 //if cmblocate.text is not null
                 if cmblocate.Text<>'' then
                    BEGIN
                       with clientdatasetidno do
                           begin
                                //check the id_id 是否在g_material_clear 中
                                     close;
                                     commandtext:='select * from sajet.g_material_clear where material_no=:material_no';
                                     params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                     open;
                                     if recordcount>0 then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO IS ALREADY EXIST!');
                                            EXIT;
                                        end;
                               close;
                               //commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                commandtext:='select A.part_id,A.material_no,A.material_qty,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                 +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                 +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID and a.locate_id=d.locate_id  '
                                 +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                 +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME )   '
                                 +    '  and d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME)   AND ROWNUM=1  ';
                              params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                              params.ParamByName('part_no').AsString :=trim(editpartno.text);
                              params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                              PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                              OPEN;

                              if recordcount> 0 then
                                 begiN
                                    //if reel_no is null
                                    if fields[3].AsString='' then
                                         begin
                                             close;
                                             commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                    +    'select A.part_id,A.material_no,A.material_qty,A.locate_id,A.warehouse_id '
                                                    +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C ,SAJET.SYS_LOCATE D'
                                                    +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID and a.locate_id=d.locate_id   '
                                                    +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                    +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME ) '
                                                    +    '  AND d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) and rownum=1 ';
                                             params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                                             params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                             params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                             PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                             execute;
                                         end
                                    // if reel_no is not null
                                         else
                                              begin
                                                   close;
                                                   commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                         +    'select A.part_id,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                                         +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C ,SAJET.SYS_LOCATE D '
                                                         +    ' WHERE  (a.material_no=:reel_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID and a.locate_id=d.locate_id   '
                                                         +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                         +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                         +    '  AND d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) and rownum=1 ';
                                                   params.ParamByName('reel_id').AsString :=trim(editidno.Text );
                                                   params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                   params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                   PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                                   execute;

                                              end;

                                 showmessage('add ok!') ;
                                 editidno.SelectAll ;
                                 with clientdatasetgmaterialclear do
                                     BEGIN
                                          close;
                                          commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                              +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,SAJET.SYS_LOCATE D '
                                              +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID  and a.locate_id=d.locate_id  '
                                              +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                              +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                              +    '  AND d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME)     ';
                                          params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                          params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                          PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                          PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                          OPEN;

                                          dbgridmaterialclear.DataSource :=dsmaterialclear;
                                          lbltotalinput.Caption :=inttostr(recordcount);
                                     END;
                                 end
                                 else
                                    begin
                                      EDITIDNO.SelectAll ; ;
                                      showmessage('NOT FIND THE ID NO!') ;
                                      EXIT;
                                    end;
                           end;
                     END;
               end;
            // 如果不是reel_id
            IF SIDNO<>'R'  THEN
                BEGIN
                // if comlocate.text is null
                 if cmblocate.Text='' then
                    BEGIN
                       with clientdatasetidno do
                           begin
                                //check the id_id 是否在g_material_clear 中
                                     close;
                                     commandtext:='select * from sajet.g_material_clear where material_no=:material_no';
                                     params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                     open;
                                     if recordcount>0 then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO IS ALREADY EXIST!');
                                            EXIT;
                                        end;
                                //check 是否有展reel_id;
                                      close;
                                      commandtext:='select distinct reel_no from sajet.g_material where material_no=:material_no and reel_no is not null';
                                      params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                      open;
                                      if fields[0].AsString <>'' then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO 有展REEL_ID!');
                                            EXIT;
                                        end
                                        ELSE
                                            BEGIN
                                               close;
                                                //commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                                 commandtext:='select A.part_id,A.material_no,A.material_qty,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                                  +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                  +    ' WHERE  (a.material_no=:MATERIAL_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                  +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                  +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) AND ROWNUM=1  ';
                                               params.ParamByName('MATERIAL_id').AsString :=trim(editidno.Text );
                                               params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                               params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                               OPEN;

                                               if recordcount> 0 then
                                                  begiN
                                                       close;
                                                       commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                                     +    'select A.part_id,A.material_no,A.material_qty,A.locate_id,A.warehouse_id  '
                                                                     +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                                     +    ' WHERE  (a.material_no=:MATERIAL_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                                     +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                                     +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) AND ROWNUM=1  ';
                                                        params.ParamByName('MATERIAL_id').AsString :=trim(editidno.Text );
                                                        params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                        params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                        execute;


                                                        showmessage('add ok!') ;
                                                        editidno.SelectAll ;
                                                         with clientdatasetgmaterialclear do
                                                             BEGIN
                                                                    close;
                                                                    commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                                                     +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                                     +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                                     +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                                     +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '   ;
                                                                     params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                                     params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                                     OPEN;

                                                                     dbgridmaterialclear.DataSource :=dsmaterialclear;
                                                                     lbltotalinput.Caption :=inttostr(recordcount);
                                                              END;

                                                       end
                                                       else
                                                           begin
                                                                 EDITIDNO.SelectAll ; ;
                                                                  showmessage('NOT FIND THE ID NO!') ;
                                                                  EXIT;
                                                            end;
                                                     end;
                                           END;
                                end;
                //if cmblocate.text is not null
                if cmblocate.Text<>'' then
                    BEGIN
                       with clientdatasetidno do
                           begin
                                //check the id_id 是否在g_material_clear 中
                                     close;
                                     commandtext:='select * from sajet.g_material_clear where material_no=:material_no';
                                     params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                     open;
                                     if recordcount>0 then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO IS ALREADY EXIST!');
                                            EXIT;
                                        end;
                                     //check 是否有展reel_id;
                                      close;
                                      commandtext:='select distinct reel_no from sajet.g_material where material_no=:material_no and reel_no is not null';
                                      params.ParamByName('material_no').AsString :=trim(editidno.Text );
                                      open;
                                      if fields[0].AsString <>''  then
                                        begin
                                            editidno.SelectAll ;
                                            showmessage('THE ID NO 有展REEL_ID!');
                                            EXIT;
                                        end
                                        ELSE
                                          BEGIN
                                               close;
                                              //commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                               commandtext:='select A.part_id,A.material_no,A.material_qty,A.reel_no,A.reel_qty,A.locate_id,A.warehouse_id  '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                                +    ' WHERE  (a.material_no=:MATERIAL_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID and a.locate_id=d.locate_id   '
                                                +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME )   '
                                                +    '  and d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME)   AND ROWNUM=1  ';
                                             params.ParamByName('MATERIAL_id').AsString :=trim(editidno.Text );
                                             params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                             params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                             PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                             OPEN;

                                             if recordcount> 0 then
                                                begiN
                                                     close;
                                                     commandtext:='insert into sajet.g_material_clear(part_id,material_no,material_qty,locate_id,warehouse_id) '
                                                                   +    'select A.part_id,A.material_no,A.material_qty,A.locate_id,A.warehouse_id '
                                                                   +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C ,SAJET.SYS_LOCATE D'
                                                                   +    ' WHERE  (a.material_no=:MATERIAL_id or A.REEL_NO=:reel_id) and  A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID and a.locate_id=d.locate_id   '
                                                                   +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                                   +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME ) '
                                                                   +    '  AND d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) and rownum=1 ';
                                                      params.ParamByName('MATERIAL_id').AsString :=trim(editidno.Text );
                                                      params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                      params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                      PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                                      execute;
       


                                                     showmessage('add okaaa!') ;
                                                      editidno.SelectAll ;
                                                      with clientdatasetgmaterialclear do
                                                          BEGIN
                                                               close;
                                                               commandtext:='select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY ,C.WAREHOUSE_NAME  '
                                                                   +    ' FROM SAJET.G_MATERIAL_clear  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,SAJET.SYS_LOCATE D '
                                                                   +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID  and a.locate_id=d.locate_id  '
                                                                   +    '  AND b.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                                   +    '  AND c.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                                   +    '  AND d.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME)     ';
                                                               params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                                               params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                                               PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                                               PARAMS.ParamByName('LOCATE_NAME').AsString :=cmblocate.Text ;
                                                               OPEN;

                                                               dbgridmaterialclear.DataSource :=dsmaterialclear;
                                                               lbltotalinput.Caption :=inttostr(recordcount);
                                                          END;
                                                      end
                                                      else
                                                         begin
                                                           EDITIDNO.SelectAll ; ;
                                                           showmessage('NOT FIND THE ID NO!') ;
                                                           EXIT;
                                                         end;
                                                  END;
                                          end;
                                    END;

                             END;
         END;
end;

procedure TFormMAIN.BTNCLEARClick(Sender: TObject);
begin
    if cmblocate.Text ='' then
       begin
          with clientdatasetgmaterialclear do
                BEGIN
                   close;
                   commandtext:=' delete  SAJET.G_MATERIAL_clear  where '
                         +    '  part_id IN (SELECT PART_id FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                         +    '  AND WAREHOUSE_ID IN (SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '   ;
                   params.ParamByName('part_no').AsString :=trim(editpartno.text);
                   params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                   execute;
               end;
       end;
   if cmblocate.Text <>'' then
       begin
          with clientdatasetgmaterialclear do
                BEGIN
                   close;
                   commandtext:=' delete  SAJET.G_MATERIAL_clear  where '
                         +    '  part_id IN (SELECT PART_id FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                         +    '  AND WAREHOUSE_ID IN (SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                         +    '  and locate_id in (select locate_id from sajet.sys_locate where locate_name=:locate_name)';
                   params.ParamByName('part_no').AsString :=trim(editpartno.text);
                   params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                   params.ParamByName('locate_name').AsString :=cmblocate.Text ;  
                   execute;
               end;
       end;
end;

procedure TFormMAIN.BTNCHeckClick(Sender: TObject);
begin
    if editpartno.Text <> '' then
       if cmbwarehouse.Text <>'' then
          with clientdatasetnoinputmaterial do
              begin
                  close;
                  params.CreateParam(ftstring,'emp_id',ptinput);
                  params.CreateParam(ftstring,'warehouse_name',ptinput);
                  commandtext:=' select * from sajet.sys_emp_warehouse a,sajet.sys_warehouse b '
                              +' where a.emp_id=:emp_id and a.warehouse_id=b.warehouse_id '
                              +' and b.warehouSe_name=:warehouse_name AND A.ENABLED=''Y'' AND ROWNUM=1 ';
                  params.ParamByName('emp_id').AsString :=updateuserid;
                  params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text;
                  open;
                  if isempty then
                  begin
                     MessageDlg('WAREHOUSE ERROR!-'+cmbwarehouse.Text, mtInformation,[mbOk], 0);
                     exit;
                  end;


                  close;
                  commandtext:='select * from sajet.sys_part where part_no=:part_no';
                  params.ParamByName('part_no').AsString :=editpartno.Text ;
                  open;

                  if recordcount=0 then
                      begin
                            cleardata;
                            showmessage('NOT FIND THE PART NO!') ;
                            EXIT;
                      end;
                 IF RECORDCOUNT<>0 THEN
                     begin
                         if cmblocate.Text ='' then
                             BEGIN
                                    close;
                                    commandtext:= ' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND A.REEL_NO IS NULL and a.material_no not in  '
                                                +    ' ( '
                                                +    ' select A.MATERIAL_NO  '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND A.REEL_NO IS NULL '
                                                +    '  AND A.MATERIAL_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    ' )'
                                            +    'union '
                                            +    ' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND A.REEL_NO IS NOT NULL  and a.reel_no not in  '
                                                +    ' ( '
                                                +    ' select A.REEL_NO '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND A.reel_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    '  ) ' ;

                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    OPEN;

                                    dbgridNOTINPUTmaterial.DataSource :=dsnotinputmaterial;
                                    lbltotalNOTINPUT.Caption :=inttostr(recordcount);

                             end;
                        if cmblocate.Text <>'' then
                             BEGIN
                                    close;
                                    commandtext:= ' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                            +    ' AND A.REEL_NO IS NULL and a.material_no not in  '
                                                +    ' ( '
                                                +    ' select A.MATERIAL_NO  '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C, sajet.sys_locate D '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    '  AND A.REEL_NO IS NULL '
                                                +    '  AND A.MATERIAL_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                     +   '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    ' )'
                                            +    'union '
                                            +    ' select B.PART_NO,A.MATERIAL_NO,A.MATERIAL_QTY,A.REEL_NO,A.REEL_QTY, C.WAREHOUSE_NAME  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID  AND A.LOCATE_ID=D.LOCATE_ID '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                            +    '  AND a.reel_no is not null and  a.reel_no not in  '
                                                +    ' ( '
                                                +    ' select A.REEL_NO '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    '  AND A.reel_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    '  ) ' ;

                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    params.ParamByName('locate_name').AsString :=cmblocate.Text ;
                                    OPEN;

                                    dbgridNOTINPUTmaterial.DataSource :=dsnotinputmaterial;
                                    lbltotalNOTINPUT.Caption :=inttostr(recordcount);
                             end;

                         first;
                         while not eof do
                         begin
                            with ClientDataSettemp do
                            begin
                                  close;
                                  params.CreateParam(ftstring,'material_no',ptinput);
                                  commandtext:='select type from sajet.g_material where  ' ;
                                  if clientdatasetnoinputmaterial.FieldByName('reel_no').AsString<>'' then
                                  begin
                                     commandtext:=commandtext+' reel_no=:material_no and rownum=1 ';
                                     params.ParamByName('material_no').AsString := clientdatasetnoinputmaterial.FieldByName('reel_no').AsString;
                                     open;
                                     if fieldbyname('type').AsString='O' Then
                                     begin
                                        MessageDlg('TRANSFER UNCONFIRM!-'+clientdatasetnoinputmaterial.FieldByName('reel_no').AsString, mtInformation,[mbOk], 0);
                                        exit;
                                     end;
                                  end
                                  else
                                  begin
                                     commandtext:=commandtext+' material_no=:material_no and rownum=1 ';
                                     params.ParamByName('material_no').AsString:=  clientdatasetnoinputmaterial.FieldByName('material_no').AsString ;
                                     open;
                                     if fieldbyname('type').AsString='O' Then
                                     begin
                                        MessageDlg('TRANSFER UNCONFIRM!-'+clientdatasetnoinputmaterial.FieldByName('material_no').AsString, mtInformation,[mbOk], 0);
                                        exit;
                                     end;
                                  end;
                            end;
                            next;
                          end;


                        btnconfirm.Enabled :=true;
                        if editpartno.Enabled =true then
                           editpartno.Enabled :=false;
                        if cmbwarehouse.Enabled =true then
                           cmbwarehouse.Enabled :=false;
                        if cmblocate.Enabled =true then
                           cmblocate.Enabled :=false;
                    end;
              end;

end;

procedure TFormMAIN.BTNConfirmClick(Sender: TObject);
begin
    if editpartno.Text <> '' then
       if cmbwarehouse.Text <>'' then
          with clientdatasetnoinputmaterial do
              begin
                  close;
                  params.CreateParam(ftstring,'emp_id',ptinput);
                  params.CreateParam(ftstring,'warehouse_name',ptinput);
                  commandtext:=' select * from sajet.sys_emp_warehouse a,sajet.sys_warehouse b '
                              +' where a.emp_id=:emp_id and a.warehouse_id=b.warehouse_id '
                              +' and b.warehouSe_name=:warehouse_name AND A.ENABLED=''Y'' AND ROWNUM=1 ';
                  params.ParamByName('emp_id').AsString :=updateuserid;
                  params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text;
                  open;
                  if isempty then
                  begin
                     MessageDlg('WAREHOUSE ERROR!-'+cmbwarehouse.Text, mtInformation,[mbOk], 0);
                     exit;
                  end;


                  close;
                  commandtext:='select * from sajet.sys_part where part_no=:part_no';
                  params.ParamByName('part_no').AsString :=editpartno.Text ;
                  open;

                  if recordcount=0 then
                  begin
                          cleardata;
                          showmessage('NOT FIND THE PART NO!') ;
                          EXIT;
                  end;
                 IF RECORDCOUNT<>0 THEN
                     begin
                         if cmblocate.Text ='' then
                             BEGIN
                                    close;
                                    params.CreateParam(ftstring,'update_userid',ptinput) ;
                                    commandtext:=' update sajet.g_material set type=''C'',update_userid=:update_userid ,update_time=sysdate where material_no in '
                                            +    ' ( '
                                            +    ' select A.MATERIAL_NO  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND A.REEL_NO IS NULL and a.material_no not in  '
                                                +    ' ( '
                                                +    ' select A.MATERIAL_NO  '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND A.REEL_NO IS NULL '
                                                +    '  AND A.MATERIAL_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    ' )'
                                           +     ' ) ';
                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    params.ParamByName('update_userid').AsString :=updateuserid;
                                    execute;

                                     close;
                                     params.CreateParam(ftstring,'update_userid',ptinput) ;
                                     commandtext:=' update sajet.g_material set type=''C'',update_userid=:update_userid ,update_time=sysdate where reel_no in '
                                            +    ' ( '
                                            +    ' select A.REEL_NO  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND A.REEL_NO IS NOT NULL  and a.reel_no not in  '
                                                +    ' ( '
                                                +    ' select A.REEL_NO '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID   '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND A.reel_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    '  ) '
                                             +     ' ) ';
                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    params.ParamByName('update_userid').AsString :=updateuserid;
                                    execute;

                                    //dbgridNOTINPUTmaterial.DataSource :=dsnotinputmaterial;
                                   // lbltotalNOTINPUT.Caption :=inttostr(recordcount);

                             end;
                        if cmblocate.Text <>'' then
                             BEGIN
                                    close;
                                    commandtext:=' update sajet.g_material set type=''C'' where material_no in '
                                            +    ' ( '
                                            +    ' select A.MATERIAL_NO  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID   '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                            +    ' AND A.REEL_NO IS NULL and a.material_no not in  '
                                                +    ' ( '
                                                +    ' select A.MATERIAL_NO  '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C, sajet.sys_locate D '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    '  AND A.REEL_NO IS NULL '
                                                +    '  AND A.MATERIAL_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                     +   '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    ' )'
                                             +     ' ) ';
                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    params.ParamByName('locate_name').AsString :=cmblocate.Text ;
                                    execute;

                                     close;
                                     commandtext:=' update sajet.g_material set type=''C'' where reel_no in '
                                            +    ' ( '
                                            +    ' select A.REEL_NO  '
                                            +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                            +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID  AND A.LOCATE_ID=D.LOCATE_ID '
                                            +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                            +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                            +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                            +    '  AND a.reel_no is not null and  a.reel_no not in  '
                                                +    ' ( '
                                                +    ' select A.REEL_NO '
                                                +    ' FROM SAJET.G_MATERIAL  A,SAJET.SYS_PART B, SAJET.SYS_WAREHOUSE C,sajet.sys_locate D '
                                                +    ' WHERE A.PART_ID=B.PART_ID AND A.WAREHOUSE_ID=C.WAREHOUSE_ID AND A.LOCATE_ID=D.LOCATE_ID  '
                                                +    '  AND B.PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)   '
                                                +    '  AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME)  '
                                                +    '  AND D.LOCATE_ID IN(SELECT LOCATE_ID FROM SAJET.SYS_LOCATE WHERE LOCATE_NAME=:LOCATE_NAME) '
                                                +    '  AND A.reel_no  IN (SELECT MATERIAL_NO FROM SAJET.G_MATERIAL_CLEAR   '
                                                     +   ' WHERE PART_ID IN (SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO)  '
                                                     +   ' AND C.WAREHOUSE_ID IN(SELECT WAREHOUSE_ID FROM SAJET.SYS_WAREHOUSE WHERE WAREHOUSE_NAme=:WAREHOUSE_NAME) ) '
                                                +    '  ) '
                                            +     ' ) ';
                                    params.ParamByName('part_no').AsString :=trim(editpartno.text);
                                    params.ParamByName('warehouse_name').AsString :=cmbwarehouse.Text ;
                                    params.ParamByName('locate_name').AsString :=cmblocate.Text ;
                                    execute;
                               end;

                           // dbgridNOTINPUTmaterial.DataSource :=dsnotinputmaterial;
                           // lbltotalNOTINPUT.Caption :=inttostr(recordcount);
                             close ;
                             commandtext:='insert into sajet.g_ht_material  '
                                       +  ' select * from sajet.g_material where part_id in(SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO) '
                                       +  ' and type=''C'' ';
                             params.ParamByName('part_no').AsString :=trim(editpartno.text);
                             EXECUTE;

                             close ;
                             commandtext:='DELETE  sajet.g_material  '
                                      +  ' where part_id in(SELECT PART_ID FROM SAJET.SYS_PART WHERE PART_NO=:PART_NO) '
                                      +  ' and type=''C'' ';
                             params.ParamByName('part_no').AsString :=trim(editpartno.text);
                             EXECUTE;

                             btnconfirm.Enabled :=false;
                             if editpartno.Enabled =false then
                                editpartno.Enabled :=true;
                             if cmbwarehouse.Enabled =false then
                                cmbwarehouse.Enabled :=true;
                             if cmblocate.Enabled =false then
                                cmblocate.Enabled :=true;
                             Showmessage('Confirm 成功!');


                    end;
              end;
end;

function TFormMAIN.SetStatusbyAuthority: Boolean;
var sAuth, UserID: string;
begin
  Result := False;
  with clientdatasettemp do
  begin
    Close;
    Params.Clear;
    //Params.CreateParam(ftString, 'PWD', ptInput);
    Params.CreateParam(ftString, 'EMP_NO', ptInput);
    CommandText := 'Select EMP_ID,EMP_NAME,EMP_NO,trim(SAJET.password.decrypt(PASSWD)) PWD '
      + '      ,ENABLED,NVL(TO_CHAR(QUIT_DATE,''yyyy/mm/dd''),''N/A'') QUIT_DATE '
      + '      ,CHANGE_PW_TIME '
      + 'From SAJET.SYS_EMP '
      + 'Where Upper(EMP_NO) = :EMP_NO ';
    //Params.ParamByName('PWD').AsString := Trim(editPwd.Text) ;
    Params.ParamByName('EMP_NO').AsString := UpperCase(Trim(editemp.Text));
    Open;
    if not IsEmpty then
    begin
      // 檢查 PWD
      if Trim(maskeditpassword.Text) <> Fieldbyname('PWD').AsString then
      begin
        Close;
        maskeditpassword.Text := '';
        MessageDlg('Invalid Password!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否已離職
      if (trim(Fieldbyname('QUIT_DATE').AsString) <> 'N/A') then
      begin
        Close;
        maskeditpassword.Text := '';
        editemp.SetFocus;
        editemp.SelectAll;
        MessageDlg('This User have Terminate!!', mtError, [mbCancel], 0);
        Exit;
      end;
      // 檢查是否有效
      if (Copy(Fieldbyname('ENABLED').AsString, 1, 1) <> 'Y') then
      begin
        Close;
        maskeditpassword.Text := '';
        editemp.SetFocus;
        editemp.SelectAll;
        MessageDlg('User invalid !!', mtError, [mbCancel], 0);
        Exit;
      end;
      UserID := Fieldbyname('EMP_ID').AsString;
      UpdateUserID:=Fieldbyname('EMP_ID').AsString;
      Close;
      Params.Clear;
      Params.CreateParam(ftString, 'EMP_ID', ptInput);
      Params.CreateParam(ftString, 'PRG', ptInput);
      Params.CreateParam(ftString, 'FUN', ptInput);
      CommandText := 'SELECT NVL(MAX(C.AUTH_SEQ),0) AS C_AUTH_SEQ  '
                    +' FROM SAJET.SYS_ROLE_PRIVILEGE A, '
                    +' SAJET.SYS_ROLE_EMP B,'
                    +' SAJET.SYS_PROGRAM_FUN C '
                    +'  WHERE A.ROLE_ID = B.ROLE_ID '
                    +'  AND B.EMP_ID =:emp_id '
                    +' AND A.PROGRAM = :prg '
                    +'  AND  A.FUNCTION =:fun '
                    +' AND  A.PROGRAM = C.PROGRAM '
                    +' AND   A.FUNCTION = C.FUNCTION '
                    +'  AND  A.AUTHORITYS = C.AUTHORITYS';
      Params.ParamByName('EMP_ID').AsString := UserID;
      Params.ParamByName('PRG').AsString := 'CLEARWH';
      Params.ParamByName('FUN').AsString := 'CLEARWH';
      Open;

      if fieldbyname('C_AUTH_SEQ').AsInteger >=1 then
         result:=true
      else
         result:=false;
    end;

     // MessageDlg('Login User Not Found !!', mtError, [mbCancel], 0);
  end;
end;

procedure TFormMAIN.BtnOKClick(Sender: TObject);
begin
      btncheck.Enabled := SetStatusbyAuthority ;
      btnclear.Enabled :=btncheck.Enabled ;
      editidno.Enabled :=btncheck.Enabled ;
      editemp.Enabled := not btncheck.Enabled ;
      maskeditpassword.Enabled :=editemp.Enabled ;
      btnok.Enabled :=editemp.Enabled ;
end;


end.
