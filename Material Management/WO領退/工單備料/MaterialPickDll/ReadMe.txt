5.3.0.47
2009/05/19
1. �ק�g_wo_pick_info table ,�O�s�[sequence and check /confirm ���ɶ��Muser
alter table g_wo_pick_info add add_time date

alter table g_wo_pick_info add add_userid number

alter table g_wo_pick_info add check_time date

alter table g_wo_pick_info add check_userid number

alter table g_wo_pick_info add confirm_time date

alter table g_wo_pick_info  add confirm_userid number

=======================================================
5.3.0.46
2008/06/26
1. �s�[chkmaterialqty����A�̦��P�_�O�_�n�d�߮w�s
========================================

5.3.0.45
2008/05/19
1. �s�[���org ���;
2. �ܮw�u��o�PORG �ۦP��factory id �ۦP�����ơC
========================================
5.3.0.44
2007/8/14
1. �s�[seq for g_wo_pick_info
2. �S����fifo�ޱ������ƴ��ܡ�Unlimit by Fifo��
========================================
5.3.0.43
2007/07/18
1.����check emp ֻ���Է��趨warehosue ���ϡ�
========================================
5.3.0.42
2007/07/04
1.����sql�е�uppercase;
========================================
5.3.0.41
2007/06/26
1.Add FIFFO Code
========================================
5.3.0.38
2006/11/27
1.���Ӷ���type;
2.��ǰ״̬ insert into sajet.g_ht_material;
===========================================
5.3.0.37
2006/09/28
1.�y�����קאּ4�X, �Цۦ�N�y������2�X�����Update��4�X, �Ъ`�N�����׬O�_����
   sajet.g_wo_pick_info, sajet.g_pick_list, sajet.MES_ERP_WIP_ISSUE_RETURN
2.Complete no charge�令9
=========================================
5.3.0.36
2006/09/25
1.�ץ����Unfinish Prepare�ƶq���~�����D
=========================================
5.3.0.35
2006/09/21
1.���[��쪩
  �`�N: �̦n�u�泣���@�q���F, ���MPick Qty�|�����D
  �NSequence��쫬�A�אּVarchar2
  SAJET.G_HT_PICK_LIST 
  SAJET.G_PICK_LIST 
  SAJET.G_WO_PICK_INFO 
  SAJET.MES_TO_ERP_WIP_ISSUE_RETURN 
=========================================
5.3.0.34
2006/09/21
1.�W�[Abnormal Incoming (Ab.In), Abnormal Return (Ab.Out)��Locator (Sys_Part)
2.��Part Type�ƮƤνT�{. (��ALL, �ܦ�W�hPick Qty=Target Qty)
  �s�W���έק諸Procedure�p�U
   alter table sajet.g_wo_pick_info add part_type varchar2(25);
   alter table sajet.g_pick_list add part_type varchar2(25);
   alter table sajet.g_ht_pick_list add part_type varchar2(25);
   A. MES_ERP_WIP_ISSUE_RETURN�W�[TTYPE IN VARCHAR2;
      (�аѦҪ���MES_ERP_WIP_ISSUE_RETURN.prc)
   B. MES_ERP_WIP_ISSUE��TPART�諸��PART_NO���PART_TYPE
      TSEQ=-1�����ζ�PART_TYPE
      (�аѦҪ���MES_ERP_WIP_ISSUE.prc)
=========================================
5.3.0.33
2006/09/19
1.Wo Status=7 (Complete no charge) ���i�H�A���, ��L���A�ҥi��
=========================================
5.3.0.30
2006/09/14
1. StrtoIntDef(Item.SubItems.Strings[1], 0) > StrToIntDef(Item.SubItems.Strings[2], 0) +  StrToIntDef(Item.SubItems.Strings[4], 0) �令
    iQty := StrtoIntDef(Item.SubItems.Strings[1], 0) * (giPick + iQty) / StrToIntDef(lablQty.Caption, 1);
    iQty > StrToIntDef(Item.SubItems.Strings[2], 0) + StrtoIntDef(Item.SubItems.Strings[4], 0)
����: �����Ʈ�, �b�U�@�����}�l�Ƥ��e�O�e�@�������A, �ҥH�|���O��⪺, ����Pick Qty��줣�OEnabled�C��~�|��
=========================================
5.3.0.28
2006/09/14
1.ListView�ܦ���D
=========================================
5.3.0.28
2006/09/13
1.�W�[Open, Prepare
=========================================
5.3.0.27
2006/09/12
1. �s�W��Jg_pick_list��g_materil��version
=========================================
5.3.0.26
2006/09/11
1.Oracle��, A * B / A <> A * (B / A), �|�y��Check�ɷ|�����~
=========================================
5.3.0.25
2006/09/05
1. �ץ�����Locate_ID��, �|���not Instock (�令�u�ˬdWarehouse�O�_���s�b)
=========================================
5.3.0.20
2006/08/24
1.�����i�γѾl�Ʈ�, ���iMapping
2.Mapping�ᦳ�h��, �R���ɥ��N�h���ƦbG_Material_WM�R��
����: �Ьd��G_Material_WM��Group_Wo�O�_��'N/A', ���i���ť�, Select�ɷ|�����D
=========================================
5.3.0.19
2006/08/23
1.Unfinish�����Request = Issue
=========================================
5.3.0.18
2006/08/21
1.�@���⧹��, �P�_�������D
=========================================
5.3.0.17
2006/08/21
1.�s�W��j�g�\�� (�bsys_base�s�W�@��Param_Name = Material Caps Lock�Y�i)
2.Check��, �אּ�����A�� (Oracle�����A���|�����D)
3.��Ʈ�, �Y�@���⧹, �h�����P�_�O�_��>Request, �Y������, ����X�i��̤j��, ���i�W�L�i��̤j�Ƥ�Request�� 
=========================================
5.3.0.16
2006/08/15
1.�W�[�O�_�nPush Title
=========================================
5.3.0.15
2006/08/14
1. �Ǩ�ERP��, ���NITEMID�ǤJ
=========================================
5.3.0.14
2006/08/04
1.�s�WMFGER_NAME, MFGER_PART_NO
=========================================
5.3.0.13
2006/07/20
1.�ץ�WM QTY
2.�u�槹��, ���i�A���
3.�����M���i�QGroup
4.�������T�{���i�QGroup
5.�w�QGroup�����i�A���
=========================================
5.3.0.9
2006/07/14
1.���F�h��, �ץ�G_WO_Group�s�W���Ƭ�N�� (���e��N-1), �s�WGroup Wo=Work Order
=========================================
5.3.0.8
2006/07/14
1.�W��Push Title
2.�YPick Qty=0, TPS�����i�~���� (5.3.0.7��w���i��)
=========================================
5.3.0.7
2006/07/10
Pick:
1.Material No�אּID No
2.Check OK�]�|��ܰT��
3.�s�WCheck����, ��藍���\��ܤ����\��Part No�æb����ListView��2�����X
4.�W�LRequest�|�ܦ���⩳ (Lime)
Confirm:
1.��ܪ�Issue�������w�⪺�ƶq
2.���UConfirm�����ˬd�O�_�j��Reqeust (���ɥu�H������ƶq�O���O�P��ڼƬ۲�)
=========================================
5.3.0.5
2006/07/04
1.�ѨMIssue�ƶq���~�����D
=========================================
YES      : ���M, �i�W�o
NO       : ���M, ���i�W�o
TPS-YES  : �����M, �i�W�o
TPS-NO   : �����M, ���i�W�o
No Check : ���ˬd