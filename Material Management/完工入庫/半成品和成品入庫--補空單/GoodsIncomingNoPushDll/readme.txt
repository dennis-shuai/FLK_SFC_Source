5.3.0.21 
2008/10/15
1.畐舦恨北

===============================================
5.3.0.20
2008/09/02
1.畐datacode 畐丁ΑYYYYMMDD

===============================================
5.3.0.19
2008/07/24
箇砞locate sys_part_factory table  い

=================================================
5.3.0.18
2008/05/16
1.ざ穝ORG逆
2.畐穝factory_type g_material tableい
∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽

5.3.0.17
=================
add by key 2008/02/17
complete status 畐
=========================================================


5.3.0.16
=================
add by key 2008/01/18
Τrelease and wip status 畐
=========================================================

5.3.0.15
畐瑈祘恨北筁commtextň,
CommandText := 'select serial_number from sajet.g_sn_status '
      + 'where pallet_no = :pallet_no and out_pdline_time is not null '
      + ' and (next_process<>0 or wip_process<>0) and rownum = 1';
∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽∽
5.3.0.14
2007/07/31
1.Push Title 多传 TPallet、EMPID
=====================================================
5.3.0.13
2007/07/09
1.Get FIFO Code 改成call Procedure: SAJET.SJ_GET_fifo
====================================================
5.3.0.12
2007/07/19
1.增加FIFO Code
========================================================
5.3.0.11
1.增加动作type
=================================================================
5．3．0．10
1．当料号没有默认的Locate，取sys_base 的ProductWarehouse 的仓库。

=============================================================
5.3.0.9
2006/09/25
1.タPallet/Lot陪ボ岿粇, 莱赣陪ボMaterial_No, τぃ琌Qc_Lot
==========================================================
5.3.0.8
2006/09/25
1. 浪琩琌畐эΘSAJET.G_GOODS_INCOMING籔SAJET.G_SEMIFINISHED_INCOMING常浪琩, ㄏノ岿粇硑Θ畐
==========================================================
5.3.0.7
2006/09/25
1. タΘ珇Qty ID滦畐拜肈
==========================================================
5.3.0.6
2006/09/21
1.Lot畐эΘパQc by Lot玻ネMaterial No, 畐, ┮ぃノ兵絏
==========================================================
5.3.0.4
2006/09/19
1.Θ珇ノLot畐, 惠Lot Qc(SAJET.G_QC_LOT.QC_TYPE = 1Θ珇畐) 
2.逆穝糤Material_No
  alter table SAJET.G_SEMIFINISHED_INCOMING add MATERIAL_NO VARCHAR2(25);
  alter table SAJET.G_GOODS_INCOMING add MATERIAL_NO VARCHAR2(25);
==========================================================
5.3.0.3
2006/09/12
1. 穝糤恶g_pick_listのg_materilversion
