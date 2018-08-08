unit uMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBCtrls, Grids, DBGrids, DBClient, MConnect, SConnect,
  ObjBrkr, StdCtrls, Buttons, ExtCtrls, ComCtrls, Spin, StrUtils,// shellapi,
  Menus, uLang, IniFiles,Comobj,TLHELP32;

type
  TfMainForm = class(TForm)
    ImageAll: TImage;
    sbtnClose: TSpeedButton;
    Image2: TImage;
    LabTitle2: TLabel;
    LabTitle1: TLabel;
    SimpleObjectBroker1: TSimpleObjectBroker;
    SProc: TClientDataSet;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SocketConnection1: TSocketConnection;
    SaveDialog: TSaveDialog;
    QryTemp1: TClientDataSet;
    edtBox: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    cmbQty: TComboBox;
    btnSplit: TButton;
    ds1: TDataSource;
    dbgrd1: TDBGrid;
    Label3: TLabel;
    lblTotalQty: TLabel;
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtBoxChange(Sender: TObject);
    procedure btnSplitClick(Sender: TObject);
  private
    //m_SNDefectLevel: String;
  public
    UpdateUserID: String;
  end;

var
  fMainForm: TfMainForm;


implementation



{$R *.dfm}





procedure TfMainForm.FormShow(Sender: TObject);
Var Bmp : TBitmap;
begin
  Bmp := TBitmap.Create ;
  Bmp.Assign(ImageAll.Picture.Graphic);
  Bmp.PixelFormat := pf32bit;
  ImageAll.Picture.Graphic := Bmp;
  Bmp.Free;
  edtBox.SetFocus;


end;

procedure TfMainForm.Image2Click(Sender: TObject);
begin
   Close;
end;


procedure TfMainForm.edtBoxChange(Sender: TObject);
var i,box_qty:Integer;
begin
  //
   with QryTemp do begin
      Close;
      Params.Clear;
      CommandText :='select box_no,count(*) qty from sajet.g_sn_status where box_no='''+edtBox.Text+''' group by Box_no';
      Open;
      cmbQty.Items.Clear;
      lblTotalQty.Caption :='0';
      box_qty := FieldByName('Qty').AsInteger;
      cmbQty.Style := csDropDownList;
      if box_qty >0 then begin
         for i:=1 to box_qty-1  do
            cmbQty.Items.Add(IntToStr(i));
         btnSplit.Enabled :=True ;
         lblTotalQty.Caption :=IntToStr(box_qty);
      end
      else
        btnSplit.Enabled :=False;
   end;
end;

procedure TfMainForm.btnSplitClick(Sender: TObject);
begin
   with QryTemp do begin
       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       Params.CreateParam(ftString,'Qty',ptInput);
       CommandText :='Update  sajet.g_sn_status set Box_no=Box_No||''1'' where box_no=:Box and Rownum<=:Qty';
       Params.ParamByName('Box').AsString  :=  edtBox.Text ;
       Params.ParamByName('Qty').AsString  := cmbQty.Text;
       Execute;

       Close;
       Params.Clear;
       Params.CreateParam(ftString,'Box',ptInput);
       CommandText :='select box_no,count(*) qty from   sajet.g_sn_status   where box_no like  :box group by box_no ';
       Params.ParamByName('Box').AsString  :=  edtBox.Text +'%';
       Open;

       btnSplit.Enabled :=false;
       lblTotalQty.Caption :='0';
       cmbQty.Items.Clear;
       edtBox.SelectAll;
       edtBox.SetFocus;

   end;
end;

end.
