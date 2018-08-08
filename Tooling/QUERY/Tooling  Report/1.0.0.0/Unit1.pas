unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Grids, DBGrids, DBGrid1, ExtCtrls, StdCtrls,
  Buttons;

type
  TForm1 = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    DBGrid11: TDBGrid1;
    DataSource1: TDataSource;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    lbl1: TLabel;
    cbb1: TComboBox;
    lbl2: TLabel;
    lbl3: TLabel;
    cbb2: TComboBox;
    lbl4: TLabel;
    cbb3: TComboBox;
    lbl5: TLabel;
    cbb4: TComboBox;
    cbb5: TComboBox;
    lbl7: TLabel;
    cbb6: TComboBox;
    btnOK: TSpeedButton;
    img1: TImage;
    img2: TImage;
    btn1: TSpeedButton;
    tmr1: TTimer;
    procedure btnOKClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure cbb4Select(Sender: TObject);
   
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.btnOKClick(Sender: TObject);
var SQLtext :string;
begin
    with Form1.QryTemp   do
    begin
       Close;
       Params.Clear;
       if   cbb1.Text <>'' then
          Params.CreateParam(ftString,'Tooling_Name',ptInput);
       if cbb2.Text <> '' then
          Params.CreateParam(ftString,'DEPT',ptInput);
       if cbb3.Text <> '' then
          Params.CreateParam(ftString,'EMP',ptInput);
       if cbb4.Text <> '' then
          Params.CreateParam(ftString,'WAREHOUSE',ptInput);
       if cbb5.Text <> '' then
          Params.CreateParam(ftString,'LOCATE',ptInput);
       if cbb6.Text <> '' then
          Params.CreateParam(ftString,'STATUS',ptInput);

       SQLtext := ' select  Tooling_name, Enabled,Machine_used,WareHouse_Name,Locate_Name,Dept_Name,Emp_Name ,count(*) as Qty from ('
                    + ' select A.TOOLING_NAME,A.TOOLING_NO,b.Tooling_SN,B.eNABLED,c.Machine_NO,C.ASSET_NO,C.MACHINE_TYPE,'
                    + ' D.EMP_NAME,E.LOCATE_NAME,F.WAREHOUSE_NAME,G.DEPT_NAME,C.MACHINE_USED,'
                    + ' C.MACHINE_MEMO,C.INCOMING_DATE from sajet.sys_tooling a,SAJET.SYS_TOOLING_SN b,'
                    + ' SAJET.G_TOOLING_MATERIAL c, SAJET.SYS_EMP d,SAJET.SYS_LOCATE e,SAJET.SYS_WAREHOUSE f,'
                    + ' SAJET.SYS_DEPT g where A.TOOLING_ID =B.TOOLING_ID and C.TOOLING_SN_ID =B.TOOLING_SN_ID and '
                    + ' C.WAREHOUSE_ID =F.WAREHOUSE_ID and C.KEEPER_USERID =D.EMP_ID and C.LOCATE_ID =E.LOCATE_ID '
                    + ' and C.MONITOR_DEPT =G.DEPT_ID ';
       if cbb1.Text <> '' then
          SQLtext := SQLtext + ' and A.TOOLING_NAME =:Tooling_Name ' ;
       if cbb2.Text <> '' then
          SQLtext  := SQLtext +' and g.dept_Name =:DEPT ';
       if cbb3.Text <> '' then
          SQLtext := SQLtext +' and  d.EMP_NAME =:EMP ';
       if cbb4.Text <> '' then
          SQLtext := SQLtext +' and  f.WareHouse_Name =:WAREHOUSE ';
       if cbb5.Text <> '' then
          SQLtext := SQLtext +' and e.Locate_Name =:LOCATE';
       if cbb6.Text <> '' then
          SQLtext := SQLtext +' and c.Machine_Used =:STATUS';

       SQLtext :=SQLtext + ') group by (Tooling_name, Enabled,Machine_used,WareHouse_Name,'
                   + ' Locate_Name,Dept_Name,Emp_Name)' ;
       CommandText :=SQLtext;

       if   cbb1.Text <>'' then
          Params.ParamByName('Tooling_Name').AsString :=cbb1.Text;
       if cbb2.Text <> '' then
          Params.ParamByName('DEPT').AsString :=cbb2.Text;
       if cbb3.Text <> '' then
          Params.ParamByName('EMP').AsString :=cbb3.Text;
       if cbb4.Text <> '' then
          Params.ParamByName('WAREHOUSE').AsString :=cbb4.Text;
       if cbb5.Text <> '' then
          Params.ParamByName('LOCATE').AsString :=cbb5.Text;
       if cbb6.Text <> '' then
          Params.ParamByName('STATUS').AsString :=cbb6.Text;
       Open;

    end;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var i :Integer;
