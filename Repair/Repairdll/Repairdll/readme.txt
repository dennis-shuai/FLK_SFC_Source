5.3.0.27
by key 2009/01/03
1. add sajet.sj_repair_transation_count proc.

=============================================
5.3.0.26
BY KEY 2008/12/23
1.�@REPLACE KP �ɡAKP�����ƮƸ������p�i���G
�h��foxlink �����ƮƸ��i�H�����@�ӫȤ�Ƹ��C

=================================
5.3.0.25
BY key 2008/11/05
1.�@�s�[labrecid ����A�Ω�O���Ͳ��uscan�@defect code���O���ͪ�recid,�Ω�g_sn_repair_point ����first_recid�r�q;
2.  delete ���s�\��s���idelete g_sn_repair_location and g_sn_repair_point table �����ƾڡC


======================================================================
5.3.0.24 
by key 2008/07/08
1.�@�T��sbtnFailSN ����A����d�߲ŦX��e���O���Ҧ��ݭת�sn

============================================================================
5.3.0.23
by key 2008/06/11
��s���e
�@1.�@�P�@SN���ۦPlocation �̦h��ϥΨ⦸�]�Y�P�@SN,�P�@location �u��repair�⦸�^;
  2.  QUERY DUTY AND QUERY REASON_CODE �i�i��Ҵ�d��;
�@3.�@QUERY REPAIR HISTORY REOCRD �[�J�i�d��location and item_no;
  4.  �ק�item_no��check �W�h�A�ϥ�g_wo_pick_list �����ƮƸ��i��d�ߡC
�ססססססססססססססססססססססססססססססססססססס�
5.3.0.22
by key 2008/04/18
��s���e�G
�@�@1.�u��Enabled='Y'�� DEFECT_CODE/REASON_CODE/DUTY_CODE�A�~��[�Jrepair�{���� 
�סססססססססססססססססססססססססססססססססססססס�
5.3.0.21
by key 2008/03/28
��s���e�G
�@�@1.�@defect point �s�[��g_sn_repair_point table���C

�סססססססססססססססססססססססססססססססססססססססססס�
5.3.0.20
by key 2007/9/24
��s���e�G
�@�@1.�@replace kp �ɡAg_sn_keyparts table����item_group �Ȥ����ק�C

��]�p�U�G

�] 5.3.0.19���e��ver���{���Areplace kp�H��Ag_sn_keyparts table����item_group �ȡ@is null --------�{��bug.
�S�]�J�w���{���ncheck�@kp�@count���Ӽ�,�䤤
�@�@  a. �ݭn�]�wkp bom ��kp ,��item_group ��not is null.
      b. ���ݭn�]�wkp bom���@kp,��item_group ��is null.
�@    c. ATE INPUT�{�� �ABDA(EDA) SN MAPPING PCBA  SN��A��item_group ��is null.
       �åB����pcba �O�~�]���A�S��pcba sn�@label.
�]���Gcheck kp�@count ���Ӽƥu�ncheck item_group �Ȭ�not is null��kp �ȧY�i�C
 
===========================================================================
5.3.0.19
by key 2007/9/15
��s���e�G
1. repace kp ���f�Anew kp��줣��input ���N��part_no,cust_part_no,vendor_part_no,
����input �Pold kpsn(�D��or �ƥή�) �ۦP��part_no,cust_part_no,vendor_part_no�~�i�Hreplace kp
2. �p�Gnew kp ���input part_no or cust_partno,vendor_part_no,�åBold kpsn��'N/A'
�~�|��replace.
3. �p�Gold kpsn ='N/A' �A�hinput ��kpno ��part_no or cust_part_no or vendor_part_no
�i�Hreplace kp
4. Repair,Replace,Remove,scrap���v���@�@���}
5. repalce kp ,�N�|check kp ��replace�e�᪺�ӼƬO�_�ۦP�C
6. �s�[new kpno���Achekc kpno(�D��or �ƥή�)�C
7. remove and remove all��kp��ưO���bg_sn_repair_repalce_kp table��.
===============================================================================
5.3.0.18  
by key 2007/9/13
��s���e�p�U�G
1.�@keypars relpace history ��ơСССзs�[query ���s�A���榹���s�~�i��d�ߡC
2.�@sn repaired history ���-------�s�[query���s�A���榹���s�~�i��d�ߡC
3.�@reason history ��ơСССзs�[query���@�A���榹���s�~�i��d�ߡC