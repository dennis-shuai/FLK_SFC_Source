unit unitIntraWeb;

interface

uses classes,sysutils,IWAppForm,IWInit,IWTreeview;

procedure G_IWChangeForm(AFormClass: TIWAppFormClass);
procedure G_IWaddTreeData(f_tvTarget : TIWTreeView;f_tsData : tstrings;f_iCol : integer);


implementation

procedure G_IWaddTreeData(f_tvTarget : TIWTreeView;f_tsData : tstrings;f_iCol : integer);
var i,j,k : integer;
    NodeParent,NodeChild : TIWTreeViewItem;
    bNull : boolean; //記錄這個點是否有資料要記錄，如果沒有的話，之後的CHILD也不新增
    bVisibleData : boolean;
begin
  bVisibleData:=f_tvTarget.Visible;
  try
    //隱藏TTREE
    f_tvTarget.Visible:=false;
    try
      //清除TTREE上原本的資料
      f_tvTarget.Items.Clear;

      for i:=1 to (f_tsData.count div f_iCol) do begin
        for j:=1 to f_iCol do begin
          if j=1 then begin
            NodeParent:=nil;
            NodeChild:=nil;
            for k:=f_tvTarget.Items.Count downto 1 do begin
              if f_tvTarget.Items[k-1].Caption=f_tsData[(i-1)*f_iCol+j-1] then begin
                NodeChild:=f_tvTarget.Items[k-1];
                break;
              end;
            end;
            if NodeChild=nil then begin
              NodeChild:=f_tvTarget.Items.add;
              NodeChild.Caption:= f_tsData[(i-1)*f_iCol+j-1];
            end;
          end
          else begin
            NodeParent:=NodeChild;
            NodeChild:=nil;
            for k:=NodeParent.SubItems.Count downto 1 do begin
              if NodeParent.SubItems.Items[k-1].Caption=f_tsData[(i-1)*f_iCol+j-1] then begin
                NodeChild:=NodeParent.SubItems.Items[k-1];
                break;
              end;
            end;
            if NodeChild=nil then begin
              NodeChild:=NodeParent.SubItems.Add;
              NodeChild.Caption:= f_tsData[(i-1)*f_iCol+j-1];
            end;
          end;
        end;
      end;
    except
      on E:exception do raise Exception.create('(G_IWaddTreeData)'+E.Message);
    end;
  finally
    f_tvTarget.visible:=bVisibleData;
  end;
end;


procedure G_IWChangeForm(AFormClass: TIWAppFormClass);
begin
  // Release the current form
  TIWAppForm (  RWebApplication.ActiveForm).Release;
  // Create the next form
  AFormClass.Create(RWebApplication).Show;
end;

end.
