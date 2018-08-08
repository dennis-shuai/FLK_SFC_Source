unit unitTreeView;

interface

uses ComCtrls,sysutils,classes;

  procedure G_addTreeData(f_target:TTreeView;f_tsData:tstrings;f_iCol :integer); overload;
  procedure G_addTreeData(f_targetData,f_targetIndex:TTreeView;f_tsData,f_tsIndex:tstrings;f_iCol :integer); overload;

implementation

//同時傳入index和data的資料來新增tree的資料
procedure G_addTreeData(f_targetData,f_targetIndex:TTreeView;f_tsData,f_tsIndex:tstrings;f_iCol :integer); overload;
var i,j,iLevel : integer;
    NodePareantIndex,NodeChildIndex,NodeParentData,NodeChildData : TTreeNode;
    bNull,bVisibleData,bVisibleIndex : boolean; //記錄這個點是否有資料要記錄，如果沒有的話，之後的CHILD也不新增
begin
  bVisibleData:=f_targetData.Visible;
  bVisibleIndex:=f_targetIndex.Visible;
  try
    //隱藏TTREE
    f_targetData.Visible:=false;
    f_targetIndex.Visible:=false;
    try
      //清除TTREE上原本的資料
      f_targetData.Items.Clear;
      f_targetIndex.Items.Clear;

      bNull:=false;
      NodeChildIndex:=nil;
      NodeChildData:=nil;
      for i:=1 to f_tsIndex.count do begin
        //取得現在要加的資料，其LEVEL
        iLevel:=(i-1) mod f_iCol;
        //如果兩邊的資料都為NULL，則將其FLAG設為TRUE
        if (f_tsIndex[i-1]='') and (f_tsData[i-1]='') then bNull:=true;

        //如果LEVEL為0則將PARENT設為NULL，若為否，則將PARENT設為原本的CHILD
        if (iLevel=0) then begin
          NodePareantIndex:=nil;
          NodeParentData:=nil;
          bNull:=false;
        end
        else begin
          NodePareantIndex:=NodeChildIndex;
          NodeParentData:=NodeChildData;
        end;
        //將NODECHILD先假設為NIL
        NodeChildIndex:=nil;
        NodeChildData:=nil;

        if not bNull then begin
          //由TTREE上由後往前找之前相同LEVEL的NODE，其值是否相同，若是則將NodeChild指向那個node
          //假如index沒值的話，則以data的值為主
          if iLevel=0 then begin
            if f_tsIndex[i-1]<>'' then begin
              for j:=f_targetIndex.Items.Count downto 1 do begin
                if f_targetIndex.Items.Item[j-1].Level=iLevel then begin
                  if (f_targetIndex.Items.Item[j-1].text=f_tsIndex[i-1]) then begin
                    NodeChildIndex:=f_targetIndex.Items.Item[j-1];
                    NodeChildData:=f_targetData.Items.Item[NodeChildIndex.AbsoluteIndex];
                  end;
                  break;
                end;
              end;
            end
            else begin
              for j:=f_targetData.Items.Count downto 1 do begin
                if f_targetdata.Items.Item[j-1].Level=iLevel then begin
                  if (f_targetData.Items.Item[j-1].text=f_tsData[i-1]) then begin
                    NodeChildData:=f_targetData.Items.Item[j-1];
                    NodeChildIndex:=f_targetIndex.Items.Item[NodeChildData.AbsoluteIndex];
                  end;
                  break;
                end;
              end;
            end;
          end
          else begin
            if f_tsIndex[i-1]<>'' then begin
              for j:=NodePareantIndex.Count downto 1 do begin
                if NodePareantIndex.Item[j-1].Level=iLevel then begin
                  if (NodePareantIndex.Item[j-1].text=f_tsIndex[i-1]) then begin
                    NodeChildIndex:=NodePareantIndex.Item[j-1];
                    NodeChildData:=f_targetData.Items.Item[NodeChildIndex.AbsoluteIndex];
                  end;
                  break;
                end;
              end;
            end
            else begin
              for j:=NodeParentData.Count downto 1 do begin
                if NodeParentData.Item[j-1].Level=iLevel then begin
                  if (NodeParentData.Item[j-1].text=f_tsData[i-1]) then begin
                    NodeChildData:=NodeParentData.Item[j-1];
                    NodeChildIndex:=f_targetIndex.Items.Item[NodeChildData.AbsoluteIndex];
                  end;
                  break;
                end;
              end;
            end;
          end;


          //若NodeChild還是為nil，則代表他與同個level上的前個node的值不同，須新增
          if (NodeChildIndex=nil) and (NodeChildData=nil) then begin
            //新增data tree上的nodeChild

            NodeChildData:=f_targetData.Items.AddChild(NodeParentData,f_tsData[i-1]);
            NodeChildData.ImageIndex:=NodeChildData.Level;
            NodeChildData.SelectedIndex:=NodeChildData.Level;

            //新增Index tree上的nodeChild
            NodeChildIndex:=f_targetIndex.Items.AddChild(NodePareantIndex,f_tsIndex[i-1]);
            NodeChildIndex.ImageIndex:=NodeChildIndex.Level;
            NodeChildIndex.SelectedIndex:=NodeChildIndex.Level;
          end;
        end;
      end;
    except
      on E:exception do raise Exception.create('(addTreeData)'+E.Message);
    end;
  finally
    f_targetData.visible:=bVisibleData;
    f_targetIndex.Visible:=bVisibleIndex;
  end;
