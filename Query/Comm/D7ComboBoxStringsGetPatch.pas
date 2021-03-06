unit D7ComboBoxStringsGetPatch;

// The patch fixes TCustomComboBoxStrings.Get method for empty string item in Delphi 7.

interface

{$IF RTLVersion <> 15.0}
'This patch is intended for Delphi 7 only';
{$IFEND}

implementation

uses
  Windows, SysUtils, StdCtrls;

resourcestring
  RsPatchingFailed = 'TCustomComboBoxStrings.Get patching failed.';

type
  TPatchResult = (prNotNeeded, prOk, prError);

function PatchCode(RoutineStartAddr: Pointer; PatchOffset: Cardinal; OriginalCode: Pointer;
  OriginalCodeLen: Cardinal; PatchedCode: Pointer; PatchedCodeLen: Cardinal): TPatchResult;
const
  JmpOpCode = $25FF;
type
  PPackageThunk = ^TPackageThunk;
  TPackageThunk = packed record
    JmpInstruction: Word;
    JmpAddress: PPointer;
  end;
var
  CodeStart: Pointer;
  BytesWritten: DWORD;
begin
  if FindClassHInstance(System.TObject) <> HInstance then
    with PPackageThunk(RoutineStartAddr)^ do
      if JmpInstruction = JmpOpCode then
        RoutineStartAddr := JmpAddress^
      else
      begin
        Result := prError;
        Exit;
      end;
  CodeStart := Pointer(LongWord(RoutineStartAddr) + PatchOffset);
  if CompareMem(CodeStart, OriginalCode, OriginalCodeLen) then
  begin
    if WriteProcessMemory(GetCurrentProcess, CodeStart, PatchedCode, PatchedCodeLen, BytesWritten) and
      (BytesWritten = PatchedCodeLen) then
    begin
      FlushInstructionCache(GetCurrentProcess, CodeStart, PatchedCodeLen);
      Result := prOk;
    end
    else
      Result := prError;
  end
  else
    Result := prNotNeeded;
end;

type
  TCustomComboBoxStringsHack = class(TCustomComboBoxStrings);

function AddrOfTCustomComboBoxStringsGet: Pointer;
begin
  Result := @TCustomComboBoxStringsHack.Get;
end;

procedure PatchTCustomComboBoxStringsGet;
const
  OriginalCode: Cardinal = $74FFF883; // CMP EAX, -1 | JZ  +$26
  PatchedCode: Cardinal = $7E00F883; // CMP EAX,  0 | JLE +$26
  PatchOffset = $1F;
  // for DEBUG DCU by Pavel Rogulin
  OriginalCodeD: Cardinal = $FFF07D83;
  PatchedCodeD: Cardinal = $00F07D83;
  PatchOffsetD = $2E;
var
  PatchResult: TPatchResult;
begin
  PatchResult := PatchCode(AddrOfTCustomComboBoxStringsGet, PatchOffset, @OriginalCode, SizeOf(OriginalCode),
    @PatchedCode, SizeOf(PatchedCode));
  if PatchResult = prNotNeeded then
    PatchResult := PatchCode(AddrOfTCustomComboBoxStringsGet, PatchOffsetD, @OriginalCodeD, SizeOf(OriginalCodeD),
      @PatchedCodeD, SizeOf(PatchedCodeD));
  case PatchResult of
    prError:
      begin
        if IsConsole then
          WriteLn(ErrOutput, RsPatchingFailed)
        else
          MessageBox(0, PChar(RsPatchingFailed), nil, MB_OK or MB_ICONSTOP or MB_TASKMODAL);
        RunError(1);
      end;
  end;
end;

initialization
  PatchTCustomComboBoxStringsGet;

end.