begin
   with Form1.QryData do
   begin
     Close;
     Params.Clear;
     CommandText := 'Select  distinct(a.Tooling_Name) from '
                 +  ' sajet.sys_tooling a,SAJET.SYS_TOOLING_SN b,SAJET.G_TOOLING_MATERIAL c'
                 +  ' where A.TOOLING_ID =B.TOOLING_ID and C.TOOLING_SN_ID =B.TOOLING_SN_ID  ' ;

     Open;
     First;
     cbb1.Clear;
     cbb1.Items.Clear;
     cbb1.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb1.Items.Add(FieldByName('TOOLING_NAME').AsString);
        Next;
     end;
     //---------
     Close;
     Params.Clear;
     CommandText := 'Select  distinct(b.DEPT_NAME) from sajet.G_TOOLING_Material a ,sajet.SYS_DEPT b '
                 + ' where a.Monitor_DEPT=b.DEPT_ID ';
     Open;
     First;
     cbb2.Clear;
     cbb2.Items.Clear;
     cbb2.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb2.Items.Add(FieldByName('DEPT_NAME').AsString);
        Next;
     end;
     //
     Close;
     Params.Clear;
     CommandText := ' select distinct EMP_NAME from SAJET.SYS_EMP a ,sajet.g_Tooling_Material b '
                   +' where A.EMP_ID =B.KEEPER_USERID' ;
     Open;
     First;
     cbb3.Clear;
     cbb3.Items.Clear;
     cbb3.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb3.Items.Add(FieldByName('EMP_NAME').AsString);
        Next;
     end;

      //
     Close;
     Params.Clear;
     CommandText := ' select distinct WAreHouse_NAME from SAJET.SYS_WAREHOUSE a ,sajet.g_Tooling_Material b '
                  + ' where A.WAREHOUSE_ID =B.WAREHOUSE_ID ';
     Open;
     First;
     cbb4.Clear;
     cbb4.Items.Clear;
     cbb4.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb4.Items.Add(FieldByName('WAreHouse_NAME').AsString);
        Next;
     end;

     Close;
     Params.Clear;
     CommandText := ' select distinct MACHINE_USED from sajet.g_Tooling_Material  '  ;

     Open;
     First;
     cbb6.Clear;
     cbb6.Items.Clear;
     cbb6.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb6.Items.Add(FieldByName('MACHINE_USED').AsString);
        Next;
     end;



   end;
   tmr1.Enabled :=False;
end;

procedure TForm1.cbb4Select(Sender: TObject);
var i:Integer;
begin
    with Form1.QryData do
    begin
     Close;
     Params.Clear;
     Params.CreateParam(ftString,'WARE_HOUSE',ptInput);
     CommandText := ' select distinct(A.LOCATE_NAME)  from SAJET.SYS_LOCATE a, SAJET.SYS_WAREHOUSE b '
                 +  ' where A.WAREHOUSE_ID =B.WAREHOUSE_ID and B.WAREHOUSE_NAME =:WARE_HOUSE ';
     Params.ParamByName('WARE_HOUSE').AsString := cbb4.Text;
     Open;
     First;
     cbb5.Clear;
     cbb5.Items.Clear;
     cbb5.Items.Add('');
     for  i:=0 to RecordCount-1 do
     begin
        cbb5.Items.Add(FieldByName('Locate_NAME').AsString);
        Next;
     end;
    end  ;
end;

end.
