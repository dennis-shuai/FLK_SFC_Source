unit uSI;

interface

uses SysUtils, Classes,Stdctrls,Graphics,Extctrls, DB, Inifiles, Unit1, VarWIPUnit;


procedure TransSIA;   // SI Header
procedure TransSIB;   // SI Body
Function CheckSIExist(sSI : String; var sSIId : String) : Boolean;
Function GetMaxSIID : String;
Function CheckSIPNExist(sSIId,sPartID : String) : Boolean;

implementation

Function CheckSIExist(sSI : String; var sSIId : String) : Boolean;
Begin
  Result := False;
  sSIId := '0';
  With Transfer.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SHIPPING_NO', ptInput);
    CommandText := 'Select SHIPPING_ID   '+
                   'From SAJET.G_SHIPPING_NO  '+
                   'Where SHIPPING_NO  = :SHIPPING_NO  ';
    Params.ParamByName('SHIPPING_NO').AsString := sSI;
    Open;
    If RecordCount > 0 Then
    begin
      sSIId := Fieldbyname('SHIPPING_ID').AsSTring;
      Result := True;
    end;
    Close;
  end;
end;

Function GetMaxSIID : String;
begin
  With Transfer.QryTemp do
  begin
    Close;
    Params.Clear;
    CommandText := 'Select RPAD(NVL(PARAM_VALUE,''1''),2,''0'') || TO_CHAR(SYSDATE,''YYMMDD'') || ''001'' SHIPPINGID '+
                   'From SAJET.SYS_BASE '+
                   'Where PARAM_NAME = ''DBID'' ' ;
    Open;
    Result := Fieldbyname('SHIPPINGID').AsString;

    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SHIPPINGID', ptInput);
    CommandText := 'Select NVL(Max(SHIPPING_ID),0) + 1 SHIPPINGID '+
                   'From SAJET.G_SHIPPING_NO '+
                   'Where SHIPPING_ID >= :SHIPPINGID ' ;
    Params.ParamByName('SHIPPINGID').AsString := Result;
    Open;
    If Fieldbyname('SHIPPINGID').AsString <> '1' Then
      Result := Fieldbyname('SHIPPINGID').AsString;
    Close;
  end;
end;

Function CheckSIPNExist(sSIId,sPartID : String) : Boolean;
Begin
  Result := False;
  With Transfer.QryTemp do
  begin
    Close;
    Params.Clear;
    Params.CreateParam(ftString	,'SHIPPING_ID', ptInput);
    Params.CreateParam(ftString	,'PART_ID', ptInput);
    CommandText := 'Select SHIPPING_ID   '+
                   'From SAJET.G_SHIPPING_SO_DETAIL  '+
                   'Where SHIPPING_ID = :SHIPPING_ID and '+
                         'PART_ID = :PART_ID ';
    Params.ParamByName('SHIPPING_ID').AsString := sSIId;
    Params.ParamByName('PART_ID').AsString := sPartID;
    Open;
    If RecordCount > 0 Then
      Result := True;
    Close;
  end;
end;

procedure TransSIA;
var mS,sSIID,sPartId : string;
  sr : TSearchRec; vFile : Textfile;
  mI : Integer;

  sFC,      // 廠別             1     FACTORY_ID
  sSI,      // SI(出貨單號)     1     SHIPPING_NO
  sSO,      // SO(訂單號碼)     1     SALES_ORDER
  sCUSTREV, // 帳款客戶編號     1
  sCUSTSED, // 送貨客戶編號     1
  sSHIP : String; // 出貨港口         2     SHIP_TO
