(***************************************************************************)
(**)                                                                     (**)
(**) unit BmpRgn;                                                        (**)
(**)                                                                     (**)
(***************************************************************************)


interface


uses
  Windows,SysUtils, Classes, Graphics, Dialogs, Forms;


(***************************************************************************)
(*          This is the only function you need to call                     *)
(***************************************************************************)
(**)                                                                     (**)
(**)  function BmpToRegion( Form: TForm; Bmp: tbitmap): HRGN;            (**)
(**)                                                                     (**)
(***************************************************************************)


TYPE
  TBooleanArray = array of array of boolean;
  TPointsArray = array of TPoint;

  TRGBTripleRow =array[0..30000]of trgbtriple;
  PRGBTripleRow=^TRGBTripleRow;


VAR
  Mask: TBooleanArray;
  Points: TPointsArray;

  BmpWidth: integer;
  BmpHeight: integer;
  MaskWidth: integer;
  MaskHeight: integer;
  PointCount: integer;

CONST
  ErrSuccess  = 0;
  ErrNoStart  = -1;
  ErrUnclosed = -2;


implementation



(***************************************************************************)
(**)                                                                     (**)
(*   A few utility procedures and functions for debugging purposes         *)
(**)                                                                     (**)
(***************************************************************************)

procedure ShowXY(s: string; x,y: integer);
begin
  ShowMessage( Format('%s %d,%d',[s,x,y]));
end;


procedure DumpMask( filename: string);
var f: TextFile; x,y: integer; c: char;
begin
  AssignFile( f, filename);
  Rewrite(f);
  for y := 0 to MaskHeight-1 do begin
    for x := 0 to MaskWidth-1 do begin
      if mask[x,y] then c := 'X' else c := '.';
      Write(f,c);
    end;
    Writeln(f);
  end;
  CloseFile( f);
end;


procedure DumpPoints( filename: string);
var f: TextFile; i: integer;
begin
  AssignFile( f, filename);
  Rewrite( f);
  if PointCount > 0 then begin
    for i := 0 to PointCount-1 do begin
      with Points[i] do writeln( f, Format('%d -> %d,%d',[i,x,y]));
    end;
  end else begin
    writeln(f, 'Points array is empty');
  end;
  CloseFile( f);
end;


procedure Init( w,h: integer);
begin
  BmpWidth   := w+2;
  BmpHeight  := h+2;
  MaskWidth  := BmpWidth*3;
  MaskHeight := BmpHeight*3;
  PointCount := 0;
  SetLength( Mask,    MaskWidth, MaskHeight);
  SetLength( Points,  BmpWidth * BmpHeight);
end;


procedure CleanupPointers;
begin
  Mask := nil;
  Points := nil;
end;



procedure CreateMask(var Bmp: TBitmap);
var
  x,y:integer;
  r,g,b: byte;
  p: prgbtriplerow;
  TranspColor: TColor;
  Temp: TBitmap;

  procedure SetMaskValues( value: boolean);
  var i,j: integer;
  begin
    for j := 0 to 2 do begin
      for i := 0 to 2 do begin
        mask[x*3+i,y*3+j] := value;
      end;
    end;
  end;

begin
  TranspColor := Bmp.Canvas.Pixels[0,0];
  r := GetRValue( TranspColor);
  g := GetGValue( TranspColor);
  b := GetBValue( TranspColor);

  Temp := TBitmap.Create;
  with Temp do begin
    Width := BmpWidth;
    Height := BmpHeight;
    Canvas.Brush.Color := TranspColor;
    Canvas.FillRect( Rect(0,0,BmpWidth,BmpHeight));
    Canvas.Draw(1,1,Bmp);
  end;
  Temp.PixelFormat := pf24bit;

  for y := 0 to BmpHeight-1 do begin
    p := Temp.Scanline[y];
    for x := 0 to BmpWidth-1 do begin
      with p[x] do begin
        // set mask to false for transparent pixels
        if (rgbtred = r) and (rgbtgreen = g) and (rgbtblue = b)
        then SetMaskValues( false)
        else SetMaskValues( true);
      end;
    end;
  end;

  Temp.Free;
end;



function ConvertMaskToPoints: integer;
var
  x,y: integer;
  startx, starty: integer;
  nextx,  nexty:  integer;
  prev1x, prev1y: integer;
  prev2x, prev2y: integer;


  function Available(px,py: integer): boolean;
  begin
    result := (not ((px = prev1x) and (py = prev1y))) and
              (not ((px = prev2x) and (py = prev2y)));
  end;

  function OnEdge(px,py: integer): boolean;
  begin
    result := (not mask[px+0,py-1]) or // north
              (not mask[px+1,py-1]) or // northeast
              (not mask[px+1,py+0]) or // east
              (not mask[px+1,py+1]) or // southeast
              (not mask[px+0,py+1]) or // south
              (not mask[px-1,py+1]) or // southwest
              (not mask[px-1,py+0]) or // west
              (not mask[px-1,py-1]);   // northwest
  end;

  function SamePoint( p1,p2: TPoint): boolean;
  begin
    result := (p1.x = p2.x) and (p1.y = p2.y);
  end;

