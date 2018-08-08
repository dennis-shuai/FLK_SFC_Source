unit clsDbInterface;

interface
uses ADODb;

type
  IDBInterface=interface(IInterface)
  procedure Add(const obj:TObject);
  procedure Edit(const obj:TObject);
  procedure Delete(const obj:TObject);
  function getTrimData:TADODataSet;
end;

var
  DBInterface:IDBInterface;
  
implementation



end.
