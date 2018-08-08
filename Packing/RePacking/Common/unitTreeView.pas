unit unitTreeView;

interface

uses ComCtrls,sysutils,classes,dialogs;

  procedure G_addTreeData(f_target:TTreeView;f_tsData:tstrings;f_iCol :integer); overload;
  procedure G_addTreeData(f_targetData,f_targetIndex:TTreeView;f_tsData,f_tsIndex:tstrings;f_iCol :integer); overload;
  procedure G_moveTreeData(f_tvSource,f_tvOther : TTreeView;f_tsAllData,f_tsSourceData:tstrings;f_iCol :integer);
  procedure G_getTreeDataToTstrings(f_tvSource : TTreeView;f_tsSourceData : tstrings;f_iCount:integer);
implementation


procedure G_getTreeDataToTstrings(f_tvSource : TTreeView;f_tsSourceData : tstrings;f_iCount:integer);
var i,j : integer;
    tsData : tstrings;
    node : TTreeNode;
begin
  try
    tsData:=TStringList.create;
    try
      f_tsSourceData.clear;
      if f_tvSource.Items.Count=0 then exit;
      for i:=1 to f_tvSource.Items.Count do begin
        if f_tvSource.Items.item[i-1].Level>=f_iCount then raise Exception.Create('Data Level Error');
        if f_tvSource.Items.Item[i-1].Count<>0 then continue;
        node := f_tvSource.Items.Item[i-1];
        tsData.Clear;
        while node.Level<>0 do begin
          tsData.insert(0,node.Text);
          node:=node.Parent;
        end;
        tsData.insert(0,node.Text);

        if tsData.Count>f_iCount then raise Exception.Create('Get Data Error');
        while tsData.Count<f_iCount do tsData.add('');

        for j:=1 to tsData.Count do f_tsSourceData.Add(tsData[j-1]);
      end;
    finally
      tsData.free;
    end;
  except
    on E:Exception do raise Exception.Create('(G_getTreeDataToTstrings)'+E.Message);
  end;
end;


procedure G_moveTreeData(f_tvSource,f_tvOther : TTreeView;f_tsAllData,f_tsSourceData:tstrings;f_iCol :integer);
var tsSource,tsOther : tstrings;
    i,j : integer;
    bSame : boolean;
begin
  try
    tsSource:=TStringList.create;
    tsOther:=TStringList.create;
    try
      if (f_tsAllData.Count mod f_iCol)<>0 then raise Exception.Create('All Data Count Error');
      if (f_tsSourceData.Count mod f_iCol)<>0 then raise Exception.Create('Source Data Count Error');


      for i:=1 to f_tsSourceData.Count do tsSource.Add(f_tsSourceData[i-1]);

      for i:=1 to (f_tsAllData.Count div f_iCol)  do begin
        if tsSource.Count=0 then bSame:=false
        else  begin
          bSame := true;
          for j:=1 to   f_iCol do begin
            if f_tsAllData[((i-1)*f_iCol)+j-1]<>tsSource[j-1] then begin
              bSame:=false;
              break;
            end;
          end;
        end;

        if bSame then for j:=1 to f_iCol do tsSource.Delete(0)
        else for j:=1 to f_iCol do tsOther.add(f_tsAllData[((i-1)*f_iCol)+j-1]);
      end;

      if tsSource.Count<>0 then raise Exception.Create('Source Data Error');
      G_addTreeData(f_tvSource,f_tsSourceData,f_iCol);
      G_addTreeData(f_tvOther,tsOther,f_iCol);
    finally
      tsSource.free;
      tsOther.free;
    end;
  except
    on E:Exception do raise Exception.create('(G_moveTreeData)'+E.Message);
  end;
end;


//�P�ɶǤJindex�Mdata����ƨӷs�Wtree�����
procedure G_addTreeData(f_targetData,f_targetIndex:TTreeView;f_tsData,f_tsIndex:tstrings;f_iCol :integer); overload;
var i,j,iLevel : integer;
    NodePareantIndex,NodeChildIndex,NodeParentData,NodeChildData : TTreeNode;
    bNull,bVisibleData,bVisibleIndex : boolean; //�O���o���I�O�_����ƭn�O���A�p�G�S�����ܡA���᪺CHILD�]���s�W
