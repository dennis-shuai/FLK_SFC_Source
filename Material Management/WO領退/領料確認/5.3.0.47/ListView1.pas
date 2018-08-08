unit ListView1;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, Graphics, Windows, CommCtrl, Messages;

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
 inherited Create(AOwner);//?��
 FHeaderFont:=TFont.Create;
 FPicture:=TPicture.Create;
 FPicture.OnChange:=PictureChanged;
 OnCustomDraw:=LVCustomDraw;
end;

//==============�R�ۨ�?===================================
destructor TListView1.Destroy;
begin
 FPicture.Free;
 FHeaderFont.Free;
 inherited Destroy;//?��
end;

//==============?�m��?�r�^===============================
procedure TListView1.SetHeaderFont(Value:TFont);
begin
 //??��?�r�^?�m�A?��?FHeaderFomt�p��?�u��A�}��?��??��
 if FHeaderFont<>Value then begin
   FHeaderFont.Assign(Value);
   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?��WindowsAPI�]�G?��?���O�^
 end;
end;

//==============?�m�I��?=================================
procedure TListView1.SetPicture(Value:TPicture);
begin
 //??�I��??�m�A?��??FPicture�p��?�u��
 if FPicture<>Value then
   FPicture.Assign(Value);
end;

//==============TPicture��OnChange�ƥ�???�{==============
procedure TListView1.PictureChanged(Sender:TObject);
begin
 //��?�C��??
 Invalidate;
end;

//==============TListView��OnCustomDraw�ƥ�???�{==========
procedure TListView1.LVCustomDraw(Sender:TCustomListView;const ARect:TRect;var DefaultDraw:Boolean);
begin
 if(FPicture.Graphic<>nil)then begin
   DrawBack;//?��I��?
   SetBkMode(Canvas.Handle,TRANSPARENT);//?��WindowsAPI�A??�����I��??�z���Ҧ�
   ListView_SetTextBKColor(Handle,CLR_NONE);//?��WindowsAPI�A?Item���奻�I��??�z��
 end;
end;

//==============?��I��?==================================
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

//======Windows����?��====================================
procedure TListView1.WndProc(var Message:TMessage);
var
   pDS:PDrawItemStruct;
   phd:PHDNotify;
begin
   inherited WndProc(Message);//?��
   with Message do
       case Msg of
           WM_DRAWITEM:
           begin//��?�C��??
              pDS:=PDrawItemStruct(Message.lParam);
              //�bPDrawItemStruct?�u?�ۤ�����?�ݭn��?�u
              if pDS.CtlType<>ODT_MENU then begin
                  DrawHeaderItem(pDS);
                  Result:=1;
             end;
          end;
          WM_NOTIFY:
          begin
             phd:=PHDNotify(Message.lParam);
             //�bPHDNotify?�u?�ۤ�����?�ݭn��?�u
             if(phd.Hdr.hwndFrom=GetDlgItem(Handle,0))then
             Case phd.Hdr.code of
               //???��??
               HDN_ITEMCLICK,HDN_ITEMCLICKW:
               begin
                   SortColumn(Columns.Items[phd.item]);
                   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?��WindowsAPI
               end;
               //?��?�Χ�?��??
               HDN_ENDTRACK,HDN_ENDTRACKW,HDN_ITEMCHANGED:
               begin
                   SetHeaderStyle(phd);
                   InvalidateRect(GetDlgItem(Handle,0),nil,true);//?��WindowsAPI
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
//�۩w?TListView���ƧǨ�??��TLVCompare
  SortType := TListView1(Item1.ListView).FSortType;
case ParamSort of
 0://�D�C�Ƨ�
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
  else//�l�C�Ƨ�
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

//======�i�b�~��?�Ϊ��ƧǤ�k===================================
procedure TListView1.SortColumn(Column:TListColumn);
var
  i: Integer;
begin
   //?��TListView��CustomSort��?�A���C�Ƨ�
   if FOldCol=Column.Index then
       FaToz := not FAtoZ
    else
      FOldCol:=Column.Index;
   i := 0;
   if FOldCol = 0 then
   begin
     while Trim(Items[i].Caption) = '' do Inc(i);
     if StrToFloatDef(Items[i].Caption,-1) <> -1 then
       FSortType := 1
     else if StrToDateTimeDef(Items[i].Caption,0) <> 0 then
       FSortType := 2
     else FSortType := 0;
   end
   else
   begin
     while Trim(Items[i].SubItems[FOldCol-1]) = '' do Inc(i);
     if StrToFloatDef(Items[i].SubItems[FOldCol-1],-1) <> -1 then
       FSortType := 1
     else if StrToDateTimeDef(Items[i].SubItems[FOldCol-1],0) <> 0 then
       FSortType := 2
     else FSortType := 0;
   end;
   AtoZOrder:=FaToz;
   CustomSort(@CustomSortProc,Column.Index);
end;

//======?���?�奻�M?��=======================================
procedure TListView1.DrawHeaderItem(pDS:PDrawItemStruct);
var
  tmpCanvas:TCanvas;
  tmpLeft:Integer;
begin
  tmpCanvas:=TCanvas.Create;
  tmpCanvas.Font:=FHeaderFont;
  tmpCanvas.Brush.Color:=clBtnFace;
  //��?��r
  tmpCanvas.Handle:=pDS.hDC;
  tmpCanvas.Brush.Style:=bsClear;
  tmpCanvas.TextOut(pDS^.rcItem.Left+6,pDS^.rcItem.Top+2,Columns[pDS^.itemID].Caption);
  //?��b?
  if(abs(pDS^.itemID)<>FOldCol)then Exit;
    with tmpCanvas do
       with pDS^.rcItem do
       begin
         tmpLeft:=TextWidth(Columns[pDS^.itemID].Caption)+Left+15;
         if FAtoZ then begin//?�b?�V�W
         Pen.Color:=clBtnHighlight;
         MoveTo(tmpLeft,Bottom-5);
         LineTo(tmpLeft+8,Bottom-5);
         Pen.Color:=clBtnHighlight;
         LineTo(tmpLeft+4,Top+5);
         Pen.Color:=clBtnShadow;
         LineTo(tmpLeft,Bottom-5);
       end else begin//?�b?�V�U
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

//========?�m��??��===============================================
procedure TListView1.SetHeaderStyle(phd:PHDNotify);
var
 i:integer;
 hdi:THDItem;
begin
  for i:=0 to Columns.Count-1 do
  begin
    hdi.Mask:=HDF_STRING or HDI_FORMAT;
    hdi.fmt:=HDF_STRING or HDF_OWNERDRAW;//?�m��??��?��?��
    Header_SetItem(phd.Hdr.hwndFrom,i,hdi);//?��WindowsAPI
  end;
//�`�N�G�p�G��?�Φ�?�{�A���\��?�b�e��?�?��?����Q�M����
end;

//=====================================================================
end.
