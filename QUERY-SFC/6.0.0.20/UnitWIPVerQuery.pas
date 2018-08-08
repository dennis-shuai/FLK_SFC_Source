unit UnitWIPVerQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, DBClient;

type
  TFormWIPverQuery = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Editserialnumber: TEdit;
    Label3: TLabel;
    Edititempartsn: TEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    DBGridpcba: TDBGrid;
    DBGridhdd: TDBGrid;
    BtnCLOSE: TButton;
    ClientDataSetPCBA: TClientDataSet;
    DSPCBA: TDataSource;
    ClientDataSetHDD: TClientDataSet;
    DSHDD: TDataSource;
    DSNULL: TDataSource;
    procedure BtnCLOSEClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cleardata ;
    procedure EditserialnumberKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdititempartsnKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWIPverQuery: TFormWIPverQuery;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormWIPverQueRY.cleardata;
begin
    editserialnumber.clear;
    editserialnumber.SetFocus ;
    edititempartsn.Clear ;
    dbgridpcba.DataSource :=dsnull;
    dbgridhdd.DataSource :=dsnull;

end;

procedure TFormWIPverQuery.BtnCLOSEClick(Sender: TObject);
begin
   close;
end;

procedure TFormWIPverQuery.FormShow(Sender: TObject);
begin
   clientdatasetPCBA.RemoteServer :=formmain.socketconnection1;
   clientdatasetPCBA.ProviderName :=formmain.Clientdataset1.ProviderName ;
   clientdatasetHDD.RemoteServer :=formmain.socketconnection1;
   clientdatasetHDD.ProviderName :=formmain.Clientdataset1.ProviderName ;

   cleardata;

end;

procedure TFormWIPverQuery.EditserialnumberKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if editserialnumber.Text <>'' then
      if key=13 then
          begin
              with clientdatasetpcba do
                 begin
                     close;
                     commandtext:='select work_order,serial_number,version from sajet.g_sn_status '
                               + ' where serial_number=:serial_number' ;
                     params.ParamByName('serial_number').AsString :=uppercase(trim(editserialnumber.Text ));
                     open;

                     if recordcount>0 then
                        begin
                            editserialnumber.SelectAll ;
                            dbgridpcba.DataSource :=dspcba;
                            with clientdatasethdd do
                               begin
                                  close;
                                  commandtext:='select work_order,item_part_sn,version '
                                      +' from sajet.g_sn_keyparts where serial_number=:serial_number' ;
                                  params.ParamByName('serial_number').AsString :=uppercase(trim(editserialnumber.Text ));
                                  open;

                                  dbgridhdd.DataSource:=dshdd;
                               end;
                        end
                        else
                          begin
                             showmessage('Not find the PCBA SN!') ;
                             cleardata;
                             exit;
                          end;
                 end;
          end;
end;

procedure TFormWIPverQuery.EdititempartsnKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if edititempartsn.Text <>'' then
      if key=13 then
          begin
              with clientdatasethdd do
                 begin
                     close;
                     commandtext:='select work_order,serial_number,item_part_sn,version from sajet.g_sn_keyparts '
                               + ' where item_part_sn=:item_part_sn' ;
                     params.ParamByName('item_part_sn').AsString :=uppercase(trim(edititempartsn.Text ));
                     open;

                     if recordcount>0 then
                        begin
                            edititempartsn.SelectAll ;
                            dbgridhdd.DataSource :=dshdd;
                            editserialnumber.Text := fields[1].AsString ;
                            with clientdatasetpcba do
                               begin
                                  close;
                                  commandtext:='select work_order,serial_number,version '
                                      +' from sajet.g_sn_status where serial_number=:serial_number' ;
                                  params.ParamByName('serial_number').AsString :=uppercase(trim(editserialnumber.Text ));
                                  open;

                                  dbgridpcba.DataSource:=dspcba;
                               end;
                        end
                        else
                          begin
                             showmessage('Not find the HDD SN!') ;
                             cleardata;
                             edititempartsn.SetFocus ;
                             exit;
                          end;
                 end;
          end;
end;

end.