end;


procedure G_addTreeData(f_target:TTreeView;f_tsData:tstrings;f_iCol :integer);
var i,j,iLevel : integer;
    NodePareant,NodeChild : TTreeNode;
    bNull,bVisibleData : boolean; //記錄這個點是否有資料要記錄，如果沒有的話，之後的CHILD也不新增
begin
  bVisibleData:=f_target.Visible;
  try
    //隱藏TTREE
    f_target.Visible:=false;
    try
      //清除TTREE上原本的資料
      f_target.Items.Clear;

      bNull:=false;
      NodeChild:=nil;
      for i:=1 to f_tsData.count do begin
        //取得現在要加的資料，其LEVEL
        iLevel:=(i-1) mod f_iCol;
        //如果兩邊的資料都為NULL，則將其FLAG設為TRUE
        if (f_tsData[i-1]='') then bNull:=true;

        //如果LEVEL為0則將PARENT設為NULL，若為否，則將PARENT設為原本的CHILD
        if (iLevel=0) then begin
          NodePareant:=nil;
          bNull:=false;
        end
        else begin
          NodePareant:=NodeChild;
        end;
        //將NODECHILD先假設為NIL
        NodeChild:=nil;

        if not bNull then begin
          //由TTREE上由後往前找之前相同LEVEL的NODE，其值是否相同，若是則將NodeChild指向那個node
          if iLevel=0 then begin
            for j:=f_target.Items.Count downto 1 do begin
              if f_target.Items.Item[j-1].Level=iLevel then begin
                if (f_target.Items.Item[j-1].text=f_tsData[i-1]) then begin
                  NodeChild:=f_target.Items.Item[j-1];
                end;
                break;
              end;
            end;
          end
          else begin
            for j:=NodePareant.Count downto 1 do begin
              if NodePareant.Item[j-1].Level=iLevel then begin
                if (NodePareant.Item[j-1].text=f_tsData[i-1]) then begin
                  NodeChild:=NodePareant.Item[j-1];
                  NodeChild:=f_target.Items.Item[NodeChild.AbsoluteIndex];
                end;
                break;
              end;
            end;
          end;


          //若NodeChild還是為nil，則代表他與同個level上的前個node的值不同，須新增
          if (NodeChild=nil)  then begin
            //新增 tree上的nodeChild
            NodeChild:=f_target.Items.AddChild(NodePareant,f_tsData[i-1]);
            NodeChild.ImageIndex:=NodeChild.Level;
            NodeChild.SelectedIndex:=NodeChild.Level;
          end;
        end;
      end;
    except
      on E:exception do raise Exception.create('(addTreeData)'+E.Message);
    end;
  finally
    f_target.visible:=bVisibleData;
  end;
end;
end.