begin
  bVisibleData:=f_targetData.Visible;
  bVisibleIndex:=f_targetIndex.Visible;
  try
    //����TTREE
    f_targetData.Visible:=false;
    f_targetIndex.Visible:=false;
    try
      //�M��TTREE�W�쥻�����
      f_targetData.Items.Clear;
      f_targetIndex.Items.Clear;

      bNull:=false;
      NodeChildIndex:=nil;
      NodeChildData:=nil;
      for i:=1 to f_tsIndex.count do begin
        //���o�{�b�n�[����ơA��LEVEL
        iLevel:=(i-1) mod f_iCol;
        //�p�G���䪺��Ƴ���NULL�A�h�N��FLAG�]��TRUE
        if (f_tsIndex[i-1]='') and (f_tsData[i-1]='') then bNull:=true;

        //�p�GLEVEL��0�h�NPARENT�]��NULL�A�Y���_�A�h�NPARENT�]���쥻��CHILD
        if (iLevel=0) then begin
          NodePareantIndex:=nil;
          NodeParentData:=nil;
          bNull:=false;
        end
        else begin
          NodePareantIndex:=NodeChildIndex;
          NodeParentData:=NodeChildData;
        end;
        //�NNODECHILD�����]��NIL
        NodeChildIndex:=nil;
        NodeChildData:=nil;

        if not bNull then begin
          //��TTREE�W�ѫ᩹�e�䤧�e�ۦPLEVEL��NODE�A��ȬO�_�ۦP�A�Y�O�h�NNodeChild���V����node
          //���pindex�S�Ȫ��ܡA�h�Hdata���Ȭ��D
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


          //�YNodeChild�٬O��nil�A�h�N��L�P�P��level�W���e��node���Ȥ��P�A���s�W
          if (NodeChildIndex=nil) and (NodeChildData=nil) then begin
            //�s�Wdata tree�W��nodeChild

            NodeChildData:=f_targetData.Items.AddChild(NodeParentData,f_tsData[i-1]);
            NodeChildData.ImageIndex:=NodeChildData.Level;
            NodeChildData.SelectedIndex:=NodeChildData.Level;

            //�s�WIndex tree�W��nodeChild
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
    bNull,bVisibleData : boolean; //�O���o���I�O�_����ƭn�O���A�p�G�S�����ܡA���᪺CHILD�]���s�W
begin
  bVisibleData:=f_target.Visible;
  try
    //����TTREE
    f_target.Visible:=false;
    try
      //�M��TTREE�W�쥻�����
      f_target.Items.Clear;

      bNull:=false;
      NodeChild:=nil;
      for i:=1 to f_tsData.count do begin
        //���o�{�b�n�[����ơA��LEVEL
        iLevel:=(i-1) mod f_iCol;
        //�p�G���䪺��Ƴ���NULL�A�h�N��FLAG�]��TRUE
        if (f_tsData[i-1]='') then bNull:=true;

        //�p�GLEVEL��0�h�NPARENT�]��NULL�A�Y���_�A�h�NPARENT�]���쥻��CHILD
        if (iLevel=0) then begin
          NodePareant:=nil;
          bNull:=false;
        end
        else begin
          NodePareant:=NodeChild;
        end;
        //�NNODECHILD�����]��NIL
        NodeChild:=nil;

        if not bNull then begin
          //��TTREE�W�ѫ᩹�e�䤧�e�ۦPLEVEL��NODE�A��ȬO�_�ۦP�A�Y�O�h�NNodeChild���V����node
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


          //�YNodeChild�٬O��nil�A�h�N��L�P�P��level�W���e��node���Ȥ��P�A���s�W
          if (NodeChild=nil)  then begin
            //�s�W tree�W��nodeChild
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
