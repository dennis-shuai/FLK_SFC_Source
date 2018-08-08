unit uItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, DBClient, StdCtrls;

type
  TfItem = class(TForm)
    LVItem: TListView;
    QryTemp: TClientDataSet;
    procedure LVItemDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    g_sItemFilter,g_sLocation:string;
    procedure ShowListView;
    { Public declarations }
  end;

var
  fItem: TfItem;

implementation

uses uRepair, uData;

{$R *.dfm}

procedure TfItem.ShowListView;
var i:integer;
begin
   //填值
   LvItem.Clear;
   for i:= 0 to (fRepair.g_tsItem.Count div g_iCol)-1 do
   begin
     if (g_sItemFilter='') or (Copy(fRepair.g_tsItem.Strings[i*g_iCol+1],1,length(g_sItemFilter))= g_sItemFilter) then
     begin
       //若有輸入則檢查location
       if (g_sLocation = '') or (g_sLocation = fRepair.g_tsItem.Strings[i*g_iCol+4]) then
       begin
         with LvItem.Items.Add do
         begin
           Caption:= fRepair.g_tsItem.Strings[i * g_iCol+1];       //Part No
           SubItems.Add(fRepair.g_tsItem.Strings[i * g_iCol+2]);   //Version
           SubItems.Add(fRepair.g_tsItem.Strings[i * g_iCol+3]);   //Spec1
           SubItems.Add(fRepair.g_tsItem.Strings[i * g_iCol+4]);   //Location
           SubItems.Add(fRepair.g_tsItem.Strings[i * g_iCol]);     //Part_Id
         end;
       end;
     end;
   end;
end;

procedure TfItem.LVItemDblClick(Sender: TObject);
begin
  ModalResult:= mrOK;
end;

end.