begin
  PointCount := 0;

  // find a coordinate where tracing can begin
  startx := -1;
  starty := -1;
  for y := 0 to MaskHeight-1 do begin
    for x := 0 to MaskWidth-1 do begin
      if (startx < 0) or (starty < 0) then begin
        if Mask[x,y] then begin
          startx := x;
          starty := y;
        end;
      end;
    end;
  end;

  // if no starting point found, exit
  if (startx < 0) or (starty < 0) then begin
    result := ErrNoStart;
    exit;
  end;

  // points coordinates are in actual size, not inflated size
  PointCount := 1;
  Points[0] := Point( startx div 3, starty div 3);

  // at startx,starty begin tracing counter of mask
  nextx := startx;
  nexty := starty;
  x := startx;
  y := starty;
  if mask[x+1,y] then begin
    nextx := x+1;
    nexty := y;
  end else
  if mask[x,y+1] then begin
    nextx := x;
    nexty := y+1;
  end;

  prev2x := 0;
  prev2y := 0;
  prev1x := x;
  prev1y := y;
  x := nextx;
  y := nexty;

  repeat

    // north
    if mask[x,y-1] and available(x,y-1) and onedge(x,y-1) then begin
      nextx := x;
      nexty := y-1;
    end else
    // east
    if mask[x+1,y] and available(x+1,y) and onedge(x+1,y) then begin
      nextx := x+1;
      nexty := y;
    end else
    // south
    if mask[x,y+1] and available(x,y+1) and onedge(x,y+1) then begin
      nextx := x;
      nexty := y+1;
    end else
    // west
    if mask[x-1,y] and available(x-1,y) and onedge(x-1,y) then begin
      nextx := x-1;
      nexty := y;
    end;

    // if next not found, then unclosed path so exit
    if (nextx = x) and (nexty = y) then begin
      ShowXY('Unclosed at ',x,y);
      result := ErrUnclosed;
      exit;
    end;

    // if we're not back at the start, add nextx, nexty to points
    if (nextx <> startx) or (nexty <> starty) then begin
      if  not SamePoint( Point(nextx div 3, nexty div 3), Points[ PointCount-1]) then begin
        inc( PointCount);
        Points[PointCount-1] := Point( nextx div 3, nexty div 3);
      end;
      prev2x := prev1x;
      prev2y := prev1y;
      prev1x := x;
      prev1y := y;
      x := nextx;
      y := nexty;
    end;

  until (nextx = startx) and (nexty = starty);
  setlength( Points, PointCount);
  result := ErrSuccess;
end;



// This routine shifts each point by a fixed amount, to compensate
// for forms with differing border styles.
procedure ShiftPoints( var points: tpointsarray; pointcount, xdelta, ydelta: integer);
var i: integer;
begin
  for i := 0 to pointcount-1 do begin
    points[i].x := points[i].x+xdelta;
    points[i].y := points[i].y+ydelta;
  end;
end;



// This routine follows the sequence of points in the outline and
// using LineTo commands, creates a closed path that can then be
// converted to a region.
function PointsToRegion( dc: hDC; points: tpointsarray; pointcount: integer): HRGN;
var i: integer;
begin
  MoveToEx( dc, Points[0].x, Points[0].y, nil);
  BeginPath( dc);
  for i := 1 to pointcount-1 do with points[i] do lineto( dc, x,y);
  EndPath( dc);
  result := PathToRegion( dc);
end;


//---------------------------------------------------------------------
// This is the All-In-One routine and should be the only one that
// you need to call in your program. It calls everything above and
// if all goes well, Voila! - a form with a custom skin created from
// a bitmap.
//
// Parameters:
//   Form - your form (usually Self) in the form's OnCreate handler
//   Bmp  - the bitmap to use for the form's region.
//
// Returns:
//   If successful, a handle to the new region is returned which
//   can then be passed to SetWindowRgn. If not successful, the
//   return value is null, which can also be passed to SetWindowRgn
//   but only serves to draw the entire form.
//----------------------------------------------------------------------
function BmpToRegion( Form: TForm; Bmp: tbitmap): HRGN;
var
  DeltaX, DeltaY, Success: integer;
  rgn: HRGN;
  MenuHandle: HMENU;
begin

  Init( Bmp.Width, Bmp.Height);
  CreateMask( Bmp);
  Success := ConvertMaskToPoints;

  if Success = errSuccess then begin

    DeltaX := -1;
    DeltaY := -1;
    case Form.BorderStyle of

      bsDialog:
      begin
        DeltaX := DeltaX+GetSystemMetrics( sm_cxFixedFrame);
        DeltaY := DeltaY+GetSystemMetrics( sm_cyFixedFrame)
                        +GetSystemMetrics( sm_cyCaption);
      end;
      bsSingle:
      begin
        DeltaX := DeltaX+GetSystemMetrics( sm_cxFixedFrame);
        DeltaY := DeltaY+GetSystemMetrics( sm_cyFixedFrame)
                        +GetSystemMetrics( sm_cyCaption);
      end;
      bsSizeable:
      begin
        DeltaX := DeltaX+GetSystemMetrics( sm_cxSizeFrame);
        DeltaY := DeltaY+GetSystemMetrics( sm_cySizeFrame)
                        +GetSystemMetrics( sm_cyCaption);
      end;
      bsSizeToolWin:
      begin
        DeltaX := DeltaX+GetSystemMetrics( sm_cxSizeFrame);
        DeltaY := DeltaY+GetSystemMetrics( sm_cySizeFrame)
                        +GetSystemMetrics( sm_cySMCaption);
      end;
      bsToolWindow:
      begin
        DeltaX := DeltaX+GetSystemMetrics( sm_cxFixedFrame);
        DeltaY := DeltaY+GetSystemMetrics( sm_cyFixedFrame)
                        +GetSystemMetrics( sm_cySMCaption);
      end;
    end;

    MenuHandle := GetMenu( Form.Handle);
    if MenuHandle <> 0
      then DeltaY := DeltaY + GetSystemMetrics( sm_cyMenu);

    ShiftPoints( Points, PointCount, DeltaX, DeltaY);
    rgn := PointsToRegion( Bmp.Canvas.Handle, Points, PointCount);

  end else begin
    rgn := 0;
  end;

  CleanupPointers;
  result := rgn;

end;


end.
