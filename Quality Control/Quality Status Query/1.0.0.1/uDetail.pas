unit uDetail;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons ,ExtCtrls, ComCtrls, DB, DBClient, MConnect, ObjBrkr, SConnect,
   Grids, Mask,ComObj,Tlhelp32,  IniFiles, DBGrids,DateUtils;

type
  TfDetail = class(TForm)
    pnl1: TPanel;
    ImageAll: TImage;
    QryData: TClientDataSet;
    QryTemp: TClientDataSet;
    SProc: TClientDataSet;
    lblLabTitle1: TLabel;
    lblLabTitle2: TLabel;
    DataSource1: TDataSource;
    SaveDialog1: TSaveDialog;
    QryDefect: TClientDataSet;
    DataSource2: TDataSource;
    Label1: TLabel;
    edtPallet: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    lblNCount: TLabel;
    lblDCount: TLabel;
    procedure edtPalletKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    
  private
    { Private declarations }
     //m_CodeSoft :TCodeSoft;
  public
    { Public declarations }
    sStartTime, sEndTime, sDStartTime, sDEndTime,sTime1,sTime2 :string;
    function QueryQC( QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;

  end;

var
  fDetail: TfDetail;
  mWO,mPartID,mPartNO,mCustPartNO:string;


implementation

{$R *.dfm}
uses uDllform,DllInit;




function TfDetail.QueryQC(QryTemp1:TClientDataset;sStartTime:String;sEndTime:String):boolean;
begin

end;

procedure TfDetail.edtPalletKeyPress(Sender: TObject; var Key: Char);
var DefectCount,AllCount:Integer;
begin
   if key <>#13 then exit;
   DefectCount:=0;
   AllCount :=0;
   with QryTemp do begin
       close;
       params.Clear;
       params.CreateParam(ftstring,'Pallet',ptinput);
       commandtext := 'select Count(*) AllCount from sajet.g_sn_status '+
                      ' where Pallet_no =:Pallet';
       params.ParamByName('Pallet').AsString :=edtPallet.Text;
       open;
       AllCount := fieldByname('AllCount').AsInteger;
       if  AllCount =0 then begin
           MessageDlg('No Pallet No',mterror,[mbok],0);
           edtPallet.SetFocus;
           edtPallet.Text :='';
           exit;
       end  else


       close;
       params.Clear;
       params.CreateParam(ftstring,'Pallet',ptinput);
       commandtext := 'select DISTINSCT SERIAL_NUMBER  from sajet.g_sn_travel a,sajet.g_sn_status b '+
                      ' where a.serial_number=b.serial_number and a.work_order = '+
                      ' b.WORK_ORDER and a.Process_id =100201 and b.Pallet_no =:Pallet';
       params.ParamByName('Pallet').AsString :=edtPallet.Text;
       open;

       if IsEmpty then DefectCount:=0
       else
        DefectCount := RecordCount;
       lblNCount.Caption :=IntToStr(AllCOunt-DefectCount);
       lblDCount.Caption := IntToStr(DefectCount);
       edtPallet.SetFocus;
       edtPallet.Text :='';
   end;
end;

procedure TfDetail.FormShow(Sender: TObject);
begin
   edtPallet.SetFocus;
end;

end.
