5.3.0.24
2007/07/30
1.Transfer UnConfirm can not Release Reel;
=============================================================
5.3.0.23
2007/07/09
1.Get FIFO Code �ĳ�call Procedure: SAJET.SJ_GET_fifo
===============================================================
5.3.0.22
2007/06/14
1.����FIFO Code;
============================================================
5.3.0.21
2006/11/27
5.3.0.21
 1.���Ӷ���type;
 2.��ǰ״̬insert into sajet.g_material; 
==================================================
5.3.0.20
 1.δ����material_no������release reel;
================================================
5.3.0.18
2006/10/13
1.�s�WTable�������i����Material
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
2.Reel_No��Sequence���D, �Эק�To_Label, �бN�쥻�d��g_material�אּg_material_temp
==============================================================
5.3.0.17
2006/09/13
1. �s�W��Jg_materil��version
==============================================================
5.3.0.15
2006/08/22
1.�ڶ���չ��ʱ��,Remarkû�и��¯�
==============================================================
5.3.0.14
2006/08/18
1.��֮ǰֻ��չBOX��Ϊͬʱ����չQTYID��
==============================================================
5.3.0.13
2006/08/18
1.��д��ˢ��DATECODE��
==============================================================
5.3.0.12
2006/08/18
1.��֮ǰ�Զ�չ��ΪˢDATECODE����һ��ˢ��DATECODE�ȶ��ڽ�����ӡ
2.�Ľ����
==============================================================
5.3.0.11
2006/08/16
1.�s�W��j�g�\�� (�bsys_base�s�W�@��Param_Name = Material Caps Lock�Y�i)
2.�s�WReprint�\��
==============================================================
5.3.0.10
2006/08/03
1.�s�WMFGER_NAME, MFGER_PART_NO
==============================================================
5.3.0.8
2006/07/20
1.��JReel��, SelectAll
==============================================================
5.3.0.6
2006/07/12
1.���NStatus�ƻs, �y���P�@��Box Id���A���@�P
==============================================================
5.3.0.5
2006/07/10
1.Material No�אּBox ID
2.�۰ʭp��i�C�L�ƶq, �a�X�̤j��, �p���, �̫�@�Ӽƶq���Ѿl��
==============================================================
5.3.0.4
2006/07/05
1.�w�QRelease���ƶq�p�⦳���D (�Y��Release�@��)
2.�u����B�}�Y�BType��Box ID�����X
==============================================================
2006/07/04
1.Default Qty���N�J
2.�i�}�ɥ��NLocate_id, Warehouse_id��J�s���ͪ�Reel ID�� (�|�y����ƪ����D)