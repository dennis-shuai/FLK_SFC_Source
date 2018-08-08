unit DllInit;

interface

uses
  Classes, Extctrls, Controls, Forms, SysUtils, Windows, ActiveX, uFormWeight  ;  

procedure InitSajetDll(ParentApplication: TApplication ;uLimit, lLimit : Double ;WeightModel : string='DDT-A1000') ; stdcall; export;
procedure InitDllForm;  stdcall; export;
procedure CloseSajetDll; stdcall; export;
function  ShowWeightForm(DelayTime : double = 0.5) : string; stdcall; export;
function  GetProductWeidght(DelayTime : Double  = 0.5) : string ; stdcall; export;
procedure ShowDllForm ; stdcall; export;

var
  Up_Limit : double = 0 ;
  Low_Limit : double = 0;
  Weight_Model : string = 'DDT-A1000';
  WeightResult : string = '0000.00g';

implementation

procedure Delay(msecs:integer);
var
  FirstTickCount:longint;
begin
  FirstTickCount:= GetTickCount;
  repeat
    Application.ProcessMessages;     //讓系統可以處理別的事件
  until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end ;

procedure CloseSajetDll;
begin
  try
    if WeightForm <> nil then
    begin
      WeightForm.Free;
      WeightForm := nil;
    end;
  except
    on E: Exception do raise Exception.create('(CloseSajetDll)' + E.Message);
  end;
end;

procedure InitSajetDll(ParentApplication: TApplication ;uLimit, lLimit : Double ;WeightModel : string='DDT-A1000') ;
var
  old : TApplication ;
begin
  try
    CloseSajetDll;
    old := Application ;
    Application := ParentApplication ;
    WeightForm := TWeightForm.Create(nil);
    WeightForm.EditUpLimit.Text := FloatToStr(uLimit);
    WeightForm.EditLowLimit.Text := FloatToStr(lLimit);
    Up_Limit := uLimit ;
    Low_Limit := lLimit ;
    Weight_Model := WeightModel ;
    Application := old ;
  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;

procedure InitDllForm ;
begin
  try
    CloseSajetDll;
    WeightForm := TWeightForm.Create(nil);
    WeightForm.EditUpLimit.Text := FloatToStr(20);
    WeightForm.EditLowLimit.Text := FloatToStr(20);
    Up_Limit := 20 ;
    Low_Limit := 20 ;
    Weight_Model := 'DDT-A1000' ;
  except
    on E: Exception do raise Exception.create('(InitSajetDll)' + E.Message);
  end;
end;  

function ShowWeightForm(DelayTime : double = 0.5) : string;
var
  TempWeidght : string ;
begin
  //顯示稱重畫面
  TempWeidght := '';
  WeightForm.Show ;
  WeightForm.Timer1.Enabled := true ;
  if DelayTime <> 0 then
    Delay(Round(DelayTime*1000));

  WeightForm.Timer1.Enabled := False ;
  WeightForm.MSComPort.PortOpen := False ;  //關閉COM口
  WeightResult := Trim(WeightForm.lblReadKG.Caption) ;
  WeightForm.Hide ;
  Result := WeightResult ;

  {TempWeidght := WeightResult ;
  if Pos('通信失敗',TempWeidght) >0 then
  begin
    Result := '電子秤通信失敗,請檢查!';
    Exit ;
  end else if Pos('測量失敗',TempWeidght) >0 then
  begin
    Result := '取得電子秤重量失敗,請檢查!';
    Exit ;
  end;

  TempWeidght := Copy(TempWeidght,1,Length(TempWeidght)-1);
  if (StrToFloat(TempWeidght) >= Low_Limit ) and
     (StrToFloat(TempWeidght) <= Up_Limit) then
  begin
    Result := 'PASS'
  end else
  begin
    Result := '產品重量不合格!';
  end ;}
end;

function GetProductWeidght(DelayTime : Double  = 0.5) : string ;
var
  TempWeidght : string ;
begin
  //顯示稱重畫面
  TempWeidght := '';
  WeightForm.Show ;
  WeightForm.Timer1.Enabled := true ;
  if DelayTime <> 0 then
    Delay(Round(DelayTime*1000));

  WeightForm.Timer1.Enabled := False ;
  WeightForm.MSComPort.PortOpen := False ;
  WeightResult := Trim(WeightForm.lblReadKG.Caption) ;
  WeightForm.Hide ;
  Result := WeightResult ;
  
  {TempWeidght := WeightResult ;
  if Pos('通信失敗',TempWeidght) >0 then
  begin
    Result := '電子秤通信失敗,請檢查!';
    Exit ;
  end else if Pos('測量失敗',TempWeidght) >0 then
  begin
    Result := '取得電子秤重量失敗,請檢查!';
    Exit ;
  end;
  Result := TempWeidght ;}
end;

procedure ShowDllForm ;
begin
  WeightForm.Show ;
end;

initialization
  CoInitialize(nil);
  
finalization
  CoUninitialize ;

end.

