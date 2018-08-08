unit ListView1;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, Graphics, Windows, CommCtrl, Messages, Dialogs;

type
  TListView1 = class(TListView)
  private
    FaToz:Boolean;
    FoldCol:Integer;
    FPicture:TPicture;
    FHeaderFont:TFont;
    FSortType: Integer;
    procedure SetHeaderFont(Value:TFont);
    procedure SetHeaderStyle(phd:PHDNotify);
    procedure DrawHeaderItem(pDS:PDrawItemStruct);
    procedure SetPicture(Value:TPicture);
    procedure PictureChanged(Sender:TObject);
    procedure LVCustomDraw(Sender:TCustomListView;const ARect:TRect;var DefaultDraw:Boolean);
    procedure DrawBack;
  protected
    procedure WndProc(var Message:TMessage);override;
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    procedure SortColumn(Column:TListColumn);
  published
    property BackPicture:TPicture read FPicture write SetPicture;
    property HeaderFont:TFont read FHeaderFont write SetHeaderFont;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SAJET', [TListView1]);
end;

constructor TListView1.Create(AOwner:TComponent);
begin
 inherited Create(AOwner);//?承
 FHeaderFont:=TFont.Create;
 FPicture:=TPicture.Create;
 FPicture.OnChange:=PictureChanged;
 OnCustomDraw:=LVCustomDraw;
end;

//==============析构函?===================================
destructor TListView1.Destroy;
begin
 FPicture.Free;
 FHeaderFont.Free;
 inherited Destroy;//?承
end;

//==============?置表?字体===============================
procedure TListView1.SetHeaderFont(Value:TFont);
begin
 //??表?字体?置，?值?FHeaderFomt私有?据域，并重?表??域
 if FHeaderFont<>Value then begin
   FHeaderFont.Assign(Value);
   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?用WindowsAPI（二?函?均是）
 end;
end;

//==============?置背景?=================================
procedure TListView1.SetPicture(Value:TPicture);
begin
 //??背景??置，?值??FPicture私有?据域
 if FPicture<>Value then
   FPicture.Assign(Value);
end;

//==============TPicture的OnChange事件???程==============
procedure TListView1.PictureChanged(Sender:TObject);
begin
 //重?列表??
 Invalidate;
end;

//==============TListView的OnCustomDraw事件???程==========
procedure TListView1.LVCustomDraw(Sender:TCustomListView;const ARect:TRect;var DefaultDraw:Boolean);
begin
 if(FPicture.Graphic<>nil)then begin
   DrawBack;//?制背景?
   SetBkMode(Canvas.Handle,TRANSPARENT);//?用WindowsAPI，??布的背景??透明模式
   ListView_SetTextBKColor(Handle,CLR_NONE);//?用WindowsAPI，?Item的文本背景??透明
 end;
end;

//==============?制背景?==================================
procedure TListView1.DrawBack;
var x,y,dx:Integer;
begin
 x:=0;
 y:=0;
 if Items.Count>0 then begin
   if ViewStyle=vsReport then x:=TopItem.DisplayRect(drBounds).Left
   else x:=Items[0].DisplayRect(drBounds).Left;
   y:=Items[0].DisplayRect(drBounds).Top-2;
 end;
 dx:=x;
 while y<=ClientHeight do begin
   while x<=ClientWidth do begin
     Canvas.Draw(x,y,FPicture.Graphic);
     inc(x,FPicture.Graphic.Width);
   end;
   inc(y,FPicture.Graphic.Height);
   x:=dx;
 end;
end;

//======Windows消息?答====================================
procedure TListView1.WndProc(var Message:TMessage);
var
   pDS:PDrawItemStruct;
   phd:PHDNotify;
begin
   inherited WndProc(Message);//?承
   with Message do
       case Msg of
           WM_DRAWITEM:
           begin//重?列表??
              pDS:=PDrawItemStruct(Message.lParam);
              //在PDrawItemStruct?据?构中有我?需要的?据
              if pDS.CtlType<>ODT_MENU then begin
                  DrawHeaderItem(pDS);
                  Result:=1;
             end;
          end;
          WM_NOTIFY:
          begin
             phd:=PHDNotify(Message.lParam);
             //在PHDNotify?据?构中有我?需要的?据
             if(phd.Hdr.hwndFrom=GetDlgItem(Handle,0))then
             Case phd.Hdr.code of
               //???表??
               HDN_ITEMCLICK,HDN_ITEMCLICKW:
               begin
                   SortColumn(Columns.Items[phd.item]);
                   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?用WindowsAPI
               end;
               //?拖?或改?表??
               HDN_ENDTRACK,HDN_ENDTRACKW,HDN_ITEMCHANGED:
               begin
                   SetHeaderStyle(phd);
                   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?用WindowsAPI
               end;
             end;
         end;
     end;
end;

//=====================================================================
var AtoZOrder:Boolean;

function CustomSortProc(Item1,Item2:TListItem;ParamSort:Integer):Integer;stdcall;
var
  SortType: Integer;
begin
//自定?TListView的排序函??型TLVCompare
  SortType := TListView1(Item1.ListView).FSortType;
