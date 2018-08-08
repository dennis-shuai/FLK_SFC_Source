unit clsGlobal;

interface
uses clsDataConnect, clsUser, Forms, SysUtils, classes;

type
  TGlobal = class(Tobject)
  public
    objDataConnect: TDataConnect;
    objUser: TclsUser;

    constructor create;
    destructor destroy; override;
  {// for CheckInOut from bar code reader
  // --------------------------------------
  destructor destroy;
  // -------------------------------------- }
  end;
 function GetCurrentDateTime: TDateTime;
var
  ObjGlobal: TGlobal;

  {// for CheckInOut from bar code reader
  FcolGlobalNextLotOp:TStringList;// key is 'bar code reader identification' and element is 'objLotOp'
   }
implementation

{ TForever }

constructor TGlobal.create;
begin
  objDataConnect := TdataConnect.Create;
  objUser := TclsUser.Create;
  objUser.FID := ''; //'A001';
  objUser.FName := ''; //'George';
  {// for CheckInOut from bar code reader
  // --------------------------------------
  FcolGlobalNextLotOp:=TStringList.Create;
  // --------------------------------------  }
end;

destructor TGlobal.destroy;
begin
  objDataConnect.Free;
  objDataConnect := nil;
  objUser.Free;
  objUser := nil;
  inherited Destroy;
end;

function GetCurrentDateTime: TDateTime;
{var
  sql:string;
  FtmpDt:TDtSet;}
begin
  Result := Now;
  {
  Case objGlobal.gDBType of
    0: begin
         sql:='select getDate() as FDate ';
       end;
    1: begin
         sql:='select sysdate as FDate from dual ';
       end;
  end;
  FtmpDt:=objGlobal.objDataConnect.DataQuery(sql);
  Result:=FtmpDt.FieldByName('FDate').AsDateTime ;
  FtmpDt.Free;
  FtmpDt:=nil;
  }
end;
{destructor TGlobal.Destroy();
var
i:integer;
begin
  {// for CheckInOut from bar code reader
  // --------------------------------------
  for i:=0 to FcolGlobalNextLotOp.count-1 do
  begin
     FcolGlobalNextLotOp.Delete(0);
  end;
  FcolGlobalNextLotOp.free;
  // --------------------------------------
end;}

end.