begin
  mI := 0;
  If FindFirst(downloadPath+'SIA_*',faAnyFile, sr) = 0 then
  begin
    Transfer.QryInst.Close;
    Transfer.QryInst.CommandText := 'Insert Into SAJET.G_SHIPPING_NO '+
                             '(SHIPPING_ID, SHIPPING_NO, '+
                              'PDLINE_ID, STAGE_ID , PROCESS_ID ,TERMINAL_ID, UPDATE_USERID,'+
                              'FACTORY_ID ,SALES_ORDER) '+
                           'Values  '+
                             '(:SHIPPING_ID, :SHIPPING_NO,'+
                              '0, 0, 0, 0, 0,'+
                              ':FACTORY_ID, :SALES_ORDER) ';
    while True do
    begin
      // Open File
      AssignFile(vFile,DownLoadPath+sr.Name);
      Reset(vFile);
      while not Eof(vFile) do
      begin
        Readln(vFile,mS);
        sFC      := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sSI      := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sSO      := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sCUSTREV := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sCUSTSED := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sSHIP    := Trim(mS); // Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        Try
          If FactoryName <> sFC Then
          begin
            FactoryName := sFC;
            If not Transfer.CheckFactoryExist Then
            begin
              FactoryId := Transfer.GetMaxFactoryID;
              // Append;
              With QryTemp do
              begin
                Close;
                Params.Clear;
                Params.CreateParam(ftString	,'FCID', ptInput);
                Params.CreateParam(ftString	,'FCCODE', ptInput);
                Params.CreateParam(ftString	,'FCNAME', ptInput);
                CommandText := 'Insert Into SAJET.SYS_FACTORY '+
                                 '(FACTORY_ID, FACTORY_CODE, FACTORY_NAME ) '+
                               'Vaules (:FCID, :FCCODE, :FCNAME )';
                Params.ParamByName('FCID').AsString := FactoryID;
                Params.ParamByName('FCCODE').AsString := FactoryName;
                Params.ParamByName('FCNAME').AsString := FactoryName;
                Execute;
              end;
              CopyToFcHistory(FactoryId);
            end;
          end;

          If not CheckPNExist(sPARTNO,sPartId) then
          begin
            // Log;
            LogError(' Part No Not Found - ' + sr.Name ,'SIA');
            Continue;
          end;

          IF not CheckSIExist(sSI,sSIId) then
          begin
            sSIId := GetMaxSIID;
            With QryInst do
            begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString	,'SHIPPING_ID', ptInput);
              Params.CreateParam(ftString	,'SHIPPING_NO', ptInput);
              Params.CreateParam(ftString	,'FACTORY_ID', ptInput);
              Params.CreateParam(ftString	,'SALES_ORDER', ptInput);

              Params.ParamByName('SHIPPING_ID').AsString := sSIId;
              Params.ParamByName('SHIPPING_NO').AsString := sSI;
              Params.ParamByName('FACTORY_ID').AsString := FactoryID;
              Params.ParamByName('SALES_ORDER').AsString := sSO;
              Execute;
            end;
          end;
        Except
          LogError(sSIID + ' , ' + sPartNo + ' - ' + sr.Name ,'SIA');
        end;
        Inc(mI);
        LabCnt.Caption := InttoStr(mI);
        LabCnt.Refresh;
      end;
      Closefile(vFile);

      Try
        Movefile(pChar(DownLoadPath+sr.Name),pChar(BackupPath+sr.Name)) ;
      Except
        LogError(' Move File Faile - ' + sr.Name ,'SIA');
      End;
      If FindNext(sr)<>0 Then
        Break;
    end;
    FindClose(sr);
  end;
  FindClose(sr);
end;

procedure TransSIB;
var mS,sSIID,sPartId : string;
  sr : TSearchRec; vFile : Textfile;
  mI : Integer;

  sFC,      // 廠別             1     FACTORY_ID
  sSI,      // SI(出貨單號)     1     SHIPPING_NO
  sPARTNO,  // 成品料號         2     PART_ID
  fACTQTY,  // 實際出貨數量
  fPLANQTY : String; // 預計出貨數量 2   QTY
