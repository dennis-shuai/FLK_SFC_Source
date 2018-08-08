5.3.0.24
2007/07/30
1.Transfer UnConfirm can not Release Reel;
=============================================================
5.3.0.23
2007/07/09
1.Get FIFO Code 改成call Procedure: SAJET.SJ_GET_fifo
===============================================================
5.3.0.22
2007/06/14
1.增加FIFO Code;
============================================================
5.3.0.21
2006/11/27
5.3.0.21
 1.增加动作type;
 2.当前状态insert into sajet.g_material; 
==================================================
5.3.0.20
 1.未入库的material_no不可以release reel;
================================================
5.3.0.18
2006/10/13
1.穝糤Table魁ゼ甶ЧMaterial
CREATE TABLE SAJET.G_MATERIAL_TEMP (
  RT_ID NUMBER(*),
  PART_ID NUMBER(*) NOT NULL,
  DATECODE VARCHAR2(25),
  MATERIAL_NO VARCHAR2(25),
  MATERIAL_QTY NUMBER(*) NOT NULL,
  REEL_NO VARCHAR2(25),
  REEL_QTY NUMBER(*),
  STATUS VARCHAR2(15) DEFAULT 0,
  LOCATE_ID NUMBER(*),
  WAREHOUSE_ID NUMBER(*),
  UPDATE_USERID NUMBER(*),
  UPDATE_TIME DATE DEFAULT SYSDATE,
  REMARK VARCHAR2(50),
  RELEASE_QTY NUMBER(*) DEFAULT 0,
  VERSION VARCHAR2(25),
  MFGER_NAME VARCHAR2(25),
  MFGER_PART_NO VARCHAR2(25)
) TABLESPACE SYSRT;
grant select, insert, update, delete on SAJET.G_MATERIAL_TEMP to sys_user;
2.Reel_NoSequence拜肈, 叫эTo_Label, 叫盢セ琩高g_materialэg_material_temp
==============================================================
5.3.0.17
2006/09/13
1. 穝糤恶g_materilversion
==============================================================
5.3.0.15
2006/08/22
1.第二次展的时候,Remark没有更新
==============================================================
5.3.0.14
2006/08/18
1.由之前只能展BOX改为同时可以展QTYID
==============================================================
5.3.0.13
2006/08/18
1.填写所刷的DATECODE
==============================================================
5.3.0.12
2006/08/18
1.由之前自动展改为刷DATECODE与上一次刷的DATECODE比对在进行列印
2.改界面
==============================================================
5.3.0.11
2006/08/16
1.穝糤锣糶 (sys_base穝糤掸Param_Name = Material Caps Lock)
2.穝糤Reprint
==============================================================
5.3.0.10
2006/08/03
1.穝糤MFGER_NAME, MFGER_PART_NO
==============================================================
5.3.0.8
2006/07/20
1.块Reel, SelectAll
==============================================================
5.3.0.6
2006/07/12
1.ゼ盢Status狡籹, 硑ΘBox Id篈ぃ璓
==============================================================
5.3.0.5
2006/07/10
1.Material NoэBox ID
2.笆璸衡计秖, 盿程, 璸衡, 程计秖逞緇计
==============================================================
5.3.0.4
2006/07/05
1.砆Release计秖璸衡Τ拜肈 (璝Release掸)
2.钡B秨繷TypeBox ID腹絏
==============================================================
2006/07/04
1.Default Qtyゼ
2.甶秨ゼ盢Locate_id, Warehouse_id恶穝玻ネReel ID柑 (穦硑Θ烩拜肈)