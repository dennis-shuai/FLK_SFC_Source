unit uDM;

interface

uses
  SysUtils, Classes, DB, DBClient, MConnect, SConnect, ObjBrkr;

type
  TdmProject = class(TDataModule)
    SocketConnection1: TSocketConnection;
    SimpleObjectBroker1: TSimpleObjectBroker;
    cdsTemp: TClientDataSet;
    cdsProcedure: TClientDataSet;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmProject: TdmProject;

implementation

{$R *.dfm}

end.