begin
  mI := 0;
  If FindFirst(editLocal.Text+'SIB_*',faAnyFile, sr) = 0 then
  begin
    Transfer.QryInst.Close;
    Transfer.QryInst.CommandText := 'Insert Into SAJET.G_SHIPPING_SO_DETAIL  '+
                             '(SHIPPING_ID, PART_ID, QTY, UPDATE_USERID) '+
                           'Values  '+
                             '(:SHIPPING_ID, :PART_ID, :QTY, 0) ';}
    Transfer.QryUpdate.Close;
    Transfer.QryUpdate.CommandText := 'Update SAJET.G_SHIPPING_SO_DETAIL '+
                             'Set QTY = :QTY '+
                             'Where SHIPPING_ID = :SHIPPING_ID and '+
                                   'PART_ID = :PART_ID ';
    while True do
    begin
      // Open File
      AssignFile(vFile,DownLoadPath+sr.Name);
      Reset(vFile);
      while not Eof(vFile) do
      begin
        Readln(vFile,mS);
        sFC      := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sSI      := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        sPARTNO  := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        fACTQTY  := Copy(mS,1,POS(sDot,mS)-1); mS := Copy(mS,POS(sDot,mS)+1,Length(mS)-POS(sDot,mS));
        fPLANQTY := Trim(mS);
{ sFC,      // 廠別             1     FACTORY_ID
  sSI,      // SI(出貨單號)     1     SHIPPING_NO
  sSO,      // SO(訂單號碼)     2     SALES_ORDER
  sSHIP,    // 出貨港口         2     SHIP_TO
  sPARTNO,  // 成品料號         2     PART_ID
  fACTQTY,  // 實際出貨數量
  fPLANQTY : String; // 預計出貨數量 2   QTY }
        Try
          If FactoryName <> sFC Then
          begin
            FactoryName := sFC;
            If not CheckFactoryExist Then
            begin
              FactoryId := GetMaxFactoryID;
              // Append;
              With QryTemp do
              begin
                Close;
                Params.Clear;
                Params.CreateParam(ftString	,'FCID', ptInput);
                Params.CreateParam(ftString	,'FCCODE', ptInput);
                Params.CreateParam(ftString	,'FCNAME', ptInput);
                CommandText := 'Insert Into SAJET.SYS_FACTORY '+
                                 '(FACTORY_ID, FACTORY_CODE, FACTORY_NAME ) '+
                               'Vaules (:FCID, :FCCODE, :FCNAME )';
                Params.ParamByName('FCID').AsString := FactoryID;
                Params.ParamByName('FCCODE').AsString := FactoryName;
                Params.ParamByName('FCNAME').AsString := FactoryName;
                Execute;
              end;
              CopyToFcHistory(FactoryId);
            end;
          end;

          If not CheckPNExist(sPARTNO,sPartId) then
          begin
            // Log;
            LogError(' Part No Not Found - ' + sr.Name ,'SIB');
            Continue;
          end;

          IF not CheckSIExist(sSI,sSIId) then
          begin
            LogError(sSI + ' SI Not Found - ' + sr.Name ,'SIB');
            Continue;
          end;

          IF not CheckSIPNExist(sSIId,sPartId) then
          begin
            With Transfer.QryInst do
            begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString	,'SHIPPING_ID', ptInput);
              Params.CreateParam(ftString	,'PART_ID', ptInput);
              Params.CreateParam(ftString	,'QTY', ptInput);
              Params.ParamByName('SHIPPING_ID').AsString := sSIId;
              Params.ParamByName('PART_ID').AsString := sPartID;
              Params.ParamByName('QTY').AsString := fPLANQTY;
              Execute;
            end;
          end else
          begin
            With QryUpdate do
            begin
              Close;
              Params.Clear;
              Params.CreateParam(ftString	,'QTY', ptInput);
              Params.CreateParam(ftString	,'SHIPPING_ID', ptInput);
              Params.CreateParam(ftString	,'PART_ID', ptInput);
              Params.ParamByName('QTY').AsString := fPLANQTY;
              Params.ParamByName('SHIPPING_ID').AsString := sSIId;
              Params.ParamByName('PART_ID').AsString := sPartID;
              Execute;
            end;
          end;}
        Except
          LogError(sSIID + ' , ' + sPartNo + ' - ' + sr.Name ,'SIB');
        end;
        Inc(mI);
        LabCnt.Caption := InttoStr(mI);
        LabCnt.Refresh;
      end;
      Closefile(vFile);

      Try
        Movefile(pChar(DownLoadPath+sr.Name),pChar(BackupPath+sr.Name)) ;
      Except
        LogError(' Move File Faile - ' + sr.Name ,'SIB');
      End;
      If FindNext(sr)<>0 Then
        Break;
    end;
    FindClose(sr);
  end;
  FindClose(sr);
end;


end.