case ParamSort of
 0://主列排序
     if AtoZOrder then
     begin
        case SortType of
          0: Result:=lstrcmp(PChar(TListItem(Item1).Caption),PChar(TListItem(Item2).Caption));
          1: Result := Integer(StrToFloatDef(Item1.Caption,-1) < StrToFloatDef(Item2.Caption,-1));
          2: Result := Integer(StrToDateTimeDef(Item1.Caption,0) < StrToDateTimeDef(Item2.Caption,0));
        end;
     end
     else
     begin
        case SortType of
          0: Result:=-lstrcmp(PChar(TListItem(Item1).Caption),PChar(TListItem(Item2).Caption));
          1: Result := Integer(StrToFloatDef(Item1.Caption,-1) > StrToFloatDef(Item2.Caption,-1));
          2: Result := Integer(StrToDateTimeDef(Item1.Caption,0) > StrToDateTimeDef(Item2.Caption,0));
        end;
     end;
  else//子列排序
     if TListItem(Item1).SubItems.Count >= ParamSort then
     begin
        if(AtoZOrder)then
        begin
           case SortType of
             0: Result:=lstrcmp(PChar(TListItem(Item1).SubItems[ParamSort-1]),
                         PChar(TListItem(Item2).SubItems[ParamSort-1]));
             1: Result := Integer(StrToFloatDef(Item1.SubItems[ParamSort-1],-1) < StrToFloatDef(Item2.SubItems[ParamSort-1],-1));
             2: Result := Integer(StrToDateTimeDef(Item1.SubItems[ParamSort-1],0) < StrToDateTimeDef(Item2.SubItems[ParamSort-1],0));
           end;
        end
        else
        begin
           case SortType of
              0: Result:=-lstrcmp(PChar(TListItem(Item1).SubItems[ParamSort-1]),
                         PChar(TListItem(Item2).SubItems[ParamSort-1]));
              1: Result := Integer(StrToFloatDef(Item1.SubItems[ParamSort-1],-1) > StrToFloatDef(Item2.SubItems[ParamSort-1],-1));
              2: Result := Integer(StrToDateTimeDef(Item1.SubItems[ParamSort-1],0) > StrToDateTimeDef(Item2.SubItems[ParamSort-1],0));
           end;
        end;
     end;
  end;
end;

//======可在外部?用的排序方法===================================
procedure TListView1.SortColumn(Column:TListColumn);
var
  i: Integer;
begin
   //?用TListView的CustomSort函?，按列排序
   if Items.Count = 0  then Exit;
   if Items[0].SubItems.Count < Column.Index then Exit;
   if FOldCol=Column.Index then
       FaToz := not FAtoZ
    else
      FOldCol:=Column.Index;
   i := 0;
   if FOldCol = 0 then
   begin
     if Trim(Items[i].Caption) = '' then Inc(i);
     if StrToFloatDef(Items[i].Caption,-1) <> -1 then
       FSortType := 1
     else if StrToDateTimeDef(Items[i].Caption,0) <> 0 then
       FSortType := 2
     else FSortType := 0;
   end
   else
   begin
     if Trim(Items[i].SubItems[FOldCol-1]) = '' then Inc(i);
     if StrToFloatDef(Items[i].SubItems[FOldCol-1],-1) <> -1 then
       FSortType := 1
     else if StrToDateTimeDef(Items[i].SubItems[FOldCol-1],0) <> 0 then
       FSortType := 2
     else FSortType := 0;
   end;
   AtoZOrder:=FaToz;
   CustomSort(@CustomSortProc,Column.Index);
end;

//======?制表?文本和?形=======================================
procedure TListView1.DrawHeaderItem(pDS:PDrawItemStruct);
var
  tmpCanvas:TCanvas;
  tmpLeft:Integer;
begin
  tmpCanvas:=TCanvas.Create;
  tmpCanvas.Font:=FHeaderFont;
  tmpCanvas.Brush.Color:=clBtnFace;
  //重?文字
  tmpCanvas.Handle:=pDS.hDC;
  tmpCanvas.Brush.Style:=bsClear;
  tmpCanvas.TextOut(pDS^.rcItem.Left+6,pDS^.rcItem.Top+2,Columns[pDS^.itemID].Caption);
  //?制箭?
  if(abs(pDS^.itemID)<>FOldCol)then Exit;
    with tmpCanvas do
       with pDS^.rcItem do
       begin
         tmpLeft:=TextWidth(Columns[pDS^.itemID].Caption)+Left+15;
         if FAtoZ then begin//?箭?向上
         Pen.Color:=clBtnHighlight;
         MoveTo(tmpLeft,Bottom-5);
         LineTo(tmpLeft+8,Bottom-5);
         Pen.Color:=clBtnHighlight;
         LineTo(tmpLeft+4,Top+5);
         Pen.Color:=clBtnShadow;
         LineTo(tmpLeft,Bottom-5);
       end else begin//?箭?向下
         Pen.Color:=clBtnShadow;
         MoveTo(tmpLeft,Top+5);
         LineTo(tmpLeft+8,Top+5);
         Pen.Color:=clBtnHighlight;
         LineTo(tmpLeft+4,Bottom-5);
         Pen.Color:=clBtnShadow;
         LineTo(tmpLeft,Top+5);
       end;
     end;
  tmpCanvas.Free;
end;

//========?置表??式===============================================
procedure TListView1.SetHeaderStyle(phd:PHDNotify);
var
 i:integer;
 hdi:THDItem;
begin
  for i:=0 to Columns.Count-1 do
  begin
    hdi.Mask:=HDF_STRING or HDI_FORMAT;
    hdi.fmt:=HDF_STRING or HDF_OWNERDRAW;//?置表??式?自?式
    Header_SetItem(phd.Hdr.hwndFrom,i,hdi);//?用WindowsAPI
  end;
//注意：如果不?用此?程，那么我?在前面?制的?形?不能被清除掉
end;

//=====================================================================
end.
