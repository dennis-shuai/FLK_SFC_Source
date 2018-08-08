unit uAddPN;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, StdCtrls;

type
  TAddPNForm = class(TForm)
    LabTitle1: TLabel;
    LabTitle2: TLabel;
    Label9: TLabel;
    edtSubPN: TEdit;
    edtSpec1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    btnAdd: TSpeedButton;
    Image1: TImage;
    SpeedButton1: TSpeedButton;
    Image2: TImage;
    SpeedButton2: TSpeedButton;
    Image3: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddPNForm: TAddPNForm;

implementation

{$R *.dfm}

end.
