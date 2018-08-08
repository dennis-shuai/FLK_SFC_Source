unit uformMoData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, DBClient, Buttons, StdCtrls,BmpRgn;

type
  TformMoData = class(TForm)
    QryData: TClientDataSet;
    Imagemain: TImage;
    Image1: TImage;
    Image5: TImage;
    Label3: TLabel;
    Label4: TLabel;
    sbtnCancel: TSpeedButton;
    sbtnSave: TSpeedButton;
    lablStation: TLabel;
    editProgVer: TEdit;
    Label1: TLabel;
    editPCBBoard: TEdit;
    Label2: TLabel;
    editProgram: TEdit;
    Label8: TLabel;
    lablMO: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure sbtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetTheRegion;
    
  end;

var
  formMoData: TformMoData;

implementation

uses uformMain;

{$R *.dfm}
procedure TformMoData.SetTheRegion;
var HR: HRGN;
begin
   HR := BmpToRegion(Self, Imagemain.Picture.Bitmap);
   SetWindowRgn(handle, HR, true);
   Invalidate;
end;

procedure TformMoData.FormCreate(Sender: TObject);
begin
   SetTheRegion;
end;

procedure TformMoData.sbtnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TformMoData.FormShow(Sender: TObject);
begin
  with qryData do
  begin
    try
      close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      commandText :=' select * from smt.g_wo_base  '
                  +' where work_order =:work_order ';
      params.paramByName('Work_order').AsString := lablMo.Caption;
      open;
      if not eof then
      begin
        editProgram.Text := FieldByName('PROGRAM_NAME').AsString;
        editProgVer.Text := FieldByName('PROGRAM_VER').AsString;
        editPCBBoard.Text := FieldByName('PCB_BOARD').AsString;
      end;
    finally
      close;
    end;
  end;
end;

procedure TformMoData.sbtnSaveClick(Sender: TObject);
begin
  editProgram.Text := trim(editProgram.Text);
  editProgVer.Text := trim(editProgVer.Text);
  editPCBBoard.Text := trim(editPCBBoard.Text);
  with qryData do
  begin
    try
      close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      commandText :=' delete smt.g_wo_base '
                  +' where work_order =:work_order ';
      params.paramByName('Work_order').AsString := lablMo.Caption;
      execute;

      close;
      Params.Clear;
      Params.CreateParam(ftString, 'work_order', ptInput);
      Params.CreateParam(ftString, 'PROGRAM_NAME', ptInput);
      Params.CreateParam(ftString, 'PROGRAM_VER', ptInput);
      Params.CreateParam(ftString, 'PCB_BOARD', ptInput);
      Params.CreateParam(ftString, 'EMP_NO', ptInput);
      commandText :=' insert into smt.g_wo_base '
                   +' (work_order,program_name,program_ver,pcb_board,emp_no,date_time )'
                   +' VALUES (:work_order,:program_name,:program_ver,:pcb_board,:emp_no,sysdate )';
      params.ParamByName('work_order').AsString :=lablMo.Caption;
      params.ParamByName('PROGRAM_NAME').AsString :=editProgram.Text;
      params.ParamByName('PROGRAM_VER').AsString :=editProgVer.Text;
      params.ParamByName('PCB_BOARD').AsString :=editPCBBoard.Text;
      params.ParamByName('EMP_NO').AsString :=formMain.UpdateUserID;
      execute;
      MessageDlg('Save OK!',mtInformation,[mbOK],0);
      modalresult :=mrOK;
    finally
      close;
    end;
  end;
end;

end.
