{******************************************************************************}
{  Unit description:                                                           }
{  Developer:                        Date:                                     }
{  Modifier:  cgy                    Date:      2002/3/8                       }
{  Modifier:  Kevin                  Date:      2003/2/26                      }
{         Copyright(C)  SCM , All right reserved                               }
{******************************************************************************}
unit clsDataConnect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, Forms,
  StdCtrls, ADODB, Inifiles, clsDbInterface, clsConnection, clsDtSet;


type
  TdataConnect = class(Tobject)
    ObjConnection: TConnection;
    constructor Create();
    procedure DataConnection;
    procedure FirstDataConnection;
    procedure DataAdd(DBInterface: IDBInterface; const obj: TObject);
    procedure DataEdit(DBInterface: IDBInterface; const obj: TObject);
    procedure DataDelete(DBInterface: IDBInterface; const obj: TObject);
    function getTrimDataSet(DBInterface: IDBInterface): TADODataSet;
    function DataQuery(SQLStr: string): TDtSet;
  end;

implementation

uses uPublicFunction, clsGlobal, clsMessage;

{ TdataConnect }

constructor TdataConnect.Create;
var
  loadtofile: Tinifile;
  lConstr: string;
begin
  loadtofile := tinifile.create(ExtractFilePath(Application.ExeName) + 'Ini\adoconnection.ini');
  (*   載入連接字串   *)
  ObjConnection := TConnection.Create(nil);
  ObjConnection.LoginPrompt := false;
  lConStr := loadtofile.Readstring('adoconnection', 'connectionstring', '');
  if lConStr <> '' then
    ObjConnection.ConnectionString := ConnectionString_Crypt(lConStr, 1) //DeCrypt
  else
  begin
    ObjConnection.Free;
    FirstDataConnection;
  end;
end;

procedure TdataConnect.DataAdd(DBInterface: IDBInterface; const obj: TObject);
begin
  DBInterface.Add(obj);
end;

procedure TdataConnect.DataEdit(DBInterface: IDBInterface; const obj: TObject);
begin
  DBInterface.Edit(obj);
end;

procedure TdataConnect.DataDelete(DBInterface: IDBInterface; const obj: TObject);
begin
  DBInterface.Delete(obj);
end;

procedure TdataConnect.Dataconnection;
var
  Constr: TLabel;
  savetofile: TIniFile;
  loadtofile: Tinifile;
  lConStr: string;
begin
  if ObjConnection.Connected = True then begin
    ObjConnection.Close;
  end;
  ObjConnection := TConnection.Create(nil);
  Constr := TLabel.Create(nil);
  ObjConnection.LoginPrompt := false;
  Constr.Caption := PromptDataSource(Application.Handle, Constr.Caption);
  ObjConnection.ConnectionString := Constr.Caption;
  if ObjConnection.ConnectionString <> '' then begin
    try
      ObjConnection.Open;
         (*   Save the ADOconnectionstriong to file *)
      savetofile := TIniFile.create(ExtractFilePath(Application.ExeName) + 'Ini\adoconnection.ini');
      savetofile.WriteString('adoconnection', 'connectionstring',
        connectionstring_crypt(Constr.Caption, 0)); //EnCrypt
    except
      MessageDlg('與資料庫連線失敗﹗', mtError, [mbYES], 0);
    end;
  end
  else begin
    MessageDlg('請提供正確的資料庫連接字串﹗', mtError, [mbYES], 0);
    loadtofile := tinifile.create(ExtractFilePath(Application.ExeName) + 'Ini\adoconnection.ini');
    lConStr := loadtofile.Readstring('adoconnection', 'connectionstring', '');
    ObjConnection.ConnectionString := ConnectionString_Crypt(lConStr, 1);
    ObjConnection.Open;
  end;
end;

function TdataConnect.DataQuery(SQLStr: string): TDtSet;
var
  ObjDataSet: TDtSet;
begin
  ObjDataSet := TDtSet.Create(nil);
  objDataSet.Connection := objConnection;
  ObjDataSet.CommandText := SQLStr;
  ObjDataSet.Open;
  Result := ObjDataSet;
end;

procedure TdataConnect.FirstDataConnection;
var
  Constr: TLabel;
  savetofile: TIniFile;
begin
  ObjConnection := TConnection.Create(nil);
  Constr := TLabel.Create(nil);
  ObjConnection.LoginPrompt := false;
  Constr.Caption := PromptDataSource(Application.Handle, Constr.Caption);
  ObjConnection.ConnectionString := Constr.Caption;
  if ObjConnection.ConnectionString <> '' then
  begin
    try
      ObjConnection.Open;
         (*   Save the ADOconnectionstriong to file *)
      savetofile := TIniFile.create(ExtractFilePath(Application.ExeName) + 'Ini\adoconnection.ini');
      savetofile.WriteString('adoconnection', 'connectionstring',
        ConnectionString_Crypt(Constr.Caption, 0)); //EnCrypt
    except
      MessageDlg('與資料庫連線失敗﹗', mtError, [mbYES], 0);
    end;
  end
  else
    Application.Terminate;
end;

function TdataConnect.getTrimDataSet(
  DBInterface: IDBInterface): TADODataSet;
begin
  Result := DBInterface.getTrimData();
end;

end.
