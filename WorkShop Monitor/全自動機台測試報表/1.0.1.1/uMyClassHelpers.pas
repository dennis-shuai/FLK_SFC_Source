unit uMyClassHelpers;
{实现窗体自适应调整尺寸以适应不同屏幕分辩率的显示问题。
        陈小斌，2012年3月5日
}

interface
Uses
  SysUtils,Windows,Classes,Graphics, Controls,Forms,Dialogs, Math,
  typinfo;

Const   //记录设计时的屏幕分辨率
   OriWidth=1600;
   OriHeight=857;

Type

  TfmForm=Class(TForm)   //实现窗体屏幕分辨率的自动调整
  Private
    fScrResolutionRateW: Double;
    fScrResolutionRateH: Double;
    fIsFitDeviceDone: Boolean;
    procedure FitDeviceResolution;
  Protected
    Property IsFitDeviceDone:Boolean Read fIsFitDeviceDone;
    Property ScrResolutionRateH:Double Read fScrResolutionRateH;
    Property ScrResolutionRateW:Double Read fScrResolutionRateW;
  Public
    Constructor Create(AOwner: TComponent); Override;
  End;

  TfdForm=Class(TfmForm)   //增加对话框窗体的修改确认
  Protected
    fIsDlgChange:Boolean;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Property IsDlgChange:Boolean Read fIsDlgChange default false;
  End;

implementation

constructor TfmForm.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fScrResolutionRateH:=1;
  fScrResolutionRateW:=1;
  Try
    if Not fIsFitDeviceDone then
    Begin
      FitDeviceResolution;
      fIsFitDeviceDone:=True;
    End;
  Except
    fIsFitDeviceDone:=False;
  End;
end;
function PropertyExists(const AObject: TObject;const APropName:String):Boolean;
 //判断一个属性是否存在
 var
   PropInfo:PPropInfo;
 begin
   PropInfo:=GetPropInfo(AObject.ClassInfo,APropName);
   Result:=Assigned(PropInfo);
 end;

function GetObjectProperty(
     const AObject   : TObject;
     const APropName : string
     ):TObject;
 var
   PropInfo:PPropInfo;
 begin
   Result  :=  nil;
   PropInfo:=GetPropInfo(AObject.ClassInfo,APropName);
   if Assigned(PropInfo) and
       (PropInfo^.PropType^.Kind = tkClass) then
     Result  :=  GetObjectProp(AObject,PropInfo);
end;

procedure TfmForm.FitDeviceResolution;
Var
  LocList:TList;
  LocFontRate:Double;
  LocFontSize:Integer;
  LocFont:TFont;
  locK:Integer;
{计算尺度调整的基本参数}
  Procedure CalBasicScalePars;
  Begin
    try
      Self.Scaled:=False;
      fScrResolutionRateH:=screen.height/OriHeight;
      fScrResolutionRateW:=screen.Width/OriWidth;
      LocFontRate:=Min(fScrResolutionRateH,fScrResolutionRateW);
    except
      Raise;
    end;
  End;

{保存原有坐标位置：利用递归法遍历各级容器里的控件，直到最后一级}
  Procedure ControlsPostoList(vCtl:TControl;vList:TList);
  Var
    locPRect:^TRect;
    i:Integer;
    locCtl:TControl;
    locFontp:^Integer;
  Begin
    try
      New(locPRect);
      locPRect^:=vCtl.BoundsRect;
      vList.Add(locPRect);
      If PropertyExists(vCtl,'FONT') Then
      Begin
        LocFont:=TFont(GetObjectProperty(vCtl,'FONT'));
        New(locFontp);
        locFontP^:=LocFont.Size;
        vList.Add(locFontP);
//        ShowMessage(vCtl.Name+'Ori:='+InttoStr(LocFont.Size));
      End;
      If vCtl Is TWinControl Then
        For i:=0 to TWinControl(vCtl).ControlCount-1 Do
        begin
          locCtl:=TWinControl(vCtl).Controls[i];
          ControlsPosToList(locCtl,vList);
        end;
    except
      Raise;
    end;
  End;

{计算新的坐标位置：利用递归法遍历各级容器里的控件，直到最后一层。
 计算坐标时先计算顶级容器级的，然后逐级递进}
  Procedure AdjustControlsScale(vCtl:TControl;vList:TList;Var vK:Integer);
  Var
    locOriRect,LocNewRect:TRect;
    i:Integer;
    locCtl:TControl;
  Begin
    try
      If vCtl.Align<>alClient Then
      Begin
        locOriRect:=TRect(vList.Items[vK]^);
        With locNewRect Do
        begin
          Left:=Round(locOriRect.Left*fScrResolutionRateW);
          Right:=Round(locOriRect.Right*fScrResolutionRateW);
          Top:=Round(locOriRect.Top*fScrResolutionRateH);
          Bottom:=Round(locOriRect.Bottom*fScrResolutionRateH);
          vCtl.SetBounds(Left,Top,Right-Left,Bottom-Top);
        end;
      End;
      If PropertyExists(vCtl,'FONT') Then
      Begin
        Inc(vK);
        LocFont:=TFont(GetObjectProperty(vCtl,'FONT'));
        locFontSize:=Integer(vList.Items[vK]^);
        LocFont.Size := Round(LocFontRate*locFontSize);
//        ShowMessage(vCtl.Name+'New:='+InttoStr(LocFont.Size));
      End;
      Inc(vK);
      If vCtl Is TWinControl Then
        For i:=0 to TwinControl(vCtl).ControlCount-1 Do
        begin
          locCtl:=TWinControl(vCtl).Controls[i];
          AdjustControlsScale(locCtl,vList,vK);
        end;
    except
      Raise;
    end;
  End;

{释放坐标位置指针和列表对象}
  Procedure FreeListItem(vList:TList);
  Var
    i:Integer;
  Begin
    For i:=0 to vList.Count-1 Do
      Dispose(vList.Items[i]);
    vList.Free;
  End;

begin
  LocList:=TList.Create;
  Try
    Try
      if (Screen.width<>OriWidth)OR(Screen.Height<>OriHeight) then
      begin
        CalBasicScalePars;
//        AdjustComponentFont(Self);
        ControlsPostoList(Self,locList);
        locK:=0;
        AdjustControlsScale(Self,locList,locK);

      End;
    Except on E:Exception Do
      Raise Exception.Create('进行屏幕分辨率自适应调整时出现错误'+E.Message);
    End;
  Finally
    FreeListItem(locList);
  End;
end;


{ TfdForm }

constructor TfdForm.Create(AOwner: TComponent);
begin
  inherited;
  fIsDlgChange:=False;
end;

end.
